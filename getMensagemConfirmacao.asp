<!--#include file="connect.asp"-->
<!--#include file="Classes/WhatsApp.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->
<%

sql = "select se.TextoSMS from configeventos ce "&_
    " left join sys_smsemail se on se.id = ce.ModeloMsgWhatsapp "&_
    " where ce.id = 1 "
set reqConfigEventoSQL = db_execute(sql)

MensagemPadraoWhatsApp=""

if not reqConfigEventoSQL.eof then
    TextoSMS = reqConfigEventoSQL("TextoSMS")
    if not isnull(TextoSMS) then
        MensagemPadraoWhatsApp=TextoSMS
    end if
end if

function centralWhatsApp(AgendamentoID, MensagemPadrao,PacienteID,ProfissionalID,localID,ProcedimentoID)

        if MensagemPadrao="" then
            Mensagem = MensagemPadraoWhatsApp
        else
            Mensagem = MensagemPadrao
        end if


        if Mensagem&"" ="" then
            Mensagem = "Olá, [Paciente.Nome] !%0a%0aPosso confirmar [Procedimento.Nome] com [Profissional.Nome] às [Agendamento.Hora]?"
        end if
        
        UnidadeID = session("UnidadeId")
        if UnidadeID = "0" then
            sqlunidade = "select u.id from locais l left join sys_financialcompanyunits u on u.id=l.UnidadeID where l.id like '"&localID&"'"
            set pUnidade = db_execute(sqlunidade)
            if not pUnidade.eof then
                if not isnull(pUnidade("id")) then
                    UnidadeID = pUnidade("id")
                end if
            end if
        end if
        
        Mensagem = tagsConverte(Mensagem,"PacienteID_"&PacienteID&"|ProcedimentoID_"&ProcedimentoID&"|AgendamentoID_"&AgendamentoID&"|UnidadeID_"&UnidadeID&"|ProfissionalID_"&ProfissionalID,"")

        centralWhatsApp = Mensagem
end function


response.write(centralWhatsApp(req("AgendamentoID"), "",req("PacienteID"),req("ProfissionalID"),req("LocalID"),req("ProcedimentoID")))

%>
