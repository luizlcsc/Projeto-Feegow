<!--#include file="../../../connect.asp"-->
<!--#include file="../../../Classes/Json.asp"-->
<%
action=Request.QueryString("action")
UserID= session("User")
LicencaID= replace(session("Banco"),"clinic","")
ComunicadoID= Request.QueryString("ComunicadoID")
Interesse= Request.QueryString("Interesse")

Select Case action
  Case "VerificaPopupsPendentes"
    'retornar um json
    ' cria a tabela de cliniccentral.comunicados

  Case "PopupVisualizado"
    'retornar um json
    ' cria a tabela de cliniccentral.comunicados
    sql = "insert into cliniccentral.comunicados ( UserID, ComunicadoID, Interesse) values ("& UserID &", "& ComunicadoID &", "& Interesse &")"
    db.execute( sql )

  Case "GetComunicadoById"

    sql = "SELECT pop.* FROM cliniccentral.popup_comunicados pop INNER JOIN cliniccentral.comunicados com ON com.ComunicadoID=pop.id WHERE com.UserID="&UserID&" AND pop.id="&Request.QueryString("ComunicadoID")
    set ComunicadoSQL = db.execute( sql )

    responseJson(recordToJSON(ComunicadoSQL))

  Case "GetComunicadoNaoVisualizado"

    sql = "SELECT pop.* FROM cliniccentral.popup_comunicados pop LEFT JOIN cliniccentral.comunicados com ON com.ComunicadoID=pop.id AND com.UserID="&UserID&" WHERE (ExibirApenas is null or ExibirApenas Like '%|"&LicencaID&"|%') AND (com.id IS NULL OR com.Interesse=1) AND (com.Interesse=1 or com.Interesse IS NULL) AND sysActive=1 AND pop.id="&Request.QueryString("ComunicadoID")
    set ComunicadoSQL = db.execute( sql )

    Exibe=True

    if not ComunicadoSQL.eof then
        RecursoAdicionalID=ComunicadoSQL("RecursoAdicionalID")
        RecursoAdicionalStatus=ComunicadoSQL("RecursoAdicionalStatus")

        if not isnull(RecursoAdicionalID) then
            if isnull(RecursoAdicionalStatus) then
                if recursoAdicional(RecursoAdicionalID)<>0 then
                    Exibe=False
                end if
            else
                if recursoAdicional(RecursoAdicionalID)&""<>RecursoAdicionalStatus&"" then
                    Exibe=False
                end if
            end if
        end if
    end if

    if not Exibe then
        Content = "False"
    else
        Content = recordToJSON(ComunicadoSQL)
    end if

    responseJson(Content)



End Select

responseJson("{success: true}")
%>