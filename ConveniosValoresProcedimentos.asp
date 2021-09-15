<!--#include file="connect.asp"-->
<!--#include file="Classes\ValorProcedimento.asp"-->
<%
ConvenioID = req("ConvenioID")
response.buffer

if req("X")<>"" then
	db_execute("delete from tissprocedimentosvalores where id="&req("X"))
	db_execute("delete from tissprocedimentosvaloresplanos where AssociacaoID="&req("X"))
	db_execute("delete from tissprocedimentosanexos where AssociacaoID="&req("X"))
end if


IF req("Recalcular") <> "" THEN
        db_execute("UPDATE tissprocedimentosvalores       SET ValorConsolidado=NULL WHERE ConvenioID="&ConvenioID)
    	db_execute("UPDATE tissprocedimentosvaloresplanos SET ValorConsolidado=NULL WHERE AssociacaoID IN (SELECT ID FROM tissprocedimentosvalores WHERE ConvenioID = "&ConvenioID&")")
END IF

if req("Clonar")<>"" then

	sqlClone = " SELECT ProcedimentoID,ConvenioID,id INTO @ProcedimentoID,@ConvenioID,@ProcedimentosValoresID FROM tissprocedimentosvalores WHERE id ="&req("Clonar")&";                                                                                                                                      "&chr(13)&_
               " INSERT INTO tissprocedimentosvalores(ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, ValorCH, TecnicaID, NaoCobre, ModoCalculo, DHUp, QuantidadeCH, CustoOperacional, ValorFilme, QuantidadeFilme, ValorUCO, ModoDeCalculo, CoeficientePorte, Porte, Contratados)                                   "&chr(13)&_
               " SELECT ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, ValorCH, TecnicaID, NaoCobre, ModoCalculo, DHUp, QuantidadeCH, CustoOperacional, ValorFilme, QuantidadeFilme, ValorUCO, ModoDeCalculo, CoeficientePorte, Porte, Contratados FROM tissprocedimentosvalores WHERE id = @ProcedimentosValoresID;"&chr(13)&_
               " SET @AssociacaoID = LAST_INSERT_ID();                                                                                                                                                                                                                                                                        "&chr(13)&_
               " INSERT INTO tissprocedimentosvaloresplanos(AssociacaoID, PlanoID, Valor, ValorCH, Codigo, NaoCobre, DHUp, QuantidadeCH, CustoOperacional, ValorFilme, QuantidadeFilme, ValorUCO, CoeficientePorte)                                                                                                           "&chr(13)&_
               " SELECT @AssociacaoID, PlanoID, Valor, ValorCH, Codigo, NaoCobre, DHUp, QuantidadeCH, CustoOperacional, ValorFilme, QuantidadeFilme, ValorUCO, CoeficientePorte FROM tissprocedimentosvaloresplanos                                                                                                           "&chr(13)&_
               " WHERE AssociacaoID = @ProcedimentosValoresID;                                                                                                                                                                                                                                                                "&chr(13)&_
               " INSERT INTO tissprocedimentosanexos(ConvenioID, ProcedimentoPrincipalID, ProcedimentoAnexoID, Valor, Descricao, Codigo, TecnicaID, TabelaID, sysUser, sysDate, DHUp, QuantidadeCH, ValorFilme, QuantidadeFilme, ValorUCO, ValorCH, ValorPadrao, Porte, CustoOperacional, Coeficiente, Calculo, AssociacaoID,Planos) "&chr(13)&_
               " SELECT ConvenioID, ProcedimentoPrincipalID, ProcedimentoAnexoID, Valor, Descricao, Codigo, TecnicaID, TabelaID, sysUser, sysDate, DHUp, QuantidadeCH, ValorFilme, QuantidadeFilme, ValorUCO, ValorCH, ValorPadrao, Porte, CustoOperacional, Coeficiente, Calculo, @AssociacaoID,Planos FROM tissprocedimentosanexos "&chr(13)&_
               " WHERE coalesce(tissprocedimentosanexos.AssociacaoID = @ProcedimentosValoresID,(@ProcedimentoID,@ConvenioID) = (ProcedimentoPrincipalID,ConvenioID))                                                                                                                                                          "

    a=Split(sqlClone,";")
    for each x in a
          db.execute(x)
    next

end if
%>

<div class="panel">
    <div class="panel-body">
    <div class="row">
        <%= quickfield("text", "ProcedimentoRapido", "Busca rápida de procedimento", 10, "", "", "", " placeholder='Digite o Nome do procedimento...' ") %>
        <div class="col-md-2">
            <label>&nbsp;</label><br />
            <a id="filtrarprocedimento" class="btn btn-primary btn-block">
                <i class="far fa-search bigger-110"></i> Filtrar
            </a> 
        </div>
    </div>
    </div>
</div>

<div class="text-right">
    <% IF getConfig("calculostabelas") THEN %>
        <button class="btn btn-sm btn-primary" style="margin-bottom: 10px" onclick="ajxContent('ConveniosValoresProcedimentos&Recalcular=1&ConvenioID=<%=ConvenioID%>', '', '1', 'divValores')">
            Recalcular
        </button>
    <% END IF %>
</div>
<div id="tableValoresConvenio">
    <!--#include file="ConveniosValoresProcedimentosLoad.asp"-->
</div>

<div class="row text-center hidden-xs">
     <ul id="pager" class="pagination pagination-sm">
    <%
    sqlProcedimentos = "select count(*) as total from procedimentos as p "&_
                    "left join tissprocedimentosvalores as v on (v.ProcedimentoID=p.id and v.ConvenioID="&ConvenioID&") "&_
                    "left join tissprocedimentostabela as pt on (v.ProcedimentoTabelaID=pt.id)"&_
                    "where p.sysActive=1 and Ativo='on' and (v.ConvenioID="&ConvenioID&" or v.ConvenioID is null) and (isnull(SomenteConvenios) or SomenteConvenios like '%|"&ConvenioID&"|%' or SomenteConvenios like '') and (SomenteConvenios not like '%|NONE|%' or isnull(SomenteConvenios)) "
    set totalProc = db.execute(sqlProcedimentos)

    total = cint(totalProc("total"))
    steps = 0
    For t = 0 To total
        t = steps*50
        steps=steps+1
        if t <= total then
            ativo=""
            if t=0 then
                ativo = "class='active'"
            end if
            %>
            <li <%=ativo%> id="<%=t%>"><a href="#!" onclick="pageChange(<%=t%>);"><%=steps%></a></li>
            <%
        end if
    Next

    %>
  </ul>
</div>

<script language="javascript">
function editaValores(ProcedimentoID, ConvenioID,AssociacaoID){
	$.ajax({
		type:"GET",
		url:"ConvenioValores.asp?ConvenioID="+ConvenioID+"&ProcedimentoID="+ProcedimentoID+"&AssociacaoID="+(AssociacaoID?AssociacaoID:''),
		success: function(data){
			$("#modal-table").modal("show");
			$("#modal").html(data);
		}
	});
}

function clonarAssociacao(I){
    if(confirm('Tem certeza de que deseja clonar esta associação?')){
        ajxContent('ConveniosValoresProcedimentos&ConvenioID=<%=ConvenioID%>&Clonar='+I, '', '1', 'divValores');
    }
}

function removeAssociacao(I){
	if(confirm('Tem certeza de que deseja remover esta associação?')){
		ajxContent('ConveniosValoresProcedimentos&ConvenioID=<%=ConvenioID%>&X='+I, '', '1', 'divValores');
	}
}

var loadMore = 0;
var steps = 50;
function pageChange(newloadMore){
$('#pager li').removeClass('active');
$('#'+newloadMore).addClass('active');
    $.get("ConveniosValoresProcedimentosLoad.asp?ConvenioID=<%=ConvenioID%>",{
        loadMore : newloadMore
    }).done(function(data) {
        if(data!==""){
            $("#tableValoresConvenio").html(data);
        } else{
        }
    }).fail(function(data) {

    }).always(function(){
    });
}

$("#filtrarprocedimento").click(function(){
        if($("#ProcedimentoRapido").val()==''){
            $("#pager").show();
            loadMore = 0;
            pageChange(0);
        }else{
            $("#pager").hide();
            $.get("ConveniosValoresProcedimentosLoad.asp?ConvenioID=<%=ConvenioID%>&txt="+$("#ProcedimentoRapido").val(),
             function(data){
                $("#tableValoresConvenio").html(data);
            });
        }
    });

</script>