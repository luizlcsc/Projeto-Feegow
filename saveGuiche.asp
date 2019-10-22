<!--#include file="connect.asp"-->
<%
Action = ref("Action")
Ticket = ref("Ticket")
Val = ref("Val")

if Action="Sta" then
    if Ticket="0" then
        set pult = db.execute("select Senha from guiche where date(DataHoraChegada)=curdate() order by Senha desc limit 1")
        if pult.eof then
            Ticket = 1
        else
            Ticket = pult("Senha")+1
        end if
        db_execute("insert into guiche (Senha, Sta) values ("&Ticket&", 'Imprimir')")
        %>

        <%
    else
        if Val = "Atendido" then
            DataAtendimento = now()
        end if

        db_execute("update guiche set Sta='"&Val&"', sysUser="&session("User")&", Guiche='"&session("Guiche")&"', DataHoraAtendimento="&mydatetime(DataAtendimento)&" where id="&Ticket)
    end if
end if
if Action="Guiche" then
    response.Cookies("Guiche")=Val
    Response.Cookies("Guiche").Expires = Date() + 365
    session("Guiche")=Val
end if
if Action="AtualizaPaciente" then
    PacienteID=ref("PacienteID")
    db_execute("update guiche SET PacienteID="&PacienteID&" WHERE id="&Ticket)

    LinkPaciente = "?P=Pacientes&I="&PacienteID&"&Pers=1"
    %>
    $(".item-guiche[data-id=<%=Ticket%>]").find(".btn-paciente-pre-espera").attr("href", "<%=LinkPaciente%>")
    <%
end if
%>