<!--#include file="connect.asp"-->
<div class="modal-header">
    <h4>Itens Executados</h4>
</div>
<div class="modal-body">
    <%
    InvoiceID = req("I")
    set ii = db.execute("select ii.id, proc.NomeProcedimento, ii.ProfissionalID from itensinvoice ii LEFT JOIN procedimentos proc on proc.id=ii.ItemID where ii.Tipo='S' and ii.Executado NOT LIKE 'S' and InvoiceID="&InvoiceID)
    if ii.EOF then
        %>
        Não há itens a serem executados para este código de barras.
        <%
    else
        %>
        <form name="frmScan" method="post" id="frmScan">
         <input type="hidden" id="ScanProfissionalID" name="ScanProfissionalID" value="" />
           <table class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th width="40%">Procedimento</th>
                        <th width="25%">Profissional</th>
                        <th width="35%" class="text-center" colspan="2">Ação</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    while not ii.eof
                        %>
                        <tr>
                            <td><%=ii("NomeProcedimento") %></td>
                            <td><%=quickfield("simpleSelect", "ScanProfissionalID"&ii("id"), "", 4, ii("ProfissionalID"), "select id, NomeProfissional from profissionais where Ativo='on' ORDER BY NomeProfissional", "NomeProfissional", " empty onchange=""$('#ScanProfissionalID').val( $(this).val() ) "" ") %></td>
                            <td class="text-center">
                                <button type="button" class="btn btn-sm btn-warning" onclick="ScanExecutadoSave(<%=ii("id") %>, 4)">AGUARDANDO</button>
                                <button type="button" class="btn btn-sm btn-success" onclick="ScanExecutadoSave(<%=ii("id") %>, 3)">ATENDIDO</button>
                            </td>
                        </tr>
                        <%
                    ii.movenext
                    wend
                    ii.close
                    set ii=nothing
                    %>
                </tbody>
            </table>
        </form>
        <%
    end if
    %>
</div>
<div class="modal-footer">

</div>
<script type="text/javascript">
    function ScanExecutadoSave(ii, StaID) {
        $.post("ScanExecutadoSave.asp?II="+ii+"&StaID="+StaID, $("#frmScan").serialize(), function(data){
            eval(data);
        });
    }
</script>