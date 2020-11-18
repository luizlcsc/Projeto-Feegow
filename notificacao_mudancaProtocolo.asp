<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 

    'id = ref("id")
    paciente = ref("paciente")
    dose = ref("dose")
    obs = ref("obs")
    medicamentoId = ref("medicamentoId")
    medicamentoNome = ref("medicamentoNome")
    tipo = ref("tipo")
    toUpdate = ""
    criar = false
    count = 0

    '  pegar os medicos auditores
    slqAuditor = "SELECT id FROM profissionais where auditor = 'S' and sysActive= 1"
    set auditores = db.execute(slqAuditor)
    while not auditores.eof

        sqlSelectNotificacao = "select count(id) as qtd from notificacoes n where TipoNotificacaoID  = 13 and UsuarioID = "&auditores("id")&" and NotificacaoIDRelativo = "&paciente&" and StatusID = 1"

        set existeNotificacao = db.execute(sqlSelectNotificacao)

        if CInt(existeNotificacao("qtd")) = 0 then

            ' gerar notificação para os medicos auditores
            sqlCriarNotificacao = "INSERT INTO notificacoes (TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, CriadoPorID, Prioridade, StatusID, metadata) VALUES(13, "&session("User")&", "&paciente&", 1, 1, 1,'');"

            db.execute(sqlCriarNotificacao)
            ' dar update na query  UPDATE sys_users SET TemNotificacao=1 WHERE id=1 para os medicos auditores

            sqlSelectToUpdate = "select id from notificacoes where TipoNotificacaoID =13 and UsuarioID = "&session("User")&" and NotificacaoIDRelativo="&paciente
            selecao1 = db.execute(sqlSelectToUpdate)

            if count > 0 then
                toUpdate = toUpdate & ", "
            end if
            toUpdate = toUpdate & selecao1("id")
            selecao1 = ""
            criar = true



            flagNotificacao = "UPDATE sys_users SET TemNotificacao=1 WHERE id="&auditores("id")
            db.execute(flagNotificacao)

        end if
        count = count +1
        auditores.movenext
    wend

    if criar then
        ' preencher tabela auxiliar

        sqlAutorizar = "INSERT INTO paciente_medicamentos_aprovacao (pacientesProtocolosMedicamentosID, MedicamentoPrescritoID, ProfissionalID, tipo, DoseMedicamento, Obs, statusId) VALUES("&paciente&", "&medicamentoId&", "&session("User")&", '"&tipo&"', "&dose&", '"&obs&"', 0);" 

        db.execute(sqlAutorizar)
        
        selecaoSql = "SELECT id from paciente_medicamentos_aprovacao where pacientesProtocolosMedicamentosID="&paciente&" and MedicamentoPrescritoID="&medicamentoId&" and ProfissionalID = "&session("User")&" and tipo = '"&tipo&"' and Obs = '"&obs&"' and statusId = 0"
        selecao2 = db.execute(selecaoSql)

        updateNotificacao = "UPDATE notificacoes set NotificacaoIDRelativo="&selecao2("id")&" where id in ("&toUpdate&")"

        db.execute(updateNotificacao)

        criar = false
    end if

%>

