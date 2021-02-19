<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 

    sql =   " INSERT INTO protocolos_documentos                          "&chr(13)&_
            " (protocoloID, tipoDocumentoID, sysActive, sysUser, sysDate)"&chr(13)&_
            " VALUES("&req("protocolo")&", "&req("tipo")&", 1, "&session("User")&", CURRENT_TIMESTAMP);                     "        

    db.execute(sql)
    response.write(true)
%>