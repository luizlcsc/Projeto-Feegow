<!--#include file="connect.asp"-->
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title">Finalizando Atendimento</h4>
</div>
<div class="modal-body">
    <div class="row">
        O que foi executado neste atendimento? &raquo; <small>Itens a serem adicionados na conta do paciente.</small>
    </div>
    <%=atendimento("NomePaciente")%>
</div>
<div class="modal-footer no-margin-top">
	<button class="btn btn-sm btn-warning pull-right" type="button" onClick="atender(0, <%= atendimento("PacienteID") %>, 'Encerrar')"><i class="far fa-stop"></i> Finalizar</button>
    
</div>