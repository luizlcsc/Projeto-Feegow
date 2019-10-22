<%
'on error resume next
function SendMailOLDFuncionando(Para, Titulo, Mensagem)

	Set objCDOSYSMail = Server.CreateObject("CDO.Message") 
	Set objCDOSYSCon = Server.CreateObject ("CDO.Configuration") 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.feegow.com.br" 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusername") = "naoresponda@feegow.com.br" 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "viaparque13" 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 587
	'objCDOSYSCon.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1 
	objCDOSYSCon.Fields.update 
	Set objCDOSYSMail.Configuration = objCDOSYSCon 
	objCDOSYSMail.From = "Agendamento <naoresponda@feegow.com.br>" 
'	objCDOSYSMail.ReplyTo = De
	objCDOSYSMail.To = Para
	'objCDOSYSMail.ReplyTo = "email@clinica.com"
	'objCDOSYSMail.cc = lcase(pPai("Email2"))
	objCDOSYSMail.Subject = Titulo
	objCDOSYSMail.HtmlBody = "<html> <head><meta http-equiv=""Content-Type"" content=""text/html;charset=utf-8""></head><body>"&Mensagem&"</body></html>"
	objCDOSYSMail.Send
	
	Set objCDOSYSMail = Nothing 
	Set objCDOSYSCon = Nothing 

end function

function SendMail(Para, Titulo, Mensagem)

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
	objCDOSYSMail.From = "nao-responda@feegowclinic.com.br>" 
'	objCDOSYSMail.ReplyTo = De
	objCDOSYSMail.To = Para
	'objCDOSYSMail.ReplyTo = "email@clinica.com"
	'objCDOSYSMail.cc = lcase(pPai("Email2"))
	objCDOSYSMail.Subject = Titulo
	objCDOSYSMail.HtmlBody = "<html> <head><meta http-equiv=""Content-Type"" content=""text/html;charset=utf-8""></head><body>"&Mensagem&"</body></html>"
	objCDOSYSMail.Send
	
	Set objCDOSYSMail = Nothing 
	Set objCDOSYSCon = Nothing 

end function

function SendMailBOM(Para, Titulo, Mensagem)
			''response.Write(strHTML)
			'AQUI FAZ O DISPARO
			Set objCDOSYSMail = Server.CreateObject("CDO.Message") 
			Set objCDOSYSCon = Server.CreateObject ("CDO.Configuration") 
			objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.feegow.com.br"
			objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusername") ="financeiro@feegow.com.br"
			objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "viaparque13"
			objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 587
			objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
			objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
			'objCDOSYSCon.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = 1
			objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
			objCDOSYSCon.Fields.update
			Set objCDOSYSMail.Configuration = objCDOSYSCon 
			objCDOSYSMail.From = "financeiro@feegow.com.br"' <Feegow - Financeiro>
			objCDOSYSMail.To = Para
			objCDOSYSMail.Subject = "Boleto Mensal Feegow Clinic"
			objCDOSYSMail.HtmlBody = "Prezado cliente, <br><br>Segue boleto para pagamento de sua fatura mensal Feegow Clinic.<br><br>Para quaisquer d&uacute;vidas, estamos &agrave; disposi&ccedil;&atilde;o.<br><br>Equipe Feegow Clinic"'"<html> <head><meta http-equiv=""Content-Type"" content=""text/html;charset=utf-8""></head><body>Teste de envio de email.</body></html>"
			


			objCDOSYSMail.Send
			response.Write("{"&return&"}")


			Set objCDOSYSMail = Nothing 
			Set objCDOSYSCon = Nothing
end function

'call sendmail("maia_silvio@hotmail.com", "Testando envio", "Esta é a mensagem de agendamento online")
'call sendmail("maia.silvio.rj@gmail.com", "Testando envio", "Esta é a mensagem de agendamento online")
'call sendmail("silvio@feegow.com.br", "Testando envio", "Esta é a mensagem de agendamento online")
%>