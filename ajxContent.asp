<%
'O QUE IDENTIFICA QUE O FORM TA SENDO CHAMADO POR AJAX É O REQUEST(Div)<>""
if request.QueryString("Pers")="1" then
  FileName = request.QueryString("P")&".asp"
else
  FileName = "DefaultContent.asp"
end if
server.Execute(FileName)
%>