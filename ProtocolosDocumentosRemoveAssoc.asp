<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 

    sql =   " UPDATE protocolos_documentos              "&chr(13)&_
            " SET sysActive=0, sysDate=CURRENT_TIMESTAMP"&chr(13)&_
            " WHERE protocoloID = "&req("protocolo")&";"            

    db.execute(sql)
    response.write(true)
%>