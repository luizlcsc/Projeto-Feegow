<!--#include file="connect.asp"-->
<%
ConvenioID = req("ConvenioID")
%>
<form id="frmOC" onsubmit="return salvarProcedimentos()" >
    <div id="main-nofitificados">
        <div class="row">
            <div class="col-md-12"  style="margin: 15px; padding: 15px; border: #dfdfdf dashed 1px">
                 <%
                  sql = "SELECT descricao, descricao AS id FROM "&_
                        "(SELECT 'ISS' Descricao UNION ALL SELECT 'PIS' UNION ALL SELECT 'CSSL' UNION ALL SELECT 'IR' UNION ALL SELECT 'COFINS' UNION ALL SELECT 'OUTROS')  AS T"
                  %>
                 <%= quickfield("multiple", "Impostos[0]" , "Imposto"   , 2, Imposto,sql, "descricao", "") %>
                 <%= quickfield("multiple", "Contratos[0]", "Contratos" , 3, Contratos,"SELECT id, CodigoNaOperadora FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND sysActive = 1 AND CodigoNaOperadora <> '' ", "CodigoNaOperadora", "") %>
                 <%=quickField("text"     , "valor[0]"    , "Valor" , 2, valor, " sql-mask-4-digits  ", "", " ")%>
                 <%=quickField("text"     , "de[0]"       , "De " , 2, de, " sql-mask-4-digits  ", "", " ")%>
                 <%=quickField("text"     , "ate[0]"      , "Até" , 2, ate, " sql-mask-4-digits  ", "", " ")%>
                 <div class="col-md-1 mt25 text-right">
                    <button type="button" class="btn btn-success w100" onclick="addNotificados(null,null)"> <i class="far fa-plus"></i></button>
                 </div>
            </div>
        </div>
    </div>

    <div id="add-nofitificados">

    </div>
    <div class="text-right">
        <button type="submit" class="btn btn-success btn-sm">Salvar</button>
    </div>
</form>

<script type="text/javascript">
var countCombinacao = 0;

function removerRow(arg) {
    $(arg).parent().parent().parent().remove()
}

function addNotificados(values){
    countCombinacao++;

    let impostos = $("#main-nofitificados select")[0].outerHTML;
        impostos = impostos.replace(/Impostos\[0\]/g,"Impostos["+ countCombinacao +"]");
        impostos = impostos.replace(/qfimpostos\[0\]/g,"qfimpostos["+ countCombinacao +"]");

    let contratos = $("#main-nofitificados select")[1].outerHTML;
        contratos = contratos.replace(/Contratos\[0\]/g,"Contratos["+ countCombinacao +"]");
        contratos = contratos.replace(/qfcontratos\[0\]/g,"qfcontratos["+ countCombinacao +"]");

    let valor = $("#valor\\[0\\]")[0].outerHTML;
        valor = valor.replace(/valor\[0\]/g,"valor["+ countCombinacao +"]");

    let de = $("#de\\[0\\]")[0].outerHTML;
        de = de.replace(/de\[0\]/g,"de["+ countCombinacao +"]");

    let ate = $("#ate\\[0\\]")[0].outerHTML;
        ate = ate.replace(/ate\[0\]/g,"ate["+ countCombinacao +"]");


    let html  = `<div class="row">
                     <div class="col-md-12"  style="margin: 15px; padding: 15px; border: #dfdfdf dashed 1px">
                        <div class="col-md-2 qf">
                            <label>Impostos</label>
                            ${impostos}
                        </div>
                        <div class="col-md-3 qf">
                            <label>Contrato</label>
                            ${contratos}
                        </div>
                        <div class="col-md-2 qf">
                            <label>Valor</label>
                            ${valor}
                        </div>
                        <div class="col-md-2 qf">
                            <label>De</label>
                            ${de}
                        </div>
                        <div class="col-md-2 qf">
                            <label>Até</label>
                            ${ate}
                        </div>
                        <div class="col-md-1 mt25 text-right">
                            <button type="submit" class="btn btn-danger w100" onclick="removerRow(this)"> <i class="far fa-times"></i></button>
                        </div>
                     </div>
                  </div>`;

    $("#add-nofitificados").append(html);

    let config = {
                    enableFiltering: true,
                    enableCaseInsensitiveFiltering: true,
                    filterPlaceholder: 'Filtrar ...',
                    allSelectedText: 'Todos Selecionados',
                    maxHeight: 200,
                    numberDisplayed: 3,
                    includeSelectAllOption: true
    };

    let tagImposto        = $('#add-nofitificados > div').last().find("select.multisel").eq(0);
    let tagContrato       = $('#add-nofitificados > div').last().find("select.multisel").eq(1);

    if(values){
        tagImposto.val(values.impostos.split(","));
        tagContrato.val(values.contratos.split(","));

        $(`[name='valor[${countCombinacao}]`).val(values.valor);
        $(`[name='de[${countCombinacao}]`).val(values.de);
        $(`[name='ate[${countCombinacao}]`).val(values.ate);
    }

    $('#add-nofitificados > div').last().find("select.multisel").multiselect(config)

    $(".sql-mask-4-digits").maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true, precision: 4});
}

function getValues(){
    let keys = [];

    ["Impostos","Contratos"].forEach((tagName) => {
        $("select[name^='"+tagName+"']").each((item,tag) => {
            re = new RegExp(tagName+"\\[(.)+\\]", "g");
            let key = $(tag).attr("name").replace(re, '$1');

            if(keys.indexOf(key) === -1){
                keys.push(key);
            }
        });
    });

    let result = {};

    ["Impostos","Contratos"].forEach((tagName)=>{
        keys.forEach((key) => {
            $("select[name='"+tagName+"["+key+"]']").each((item,tag) => {
                if(!result[key]){
                    result[key] = {};
                }
                result[key][tagName] = $(tag).val();
            });
        });
    });


    keys.forEach((key) => {
         result[key]["valor"]  = $(`[name='valor[${key}]']`).val();
         result[key]["de"] = $(`[name='de[${key}]']`).val().replace(".","").replace(",",".");
         result[key]["ate"] = $(`[name='ate[${key}]']`).val().replace(".","").replace(",",".");
    });
    return result;
}

var salvarProcedimentos = function(){
      fetch(domain+'api/convenios-impostos/save',{
         method:"POST",
         headers: {
                "x-access-token":localStorage.getItem("tk"),
                 'Accept': 'application/json',
                 'Content-Type': 'application/json'
         },
         body:JSON.stringify({parametros:getValues(),convenio:<%=ConvenioID%>})
      }).then(() => {
             new PNotify({
                  title: 'Sucesso!',
                  text: 'Dados cadastrados com sucesso.',
                  type: 'success',
                  delay: 2500
              });
      });

      return false;
};

var resultados = [];

<%
    set objRec = db.execute("SELECT * FROM impostos_associacao WHERE  AssociationID=6 and AccountID="&ConvenioID&" ORDER BY 1 ASC ")

    While Not objRec.EOF
    %>
    resultados.push({
       impostos:  '<%=objRec("impostos") %>',
       contratos: '<%=objRec("contratos") %>',
       valor:     '<% if not isnull(objRec("valor")) then
                            response.write(formatnumber(objRec("valor"),4))
                  end if %>',
       de:        '<% if not isnull(objRec("de")) then
                                  response.write(formatnumber(objRec("de"),4))
                  end if %>',
       ate:       '<% if not isnull(objRec("ate")) then
                                  response.write(formatnumber(objRec("ate"),4))
                  end if %>'
    });
    <%
      objRec.MoveNext
    Wend
%>

let i = 0;
resultados.map((key) => {
    if(i == 0){
        i++;
           jQuery("#Impostos\\[0\\]").val(key.impostos.split(","));
           jQuery("#Contratos\\[0\\]").val(key.contratos.split(","))
           jQuery("#valor\\[0\\]").val(key.valor);
           jQuery("#ate\\[0\\]").val(key.ate);
           jQuery("#de\\[0\\]").val(key.de);

           return;
    }

    addNotificados(key);
});

<!--#include file="JQueryFunctions.asp"-->
</script>