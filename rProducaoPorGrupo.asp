<!--#include file="connect.asp"-->
<%
De = cdate(ref("DataDe"))
Ate = cdate(ref("DataAte"))
Unidades = replace(ref("Unidades"), "|", "")

if Unidades="" then
    %>
    Selecione ao menos uma unidade.
    <%
    response.end
end if


set nun = db.execute("select group_concat(NomeFantasia) NomeFantasia from (select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits) t WHERE id IN ("& Unidades &")")
if not nun.eof then
    NomeFantasia = nun("NomeFantasia")
end if
%>
<h2 class="m25 text-center">PRODUÇÃO POR GRUPO - SINTÉTICO
    <br />
    <small><%= De &" a "& Ate %>
        <br />
        <%= NomeFantasia %>
    </small>

</h2>

<table class="table table-striped table-hover table-bordered">
    <thead>
        <tr class="info">
            <th rowspan="2">Grupo</th>
            <%
            Data = De
            while Data<=Ate
                %>
                <th class="text-center" colspan="3"><%= left(Data, 5) %></th>
                <%
                Data = Data+1
            wend
            %>
            <th colspan="3" class="text-center">Total</th>
        </tr>
        <tr class="info">
            <%
            De = cdate(ref("DataDe"))
            Ate = cdate(ref("DataAte"))
            Data = De
            while Data<=Ate
                %>
                <th class="text-center">Qtd.</th>
                <th class="text-center">Bruto</th>
                <th class="text-center">Líquido</th>
                <%
                Data = Data+1
            wend
            %>
            <th class="text-center">Qtd.</th>
            <th class="text-center">Total Bruto</th>
            <th class="text-center">Total Líquido</th>
        </tr>
    </thead>
    <tbody>
    <%
    response.Buffer

    set grupo = db.execute("select distinct ifnull(proc.GrupoID, 0) GrupoID, ifnull(pg.NomeGrupo, 'Sem grupo') NomeGrupo FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN procedimentosgrupos pg ON pg.id=proc.GrupoID WHERE ii.Tipo='S' AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") ORDER BY pg.NomeGrupo")
    while not grupo.eof
        response.Flush()
        QtdGrupo = 0
        ValorGrupo = 0
        LiquidoGrupo = 0
        %>
        <tr>
            <td><%= grupo("NomeGrupo") %></td>
            <%
            Data = De
            while Data<=Ate
                set vqtd = db.execute("select ifnull(count(ii.id), 0) Qtd from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ifnull(proc.GrupoID, 0)="& grupo("GrupoID") &" AND ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")
                set vval = db.execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ifnull(proc.GrupoID, 0)="& grupo("GrupoID") &" AND ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")
                sqlRep = "select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ifnull(proc.GrupoID, 0)="& grupo("GrupoID") &" AND ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") AND ContaCredito LIKE '%\_%'"
                set vrep = db.execute( sqlRep )
                Qtd = ccur(vqtd("Qtd"))
                Valor = ccur(vval("Valor"))
                Repasses = ccur(vrep("Repasses"))
                ValorLiquido = Valor - Repasses

                QtdGrupo = QtdGrupo + Qtd
                ValorGrupo = ValorGrupo + Valor
                LiquidoGrupo = LiquidoGrupo + ValorLiquido
                %>
                <td class="text-right"><%= Qtd %></td>
                <td class="text-right"><%= fn(Valor) %></td>
                <td class="text-right"><%= fn(ValorLiquido) %></td>
                <%
                Data = Data+1
            wend
            %>
            <th class="text-right"><a target="_blank" href="PrintStatement.asp?R=rProducaoPorGrupoDet&De=<%= De %>&Ate=<%= Ate %>&U=<%= Unidades %>&G=<%= grupo("GrupoID") %>"> <%= QtdGrupo %> </a></th>
            <th class="text-right"><%= fn(ValorGrupo) %></th>
            <th class="text-right">
                <%'= sqlRep %>
                <%= fn(Liquidogrupo) %></th>
        </tr>
        <%
    grupo.movenext
    wend
    grupo.close
    set grupo = nothing
    %>
    </tbody>
    <tfoot>
        <tr>
            <th></th>
            <%
            QtdGrupo = 0
            ValorGrupo = 0
            LiquidoGrupo = 0
            Data = De
            while Data<=Ate
                set vqtd = db.execute("select ifnull(count(ii.id), 0) Qtd from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")
                set vval = db.execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE  ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")
                sqlRep = "select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") AND ContaCredito LIKE '%\_%'"
                set vrep = db.execute( sqlRep )
                Qtd = ccur(vqtd("Qtd"))
                Valor = ccur(vval("Valor"))
                Repasses = ccur(vrep("Repasses"))
                ValorLiquido = Valor - Repasses

                QtdGrupo = QtdGrupo + Qtd
                ValorGrupo = ValorGrupo + Valor
                LiquidoGrupo = LiquidoGrupo + ValorLiquido
                %>
                <th class="text-right"><%= Qtd %></th>
                <th class="text-right"><%= fn(Valor) %></th>
                <th class="text-right">
                    <%'= sqlRep %>
                    
                    <%= fn(ValorLiquido) %></th>
                <%
                Data = Data+1
            wend
            %>
            <th class="text-right"><%= QtdGrupo %></th>
            <th class="text-right"><%= fn(ValorGrupo) %></th>
            <th class="text-right"><%= fn(Liquidogrupo) %></th>
        </tr>
    </tfoot>
</table>