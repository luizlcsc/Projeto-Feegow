<%
captchaSecret = "6LcYU94cAAAAADu_68RE-InoTkQOArqIX8RJFvGC"

function validateCaptcha(token, ip)
    Dim data, httpRequest, postResponse

    data = "secret="&captchaSecret
    data = data & "&response="&token
    data = data & "&remoteip="&ip

    Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
    httpRequest.Open "POST", "https://www.google.com/recaptcha/api/siteverify", False
    httpRequest.SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"
    httpRequest.Send data

    postResponse = httpRequest.ResponseText

    if instr(postResponse, """success"": true") > 0 then
        validateCaptcha="VALID"
    else
        validateCaptcha="INVALID"
    end if
end function
%>