<!--#include file="connect.asp"-->
<%
I = req("I")
if I="N" then
	sqlVie = "select * from produtos where sysUser="&session("User")&" and sysActive=0 and TipoProduto = 5"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into produtos (sysUser, sysActive, TipoProduto) values ("&session("User")&", 0, 5)")
		set vie = db.execute(sqlVie)
	end if
    response.Redirect("./?P=ProdutosTaxas&I="&vie("id")&"&Pers=1")
    vie.close
else
	set reg = db.execute("select * from produtos where TipoProduto = 5 and id="&I)
	if reg.eof then
        response.Redirect("./?P=ListaProdutosTaxas&Pers=1")
        reg.close
	end if
end if
%>

<script type="text/javascript">
    $(".crumb-active a").html("Taxas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html('Taxa');
    $(".crumb-icon a span").attr("class", "far fa-money");

    $("#rbtns").html('<button class="btn btn-sm btn-primary" type="button" id="Salvar" onclick="taxaSubmit()"><i class="far fa-save"></i> <strong>SALVAR</strong></button>');
</script>

<form method="post" id="frm" name="frm" action="save.asp">
    <input type="hidden" name="I" value="<%=request.QueryString("I")%>" class="idItem"/>
    <input type="hidden" name="P" value="produtos" />

    <div class="tabbable panel">
        <div class="tab-content panel-body mt20">
            <div id="divCadastroProduto" class="tab-pane in active">
                <div class="row">
                    <input type="hidden" name="TipoProduto" id="TipoProduto" value="5">
                    <%=quickField("text", "NomeProduto", "Nome", 4, reg("NomeProduto"), "", "", " required")%>                  
                    <%=quickField("simpleSelect", "CD", "CD", 3, reg("CD"), "select * from cliniccentral.tisscd where id=7 order by Descricao", "Descricao", "semVazio")%>
                </div>
            </div>
        </div>
    </div>
</form>

<script type="text/javascript">
    function taxaSubmit() {
        if ($('#frm')[0].reportValidity()) {
            $('#frm').submit();
        }
    }
    $(document).ready(function() {
        <%call formSave("frm", "save", "")%>
    });
</script>