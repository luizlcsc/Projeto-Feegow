<%
action=req("action")


Select Case action
  Case "Finaliza"
    'session("AtendimentoTelemedicina")=""
End Select

response.write("{success: true}")
%>