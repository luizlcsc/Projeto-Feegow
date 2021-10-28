<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")

set pac = db.execute("select p.NomePaciente, p.ConvenioID1 from pacientes p where p.id="&PacienteID)
ConvenioID = pac("ConvenioID1")
if isnull(ConvenioID) or ConvenioID=0 then
	ConvenioID = ""
else
	ConvenioID = pac("ConvenioID")
end if

set atend = db.execute("select * from atendimentos where PacienteID="&PacienteID&" and Data="&mydatenull(date())&" order by id desc limit 1")
if not atend.EOF then
	HoraInicio = atend("HoraInicio")
	if not isnull(HoraInicio) then
		HoraInicio = formatdatetime(HoraInicio, 4)
	end if
	HoraFim = atend("HoraFim")
	if not isnull(HoraFim) then
		HoraFim = formatdatetime(HoraFim, 4)
	end if
	set prof = db.execute("select * from sys_users where `Table` like 'Profissionais' and id="&treatvalnull(atend("sysUser")))
	if not prof.EOF then
		ProfissionalID = prof("idInTable")
	end if
end if
if ProfissionalID="" then
	set agend = db.execute("select ProfissionalID from agendamentos where Data="&mydatenull(date())&" and PacienteID="&PacienteID&" limit 1")
	if not agend.eof then
		ProfissionalID = agend("ProfissionalID")
	end if
end if
%>
<form id="infproc">
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title">Lan&ccedil;ar Procedimento Realizado &raquo; <small><%=pac("NomePaciente")%></small> </h4>
</div>
<div class="modal-body">
    <div class="row">
		<%=quickField("select", "inf-ProfissionalID", "Profissional", 5, ProfissionalID, "select id, NomeProfissional from profissionais where sysActive=1 order by NomeProfissional", "NomeProfissional", "")%>
		<%=quickField("datepicker", "inf-Data", "Data", 3, date(), "", "", " required")%>
		<%=quickField("text", "inf-HoraInicio", "In&iacute;cio", 2, HoraInicio, "input-mask-l-time", "", "required")%>
		<%=quickField("text", "inf-HoraFim", "Fim", 2, HoraFim, "input-mask-l-time", "", "required")%>
    </div>
    <div class="row">
		<%=quickField("select", "inf-ProcedimentoID", "Procedimento", 5, "", "select '' id, '--- Selecione ---' NomeProcedimento UNION ALL select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeProcedimento", "NomeProcedimento", " required onchange='valProcInf(this.value)'")%>
        <div class="col-md-3"><br>
        	<label><input type="radio" onClick="vp('V')" class="ace" name="inf-rdValorPlano" value="V"<%if ConvenioID="" then%> checked<%end if%>> <span class="lbl"> Particular</span></label>
            &nbsp;
        	<label><input type="radio" onClick="vp('P')" class="ace" name="inf-rdValorPlano" value="P"<%if ConvenioID<>"" then%> checked<%end if%>> <span class="lbl"> Conv&ecirc;nio</span></label>
        </div>
   		<%=quickField("simpleSelect", "inf-ConvenioID", "Conv&ecirc;nio", 4, ConvenioID, "select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", "")%>
   		<%=quickField("currency", "inf-Valor", "Valor", 4, "", "", "", "")%>
    </div>
    <div class="row">
		<%=quickField("memo", "inf-Obs", "Observa&ccedil;&otilde;es", 6, "", "", "", "")%>
    </div>
</div>
<div class="modal-footer">
	<button class="btn btn-save btn-success"><i class="far fa-save"></i> Salvar</button>
</div>
</form>

<%
'Verifica se no dia teve agendamento e coloca atrelado ao agendamentoid
' já marca o convenio/particular baseado na ficha do paciente
%>

<script>
function vp(val){
	if(val=='V'){
		$("#qfinf-convenioid").css("display", "none");
		$("#qfinf-valor").css("display", "block");
	}else{
		$("#qfinf-convenioid").css("display", "block");
		$("#qfinf-valor").css("display", "none");
	}
}
$(document).ready(function(e) {
    <%
	if ConvenioID="" then
		%>
		vp("V");
		<%
	else
		%>
		vp("P");
		<%
	end if
	%>
});

function valProcInf(val){
	$.post("inf-AgendaParametros.asp?tipo=select-ProcedimentoID&id="+val, "", function(data, status){ eval(data) })
}

$("#infproc").submit(function(){
	$.post("saveInfProc.asp?PacienteID=<%=PacienteID%>", $("#infproc").serialize(), function(data, status){ eval(data) });
	return false;
});
<!--#include file="jqueryfunctions.asp"-->
</script>