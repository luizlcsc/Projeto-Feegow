<!--#include file="./../../connect.asp"-->
<!--#include file="AuditoriaUtils.asp"-->
<%

StatusID = req("StatusID")
response.write(badgeStatusAuditado(StatusID))
%>