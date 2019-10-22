<%
function SendMailMarketing(De, DeNome, Para, Titulo, Mensagem)

	Set objCDOSYSMail = Server.CreateObject("CDO.Message") 
	Set objCDOSYSCon = Server.CreateObject ("CDO.Configuration") 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "in-v3.mailjet.com" 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusername") = "c5859ca10e54a8797e246dc4a60769a5" 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "d04f670ed390e83fe31b620e639e8dd3" 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 587
	'objCDOSYSCon.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
	objCDOSYSCon.Fields.update 
	Set objCDOSYSMail.Configuration = objCDOSYSCon 
	objCDOSYSMail.From = DeNome & "<nao-responda@feegowclinic.com.br>"
	objCDOSYSMail.ReplyTo = De
	objCDOSYSMail.To = Para
	'objCDOSYSMail.cc = lcase(pPai("Email2"))
	objCDOSYSMail.Subject = Titulo
	objCDOSYSMail.HtmlBody = "<html> <head><meta http-equiv=""Content-Type"" content=""text/html;charset=utf-8""></head><body>"&Mensagem&"</body></html>"
	objCDOSYSMail.Send
	
	Set objCDOSYSMail = Nothing 
	Set objCDOSYSCon = Nothing 

end function
%>