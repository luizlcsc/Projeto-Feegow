<!--#include file="connect.asp"-->
<%
wppActive = ref("wppActive")
wppID = ref("wppID")

updateWhatsappActiveSQL = "UPDATE eventos_emailsms SET Ativo = '"+wppActive+"' WHERE id = "+wppID
db.execute(updateWhatsappActiveSQL)
%>