<!--#include file="connect.asp"-->
<%
ConvenioID = req("ConvenioID")
%>
<form id="frmOC" onsubmit="return salvarProcedimentos()" >
    <div id="main-nofitificados">
        <div class="row"  style="margin: 15px; padding: 15px; border: #dfdfdf dashed 1px">
            <div class="col-md-12" >
                 <%
                  sql = "SELECT descricao, descricao AS id FROM "&_
                        "(SELECT 'UCO' Descricao UNION ALL SELECT 'CH' UNION ALL SELECT 'R$' UNION ALL SELECT 'Filme' UNION ALL SELECT 'Porte' UNION ALL SELECT 'Materiais' UNION ALL SELECT 'Medicamentos' UNION ALL "&_
                        "SELECT 'OPME' UNION ALL SELECT 'Taxas' UNION ALL SELECT 'Gases')  AS T"

                  sqlContratado = " SELECT CONCAT(contratosconvenio.id,'') AS id,CONCAT(CodigoNaOperadora,' - ',NomeContratado) as Contratado FROM (                "&chr(13)&_
                                  " select 0 as id,NomeFantasia as NomeContratado from empresa                                      "&chr(13)&_
                                  " UNION ALL                                                                                      "&chr(13)&_
                                  " select id*-1,NomeFantasia from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1"&chr(13)&_
                                  " UNION ALL                                                                                      "&chr(13)&_
                                  " select id, NomeProfissional from profissionais where sysActive=1) t                            "&chr(13)&_
                                  " JOIN contratosconvenio ON contratosconvenio.Contratado = t.id                                  "&chr(13)&_
                                  " WHERE ConvenioID = "&ConvenioID&"                                                              "

                  %>
              
                 <%= quickfield("multiple", "Calculos[0]", "Cálculos", 3, Calculo, sql, "descricao",  "onchange=""ocultar_campos($(this).data('key'))"" teste2 ")%>
                
 

                 <div id="medic0" style="display:none;">

                    <div class="col-md-3">
                        <label for="tabela[0]">Tabela</label>
                        <select class="form-control" id="tabela[0]" name="tabela[0]">
                            <option value="">Selecione</option>
                            <option value="|Brasindice|">Brasindice</option>
                            <option value="|Simpro|">Simpro</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label for="preco[0]">Preço</label>
                        <select class="form-control" id="preco[0]" name="preco[0]">
                            <option value="|PFB|">PFB</option>
                            <option value="|PMC|">PMC</option>
                        </select>
                    </div>

                    <%= produtos %>
                    <div id="produtoWarper" class="col-md-3">
                    
                    </div>
                 </div>

                 <%= quickfield("multiple", "Grupos[0]", "Grupos", 3, Planos,"SELECT * FROM procedimentosgrupos  WHERE sysActive = 1  ", "NomeGrupo", "") %>
                 <%= quickfield("multiple", "Procedimentos[0]", "Procedimentos", 3, Procedimentos, "SELECT id,NomeProcedimento FROM procedimentos WHERE Ativo = 'on' AND sysActive = 1", "NomeProcedimento", "") %>
                 <%= quickfield("multiple", "Planos[0]", "Planos", 3, Planos,"SELECT id, NomePlano FROM conveniosplanos WHERE ConvenioID = "&ConvenioID, "NomePlano", "") %>
            </div>
            <div class="col-md-12 mt10">
                 <%= quickfield("multiple", "Contratados[0]", "Contratados", 3, "",sqlContratado, "Contratado", "") %>
                 <%= quickfield("multiple", "Vias[0]", "Vias", 3, "","select * from tissvia order by descricao", "descricao", "") %>
                 <div class="col-md-3">
                    <label for="Planos">Tipo</label>
                    <select class="form-control" id="tipo[0]" name="tipo[0]">
                        <option value="-1">Deflator (-)</option>
                        <option value="1">Inflator (+)</option>
                    </select>
               
               
                 </div>
              
                

                
                  <div class="col-md-2">
                      <%=quickField("text", "valor[0]", "Valor (%)", 12, ValorCH, " sql-mask-4-digits  ", "", " ")%>
                  </div>
                   
                <div class="col-md-1">
                      <label>&nbsp;</label>
                      <br/>
                     <button type="button" class="btn btn-block btn-success" onclick="addNotificados(null,null)"> <i class="far fa-plus"></i></button>
                </div>

            </div>
        </div>
    </div>

    <div id="add-nofitificados">

    </div>
<!--    <div class="text-right">-->
<!--        <button type="submit" class="btn btn-success btn-sm">Salvar</button>-->
<!--    </div>-->
</form>

<script type="text/javascript">
    




  

var countCombinacao = 0;
var Count = 0;

function removerRow(arg) {
    $(arg).parent().parent().parent().remove()
}

function addNotificados(values){
    countCombinacao++;
 

    let calculos = $("#main-nofitificados select")[0].outerHTML;
        calculos = calculos.replace(/Calculos\[0\]/g,"Calculos["+ countCombinacao +"]");
        calculos = calculos.replace(/qfcalculos\[0\]/g,"qfcalculos["+ countCombinacao +"] ");
        calculos = calculos.replace("ocultar_campos(0)","ocultar_campos("+ countCombinacao +")");
        calculos = calculos.replace("teste2","data-key=\""+countCombinacao+"\"");
      
      
    let preco = $("#main-nofitificados select")[2].outerHTML;
        preco = preco.replace(/preco\[0\]/g,"preco["+ countCombinacao +"]");
        preco = preco.replace(/qfpreco\[0\]/g,"qfpreco["+ countCombinacao +"]");

    let tabela = $("#main-nofitificados select")[1].outerHTML;
        tabela = tabela.replace(/tabela\[0\]/g,"tabela["+ countCombinacao +"]");
        tabela = tabela.replace(/qftabela\[0\]/g,"qftabela["+ countCombinacao +"]");

    let produto = $("#main-nofitificados select")[3].outerHTML;
        produto = produto.replace(/Produtos\[0\]/g,"Produtos["+ countCombinacao +"]");
        produto = produto.replace(/qfprodutos\[0\]/g,"qfprodutos["+ countCombinacao +"]");

    let grupos = $("#main-nofitificados select")[4].outerHTML;
        grupos = grupos.replace(/Grupos\[0\]/g,"Grupos["+ countCombinacao +"]");
        grupos = grupos.replace(/qfgrupos\[0\]/g,"qfgrupos["+ countCombinacao +"]");

    let procedimentos = $("#main-nofitificados select")[5].outerHTML;
        procedimentos = procedimentos.replace(/Procedimentos\[0\]/g,"Procedimentos["+ countCombinacao +"]");
        procedimentos = procedimentos.replace(/qfprocedimentos\[0\]/g,"qfprocedimentos["+ countCombinacao +"]");

    let planos = $("#main-nofitificados select")[6].outerHTML;
        planos = planos.replace(/Planos\[0\]/g,"Planos["+ countCombinacao +"]");
        planos = planos.replace(/qfplanos\[0\]/g,"qfplanos["+ countCombinacao +"]");

    let contratados = $("#main-nofitificados select")[7].outerHTML;
        contratados = contratados.replace(/Contratados\[0\]/g,"Contratados["+ countCombinacao +"]");
        contratados = contratados.replace(/qfcontratados\[0\]/g,"qfcontratados["+ countCombinacao +"]");

    let vias = $("#main-nofitificados select")[8].outerHTML;
        vias = vias.replace(/Vias\[0\]/g,"Vias["+ countCombinacao +"]");
        vias = vias.replace(/qfvias\[0\]/g,"qfvias["+ countCombinacao +"]");

        


    let valorCH = $("#valor\\[0\\]")[0].outerHTML;
        valorCH = valorCH.replace(/valor\[0\]/g,"valor["+ countCombinacao +"]");

    let html  = `<div class="row" style="margin: 15px; padding: 15px; border: #dfdfdf dashed 1px" >
                     <div class="col-md-12 calculos" data-key="${countCombinacao}">
                        <div class="col-md-3 qf" data-key="${countCombinacao}">
                            <label>Cálculos</label>
                            ${calculos}
                   
                        </div>
                            
                        <div id="medic${countCombinacao}" style="display:none;">
                      
                            <div class="col-md-3">
                                <label>Tabela</label>
                                ${tabela}
                            </div>

                            <div class="col-md-3">
                                <label>Preço</label>
                                ${preco}
                            </div>

                            <div class="col-md-3 qf">
                                <label>Materiais e Medicamentos</label>
                                ${produto}
                            </div>

                        </div>

                        <div class="col-md-3 qf">
                            <label>Grupos</label>
                            ${grupos}
                        </div>
                        <div class="col-md-3 qf">
                            <label>Procedimentos</label>
                            ${procedimentos}
                        </div>
                        <div class="col-md-3 qf">
                            <label>Planos</label>
                            ${planos}
                        </div>

                     </div>
                     <div class="col-md-12 mt10"  >
                        <div class="col-md-3 qf">
                            <label>Contratados</label>
                            ${contratados}
                        </div>
                        <div class="col-md-3">
                            <label>Vias</label>
                             ${vias}
                        </div>

                    
                        <div class="col-md-3">
                            <label>Tipo</label>
                            <select class="form-control" id="tipo[${countCombinacao}]" name="tipo[${countCombinacao}]">
                                <option value="-1">Deflator (-)</option>
                                <option value="1">Inflator (+)</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label>Valor (%)</label>
                             ${valorCH}
                        </div>
                        <div  class="col-md-1">
                            <label>&nbsp;</label>

                            <button type="submit" class="btn btn-block btn-danger" onclick="removerRow(this)"> <i class="far fa-times"></i></button>
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

    let tagCalculo      = $('#add-nofitificados > div').last().find("select.multisel").eq(0);
    let tagGrupo        = $('#add-nofitificados > div').last().find("select.multisel").eq(2);
    let tagProcedimento = $('#add-nofitificados > div').last().find("select.multisel").eq(3);
    let tagPlano        = $('#add-nofitificados > div').last().find("select.multisel").eq(4);
    let tagContratado   = $('#add-nofitificados > div').last().find("select.multisel").eq(5);
    let tagVias         = $('#add-nofitificados > div').last().find("select.multisel").eq(6);
    let tagProduto      = $('#add-nofitificados > div').last().find("select.multisel").eq(1);
    let tagTabela       = $('#add-nofitificados > div').last().find("select").eq(1);
    let tagPreco        = $('#add-nofitificados > div').last().find("select").eq(2);


    if(values){
        tagCalculo.val(values.calculos.split(","));
        tagGrupo.val(values.grupos.split(","));
        tagProcedimento.val(values.procedimentos.split(","));
        tagPlano.val(values.planos.split(","));
        tagContratado.val(values.contratados.split(","));
        tagVias.val(values.vias.split(","));
        tagTabela.val(values.tabela);
        tagPreco.val(values.preco);
        tagProduto.val(values.produtos.split(","));

        $(`[name='tipo[${countCombinacao}]`).val(values.tipo);
        $(`[name='valor[${countCombinacao}]`).val(values.valor);
    }

    tagCalculo.multiselect(config);
    tagGrupo.multiselect(config);
    tagProcedimento.multiselect(config);
    tagPlano.multiselect(config);
    tagContratado.multiselect(config);
    tagVias.multiselect(config);
    tagProduto.multiselect(config);

    $(".sql-mask-4-digits").maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true, precision: 4});
}

function getValues(){
    let keys = [];

    ["Contratados","Calculos","Planos","Procedimentos","Grupos","Vias","preco","tabela","Produtos"].forEach((tagName) => {
        $("select[name^='"+tagName+"']").each((item,tag) => {
           
            re = new RegExp(tagName+"\\[(.)+\\]", "g");
            let key = $(tag).attr("name").replace(re, '$1');

            if(keys.indexOf(key) === -1){
                keys.push(key);
            }
        });
    });


    let result = {};
    let errors = [];
    ["Contratados","Calculos","Planos","Procedimentos","Grupos","Vias","preco","tabela","Produtos"].forEach((tagName)=>{
        keys.forEach((key) => {
           
            $("select[name='"+tagName+"["+key+"]']").each((item,tag) => {
                if(!result[key]){
                    result[key] = {};
                }
                let isvalid = validCampos(key,tagName,$(tag).val());
                if(isvalid!="")
                    errors.push(isvalid)
                result[key][tagName] = $(tag).val();
            });
        });
    });

    keys.forEach((key) => {
      
        let isvalid = validCampos(key,"Tipo",$(`[name='tipo[${key}]']`).val())
        if(isvalid != "")
            errors.push(isvalid)

        isvalid = validCampos(key,"valor",$(`[name='valor[${key}]']`).val())
        if(isvalid != "")
            errors.push(isvalid)

        result[key]["Tipo"]  = $(`[name='tipo[${key}]']`).val();
        result[key]["valor"] = $(`[name='valor[${key}]']`).val().replace(".","").replace(",",".");
         
       


    });

    if(errors.length>0)
        result.errors = errors;

    return result;
}

function validCampos(itemIndex,campo,valor){
    let RequiredCampos = ["Calculos","valor"];
    if(RequiredCampos.includes(campo))
    {
        if (valor=="" ||valor == null)
           return "o campo "+campo+" do item "+(parseInt( itemIndex)+1)+" deve ser preenchido";
    }
    return "";

}

$('#save').replaceWith($('#save').clone());
$("#save").on('click',() => salvarProcedimentos());

var salvarProcedimentos = function(){

    if(!$("#divValoresPlanos").is(':visible')){
    return ;
    }
    let values = getValues();
    if( values.hasOwnProperty('errors')){
        for (const error of values.errors) {
            new PNotify({
                title: 'Atenção!',
                text: error,
                type: 'warning',
                delay: 2500
            });
        }
        return;
    }
      fetch(domain+'api/convenios-modificadores/save',{
         method:"POST",
         headers: {
                "x-access-token":localStorage.getItem("tk"),
                 'Accept': 'application/json',
                 'Content-Type': 'application/json'
         },
         body:JSON.stringify({parametros:values,convenio:<%=ConvenioID%>})
      }).then(data => data.json()).then( jsonData => {
          const result = jsonData;
         
          if(result.status === "error"){
             new PNotify({
                  title: 'Atenção!',
                  text: result.msg,
                  type: 'warning',
                  delay: 2500
              }); 
          }else if(result.status === "success")
             {
             new PNotify({
                  title: 'Sucesso!',
                  text: 'Dados cadastrados com sucesso.',
                  type: 'success',
                  delay: 2500
              });
            }
      });

      return false;
};

var resultados = [];

<%
    set objRec = db.execute("SELECT * FROM conveniosmodificadores WHERE ConvenioID = "&ConvenioID)

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
       procedimentos:'<%=objRec("procedimentos") %>',
       contratados   :'<%=objRec("contratados") %>',
       vias          :'<%=objRec("vias") %>',    
       tabela          :'<%=objRec("tabela") %>',
       preco          :'<%=objRec("preco") %>',
       produtos: '<%=objRec("produtos") %>',
    });
    <%
      objRec.MoveNext
    Wend
%>


let i = 0;

count = resultados.length;

resultados.map((key) => { 
  
    if(i == 0){
        

       i++
        jQuery("#Contratados\\[0\\]").val(key.contratados.split(","));
        jQuery("#Calculos\\[0\\]").val(key.calculos.split(","));
        jQuery("#preco\\[0\\]").val(key.preco);
        jQuery("#tabela\\[0\\]").val(key.tabela);
             
        jQuery("#Planos\\[0\\]").val(key.planos.split(","));
        jQuery("#Grupos\\[0\\]").val(key.grupos.split(","));
        jQuery("#Procedimentos\\[0\\]").val(key.procedimentos.split(","));
        jQuery("#tipo\\[0\\]").val(key.tipo.split(","));
        jQuery("#valor\\[0\\]").val(key.valor.split(","));
        jQuery("#Vias\\[0\\]").val(key.vias.split(","));
        jQuery("#Produtos\\[0\\]").val(key.produtos.split(","));

        
        return;
    }  
    addNotificados(key);
});    
         
    
function ocultar_campos(id){
    var id = (id === undefined  ? '0' : id);  
    var qf = document.querySelectorAll('INPUT'); 
  
    var ar = '#medic'+id+'';
    var cr = '#Calculos\\['+id+'\\]';
    let conteudo = $(cr).val(); 
    
    conteudo = (conteudo=== null  ? ' ' : conteudo);  

    if (conteudo.includes("|Materiais|") || conteudo.includes("|Medicamentos|"))
    { 
        let tipo = getSelectedCalculo(conteudo)
        getSelect(tipo)

        $('#preco\\['+id+'\\]').val("|PFB|");
        $('#tabela\\['+id+'\\]').val("");
        
        $(ar).show();
    }  else{
        $('#preco\\['+id+'\\]').val(" ");
        $('#tabela\\['+id+'\\]').val(" ");
      
         $(ar).hide();
    }
}

function getSelect(id){
    $.get("ValoresPlanosContratadoGetProduto.asp?tipo=" + id, function (data) {
        console.log(data)
            $("#produtoWarper").html(data);
    });
}

function getSelectedCalculo(conteudo){
    tipo = false
    if(conteudo.includes("|Materiais|") && !conteudo.includes("|Medicamentos|")){
            tipo = 3
    }else if (conteudo.includes("|Medicamentos|") && !conteudo.includes("|Materiais|")){
            tipo = 4
    }else if (conteudo.includes("|Medicamentos|") && conteudo.includes("|Materiais|")){
            tipo = 0 
    }
    return tipo
}

$(document).ready(()=>{
    let conteudo = $("select[id^='Calculos']").val()
    conteudo = (conteudo=== null  ? ' ' : conteudo);
    let selecionado = getSelectedCalculo(conteudo)
    if(selecionado){
        getSelect(selecionado)
    }
})

 <%
     contador  = 0
     if not objRec.bof then
         objRec.movefirst
     end if
     While Not objRec.EOF 

        recCalculos = objRec("calculos")
        if InStr(recCalculos, "Medicamentos") or InStr(recCalculos, "Materiais") then
           response.write ("$('#medic"&contador&"').show();")
        end if

        contador  = contador + 1
        objRec.MoveNext
     wend 
  %>
a=-1;
resultados.map((key) => { 
    a++;
    console.log(a)
jQuery("#preco\\["+a+"\\]").val(key.preco);
jQuery("#tabela\\["+a+"\\]").val(key.tabela);

});
a--;

<!--#include file="JQueryFunctions.asp"-->
</script>
