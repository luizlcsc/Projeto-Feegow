<%
'O QUE IDENTIFICA QUE O FORM TA SENDO CHAMADO POR AJAX É O REQUEST(Div)<>""
if req("Pers")="1" then
  FileName = req("P")&".asp"
else
  FileName = "DefaultContent.asp"
end if
server.Execute(FileName)
%>