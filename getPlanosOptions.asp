<!--#include file="connect.asp"-->
<%
ConvenioID = req("ConvenioID")
PlanoID = req("PlanoID")
response.write(getPlanosOptions(ConvenioID, PlanoID))
%>