<!--#include file="connect.asp"-->
<%
tab = "historic_11_12"

set dist = db.execute("select distinct CodPaciente, DataConsulta, CodMedico from pesada."&tab&" where Importado=0 limit 1")
if not dist.eof then
    set reg = db.execute("select * from pesada."&tab&" where CodPaciente="&dist("CodPaciente")&" and DataConsulta='"&dist("DataConsulta")&"' and CodMedico="&dist("CodMedico")&" limit 20")
    while not reg.eof
        Texto = Texto & reg("Atributo") & " " & reg("Historico") &"<br>"
    reg.movenext
    wend
    reg.close
    set reg=nothing
    db_execute("insert into clinic2000._2 (Data, PacienteID, sysUser, Texto) values ('"&dist("DataConsulta")&"', "&dist("CodPaciente")&", "&dist("CodMedico")&", '"&rep(Texto)&"')")
'    db_execute("update pesada.historic set Importado=1 where CodPaciente="&dist("CodPaciente")&" and DataConsulta='"&dist("DataConsulta")&"' and CodMedico="&dist("CodMedico")&"")
    db_execute("delete from pesada."&tab&" where CodPaciente="&dist("CodPaciente")&" and DataConsulta='"&dist("DataConsulta")&"' and CodMedico="&dist("CodMedico")&"")
    response.Write(time())
    %>
    <script>
         location.reload(); 
    </script>
    <%
end if

%>