<!--#include file="connect.asp"-->
<%
    sql = "select count(1)"
    set retorno = db.execute(sql)

    dd(retorno)
    if retorno.eof then
        response.write("Health")
    else
        response.write("Error")
    end if
%>