<!--#include file="./../../connect.asp"-->
<%
InvoiceID=req("InvoiceID")

sql = "select p.NomeProcedimento, ii.Desconto, ii.Acrescimo, ii.ValorUnitario, ii.id as iditensinvoice, ii.Executado, rr.id RepasseID, lie.id LabIntegracaoID, ii.Tipo "&_
      "from sys_financialinvoices invoice "&_
      "inner join itensinvoice ii on ii.InvoiceID = invoice.id "&_
      "inner join procedimentos p ON p.id = ii.ItemID "&_
      "left join rateiorateios rr ON rr.ItemInvoiceID = ii.id "&_
      "left join labs_invoices_exames lie ON lie.ItemInvoiceID = ii.id AND lie.StatusID=1 "&_
      "where  invoice.id = " & InvoiceID &" "&_
      "GROUP BY ii.id "&_
      "ORDER BY ii.id ASC"

set ItensInvoiceSQL = db.execute(sql)
ExecutantesTipos = "5, 8, 2"

DataExecucao=date()

if not ItensInvoiceSQL.eof then
    ItemInvoiceID=ItensInvoiceSQL("iditensinvoice")


%>
<div class="row">
    <div class="col-md-12 mb15">
        Selecione abaixo os itens que deseja marcar como <i>"Executado"</i>:
    </div>
</div>
<div class="row">
    <div class="col-md-6">
        <%=selectInsertCA("Executante", "ExecutanteIDMultiplo", "", ExecutantesTipos, "", " required", "")%>
    </div>
    <%= quickField("datepicker", "DataExecucaoMultiplo", "Data da Execução", 6, DataExecucao, "", "", "") %>
</div>
<div class="row">
    <div class="col-md-12">
        <hr class="short alt" />
    </div>
    <div class="col-md-12">
        <table class="table table-condensed">
            <tr class="primary">
                <th><input onclick="selectAllExecucaoMultipla($(this).prop('checked'))" type="checkbox"></th>
                <th>Item</th>
                <th>Executado</th>
                <th>Valor</th>
            </tr>
        <%
            while not ItensInvoiceSQL.eof
                Executado=""
                PermiteSelecionar=True
                DescricaoPermiteSelecionar=""
                ItemInvoiceID=ItensInvoiceSQL("iditensinvoice")

                if not isnull(ItensInvoiceSQL("RepasseID")) then
                    PermiteSelecionar=False
                    DescricaoPermiteSelecionar="Há um ou mais repasse(s) consolidado(s) para este item"
                end if


                if not isnull(ItensInvoiceSQL("LabIntegracaoID")) then
                    PermiteSelecionar=False
                    DescricaoPermiteSelecionar="Há integrações realizadas para este item"
                end if


                if ItensInvoiceSQL("Executado")="C" then
                    PermiteSelecionar=False
                    DescricaoPermiteSelecionar="Item cancelado"
                end if

                if ItensInvoiceSQL("Executado")="S" then
                    Executado="Sim"
                else
                    Executado="Não"
                end if
        %>
            <tr <% if not PermiteSelecionar then %>style="background-color: #f4f4f4; cursor: not-allowed"<%end if%>>
                <td>
                    <%
                    if PermiteSelecionar then
                    %>
                    <input type="checkbox" name="item-multiplos-executados" id="multipla-execucao-<%=ItemInvoiceID%>" class="execucao-multipla-item" value="<%=ItensInvoiceSQL("iditensinvoice")%>">
                    <%
                    else
                    %>
                    <i data-toggle="tooltip"
                        style="color: orangered;"
                      title="<%=DescricaoPermiteSelecionar%>"
                      class="far fa-exclamation-circle"
                      aria-hidden="true"></i>
                    <%
                    end if
                    %>
                </td>
                <td><label for="multipla-execucao-<%=ItemInvoiceID%>"><%=ItensInvoiceSQL("NomeProcedimento") %></label></td>
                <td><%=Executado%></td>
                <td><%=fn(ItensInvoiceSQL("ValorUnitario")) %></td>
            </tr>
        <%
            ItensInvoiceSQL.movenext
            wend
        %>
        </table>
    </div>
</div>

<%
else
%>
<div class="row">
    <div class="col-md-12">
        Nenhum item disponível para ser executado.
    </div>
</div>
<%
end if
%>

<script >
$('[data-toggle="tooltip"]').tooltip();

function selectAllExecucaoMultipla(checked){
    $(".execucao-multipla-item").prop('checked', checked)
}
<!--#include file="./../../JQueryFunctions.asp"-->
</script>