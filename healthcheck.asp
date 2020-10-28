<!--#include file="Classes/Connection.asp"-->
<%
    set db = newConnection(session("Banco"), "")

    sql = "select count(1) as count"
    set retorno = db.execute(sql)

    if not isNull(retorno) then
        response.write("Health")
    else
        response.write("Error")
    end if
%>