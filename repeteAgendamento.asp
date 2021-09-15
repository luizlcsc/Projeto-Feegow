<!--#include file="connect.asp"-->
<%
ConsultaID = req("ConsultaID")
	%>
<form method="post" action="" id="formRepeteAgendamento" name="formRepeteAgendamento">
<div class="modal-header">
<button class="bootbox-close-button close" data-dismiss="modal" type="button">&times;</button>
<h4 class="modal-title">Repeti&ccedil;&atilde;o de agendamento</h4>
</div>

<div class="modal-body">
    <div class="bootbox-body">
		<div class="row">
        	<div class="col-md-12">
	            <label class="control-label bolder blue">Selecione a data e repita o agendamento quantas vezes for neces&aacute;rio:</label>
            </div>
        </div>
        <div class="row">
        	<%= quickField("datepicker", "Data", "Data", 6, "", "", "", "") %>
            <%= quickField("timepicker", "Hora", "Hora", 6, "00:00:00", "", "", "") %>
        	<%= quickField("simpleSelect", "StaID", "Status", 12, 7, "select * from StaConsulta", "StaConsulta", "") %>
            <%= quickField("memo", "Notas", "Notas", 12, Notas, "", "", "") %>
        </div>
	</div>
</div>
<div class="modal-footer">
    <button class="btn btn-sm btn-success" type="button" data-bb-handler="danger" onclick="pedidoRepeticao(<%=ConsultaID%>);">
    	<i class="far fa-copy"></i> Confirmar Repeti&ccedil;&atilde;o
    </button>
</div>
</form>
<script language="javascript">
function pedidoRepeticao(ConsultaID){
	$.ajax({
		type:"POST",
		url:"pedidoRepeticao.asp?ConsultaID="+ConsultaID,
		data:$("#formRepeteAgendamento").serialize(),
		success:function(data){
			eval(data);
		}
	});
}
<!--#include file="jQueryFunctions.asp"-->
</script>