<!--#include file="connect.asp"-->
<div>
<table width="100%" class="table table-striped table-bordered table-hover table-condensed">
<thead>
    <tr class="info">
        <th colspan="5">Detalhes do Agendamento</th>
        <th><button type="button" onclick="$('#divhist<%= req("AgendamentoID") %>').css('display', 'none')" class="btn btn-block btn-xs btn-default"><i class="far fa-close"></i> Fechar</button></th>
    </tr>
</thead>
<tbody>
<%
    sql = "select l.*, proc.NomeProcedimento, prof.NomeProfissional, mot.Motivo, mot.Solicitante, sta.StaConsulta, esp.Especialidade NomeEspecialidade FROM LogsMarcacoes l LEFT JOIN procedimentos proc on proc.id=l.ProcedimentoID LEFT JOIN profissionais prof on prof.id=l.ProfissionalID LEFT JOIN agendamentos age ON age.id=l.ConsultaID LEFT JOIN especialidades esp ON esp.id=age.EspecialidadeID or (age.EspecialidadeID is null and prof.EspecialidadeID=esp.id) LEFT JOIN motivosReagendamento mot on mot.id=l.Motivo LEFT JOIN staconsulta sta ON sta.id=l.sta WHERE l.ConsultaID="&req("AgendamentoID")&" and l.PacienteID="&req("PacienteID")&" order by l.DataHora desc"

	set pLogs=db.execute(sql)
	if plogs.eof then
	%>
	<tr><td colspan="2">Nenhum log para este agendamento.</td></tr>
	<%
	end if
	while not pLogs.EOF
		if pLogs("ARX")="X" then
			Acao="Exclus&atilde;o"
		elseif pLogs("ARX")="A" then
			Acao="Agendamento"
		elseif pLogs("ARX")="R" then
			Acao="Altera&ccedil;&atilde;o de agendamento."
		end if
		Agendamentos = Agendamentos & ", "& pLogs("ConsultaID")

		if not isnull(pLogs("Hora")) then
		    Hora = formatdatetime(pLogs("Hora"),3)
        else
		    Hora = pLogs("Hora")
        end if
		%>
		<tr>
		  <td align="left"><strong>HORA AGENDADA</strong><br /><strong><%=pLogs("Data")%>&nbsp;<%=Hora%></strong></td>
		  <td align="left"><strong>PROFISSIONAL</strong> <br /><%if isnull(pLogs("NomeProfissional")) then response.Write("<em>Profissional Exclu&iacute;do</em>") else response.Write(pLogs("NomeProfissional")) end if%></td>
		  <td align="left"><strong>ESPECIALIDADE</strong> <br /><%=pLogs("NomeEspecialidade")%></td>
		  <td align="left"><strong>PROCEDIMENTO</strong> <br /><%if isnull(pLogs("NomeProcedimento")) then response.Write("<em>Procedimento Exclu&iacute;do</em>") else response.Write(pLogs("NomeProcedimento")) end if%></td>
		  <td align="left"><strong>DESCRI&Ccedil;&Atilde;O</strong><br /><%=pLogs("Motivo")%></td>
          <td rowspan="2"><strong>OBSERVA&Ccedil;&Otilde;ES</strong><br /><%=pLogs("Obs")%><br /><em><%=NotasConsulta%></em></td>
	    </tr>
		<tr>
		  <td align="left"><strong>DATA DA A&Ccedil;&Atilde;O</strong><br /><%=pLogs("DataHora")%></td>
		  <td colspan="2" align="left" nowrap="nowrap"><strong>USU&Aacute;RIO</strong><br /><%=NameInTable(pLogs("Usuario"))%></td>
		  <td align="left"><strong>A&Ccedil;&Atilde;O</strong><br /><%=Acao%></td>
          <td align="left"><strong>STATUS</strong> <br /><%=pLogs("StaConsulta")%></td>
        </tr>
        <tr><td colspan="6"></td></tr>

	<%
	pLogs.moveNext
	wend
	pLogs.close
	set pLogs=nothing
%>
</tbody>
</table></div>