<!--#include file="connect.asp"-->
<%
LinhaID = req("LinhaID")
Mes = req("Mes")
Total = 0
c = 0
%>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Detalhes dos Lan�amentos</span>
        <span class="panel-controls"></span>
    </div>
    <div class="panel-body">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Data</th>
                    <th>Conta</th>
                    <th>Conta</th>
                    <th>NF-e</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                set reg = db.execute("select * from cliniccentral.dre_temp where Valor>0 and sysUser="& session("User") &" and month(Data)="& Mes &" and LinhaID="& LinhaID)
                while not reg.eof
                    c = c+1
                    Total = Total+reg("Valor")
                    %>
                    <tr>
                        <td><%= reg("Data") %></td>
                        <td><%= nameInAccount(reg("Conta")) %></td>
                        <td class="text-right"><%= fn(reg("Valor")) %></td>
                        <td class="text-right"><%= fn(reg("nroNFe")) %></td>
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