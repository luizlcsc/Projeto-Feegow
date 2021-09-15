<!--#include file="connect.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<%
ProfissionalID = req("ProfissionalID")
Data = req("Data")
LocalID = req("LocalID")

if instr(req("A"), "X_")>0 then
	db_execute("delete from filaespera where id="&replace(req("A"), "X_", ""))
end if
if instr(req("A"), "F_")>0 then
	session("FilaEspera")=replace(req("A"), "F_", "")
	if ProfissionalID <> 0 then
	%>
    <script>
	loadAgenda('<%=Data%>', <%=ProfissionalID%>);
	</script>
	<%
	else
	%>
    <script>
	$("#buscar").click();
	</script>
	<%
	end if
end if
if instr(req("A"), "U_")>0 then
	spl = split(req("A"), "_")
	FilaID = spl(1)
	Hora = spl(2)
	set pfila = db.execute("select * from filaespera where id="&FilaID)
	if not pfila.eof then
		Notas = pfila("Notas")
		db_execute("insert into agendamentos (PacienteId, ProfissionalID, Data, Hora, TipoCompromissoID, StaID, ValorPlano, rdValorPlano, Notas, FormaPagto, HoraSta, LocalID, Tempo, HoraFinal, SubtipoProcedimentoID, ConfEmail, ConfSMS, sysUser) values ('"&pfila("PacienteID")&"','"&ProfissionalID&"','"&mydate(Data)&"','"&Hora&"','"&pfila("TipoCompromissoID")&"','7', "&treatValzero(pfila("ValorPlano"))&",'"&pfila("rdValorPlano")&"','"&rep(Notas)&"','0', NULL, "&treatvalzero(LocalID)&", '"&pfila("Tempo")&"', NULL, "&treatvalzero(pfila("SubtipoProcedimentoID"))&", NULL, NULL, "&session("User")&")")
	
		set pult = db.execute("select id, ProfissionalID from agendamentos where PacienteID="& pfila("PacienteID") &" order by id desc limit 1")
		
		call agendaUnificada("insert", pult("id"), pult("ProfissionalID"))
	
	end if
	db_execute("delete from filaespera where id="&FilaID)
	session("FilaEspera")=""
	%>
    <script>
	loadAgenda('<%=Data%>', <%=ProfissionalID%>);
	</script>
	<%
end if

if instr(req("A"), "cancelar")>0 then
	session("FilaEspera")=""
	%>
    <script>
		loadAgenda('<%=Data%>', '<%=ProfissionalID%>');
	</script>
	<%
end if
%>

<button onClick="detalheFilaEspera(0, <%=ProfissionalID%>, 'I')" class="btn btn-block btn-xs btn-info"><i class="far fa-plus"></i> Adicionar Paciente</button>
<div class="row">
	<div class="col-md-12" style="height:300px; overflow-y:scroll">
    <table class="table table-hover table-striped no-padding no-margin">
    <%
	if ProfissionalID<>0 then
		profissionalWhere = "where f.ProfissionalID="&ProfissionalID
	end if 
	
	set fila = db.execute("select f.*, p.NomePaciente from filaespera as f left join pacientes as p on p.id=f.PacienteID "&profissionalWhere&" order by id")
	if fila.eof then
		%>
    	<tr><td>Nenhum paciente na fila de espera deste profissional.</td></tr>
        <%
	end if
	while not fila.eof
	if fila("rdValorPlano")="V" then
		icone="money"
	else
		icone="credit-card"
	end if
		%>
        <tr>
            <td width="1%" nowrap>
            <button type="button" onClick="filaEspera('F_<%=fila("id")%>',<%=ProfissionalID%>);" class="btn btn-xs btn-primary"><i class="far fa-chevron-right"></i></button>
            <button type="button" onClick="detalheFilaEspera(<%=fila("PacienteID")%>, <%=fila("ProfissionalID")%>, 'E')" class="btn btn-xs btn-success"><i class="far fa-edit"></i></button>
            <button type="button" onClick="if(confirm('Tem certeza de que deseja excluir este paciente da fila de espera?'))filaEspera('X_<%=fila("id")%>');" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button>
            </td>
            <td width="1%"><i class="far fa-<%=icone%>"></i></td><td><%=fila("NomePaciente")%></td>
        </tr>
        <%
	fila.movenext
	wend
	fila.close
	set fila=nothing
	%>
    </table>
    </div>
</div>