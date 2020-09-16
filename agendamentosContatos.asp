<!--#include file="connect.asp"-->
<%
AgendamentoID = req("id")
n = 0
while n<5
    n = n+1
    set ac = db.execute("select * from agendamentoscontatos where AgendamentoID='"& AgendamentoID &"' AND n="& n)
    if ac.eof then
        EmailAcesso = ""
        Nome = ""
        Telefone = ""
    else
        EmailAcesso = ac("EmailAcesso")
        Nome = ac("Nome")
        Telefone = ac("Telefone")
    end if
    call quickfield("text", "EmailAcesso"&n, "E-mail de acesso", 5, EmailAcesso, "", "", "")
    call quickfield("text", "Nome"&n, "Nome", 5, Nome, "", "", "")
    call quickfield("phone", "Telefone"&n, "Telefone", 2, Telefone, "", "", "")
wend
%>