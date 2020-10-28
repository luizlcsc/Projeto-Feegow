<!--#include file="Classes/Connection.asp"-->
<%
    set db = newConnection(session("Banco"), "")

    if isNull(db) then
        response.write("Error")
        response.end

    end if

    sql = "select count(1) as count"
    set retorno = db.execute(sql)

    if not isNull(retorno) then
        response.write("Health")
    else
        response.write("Error")
    end if
%>