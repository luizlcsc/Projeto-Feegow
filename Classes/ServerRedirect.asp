<%
'::: NO INÍCIO DO ARQUIVO INDEX.ASP :::
Dim variavel
Dim i
Dia = weekday(date())
URLAtual = request.servervariables("SERVER_NAME")
PaginaAtual = request.QueryString()
ForceServerRedir = request.QueryString("FORCE_SERVER_REDIR")="1"
URLServerNormal = "app.feegow.com"
URLServerReduzido = "app2.feegow.com"

URLReduzidoRedirect= "https://"& URLServerReduzido &"/main"
HoraNormalSemana = 18
HoraNormalSabado = 13
sysUser = session("User")

'Está na hora de trocar de servidor

if AppEnv = "production" and ((Dia>=2 and Dia<=6 and hour(time())>=HoraNormalSemana) or (Dia=7 and hour(time())>=HoraNormalSabado) or (Dia=1) or ForceServerRedir) then

    'Se está no server errado
    if URLAtual=URLServerNormal and req("RFSS")="" and LicenseID&""="105" then
        %><!--#include file="./../connectCentral.asp"--><%
        'Apaga lixos anteriores
        dbc.execute("DELETE FROM cliniccentral.temp_sessions WHERE sysUser="& sysUser)
        For Each variavel in Session.Contents
            If IsArray(Session(variavel)) then
                For i = LBound(Session(variavel)) to UBound(Session(variavel))
                    Response.Write variavel & "(" & i & ") – " & _
                    Session(variavel)(i) & "<BR>"
                Next
            Else
                'Response.Write variavel & " :: " & Session.Contents(variavel) & "<BR>"
                NomeSessao = variavel
                ValorSessao = Session.Contents(variavel)
                dbc.execute("INSERT INTO cliniccentral.temp_sessions SET sysUser="& sysUser &", NomeSessao='"& NomeSessao &"', ValorSessao='"& ValorSessao &"'")
            End If
        Next
        'Grava a página atual
        dbc.execute("INSERT INTO cliniccentral.temp_sessions SET sysUser="& sysUser &", NomeSessao='RFSS', ValorSessao='"& PaginaAtual &"'")
        'Redireciona pro server correto
        response.redirect(URLReduzidoRedirect &"?RFSS="& sysUser)
        %><!--#include file="./../disconnect.asp"--><%
    'Se está no server correto
    else
        if req("RFSS")<>"" then
            %><!--#include file="./../connectCentral.asp"--><%

            'Adquire as sessoes no novo servidor
            set ses = dbc.execute("SELECT * FROM cliniccentral.temp_sessions WHERE sysUser="& req("RFSS"))
            while not ses.eof
                if ses("NomeSessao")<>"RFSS" then
                    session(ses("NomeSessao")) = ses("ValorSessao")
                else
                    RedirecionarPara = ses("ValorSessao")
                end if
            ses.movenext
            wend
            ses.close
            set ses = nothing
            'Envia pra página correta
            dbc.execute("DELETE FROM cliniccentral.temp_sessions WHERE sysUser="& sysUser)

            if RedirecionarPara<>"" then
                response.redirect("./?"& RedirecionarPara)
            end if
            %><!--#include file="./../disconnect.asp"--><%
        end if
    end if

end if
%>
