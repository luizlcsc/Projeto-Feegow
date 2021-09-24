<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<%
ConsultaID = req("ConsultaID")
token = req("token")
if req("Confirma")="0" then
	%>
<form method="post" action="" id="formExcluiAgendamento" name="formExcluiAgendamento">

<div class="panel">

<div class="panel-heading">
<span class="panel-title">Tem certeza de que deseja excluir este agendamento?</span>
    <div class="panel-controls" onclick="af('f');" type="button"><i class="far fa-arrow-left"></i> <span class="hidden-xs">Voltar</span>
    </div>
</div>

    <div class="panel-body">
    <%
    set vRPT = db.execute("select * from agendamentosrepeticoes where Agendamentos like '%|"& ConsultaID &"|%'")
    if not vRPT.eof then
        %>
        <div class="alert alert-warning">
            Este agendamento foi gerado em uma sequencia de repetições. O que você deseja fazer com os outros agendamentos deste conjunto?
            <br />
            <label><input type="radio" class="ace" name="rptAction" value="Todos" /><span class="lbl"> Excluir todos os agendamentos gerados junto a este.</span></label><br />
            <label><input type="radio" class="ace" name="rptAction" value="Posteriores" /><span class="lbl"> Excluir todos os agendamentos posteriores a este. (incluindo este)</span></label><br />
            <label><input type="radio" class="ace" name="rptAction" value="Somente" /><span class="lbl"> Excluir somente este.</span></label>

        </div>
        <%
    end if
        %>

		<div class="row">
        	<div class="col-md-12">
	            <label class="control-label bolder blue">Informe abaixo o motivo da exclus&atilde;o:</label>
            </div>
        </div>
        <div class="row">
        	<div class="col-md-7">
			<%
			set motivos = db.execute("select * from motivosreagendamento where sysActive=1")
			while not motivos.eof
				%>
				<label><input required type="radio" name="Motivo" class="ace" value="<%=motivos("id")%>" /><span class="lbl"> <%=motivos("Motivo")%></span></label><br />
				<%
			motivos.movenext
			wend
			motivos.close
			set motivos = nothing
			%>
            </div>
            <div class="col-md-5">
            	<textarea name="Obs" class="form-control" placeholder="Observa&ccedil;&otilde;es..."></textarea>
            </div>
            <input type="hidden" name="tipoequipamento" id="tipoequipamento">
        </div>
	</div>
    <div class="panel-footer">
        <button class="btn btn-sm btn-danger" id="btnConfirmarExclusao" data-bb-handler="danger">
            <i class="far fa-trash"></i> Confirmar Exclus&atilde;o
        </button>
    </div>
</div>
    <input type='hidden'>
</form>
<script >
    $(document).ready(function() {
        $("#tipoequipamento").val($("#EquipamentoID").val());

        $("#formExcluiAgendamento").submit(function() {
            $("#btnConfirmarExclusao").attr("disabled", true);

            excluiAgendamento('<%=ConsultaID%>', 1);

            return false;
        });
    });
</script>
	<%
else

    agendaEquipamento = ref("tipoequipamento")
	set pCon=db.execute("select *, l.UnidadeID,ag.id as id from agendamentos ag left JOIN locais l ON (l.id  = ag.LocalID) where ag.id="&ConsultaID)
	ProfissionalID=pCon("ProfissionalID")
	PacienteID=pCon("PacienteID")
	ProcedimentoID=pCon("TipoCompromissoID")
	Data=pCon("Data")
	Hora=hour(pCon("Hora"))&":"&minute(pCon("Hora"))
	Sta=0
	Usuario=session("User")

    ' ######################### BLOQUEIO FINANCEIRO ########################################
    if not isnull(pcon("UnidadeID")) then
        contabloqueada = verificaBloqueioConta(2, 2, 0, pcon("UnidadeID"),Data)
        if contabloqueada = "1" then
            redirectID = ProfissionalID
            if agendaEquipamento <> "" then
                redirectID = agendaEquipamento
            end if
             %>
            <script type="text/javascript">
                showMessageDialog('Agenda bloqueada para edição retroativa (data fechada).', 'danger', 'Não permitido!');
                loadAgenda('<%=Data%>', <%= redirectID %>);
                af('f');
            </script>
            <%
            Response.End
        end if
    end if
    ' #####################################################################################

	if isNumeric(ref("Motivo")) and ref("Motivo")<>"" then
		Motivo=ref("Motivo")
	else
		Motivo=0
	end if
	Obs=ref("Obs")
	ARE="X"
	ConsultaID=pCon("id")
	
	sql = "insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID, UnidadeID) values ('"&PacienteID&"', '"&ProfissionalID&"', '"&ProcedimentoID&"', '"&now()&"', "&mydatenull(Data)&", '"&Hora&"', '"&Sta&"', '"&Usuario&"', '"&Motivo&"', '"&Obs&"', '"&ARE&"', '"&ConsultaID&"', "&treatvalzero(session("UnidadeID"))&")"
	
'	response.Write(sql)
	
    if token = "98b4d9bbfdfe2170003fcb23b8c13e6b" then

        call agendaUnificada("delete", ConsultaID, ProfissionalID)
        
        sqlDel = "update agendamentos set sysActive='-1' where id="&ConsultaID

        call gravaLogs(sqlDel, "AUTO", "Agendamento excluído", "")
        db_execute(sqlDel)
    else
        dd("funcionou")
    end if
	'call centralSMS("", "", "", ConsultaID)
	'call centralEmail("", "", "", ConsultaID)
	call googleCalendar("X", "", ConsultaID, "", "", "", "", "", "", "")

    getEspera(ProfissionalID &"")

    select case ref("rptAction")
        case "Todos"
            set ags = db.execute("select replace(Agendamentos, '|', '') ids from agendamentosrepeticoes where Agendamentos like '%|"&ConsultaID&"|%'")
            if not ags.eof then
                Apagar = ags("ids")
                db_execute("delete from agendamentos where id IN("&Apagar&")")
            end if
        case "Posteriores"
            set ags = db.execute("select replace(Agendamentos, '|', '') ids from agendamentosrepeticoes where Agendamentos like '%|"&ConsultaID&"|%'")
            if not ags.eof then
                Apagar = ags("ids")
                db_execute("delete from agendamentos where id IN("&Apagar&") and Data>"&mydatenull(Data))
            end if
    end select

    redirectID = ProfissionalID
    if agendaEquipamento <> "" then
        redirectID = agendaEquipamento
    end if

	%>
	<script type="text/javascript">


    gtag('event', 'agendamento_excluido', {
        'event_category': 'agendamento',
        'event_label': "Agendamento > Excluir",
    });

    loadAgenda('<%=Data%>', <%= redirectID %>);

    getUrl("patient-interaction/get-appointment-events", {appointmentId: "<%=ConsultaID%>"});

    af('f');
	</script>
	<%
end if
%>