<!--#include file="Classes/Connection.asp"-->
<!--#include file="connect.asp"-->
<%
    set db = newConnection("", "")

    if isNull(db) then
        response.write("Error")
        response.end

    end if

    sql = "select count(1) as count"
    set retorno = db.execute(sql)

    if not isNull(retorno) then
        response.write("OK")
    else
        call Err.Raise(500, "unhealthy", "Internal server error.")
    end if
%>