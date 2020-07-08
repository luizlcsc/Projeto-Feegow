<!--#include file="connect.asp"-->


<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Observações do Convênio</h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>

</div>
<%
set ConvenioSQL = db.execute("SELECT Obs FROM convenios WHERE id="&treatvalzero(req("ConvenioID")))
if not ConvenioSQL.eof then
    ObsConvenio = ConvenioSQL("Obs")
end if
%>
<div class="modal-body">
<%=ObsConvenio%>

</div>

<script type="text/javascript">

<!--#include file="JQueryFunctions.asp"-->
</script>