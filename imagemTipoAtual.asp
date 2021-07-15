<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
response.Charset="utf-8"

    sql =   " select TipoArquivoID,validade from arquivos where id="&req("id")
    
    ' response.write(sql)
    
    response.write(recordToJSON(db.execute(sql)))
%>