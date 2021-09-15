<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Repasses a Consolidar");
    $(".crumb-icon a span").attr("class", "far fa-puzzle-piece");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("conferência de repasses gerados");
    <%
    if aut("configrateio")=1 and false then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=Rateio&Pers=1"><i class="far fa-puzzle-piece"></i><span class="menu-text"> Configurar Regras de Repasse</span></a>');
    <%
    end if
    %>
</script>
      
      
      
    <%

Unidades = reqf("Unidades")
if Unidades="" then
    Unidades = "|"& session("UnidadeID") &"|"
end if

	
ContaCredito = reqf("ContaCredito")
FormaID = reqf("FormaID")
Lancado = reqf("Lancado")
Status = reqf("Status")
De = reqf("De")
Ate = reqf("Ate")

if instr(De, "-")>0 then
    De = cdate(De)
    Ate = cdate(Ate)
end if


dividirCompensacao = reqf("dividirCompensacao")
ExibirNaoExecutado = reqf("ExibirNaoExecutado")

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

    <form action="" id="buscaRepasses" name="buscaRepasses" method="post">
        <input type="hidden" name="P" value="RepassesAConferir" />
        <input type="hidden" name="AutoConsolidarRepasse" value="<%=AutoConsolidarRepasse%>" />
        <input type="hidden" name="Pers" value="1" />
        <br />
        <div class="panel">
            <div class="panel-body hidden-print">
                <div class="row">
                    <%= quickfield("multiple", "Forma", "Convênio", 2, reqf("Forma"), "select '0' id, '   PARTICULAR' Forma UNION ALL select id, NomeConvenio from (select c.id, c.NomeConvenio from convenios c where c.sysActive=1 and c.NomeConvenio!='' and Ativo='on' order by c.NomeConvenio) t ORDER BY Forma", "Forma", " required ") %>
                    <%= quickfield("multiple", "TipoRecebedor", "Tipo do recebedor", 2, reqf("TipoRecebedor"), "select id, AssociationName from sys_financialaccountsassociation where id in (2,4,5,8) ORDER BY AssociationName", "AssociationName", "") %>
                    <div class="col-md-2">
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
                        <span class="radio-custom"><input type="radio" name="TipoData" value="Exec" <% if reqf("TipoData")="Exec" or reqf("TipoData")="" then response.write(" checked ") end if %> id="TDE" /><label for="TDE"> Execução</label></span>
                        <br />
                        <span class="radio-custom"><input type="radio" name="TipoData" value="Comp" <% if reqf("TipoData")="Comp" then response.write(" checked ") end if %> id="TDC" /><label for="TDC"> Compensação</label></span>
                    </div>
                </div>
                <div class="row mt10">
                    <div class="checkbox-custom checkbox-primary col-md-2 pt20">
                        <input type="checkbox" id="dividirCompensacao" name="dividirCompensacao" value="S"<% if dividirCompensacao="S" then response.write(" checked ") end if %> /><label for="dividirCompensacao">Dividir por compensação</label>
                    </div>
                    <div class="col-md-2">
                        <%= quickfield("empresaMultiIgnore", "Unidades", "Unidades", 12, Unidades, "", "", "") %>
                    </div>
                    <div class="checkbox-custom checkbox-primary col-md-2 pt20">
                        <input type="checkbox" id="ExibirNaoExecutado" name="ExibirNaoExecutado" value="S"<% if ExibirNaoExecutado="S" then response.write(" checked ") end if %> /><label for="ExibirNaoExecutado">Exibir não executado</label>
                    </div>
                    <%
                    if reqf("B")="1" then
                    %>
                    <input type="hidden" id="AccountID" name="AccountID" value="<%=reqf("AccountID")%>">
                    <input type="hidden" id="B" name="B" value="1">
                    <%
                    else
                    %>
                    <div class="col-md-2">
                        <%=selectInsertCA("Executante", "AccountID", reqf("AccountID"), "5, 8, 2, 4", "", " ", "")%>

                    </div>
                    <%
                    end if
                    %>
                    <%= quickfield("simpleSelect", "ProcedimentoID", "Limitar procedimento", 2, reqf("ProcedimentoID"), "select distinct(concat('G', pg.id)) id, concat('&raquo; ', trim(NomeGrupo)) NomeProcedimento from procedimentosgrupos pg  WHERE sysActive=1    UNION ALL       select id, NomeProcedimento from procedimentos where ativo='on' and sysActive=1 order by NomeProcedimento limit 1000", "NomeProcedimento", "") %>
                    <div class="col-md-2">
                        <button id="BtnBuscar" class="btn btn-primary btn-buscar btn-block mt25"><i class="far fa-search"></i>Buscar</button>
                    </div>
                </div>
               <% if reqf("Forma")<>"" or reqf("AC")="1" then %>
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
                        <button type="button" onclick="descAll()" class="btn btn-xs btn-danger"><i class="far fa-remove"></i> Desconsolidar</button>
                        <button class="btn btn-default btn-xs btn-consolida" type="button" onclick="consolida()">
                            <i class="far fa-check"></i> Consolidar
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
        <div class="alert alert-sm alert-border-left alert-danger alert-dismissable">
          <i class="far fa-exclamation-circle pr10"></i>
          <strong>Atenção!</strong> Escolha um período menor que 3 meses.
        </div>
        <%
    else

    if ExibirNaoExecutado="S" then
        %>
        <div class="alert alert-sm alert-border-left alert-warning alert-dismissable">
          <i class="far fa-exclamation-circle pr10"></i>
          <strong>Atenção!</strong> Ao exibir atendimentos não executados, regras com recebedor <i>"Profissional Executante"</i> <strong>não serão aplicadas</strong>.
        </div>
<%
    end if
    %>
        <!--#include file="RepasseCalculoAConferir.asp"-->
    <%
    end if

%>



<script type="text/javascript">
$(".repasse, #marcar").change(function(){
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?ContaCredito=<%=reqf("ContaCredito")%>",
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


$(document).ready(function() {

    $("#ExibirNaoExecutado").change(function() {
        $("#searchAccountID, #AccountID").val("").attr("disabled", $(this).prop("checked"));
    });
});

<%


if ExibirNaoExecutado="S" then
    %>
    $("#searchAccountID, #AccountID").val("").attr("disabled", true);
    <%
end if

if reqf("B")="1" then
%>
$(document).ready(function() {


        $(".botoes-painel").remove();
         $(".checkbox-custom, .btn", "#content").not(".btn-buscar").remove();
});

<%

end if
'roda esse bloco caso ja esteja com resultados na tela

if reqf("AccountID")<>"" then
    if reqf("AutoConsolidarRepasse")="S" then
    %>
    var AConsolidarLen = $('input[name=linhaRepasse]').length;

    if(AConsolidarLen>0){
        $("input[name=allSuccess], input[name=allDanger]").click();
        consolida();
    }else{
        var url = "<%=request.QueryString()%>";
        url = url.replace("P=RepassesAConferir" , "?P=RepassesConferidos");
        location.href = url;
    }
    <%
    end if
end if
%>
function detalhaDominio(tipoItem, itemId) {
    openComponentsModal("TestaRegraDeRepasse.asp", {
        Tabela: tipoItem,
        I: itemId
    },"Teste da regra de repasse", true, false, "lg");
}
</script>