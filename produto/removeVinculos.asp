<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    sql =   " UPDATE produtos_vindulados   "&chr(13)&_
            " SET sysActive = -1            "&chr(13)&_
            " WHERE produtoPrincipalID = "&req("produto")


    ' response.write(sql)
    db.execute(sql)
    response.write(true)

%> 
