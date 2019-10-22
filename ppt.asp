<%
Dim objPPT
Set objPPT = server.CreateObject("PowerPoint.Application")
objPPT.activate
call objPPT.presentations.Open("http://www.uol.com.br")
objppt.ActivePresentation.saveCopyAs("c:\inetpub\wwwroot\feegowclinic\test.ppt")
objPPT.ActivePresentation.close
objPPT.Quit
Set objPPT = Nothing 
%>