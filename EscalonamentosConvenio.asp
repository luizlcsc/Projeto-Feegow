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
                        "(SELECT 'UCO' Descricao UNION ALL SELECT 'CH' UNION ALL SELECT 'R$' UNION ALL SELECT 'Filme' UNION ALL SELECT 'Porte' UNION ALL SELECT 'Materiais' UNION ALL SELECT 'Medicamentos' UNION ALL "&_
                        "SELECT 'OPME' UNION ALL SELECT 'Taxas' UNION ALL SELECT 'Gases')  AS T"

                  %>
                 <%= quickfield("multiple", "Calculos[0]", "Cálculos", 3, Calculo,sql, "descricao", "") %>
                 <%= quickfield("multiple", "Contratos[0]", "Contratos", 3   , Contratos,"SELECT id, CodigoNaOperadora FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND sysActive = 1 AND CodigoNaOperadora <> '' ", "CodigoNaOperadora", "") %>
                 <%= quickfield("multiple", "Grupos[0]", "Grupos", 3, Planos,"SELECT * FROM procedimentosgrupos  WHERE sysActive = 1  ", "NomeGrupo", "") %>
                 <%= quickfield("multiple", "Procedimentos[0]", "Procedimentos", 3, Procedimentos, "SELECT id,NomeProcedimento FROM procedimentos WHERE Ativo = 'on' AND sysActive = 1", "NomeProcedimento", "") %>
                 <%= quickfield("multiple", "Planos[0]", "Planos", 3, Planos,"SELECT id, NomePlano FROM conveniosplanos WHERE ConvenioID = "&ConvenioID, "NomePlano", "") %>
                 <%= quickfield("multiple", "Escalonamentos[0]", "Escalonamentos", 3, Escalonamentos,"SELECT '2' id, '2º Procedimento' descricao UNION ALL SELECT  '3', '3º Procedimento' UNION ALL SELECT '4', '4º Procedimento' UNION ALL SELECT'5', '5º Procedimento' UNION ALL SELECT'6', '6º Procedimento' UNION ALL SELECT'7', '7º Procedimento' UNION ALL SELECT'8', '8º Procedimento'  UNION ALL SELECT'9', '9º Procedimento'  UNION ALL SELECT'10', '10º Procedimento' ", "descricao", "") %>
                 <div class="col-md-3">
                    <label for="Planos[0]">Tipo</label>
                    <select class="form-control" id="tipo[0]" name="tipo[0]">
                        <option value="-1">Deflator (-)</option>
                        <option value="1">Inflator (+)</option>
                    </select>
                 </div>
                  <div class="col-md-2">
                      <%=quickField("text", "valor[0]", "Valor (%)", 12, ValorCH, " sql-mask-4-digits  ", "", " ")%>
                  </div>

                 <div class="col-md-1 mt25 text-right">
                    <button type="button" class="btn btn-success w100" onclick="addNotificados(null,null)"> <i class="fa fa-plus"></i></button>
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

    let calculos = $("#main-nofitificados select")[0].outerHTML;
        calculos = calculos.replace(/Calculos\[0\]/g,"Calculos["+ countCombinacao +"]");
        calculos = calculos.replace(/qfcalculos\[0\]/g,"qfcalculos["+ countCombinacao +"]");

    let contrato = $("#main-nofitificados select")[1].outerHTML;
        contrato = contrato.replace(/Contratos\[0\]/g,"Contratos["+ countCombinacao +"]");
        contrato = contrato.replace(/qfcontratos\[0\]/g,"qfcontratos["+ countCombinacao +"]");

    let grupos = $("#main-nofitificados select")[2].outerHTML;
        grupos = grupos.replace(/Grupos\[0\]/g,"Grupos["+ countCombinacao +"]");
        grupos = grupos.replace(/qfgrupos\[0\]/g,"qfgrupos["+ countCombinacao +"]");

    let procedimentos = $("#main-nofitificados select")[3].outerHTML;
        procedimentos = procedimentos.replace(/Procedimentos\[0\]/g,"Procedimentos["+ countCombinacao +"]");
        procedimentos = procedimentos.replace(/qfprocedimentos\[0\]/g,"qfprocedimentos["+ countCombinacao +"]");

    let planos = $("#main-nofitificados select")[4].outerHTML;
        planos = planos.replace(/Planos\[0\]/g,"Planos["+ countCombinacao +"]");
        planos = planos.replace(/qfplanos\[0\]/g,"qfplanos["+ countCombinacao +"]");

    let escalonamento = $("#main-nofitificados select")[5].outerHTML;
        escalonamento = escalonamento.replace(/Escalonamentos\[0\]/g,"Escalonamentos["+ countCombinacao +"]");
        escalonamento = escalonamento.replace(/qfescalonamentos\[0\]/g,"qfescalonamentos["+ countCombinacao +"]");

    let valorCH = $("#valor\\[0\\]")[0].outerHTML;
        valorCH = valorCH.replace(/valor\[0\]/g,"valor["+ countCombinacao +"]");

    let html  = `<div class="row">
                     <div class="col-md-12"  style="margin: 15px; padding: 15px; border: #dfdfdf dashed 1px">
                        <div class="col-md-3 qf">
                            <label>Cálculo</label>
                            ${calculos}
                        </div>
                        <div class="col-md-3 qf">
                            <label>Contrato</label>
                            ${contrato}
                        </div>
                        <div class="col-md-3 qf">
                            <label>Grupos</label>
                            ${grupos}
                        </div>
                        <div class="col-md-3 qf">
                            <label>Procedimento</label>
                            ${procedimentos}
                        </div>
                        <div class="col-md-3 qf">
                            <label>Planos</label>
                            ${planos}
                        </div>
                        <div class="col-md-3 qf">
                            <label>Escalonamento</label>
                            ${escalonamento}
                        </div>
                        <div class="col-md-3">
                            <label>Tipo</label>
                            <select class="form-control" id="tipo[${countCombinacao}]" name="tipo[${countCombinacao}]">
                                <option value="-1">Deflator (-)</option>
                                <option value="1">Inflator (+)</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                             <label>Valor</label>
                             ${valorCH}
                        </div>
                        <div class="col-md-1 mt25 text-right">
                            <button type="submit" class="btn btn-danger w100" onclick="removerRow(this)"> <i class="fa fa-times"></i></button>
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

    let tagCalculo        = $('#add-nofitificados > div').last().find("select.multisel").eq(0);
    let tagContrato       = $('#add-nofitificados > div').last().find("select.multisel").eq(1);
    let tagGrupo          = $('#add-nofitificados > div').last().find("select.multisel").eq(2);
    let tagProcedimento   = $('#add-nofitificados > div').last().find("select.multisel").eq(3);
    let tagPlano          = $('#add-nofitificados > div').last().find("select.multisel").eq(4);
    let tagEscalonamento  = $('#add-nofitificados > div').last().find("select.multisel").eq(5);

    if(values){
        tagCalculo.val(values.calculos.split(","));
        tagGrupo.val(values.grupos.split(","));
        tagProcedimento.val(values.procedimentos.split(","));
        tagPlano.val(values.planos.split(","));
        tagContrato.val(values.contratos.split(","));
        tagEscalonamento.val(values.escalonamentos.split(","));

        $(`[name='tipo[${countCombinacao}]`).val(values.tipo);
        $(`[name='valor[${countCombinacao}]`).val(values.valor);
    }

    $('#add-nofitificados > div').last().find("select.multisel").multiselect(config)

    $(".sql-mask-4-digits").maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true, precision: 4});
}

function getValues(){
    let keys = [];

    ["Calculos","Planos","Procedimentos","Grupos","Escalonamentos","Contratos"].forEach((tagName) => {
        $("select[name^='"+tagName+"']").each((item,tag) => {

            re = new RegExp(tagName+"\\[(.)+\\]", "g");
            let key = $(tag).attr("name").replace(re, '$1');

            if(keys.indexOf(key) === -1){
                keys.push(key);
            }
        });
    });

    let result = {};

    ["Calculos","Planos","Procedimentos","Grupos","Escalonamentos","Contratos"].forEach((tagName)=>{
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
         result[key]["Tipo"]  = $(`[name='tipo[${key}]']`).val();
         result[key]["valor"] = $(`[name='valor[${key}]']`).val().replace(".","").replace(",",".");
    });
    return result;
}

var salvarProcedimentos = function(){
      fetch(domain+'api/convenios-escalonamento/save',{
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
    set objRec = db.execute("SELECT * FROM conveniosescalonamento WHERE ConvenioID = "&ConvenioID&" ORDER BY 1 ASC ")

    While Not objRec.EOF
    %>
    resultados.push({
       tipo:         '<%=objRec("tipo") %>',
       valor:        '<% if not isnull(objRec("valor")) then
                            response.write(formatnumber(objRec("valor"),4))
                        end if %>',
       grupos:       '<%=objRec("grupos") %>',
       planos:       '<%=objRec("planos") %>',
       calculos:     '<%=objRec("calculos") %>',
       contratos:     '<%=objRec("contratos") %>',
       escalonamentos:     '<%=objRec("escalonamento") %>',
       procedimentos:'<%=objRec("procedimentos") %>'
    });
    <%
      objRec.MoveNext
    Wend
%>

let i = 0;
resultados.map((key) => {
    if(i == 0){
        i++;
           jQuery("#Calculos\\[0\\]").val(key.calculos.split(","));
           jQuery("#Planos\\[0\\]").val(key.planos.split(","));
           jQuery("#Grupos\\[0\\]").val(key.grupos.split(","))
           jQuery("#Procedimentos\\[0\\]").val(key.grupos.split(","))
           jQuery("#Contratos\\[0\\]").val(key.contratos.split(","))
           jQuery("#Escalonamentos\\[0\\]").val(key.escalonamentos.split(","))
           jQuery("#tipo\\[0\\]").val(key.tipo)
           jQuery("#valor\\[0\\]").val(key.valor);

           return;
    }

    addNotificados(key);
});

<!--#include file="JQueryFunctions.asp"-->
</script>
