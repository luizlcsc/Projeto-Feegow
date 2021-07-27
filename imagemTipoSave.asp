<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

    sql =   " UPDATE arquivos                           "&chr(13)&_
            " SET TipoArquivoID = "&req("tipo")&",      "&chr(13)&_
            " validade = '"&req("validade")&"'          "&chr(13)&_
            " WHERE id= "&req("id")&"                   "

    db.execute(sql)           
    response.write(True)


%>