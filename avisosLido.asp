<!--#include file="connect.asp"-->
<%

if ref("AvisoID")<>"" then
    db.execute("insert into avisosleitura set AvisoID="& ref("AvisoID") &", sysUser="& session("User") &", UnidadeID="& session("UnidadeID"))
end if
%>