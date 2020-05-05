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
    db.exe2cute( sql )

  Case "GetComunicadoById"

    sql = "SELECT pop.* FROM cliniccentral.popup_comunicados pop INNER JOIN cliniccentral.comunicados com ON com.ComunicadoID=pop.id WHERE com.UserID="&UserID&" AND pop.id="&Request.QueryString("ComunicadoID")
    set ComunicadoSQL = db.execute( sql )

    responseJson(recordToJSON(ComunicadoSQL))

  Case "GetComunicadoNaoVisualizado"

    sql = "SELECT pop.* FROM cliniccentral.popup_comunicados pop LEFT JOIN cliniccentral.comunicados com ON com.ComunicadoID=pop.id AND com.UserID="&UserID&" WHERE (ExibirApenas is null or ExibirApenas Like '%|"&LicencaID&"|%') AND com.id IS NULL AND (com.Interesse=1 or com.Interesse IS NULL) AND sysActive=1 AND pop.id="&Request.QueryString("ComunicadoID")
    set ComunicadoSQL = db.execute( sql )

    Exibe=True

    if not ComunicadoSQL.eof then
        if not isnull(ComunicadoSQL("RecursoAdicionalID")) then
            if recursoAdicional(ComunicadoSQL("RecursoAdicionalID"))<>0 then
                Exibe=False
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