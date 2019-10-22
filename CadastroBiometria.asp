<!--#include file="connect.asp"-->
<%
if req("I")<>"" then
    'tem q somar licencaid + 10000000000000000000000 + usuarioid
    db_execute("delete from cliniccentral.biometria")
    db_execute("insert into cliniccentral.biometria (UsuarioID) values ("&req("I")&")")
    %>
    Cadastre sua biometria no leitor!
    <br />
    Aguardando leitura...
    <script type="text/javascript">
        alert('Cadastre sua biometria no leitor!');
        location.href = './?P=Login&Log=Off';
    </script>
    <%
end if
%>