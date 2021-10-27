<!--#include file="connect.asp"-->
<%
eventoID       = ref("eventoID")&""
deleteEvento   = ref("deleteEvento")&""
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
modeloID       = ref("modeloID")
nomeEvento     = ref("nomeEvento")

if eventoID <> "" then 
    updateEventoSQL="   UPDATE eventos_emailsms eve SET eve.Descricao ='"+nomeEvento+"', eve.ModeloID = '"+modeloID+"',     "&chr(13)&_
                    "   eve.`Status` = '"+statusAgenda+"', eve.IntervaloHoras = '"+intervalo+"', eve.AntesDepois =          "&chr(13)&_
                    "   '"+antesDepois+"', eve.ApenasAgendamentoOnline = '"+paraApenas+"', eve.Ativo = '"+ativoCheckbox+"', "&chr(13)&_
                    "   eve.Profissionais ='"+profissionais+"', eve.Unidades = '"+unidades+"', eve.Especialidades =         "&chr(13)&_
                    "   '"+especialidades+"', eve.Procedimentos = '"+procedimentos+"', eve.EnviarPara = '"+enviarPara+"'    "&chr(13)&_
                    "   WHERE eve.id = "+eventoID

    db.execute(updateEventoSQL)
end if

if eventoID = "" then
    insertEventoSQL="   INSERT INTO eventos_emailsms                                                                     "&chr(13)&_
                    "   (Descricao, ModeloID, `Status`, IntervaloHoras, AntesDepois, ApenasAgendamentoOnline,            "&chr(13)&_
                    "   Ativo, `Profissionais`, Unidades, `Especialidades`, `Procedimentos`, EnviarPara, sysActive)      "&chr(13)&_
                    "   VALUES ('"+nomeEvento+"', '"+modeloID+"', '"+statusAgenda+"', '"+intervalo+"', '"+antesDepois+"',"&chr(13)&_
                    "   '"+paraApenas+"', '"+ativoCheckbox+"', '"+profissionais+"', '"+unidades+"', '"+especialidades+"',"&chr(13)&_
                    "   '"+procedimentos+"', '"+enviarPara+"', 0)                                                        "

    db.execute(insertEventoSQL)
    
elseif deleteEvento = 1 then
    deletarEventoSQL = "DELETE FROM `eventos_emailsms` WHERE `id`= "+deleteID
    db.execute(deletarEventoSQL)
end if

%>