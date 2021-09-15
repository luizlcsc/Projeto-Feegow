<!--#include file="connect.asp"-->
<%
LinhaID = req("LinhaID")
Mes = req("Mes")
Total = 0
c = 0

Agrupamento = req("A")
if Agrupamento="Outros" then
	sqlAgrupamento = " is null "
else
	sqlAgrupamento = "='"& Agrupamento &"'"
end if

%>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Detalhes dos Lançamentos</span>
        <span class="panel-controls"></span>
    </div>
    <div class="panel-body">
        <form id="formExcel" method="POST">
            <input type="hidden" name="html" id="htmlTable">
        </form>

        <div class="col-md-offset-11 col-md-1 mb10">
            <button class="btn btn-success" type="button" onClick="downloadExcel('#dre-table-analitico')"><i class="far fa-file-excel-o"></i></button>
        </div>

        <table class="table table-hover" id="dre-table-analitico">
            <thead>
                <tr class="primary">
                    <th>Data</th>
                    <th>Conta</th>
                    <th>Categoria</th>
                    <th>Valor</th>
                    <th>NF-e</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                set reg = db.execute("select dre.*, if(i.CD='C', ctC.Name, ctD.Name) Categoria from cliniccentral.dre_temp dre LEFT JOIN itensinvoice ii ON ii.id=dre.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN sys_financialexpensetype ctD ON ctD.id=ii.CategoriaID LEFT JOIN sys_financialincometype ctC ON ctC.id=ii.CategoriaID where dre.Valor>0 and dre.sysUser="& session("User") &" and month(dre.Data)="& Mes &" and dre.LinhaID="& LinhaID &" AND Agrupamento "& sqlAgrupamento)
                while not reg.eof
                    c = c+1
                    Total = Total+reg("Valor")
                    nroNFe = reg("NF")
                    %>
                    <tr>
                        <td><%= reg("Data") %></td>
                        <td><%= nameInAccount(reg("Conta")) %></td>
                        <td><%= reg("Categoria") %></td>
                        <td class="text-right"><%= fn(reg("Valor")) %></td>
                        <td class=""><%= nroNFe %></td>
                        <td><a href="<%= reg("Link") %>" target="_blank" class="btn btn-xs btn-info"><i class="far fa-external-link"></i></a></td>
                    </tr>
                    <%
                reg.movenext
                wend
                reg.close
                set reg=nothing
                %>
            </tbody>
            <tfoot>
                <tr class="dark">
                    <th colspan="3"><%= c &" item(s)" %></th>
                    <th class="text-right"><%= fn(Total) %></th>
                    <th colspan="2"></th>
                </tr>
            </tfoot>
        </table>
    </div>
</div>