<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Repasses a Consolidar");
    $(".crumb-icon a span").attr("class", "fa fa-puzzle-piece");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("conferência de repasses gerados");
    <%
    if aut("configrateio")=1 and false then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=Rateio&Pers=1"><i class="fa fa-puzzle-piece"></i><span class="menu-text"> Configurar Regras de Repasse</span></a>');
    <%
    end if
    %>
</script>
      
      
      
    <%

Unidades = req("Unidades")
if Unidades="" then
    Unidades = "|"& session("UnidadeID") &"|"
end if

	
ContaCredito = request.QueryString("ContaCredito")
FormaID = request.QueryString("FormaID")
Lancado = request.QueryString("Lancado")
Status = request.QueryString("Status")
De = request.QueryString("De")
Ate = request.QueryString("Ate")

if instr(De, "-")>0 then
    De = cdate(De)
    Ate = cdate(Ate)
end if


dividirCompensacao = req("dividirCompensacao")
if De="" then
	De = date()
end if
if Ate="" then
	Ate = date()
end if

set ConfigSQL = db.execute("SELECT AutoConsolidar FROM sys_config")
if not ConfigSQL.eof then
'    AutoConsolidarRepasse=ConfigSQL("AutoConsolidar")
end if
%>

    <form action="" id="buscaRepasses" name="buscaRepasses" method="get">
        <input type="hidden" name="P" value="RepassesAConferir" />
        <input type="hidden" name="AutoConsolidarRepasse" value="<%=AutoConsolidarRepasse%>" />
        <input type="hidden" name="Pers" value="1" />
        <br />
        <div class="panel">
            <div class="panel-body hidden-print">
                <div class="row">
                    <%= quickfield("multiple", "Forma", "Convênio", 2, req("Forma"), "select '0' id, '   PARTICULAR' Forma UNION ALL select id, NomeConvenio from (select c.id, c.NomeConvenio from convenios c where c.sysActive=1 and Ativo='on' order by c.NomeConvenio) t ORDER BY Forma", "Forma", " required ") %>
                    <%'= quickfield("multiple", "FormaRecto", "Forma de recto.", 2, req("FormaRecto"), "select id, PaymentMethod from cliniccentral.sys_financialpaymentmethod where TextC<>'' ORDER BY PaymentMethod", "PaymentMethod", "") %>
                    <div class="col-md-2 col-md-offset-2">
                        <label for="Status">Status de Recto</label><br />
                        <select name="Status" class="form-control" id="Status">
                            <option value="">Todos</option>
                            <option value="S" <%if Status="S" then%> selected="selected" <%end if%>>Recebidos</option>
                            <option value="N" <%if Status="N" then%> selected="selected" <%end if%>>N&atilde;o recebidos</option>
                            <option value="C" <%if Status="C" then%> selected="selected" <%end if%>>Consolidados</option>
                        </select>
                    </div>
                    <%= quickField("datepicker", "De", "Per&iacute;odo", 2, De, "", "", " placeholder='De' required='required'") %>
                    <%= quickField("datepicker", "Ate", "&nbsp;", 2, Ate, "", "", " placeholder='At&eacute;' required='required'") %>
                    <div class="col-md-2">
                        <label>Tipo de Data:</label><br />
                        <span class="radio-custom"><input type="radio" name="TipoData" value="Exec" <% if req("TipoData")="Exec" or req("TipoData")="" then response.write(" checked ") end if %> id="TDE" /><label for="TDE"> Execução</label></span>
                        <br />
                        <span class="radio-custom"><input type="radio" name="TipoData" value="Comp" <% if req("TipoData")="Comp" then response.write(" checked ") end if %> id="TDC" /><label for="TDC"> Compensação</label></span>
                    </div>
                </div>
                <div class="row mt10">
                    <div class="checkbox-custom checkbox-primary col-md-4 pt20">
                        <input type="checkbox" id="dividirCompensacao" name="dividirCompensacao" value="S"<% if dividirCompensacao="S" then response.write(" checked ") end if %> /><label for="dividirCompensacao">Dividir por compensação</label>
                    </div>
                    <div class="col-md-2">
                        <%= quickfield("empresaMultiIgnore", "Unidades", "Unidades", 12, Unidades, "", "", "") %>
                    </div>
                    <%
                    if req("B")="1" then
                    %>
                    <input type="hidden" id="AccountID" name="AccountID" value="<%=req("AccountID")%>">
                    <input type="hidden" id="B" name="B" value="1">
                    <%
                    else
                    %>
                    <div class="col-md-2">
                        <%=selectInsertCA("Executante", "AccountID", req("AccountID"), "5, 8, 2, 4", "", " ", "")%>

                    </div>
                    <%
                    end if
                    %>
                    <%= quickfield("simpleSelect", "ProcedimentoID", "Limitar procedimento", 2, req("ProcedimentoID"), "select distinct(concat('G', pg.id)) id, concat('&raquo; ', trim(NomeGrupo)) NomeProcedimento from procedimentosgrupos pg      UNION ALL       select id, NomeProcedimento from procedimentos where ativo='on' and sysActive=1 order by NomeProcedimento limit 1000", "NomeProcedimento", "") %>
                    <div class="col-md-2">
                        <button id="BtnBuscar" class="btn btn-primary btn-buscar btn-block mt25"><i class="fa fa-search"></i>Buscar</button>
                    </div>
                </div>
               <% if req("Forma")<>"" or req("AC")="1" then %>
               <hr class="short alt" />
                <div class="row botoes-painel">
                    <div class="col-md-12">
                        <span class="checkbox-custom checkbox-success">
                            <input type="checkbox" id="allSuccess" name="allSuccess" onclick="$('.checkbox-success input[type=checkbox]').prop('checked', $(this).prop('checked') )" /><label for="allSuccess">Marcar pagos</label>
                        </span>
                        <span class="checkbox-custom checkbox-danger">
                            <input type="checkbox" id="allDanger" name="allDanger" onclick="$('.checkbox-danger input[type=checkbox]').prop('checked', $(this).prop('checked') )" /><label for="allDanger">Marcar não pagos</label>
                        </span>
                        <span class="checkbox-custom">
                            <input type="checkbox" id="allCons" name="allCons" onclick="$('input[name=desconsAll]').prop('checked', $(this).prop('checked') )" /><label for="allCons">Marcar consolidados</label>
                        </span>
                        <button type="button" onclick="descAll()" class="btn btn-xs btn-danger"><i class="fa fa-remove"></i> Desconsolidar</button>
                        <button class="btn btn-default btn-xs btn-consolida" type="button" onclick="consolida()">
                            <i class="fa fa-check"></i> Consolidar
                        </button>
                    </div>
                </div>
            <% end if %>
            </div>
        </div>
    </form>


<%


    if datediff("d", De, Ate)>91 then
        %>
        <div class="alert alert-warning">
            <strong>Atenção! </strong> Escolha um período menor que 3 meses.
        </div>
        <%
    else
    %>
        <!--#include file="RepasseCalculoAConferir.asp"-->
    <%
    end if
%>



<script type="text/javascript">
$(".repasse, #marcar").change(function(){
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?ContaCredito=<%=request.QueryString("ContaCredito")%>",
		data:$("#frmRepasses").serialize(),
		success: function(data){
			$("#calculaRepasses").html(data);
		}
	});
});

$("#marcar").click(function(){
	if($(this).prop("checked")==true){
		$(".repasse").prop("checked", "checked");
	}else{
		$(".repasse").removeAttr("checked");
	}
});
function lancaRepasses(rps, vlr, cc){
	$("#calculaRepasses").html("Lan&ccedil;ando repasses no contas a pagar...");
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?rps="+rps+"&vlr="+vlr+"&cc="+cc,
		data:$("#frmRepasses, #buscaRepasses").serialize(),
		success: function(data){
			eval(data);
		}
	});
}

function x(I){
	if(confirm('Tem certeza de que deseja excluir este repasse?')){
		location.href='./?<%=request.QueryString()%>&X='+I;
	}
}

var $btnConsolida = $(".btn-consolida");

function consolida(){
    $btnConsolida.attr("disabled", true);
    $.post("repasseConsolida.asp", $("input[name=linhaRepasse]:checked, input[name=linhaRepasseG]:checked, input[type=hidden]").serialize(), function(data){
        eval(data);
        $btnConsolida.attr("disabled", false);
    });
}


function desconsolida(Tipo, I, IDescID, GConsol) {
    $.post("repasseDesconsolida.asp", { Tipo: Tipo, I: I, IDescID: IDescID, GConsol: GConsol }, function (data) {
        eval(data);
    });
}


function descAll() {
    $.post("repasseDesconsolida.asp", $("input[name=desconsAll]").serialize(), function (data) {
        eval(data);
    });
}



<%
if req("B")="1" then
%>
$(document).ready(function() {
        $(".botoes-painel").remove();
         $(".checkbox-custom, .btn", "#content").not(".btn-buscar").remove();
});
<%
end if
'roda esse bloco caso ja esteja com resultados na tela
if req("AccountID")<>"" then
    if req("AutoConsolidarRepasse")="S" then
    %>
    var AConsolidarLen = $('input[name=linhaRepasse]').length;

    if(AConsolidarLen>0){
        $("input[name=allSuccess], input[name=allDanger]").click();
        consolida();
    }else{
        var url = "<%=request.querystring()%>";
        url = url.replace("P=RepassesAConferir" , "?P=RepassesConferidos");
        location.href = url;
    }
    <%
    end if
end if
%>

</script>