<%
on error resume next
%>
<!--#include file="centralFunctions.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="SendMailMarketing.asp"-->
<%
set mm = dbc.execute("select * from emailmarketing LIMIT 10")
while not mm.eof
	Mensagem = mm("Mensagem")
	%>
	<%=mm("EmailRemetente") &" - "&mm("Assunto")%><br>
	<%
	call SendMailMarketing(mm("EmailRemetente"), mm("NomeRemetente"), mm("Para"), mm("Assunto"), Mensagem )
	dbc.execute("insert into emailmarketing_historico (select * from emailmarketing where id="&mm("id")&")")
	dbc.execute("delete from emailmarketing where id="&mm("id"))
mm.movenext
wend
mm.close
set mm=nothing
%>