<!--#include file="connect.asp"-->
<!--#include file="Classes\Json.asp"-->

<%
Codigo = req("Codigo")
Local = req("Local")

IF Local = "Novo" THEN
    ConvenioID     = req("ConvenioID")
    ProcedimentoID = req("ProcedimentoID")

    sql = " SELECT                                                                                                                                                                                 "&chr(13)&_
          "         78                                                                                              as id                                                                          "&chr(13)&_
          "        ,coalesce(convenios.TabelaPadrao,convenios.TabelaCalculo)                                        as TabelaConvenioID                                                            "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.Codigo,localprocedimentos.Codigo)                        as Codigo                                                                      "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.CodigoTUSS,localprocedimentos.CodigoTUSS)                as CodigoTUSS                                                                  "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.Procedimento,localprocedimentos.Procedimento)            as Procedimento                                                                "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.Coeficiente,localprocedimentos.Coeficiente)              as Coeficiente                                                                 "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.Porte,localprocedimentos.Porte)                          as Porte                                                                       "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.CustoOperacional,localprocedimentos.CustoOperacional)    as CustoOperacional                                                            "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.Auxiliares,localprocedimentos.Auxiliares)                as Auxiliares                                                                  "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.PorteAnestesico,localprocedimentos.PorteAnestesico)      as PorteAnestesico                                                             "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.Filme,localprocedimentos.Filme)                          as Filme                                                                       "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.Incidencia,localprocedimentos.Incidencia)                as Incidencia                                                                  "&chr(13)&_
          "        ,coalesce(tabelasconveniosprocedimentos.QuantidadeCH,localprocedimentos.QuantidadeCH)            as QuantidadeCH                                                                "&chr(13)&_
          "        ,coalesce(localprocedimentos.ValorReal)                                                          as Valor                                                                       "&chr(13)&_
          " FROM convenios                                                                                                                                                                         "&chr(13)&_
          "      JOIN procedimentos                                     ON procedimentos.id = "&ProcedimentoID&"                                                                                   "&chr(13)&_
          " LEFT JOIN tabelasconveniosprocedimentos  localprocedimentos ON localprocedimentos.TabelaConvenioID*-1  = coalesce(convenios.TabelaCalculo,convenios.TabelaPadrao)                      "&chr(13)&_
          "                                                            AND COALESCE(localprocedimentos.ProcedimentoID = procedimentos.id,localprocedimentos.CodigoTuss = procedimentos.Codigo)     "&chr(13)&_
          " LEFT JOIN cliniccentral.tabelasconveniosprocedimentos       ON tabelasconveniosprocedimentos.Tabela*1 = coalesce(convenios.TabelaCalculo,convenios.TabelaPadrao)                       "&chr(13)&_
          "                                                            AND procedimentos.Codigo = tabelasconveniosprocedimentos.CodigoTuss                                                         "&chr(13)&_
          " WHERE TRUE                                                                                                                                                                             "&chr(13)&_
          " AND convenios.id = "&ConvenioID&";                                                                                                                                                     "


    response.write(recordToJSON(db.execute(sql)))

    response.end()
END IF

if Codigo<>"" then
    Response.AddHeader "Content-Type", "text/html;charset=UTF-8"


    Codigo = replace(Codigo," ","%")

    sql = " SELECT tabelasconveniosprocedimentos.*,Descricao,UCO                                                                            "&_
          " FROM cliniccentral.tabelasconveniosprocedimentos                                                                                "&_
          " JOIN cliniccentral.tabelasconvenios ON cliniccentral.tabelasconvenios.id = cliniccentral.tabelasconveniosprocedimentos.Tabela   "&_
          " WHERE Codigo LIKE '%"&Codigo&"%' OR Procedimento LIKE '%"&Codigo&"%' OR CodigoTUSS LIKE '%"&Codigo&"%' LIMIT 10              ;  "
    IF Local = "Local" THEN
            sql = " SELECT tabelasconveniosprocedimentos.*,tabelasconvenios.UCO,tabelasconvenios.Descricao FROM tabelasconveniosprocedimentos                              "&_
                  "       JOIN tabelasconvenios       ON tabelasconvenios.id = tabelasconveniosprocedimentos.TabelaConvenioID                                              "&_
                  "  LEFT JOIN tabelasconveniosportes ON tabelasconveniosportes.TabelaPorteID = tabelasconveniosprocedimentos.TabelaConvenioID                             "&_
                  "                                  AND tabelasconveniosportes.Porte = tabelasconveniosprocedimentos.Porte                                                "&_
                  " WHERE tabelasconveniosprocedimentos.Codigo LIKE '%"&Codigo&"%' OR tabelasconveniosprocedimentos.Procedimento LIKE '%"&Codigo&"%' OR CodigoTuss LIKE '%"&Codigo&"%' LIMIT 10; "
    END IF



    sql = " select * from (                                                                                                                                                                                     "&chr(13)&_
          "                   SELECT 'local' as tipo,                                                                                                                                                           "&chr(13)&_
          "                          tabelasconveniosprocedimentos.id,                                                                                                                                          "&chr(13)&_
          "                          TabelaConvenioID,                                                                                                                                                          "&chr(13)&_
          "                          Codigo,                                                                                                                                                                    "&chr(13)&_
          "                          CodigoTUSS,                                                                                                                                                                "&chr(13)&_
          "                          Procedimento,                                                                                                                                                              "&chr(13)&_
          "                          Coeficiente,                                                                                                                                                               "&chr(13)&_
          "                          tabelasconveniosprocedimentos.Porte,                                                                                                                                       "&chr(13)&_
          "                          CustoOperacional,                                                                                                                                                          "&chr(13)&_
          "                          Auxiliares,                                                                                                                                                                "&chr(13)&_
          "                          PorteAnestesico,                                                                                                                                                           "&chr(13)&_
          "                          Filme,                                                                                                                                                                     "&chr(13)&_
          "                          Valor,                                                                                                                                                                     "&chr(13)&_
          "                          Incidencia,                                                                                                                                                                "&chr(13)&_
          "                          QuantidadeCH,                                                                                                                                                              "&chr(13)&_
          "                          tabelasconvenios.Descricao,                                                                                                                                                "&chr(13)&_
          "                          tabelasconvenios.UCO                                                                                                                                                       "&chr(13)&_
          "                   FROM tabelasconveniosprocedimentos                                                                                                                                                "&chr(13)&_
          "                            JOIN tabelasconvenios ON tabelasconvenios.id = tabelasconveniosprocedimentos.TabelaConvenioID                                                                            "&chr(13)&_
          "                            LEFT JOIN tabelasconveniosportes ON tabelasconveniosportes.TabelaPorteID =                                                                                               "&chr(13)&_
          "                                                                tabelasconveniosprocedimentos.TabelaConvenioID                                                                                       "&chr(13)&_
          "                       AND tabelasconveniosportes.Porte = tabelasconveniosprocedimentos.Porte                                                                                                        "&chr(13)&_
          "  WHERE Codigo LIKE '%"&Codigo&"%' OR Procedimento LIKE '%"&Codigo&"%' OR CodigoTUSS LIKE '%"&Codigo&"%' LIMIT 10                                                                                    "&chr(13)&_
          "                                                                                                                                                                                                     "&chr(13)&_
          "               ) as j                                                                                                                                                                                "&chr(13)&_
          "      UNION ALL                                                                                                                                                                                      "&chr(13)&_
          "  select * from (                                                                                                                                                                                    "&chr(13)&_
          "  SELECT 'central' as tipo,tabelasconveniosprocedimentos.id, Tabela, Codigo, CodigoTUSS, Procedimento, Coeficiente, Porte, CustoOperacional, Auxiliares, PorteAnestesico, Filme,null, Incidencia, QuantidadeCH,Descricao,UCO"&chr(13)&_
          "  FROM cliniccentral.tabelasconveniosprocedimentos                                                                                                                                                   "&chr(13)&_
          "  JOIN cliniccentral.tabelasconvenios ON cliniccentral.tabelasconvenios.id = cliniccentral.tabelasconveniosprocedimentos.Tabela                                                                      "&chr(13)&_
          "  WHERE tabelasconveniosprocedimentos.Codigo LIKE '%"&Codigo&"%' OR tabelasconveniosprocedimentos.Procedimento LIKE '%"&Codigo&"%' OR CodigoTuss LIKE '%"&Codigo&"%'                                 "&chr(13)&_
          " limit 10) as t                                                                                                                                                                                      "

    response.write(recordToJSON(db.execute(sql)))
    response.end
end if
%>
<% call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from tabelasconvenios where id="& req("I"))
%>
<style>
  .table-absolute{
    padding: 10px;
    background: #ffffff;
    border: #dfdfdf;
    border-radius: 10px;
    position: absolute;
    z-index: 1000;
  }
  .table-absolute-content{
      overflow: auto;
      max-width: 600px;
      max-height:200px;
  }
</style>
<div class="panel">
    <div class="panel-body">
        <form method="post" id="frm" name="frm" action="save.asp">
            <%=header(req("P"), "Tabelas de Cálculo", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
            <input type="hidden" name="I" value="<%=req("I")%>" />
            <input type="hidden" name="P" value="<%=req("P")%>" />

            <div class="row">
                <%=quickField("text", "Descricao", "Descricao", 6, reg("Descricao"), "", "", " required")%>
                <%=quickField("text", "CodigoTabela", "CodigoTabela", 3, reg("CodigoTabela"), "", "", " maxlength=3 ")%>
                <%=quickField("currency", "UCO", "UCO", 3, fn(reg("UCO")), "", "", "") %>
            </div>
            <div class="row pt15">
                <div class="col-md-12">
                    <%call Subform("tabelasconveniosprocedimentos", "TabelaConvenioID", req("I"), "frm")%>
                </div>
            </div>
        </form>
    </div>
</div>
<script>
<!--#include file="jQueryFunctions.asp"-->


function formatNumber(num,fix){
    if(!num){
        return null;
    }
    return Number(num.replace(".","").replace(",",".")).toLocaleString('de-DE', {
     minimumFractionDigits: fix,
     maximumFractionDigits: fix
   });
}

function addItemTabela(arg1,arg2){

    let sugestao = sugestoes.find(e => e.id == arg2);

    if(!sugestao){
        return;
    }

    Object.keys(sugestao).forEach((s)=> {
        let tag = $("#"+arg1).parents("tr").find(`[id^='${s}-']`);
            tag.val(sugestao[s]);
        if(['Coeficiente','CustoOperacional','Filme'].indexOf(s) !== -1){
            tag.val(formatNumber(sugestao[s],4));
        }

       if(tag.prop("tagName") === 'SELECT'){
          tag.trigger("change");
       }
    });

    $(".table-absolute").remove();

}
var dentro = false;
var sugestoes = [];
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

        if(!(
            id.indexOf("Procedimento-tabelasconveniosprocedimentos") !== -1
         || id.indexOf("Codigo-tabelasconveniosprocedimentos") !== -1
         || id.indexOf("CodigoTUSS-tabelasconveniosprocedimentos") !== -1
        )){
            return false;
        }
           $(".table-absolute").remove();

           //let tr                      = $(arg.target).parents("tr");
           let componentCodigo         = $(arg.target);
           let Codigo                  = $(arg.target).val();

           if(Codigo){
               fetch(`tabelasconvenios.asp?Codigo=${Codigo}`)
               .then((data)=>{
                    return data.json();
               }).then((json) => {
                   if(!(json && json.length > 0)){
                      return ;
                   }
                   sugestoes = json;

                   let linhas = json.map((j) => {
                       return `<tr>
                                    <td>${j.Codigo}</td>
                                    <td>${j.Procedimento}</td>
                                    <td>${j.Descricao}</td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-success" onclick="addItemTabela('${componentCodigo.attr("id")}',${j.id})"><i class="fa fa-plus"></i></button>
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




$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});


</script>
<!--#include file="disconnect.asp"-->