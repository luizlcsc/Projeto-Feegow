<!--#include file="connect.asp"-->
<%
call insertRedir(request.QueryString("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
%>
<br>
<div class="panel">
<div class="panel-body">
<form method="post" id="frm" name="frm" action="save.asp">
	<input type="hidden" name="I" value="<%=req("I")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />
	<%=header(req("P"), "MODELOS DE CONTRATOS", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
<div class="row">
    <div class="col-md-12">
        <div class="row">
	        <%=quickField("text", "NomeModelo", "Nome do Modelo", 9, reg("NomeModelo"), "", "", " required")%>
	        <%=quickField("text", "UrlContrato", "Link do contrato (PDF)", 5, reg("UrlContrato"), "", "", " ")%>
        </div>

        <div class="conteudo-contrato-texto-livre">
            <br />
            <div class="row">
                <%=quickField("editor", "Conteudo", "Conteúdo", 9, reg("Conteudo"), "500", "", " required")%>
                <div class="col-md-3">
                    <!--#include file="Tags.asp"-->
                </div>
            </div>

            <br />
            <div class="row">
                <div class="col-md-12">
                    <label><input type="checkbox" name="AgruparExecutante" id="AgruparExecutante" value="S" class="ace"<%if reg("AgruparExecutante")="S" then response.write(" checked ") end if %> /><span class="lbl"> Agrupar por executante</span></label>
                </div>
                <div class="col-md-12">
                    <label><input type="checkbox" name="AgruparParcela" id="AgruparParcela" value="S" class="ace"<%if reg("AgruparParcela")="S" then response.write(" checked ") end if %> /><span class="lbl"> Agrupar por parcela</span></label>
                </div>
            </div>
        </div>
    </div>
    
</div>
<br />
<br />
<br />
<br />
<br />
<br />
</form>

</div>
</div>

<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>

	$("#UrlContrato").change(function() {
	  linkPreenchido();
	})
});

function linkPreenchido() {
    var link = $("#UrlContrato").val(),
        $conteudoTextoLivre = $(".conteudo-contrato-texto-livre");

    if(!link){
        $conteudoTextoLivre.fadeIn();
    }else{
        $conteudoTextoLivre.fadeOut();
    }
}

linkPreenchido();
</script>
<!--#include file="disconnect.asp"-->