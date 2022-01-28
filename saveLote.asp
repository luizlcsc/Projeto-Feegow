<!--#include file="connect.asp"-->
<%
Acao = req("Acao")
Tipo = req("T")
CriaInvoice = req("CriaInvoice")

function gerarcar(loteid,ConvenioID,tipoguiais,valortotal)
    Lotes = loteid
    ConvenioID = ConvenioID
    TG = tipoguiais
    incrementar = ""
    sqlguias  = "SELECT GROUP_CONCAT(id) AS ids FROM tiss"&TG&" WHERE LoteID='"&loteid&"'"
    set resguias = db.execute(sqlguias)
    if not resguias.eof then 
        listadeguias = resguias("ids")
    else 
        %>
            new PNotify({
                title: 'N&Atilde;O LAN&Ccedil;ADO!',
                text: 'Não foram encontradas guias para este lote!',
                type: 'danger',
                delay: 4000
            });
        <%
        response.end
    end if
    if TG="guiaconsulta" then
        coluna = "ValorProcedimento"
    elseif TG="guiasadt" then
        coluna = "TotalGeral"
    elseif TG="guiahonorarios" then
        coluna = "Procedimentos"
    end if
    sql = "select l.*, (select UnidadeID from tiss"&TG&" where id IN("&listadeguias&") LIMIT 1) UnidadeID, group_concat(Lote) LotesDescricoes from tisslotes l where id IN ("&Lotes&")"
    set plote = db.execute( sql )
    if not plote.eof then
        if incrementar="" then
            db_execute("insert into sys_financialinvoices (Name, AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser,sysDate, FormaID, ContaRectoID) values ('Fechamento de Lotes', "&ConvenioID&", 6, "&treatvalzero(valortotal)&", 1, 'BRL', "&treatvalzero(plote("UnidadeID"))&", 1, 'm', 'C', 1, "&session("User")&",CURDATE(), 0, 0)")
            set pultInv = db.execute("select id from sys_financialinvoices where sysUser="&session("User")&" order by id desc limit 1")
            InvoiceID = pultInv("id")
            db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, UnidadeID) values (0, 0, 6, "&ConvenioID&", "&treatvalzero(valortotal)&", CURDATE(), 'C', 'Bill', 'BRL', 1, "&InvoiceID&", 1, "&session("User")&", "&treatvalzero(plote("UnidadeID"))&")")
        else
            InvoiceID=incrementar
            set HaPagamentosSQL = db.execute("SELECT SUM(credito.Value) ValorPago "&_
                                            "FROM sys_financialmovement debito "&_
                                            "LEFT JOIN sys_financialdiscountpayments pagamento ON pagamento.InstallmentID=debito.id "&_
                                            "LEFT JOIN sys_financialmovement credito ON credito.id=pagamento.MovementID "&_
                                            "WHERE debito.InvoiceID="&InvoiceID)
            if HaPagamentosSQL("ValorPago")>0 then
                %>
                new PNotify({
                    title: 'N&Atilde;O LAN&Ccedil;ADO!',
                    text: 'Já há pagamentos lançados para esta conta.',
                    type: 'danger',
                    delay: 4000
                });
                <%
                Response.End
            end if
            set InvoiceSQL = db.execute("SELECT Value FROM sys_financialinvoices WHERE id="&InvoiceID)
            Valor = valortotal
            ValorConta = InvoiceSQL("Value")

            ValorAtualizado = ccur(ValorConta) + ccur(Valor)

            db_execute("update sys_financialmovement SET Value="&treatvalzero(ValorAtualizado)&" WHERE Type='Bill' AND InvoiceID="&InvoiceID)
            db_execute("update sys_financialinvoices SET Value="&treatvalzero(ValorAtualizado)&" WHERE id="&InvoiceID)
        end if
        'valida se ja ha esse registro na tissguiainvoice
        sqlvalidacao = "SELECT id FROM tissguiasinvoice WHERE GuiaID IN ("&listadeguias&") AND TipoGuia='"&TG&"'"
        'response.write(sqlvalidacao)
        set ValidacaoGuiaInvoiceSQL = db.execute(sqlvalidacao)

        if not ValidacaoGuiaInvoiceSQL.eof then
            %>
            new PNotify({
                title: 'N&Atilde;O LAN&Ccedil;ADO!',
                text: 'Guia já lançada para recebimemto.',
                type: 'danger',
                delay: 4000
            });
            <%
            Response.End
        end if
        sqlinsertii = "insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, Executado, sysUser, ProfissionalID, Associacao, CentroCustoID) values ("& InvoiceID &", 'O', 1, 0, 0, "&treatvalzero(valortotal)&", 0, 'Lote(s): "&plote("LotesDescricoes")&"', '', "&session("User")&", 0, 0, 0)"
        db_execute(sqlinsertii)
        set pultInvItem = db.execute("select id from itensinvoice where InvoiceID="&InvoiceID&" order by id desc limit 1")
        ItemInvoiceID = pultInvItem("id")
        
        if CriaInvoice = 1 then
            call lancarImposto(InvoiceID,valortotal,ConvenioID)
        end if 

        spl = split(listadeguias, ",")
        
        for i=0 to ubound(spl)
            sqlinserttg = "insert into tissguiasinvoice (ItemInvoiceID, InvoiceID, GuiaID, TipoGuia) values ("& ItemInvoiceID &", "& InvoiceID &", "& spl(i) &", '"&TG&"')"
            db_execute(sqlinserttg)
        next
     else
        %>
        new PNotify({
            title: 'N&Atilde;O LAN&Ccedil;ADO!',
            text: 'Houve um erro ao lançar conta.',
            type: 'danger',
            delay: 4000
        });
        <%
    end if
end function 



if Acao="Inserir" then
	if not isnumeric(ref("Lote")) or ref("Lote")="" then
		erro = "N&uacute;mero do lote inv&aacute;lido."
	else
		set vca=db.execute("select * from tisslotes where Lote="&ref("Lote"))
		if not vca.eof then
			erro = "J&aacute; existe um lote com este n&uacute;mero."
		end if
	end if
	if erro<>"" then
		%>
        $.gritter.add({
            title: '<i class="far fa-thumbs-down"></i> ERRO:',
            text: '<%=erro%>',
            class_name: 'gritter-error gritter-light'
        });
		<%
	else
		db_execute("insert into tisslotes (Lote, ConvenioID, Mes, Ano, Ordem, Tipo, sysUser,Observacoes,DataPrevisao) values ("&ref("Lote")&", "&req("ConvenioID")&", "&ref("Mes")&", "&ref("Ano")&", '"&ref("Ordem")&"', '"&Tipo&"', "&session("User")&", '"&ref("Obs")&"',"&mydatenull(ref("PrevisaoRecebimento"))&")")
		set pult = db.execute("select id from tisslotes where sysUser="&session("User")&" order by id desc limit 1")
		spl = split(ref("guia"), ", ")
		if Tipo="GuiaConsulta" then
			tabela = "tissguiaconsulta"
		elseif Tipo="GuiaSADT" then
			tabela = "tissguiasadt"
		elseif Tipo="GuiaHonorarios" then
			tabela = "tissguiahonorarios"
		end if
		for i=0 to ubound(spl)
		    loteSql = "update "&tabela&" set LoteID="&pult("id")&" where id="&spl(i)
			db_execute(loteSql)
		next
		if CriaInvoice = "1" then
            if Tipo="GuiaConsulta" then
                set valorProc = db.execute("select sum(ValorProcedimento) Valor, ProcedimentoID  from tissguiaconsulta t where LoteID = "&pult("id")&"")
            elseif Tipo="GuiaSADT" then
                set valorProc = db.execute("select sum(TotalGeral) Valor from tissguiasadt t where LoteID = "&pult("id")&"")
            elseif Tipo="GuiaHonorarios" then
                set valorProc = db.execute("select sum(ValorPago) Valor from tissguiahonorarios t where LoteID = "&pult("id")&"")
            end if

            call gerarcar(pult("id"),req("ConvenioID"),lcase(Tipo),valorProc("Valor"))

        end if
		%>

		
		gtag('event', 'fechamento_de_lote', {
			'event_category': 'lote',
			'event_label': "Tiss > Fechar lote > Salvar",
		});
		
        alert('O lote foi salvo com sucesso. Para gerar o arquivo XML, acesse o menu TISS -> Administrar Lotes.');
        location.href='./?P=tissfechalote&Pers=1';
		<%
	end if
elseif Acao="Update" then
    LoteID = ref("LoteID")
    Enviado = ref("Enviado")
    Protocolo = ref("Protocolo")
    NumeroNFSe = ref("NumeroNFSe")
    DataEnvio = mydatenull(ref("DataEnvio"))
    DataPrevisao = mydatenull(ref("DataPrevisao"))
    DataPrevisaoOriginal = mydatenull(ref("DataPrevisaoOriginal"))
    db_execute("update tisslotes set Protocolo='"&Protocolo&"', NumeroNFSe='"&NumeroNFSe&"', Enviado="&Enviado&" , DataEnvio="&DataEnvio&", DataPrevisao="&DataPrevisao&", DataPrevisaoOriginal="&DataPrevisaoOriginal&" where id="&LoteID)
    %>
           $.gritter.add({
            title: '<i class="far fa-save"></i> Informações salvas com sucesso!',
            text: '',
            class_name: 'gritter-success gritter-light'
        });

    <%
end if
%>