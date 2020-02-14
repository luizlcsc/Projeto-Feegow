<!--#include file="connect.asp"-->
<!--#include file="Classes/Connection.asp"-->
<%
set dblicense = newConnection("clinic5459", "dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com")

RelativoID=ref("RelativoID")
TipoID=ref("TipoID")
Nota=ref("Nota")
Obs=ref("Obs")

sqlI="INSERT INTO avaliacoes (RelativoID, TipoID, Nota, Comentario, sysUser) VALUES "&_
   " ("&treatvalnull(RelativoID)&", '"&TipoID&"',"&treatvalnull(Nota)&",'"&Obs&"', "&session("User")&") "
dblicense.execute(sqlI)
%>