<meta http-equiv="refresh" content="10" />
<%
response.Charset="utf-8"
on error resume next
Session.Timeout=600
session.LCID=1046
ConnStringo = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=migracao;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set dbo = Server.CreateObject("ADODB.Connection")
dbo.Open ConnStringo
ConnStringd = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=clinic90;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set dbd = Server.CreateObject("ADODB.Connection")
dbd.Open ConnStringd

function rep(Val)
	rep = trim(replace(Val&" ", "'", "''"))
end function

function myDate(Val)
	myDate = year(Val)&"-"&month(Val)&"-"&day(Val)
end function


function nascimento(val)
	nascimento = val
	if isdate(nascimento) then
		nascimento = "'"&myDate(nascimento)&"'"
	else
		nascimento = "NULL"
	end if
end function

function tel(numero)
	if len(numero)>7 then
		tel = "(99) "&left(numero, 4)&"-"&right(numero, 4)
	else
		tel = ""
	end if
end function

function cpf(numero)
	cpf = trim(numero&" ")
	cpf = replace(replace(replace(cpf, "-", ""), ".", ""), " ", "")
	if len(cpf)=11 then
		cpf = left(cpf, 3)&"."&mid(cpf, 4, 3)&"."&mid(cpf, 7, 3)&"-"&right(cpf, 2)
	else
		cpf = ""
	end if
end function

function cep(numero)
	cep = trim(numero&" ")
	cep = replace(replace(replace(cep, "-", ""), ".", ""), " ", "")
	if len(cep)=8 then
		cep = left(cep, 5)&"-"&right(cep, 3)
	else
		cep = ""
	end if
end function

function EstadoCivil(val)
	EstadoCivil = trim(lcase(val&" "))
	if instr(EstadoCivil, "cas")>0 or instr(EstadoCivil, "uni")>0 then
		EstadoCivil = 1
	elseif instr(EstadoCivil, "solt")>0 then
		EstadoCivil = 2
	elseif instr(EstadoCivil, "div")>0 or instr(EstadoCivil, "sep")>0 then
		EstadoCivil = 3
	elseif instr(EstadoCivil, "vi")>0 then
		EstadoCivil = 4
	else
		EstadoCivil = 0
	end if
end function

%>
<table width="100%" border="1">
<%
set p = dbo.execute("select * from receitas where feito='' limit 300")
while not p.eof
	set pac = dbo.execute("select codigo, nome from mala where nome like '"&rep(p("nome"))&"'")
	if not pac.eof then
		receita = ""
		nSubs = 0
		while nSubs<15
			nSubs=nSubs+1
			if trim(p("subs"&nSubs))<>"" then
				receita = receita&"<br />"&p("subs"&nSubs)
			end if
		wend
		receita = receita&"<br /><br /><br />"&p("Posolog")
		%><%=p("numero")%><br /><%
		dbd.execute("insert into pacientesprescricoes (id, Data, sysUser, PacienteID, Prescricao) values ("&p("numero")&", '"&mydate(p("data"))&"', 89, "&pac("codigo")&", '"&rep(receita)&"')")
		dbo.execute("update receitas set feito='S' where numero="&p("numero"))
	else
		dbo.execute("update receitas set feito='N' where numero="&p("numero"))
	end if
p.movenext
wend
p.close
set p= nothing
%>
</table>
Feito :: <%=time()%>