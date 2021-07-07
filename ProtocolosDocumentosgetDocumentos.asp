<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 

    sql =   " select                                                        "&chr(13)&_
            " 	tda.NomeArquivo ,                                           "&chr(13)&_
            " 	tda.id                                                      "&chr(13)&_
            " from protocolos_documentos p                                  "&chr(13)&_
            " join tipos_de_arquivos tda on tda.id = p.tipoDocumentoID      "&chr(13)&_
            " where p.sysActive = 1                                         "&chr(13)&_
            " and p.protocoloID = "&req("protocolo")&"                      "&chr(13)&_
            " order by tda.NomeArquivo                                      "


    response.write(recordToJSON(db.execute(sql)))
%>