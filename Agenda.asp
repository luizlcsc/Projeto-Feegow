<style type="text/css">
.carinha {
	margin:-2px 4px 1px 3px;
}
.item-agenda-1 {
	width:35%;
}
.item-agenda-2 {
	width:25%;
}
.item-agenda-3 {
	width:20%;
}
.item-agenda-4 {
	width:9%;
}
.hand {
	cursor:pointer;
}
.hand:hover {
	background-color:#F5FDEA;
}
.intervalo {
	background-color:#f3f3f3;
}
.spanNomePaciente {
	text-overflow: ellipsis;
    overflow: hidden;
    text-align: left;
	width:100%;
}
.modal-dialog{
	width:80%;
	min-width:380px;
	max-width:990px;
	/* asdsd */
	/*Testando TAG*/
}
</style>
<link rel="stylesheet" href="assets/css/fullcalendar.css" />
<!--#include file="connect.asp"-->
<!--#include file="modalAgenda.asp"-->
<!-- PAGE CONTENT BEGINS -->
<%
set vca = db.execute("SELECT TABLE_SCHEMA FROM INFORMATION_SCHEMA.COLUMNS WHERE column_name = 'LocalID' and TABLE_NAME='tempagenda' and TABLE_SCHEMA='"&session("Banco")&"'")
if vca.eof then
	db_execute("alter table tempagenda add column `LocalID` int(11) NULL DEFAULT NULL")
end if
%>
<div class="row">
	<div class="col-sm-9">
		<div class="space"></div>

            <div id="calendario" class="fc fc-ltr">
              <table class="fc-header" style="width:100%">
                <tbody>
                  <tr>
                    <td class="fc-header-left">
                    <%
					if aut("horarios")=1 then
						%>
						<button class="btn btn-default btn-xs" type="button" onclick="location.href='?P=Profissionais&I='+$('#ProfissionalID').val()+'&Pers=1&Aba=Horarios';"><i class="far fa-cog"></i> Grade</button>
						<%
					end if
					%>
                    	<button onClick="imprimir()" class="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown" type="button"><i class="far fa-print"></i> Imprimir </button>
                    </td>
                    <td class="fc-header-center"><span class="fc-header-title">
                      <h2 id="data-escrita"></h2>
                      </span></td>
                    <td class="fc-header-right">
                    <%
					if aut("agendaI")=1 then
					%>
                    <button class="btn btn-default btn-xs" type="button" id="AbrirEncaixe"><i class="far fa-external-link"></i> Abrir Encaixe</button>
                    <button class="btn btn-default btn-xs" type="button" onclick="abreBloqueio(0, $('#Data').val(), '')"><i class="far fa-lock"></i> Inserir Bloqueio</button>
                    <%
					end if
					%>
                    </td>
                  </tr>
                </tbody>
              </table>
              <div class="fc-content" style="position: relative;">
                <div class="fc-view fc-view-agendaDay fc-agenda" style="position: relative; -moz-user-select: none;" unselectable="on">
                  <table class="fc-agenda-days fc-border-separate" cellspacing="0" style="width:100%">
                    <thead>
                      <tr class="fc-first fc-last">
                        <th class="fc-agenda-axis fc-widget-header fc-first" style="width: 72px;"> </th>
                        <th class="fc-thu fc-col0 fc-widget-header" id="nome-profissional"></th>
                        <th class="fc-agenda-gutter fc-widget-header fc-last" style="width: 17px;"> </th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr class="fc-first fc-last">
                        <th class="fc-agenda-axis fc-widget-header fc-first"> </th>
                        <td class="fc-col0 fc-thu fc-widget-content fc-state-highlight fc-today"><div style="height: 1500px">
                            <div class="fc-day-content">
                              <div style="position:relative"> </div>
                            </div>
                          </div></td>
                        <td class="fc-agenda-gutter fc-widget-content fc-last" style="width: 17px;"></td>
                      </tr>
                    </tbody>
                  </table>
                  <div style="position: absolute; z-index: 2; left: 0px; width: 100%; top: 22px;">
                    <div style="position: absolute; width: 100%; overflow-x: hidden; overflow-y: auto; height: 1500px;">
                      <div style="position:relative;width:100%;overflow:hidden">
                        <div class="fc-event-container" style="position:absolute;z-index:8;top:0;left:0"></div>
                        	 <div id="GradeAgenda">
                            </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>


	</div>
	<div class="col-sm-3">
    	<input type="hidden" name="Data" id="Data" value="<%=date()%>" />
		<%
		if aut("agendaV")=1 then
			%>
            <label for="ProfissionalID">Profissional</label>
    	    <select name="ProfissionalID" id="ProfissionalID" class="form-control">
        	<%
			set Prof = db.execute("select id, NomeProfissional from Profissionais where Ativo='on' order by NomeProfissional")
			while not Prof.EOF
				%>
				<option value="<%=Prof("id")%>"<%if lcase(session("table"))="profissionais" and session("idInTable")=Prof("id") then%> selected="selected"<%end if%>><%=Prof("NomeProfissional")%></option>
				<%
			Prof.movenext
			wend
			Prof.close
			set Prof = nothing
			%>
			</select>
            <%
		else
			%>
			<input type="hidden" name="ProfissionalID" id="ProfissionalID" value="<%=session("idInTable")%>" />
			<%
		end if
		%>
        <hr />
        <div id="divCalendario">
	        <%server.Execute("AgendamentoCalendario.asp")%>
        </div>
    </div>
    <div class="col-sm-3">



    <div class="tabbable">
        <ul id="myTab" class="nav nav-tabs">
            <li class="active">
                <a href="#notas" class="no-padding" data-toggle="tab">&nbsp;<i class="green far fa-file-text bigger-110"></i> Notas&nbsp;</a>
		    </li>
            <li>
            	<a href="#fila" class="no-padding" data-toggle="tab" onclick="filaEspera('');">&nbsp;<i class="green far fa-male bigger-110"></i> Fila de Espera&nbsp;</a>
            </li>
		</ul>
        <div class="tab-content">
			<div id="notas" class="tab-pane in active">
            	<textarea id="AgendaObservacoes" name="AgendaObservacoes" rows="7" class="form-control"></textarea>
            </div>
            <div id="fila" class="tab-pane">
            	Carregando...
            </div>
        </div>
    </div>
</div>
<script language="javascript">
function loadAgenda(Data, ProfissionalID){
	$.ajax({
		type:"POST",
		url:"GradeAgenda.asp?Data="+Data+"&ProfissionalID="+ProfissionalID,
		success:function(data){
			$("#GradeAgenda").html(data);
		}
	});
}
<%
if req("Conf")="" then
	%>
	loadAgenda($("#Data").val(), $("#ProfissionalID").val());
<%else
	set conf = db.execute("select ar.*, a.ProfissionalID, a.Data from agendamentosrespostas ar LEFT JOIN agendamentos a on a.id=ar.AgendamentoID LEFT JOIN pacientes p on p.id=a.PacienteID where ar.id= "&req("Conf")&" limit 1")
	%>
	loadAgenda('<%=formatdatetime(conf("Data"),2)%>', '<%=conf("ProfissionalID")%>');
	<%
end if
%>

function abreAgenda(horario, id, data, LocalID){
	$("#modal-agenda").modal('show');
	$.ajax({
		type:"POST",
		url:"divAgendamento.asp?horario="+horario+"&id="+id+"&data="+data+"&profissionalID="+$("#ProfissionalID").val()+"+&LocalID="+LocalID,
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
function abreBloqueio(BloqueioID, Data, Hora){
	if(BloqueioID==-1){
		return;
	}
	$("#modal-agenda").modal('show');
	$.ajax({
		type:"POST",
		url:"divBloqueio.asp?BloqueioID="+BloqueioID+"&Data="+Data+"&Hora="+Hora+"&ProfissionalID="+$("#ProfissionalID").val(),
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
function changeMonth(newDate){
	$.ajax({
	   type:"GET",
	   url:"AgendamentoCalendario.asp?Data="+newDate,
	   success:function(data){
		   $("#divCalendario").html(data);
	   }
	});
}
$("#ProfissionalID").change(function(){
	loadAgenda($('#Data').val(), $(this).val());
	$("#ProfissionalID").val($(this).val());
});
$("#AbrirEncaixe").click(function(){
  abreAgenda('00:00', 0, $('#Data').val(), 0);
});

$("#AgendaObservacoes").change(function(){
	$.post("saveAgendaObservacoes.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val(),
	{Observacoes:$(this).val()},
	function(data,status){
		eval(data);
});
});	
	/*$.post("financialPaymentAccounts.asp",{
			   PaymentMethod:$("#PaymentMethod").val(),
			   T:$("#T").val(),
			   },function(data,status){
		  $("#divPaymentMethod").html(data);
		});
	
	
	
	
	$.ajax({
		type:"POST",
		url:"saveAgendaObservacoes.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val(),
		data: $(this).val(),
		success:function(data){
			alert('salvo');
		}
	});
*/
function filaEspera(A){
	$.ajax({
		type:"POST",
		url:"FilaEspera.asp?ProfissionalID="+$("#ProfissionalID").val()+"&Data="+$("#Data").val()+"&A="+A,
		success: function(data){
			$("#fila").html(data);
		}
	});
}
function remarcar(AgendamentoID, Acao, Hora){
	$.ajax({
		type:"POST",
		url:"Remarcar.asp?ProfissionalID="+$("#ProfissionalID").val()+"&Data="+$("#Data").val()+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao,
		success: function(data){
			eval(data);
		}
	});
}
function repetir(AgendamentoID, Acao, Hora){
	$.ajax({
		type:"POST",
		url:"Repetir.asp?ProfissionalID="+$("#ProfissionalID").val()+"&Data="+$("#Data").val()+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao,
		success: function(data){
			eval(data);
		}
	});
}
function detalheFilaEspera(PacienteID, ProfissionalID, Acao){
	$.ajax({
		type:"POST",
		url:"detalheFilaEspera.asp?PacienteID="+PacienteID+"&ProfissionalID="+ProfissionalID+"&Acao="+Acao,
		success: function(data){
			$("#div-agendamento").html(data);
			$("#modal-agenda").modal("show");
		}
	});
}
function imprimir(){
	$("#modal-agenda").modal("show");
	$("#div-agendamento").html("<iframe src='GradeAgendaPrint.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val()+"' width='100%' height='800' scrolling='auto' frameborder='0'></iframe>");
}
</script>