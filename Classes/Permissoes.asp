<!--#include file="../connect.asp"-->
<%

function validatePrivatePage(onlyAdmin, permissionRequired, messageEnd)

    if messageEnd="" then
        messageEnd = "Entre em contato com o administrador de sua licença."
    end if

    if onlyAdmin=1 and session("admin")=0 then
        response.write("<div class='mt15 alert alert-warning'>Página não autorizada! "&messageEnd&"</div>")
        Response.End
    end if


    if permissionRequired<>"" and aut(permissionRequired)=0 then
        response.write("<div class='mt15 alert alert-warning'>Página não autorizada! "&messageEnd&"</div>")
        Response.End
    end if

end function

%>