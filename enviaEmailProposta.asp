<!--#include file="connect.asp"-->

<%
if ref("Para")<>"" then
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
	objCDOSYSMail.From = "nao-responda@feegowclinic.com.br" '<"&ref("EmailProp")&">" 
'	objCDOSYSMail.ReplyTo = De
	objCDOSYSMail.To = ref("Para")
	'objCDOSYSMail.ReplyTo = ref("EmailProp")
	'objCDOSYSMail.cc = lcase(pPai("Email2"))
	objCDOSYSMail.Subject = ref("Assunto")
	objCDOSYSMail.HtmlBody = "<html> <head><meta http-equiv=""Content-Type"" content=""text/html;charset=utf-8""></head><body>"&ref("Mensagem")&"</body></html>"
    objCDOSYSMail.AddAttachment "C:\inetpub\weegow\beta\pdf\"&ref("F")&".pdf"
	'objCDOSYSMail.Send!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	Set objCDOSYSMail = Nothing 
	Set objCDOSYSCon = Nothing

    PacienteID = "3_"& ref("PacienteID")
    
    sql = "insert into "&ref("B")&".chamadas (StaID, sysUserAtend, DataHoraAtend, RE, Telefone, Contato, Assunto, Notas) values (2, "&ref("User")&", NOW(), '7', '"&ref("Para")&"', '"&PacienteID&"', '"&ref("Assunto")&"', '"&ref("Mensagem")&"')"
    
    db_execute(sql)
    
    db_execute("insert into "&ref("B")&".propostasanexas (EmailID, Arquivo) values ((select id from "&ref("B")&".chamadas where sysUserAtend="&ref("User")&" order by id desc limit 1), '"&ref("F")&".pdf')")
    %>
        $.gritter.add({
            title: '<i class="far fa-envelope"></i> E-mail enviado...',
            text: "<%'=sql %>",
            class_name: 'gritter-success gritter-light'
        });
    <%
end if
%>
