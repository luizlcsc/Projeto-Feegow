<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 

    sql =   " UPDATE tipos_de_arquivos                            "&chr(13)&_
            " SET NomeArquivo='"&req("NomeArquivo")&"',           "&chr(13)&_
            " Obrigatorio="&req("Obrigatorio")&"                  "&chr(13)&_
            " WHERE id= "&req("id")&" ;                           "

    db.execute(sql)

    response.write(true)

%>