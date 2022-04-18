<!--#include file="connect.asp"-->
<%
eventoID       = ref("eventoID")&""
linkPers       = ref("linkPers")
sysUser        = ref("sysUser")
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

if instr(profissionais, "|ALL|") > 0 then
    profissionais = "|ALL|"
end if

if instr(unidades, "|ALL|") > 0 then
    unidades = "|ALL|"
end if

if instr(especialidades, "|ALL|") > 0 then
    especialidades = "|ALL|"
end if

if instr(procedimentos, "|ALL|") > 0 then
    procedimentos = "|ALL|"
end if

if eventoID <> "" then 
    if deleteEvento = "1" then
        deletarEventoSQL = "UPDATE eventos_emailsms eve SET eve.sysActive = -1 WHERE eve.id = "+eventoID
        db.execute(deletarEventoSQL)
        tpOperacao = "X"
    else
        updateEventoSQL="   UPDATE eventos_emailsms eve SET eve.Descricao ='"+nomeEvento+"', eve.ModeloID = '"+modeloID+"',     "&chr(13)&_
                        "   eve.`Status` = '"+statusAgenda+"', eve.IntervaloHoras = '"+intervalo+"', eve.AntesDepois =          "&chr(13)&_
                        "   '"+antesDepois+"', eve.ApenasAgendamentoOnline = '"+paraApenas+"', eve.Ativo = '"+ativoCheckbox+"', "&chr(13)&_
                        "   eve.Profissionais ='"+profissionais+"', eve.Unidades = '"+unidades+"', eve.Especialidades =         "&chr(13)&_
                        "   '"+especialidades+"', eve.Procedimentos = '"+procedimentos+"', eve.EnviarPara = '"+enviarPara+"',   "&chr(13)&_
                        "   eve.sysUser = '"+sysUser+"', eve.LinkPersonalizado = '"+linkPers+"' WHERE eve.id = "+eventoID

        db.execute(updateEventoSQL)
        tpOperacao = "E"
    end if
else
    insertEventoSQL="   INSERT INTO eventos_emailsms                                                                                        "&chr(13)&_
                    "   (Descricao, ModeloID, `Status`, IntervaloHoras, AntesDepois, ApenasAgendamentoOnline, Ativo, LinkPersonalizado,     "&chr(13)&_
                    "   `Profissionais`, Unidades, `Especialidades`, `Procedimentos`, EnviarPara, Whatsapp, sysUser, sysActive)             "&chr(13)&_
                    "   VALUES ('"+nomeEvento+"', '"+modeloID+"', '"+statusAgenda+"', '"+intervalo+"', '"+antesDepois+"',                   "&chr(13)&_
                    "   '"+paraApenas+"', '"+ativoCheckbox+"', '"+linkPers+"', '"+profissionais+"', '"+unidades+"', '"+especialidades+"',   "&chr(13)&_
                    "   '"+procedimentos+"', '"+enviarPara+"', 1, '"+sysUser+"', 1)                                                         "

    db.execute(insertEventoSQL)

    sqlUltimoInsert  = "SELECT LAST_INSERT_ID() as eventoID"
    set registro = db.execute(sqlUltimoInsert)
    ultimoEventoID = registro("eventoID")
    eventoID = ultimoEventoID

    tpOperacao = "I"   
    
end if

'****** ADICIONANDO LOG DE OPERAÇÃO *******
db.execute("insert into log (I, Operacao, recurso, colunas, valorAnterior, valorAtual, sysUser) values ("&eventoID&", '"&tpOperacao&"', 'evento_whatsapp', '', '', '', '"&session("User")&"')")

%>