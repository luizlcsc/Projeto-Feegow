<!--#include file="connect.asp"--> <!--#include file="./Classes/imagens.asp"-->
<%
Tipo  = req("Tipo")
IDs   = req("IDs")
LicencaID = replace(session("Banco"),"clinic","")

qArquivosSQL = "SELECT NomeArquivo,Descricao FROM arquivos WHERE id IN("&IDs&")"

set arquivosSQL = db.execute(qArquivosSQL)
while not arquivosSQL.eof

    arq_NomeArquivo = arquivosSQL("NomeArquivo")
    arq_Descricao   = arquivosSQL("Descricao")

    imgModeloHTML = "<img class='printThisFull' width='100' src='"&imgSRC("Imagens",trim(arq_NomeArquivo)&"&dimension=full")&"' alt='"&arq_Descricao&"'> "&"<hr>"

    if imgHTML="" then
        imgHTML = imgModeloHTML
    else
        imgHTML = imgHTML&imgModeloHTML
    end if

arquivosSQL.movenext
wend
arquivosSQL.close
set arquivosSQL = nothing
%>
<style type="">
body {opacity:0;}
 @media print {
     body {opacity:1;}
     .printThisFull {
         width:100%;
         height:auto;
         page-break-after:always
     }
 }
</style>
<%=(imgHTML)%>
<script>
    window.print();
    window.addEventListener("afterprint", function(event) { window.close(); });
    window.onafterprint();
</script>
