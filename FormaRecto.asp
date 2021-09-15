<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Formas de Recebimento");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("edição das formas predefinidas de recebimento");
    $(".crumb-icon a span").attr("class", "far fa-usd");
</script>

<style type="text/css">
.tags, .chosen-container {
	width:100%!important;
}
.select-group{
	background: none; 
	border: none; 
	padding: 0;
	margin: 0; 
	height: 16px;
}
</style>

<br />


<form method="post" id="formForma">
    <div class="panel">
        <div class="panel-heading">
            <div class="col-md-2">
                <div class="btn-group">
                    <button type="button" data-toggle="dropdown" class="btn btn-success btn-sm dropdown-toggle"><i class="far fa-plus"></i> <strong>ADICIONAR</strong></button>
                    <ul class="dropdown-menu dropdown-info">
                    <%
                    set pm = db.execute("select * from sys_financialpaymentmethod where AccountTypesC!='' order by PaymentMethod")
                    while not pm.eof
                        %>
                        <li><a href="javascript:addForma('<%= pm("id") %>');"><%=pm("PaymentMethod")%></a></li>
                        <%
                    pm.movenext
                    wend
                    pm.close
                    set pm=nothing
                    %>
                    </ul>
                </div>
            </div>
            <div class="col-md-2 col-md-offset-8 text-right">
                <button type="button" onclick="addForma('save')" class="btn btn-sm btn-primary">&nbsp;&nbsp;<i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>
            </div>
        </div>

        <div id="FormaRectoTabela" class="panel-body">
            <%server.Execute("FormaRectoTabela.asp")%>
        </div>
        <!-- <div class="panel-footer">
            <div class="row">
                <%=quickField("multiple", "UsuariosLivres", "Usu&aacute;rios com permiss&atilde;o para recebimento em todas os m&eacute;todos poss&iacute;veis", 8, UsuariosLivres, "select * from (select f.sysActive, f.Ativo, u.id, concat(f.NomeFuncionario, ' - Funcionário') as Nome from sys_users as u left join funcionarios as f on f.id=u.idInTable                                  union all                                          select p.sysActive, p.Ativo, u.id, concat(p.NomeProfissional, ' - Profissional') from sys_users as u left join profissionais as p on p.id=u.idInTable)t  WHERE t.sysActive=1 AND t.Ativo='on'  order by Nome", "Nome", "")%>
                <div class="col-md-4">
	                <label><input type="checkbox" class="ace" name="UsuariosLivres" checked="checked" value="|ALL|" /><span class="lbl"> Todos (desmarque esta op&ccedil;&atilde;o para que apenas os usu&aacute;rios selecionados ao lado possam ter acesso a todas as formas de recebimento poss&iacute;veis)</span></label>
                </div>
            </div>
        </div>-->
    </div>
</form>


<script type="text/javascript">
function addForma(PM){
	$.post("FormaRectoTabela.asp?PM="+PM, $("#formForma").serialize(), function(data, status){$("#FormaRectoTabela").html(data);});
}

$(document).ready(function() {
  setTimeout(function() {
    $("#toggle_sidemenu_l").click()
  }, 500);
})
</script>