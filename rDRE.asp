<style type="text/css">
body, tr, td, th {
	font-size:10px!important;
	padding:2px!important;
}

.btnPac {
    visibility:hidden;
}

.linhaPac:hover .btnPac {
    visibility:visible;
}


.btnsHV {
    display:none;
}

#resumo tr td {
    height:22px!important;
}

</style>
<!--#include file="connect.asp"-->

<h2>Demonstração do Resultado do Exercício - DRE</h2>

<div class="alert alert-info">
    A DRE está sendo atualizada.
</div>

<% if 0 then %>

<table class="table table-striped table-hover">
<%

Exibicao = ref("Exibicao")
Exercicio = replace(ref("Exercicio"), "|", "")
dim Subtotal(12), receitas(12), despesas(12)


function somaPer(CD, Mes, Ano, T, CategoriaID)
    'quando o T(Tipo) é O ele traz o CategoriaPrincipalID e nao o CategoriaID
    if T="O" then
        TabelaCategoria = "CategoriaPrincipalID"
    else
        TabelaCategoria = "CategoriaID"
    end if
    set soma = db.execute("SELECT ifnull(SUM(Valor), 0) Total FROM cliniccentral.temp_dre WHERE CD='"& CD &"' AND MONTH(Competencia)="& Mes &" AND YEAR(Competencia)="& Ano &" AND T='"& T &"' AND "& TabelaCategoria &"="& CategoriaID &" AND sysUser="& session("User"))
    somaPer = soma("Total")
end function

function linhaGrupo( T, CD, sqlLinha )
    'response.write( sqlLinha &"<br>")
    set c1 = db.execute( sqlLinha )
    while not c1.eof
        response.Flush()
        TotalCat = 0
        %>
        <tr>
            <td><%'= CategoriaID %>  <%'= T %>   <%= c1("NomeGrupo") %></td>
            <%
'            if T="O" and 0 then
'                CategoriaID = c1("CategoriaPrincipalID")
'            else
                CategoriaID = c1("CategoriaID")
'            end if
            Mes = 0
            while Mes<12
                Mes = Mes+1
                                
                Total = ccur( somaPer(CD, Mes, Ano, T, CategoriaID) )
                TotalCat = TotalCat + Total

                if CD="C" then
                    'response.Write(receitas(Mes) &"+"& Total &"<br>")
                    receitas(Mes) = receitas(Mes)+Total
                else
                    despesas(Mes) = despesas(Mes)+Total
                end if
                %>
                <td class="text-right"><%= fn(Total) %></td>
                <%
            wend
            %>
            <td class="text-right"><%= fn(TotalCat) %></td>
        </tr>
        <%
    c1.movenext
    wend
    c1.close
    set c1=nothing

end function

db.execute("delete from cliniccentral.temp_dre where sysUser="& session("User"))

sqlS = "insert into cliniccentral.temp_dre (sysUser, CD, T, tid, CategoriaID, Valor, Competencia) "&_
    "select "& session("User") &", i.CD, ii.Tipo, ii.id, ifnull(proc.GrupoID, 0), (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)), i.sysDate from sys_financialinvoices i left join itensinvoice ii ON ii.InvoiceID=i.id LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE year(i.sysDate) IN ("& Exercicio &") AND i.sysActive=1 AND (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))>0 AND ii.Tipo='S'"

sqlOM = "INSERT INTO cliniccentral.temp_dre (sysUser, CD, T, tid, CategoriaID, Valor, Competencia) "&_
    "SELECT "& session("User") &", i.CD, ii.Tipo, ii.id, ii.CategoriaID, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)), i.sysDate from sys_financialinvoices i left join itensinvoice ii ON ii.InvoiceID=i.id WHERE year(i.sysDate) IN ("& Exercicio &") AND i.sysActive=1 AND (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))>0 AND ii.Tipo IN ('M', 'O')"



'response.Write( sqlS &"<br>")
db.execute( sqlS )
'response.Write( sqlOM &"<br>")
db.execute( sqlOM )



'DÁ UM DISTINCT NAS CATEGORIAS DE O->CD->INCOME E DE O->CD->EXPENSE COM CONCAT
set dist = db.execute("select CategoriaID, CD from cliniccentral.temp_dre where sysUser="& session("User") &" and T='O' group by CategoriaID")
while not dist.eof
    if dist("CD")="D" then
        tb = "sys_financialexpensetype"
    else
        tb = "sys_financialincometype"
    end if


    CategoriaPrincipalID = dist("CategoriaID")
    'response.write( dist("CategoriaID") &" - "& tb &"<br>")
    set c1 = db.execute("select * from "& tb &" where id="& dist("CategoriaID"))
    if not c1.eof then
        if c1("Category")<>0 then
            CategoriaPrincipalID = c1("Category")
            set c2 = db.execute("select * from "& tb &" where id="& CategoriaPrincipalID)
            if not c2.eof then
                if c2("Category")=0 then
                    CategoriaPrincipalID = c2("id")
                else
                    CategoriaPrincipalID = c2("Category")
                    set c3 = db.execute("select * from "& tb &" where id="& CategoriaPrincipalID)
                    if not c3.eof then
                        if c3("Category")=0 then
                            CategoriaPrincipalID = c3("id")
                        else
                            CategoriaPrincipalID = c3("Category")
                        end if
                    end if
                end if
            end if
        end if
    end if
    db.execute("update cliniccentral.temp_dre set CategoriaPrincipalID="& CategoriaPrincipalID &" where sysUser="& session("User") &" AND CategoriaID="& dist("CategoriaID"))
dist.movenext
wend
dist.close
set dist = nothing


response.Buffer

if Exibicao="m" then
    splAnos = split(Exercicio, ", ")
    for i=0 to ubound(splAnos)
        Ano = splAnos(i)
        %>
        <h3><%= Ano %></h3>


        <%
        arrCD = array("C", "D")
        for j=0 to ubound(arrCD)
            CD = arrCD(j)
            if CD="C" then
                Titulo = "receitas"
                classe = "success"
                tabcat = "sys_financialincometype"
            else
                Titulo = "despesas"
                classe = "danger"
                tabcat = "sys_financialexpensetype"
            end if
        %>
                <tr class="<%= classe %>">
                    <th><%= ucase(Titulo) %></th>
                    <%
                    Mes = 0
                    while Mes<12
                        Mes = Mes+1
                        Subtotal(Mes) = 0
                        %>
                        <th><%= left(ucase(monthname(Mes)), 3) %></th>
                        <%
                    wend
                    %>
                    <th>TOTAL</th>
                </tr>
            <tbody>
                <%
                '1. listar as receitas de serviços
                if CD="C" then
                    call linhaGrupo( "S", CD, "SELECT * FROM (SELECT t.CategoriaID, g.NomeGrupo FROM cliniccentral.temp_dre t LEFT JOIN procedimentosgrupos g ON g.id=t.CategoriaID WHERE t.CD='"& CD &"' AND t.T='S' AND t.sysUser="& session("User") &" AND t.CategoriaID<>0 GROUP BY g.NomeGrupo) comCat UNION ALL SELECT 0, 'Outras receitas sobre serviços' FROM cliniccentral.temp_dre WHERE T='S' AND CategoriaID=0 AND CD='"& CD &"' AND sysUser="& session("User") &" GROUP BY CategoriaID" )
                end if

                '2. listar receitas com produtos em uma linha só
                call linhaGrupo( "M", CD, "SELECT * FROM (SELECT t.CategoriaID, g.NomeCategoria NomeGrupo FROM cliniccentral.temp_dre t LEFT JOIN produtoscategorias g ON g.id=t.CategoriaID WHERE t.CD='"& CD &"' AND t.T='M' AND t.sysUser="& session("User") &" AND t.CategoriaID<>0 GROUP BY g.NomeCategoria) comCat UNION ALL SELECT 0, 'Outras "& Titulo &" de produtos' FROM cliniccentral.temp_dre WHERE T='M' AND CategoriaID=0 AND CD='"& CD &"' AND sysUser="& session("User") &" GROUP BY CategoriaID" )


                '3. listar outras receitas por cat em segundo nível e 0 (outras)
                call linhaGrupo( "O", CD, "SELECT * FROM (SELECT t.CategoriaPrincipalID CategoriaID, g.Name NomeGrupo FROM cliniccentral.temp_dre t LEFT JOIN "& tabcat &" g ON g.id=t.CategoriaPrincipalID WHERE t.CD='"& CD &"' AND t.T='O' AND t.sysUser="& session("User") &" AND t.CategoriaPrincipalID<>0 GROUP BY g.Name) comCat UNION ALL SELECT 0, 'Outras "& Titulo &"' FROM cliniccentral.temp_dre WHERE T='O' AND CategoriaPrincipalID=0 AND CD='"& CD &"' AND sysUser="& session("User") &" GROUP BY CategoriaPrincipalID" )


                    %>
            </tbody>
                <tr class="<%= classe %>" lighter">
                    <th>Total das <%= Titulo %></th>
                    <%
                    Mes = 0
                    Total = 0
                    while Mes<12
                        Mes = Mes+1
                        'Total = Total+Subtotal(Mes)
                        if CD="C" then
                            Subtotal(Mes) = Subtotal(Mes) + receitas(Mes)
                        else
                            Subtotal(Mes) = Subtotal(Mes) + despesas(Mes)
                        end if
                        Total = Total + Subtotal(Mes)
                        %>
                        <th class="text-right"><%= fn(Subtotal(Mes)) %> </th>
                        <%
                    wend
                    %>
                    <th class="text-right"><%= fn(Total) %></th>
                </tr>

        <%
        next
    next
end if

%>
        <tr class="primary">
            <th>RESULTADO</th>
            <%
            Mes = 0
            resultadoTotal = 0
            while Mes<12
                Mes = Mes+1
                resultado = receitas(Mes)-despesas(Mes)
                resultadoTotal = resultadoTotal + resultado
                %>
                <th class="text-right"><%= fn(resultado) %></th>
                <%
            wend
            %>
            <th class="text-right"><%= fn(resultadoTotal) %></th>
        </tr>

</table>
<% end if %>