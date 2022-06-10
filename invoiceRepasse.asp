<!--#include file="connect.asp"-->
<%
Linhas = req("Row")

if IsNumeric(Linhas) then
    Row = Linhas
end if


Linha = Split(Linhas, ",")
for i = 0 to ubound(Linha) 
    Row = Linha(i)


if IsNumeric(Row) then 

FormaID = "|P"& ref("FormaID") &"|"

InvoiceID = req("InvoiceID")

ProfissionalID = ref("ProfissionalID"&Row)
ProcedimentoID = ref("ItemID"&Row)
EspecialidadeID = ref("EspecialidadeID"&Row)
TabelaID = ref("invTabelaID")
UnidadeID = ref("CompanyUnitID")

db.execute("delete from itensinvoiceoutros where InvoiceID="&InvoiceID&" and ItemInvoiceID="& Row)

DominioID = dominioRepasse(FormaID, ProfissionalID, ProcedimentoID, UnidadeID, TabelaID, EspecialidadeID, "", "")

set getFun = db.execute("select id from itensinvoiceoutros where InvoiceID="& InvoiceID &" and ItemInvoiceID="& Row &" and sysActive=1")

if getFun.eof then
    'set fun = db.execute("SELECT * FROM rateiofuncoes WHERE DominioID="&DominioID)'dar union all nos kits
    set fun = db.execute("SELECT * FROM rateiofuncoes WHERE DominioID="&DominioID &" AND FM IN('F', 'E')")'dar union all nos kits

    while not fun.eof
        FM = fun("FM")
        Funcao = fun("Funcao")
        tipoValor = fun("tipoValor")
        Valor = fun("Valor")
        ContaPadrao = fun("ContaPadrao")
        ProdutoID = fun("ProdutoID")
        ValorUnitario = fun("ValorUnitario")
        if valorAnterior <> "" then
            ValorUnitario = valorAnterior 
        end if
        Quantidade = fun("Quantidade")
        Variavel = fun("Variavel")
        ValorVariavel = fun("ValorVariavel")
        TabelasPermitidas = "|5|, |8|, |4|, |2|, |3|"
        FuncaoID = fun("id")
        ContaVariavel = ""
        ProdutoKitID = 0
        FuncaoEquipeID = 0
        ProdutoVariavel = ""
        if ContaPadrao="" then
            ContaVariavel = "S"
        end if
        if FM="M" and ProdutoID=0 then
            ProdutoVariavel = "S"
        end if


        'isso vai pra quando tiver listando os itens gravados
        if FM="M" or FM="F" then
            'call subitemRepasse(FM, Funcao, tipoValor, Valor, ContaPadrao, ProdutoID, ValorUnitario, Quantidade, Variavel, ValorVariavel, TabelasPermitidas, 0, FuncaoID, 0)
            if Variavel="S" or ValorVariavel="S" or ContaVariavel="S" or ProdutoVariavel="S" then
                db.execute("insert into itensinvoiceoutros (InvoiceID, ItemInvoiceID, Tipo, FuncaoID, ProdutoID, Quantidade, ValorUnitario, ProdutoKitID, FuncaoEquipeID, TipoValor, Conta, Funcao, Variavel, ValorVariavel, ContaVariavel, ProdutoVariavel) values ("& InvoiceID &", "&row&", '"&FM&"', "& treatvalzero(FuncaoID) &", "& treatvalzero(ProdutoID) &", "& treatvalzero(Quantidade) &", "& treatvalzero(ValorUnitario) &", "& treatvalzero(ProdutoKitID) &", "& treatvalzero(FuncaoEquipeID) &", '"&TipoValor&"', '"&ContaPadrao&"', '"&Funcao&"', '"&Variavel&"', '"&ValorVariavel&"', '"&ContaVariavel&"', '"& ProdutoVariavel &"')")
            end if

        elseif FM="K" then
            set kit = db.execute("SELECT pk.id ProdutoKitID, pk.ProdutoID, pk.Valor, pk.Variavel, pk.ValorVariavel, pk.Quantidade, pk.ContaPadrao FROM procedimentoskits pck LEFT JOIN produtosdokit pk ON pk.KitID=pck.KitID WHERE pck.Casos LIKE '%|P|%' AND ProcedimentoID LIKE '"& ProcedimentoID &"'")
            while not kit.eof
                FM = "M"
                ProdutoID = kit("ProdutoID")
                ValorUnitario = kit("Valor")
                Variavel = kit("Variavel")
                ValorVariavel = kit("ValorVariavel")
                Quantidade = kit("Quantidade")
                ProdutoKitID = kit("ProdutoKitID")
                if ProdutoID=0 or isnull(ProdutoID) then
                    ProdutoVariavel = "S"
                else
                    ProdutoVariavel = ""
                end if
                ContaPadrao = kit("ContaPadrao")&""
                if ContaPadrao="" then
                    ContaVariavel = "S"
                else
                    ContaVariavel = ""
                end if
                if Variavel="S" or ValorVariavel="S" or ContaVariavel="S" or ProdutoVariavel="S" then
                    db.execute("insert into itensinvoiceoutros (InvoiceID, ItemInvoiceID, Tipo, FuncaoID, ProdutoID, Quantidade, ValorUnitario, ProdutoKitID, FuncaoEquipeID, TipoValor, Conta, Funcao, Variavel, ValorVariavel, ContaVariavel, ProdutoVariavel) values ("& InvoiceID &", "&row&", '"&FM&"', "& treatvalzero(FuncaoID) &", "& treatvalzero(ProdutoID) &", "& treatvalzero(Quantidade) &", "& treatvalzero(ValorUnitario) &", "& treatvalzero(ProdutoKitID) &", "& treatvalzero(FuncaoEquipeID) &", '"&TipoValor&"', '"&ContaPadrao&"', '"&Funcao&"', '"&Variavel&"', '"&ValorVariavel&"', '"&ContaVariavel&"', '"& ProdutoVariavel &"')")
                end if
                'call subitemRepasse(FM, Funcao, tipoValor, Valor, ContaPadrao, ProdutoID, ValorUnitario, Quantidade, Variavel, ValorVariavel, TabelasPermitidas, ProdutoKitID, FuncaoID, 0)
            kit.movenext
            wend
            kit.close
            set kit = nothing
        elseif FM="E" then
            set eqp = db.execute("SELECT * FROM procedimentosequipeparticular WHERE ContaPadrao='' AND ProcedimentoID="& ProcedimentoID)
            while not eqp.eof
                FM = "F"
                Funcao = eqp("Funcao")
                Valor = eqp("Valor")
                tipoValor = eqp("TipoValor")
                TabelasPermitidas = eqp("TabelasPermitidas")
                FuncaoEquipeID = eqp("id")
                if Variavel="S" or ValorVariavel="S" or ContaVariavel="S" then
                    db.execute("insert into itensinvoiceoutros (InvoiceID, ItemInvoiceID, Tipo, FuncaoID, ProdutoID, Quantidade, ValorUnitario, ProdutoKitID, FuncaoEquipeID, TipoValor, Conta, Funcao, Variavel, ValorVariavel, ContaVariavel, ProdutoVariavel) values ("& InvoiceID &", "&row&", '"&FM&"', "& treatvalzero(FuncaoID) &", "& treatvalzero(ProdutoID) &", "& treatvalzero(Quantidade) &", "& treatvalzero(ValorUnitario) &", "& treatvalzero(ProdutoKitID) &", "& treatvalzero(FuncaoEquipeID) &", '"&TipoValor&"', '"&ContaPadrao&"', '"&Funcao&"', '"&Variavel&"', '"&ValorVariavel&"', '"&ContaVariavel&"', '"& ProdutoVariavel &"')")
                end if
                'call subitemRepasse(FM, Funcao, tipoValor, Valor, ContaPadrao, ProdutoID, ValorUnitario, Quantidade, Variavel, ValorVariavel, TabelasPermitidas, FuncaoEquipeID, FuncaoID, 0)
            eqp.movenext
            wend
            eqp.close
            set eqp=nothing
        end if
    fun.movenext
    wend
    fun.close
    set fun=nothing
end if

set getFun = db.execute("select * from itensinvoiceoutros where InvoiceID="& InvoiceID &" and ItemInvoiceID="& Row)

while not getFun.eof

    response.write("<div class='row'>")

    IF "Indicação" = getFun("Funcao") THEN
        sql = " SELECT "&_
              " SUBSTRING(agendamentos.IndicadoPor,3) as id "&_
              " ,COALESCE(profissionais.NomeProfissional,funcionarios.NomeFuncionario,pacientes.NomePaciente,profissionalexterno.NomeProfissional,fornecedores.NomeFornecedor) as nome "&_
              " FROM agendamentos "&_
              " LEFT JOIN profissionais       ON SUBSTRING(agendamentos.IndicadoPor,1,1) = 5 AND SUBSTRING(agendamentos.IndicadoPor,3) = profissionais.id         "&_
              " LEFT JOIN funcionarios        ON SUBSTRING(agendamentos.IndicadoPor,1,1) = 4 AND SUBSTRING(agendamentos.IndicadoPor,3) = funcionarios.id          "&_
              " LEFT JOIN pacientes           ON SUBSTRING(agendamentos.IndicadoPor,1,1) = 3 AND SUBSTRING(agendamentos.IndicadoPor,3) = pacientes.id             "&_
              " LEFT JOIN profissionalexterno ON SUBSTRING(agendamentos.IndicadoPor,1,1) = 8 AND SUBSTRING(agendamentos.IndicadoPor,3) = profissionalexterno.id   "&_
              " LEFT JOIN fornecedores        ON SUBSTRING(agendamentos.IndicadoPor,1,1) = 2 AND SUBSTRING(agendamentos.IndicadoPor,3) = fornecedores.id          "&_
              " WHERE agendamentos.id = "& treatvalzero(ref("AgendamentoID"&Row))

        set getIndicacao = db.execute(sql)
        IF not getIndicacao.eof THEN
        %>
            <script>
                var idFun = '#searchC<%= getFun("id")%>';
                var idFunHidden = '#C<%= getFun("id")%>';
                $(idFun).val('<%= getIndicacao("nome")%>');
                $(idFunHidden).val('<%= getIndicacao("id")%>')
            </script>
        <%
        END IF
    END IF
    call subitemRepasse(getFun("Tipo"), getFun("Funcao"), getFun("tipoValor"), getFun("ValorUnitario"), getFun("Conta"), getFun("ProdutoID"), getFun("ValorUnitario"), getFun("Quantidade"), getFun("Variavel"), getFun("ValorVariavel"), getFun("ContaVariavel"), getFun("ProdutoVariavel"), getFun("TabelasPermitidas"), getFun("FuncaoEquipeID"), getFun("FuncaoID"), getFun("id"))
    response.write("</div>")
getFun.movenext
wend
getFun.close
set getFun = nothing
end if
i = i + 1
next
%>
<%'=DominioID %>
<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
</script>