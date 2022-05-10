<%
response.Charset="utf-8"

on error resume next

%>
<!--#include file="connect.asp"-->
<%

if pac1="" and pac2="" then
    pac1 = ccur(req("p1"))
    pac2 = ccur(req("p2"))
end if

set p1=db.execute("select * from pacientes where id="&pac1)
set p2=db.execute("select * from pacientes where id="&pac2)

if not p1.eof and not p2.eof then
	'verifica quem teve o último atendimento
	set ultat = db.execute("select PacienteID from atendimentos where PacienteID in (182512, 226081) order by Data desc limit 1")
	if not ultat.eof then
		if ultat("PacienteID")=pac1 or ultat("PacienteID")=pac2 then
			Prin = ultat("PacienteID")
		else
			Prin = pac1
		end if
	end if
	if Prin=pac1 then
		novoid = pac1
		velhoid = pac2
	else
		novoid = pac2
		velhoid = pac1
	end if





	%>
    <table width="100%" border="1">
    <thead>
      <tr>
        <th></th>
        <th><% If pac1=Prin Then %>&raquo; <% End If %>Paciente <%= pac1 %></th>
        <th><% If pac2=Prin Then %>&raquo; <% End If %>Paciente <%= pac2 %></th>
        <th>Valor Final</th>
      </tr>
    </thead>
    <tbody>
	<%
	set campos = db.execute("select * from cliniccentral.sys_resourcesfields where resourceID=1")
	while not campos.eof
		Coluna = campos("columnName")
		if Prin=pac1 then
			Valor = p1(""&Coluna&"")
			Reverso = p2(""&Coluna&"")
		else
			Valor = p2(""&Coluna&"")
			Reverso = p1(""&Coluna&"")
		end if
		if isnull(Valor) or Valor="" then
			Valor = Reverso
		end if

		ints = "sexo, estadocivil, corpele, grauinstrucao, tabela, pais, convenioid1, convenioid2, convenioid3, planoid1, planoid2, planoid3"
		if instr(ints, lcase(Coluna))>0 then
			strUpdate = strUpdate&Coluna&"="&treatvalnull(Valor)&", "
		elseif Coluna="Nascimento" or Coluna="Validade1" or Coluna="Validade2" or Coluna="Validade3" then
			strUpdate = strUpdate&Coluna&"="&mydatenull(Valor)&", "
		else
			strUpdate = strUpdate&Coluna&"='"&rep(Valor)&"', "
		end if
		%>
		<tr>
        	<th><%=campos("label")%></th>
        	<td><%=p1(""&Coluna&"")%></td>
        	<td><%=p2(""&Coluna&"")%></td>
            <td><%= Valor %></td>
        </tr>
		<%
	campos.movenext
	wend
	campos.close
	set campos = nothing
end if

strUpdate = "update pacientes set "&strUpdate &"sysActive=1 where id="&novoid

'response.Write(strUpdate)
db_execute(strUpdate)
'response.Write("delete from pacientes where id="&velhoid)
db_execute("UPDATE pacientes SET sysActive=-1 where id="&velhoid)

call logMessage("pacientes",novoid,"Mesclagem de paciente. "&p1("NomePaciente")&"{"&velhoid&"} -> "&p2("NomePaciente")&"{"&novoid&"}")

set fp = db.execute("select distinct ModeloID from buiformspreenchidos where  ModeloID <> 0 and PacienteID="&velhoid)
while not fp.eof
	db_execute("update _"&fp("ModeloID")&" set PacienteID="&novoid&" where PacienteID="&velhoid)
fp.movenext
wend
fp.close
set fp=nothing

'pega os buiforms preenchidos antes desse cara e da um distinct nos modelos, em seguida passando pelas tabelas

'db_execute("update agendamentos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update arquivos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update atendimentos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update buicurva set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update buiformslembrarme set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update buiformspreenchidos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update buiregistrosforms set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update estoquelancamentos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update filaespera set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update logsmarcacoes set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update pacientesatestados set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update pacientesdiagnosticos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update pacientespedidos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update pacientesprescricoes set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update pacientesrelativos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update pacientesretornos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update recibos set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update tissguiaconsulta set PacienteID="&novoid&" where PacienteID="&velhoid)
'db_execute("update tissguiasadt set PacienteID="&novoid&" where PacienteID="&velhoid)

db_execute("update invoicesfixas set AccountID="&novoid&" where AssociationAccountID=3 and AccountID="&velhoid)
db_execute("update sys_financialinvoices set AccountID="&novoid&" where AssociationAccountID=3 and AccountID="&velhoid)
db_execute("update sys_financialissuedchecks set AccountID="&novoid&" where AccountAssociationID=3 and AccountID="&velhoid)
db_execute("update sys_financialreceivedchecks set AccountID="&novoid&" where AccountAssociationID=3 and AccountID="&velhoid)
db_execute("update sys_financialmovement set AccountIDCredit="&novoid&" where AccountAssociationIDCredit=3 and AccountIDCredit="&velhoid)
db_execute("update sys_financialmovement set AccountIDDebit="&novoid&" where AccountAssociationIDDebit=3 and AccountIDDebit="&velhoid)


set tabs = db.execute("select table_name, column_name from information_schema.columns i where i.table_schema='"&session("Banco")&"' and i.column_name in('PacienteID', 'Paciente') and i.table_name!='agendamentoseatendimentos' order by table_name")
while not tabs.eof
    db_execute("update `"&tabs("table_name")&"` set `"&tabs("column_name")&"`="&novoid&" where `"&tabs("column_name")&"`="&velhoid)
tabs.movenext
wend
tabs.close
set tabs = nothing

if not MesclarMultiplos then
    response.Redirect("./?P=Pacientes&Pers=1&I="&novoid)
end if
%>
</tbody>
</table>
<%'=strUpdate%>