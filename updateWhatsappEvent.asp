<!--#include file="connect.asp"-->
<%
wppID          = ref("wppID")
statusAgenda   = ref("statusAgenda")
intervalo      = ref("intervalo")
antesDepois    = ref("antesDepois")
paraApenas     = ref("paraApenas")
ativoCheckbox  = ref("ativoCheckbox")
profissionais  = ref("profissionais")
unidades       = ref("unidades")
especialidades = ref("especialidades")
procedimentos  = ref("procedimentos")
enviarPara     = ref("enviarPara")

updateWhatsappSQL = "UPDATE eventos_emailsms eve SET eve.`Status` = '"+statusAgenda+"', eve.IntervaloHoras = '"+intervalo+"', eve.AntesDepois = '"+antesDepois+"', eve.ApenasAgendamentoOnline = '"+paraApenas+"', eve.Ativo = '"+ativoCheckbox+"', eve.Profissionais = '"+profissionais+"', eve.Unidades = '"+unidades+"', eve.Especialidades = '"+especialidades+"', eve.Procedimentos = '"+procedimentos+"', eve.EnviarPara = '"+enviarPara+"' WHERE eve.id = "+wppID
db.execute(updateWhatsappSQL)
%>