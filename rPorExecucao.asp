<!--#include file="connect.asp"-->

<%

De = req("De")
Ate = req("Ate")
ExecutadoPor = req("ExecutadoPor")

splExec = split(ExecutadoPor, "_")
Associacao = splExec(0)
ExecID = splExec(1)
%>
<h3 class="text-center">Serviços por Execução</h3>
<h4 class="text-center"><%=De%> e <%=Ate%></h4>

<table class="table table-condensed">
    <thead>
        <tr>
            <th>Serviço</th>
            <th>Quantidade</th>
            <th>Valor</th>
        </tr>
    </thead>
    <tbody>
        <%
        qt = 0
        vt = 0

        db_execute("delete from cliniccentral.rel_servicosporexecucao where sysUser="& session("User"))

        db_execute("insert into cliniccentral.rel_servicosporexecucao (sysUser, ProcedimentoID, Quantidade, Valor, ItemInvoiceID) select '"& session("User") &"', ii.ItemID, ii.Quantidade, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)), ii.id from itensinvoice ii WHERE ii.Tipo='S' and ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND ii.ProfissionalID="& ExecID &" AND Associacao="& Associacao )

        set pserv = db.execute("select distinct ii.ProcedimentoID, p.NomeProcedimento from cliniccentral.rel_servicosporexecucao ii LEFT JOIN procedimentos p ON p.id=ii.ProcedimentoID where ii.sysUser="& session("User") &" order by p.NomeProcedimento")
        while not pserv.eof

            set conta = db.execute("select sum(Quantidade) Quantidade from cliniccentral.rel_servicosporexecucao where sysUser="&session("User") &" and ProcedimentoID="& pserv("ProcedimentoID"))
            set subtot = db.execute("select sum(Valor) Subtotal from cliniccentral.rel_servicosporexecucao where sysUser="&session("User") &" and ProcedimentoID="& pserv("ProcedimentoID"))
            qt = qt+ccur(conta("Quantidade"))
            vt = vt+ccur(subtot("Subtotal"))

            %>
            <tr>
                <td><%= pserv("NomeProcedimento") %></td>
                <td class="text-right"><%= conta("Quantidade") %></td>
                <td class="text-right"><%= fn(subtot("Subtotal")) %></td>
            </tr>
            <%
        pserv.movenext
        wend
        pserv.close
        set pserv = nothing

        db_execute("delete from cliniccentral.rel_servicosporexecucao where sysUser="& session("User"))
        %>
    </tbody>
    <tfoot>
        <tr>
            <td></td>
            <td class="text-right"><%= qt %></td>
            <td class="text-right"><%= fn(vt) %></td>
        </tr>
    </tfoot>
</table>