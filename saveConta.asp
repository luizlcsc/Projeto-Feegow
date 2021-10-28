<!--#include file="connect.asp"-->
<%
id = req("AtID")
valor = ref("Valor")

db_execute("update atendimentosprocedimentos set Obs='"&valor&"' where id="&id)
%>
$.gritter.add({
    title: '<i class="far fa-save"></i> Observa&ccedil;&otilde;es salvas!',
    text: '',
    class_name: 'gritter-success gritter-light'
});
