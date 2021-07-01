<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 
    Existe = req("Existe")
    if Existe=0 then
        sql =   " insert into tipos_de_arquivos(NomeArquivo, Obrigatorio, sysActive, sysUser)   "&chr(13)&_
            " values(                                                                       "&chr(13)&_
            " '"&req("NomeArquivo")&"',                                                     "&chr(13)&_
            " "&req("Obrigatorio")&",                                                       "&chr(13)&_
            " 1,                                                                            "&chr(13)&_
            " "&session("User")&"                                                           "&chr(13)&_
            " )                                                                               "
    elseif Existe=1 then 
        sql = "UPDATE tipos_de_arquivos SET NomeArquivo = '"&req("NomeArquivo")&"', Obrigatorio = "&req("Obrigatorio")&" WHERE id = "&treatvalzero(req("id"))
    end if
    db.execute(sql)

    response.write(true)

%>