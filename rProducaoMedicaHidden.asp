<!--#include file="connect.asp"-->

<style type="text/css">
body, tr, td, th {
	font-size:11px;
	padding:2px!important;
}
</style>

<%
db_execute("CREATE TABLE IF NOT EXISTS `tempfaturamento` (  `sysUser` int(11) DEFAULT NULL,  `ProcedimentoID` int(11) DEFAULT NULL,  `ProfissionalID` int(11) DEFAULT NULL,  `ConvenioID` int(11) DEFAULT NULL,   `Valor` float NULL DEFAULT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8")
db_execute("delete from tempfaturamento where sysUser="&session("User"))

DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")
'ProfissionalID = req("ProfissionalID")
'if ProfissionalID="0" then
'	sqlProf = ""
'else
'	sqlProf = " and p.id="&ProfissionalID
'end if
%>
<h3 class="text-center">Produ&ccedil;&atilde;o M&eacute;dica Geral</h3>
<h4 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h4>

      <%
	  Total = 0
	  set prof = db.execute("select p.*, u.id UsuarioID from profissionais p left join sys_users u on u.idInTable=p.id and `Table` like 'profissionais' where p.sysActive=1 and p.Ativo='on' "&sqlProf&" and p.id in("&req("ProfissionalID")&") order by p.NomeProfissional")
	  while not prof.eof
	  	if isnull(prof("UsuarioID")) then
			UsuarioID = 0
		else
			UsuarioID = prof("UsuarioID")
		end if
	  %>
<table class="table table-bordered table-hover" width="100%">
	<thead>
		<tr>
        	<th colspan="6" class="warning text-center">PROFISSIONAL: <%=ucase(prof("NomeProfissional"))%></th>
        </tr>
        <tr class="success">
        	<th class="text-center">PACIENTE</th>
            <th class="text-center">DATA</th>
            <th class="text-center">HORA</th>
            <th class="text-center">SERVI&Ccedil;O / PROCEDIMENTO</th>
            <th>CONV&Ecirc;NIO</th>
            <th class="text-center">VALOR</th>
        </tr>
	</thead>
    <tbody>
        <%
		'set G = db.execute("select pac.NomePaciente, c.NomeConvenio, gc.DataAtendimento, gc.id, p.NomeProcedimento, gc.ValorProcedimento from tissguiaconsulta as gc left join procedimentos as p on gc.ProcedimentoID=p.id left join convenios as c on c.id=gc.ConvenioID left join pacientes as pac on pac.id=gc.PacienteID where ProfissionalID="&prof("id")&" and gc.sysActive=1 and DataAtendimento>="&mydatenull(DataDe)&" and DataAtendimento<="&mydatenull(DataAte)&" union all select pac.NomePaciente, c.NomeConvenio, gsi.`Data`, gs.id, p.NomeProcedimento, gsi.ValorTotal from tissprocedimentossadt as gsi left join tissguiasadt as gs on gs.id=gsi.GuiaID left join procedimentos as p on gsi.ProcedimentoID=p.id left join convenios as c on c.id=gs.ConvenioID left join pacientes as pac on pac.id=gs.PacienteID where ProfissionalID="&prof("id")&" and gs.sysActive=1 and `Data`>="&mydatenull(DataDe)&" and `Data`<="&mydatenull(DataAte)&" order by DataAtendimento")
		if req("Unidades")<>"" then
			sqlUnidades = " and at.UnidadeID in ("&req("Unidades")&")"
		end if
	'	str = "select ap.ValorPlano, at.PacienteID, ap.rdValorPlano, at.`Data`, at.HoraInicio, at.HoraFim, proc.NomeProcedimento, proc.TipoProcedimentoID, pac.NomePaciente, conv.NomeConvenio, conv.segundoProcedimento, conv.terceiroProcedimento, conv.quartoProcedimento, ap.ProcedimentoID, ap.ValorPlano ConvenioID from atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID LEFT JOIN procedimentos proc on ap.ProcedimentoID=proc.id LEFT JOIN pacientes pac on pac.id=at.PacienteID LEFT JOIN convenios conv on conv.id=ap.ValorPlano WHERE ProfissionalID="&prof("id")&" and `Data`>="&mydatenull(DataDe)&" and `Data`<="&mydatenull(DataAte)&" "&sqlUnidades&" order by NomePaciente, HoraInicio"
		str = " select ap.ValorPlano, at.PacienteID, ap.rdValorPlano, at.`Data`, at.HoraInicio, at.HoraFim, proc.NomeProcedimento, proc.TipoProcedimentoID, pac.NomePaciente, conv.NomeConvenio, conv.segundoProcedimento, conv.terceiroProcedimento, conv.quartoProcedimento, ap.ProcedimentoID, ap.ValorPlano ConvenioID  from atendimentosprocedimentos ap  LEFT JOIN atendimentos at on at.id=ap.AtendimentoID  LEFT JOIN procedimentos proc on ap.ProcedimentoID=proc.id  LEFT JOIN pacientes pac on pac.id=at.PacienteID  LEFT JOIN pacientesconvenios pc on pc.PacienteID=pac.id and not isnull(ConvenioID)  LEFT JOIN convenios conv on conv.id=pc.ConvenioID WHERE ProfissionalID="&prof("id")&" and `Data`>="&mydatenull(DataDe)&" and `Data`<="&mydatenull(DataAte)&" "&sqlUnidades&" order by NomePaciente, HoraInicio"
'		response.Write(str)
		set G = db.execute(str)
		Subtotal = 0
		SubtotalNovo = 0
		Conta = 0
		while not G.eof
			ProcedimentoID = G("ProcedimentoID")
			TipoProcedimentoID = G("TipoProcedimentoID")
			ConvenioID = G("ConvenioID")
			PlanoID = 0
			PacienteID = G("PacienteID")
			Caso = 0
			NomePaciente = G("NomePaciente")
			segundoProcedimento = G("segundoProcedimento")
			terceiroProcedimento = G("terceiroProcedimento")
			quartoProcedimento = G("quartoProcedimento")
			
			
			if G("rdValorPlano")="V" then
				Valor = G("ValorPlano")
				Convenio = "Particular"
			else
				if ConvenioID<>0 and not isnull(ConvenioID) then
					set convpac = db.execute("select ConvenioID, PlanoID from pacientesconvenios where PacienteID="&PacienteID&" and ConvenioID="&ConvenioID)
					if convpac.eof then
						rebusca = "S"
					else
						ConvenioID = convpac("ConvenioID")
						Caso = 1
						if not isnull(convpac("PlanoID")) then
							PlanoID = convpac("PlanoID")
						end if
					end if
				else
					rebusca = "S"
				end if
				if rebusca = "S" then
					set convpac = db.execute("select ConvenioID, PlanoID from pacientesconvenios where PacienteID="&PacienteID&" and not isnull(ConvenioID) and ConvenioID<>0 order by PlanoID desc")
					if not convpac.eof then
						ConvenioID = convpac("ConvenioID")
						Caso = 2
						if not isnull(convpac("PlanoID")) then
							PlanoID = convpac("PlanoID")
						end if
					end if
				end if
				'Acima terminei de definir o convenio do paciente
				
				'define o valor pago pelo convenio para o procedimento (geral)
				set proc = db.execute("select pv.*, pv.id as AssociacaoID, pt.* from tissprocedimentosvalores as pv left join tissprocedimentostabela as pt on pv.ProcedimentoTabelaID=pt.id where pv.ConvenioID="&ConvenioID&" and pv.ProcedimentoID="&ProcedimentoID)
				if proc.eof then
					Valor = 0
					AssociacaoID = 0
				else
					if isnull(proc("Valor")) then
						Valor = 0
					else
						Valor = proc("Valor")
					end if
					AssociacaoID = proc("AssociacaoID")
				end if
				Convenio = G("NomeConvenio")

				'refinando mais a busca pra ver se o plano do paciente tem valor diferenciado
				set procval = db.execute("select * from tissprocedimentosvaloresplanos where AssociacaoID="&AssociacaoID&" and PlanoID="&PlanoID)
				if not procval.eof then
					if not isnull(procval("Valor")) and procval("valor")>0 then
					'	Valor = procval("Valor")
					end if
				end if
			end if
			Subtotal = Subtotal+Valor
			if (Convenio="" or isnull(Convenio)) and isnumeric(ConvenioID) and not isnull(ConvenioID) and ConvenioID<>"" then
				set nomeconv = db.execute("select NomeConvenio, segundoProcedimento, terceiroProcedimento, quartoProcedimento from convenios where id="&ConvenioID)
				if not nomeconv.eof then
					Convenio = nomeconv("NomeConvenio")
					segundoProcedimento = nomeconv("segundoProcedimento")
					terceiroProcedimento = nomeconv("terceiroProcedimento")
					quartoProcedimento = nomeconv("quartoProcedimento")
				end if
			end if
			
			
			if UltimoPaciente<>NomePaciente then
				Contagem = 0
			end if
			if TipoProcedimentoID=4 and Convenio<>"Particular" and Contagem<4 then
				Contagem = Contagem+1
			end if
			
			ValorNovo = Valor
			if Contagem=2 and not isnull(segundoProcedimento) and TipoProcedimentoID=4 then
				ValorNovo = Valor*(segundoProcedimento/100)
			end if
			if Contagem=3 and not isnull(terceiroProcedimento) and TipoProcedimentoID=4 then
				ValorNovo = Valor*(terceiroProcedimento/100)
			end if
			if Contagem=4 and not isnull(quartoProcedimento) and TipoProcedimentoID=4 then
				ValorNovo = Valor*(quartoProcedimento/100)
			end if
			
			if ( instr(req("Forma"), "V")>0 and G("rdValorPlano")="V" )    OR    ( instr(req("Forma"), "P")>0 and G("rdValorPlano")="P" )   OR     ( instr(req("Forma"), "|"&ConvenioID&"|")>0 and G("rdValorPlano")="P" )     then
				Conta = Conta+1
				SubtotalNovo = SubtotalNovo+ValorNovo
				if G("rdValorPlano")="V" then
					tempConv=0
				else
					tempConv=ConvenioID
				end if
				db_execute("insert into tempfaturamento (sysUser, ProcedimentoID, ConvenioID, Valor) values ("&session("User")&", "&ProcedimentoID&", "&ConvenioID&", "&treatvalzero(ValorNovo)&")")
				%>
				<tr>
					<td><%=NomePaciente%></td>
					<td><%=G("Data")%></td>
					<td><% If not isnull(G("HoraInicio")) and not isnull(G("HoraFim")) Then %><%=formatdatetime(G("HoraInicio"),4)%> - <%=formatdatetime(G("HoraFim"),4)%><% End If %></td>
					<td><%=G("NomeProcedimento")%></td>
					<td><%=Convenio%><!-- PlanoID = <%=PlanoID%> PacienteID = <%=PacienteID%> ConvenioID = <%=ConvenioID%> Caso = <%=Caso%>--></td>
					<td class="text-right"><%'=formatnumber(Valor,2)%><%=formatnumber(ValorNovo,2)%></td>
					<td nowrap class="hidden">
						Tipo Procedimento: <%'=TipoProcedimentoID%><br>
						Contagem: <%'=Contagem%><br>
						Percentual: <%'=segundoProcedimento%><br>
						<%=ConvenioID%><br>
						<%=G("rdValorPlano")%>
					</td>
				</tr>
				<%
			end if
			UltimoPaciente = NomePaciente
		G.movenext
		wend
		G.close
		set G=nothing
		%>
		<tr>
        	<td colspan="4"><strong><%=Conta%> procedimento(s)</strong></td>
        	<td class="text-right"><strong>SUBTOTAL:</strong></td>
            <td class="text-right"><strong><%'=formatnumber(Subtotal,2)%><%=formatnumber(SubtotalNovo,2)%></strong></td>
        </tr>
    </tbody>
</table>
<hr style="page-break-after:auto; margin:0;padding:0">
	  	<%
		Total = Total+Subtotal
		TotalNovo = TotalNovo+SubtotalNovo
	  prof.movenext
	  wend
	  prof.close
	  set prof = nothing
	  %>
<table class="table table-striped table-bordered" width="100%">
  <thead>
  	<tr>
    	<th colspan="3">Resumo por Procedimento</th>
    </tr>
  </thead>
  <tbody>
	<%
	set res = db.execute("select distinct tf.ProcedimentoID, proc.NomeProcedimento, (select count(*) from tempfaturamento where ProcedimentoID=tf.ProcedimentoID and sysUser="&session("User")&") qtd, (select sum(valor) from tempfaturamento where sysUser="&session("User")&" and ProcedimentoID=tf.ProcedimentoID) total from tempfaturamento tf left join procedimentos proc on proc.id=tf.ProcedimentoID where not isnull(NomeProcedimento) and tf.sysUser="&session("User")&" order by proc.NomeProcedimento")
	TotalProcs = 0
	TotalProcsValor = 0
	while not res.EOF
		TotalProcs = TotalProcs+ccur(res("qtd"))
		TotalProcsValor = TotalProcsValor+ccur(res("total"))
		%>
		<tr>
        	<td><%=res("NomeProcedimento")%></td>
        	<td class="text-right"><%=res("qtd")%></td>
        	<td class="text-right">R$ <%=formatnumber(res("total"), 2)%></td>
        </tr>
		<%
	res.movenext
	wend
	res.close
	set res=nothing
	%>
  </tbody>
  <tfoot>
    <tr>
    	<td><strong>TOTAL GERAL</strong></td>
        <td class="text-right"><strong><%=TotalProcs%></strong></td>
        <td class="text-right"><strong>R$ <%=formatnumber(TotalProcsValor, 2)%></strong></td>
    </tr>
  </tfoot>
</table>
