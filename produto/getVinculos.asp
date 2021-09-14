<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    sql = "select * from produtos_vindulados where sysActive = 1 AND produtoPrincipalID = "&req("id")
    response.write(recordToJSON(db.execute(sql)))
%>