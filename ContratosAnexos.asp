<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%if ref("E")="E" then
    db.execute("update contratosanexos set DataInicio='"&ref("DataInicio")&"' , DataFim='"&ref("DataFim")&"', Contrato='"&ref("Contrato")&"' ")
    %>
    <script type="text/javascript">
    $(document).ready(function(e) {
        new PNotify({
            title: 'Salvo com sucesso!',
            text: '',
            type: 'success',
            delay: 3000
        });
    });
    </script>
    <%
end if

DataInicio = ""
DataFim = ""
Contrato = ""

set assoc = db.execute("select id from sys_financialaccountsassociation where `table` = '"&lcase(req("T"))&"'  ")
if not assoc.eof then
    AssocID = assoc("id")

    set con = db.execute("select * from contratosanexos where AccountID="&req("I")&" AND AccountAssociationID="&AssocID)
    if not con.eof then
        DataInicio = con("DataInicio")&""
        DataFim = con("DataFim")&""
        Contrato = con("Contrato")&""
    end if
end if


%>
<div class="tabbable">
    <div class="tab-content">
        <form method="post" id="frmContratos" name="frmContratos" action="saveContratosAnexos.asp">
            <input type="hidden" name="I" value="<%=req("I")%>" />
            <input type="hidden" name="P" value="<%=req("P")%>" />
            <input type="hidden" name="E" value="E" />

            <div class="panel">
                <div class="panel-heading">
                    <span class="panel-title">
                        Contratos
                    </span>
                    <span class="panel-controls">
                        <button class="btn btn-primary btn-sm" id="saveContratos"> <i class="far fa-save"></i> Salvar </button>
                    </span>
                </div>

                <div id="contrato-box" class="panel-body">
                    <div class="row">
                        <%= quickField("datepicker", "DataInicio", "Data Início", 2, DataInicio, "", "", " required='required'") %>
                        <%= quickField("datepicker", "DataFim", "Data Fim", 2, DataFim, "", "", " required='required'") %>

                        <div class="col-md-8">
                            <label for="Contrato">Link do Contrato</label>
                            <div class="input-group">
                            <span class="input-group-addon">
                                <i class="far fa-paperclip bigger-110"></i>
                            </span>
                                <input type="text" class="form-control" required="required" name="Contrato" id="Contrato" value="<%=Contrato%>" />

                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </form>
    </div>
</div>
<script type="text/javascript">
$("#frmContratos").submit(function(){
    $.post("ContratosAnexos.asp", $(this).serialize(), function(data){
        $("#content").find(".col-xs-12").html(data);

    });
    return false;
});



<!--#include file="JQueryFunctions.asp"-->
</script>