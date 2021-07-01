<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<!--#include file="geraPacientesProtocolosCiclos.asp"-->
<% 
    response.Charset="utf-8" 

    paciente = ref("paciente")
    id = ref("id")
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

    sqlPacienteProtocolo = "SELECT PacienteProtocoloID FROM pacientesprotocolosmedicamentos WHERE id = " & ppm
    set rsPacienteProtocolo = db.execute(sqlPacienteProtocolo)

    if CInt(existe("existe")) = 0 or rsPacienteProtocolo.eof  then
        response.write(false)
        response.end
    end if

    pacienteProtocoloId = rsPacienteProtocolo("PacienteProtocoloID")

    if aprovacao = "1" then
        status = 1
    else
        status = 2
    end if

    sqlPMA = "UPDATE paciente_medicamentos_aprovacao SET ObsAuditor='"&obsA&"', AuditorID="&session("User")&", statusId="&status&" WHERE id="&id
    db.execute(sqlPMA)

    if aprovacao = "1" then
        if tipo = "R" then
            sqlPPM = "UPDATE pacientesprotocolosmedicamentos SET sysActive= -1 WHERE id="&ppm
            call updatePacientesProtocolosCiclosStatus(pacienteProtocoloId, 7, "Aprovado o pedido de remoção de protocolo")
        else
            sqlPPM = "UPDATE pacientesprotocolosmedicamentos SET DoseMedicamento="&treatValZero(existe("DoseMedicamento"))&", Obs='"&existe("obs")&"' WHERE id="&ppm
            call updatePacientesProtocolosCiclosStatus(pacienteProtocoloId, 6, "Aprovado o pedido de alteração de protocolo")
        end if
        db.execute(sqlPPM)
    else
        'foi verificado com o Everton que em caso de reprovação da notificação, colocar o status de não autorizado
        call updatePacientesProtocolosCiclosStatus(pacienteProtocoloId, 5, "Reprovado o pedido de alteração de protocolo")
    end if


    slqAuditor = "SELECT su.id FROM profissionais p LEFT JOIN sys_users su ON su.idInTable = p.id AND (su.table='profissionais' or su.table='Profissionais') where p.auditor = 'S' and p.sysActive = 1"
    set auditores = db.execute(slqAuditor)
    while not auditores.eof

        sqlUpdate = "UPDATE notificacoes SET StatusID = 3 WHERE TipoNotificacaoID = 13 and UsuarioID = "&auditores("id")&" and NotificacaoIDRelativo = "&id

        db.execute(sqlUpdate)

        auditores.movenext
    wend

    response.write(true)

%>