<!--#include file="connect.asp"-->
<style>
#perfil-usuarios th {
  background: white;
  position: sticky;
  top: 0;
  box-shadow: 0 2px 2px -1px rgba(0, 0, 0, 0.4);
}
</style>
<div class="_panel" id="perfil-usuarios">
    <div class="_panel-body" id="documentos-arquivo">
        <div class="row">
            <div class="col-md-12">
                Nome
                <input class="form-control input-sm" type="text" onkeyup="searchByName(this.value)"  />
            </div>
            <div class="col-md-12 mt15  table-result" style="display: none; overflow: auto; max-height: 400px">
                <table class="pesquisa-paciente table table-bordered table-condensed table-hover">
                    <thead>

                    </thead>
                    <tbody>

                    </tbody>
                </table>
            </div>

            <div class="col-md-12 mt15 loading-table" style="display: none">
              <div class="loading text-center">
                <i class="fa fa-spin fa-5x fa-circle-o-notch"></i>
              </div>
             </div>
             <div class="col-md-12 alertando mt15">

             </div>
        </div>
    </div>
</div>
<script>
var tk = localStorage.getItem("tk")
var timeSearch = null;
function searchByName(value){
    $(".table-result").hide()
    $(".loading-table").show()
     $(".alertando").html("");

    <% if isAmorSaude() then %>
        const parceiro = 'Cartao-De-Todos';
        const ans      = '140188';
    <% else %>
        const parceiro = 'DNA';
        const ans      = 'DNA';
    <% end if %>

    clearInterval(timeSearch)

    function hasNumbers(t)
    {
    var regex = /\d{3,1000}/g;
    return regex.test(t);
    }

    timeSearch = setTimeout(function(){
        var requestOptions = {
          method: 'POST',
          body: JSON.stringify({"parceiro":parceiro,"filter":{"nome":value.split(" ").join("%")+"%"}}),
          redirect: 'follow'
        };

        if(hasNumbers(value)){
             fetch(`${domain}/autorizador/elegivel/${ans}/cpf/${value}`)
            .then(response => response.json())
            .then(data => {
                     $(".loading-table").hide()

                     let dados = data && data.data && data.data.dados;

                     if(!(dados.length > 0)){
                         $(".alertando").html(`<div class="alert alert-warning" role="alert">Nenhum resultado encontrado.</div>`)
                         return ;
                     }

                      let [ths,trs] = mountTableData(title,dados);
                      $(".pesquisa-paciente thead").html(`<tr>${ths}</tr>`);
                      $(".pesquisa-paciente tbody").html(`<tr>${trs}</tr>`);
                      $(".table-result").show()
            });

        }else{
           fetch(domain+"/autorizador-tiss/consulta/by-name?tk="+tk, requestOptions)
             .then(response => response.json())
             .then(result => {
                 $(".loading-table").hide()
                 if(!(result && result.dados && result.dados.length > 0)){
                     $(".alertando").html(`<div class="alert alert-warning" role="alert">Nenhum resultado encontrado.</div>`)
                     return ;
                 }

                  let [ths,trs] = mountTableData(title,result.dados);
                  $(".pesquisa-paciente thead").html(`<tr>${ths}</tr>`);
                  $(".pesquisa-paciente tbody").html(`<tr>${trs}</tr>`);
                  $(".table-result").show()
             })
             .catch(error => {
                 $(".loading-table").hide();
                 $(".alertando").html(`<div class="alert alert-warning" role="alert">Não foi possível efetuar a pesquisa.</div>`)
           });
        }


    },700);
}

function formatDate(str){
    if(!str){
        return;
    }
    return new Date(str).toLocaleString('pt-BR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    })
}

let title =[
    {
        alias:"Nome",column:"nomeFiliado"
    },
    {
        alias:"Matrícula",column:"matricula"
    },
    {
        alias:"CPF",column:"cpf"
    },
    {
        alias:"Status",column:"statusFiliado"
    },
    {
        alias:"Titular",column:"tipoFiliado"
    },
    {
        alias:"Data de Nascimento",column:"dataNascimento",f:formatDate
    },
]

function mountTableData(titles,data){
    let ths = titles.map(item => `<th>${item.alias}</th>`).join("");

    let trs = data.map((row) => {
        return `<tr onclick='callCallRow(${JSON.stringify(row)})'>`+titles.map(col => `<td>${col.f && col.f(row[col.column]) || row[col.column]}</td>`).join("")+"</tr>";
    });
    return [ths,trs];
}

function callCallRow(arg){
    window["callRow"] && callRow(arg)
}
</script>