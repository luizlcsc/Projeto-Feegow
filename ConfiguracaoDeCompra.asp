<!--#include file="connect.asp"-->
<!--#include file="Classes\JSON.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Compra");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Configuração para Aprovação de Compras");
    $(".crumb-icon a span").attr("class", "far fa-shopping-cart");
</script>

<div class="panel mt20 mtn">
    <div class="panel-body">
        <h4>Configuração de Compra</h4>
        <form id="frmOC" onsubmit="return salvarProcedimentos()" >
            <div id="main-nofitificados">
                <div class="row">
                    <div class="col-md-12"  style="margin: 15px; padding: 15px; border: #dfdfdf dashed 1px">
                        <% sql = " SELECT sys_users.id,coalesce(NomeProfissional,NomeFuncionario) as users FROM sys_users                            "&chr(13)&_
                                 " LEFT JOIN profissionais ON sys_users.`Table` = 'profissionais' AND sys_users.idInTable = profissionais.id"&chr(13)&_
                                 " LEFT JOIN funcionarios  ON sys_users.`Table` = 'Funcionarios' AND sys_users.idInTable = Funcionarios.id  "&chr(13)&_
                                 " WHERE coalesce(NomeProfissional,NomeFuncionario) IS NOT NULL                                             " %>

                         <%= quickfield("float"    , "De[0]" , "Valor De" , 1, De    ," ", " ", "") %>
                         <%= quickfield("float"    , "Ate[0]", "Valor Até", 1, Ate   ," ", " ", "") %>
                         <%= quickfield("multiple", "Categorias[0]", "Limitar Categorias", 3, Categorias,"SELECT id,Name FROM sys_financialexpensetype", "Name", "") %>
                         <%= quickfield("multiple", "Usuarios[0]", "Usuários", 3, Usuarios,sql, "users", "") %>
                         <%= quickfield("number"  , "MinProvacao[0]", "Mín. Usuários para Aprovação", 3, 1," ", "users", "") %>
                         <div  class="mt25 col-md-1">
                            <button type="button" style="width: 100%" class="btn btn-success" onclick="addNotificados()"> <i class="far fa-plus"></i></button>
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

</div>
</div>

<script type="text/javascript">
var countCombinacao = 0;

function removerRow(arg) {
    $(arg).parent().parent().parent().remove()
}

function addNotificados(valorInserido){
    countCombinacao++;

    let De = $("#main-nofitificados [name='De[0]']")[0].outerHTML;
        De = De.replace(/De\[0\]/g,"De["+ countCombinacao +"]");
        De = De.replace(/qfde\[0\]/g,"qfde["+ countCombinacao +"]");

    let Ate = $("#main-nofitificados [name='Ate[0]']")[0].outerHTML;
        Ate = Ate.replace(/Ate\[0\]/g,"Ate["+ countCombinacao +"]");
        Ate = Ate.replace(/qfate\[0\]/g,"qfate["+ countCombinacao +"]");

    let Categorias = $("#main-nofitificados [name='Categorias[0]']")[0].outerHTML;
        Categorias = Categorias.replace(/Categorias\[0\]/g,"Categorias["+ countCombinacao +"]");
        Categorias = Categorias.replace(/qfcategorias\[0\]/g,"qfcategorias["+ countCombinacao +"]");

    let Usuarios = $("#main-nofitificados [name='Usuarios[0]']")[0].outerHTML;
        Usuarios = Usuarios.replace(/Usuarios\[0\]/g,"Usuarios["+ countCombinacao +"]");
        Usuarios = Usuarios.replace(/qfusuarios\[0\]/g,"qfusuarios["+ countCombinacao +"]");

    let MinProvacao = $("#main-nofitificados [name='MinProvacao[0]']")[0].outerHTML;
        MinProvacao = MinProvacao.replace(/MinProvacao\[0\]/g,"MinProvacao["+ countCombinacao +"]");
        MinProvacao = MinProvacao.replace(/qfminprovacao\[0\]/g,"qfminprovacao["+ countCombinacao +"]");

    let html  = `<div class="row">
                     <div class="col-md-12"  style="margin: 15px; padding: 15px; border: #dfdfdf dashed 1px">
                        <div class="col-md-1 qf">
                            ${De}
                        </div>
                        <div class="col-md-1 qf">
                            ${Ate}
                        </div>
                        <div class="col-md-3 qf">
                            ${Categorias}
                        </div>
                        <div class="col-md-4 qf">
                            ${Usuarios}
                        </div>

                        <div class="col-md-2 qf">
                            ${MinProvacao}
                        </div>
                        <div  class=" col-md-1">
                            <button type="submit" style="width: 100%" class="btn btn-danger" onclick="removerRow(this)"> <i class="far fa-times"></i></button>
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

    let tagCategorias = $('#add-nofitificados > div').last().find("select.multisel");
    let tagUsuarios   = $('#add-nofitificados > div').last().find("select.multisel");

    jQuery("#MinProvacao\\["+countCombinacao+"\\]").val(1);
    if(valorInserido){
        jQuery("#De\\["+countCombinacao+"\\]").val(formatNumber(valorInserido.de,2));
        jQuery("#Ate\\["+countCombinacao+"\\]").val(formatNumber(valorInserido.ate,2));
        jQuery("#MinProvacao\\["+countCombinacao+"\\]").val(valorInserido.MinAprovacao);
        if(valorInserido.Categorias){
             jQuery("#Categorias\\["+countCombinacao+"\\]").val(valorInserido.Categorias.split(","))
             jQuery("#Categorias\\["+countCombinacao+"\\]").trigger('change')
        }
        if(valorInserido.Usuarios){
          jQuery("#Usuarios\\["+countCombinacao+"\\]").val(valorInserido.Usuarios.split(","))
          jQuery("#Categorias\\["+countCombinacao+"\\]").trigger('change')
        }
    }


    tagCategorias.multiselect(config);
    tagUsuarios.multiselect(config);

    $(".input-mask-brl").maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true, precision: 2});
}

function getValues(){
    let keys = [];

    ["De","Ate","Categorias","Usuarios","MinProvacao"].forEach((tagName) => {
        $("[name^='"+tagName+"']").each((item,tag) => {
            re = new RegExp(tagName+"\\[(.)+\\]", "g");
            let key = $(tag).attr("name").replace(re, '$1');

            if(keys.indexOf(key) === -1){
                keys.push(key);
            }
        });
    });

    let result = {};

    ["De","Ate","Categorias","Usuarios","MinProvacao"].forEach((tagName)=>{
        keys.forEach((key) => {
            $("[name='"+tagName+"["+key+"]']").each((item,tag) => {
                if(!result[key]){
                    result[key] = {};
                }
                result[key][tagName] = $(tag).val();

                if(["De","Ate"].indexOf(tagName) !== -1){
                    result[key][tagName] = $(tag).val().replace(".","").replace(",",".")
                }

            });
        });
    });

    return result;
}

var salvarProcedimentos = function(){
      fetch(domain+'api/compras/configuracao/save',{
         method:"POST",
         headers: {
                "x-access-token":localStorage.getItem("tk"),
                 'Accept': 'application/json',
                 'Content-Type': 'application/json'
         },
         body:JSON.stringify({parametros:getValues()})
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

var valoresInseridos = <%=recordToJSON(db.execute("SELECT * FROM configuracaodecompra")) %>;

function formatNumber(num,fix){
    if(!num){
        return null;
    }
    return Number(num.replace(".","").replace(",",".")).toLocaleString('de-DE', {
     minimumFractionDigits: fix,
     maximumFractionDigits: fix
   });
}


$( document ).ready(function() {
    valoresInseridos.forEach((valorInserido,key) => {
        if(key !== 0){
            addNotificados(valorInserido);
            return ;
        }
        jQuery("#De\\["+countCombinacao+"\\]").val(formatNumber(valorInserido.de,2));
        jQuery("#Ate\\["+countCombinacao+"\\]").val(formatNumber(valorInserido.ate,2));
        jQuery("#MinProvacao\\["+countCombinacao+"\\]").val(valorInserido.MinAprovacao);
        if(valorInserido.Categorias){
         jQuery("#Categorias\\["+countCombinacao+"\\]").val(valorInserido.Categorias.split(","));
         jQuery("#Categorias\\["+countCombinacao+"\\]").trigger('change');
        }
        if(valorInserido.Usuarios){
          jQuery("#Usuarios\\["+countCombinacao+"\\]").val(valorInserido.Usuarios.split(","));
          jQuery("#Categorias\\["+countCombinacao+"\\]").trigger('change');
        }
    });
});



<!--#include file="JQueryFunctions.asp"-->
</script>
