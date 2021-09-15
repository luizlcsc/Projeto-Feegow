<!--#include file="connect.asp"-->
<%
ConvenioID = req("ConvenioID")
ProcedimentoID = req("ProcedimentoID")
AssociacaoID = req("AssociacaoID")

set c = db.execute("select * from convenios where id="&ConvenioID)
set p = db.execute("select id, NomeProcedimento,Codigo, TecnicaID, CH, UCO as CustoOperacional,Valor,Filme as  QuantidadeFilme from procedimentos where id="&ProcedimentoID)

db.execute("UPDATE tissprodutosprocedimentos pp set pp.ProdutoTabelaID=(select ProdutoTabelaID from tissprodutosvalores where id=pp.ProdutoValorID) where isnull(pp.ProdutoTabelaID)")

sql = "select pv.*, pv.id as AssociacaoID, pt.* from tissprocedimentosvalores as pv left join tissprocedimentostabela as pt on pv.ProcedimentoTabelaID=pt.id where COALESCE(pv.id = NULLIF('"&AssociacaoID&"',''),pv.ConvenioID="&ConvenioID&" and pv.ProcedimentoID="&ProcedimentoID&")"

sqlContratado = " SELECT CONCAT(contratosconvenio.id,'') AS id,CONCAT(CodigoNaOperadora,' - ',NomeContratado) as Contratado FROM (                "&chr(13)&_
                " select 0 as id,NomeFantasia as NomeContratado from empresa                                      "&chr(13)&_
                " UNION ALL                                                                                      "&chr(13)&_
                " select id*-1,NomeFantasia from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1"&chr(13)&_
                " UNION ALL                                                                                      "&chr(13)&_
                " select id, NomeProfissional from profissionais where sysActive=1) t                            "&chr(13)&_
                " JOIN contratosconvenio ON contratosconvenio.Contratado = t.id                                  "&chr(13)&_
                " WHERE ConvenioID = "&ConvenioID&"                                                              "

set proc = db.execute(sql)
if not proc.eof then
    Novo             = "false"
	TabelaID         = proc("TabelaID")
	Contratados      = proc("Contratados")
	Porte            = proc("Porte")
	QuantidadeFilme  = proc("QuantidadeFilme")
	ValorFilme       = proc("ValorFilme")
	QuantidadeCH     = proc("QuantidadeCH")
	CustoOperacional = proc("CustoOperacional")
	ValorUCO         = proc("ValorUCO")
	Descricao        = proc("Descricao")
	Codigo           = proc("Codigo")
	TecnicaID        = proc("TecnicaID")
	ModoCalculo      = proc("ModoDeCalculo")
	ValorUnitario    = proc("Valor")
	ValorCH          = proc("ValorCH")
	NaoCobre         = proc("NaoCobre")
	AssociacaoID     = proc("AssociacaoID")
	CoeficientePorte = proc("CoeficientePorte")
    profissionalExecutanteGuia = proc("profissionalExecutanteGuia")
else
    Novo             = "true"
    Codigo           = p("Codigo")
    TecnicaID        = p("TecnicaID")
	TabelaID         = c("TabelaPadrao")
	Descricao        = p("NomeProcedimento")
	ModoCalculo      = c("ModoDeCalculo")
end if


if NOT ISNULL(c("ValorUCO")) then
   PHValorUCO = c("ValorUCO")
end if

if NOT ISNULL(c("ValorFilme")) then
   PHValorFilme = formatnumber(c("ValorFilme"),4)
end if

if c("ValorCH")&"" <>"" then
    PlaceholderValorCH = formatnumber(c("ValorCH"),4)
end if


function coalesce(valor1,valor2,valor3)

	IF NOT ISNULL(valor1) THEN
	    coalesce = (valor1)
	    Exit Function
	END IF

	IF NOT ISNULL(valor2) THEN
    	coalesce = (valor2)
    	Exit Function
    END IF

    IF NOT ISNULL(valor3) THEN
        coalesce = (valor3)
        Exit Function
    END IF

end function

CoeficientePorte = coalesce(CoeficientePorte,1,null)

%>
<style>
  .table-absolute{
    padding: 10px;
    background: #ffffff;
    border: #dfdfdf 1px solid;
    border-radius: 10px;
    position: absolute;
    z-index: 1000;
  }

  #ConvenioMateriaisProcedimentos .table-absolute{
        right:0px;
  }

  .table-absolute-content{
      overflow:   auto;
      max-width:  700px;
      width:      700px;
      max-height: 200px;
  }
</style>
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title"><%=c("NomeConvenio")%> &raquo; <%=p("NomeProcedimento")%></h4>
</div>
<form method="post" action="" id="frmConvenioValores" name="frmConvenioValores">
<div class="modal-body">
    <div class="row">
       <%=quickField("simpleSelect", "TabelaID", "Tabela", 2, TabelaID, "select id,CONCAT(id,' - ',descricao) as descricao from tisstabelas WHERE ID NOT IN (18,19) UNION ALL select CONCAT(id*-1,''),descricao as descricao  from tabelasconvenios WHERE sysActive = 1", "descricao", " required empty")%>
	   <%=quickField("text", "Codigo", "C&oacute;digo na Tabela", 2, Codigo, " consultarCentral ", "", " required")%>
       <%=quickField("text", "Descricao", "Descri&ccedil;&atilde;o", 4, Descricao, " consultarCentral ", "", " required")%>
       <%=quickField("simpleSelect", "TecnicaID", "T&eacute;cnica", 2, TecnicaID, "select * from tisstecnica order by id", "Descricao", "")%>
       <%=quickField("multiple", "ModoDeCalculo", "Modo de Cálculo", 2, ModoCalculo, "select 'R$' id, 'R$' Descricao UNION ALL select 'CH', 'CH' UNION ALL SELECT 'UCO', 'UCO' UNION ALL SELECT 'PORTE', 'PORTE' UNION ALL SELECT 'FILME', 'FILME'", "Descricao", " semVazio no-select2")%>
    </div>
    <div class="row">
       <%=quickField("currency", "ValorUnitario", "Valor Unit&aacute;rio Geral", 2, ValorUnitario, " valor-unitario ", "", " placeholder="&PHValorFixo&" ")%>
       <%=quickField("currency", "ValorCH", "Valor do CH", 2, ValorCH, " sql-mask-4-digits valor-ch ", "", " placeholder='"&PlaceholderValorCH&"'")%>
       <%=quickField("currency", "QuantidadeCH", "Quantidade de CH", 2, QuantidadeCH, " sql-mask-4-digits QuantidadeCH ", "", " placeholder='"&PHQuantidadeCH&"' ")%>
       <%=quickField("currency", "CustoOperacional", "Custo Operacional", 2, CustoOperacional, " CustoOperacional sql-mask-4-digits ", "",  " placeholder='"&PHCustoOperacional&"'")%>
       <%=quickField("currency", "ValorFilme", "Valor do Filme", 2, ValorFilme, "ValorFilme sql-mask-4-digits", "",  " placeholder='"&PHValorFilme&"'")%>
       <%=quickField("float"  , "QuantidadeFilme", "Quantidade de Filme", 2, QuantidadeFilme, " QuantidadeFilme sql-mask-4-digits ", "",  " placeholder='"&PHQuantidadeFilme&"'")%>
       </div>
    <div class="row">
       <%=quickField("currency", "ValorUCO", "Valor da UCO", 2, ValorUCO, " ValorUCO sql-mask-4-digits", "",  " placeholder='"&PHValorUCO&"'")%>
       <%=quickField("simpleSelect", "Porte", "Porte", 2, Porte, "SELECT distinct Porte id,Porte  FROM cliniccentral.tabelasportesvalores", "Porte", "")%>
       <%=quickField("float", "CoeficientePorte", "Coeficiente Porte", 2, CoeficientePorte, " CoeficientePorte sql-mask-4-digits ", "", " ")%>
       <%=quickField("multiple", "Contratados", "Contratados", 2, Contratados ,sqlContratado , "Contratado", " semVazio no-select2")%>
    </div>
    <div class="row">
       <div class="col-md-3"><br />
           <div class="checkbox-custom checkbox-danger"><input type="checkbox" name="NaoCobre" id="NaoCobre" value="S"<%if NaoCobre="S" then%> checked="checked"<%end if%> /> <label for="NaoCobre"> N&atilde;o cobre</label></div></div>
       </div>

    <%
    set plan = db.execute("select * from conveniosplanos where ConvenioID="&ConvenioID&" and sysActive=1 and not NomePlano like ''")

    if not plan.eof then
    %>
    <div class="row">
    	<div class="col-md-12 widget-box transparent planos">
            <div class="widget-header">
	            <h4 class="lighter">Varia&ccedil;&atilde;o por Plano</h4>
            </div>
            <div class="widget-main padding-6">
        	<table class="table table-hover table-striped table-bordered" width="100%">
            	<thead>
                	<tr>
                    	<th>Plano</th>
                        <th>Código</th>
                    	<th>Quantidade de CH</th>
                    	<!-- <th>Custo Operacional</th> -->
                    	<th>Valor do Filme</th>
                    	<th>Quantidade de Filme</th>
                    	<th>Valor da UCO</th>
                    	<th>Valor CH</th>
                        <th>Valor</th>
                        <th>N&atilde;o cobre</th>
                    </tr>
                </thead>
                <tbody>
                <%
				PlaceholderCodigo="placeholder="""&Codigo&""""

				while not plan.eof
					if AssociacaoID<>"" then
					    sqlPlan = "select * from tissprocedimentosvaloresplanos where AssociacaoID="&AssociacaoID&" and PlanoID="&plan("id")
						set vcaAssoc = db.execute(sqlPlan)

						if vcaAssoc.eof then
							Valor = ""
							PlanoNaoCobre = ""
						else
							Valor = fn(vcaAssoc("Valor"))
							PlanoNaoCobre = vcaAssoc("NaoCobre")
                            CodigoPlano = vcaAssoc("Codigo")
                            ValorPlanoCH = vcaAssoc("ValorCH")
                            QuantidadeCH = vcaAssoc("QuantidadeCH")
                            CustoOperacional = vcaAssoc("CustoOperacional")
                            ValorFilme = vcaAssoc("ValorFilme")
                            QuantidadeFilme = vcaAssoc("QuantidadeFilme")
                            ValorUCO = vcaAssoc("ValorUCO")
						end if
					end if

					db.execute("SET @plano        = "&plan("id"))
                    db.execute("SET @convenio     = "&ConvenioID)
                    db.execute("SET @procedimento = "&ProcedimentoID)


					sql = " SELECT coalesce(tissprocedimentosvalores.QuantidadeCH)                                                                      as PHPQuantidadeCH                                    "&chr(13)&_
                          "       ,format(coalesce(tissprocedimentosvalores.CustoOperacional),4,'de_DE')                                                as PHPCustoOperacional                                "&chr(13)&_
                          "       ,format(coalesce(tissprocedimentosvalores.ValorFilme,conveniosplanos.ValorPlanoFilme,convenios.ValorFilme),4,'de_DE') as PHPValorFilme                                      "&chr(13)&_
                          "       ,format(coalesce(tissprocedimentosvalores.QuantidadeFilme),4,'de_DE')                                                 as PHPQuantidadeFilme                                 "&chr(13)&_
                          "       ,format(coalesce(tissprocedimentosvalores.ValorUCO,conveniosplanos.ValorPlanoUCO,convenios.ValorUCO),4,'de_DE')       as PHPValorUCO                                        "&chr(13)&_
                          "       ,format(coalesce(tissprocedimentosvalores.ValorCH,conveniosplanos.ValorPlanoCH,convenios.ValorCH),4,'de_DE')          as PHPValorCH                                         "&chr(13)&_
                          "       ,format(coalesce(tissprocedimentosvalores.Valor),2,'de_DE')                                                           as PHPValorFixo                                       "&chr(13)&_
                          "       ,coalesce(NULLIF(tissprocedimentostabela.Codigo,''),NULLIF(procedimentos.Codigo,''))                as PHPCodigo                                                            "&chr(13)&_
                          " FROM convenios                                                                                                                                                                    "&chr(13)&_
                          "          JOIN procedimentos                           ON procedimentos.id                            = @procedimento                                                              "&chr(13)&_
                          "          LEFT JOIN conveniosplanos                    ON conveniosplanos.id                          = @plano                                                                     "&chr(13)&_
                          "          LEFT JOIN tissprocedimentosvalores           ON tissprocedimentosvalores.id                 = '"&AssociacaoID&"'                                                         "&chr(13)&_
                          "          LEFT JOIN tissprocedimentosvaloresplanos     ON tissprocedimentosvaloresplanos.PlanoID      = conveniosplanos.id                                                         "&chr(13)&_
                          "                                                      AND tissprocedimentosvaloresplanos.AssociacaoID = tissprocedimentosvalores.id                                                "&chr(13)&_
                          "          LEFT JOIN cliniccentral.tabelasportesvalores ON tabelasportesvalores.Porte                  = procedimentos.Porte                                                        "&chr(13)&_
                          "                                                    AND tabelasportesvalores.TabelaPorteID            = coalesce(NULLIF(conveniosplanos.TabelaPlanoPorte,0),convenios.TabelaPorte) "&chr(13)&_
                          "          LEFT JOIN tissprocedimentostabela            ON tissprocedimentostabela.id                  = tissprocedimentosvalores.ProcedimentoTabelaID                              "&chr(13)&_
                          " WHERE convenios.id = @convenio;                                                                                                                                                   "
                     set PHolders = db.execute(sql)

                     IF NOT PHolders.EOF THEN
                        PHPQuantidadeCH     = PHolders("PHPQuantidadeCH")
                        PHPCustoOperacional = PHolders("PHPCustoOperacional")
                        PHPValorFilme       = PHolders("PHPValorFilme")
                        PHPQuantidadeFilme  = PHolders("PHPQuantidadeFilme")
                        PHPValorUCO         = PHolders("PHPValorUCO")
                        PHPValorCH          = PHolders("PHPValorCH")
                        PHPValorFixo        = PHolders("PHPValorFixo")
                        PHPCodigo           = PHolders("PHPCodigo")
                     END IF

					%>
                    <tr>
                    	<td><%=plan("NomePlano")%></td>
                        <td><%=quickField("text"    , "Codigo" &plan("id")          , "", 12, CodigoPlano       , " CodigoPlano"                , "", "placeholder='"&PHPCodigo&"'")%></td>
                        <td><%=quickField("currency", "QuantidadeCH"&plan("id")     , "", 12, QuantidadeCH      , " sql-mask-4-digits ", "", " placeholder='"&PHPQuantidadeCH&"'")%></td>
                        <!--<td> <%=quickField("currency", "CustoOperacional"&plan("id") , "", 12, CustoOperacional  , "sql-mask-4-digits ", "", " placeholder='"&PHPCustoOperacional&"'")%> </td>-->
                        <td><%=quickField("currency", "ValorFilme"&plan("id")       , "", 12, ValorFilme        , "sql-mask-4-digits ", "", "placeholder='"&PHPValorFilme&"'")%></td>
                        <td><%=quickField("float", "QuantidadeFilme"&plan("id")      , "", 12, QuantidadeFilme     , " sql-mask-4-digits ", "", " placeholder='"&PHPQuantidadeFilme&"'")%></td>
                        <td><%=quickField("currency", "ValorUCO"&plan("id")         , "", 12, ValorUCO          , " sql-mask-4-digits ", "", "placeholder='"&PHPValorUCO&"'")%></td>
                        <td><%=quickField("currency", "ValorCH"&plan("id")          , "", 12, ValorPlanoCH      , " valor-ch sql-mask-4-digits ", "", "placeholder='"&PHPValorCH&"'")%></td>
                        <td><%=quickField("currency", "Valor"  &plan("id")          , "", 12, Valor             , "  Valor valor-unitario"      , "", "placeholder='"&PHPValorFixo&"'")%></td>
                        <td class="ptn"><div style="position:relative;bottom: 10px" class="checkbox-custom checkbox-danger mn pn"><input class="mn pn NaoCobre" type="checkbox" name="NaoCobre<%=plan("id")%>" id="NaoCobre<%=plan("id")%>" value="S"<%if PlanoNaoCobre="S" then%> checked="checked"<%end if%> /><label class="mn pn" for="NaoCobre<%=plan("id")%>"> </label></div></td>
                    </tr>
                    <%
				plan.movenext
				wend
				plan.close
				set plan = nothing
				%>
                </tbody>
            </table>
            </div>
        </div>
    </div>
    <%
    end if
    %>


    <hr class="short alt" />
    <div class="row">
        <div class="col-md-12 panel">
            <div class="panel-heading">
                <span class="panel-title">Outras Despesas a Anexar</span>
                <span class="panel-controls">
                    <button onclick="Add(1);" class="btn btn-sm btn-success" type="button"><i class="far fa-plus"></i> Adicionar Item</button>
                    <button onclick="addProc()" class="btn btn-sm btn-success" type="button"><i class="far fa-plus"></i> Adicionar Procedimento</button>
                </span>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-12" id="ConvenioMateriaisProcedimentos">
                        <%server.Execute("ConvenioMateriaisProcedimentos.asp")%>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <hr class="short alt" />
    <div class="row">
        <div class="col-md-12 panel">
            <div class="panel-heading">
                <span class="panel-title">Profissional Executante Padrão</span>
            </div>
            <div class="panel-body">
                <div class="row">
                <!-- Verifica se o profissional está habilitado pela string concatenada no select -->
                    <%= quickField("simpleSelect", "profissionalExecutanteGuia", "Nome do Profissional", 6, profissionalExecutanteGuia, "SELECT p.id, p.especialidadeID, esp.codigoTISS, CONCAT( p.NomeProfissional, if((p.Conselho IS NULL or p.Conselho='') OR (p.UFConselho IS NULL OR p.UFConselho='') OR (p.CPF IS NULL OR p.CPF='') OR (esp.codigoTISS IS NULL OR esp.codigoTISS=''), ' [incompleto]','')) NomeProfissional from profissionais p left JOIN especialidades esp ON esp.id = p.EspecialidadeID WHERE p.sysActive=1 AND p.Ativo='on' order by NomeProfissional DESC", "NomeProfissional", " no-select2" ) %>
                    <!--<br><br><p style="margin-left:30px;color:red;">Documentos necessários: CPF, CBO, Nº do conselho e UF! </p>-->
                </div>
            </div>
        </div>
    </div>


</div>
<div class="modal-footer no-margin-top">
	<button id="salvar" class="btn btn-sm btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
</div>

</form>
<script type="text/javascript">
<!--#include file="jQueryFunctions.asp"-->


$("#ModoCalculo").change(function() {
    var val = $(this).val();

    //$(".valor-ch").attr("readonly", (val !== "CH"));
    //$(".valor-unitario").attr("readonly", (val !== "R$"));
});

$("#Codigo").keyup(function() {
    $(".CodigoPlano").attr("placeholder", $(this).val());
});

function addProc(){
    $.get("ConvenioMateriaisProcedimentos.asp?addProc=1&AssociacaoID=<%=req("AssociacaoID")%>&ConvenioID=<%=req("ConvenioID")%>&ProcedimentoID=<%=req("ProcedimentoID")%>", function(data){
        $("#ConvenioMateriaisProcedimentos").html(data);
    });
}

$("#profissionalExecutanteGuia").change(function(){
    let str = $('#profissionalExecutanteGuia :selected').text();
    if (str.includes('[incompleto]') == true){
        $("#salvar").prop("disabled", true)
        new PNotify({
            title: 'Necessário completar os dados necessários no cadastro deste profissional! (CPF, Nº do conselho, UF e Especialidade com CBOS)',
            type: 'danger',
            delay: 4000
            });
    } else {
        $("#salvar").prop("disabled", false)
    }
});

$("#frmConvenioValores").submit(function(){
	$.ajax({
		type:"POST",
		url:"saveConvenioValores.asp?ConvenioID=<%=ConvenioID%>&ProcedimentoID=<%=ProcedimentoID%>&AssociacaoID=<%=req("AssociacaoID")%>",
		data:$("#frmConvenioValores").serialize(),
		success: function(data){
			eval(data);
		}
	});
	return false;
});

$("#Codigo").change(function(){
	$.ajax({
		type:"POST",
		url:"tisspreenche.asp?Tipo=DescricaoTabela&Destino=Descricao",
		data:$("#frmConvenioValores").serialize(),
		success: function(data){
			eval(data);
		}
	});
	return false;
});

$("#NaoCobre").click(function(){
	$(".NaoCobre").prop("checked", $(this).prop("checked"));
});

$("#ValorUnitario").keyup(function(){
	$(".planos .Valor").val( $(this).val() );
});

function Add(Q){
	$.ajax({
		type:"POST",
		url:"ConvenioMateriaisProcedimentos.asp?Add="+Q+"&ProcedimentoID=<%=req("ProcedimentoID")%>&ConvenioID=<%=req("ConvenioID")%>&I=0&Valor="+$("#Valor").val()+"&Desconto="+$("#Desconto").val(),
		data:$("#frmConvenioValores").serialize(),
		success:function(data){
			$("#ConvenioMateriaisProcedimentos").html(data);
		}
	});
}

function Remove(R){
	$.ajax({
		type:"POST",
		url:"ConvenioMateriaisProcedimentos.asp?Remove="+R+"&ConvenioID=<%=req("ConvenioID")%>&ProcedimentoID=<%=req("ProcedimentoID")%>&I=0&Valor="+$("#Valor").val()+"&Desconto="+$("#Desconto").val(),
		data:$("#frmConvenioValores").serialize(),
		success:function(data){
			$("#ConvenioMateriaisProcedimentos").html(data);
		}
	});
}

$("#Valor").change(function(){
	$(".valor").val( $(this).val() );
});

$("#ModoCalculo").change();

setTimeout(function () {
    $(".select2-single").select2();

}, 1000);

$(".modal-dialog").css("width","98%");
$(".modal-content").css("width","100%");
$(".modal-content").css("margin-left","0");



if(true === <%=Novo %>){
      fetch(`tabelasconvenios.asp?Local=Novo&ConvenioID=<%=req("ConvenioID")%>&ProcedimentoID=<%=req("ProcedimentoID")%>`)
      .then((data)=>{
            return data.json();
      }).then((json) => {
            sugestoes = json;
            addItemTabela(null,78,3);
      });
}


if( !(dentro === false || dentro === true)){
    var dentro = false;
    var idAnexo = null;
    var sugestoes = [];

    function formatNumber(num,fix){
        if(!num){
            return null;
        }
        return Number(num.replace(".","").replace(",",".")).toLocaleString('de-DE', {
         minimumFractionDigits: fix,
         maximumFractionDigits: fix
       });
    }

    function addItemTabela(arg1,arg2,tipo){
        let sugestao = sugestoes.find(e => e.id == arg2);

         if(!sugestao){
            return;
         }

         if(idAnexo){
             let tag = $("#"+idAnexo).parent().parent().parent();
             tag.find(".Descricao").val(sugestao.Procedimento);
             tag.find(".QuantidadeCH").val(formatNumber(sugestao.QuantidadeCH,0));
             tag.find(".Porte select").val(sugestao.Porte);

             //tag.find(".ValorFilme").val();
             tag.find(".CustoOperacional").val(formatNumber(sugestao.CustoOperacional,2));
             tag.find(".Coeficiente").val(formatNumber(sugestao.Coeficiente,2));
             tag.find(".QuantidadeFilme").val(formatNumber(sugestao.Filme,4));
             tag.find(".ValorUCO").val(formatNumber(sugestao.UCO,4));
             tag.find(".Valor").val(formatNumber(sugestao.Valor,2));
             tag.find(".Codigo").val(sugestao.CodigoTUSS);
             $(".table-absolute").remove();
             atualizarLinha($("#"+idAnexo))
             return
         }



        if(tipo === 3){
            if(sugestao.QuantidadeCH){
                $("#frmConvenioValores [name^='QuantidadeCH']").attr("placeholder",formatNumber(sugestao.QuantidadeCH,0))
            }
            if(sugestao.Filme){
                $("#frmConvenioValores [name^='QuantidadeFilme']").attr("placeholder",formatNumber(sugestao.Filme,4));
            }
            if(sugestao.Codigo){
                $("#frmConvenioValores [name^='Codigo']").attr("placeholder",sugestao.Codigo);
            }
            if(sugestao.Valor){
                $("#frmConvenioValores .valor-unitario").attr("placeholder",formatNumber(sugestao.Valor,2));
            }
            $("#Porte").val(sugestao.Porte).trigger("change");
            $("#CustoOperacional").val(formatNumber(sugestao.CustoOperacional,4));
            $("#TabelaID").val(sugestao.TabelaConvenioID).trigger("change");
            $("#QuantidadeCH").val(formatNumber(sugestao.QuantidadeCH,0));
            $("#QuantidadeFilme").val(formatNumber(sugestao.Filme,4));
            $("#Descricao").val(sugestao.Procedimento);
            $("#Codigo").val(sugestao.Codigo);
            $("#ValorUnitario").val(formatNumber(sugestao.Valor,2));
        }

         if(tipo === 2){
            $("#frmConvenioValores [name^='Codigo']").attr("placeholder",sugestao.CodigoTUSS?sugestao.CodigoTUSS:sugestao.Codigo);
            $("#frmConvenioValores [name^='QuantidadeCH']").attr("placeholder",formatNumber(sugestao.QuantidadeCH,0));
            $("#frmConvenioValores [name^='QuantidadeFilme']").attr("placeholder",formatNumber(sugestao.Filme,4));
            $("#frmConvenioValores .valor-unitario").attr("placeholder",formatNumber(sugestao.ValorReal,4));
            $("#Porte").val(sugestao.Porte).trigger("change");
            $("#Codigo").val(sugestao.CodigoTUSS?sugestao.CodigoTUSS:sugestao.Codigo);
            $("#CustoOperacional").val(formatNumber(sugestao.CustoOperacional,4));
            $("#QuantidadeCH").val(formatNumber(sugestao.QuantidadeCH,0));
            $("#QuantidadeFilme").val(formatNumber(sugestao.Filme,4));
            $("#TabelaID").val("22").trigger("change");
            $("#Descricao").val(sugestao.Procedimento);
            $("#ValorUnitario").val(formatNumber(sugestao.ValorReal,4));
        }

        if(tipo === 1){
            if(!sugestao.tipo || sugestao.tipo === 'local'){
                $("#TabelaID").val(sugestao.TabelaConvenioID*-1).trigger("change");
            }
            $("#Porte").val(sugestao.Porte).trigger("change");

            $("#frmConvenioValores [name^='QuantidadeCH']").attr("placeholder",formatNumber(sugestao.QuantidadeCH,0))
            $("#frmConvenioValores [name^='QuantidadeFilme']").attr("placeholder",formatNumber(sugestao.Filme,4));
            $("#frmConvenioValores [name^='Codigo']").attr("placeholder",sugestao.Codigo);
            $("#frmConvenioValores .valor-unitario").attr("placeholder",formatNumber(sugestao.ValorReal,4));

            $("#Codigo").val(sugestao.Codigo);
            $("#Descricao").val(sugestao.Procedimento);
            $("#QuantidadeCH").val(formatNumber(sugestao.QuantidadeCH,0));
            $("#CustoOperacional").val(formatNumber(sugestao.CustoOperacional,4));
            $("#QuantidadeFilme").val(formatNumber(sugestao.Filme,4));
            $("#ValorUnitario").val(formatNumber(sugestao.ValorReal,4));
        }

        $(".table-absolute").remove();

    }

    $(function() {
       document.addEventListener("click", () => {
           if(!dentro){
               $(".table-absolute").remove();
           }
       }, true);

       $("input").attr("autocomplete","off");

       document.addEventListener("keyup", (arg) => {
            $("input").attr("autocomplete","off");
            let id = arg.target.id;

            if(!(id.indexOf("Codigo") !== -1 || id.indexOf("Descricao") !== -1 || id.indexOf("ValorAnexo") !== -1)){
                return false;
            }

            idAnexo = null;

            if(id.indexOf("ValorAnexo") !== -1){
                idAnexo = id;
            }

            if(!$(arg.target).hasClass('consultarCentral')){
                return false;
            }

           let componentCodigo         = $(arg.target);
           let Codigo                  = $(arg.target).val();

           if(Codigo){
               fetch(`tabelasconvenios.asp?Local=Local&Codigo=${Codigo}`)
               .then((data)=>{
                    return data.json();
               }).then((json) => {
                   $(".table-absolute").remove();

                   if(!(json && json.length > 0)){
                      return ;
                   }
                   sugestoes = json;

                   let linhas = json.map((j) => {
                       return `<tr>
                                    <td>${j.Procedimento}</td>
                                    <td>
                                        <span class="${j.Codigo?'':'hidden'}">
                                         ${j.Descricao}<br/>
                                        <button type="button" class="btn btn-sm btn-success" onclick="addItemTabela('${componentCodigo.attr("id")}',${j.id},1)">${j.Codigo}</button>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="${j.CodigoTUSS?'':'hidden'}">
                                        TUSS<br/>
                                        <button type="button" class="btn btn-sm btn-success" onclick="addItemTabela('${componentCodigo.attr("id")}',${j.id},2)">${j.CodigoTUSS}</button>
                                        </span>
                                    </td>
                               </tr>`
                   });

                   let linhasstr = linhas.join(" ");

                   let html = `<div class="table-absolute">
                                    <div class="table-absolute-content">
                                        <table class="table table-bordered table-striped">

                                            <tbody>
                                            ${linhasstr}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>`;

                   $(arg.target).parent().append(html);

                   $( ".table-absolute" )
                   .mouseenter(function() {
                       dentro = true;
                   })
                   .mouseleave(function() {
                       dentro = false;
                   });
               });
           }
       }, true);
    });
}


</script>