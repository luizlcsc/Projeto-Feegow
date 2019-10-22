<!--#include file="connect.asp"-->
<%
RegraID = req("I")
T = req("T")
PessoaID = req("PessoaID")

if RegraID="N" then
	db_execute("insert into regraspermissoes (regra, Permissoes) values ('"&ref("Regra")&"', '"&ref("Permissoes")&"')")
	set veseha = db.execute("select * from RegrasPermissoes order by id desc limit 1")
	RegraID = veseha("id")
else
	db_execute("update regraspermissoes set Regra='"&ref("Regra")&"', Permissoes='"&ref("Permissoes")&"' where id="&RegraID)
end if
db_execute("update sys_users set Permissoes='"&ref("Permissoes")&" ["&RegraID&"]' where Permissoes like '%["&RegraID&"]%'")
%>
ajxContent('Permissoes&T=<%=T%>', <%=PessoaID%>, 1, 'divPermissoes');
$("#modal-table").modal("hide");

new PNotify({
    title: 'Sucesso!',
    text: 'Regra alterada.',
    type: 'success',
    delay: 1500
});
