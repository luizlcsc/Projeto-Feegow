<!--#include file="connect.asp"-->
<%
if 1=2 then
    set pHor = db.execute("select id from assfixalocalxprofissional where ProfissionalID="&req("ProfissionalID"))
    while not pHor.EOF
	    id = pHor("id")
	    db_execute("update assfixalocalxprofissional set HoraDe="&mytime(ref("HoraDe"&id))&", HoraA="&mytime(ref("HoraA"&id))&", Intervalo="&treatvalnull(ref("Intervalo"&id))&", LocalID="&treatvalzero(ref("LocalID"&id))&", Compartilhada='"&ref("Compartilhada"&id)&"' where id="&id)
    pHor.movenext
    wend
    pHor.close
    set pHor=nothing
end if

if erro<>"" then
%>
    $.gritter.add({
        title: '<i class="far fa-thumbs-down"></i> Erro no horário de <%=weekdayname(Dia)%>!',
        text: '<%=erro1%><br><%=erro2%><br><%=erro3%>',
        class_name: 'gritter-error gritter-light'
    });
<%
else
%>
    new PNotify({
        title: 'Salvo',
        text: 'Horários gravados com sucesso.',
        type: 'success',
        delay: 1000
    });
<%

db_execute("update profissionais set MaximoEncaixes="&treatvalnull(ref("MaximoEncaixes"))&" where id="&req("ProfissionalID"))

end if


%>
<!--#include file="disconnect.asp"-->