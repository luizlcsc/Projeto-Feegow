<!--#include file="connect.asp"-->
<input type="hidden" id="updateActive" name="updateActive" value="">
<%
wppActive = ref("wppActive")
wppID = ref("wppID")

updateWhatsappActiveSQL = "UPDATE sys_smsemail SET AtivoWhatsApp = '"+wppActive+"' WHERE id = "+wppID
db.execute(updateWhatsappActiveSQL)
%>