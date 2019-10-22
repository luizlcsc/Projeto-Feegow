<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
FuncionarioID = req("FuncionarioID")
Profissionais = ref("Profissionais")
if PacienteID<>"" then
    db.execute("update pacientes set Profissionais='"& Profissionais &"' where id="& PacienteID)
    db.execute("insert into pacientesdelegacao (sysUser, Profissionais) values ("& session("User") &", '"& Profissionais &"')")
end if
if FuncionarioID<>"" then
    db.execute("update funcionarios set Profissionais='"& Profissionais &"' where id="& FuncionarioID)
end if
%>
new PNotify({
    title: 'Dados gravados com sucesso.',
    text: '',
    type: 'success',
    delay:500
});
