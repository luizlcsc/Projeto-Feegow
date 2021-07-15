<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<!--#include file="../Classes/StringFormat.asp"-->
<% 
    response.Charset="utf-8" 

    sql =   " DELETE FROM medicamentos_convenio"&chr(13)&_
            " WHERE id in ("&req("ids")&");               "

    ' response.write(sql)
    db.execute(sql)

    response.write(true)

%>