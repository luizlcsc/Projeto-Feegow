<%
response.Charset="utf-8"
set f = db.execute("select a.PacienteID, a.Data, proc.NomeProcedimento, proc.TipoProcedimentoID, con.segundoProcedimento '2', con.terceiroProcedimento '3', con.quartoProcedimento '4', ap.* from atendimentosprocedimentos ap left join atendimentos a on a.id=ap.AtendimentoID left join convenios con on con.id=ap.ValorPlano left join procedimentos proc on proc.id=ap.ProcedimentoID where ap.ProcedimentoID<>0 and ap.rdValorPlano='P' and ap.ValorPlano<>0 and not isnull(a.PacienteID) and proc.TipoProcedimentoID=4 order by a.Data, a.PacienteID")
while not f.eof
	if PacienteID<>f("PacienteID") or Data<>f("Data") then
		c = 1
		Fator = 100
	else
		c = c+1
		Fator = f(""&c&"")
	end if
	if c>3 then
		c=3
	end if
	if isnull(Fator) then
		Fator = 100
	end if
	Fator = Fator/100
	
	db_execute("update atendimentosprocedimentos set Fator="&treatvalnull(Fator)&" where id="&f("id"))
	if 1=2 then
	%>
	<tr>
    	<td><%= c %></td>
    	<td><%= f("Data") %></td>
    	<td><%= f("PacienteID") %></td>
    	<td><%= f("NomeProcedimento") %></td>
    	<td><%= f("ValorPlano") %></td>
    	<td><%= Fator %></td>
    </tr>
	<%
	end if
	PacienteID = f("PacienteID")
	Data = f("Data")
f.movenext
wend
f.close
set f=nothing
%>