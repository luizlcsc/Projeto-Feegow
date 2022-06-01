<!--#include file="./../../Classes/Connection.asp"-->
<!--#include file="./../../functions.asp"-->
<!--#include file="./../../connectCentral.asp"-->
<!--#include file="./../../Classes/Json.asp"-->
<%
Codigo = req("codigo")
HashVerificacao = req("EV")

set CodigoSQL = dbc.execute("SELECT * FROM cliniccentral.licencasusuariosalterarsenhas WHERE hashcod='"& HashVerificacao &"' ORDER BY id DESC LIMIT 1")

if not CodigoSQL.eof then
    IF CodigoSQL("AuthCode")&""=Codigo&"" THEN
        DataExpiracao = CodigoSQL("DataExpirar")

        if DataExpiracao&""<>"" then
            if now()>cdate(DataExpiracao) then
                responseJson("{""success"": false,message:""Código expirado.""}")
            end if
        end if

        responseJson("{""success"": true,""message"":""Código validado com sucesso.""}")
    END IF
else
    responseJson("{""success"": false,""message"":""Operação inválida.""}")
end if
%>