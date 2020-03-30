<!--#include file="../../../connect.asp"-->
<%
action=Request.QueryString("action")
UserID= session("User")

Select Case action
  Case "VerificaPopupsPendentes"
    'retornar um json
    ' cria a tabela de cliniccentral.comunicados


End Select

response.write("{success: true}")
%>