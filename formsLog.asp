<!--#include file="connect.asp"-->
<%
db_execute("insert into cliniccentral.formslog (txt, p, m, i, UserID, LicencaID) values ('"&rep(request.form())&"', "&req("p")&", "&req("m")&", "&treatvalzero(req("i"))&", "&session("User")&", "& replace(session("Banco"), "clinic", "") &")")
%>