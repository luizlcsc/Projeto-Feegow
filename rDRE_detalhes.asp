<!--#include file="connect.asp"-->
<%
LinhaID = req("LinhaID")
Mes = req("Mes")
Total = 0
c = 0
%>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Detalhes dos Lançamentos</span>
        <span class="panel-controls"></span>
    </div>
    <div class="panel-body">
        <table class="table table-hover">
            <thead>
                <tr class="primary">
                    <th>Data</th>
                    <th>Conta</th>
                    <th>Conta</th>
                    <th>NF-e</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                set reg = db.execute("select dre.*, i.nroNFe from cliniccentral.dre_temp dre LEFT JOIN sys_financialinvoices i ON i.id=dre.InvoiceID where dre.Valor>0 and dre.sysUser="& session("User") &" and month(dre.Data)="& Mes &" and dre.LinhaID="& LinhaID)
                while not reg.eof
                    c = c+1
                    Total = Total+reg("Valor")
                    nroNFe = Total+reg("nroNFe")
                    %>
                    <tr>
                        <td><%= reg("Data") %></td>
                        <td><%= nameInAccount(reg("Conta")) %></td>
                        <td class="text-right"><%= fn(reg("Valor")) %></td>
                        <td class=""><%= nroNFe %></td>
                        <td><a href="<%= reg("Link") %>" target="_blank" class="btn btn-xs btn-info"><i class="fa fa-external-link"></i></a></td>
                    </tr>
                    <%
                reg.movenext
                wend
                reg.close
                set reg=nothing
                %>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="2"><%= c &" item(s)" %></th>
                    <th class="text-right"><%= fn(Total) %></th>
                </tr>
            </tfoot>
        </table>
    </div>
</div>