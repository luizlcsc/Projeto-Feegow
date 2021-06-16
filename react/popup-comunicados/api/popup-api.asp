<!--#include file="../../../connect.asp"-->
<!--#include file="../../../connectCentral.asp"-->
<!--#include file="../../../Classes/Json.asp"-->

<%
action=req("action")
UserID= session("User")
LicencaID= replace(session("Banco"),"clinic","")
ComunicadoID= req("ComunicadoID")
Interesse= req("Interesse")

Select Case action
  Case "VerificaPopupsPendentes"
    'retornar um json
    ' cria a tabela de cliniccentral.comunicados

  Case "PopupVisualizado"
    'retornar um json
    ' cria a tabela de cliniccentral.comunicados
    sql = "insert into cliniccentral.comunicados ( UserID, ComunicadoID, Interesse) values ("& UserID &", "& ComunicadoID &", "& Interesse &")"
    dbc.execute( sql )

  Case "GetComunicadoById"

    sql = "SELECT pop.* FROM cliniccentral.popup_comunicados pop INNER JOIN cliniccentral.comunicados com ON com.ComunicadoID=pop.id WHERE com.UserID="&UserID&" AND pop.id="&Request.QueryString("ComunicadoID")
    set ComunicadoSQL = dbc.execute( sql )

    responseJson(recordToJSON(ComunicadoSQL))

  Case "GetComunicadoNaoVisualizado"

    sql = "SELECT pop.*, "&_
          "(SELECT com.Interesse FROM cliniccentral.comunicados com WHERE com.ComunicadoID=pop.id AND com.UserID="&session("User")&" ORDER BY id DESC LIMIT 1) feedback_comunicado "&_
          "FROM cliniccentral.popup_comunicados pop "&_
          "LEFT JOIN cliniccentral.clientes_servicosadicionais cs ON cs.LicencaID="&LicencaID&" AND cs.ServicoID=pop.RecursoAdicionalID "&_
          " "&_
          "WHERE (ExibirApenas IS NULL OR ExibirApenas LIKE '%|"&LicencaID&"|%') AND sysActive=1 "&_
          " "&_
          "AND ((cs.`Status` = pop.RecursoAdicionalStatus AND cs.id IS NOT null) OR (cs.id IS NULL AND pop.RecursoAdicionalStatus IS NULL)) "&_
          "AND pop.sysActive = 1 "&_
          "GROUP BY pop.id "&_
          "HAVING feedback_comunicado is NULL "

    set ComunicadoSQL = dbc.execute( sql )
    Content = recordToJSON(ComunicadoSQL)

    responseJson(Content)



End Select

responseJson("{success: true}")
%>