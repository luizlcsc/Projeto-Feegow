<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 

    paciente = ref("paciente")
    id = ref("id")
    acao = ref("acao")
    tipo = ref("tipo")
    aprovacao = ref("aprovacao")
    ppm = ref("ppm")
    obsA = ref("obsA")

    ' confere se alguem ja interagiu com esse pedido OK
        ' se sim retorna avisando OK
        ' se não 
        ' faz o update na tabela auxiliar 'paciente_medicamentos_aprovacao' com a resolução
        ' se edição
        ' faz o update na tabela 'pacientesprotocolosmedicamentos' caso troca de dose
        ' se exclusão
        ' faz o remove da tabela 'pacientesprotocolosmedicamentos' o medicamento
        ' faz o update na tabela notificacoes de todos os auditores


    '  pegar os medicos auditores

    sqlConfereAcao = "select count(id) as existe, DoseMedicamento, obs from paciente_medicamentos_aprovacao where statusId = 0 and id = "&id

    existe = db.execute(sqlConfereAcao)

    if CInt(existe("existe")) = 0 then
        response.write(false)
        response.end
    end if

    if aprovacao = "true" then
        status = 1
    else
        status = 2
    end if

    sqlPMA = "UPDATE paciente_medicamentos_aprovacao SET ObsAuditor='"&obsA&"', AuditorID="&session("User")&", statusId="&status&" WHERE id="&id
    db.execute(sqlPMA)

    if tipo = "R" then
        sqlPPM = "UPDATE pacientesprotocolosmedicamentos SET sysActive= -1 WHERE id="&ppm
    else
        sqlPPM = "UPDATE pacientesprotocolosmedicamentos SET DoseMedicamento="&existe("DoseMedicamento")&", Obs='"&existe("obs")&"' WHERE id="&ppm
    end if

    db.execute(sqlPPM)

    slqAuditor = "SELECT id FROM profissionais where auditor = 1 and sysActive= 1"
    set auditores = db.execute(slqAuditor)
    while not auditores.eof

        sqlUpdate = "UPDATE notificacoes SET StatusID = 3 WHERE TipoNotificacaoID = 13 and UsuarioID = "&auditores("id")&" and NotificacaoIDRelativo = "&id

        db.execute(sqlUpdate)

        auditores.movenext
    wend

    response.write(true)

%>