<%
if req("E")="E" then
%>
<div class="clearfix form-actions">
	<div class="col-md-8">
	    <h4 class="lighter blue"><i class="far fa-envelope"></i> Enviar E-mail</h4>
        <div class="row">
			<%=quickField("text", "Assunto", "Assunto", 12, "", "", "", "")%>
			<%=quickField("editor", "Mensagem", "Mensagem", 12, "", "100", "", "")%>
        </div>
          <hr />
        <div class="row">
            <div class="col-md-2">
                <button type="button" class="btn btn-primary"><i class="far fa-arrow-right"></i> ENVIAR</button>
            </div>
            <div class="col-md-4">
                <select class="form-control">
                    <option>--- Carregar Template ---</option>
                </select>
            </div>
            <div class="col-md-1">
                <button type="button" class="btn btn-success"><i class="far fa-plus"></i></button>
            </div>
		</div>
    </div>
    <div class="col-md-4">
    	<h4 class="lighter blue"><i class="far fa-tag"></i> Gerar Etiquetas</h4>
        <div class="row">
			<%=quickField("text", "Linhas", "N&uacute;mero de Linhas", 6, "4", "", "", "")%>
            <%=quickField("text", "Colunas", "N&uacute;mero de Colunas", 6, "12", "", "", "")%>
        </div>
        <hr />
        <div class="row">
        	<div class="col-md-12">
	            <button type="button" class="btn btn-primary"><i class="far fa-print"></i> IMPRIMIR</button>
            </div>
        </div>
    </div>
</div>
<%
end if
%>