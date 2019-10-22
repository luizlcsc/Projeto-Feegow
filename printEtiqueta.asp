<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-heading">
        <h4>Impressão de Etiquetas</h4>
    </div>
    <div class="panel-body">
        <iframe name="cbiGeraEtiquetas" id="cbiGeraEtiquetas" src="cbiGeraEtiquetas.asp?ProdutoID=<%=req("ProdutoID") %>&Etiquetas=<%=ref("etiqueta") %>" frameborder="0" width="100%" height="450"></iframe>
    </div>
</div>