<!--#include file="connect.asp"-->

<input type="hidden" id="updateActive" name="updateActive" value="">

<%

wppActive = ref("wppActive")
wppID = ref("wppID")

'dd(wppID)

updateWhatsappActiveSQL = "UPDATE sys_smsemail SET AtivoWhatsApp = '"+wppActive+"' WHERE id = "+wppID
'dd(updateWhatsappActiveSQL)
db.execute(updateWhatsappActiveSQL)

%>