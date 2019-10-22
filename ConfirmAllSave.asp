<!--#include file="connect.asp"-->
<%
A = ref("A")
L = ref("L")
StaID = ref("StaID")
Notas = ref("Notas")

sql = "update clinic"&L&".agendamentos set StaID="& StaID &", Notas='"& ref("Notas") &"' where id="& A

db_execute( sql )
%>
$.gritter.add({
    title: '<i class="fa fa-copy"></i> Alterado com sucesso!',
    text: "<%'= sql %>",
    class_name: 'gritter-success gritter-light'
});
