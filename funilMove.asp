<!--#include file="connect.asp"-->
<%
Origem = replace(ref("Origem"), "f", "")
Destino = replace(ref("Destino"), "f", "")
Elemento = ref("Elemento")

if session("Banco")="clinic5594" then 'consultare
    tabela = "profissionalexterno"
else
    tabela = "pacientes"
end if

db_execute("update "& tabela &" set ConstatusID="& Destino &" where id="& Elemento)
db_execute("insert into pacientesstalog (PacienteID, sysUser, StaID) values ("& Elemento &", "& session("User") &", "& Destino &")")
%>
new PNotify({
    type:'success',
    title:'Movido com sucesso...',
    delay:1000
});