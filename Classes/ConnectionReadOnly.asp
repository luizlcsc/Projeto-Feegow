<!--#include file="Connection.asp"-->
<%

function newReadOnlyConnection()
    ServidorReadOnly = session("ServidorReadOnly")

    if ServidorReadOnly="" then
        ServidorReadOnly=session("Servidor")
    end if

    set newReadOnlyConnection = newConnection(session("Banco"), ServidorReadOnly)
end function

%>