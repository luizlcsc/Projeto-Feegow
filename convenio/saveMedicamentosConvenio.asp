<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<!--#include file="../Classes/StringFormat.asp"-->
<% 
    response.Charset="utf-8" 

    sql =   " INSERT INTO medicamentos_convenio"&chr(13)&_
            " (                                "&chr(13)&_
            " produtoPrescrito,                "&chr(13)&_
            " produtoReferencia,               "&chr(13)&_
            " convenioID,                      "&chr(13)&_
            " planoID,                         "&chr(13)&_
            " sysUser,                         "&chr(13)&_
            " sysActive                        "&chr(13)&_
            " )                                "&chr(13)&_
            " VALUES("&req("prescrito")&", "&req("referencia")&","&req("convenio")&", nullif('"&req("plano")&"',''), "&session("User")&", 1)"


    db.execute(sql)

    response.write(true)

%>