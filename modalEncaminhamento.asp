<!--#include file="connect.asp"-->
<div class="modal-body">
    <div class="row">
        <div class="col-md-10">
        <%
			src="printEncaminhamento.asp?TipoEncaminhamento="&ref("Tipo")&"&PacienteID="&ref("PacienteID")&"&EncaminhamentoID="&ref("EncaminhamentoID")
		%>
        <iframe width="100%" height="600px" src="<%=src%>" id="ImpresaoEncaminhamento" name="ImpresaoEncaminhamento" frameborder="0"></iframe>
        </div>
        <div class="col-md-2">
            <label><input type="checkbox" id="Carimbo" name="Carimbo" class="ace" checked="checked" onclick="window.frames['ImpresaoEncaminhamento'].Carimbo(this.checked);" />
                <span class="lbl"> Carimbar</span>
            </label>
            <label><input type="checkbox" id="Timbrado" name="Timbrado" class="ace" checked  onclick="window.frames['ImpresaoEncaminhamento'].Timbrado(this.checked);" />
                <span class="lbl"> Papel Timbrado</span>
            </label>
            <hr />
            <button class="btn btn-sm btn-success btn-block" data-dismiss="modal">
                <i class="far fa-remove"></i>
                Fechar
            </button>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">


</div>
