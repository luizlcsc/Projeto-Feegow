<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    sqlInsert =     " INSERT INTO produtos_vindulados ("&chr(13)&_
                    " produtoPrincipalID,              "&chr(13)&_
                    " produtoSubistitutoID,            "&chr(13)&_
                    " ordem,                           "&chr(13)&_
                    " sysUser,                         "&chr(13)&_
                    " sysActive                        "&chr(13)&_
                    " )                                "&chr(13)&_
                    " VALUES (" &req("produtoID")&", "&req("subistitutoID")&", "&req("ordem")&", "&session("User")&", "&chr(13)&_
                    " 1                                "&chr(13)&_
                    " );                               "
    
    db.execute(sqlInsert)
    response.write(true)

%>