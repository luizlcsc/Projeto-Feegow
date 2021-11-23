<!-- #include file = "connect.asp" -->
<%
limite = 100
ConciliacaoID = req("ConciliacaoID")
sqlCC = "select cc.*, t.BandeiraCartaoID, m.AccountIDDebit ContaCartao, IFNULL(conta.CreditAccount,0) ContaBancaria from cartaoconciliacao cc "&_ 
    " LEFT JOIN sys_financialcreditcardreceiptinstallments parc ON parc.id=cc.ParcelaID "&_ 
    " LEFT JOIN sys_financialcreditcardtransaction t ON t.id=parc.TransactionID "&_ 
    " LEFT JOIN sys_financialmovement m ON m.id=t.MovementID "&_ 
    " LEFT JOIN sys_financialcurrentaccounts conta ON conta.id=m.AccountIDDebit "&_ 
    " where "
if ConciliacaoID<>"" then
    ValorLiquido = ref("ValorLiquido")
    ValorClinica = ref("ValorClinica")
    PercentualTaxa = ref("PercentualTaxa")
    ValorTaxa = ccur(ref("ValorTaxa"))
    ValorAntecipacao = ccur(ref("ValorAntecipacao"))
    DataPagto = ref("DataPagto")
    ValorSplit = ccur(ref("ValorSplit"))
    ParcelaID = ref("ParcelaID")
    Parcela = ref("Parcela")
    Parcelas = ref("Parcelas")

    sql = "select parc.*, "&_ 
        " coalesce(t.transactionNumber, t.AuthorizationNumber) Transacao, "&_
        " mPag.AccountIDDebit ContaCartao, "&_ 
        " cc.CreditAccount ContaBancariaRecto, cc.AccountType, cc.Empresa UnidadeCC "&_
        " FROM sys_financialcreditcardreceiptinstallments parc "&_ 
        " INNER JOIN sys_financialcreditcardtransaction t ON t.id=parc.TransactionID "&_ 
        " INNER JOIN sys_financialmovement mPag ON mPag.id=t.MovementID "&_ 
        " INNER JOIN sys_financialcurrentaccounts cc ON mPag.AccountIDDebit=cc.id "&_ 
        " WHERE parc.id="& ParcelaID
    'response.write( sql )
    set parc = db.execute( sql )
    'Apaga a movement da InvoiceReceiptID
    if parc("InvoiceReceiptID")>0 then
        db.execute("delete from sys_financialmovement where id="& parc("InvoiceReceiptID") &" or MovementAssociatedID="& parc("InvoiceReceiptID"))
    end if
    'Cria uma movement com o Name Transação [id da transaction] - Parcela/Parcelas, AccountAssCred/Deb=1, AccCred=Cartao da trans, AccDeb=Conta do cartao da trans, PMID=3, Value=ValorClinica, CD=C, Type=CCCred ou Deb, unidadeID do dono da conta
    db.execute("insert into sys_financialmovement set Name='Transação "& parc("Transacao") &" - "& Parcela &"/"& Parcelas &"', AccountAssociationIDCredit=1, AccountIDCredit="& parc("ContaCartao") &", AccountAssociationIDDebit=1, AccountIDDebit="& treatvalzero(parc("ContaBancariaRecto")) &", PaymentMethodID=3, Value="& treatvalzero(ValorClinica) &", Date="& mydatenull(DataPagto) &", CD='C', Type='CCCred', Currency='BRL', Rate=1, UnidadeID=0, sysUser="& session("User") )
    'Pega o ID dessa movement e grava no InvoiceReceiptID, assim como Fee perc, Value ValorClinica, Split, Anticipation, DateToReceive DataPagto
    set pult = db.execute("select id from sys_financialmovement where Type='CCCred' ORDER BY id desc LIMIT 1")
    MovID = pult("id")
    db.execute("update sys_financialcreditcardreceiptinstallments set DateToReceive="& mydatenull(DataPagto) &", Fee="& treatvalzero(PercentualTaxa) &", Split="& treatvalzero(ValorSplit) &", Anticipation="& treatvalzero(ValorAntecipacao) &", InvoiceReceiptID="& MovID &" WHERE id="& ParcelaID)
    'Cria uma movement com o Name Desc. trans. [id da transaction] - Parcela/Parcelas, AccountAssCred=1, Deb=0, AccCred=Cartao da trans, AccDeb=0, PMID=3, Value=ValorTaxa, CD=C, Type=CCFee, unidadeID do dono da conta
    if ValorTaxa>0 then
        db.execute("insert into sys_financialmovement set Name='Desc. Trans. "& parc("Transacao") &" - "& Parcela &"/"& Parcelas &"', AccountAssociationIDCredit=1, AccountIDCredit="& parc("ContaCartao") &", AccountAssociationIDDebit=0, AccountIDDebit=0, PaymentMethodID=3, Value="& treatvalzero(ValorTaxa) &", Date="& mydatenull(DataPagto) &", CD='C', Type='CCFee', Currency='BRL', Rate=1, MovementAssociatedID="& MovID &", sysUser="& session("User") )
    end if
    'SE SPLIT >0 Cria uma movement com o Name Split trans. [id da transaction] - Parcela/Parcelas, AccountAssCred=1, Deb=0, AccCred=Cartao da trans, AccDeb=0, PMID=3, Value=ValorTaxa, CD=C, Type=CCSpli, unidadeID do dono da conta
    if ValorSplit>0 then
        db.execute("insert into sys_financialmovement set Name='Split Trans. "& parc("Transacao") &" - "& Parcela &"/"& Parcelas &"', AccountAssociationIDCredit=1, AccountIDCredit="& parc("ContaCartao") &", AccountAssociationIDDebit=0, AccountIDDebit=0, PaymentMethodID=3, Value="& treatvalzero(ValorSplit) &", Date="& mydatenull(DataPagto) &", CD='C', Type='CCFee', Currency='BRL', Rate=1, MovementAssociatedID="& MovID &", UnidadeID=0, sysUser="& session("User") )
    end if
    'SE ANTECIP >0 Cria uma movement com o Name Split trans. [id da transaction] - Parcela/Parcelas, AccountAssCred=1, Deb=0, AccCred=Cartao da trans, AccDeb=0, PMID=3, Value=ValorTaxa, CD=C, Type=CCAnte, unidadeID do dono da conta
    if ValorAntecipacao>0 then
        db.execute("insert into sys_financialmovement set Name='Antec. Trans. "& parc("Transacao") &" - "& Parcela &"/"& Parcelas &"', AccountAssociationIDCredit=1, AccountIDCredit="& parc("ContaCartao") &", AccountAssociationIDDebit=0, AccountIDDebit=0, PaymentMethodID=3, Value="& treatvalzero(ValorAntecipacao) &", Date="& mydatenull(DataPagto) &", CD='C', Type='CCFee', Currency='BRL', Rate=1, MovementAssociatedID="& MovID &", UnidadeID=0, sysUser="& session("User") )
    end if
    'Na CartaoConciliacao colocar Conciliado=1
    db.execute("update cartaoconciliacao set Conciliado=1 where id="& ConciliacaoID)
    
    sql = sqlCC & " cc.id="& ConciliacaoID
    set l = db.execute(sql)
    %>
    <!--#include file="CartaoConciliaBloco.asp"-->
    <%
    response.end
end if
%>



<!-- #include file = "UploadFuncoes.asp" -->


<style>
.panel-body {
    border:0!important;
}
</style>

<%
set adq = db.execute("select group_concat(NomeAdquirente separator ', ') Adquirentes from cliniccentral.cartaoadquirentes")
Adquirentes = adq("Adquirentes")
%>
<div class="row">
    <div class="col-md-6">
        <form name="form1" action="./?P=CartaoConcilia&Pers=1&E=E" method="post" enctype="multipart/form-data">
            <input hidden name="bancoConcilia" value="true">
            <div class="panel mt20">
                <div class="panel-heading">
                    <span class="panel-title">NOVO ARQUIVO: </span>
                    <%
                    'config migrada para Cliniccentral
                    if session("Admin")=1 and False then
                        %>
                        <span class="panel-controls">
                            <button type="button" class="btn btn-default" onclick="location.href='./?P=CartaoLayouts&Pers=Follow'">Editar Layouts</button>
                        </span>
                        <%
                    end if
                    %>
                </div>
                <div class="panel-body">
                    <div class="col-md-5">
                        SELECIONE O ARQUIVO CSV: <input required type="file" name="Arquivo" size="14">
                    </div>
                    <%= quickfield("simpleSelect", "LayoutID", "Layout", 3, "", "select * from cliniccentral.cartaolayouts where sysActive=1 order by NomeLayout", "NomeLayout", " required semVazio ") %>
                    <div class="col-md-4">
                        <button type="submit" class="btn-block btn btn-primary mt25" name="submit">ENVIAR</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
    
    <div class="col-md-6">
        <div class="panel mt20">
            <div class="panel-heading">
                <span class="panel-title">CONCILIAÇÕES ANTERIORES</span>
            </div>
            <div class="panel-body">
                <%
                set contaConc = db.execute("select Conciliado, COUNT(*) Qtd FROM cartaoconciliacao WHERE ValorBruto>0 GROUP BY Conciliado")
                if contaConc.eof then
                    response.write("Nenhum arquivo conciliado anteriormente.")
                else
                    while not contaConc.eof
                        select case contaConc("Conciliado")
                            case 0
                                DescricaoConc = "Pendentes"
                                ClasseConc = "warning"
                            case 1 
                                DescricaoConc = "Conciliados"
                                ClasseConc = "success"
                            case 2
                                DescricaoConc = "Não encontrados"
                                ClasseConc = "danger"
                        end select
    
                        %>
                        <a class="btn btn-<%= ClasseConc %>" href="./?P=CartaoConcilia&Pers=1&E=<%= ContaConc("Conciliado") %>"><%= DescricaoConc &" - "& ContaConc("Qtd") %></a>
                        <%
    
                    contaConc.movenext
                    wend
                    contaConc.close
                    set contaConc = nothing
                end if
                %>
            </div>
        </div>
    </div>
</div>

<%
if req("E")="" then

elseif req("E")="E" then
    ' Chamando Funções, que fazem o Upload funcionar
    byteCount = Request.TotalBytes
    RequestBin = Request.BinaryRead(byteCount)
    Set UploadRequest = CreateObject("Scripting.Dictionary")
    BuildUploadRequest RequestBin

    ' Recuperando os Dados Digitados ----------------------
    'AdquirenteID = UploadRequest.Item("AdquirenteID").Item("Value")
    'mail = UploadRequest.Item("email").Item("Value")

    ' Tipo de arquivo que esta sendo enviado
    tipo_arquivo = UploadRequest.Item("Arquivo").Item("ContentType")

    ' Caminho completo dos arquivos enviados
    caminho_Arquivo = UploadRequest.Item("Arquivo").Item("FileName")

    ' Nome dos arquivos enviados
    nome_arquivo = Right(caminho_Arquivo,Len(caminho_Arquivo)-InstrRev(caminho_Arquivo,"\"))

    ' Conteudo binario dos arquivos enviados
    Arquivo = UploadRequest.Item("Arquivo").Item("Value")
    extensao = right(nome_arquivo, 4)

    ' pasta onde as imagens serao guardadas
    pasta = Server.MapPath("ofx")

    ' pasta + nome dos arquivos
    'cArquivo = "imagens/lojas" + nome_arquivo
    novoNome = replace(session("Banco"), "clinic", "") &"_"& session("User") &"_"& replace(replace(replace(now(), "/", ""), ":", ""), " ", "")
    nome_arquivo = "/"&nome_arquivo

    ' Fazendo o Upload do arquivo selecionado
    if Arquivo <> "" then
        if lcase(Extensao)=".csv" then
            Set ScriptObject = Server.CreateObject("Scripting.FileSystemObject")
            Set MyFile = ScriptObject.CreateTextFile(pasta &"//"& novoNome &".csv")
            For i = 1 to LenB(Arquivo)
                MyFile.Write chr(AscB(MidB(Arquivo,i,1)))
            Next
            MyFile.Close
            Response.write "Dados Cadastrados com Sucesso! Tipo arquivo: "& tipo_arquivo &" - Extensao: "& Extensao
            response.Redirect("./?P=CartaoConcilia&Pers=1&E="& NovoNome &"&LayoutID="& UploadRequest.Item("LayoutID").Item("Value"))
        else
            response.write("Erro: Formato de arquivo CSV inválido.")
        end if
    end if
elseif req("E")<>"E" AND NOT ISNUMERIC(req("E")) then

    'Pegando ordem das colunas
    set cols = db.execute("SELECT ccol.NomeColuna, ccol.Descricao, ccol.Tipo, ccol.id ColunaCentralID, cl.Posicao FROM cliniccentral.conciliacaocolunas ccol LEFT JOIN cliniccentral.cartaocolunaslayout cl ON (cl.LayoutID="& req("LayoutID") &" AND cl.ColunaCentralID=ccol.id) ORDER BY ccol.id")
    while not cols.eof
        strNomeColuna = strNomeColuna & cols("NomeColuna") &";"
        strPosicao = strPosicao & cols("Posicao") &";"
        strTipo = strTipo & cols("Tipo") &";"
    cols.movenext
    wend
    cols.close
    set cols = nothing

    'rw("string colunas: "& strNomeColuna)
    'rw("string posicao: "& strPosicao)
    'rw("string tipo: "& strTipo)
    'response.end



    'Lendo o arquivo subido e definindo o tipo de operadora
    Set fs=Server.CreateObject("Scripting.FileSystemObject")
    Set f=fs.OpenTextFile(Server.MapPath("ofx/"& req("E") &".csv"), 1)
    PrimeiraLinha = f.ReadLine
    
    'Definindo qual a adquirente pra trabalhar o layout
    '1. STONE
    'Primeira linha da Stone (1) -> "STONECODE;DOCUMENTO;NOME FANTASIA;CATEGORIA;HORA DA VENDA;DATA DE VENCIMENTO;TIPO;Nº DA PARCELA;QTD DE PARCELAS;BANDEIRA;STONE ID;N° CARTÃO;VALOR BRUTO;VALOR LÍQUIDO;DESCONTO DE ANTECIPAÇÃO;DESCONTO DE MDR;ÚLTIMO STATUS;DATA DO ÚLTIMO STATUS;CHAVE EXTERNA"
    if instr(PrimeiraLinha, "STONECODE") then
        AdquirenteID = 1
        PrimeiraLinhaConteudo = 2

    'Primeira linha da Cielo (2) -> "Central de Relacionamento;4002 5472 (todas as localidades);0800 570 8472 (exceto capitais)"
    elseif instr(PrimeiraLinha, "Central de Relacionamento;4002 5472") then
        AdquirenteID = 2
        PrimeiraLinhaConteudo = 5

    else
        AdquirenteID = 0'Layout inválido
        %>
        <script>
            alert('Layout não reconhecido. Por favor, contate a Feegow, pois a adquirente pode ter alterado seu layout e será necessário que atualizemos o sistema para reconhecer o layout.');
        </script>
        <%
    end if

    response.buffer


    'Gravando o arquivo no banco de dados
    'if AdquirenteID>0 then
        NumeroLinha = 1
        do while f.AtEndOfStream = false
            response.flush()
            NumeroLinha = NumeroLinha+1
            ConteudoLinha = f.ReadLine &""
            ConteudoLinha = replace( ConteudoLinha, """", "")
            ConteudoLinha = replace( ConteudoLinha, "R$ ", "")
            if NumeroLinha>=PrimeiraLinhaConteudo then
                spl = split( ConteudoLinha, ";" )
ADQUIRENTEID = 0
IF 0 THEN
                if AdquirenteID=1 then'Stone
                    NomeAdquirente = "Stone"
                    'Grava os campos prontos e no fim busca a autorização no microtef por comparativo
                    CredDeb = spl(6)
                    Bandeira = spl(9)
                    CodigoMaquina = spl(0)
                    NumeroCartao = spl(11)
                    Status = spl(16)
                    DataVenda = spl(4)
                    DataPagto = spl(5)
                    ValorBruto = spl(12)
                    ValorLiquido = spl(13)
                    ValorAntecipacao = spl(14)
                    ValorTaxa = spl(15)
                    Parcela = spl(7)
                    Parcelas = spl(8)
                    Autorizacao = spl(10)
                    Transacao = spl(10)
                    Categoria = spl(3)'VENDA / SPLIT / CANCELAMENTO'
                elseif AdquirenteID=2 then'Cielo
                    NomeAdquirente = "Cielo"
                    CredDeb = spl(8)
                    Bandeira = spl(7)
                    CodigoMaquina = spl(18)
                    NumeroCartao = spl(11)
                    Status = spl(0)
                    DataVenda = spl(6)
                    DataPagto = spl(5)
                    ValorBruto = spl(14)
                    ValorLiquido = spl(15)
                    ValorAntecipacao = spl(21)
                    ValorTaxa = ccur(ValorBruto) - ccur(ValorLiquido) + ccur(ValorAntecipacao)
                    Parcela = spl(9)
                    Parcelas = spl(10)
                    Autorizacao = spl(12)
                    Transacao = spl(13)
                    Categoria = spl(1)'Recebíveis de venda
                end if

                hash = AdquirenteID &", '"& Autorizacao &"', '"& Transacao &"', '"& CredDeb &"', '"& Bandeira &"', '"& CodigoMaquina &"', '"& NumeroCartao &"', '"& Status &"', '"& Categoria &"', "& mydatetime(DataVenda) &", "& mydatetime(DataPagto) &", "& treatvalzero(ValorBruto) &", "& treatvalzero(ValorLiquido) &", "& treatvalzero(ValorAntecipacao) &", "& treatvalzero(ValorTaxa) &", "& treatvalzero(Parcela) &", "& treatvalzero(Parcelas)
                hash = replace(hash, "'", "")
                sql = "insert ignore into cartaoconciliacao (AdquirenteID, Autorizacao, Transacao, CredDeb, Bandeira, CodigoMaquina, NumeroCartao, Status, Categoria, DataVenda, DataPagto, ValorBruto, ValorLiquido, ValorAntecipacao, ValorTaxa, Parcela, Parcelas, Hash) values ("& AdquirenteID &", '"& Autorizacao &"', '"& Transacao &"', '"& CredDeb &"', '"& Bandeira &"', '"& CodigoMaquina &"', '"& NumeroCartao &"', '"& Status &"', '"& Categoria &"', "& mydatetime(DataVenda) &", "& mydatetime(DataPagto) &", "& treatvalzero(ValorBruto) &", "& treatvalzero(ValorLiquido) &", "& treatvalzero(ValorAntecipacao) &", "& treatvalzero(ValorTaxa) &", "& treatvalzero(Parcela) &", "& treatvalzero(Parcelas) &", md5('"& hash &"'))"
                'response.write( sql &"<br>")
                db.execute( sql )
                'ACIMA DESATIVADO A APAGAR'

ELSE
        'ESTE É O ELSE QUE VALE'
                Colunas = ""
                Valores = ""
                splNomeColuna = split(strNomeColuna,";")
                splPosicao = split(strPosicao,";")
                splTipo = split(strTipo,";")
                for j=0 to ubound(splNomeColuna)
                    if splNomeColuna(j)<>"" then
                        Tipo = splTipo(j)
                        'rw("{"& splPosicao(j) &"}")
                        if not isnull(splPosicao(j)) and splPosicao(j)&""<>"" then
                            if ccur(splPosicao(j))>0 then
                                ValorItem = spl( splPosicao(j)-1 )
                                if Tipo="varchar" then
                                    ValorItem = "'"& ValorItem &"'"
                                elseif Tipo="timestamp" then
                                    ValorItem = mydatetime( ValorItem )
                                elseif Tipo="double" or Tipo="int" then
                                    ValorItem = treatvalzero( ValorItem )
                                end if
                                


                                Colunas = Colunas &", "& splNomeColuna(j)
                                Valores = Valores & ", "& ValorItem
                            end if
                        end if
                    end if
                next
                hash = Valores
                hash = replace(hash, "'", "")
                db.execute("insert ignore into cartaoconciliacao (AdquirenteID"& Colunas & ", Hash) VALUES ("& AdquirenteID & Valores &", md5('"& hash &"'))")
                
                db.execute("UPDATE cartaoconciliacao as filho INNER JOIN cartaoconciliacao AS pai ON (filho.Transacao=pai.Transacao AND filho.Autorizacao=pai.Autorizacao AND filho.Parcela=pai.Parcela and pai.ValorBruto>0) SET filho.Pai=pai.id WHERE filho.conciliado=0 AND filho.ValorBruto<0 AND filho.Pai=0")
                db.execute("UPDATE cartaoconciliacao SET ValorTaxa=ValorBruto-ValorLiquido WHERE Conciliado=0 AND ISNULL(ValorTaxa) AND ValorBruto>0 AND ValorLiquido>0")

END IF
            end if
        loop
    'end if

    f.Close

    Set f=Nothing
    Set fs=Nothing
    %>
    <script type="text/javascript">
    location.href='./?P=CartaoConcilia&Pers=1&E=0';
    </script>
    <%
elseif isnumeric(req("E")) then

    'Fazendo a análise e conciliação de cada linha
    c = 0
    Pagina = req("Pagina")
    if Pagina="" then
        Pagina = 0
    else
        Pagina = ccur(Pagina)-1
    end if
    Pagina = Pagina &", "
    sql = sqlCC & " cc.Conciliado='"& req("E") &"' AND cc.ValorBruto>0 and cc.Pai=0 LIMIT "& Pagina & limite
    'rw(sql)
    set l = db.execute(sql)
    while not l.eof
        response.flush()
        %>
        <div id="panel<%= l("id")%>">
            <!--#include file="CartaoConciliaBloco.asp"-->
        </div>
        <%
    l.movenext
    wend
    l.Close
    set l=nothing

    %>
    
    <div class="panel" style="position:fixed; bottom:24px; width:800px; margin-left:80px; -webkit-box-shadow: 3px 3px 14px 5px rgba(0,0,0,0.41); box-shadow: 3px 3px 14px 5px rgba(0,0,0,0.41);">
        <div class="panel-body">
            <div class="row">
                <div class="col-md-3">
                    <label><input type="checkbox" class="selectAll" onclick="$('input[type=checkbox]').prop('checked', $(this).prop('checked') )"> Selecionar tudo</label>
                </div>
                <div class="col-md-3">
                    <button onclick="conciliarTudo(); $('.selectAll').prop('checked', false)" type="button" class="btn btn-sm btn-success btn-block btn-sm"><i class="far fa-check"></i> Conciliar <span class="qtdChecado">0</span> selecionados</button>
                </div>
            </div>
            <hr class="short alt">
            <%
            if c>limite and 0 then
                %>
                <div class="alert alert-warning">
                    <i class="far fa-exclamation-triangle"></i> Exibindo os primeros <%= limite %> registros. Após conciliar, clique em recarregar para conciliar o restante. <a href="javascript:location.reload()" class="btn btn-sm btn-danger">Recarregar</a>
                </div>
                <%
            end if
            %>
        </div>
    </div>
    
    <%

    'Autorização não encontrada busca na microtef
    'Tratar exceção de split e Cancelamento na Stone
    'Não apaga os não conciliados, mas mostra quantos existem e dá opção de exibir paginado ou limitado para reprocessar


end if
%>


<script type="text/javascript">
    $(".crumb-active a").html("Conciliação de Cartões");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("upload de arquivo CSV");
    $(".crumb-icon a span").attr("class", "far fa-file");

    function conciliar(ConciliacaoID) {
        $.post("CartaoConcilia.asp?ConciliacaoID="+ ConciliacaoID, {
            ValorLiquido: $("#ValorLiquido"+ ConciliacaoID).val(),
            PercentualTaxa: $("#PercentualTaxa"+ ConciliacaoID).val(),
            ValorTaxa: $("#ValorTaxa"+ ConciliacaoID).val(),
            ValorAntecipacao: $("#ValorAntecipacao"+ ConciliacaoID).val(),
            DataPagto: $("#DataPagto"+ ConciliacaoID).val(),
            ValorSplit: $("#ValorSplit"+ ConciliacaoID).val(),
            ValorClinica: $("#ValorClinica"+ ConciliacaoID).val(),
            ParcelaID: $("#ParcelaID"+ ConciliacaoID).val(),
            Parcela: $("#Parcela"+ ConciliacaoID).val(),
            Parcelas: $("#Parcelas"+ ConciliacaoID).val()
        }, function(data){
            $("#panel"+ ConciliacaoID).html(data);
        });
    }

    function conciliarTudo(){
        $(".chkConc:checked").each(function(){
            conciliar( $(this).val() );
        });
    }

    function contaSel(){
        $(".qtdChecado").html( $(".chkConc:checked").size() );
    }

    $("input[type=checkbox]").click(function(){
        contaSel();
    });
</script>