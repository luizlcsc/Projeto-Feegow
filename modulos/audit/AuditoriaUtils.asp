<!--#include file="./../../connect.asp"-->
<%

function registraEventoAuditoria(event_slug, id_audit, details)
    set AuditoriaEventoSQL = db_execute("select id, NivelID from cliniccentral.auditoria_eventos WHERE Slug='"&event_slug&"'")

    if not AuditoriaEventoSQL.eof then
        AuditoriaEventoID = AuditoriaEventoSQL("id")

        sql = "INSERT INTO auditoria_itens (AuditoriaEventoID, RegistroID, Data, Hora, sysUser, UnidadeID, Detalhes) VALUES "&_
                       "("&treatvalzero(AuditoriaEventoID)&", "&treatvalzero(id_audit)&", curdate(), now(), "&session("User")&", "&session("UnidadeID")&", '"&details&"')"

        db_execute(sql)

    end if
end function


function badgeStatusAuditado(statusAuditado)
    if statusAuditado=1 then
        classCor = "warning"
        classIcon = "fa-exclamation-circle"
        Texto = "Não auditado"
    end if
    if statusAuditado=2 then
        classCor = "success"
        classIcon = "fa-check-circle"
        Texto = "Auditado"
    end if
    if statusAuditado=3 then
        classCor = "default"
        classIcon = "fa-question-circle"
        Texto = "Ignorado"
    end if
    if statusAuditado=4 then
        classCor = "danger"
        classIcon = "fa-exclamation-circle"
        Texto = "Suspeito"
    end if

    badgeStatusAuditado = "<span class='label label-"&classCor&"'><i class='far "&classIcon&"'></i> "&Texto&"</span>"
end function
%>