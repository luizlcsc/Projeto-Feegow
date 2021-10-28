<!--#include file="connect.asp"-->
<%
    db_execute("delete from chamadasrecontatar where Contato='"&req("ContatoID")&"' and sysUser="& session("User"))
    db_execute("insert into chamadasrecontatar (Contato, Data, Hora, sysUser, ChamadaOrigemID) values ('"&req("ContatoID")&"', "&mydatenull(ref("DataReligar"))&", '"&ref("HoraReligar")&"', "&session("User")&", "&ref("CallID")&")")
%>
new PNotify({
    title: '<i class="far fa-save"></i> Recontato Salvo',
    text: 'Para dia <%=ref("DataReligar") %> às <%=ref("HoraReligar") %>',
    type: 'success'
});
