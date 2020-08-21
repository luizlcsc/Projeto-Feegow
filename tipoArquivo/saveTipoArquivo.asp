<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 

    sql =   " insert into tipos_de_arquivos(NomeArquivo, Obrigatorio, sysActive, sysUser)   "&chr(13)&_
            " values(                                                                       "&chr(13)&_
            " '"&req("NomeArquivo")&"',                                                     "&chr(13)&_
            " "&req("Obrigatorio")&",                                                       "&chr(13)&_
            " 1,                                                                            "&chr(13)&_
            " "&session("User")&"                                                           "&chr(13)&_
            " )                                                                             "

    db.execute(sql)

    response.write(true)

%>