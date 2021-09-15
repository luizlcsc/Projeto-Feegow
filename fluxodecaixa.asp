<!--#include file="connect.asp"-->
<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script src="assets/js/cmc7.js"></script>
<script src="assets/js/date-time/moment.min.js"></script>
<script type="text/javascript">
    $(".crumb-active").html("<a href='#'>Financeiro</a>");
    $(".crumb-icon a span").attr("class", "far fa-money");
    $(".crumb-trail").removeClass("hidden");
    $(".crumb-trail").html("Fluxo de Caixa");
</script>

<style>
    #fluxo-de-caixa-main h2{
        margin: 0px 0px 10px 0px;
    }

    .btn-outline-secondary{color:#6c757d;background-color:transparent;background-image:none;border-color:#6c757d;}
    .btn-outline-secondary:hover{color:#fff;background-color:#6c757d;border-color:#6c757d;}
    .btn-outline-secondary:focus{box-shadow:0 0 0 .2rem rgba(108,117,125,.5);}
    .btn-outline-secondary:disabled{color:#6c757d;background-color:transparent;}

    .formatoHorizontal.ativo,.formatoVertical.ativo,.formatoSemanal.ativo{
        background-color:#cCCCCC !important;
        color: #333333 !important;
    }
    .header-tr-tipo{
        border-top: 12px solid #ffff;
    }

    .Previsto{
        background-color:#cCCCCC !important;
                color: #333333 !important;
    }

    .Realizado{
     background-color:#cCCCCC !important;
             color: #333333 !important;
    }
    .header-tr td,.header-tr th,.header-tr{
        background-color:#cCCCCC !important;
        color: #333333 !important;
    }

    .loading-cubo{
      background-image: url('assets/img/gif_cubo_alpha.gif');
      background-repeat: no-repeat;
      background-position: center;
      height: 600px;
    }

    .entradas td{
            background-color:#cad1fb !important;
    }

    .entradas td.Realizado{
            background-color:#a4abd2 !important;
    }

    .entradas.header-tr-tipo td{
        background-color:#8196b7 !important;
        color: #000000;
        padding-left: 15px;
    }
    .entradas .header-tr{
        background-color:#a4abd2 !important;
        padding-left: 15px;
    }


    .saidas td{
            background-color:#fbe9e5 !important;
    }

    .saidas td.Realizado{
            background-color:#cfbdb9 !important;
    }

    .saidas.header-tr-tipo td{
        background-color:#b38882 !important;
        color: #000000;
        padding-left: 15px;
    }
    .saidas .header-tr{
        background-color:#cfbdb9 !important;
        padding-left: 15px;
    }



    th,td{
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      text-align: center;
    }
    select,option{
        text-align: center;
        text-align-last:center;
    }
    .container-flex {
    	justify-content: center;
    	max-width: 66%;
    	margin: 0 auto;
    	display: flex;
    }
    .formatoSemanalFiltros{
        display: none;
    }
    .item {
        width: 50%;
    	margin: 5px;
    	padding: 0 10px;
    	text-align: center;
    	font-size: 1.5em;
    }
</style>
<div class="tabbable panel" id="fluxo-de-caixa-main">
    <div  class="tab-content panel-body" >
        <h2>Fluxo de Caixa</h2>
        <div class="row">
            <div class="col-md-2">
                <label>Data Início</label>
                <input type="date" class="form-control" id="data-inicio">
            </div>
            <div class="col-md-2">
                <label>Data Fim</label>
                <input type="date" class="form-control" id="data-fim">
            </div>
            <div class="col-md-2">
                <label>&nbsp;</label>
                <button class="btn btn-success" onclick="loadDados()" style="width: 100%">
                    <i class="far fa-search"></i>
                    Pesquisar
                </button>
            </div>
        </div>
        <div style="margin: 10px 0px; text-align: right">
            <button class="btn btn-sm btn-outline-secondary formatoHorizontal" onclick="alterarFormato('formatoHorizontal')">Horizontal</button>
        </div>
        <div class="formatoSemanalFiltros">
            <div style="margin-top: 10px;margin-bottom: 10px" class="container-flex" >
                <div class="item ano">

                </div>
                <div class="item mes">

                </div>
            </div>
        </div>

        <div id="fluxo-de-caixa" style="overflow: auto">
            <div class="loading-cubo"></div>
        </div>
    </div>
</div>
<script>

    var formatoSelecionado = "formatoHorizontal";
    var dadosTabela = [];
    var mesesDescricao = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
    var anosMeses = {};
    var FormaPagamento = [];
    var DataPagamento  = [];
    var PrimeiraData  = null;
    var ano         = null;
    var mes         = null;


    function alterarFormato(formato){
        $(".formatoHorizontal,.formatoVertical,.formatoSemanal").removeClass("ativo");
        $(`.${formato}`).addClass("ativo");
        formatoSelecionado = formato;
        atualizaTabela();
    }


    loadDados = ()=>{
        let inicio = $("#data-inicio").val();
        let fim = $("#data-fim").val();
        $("#fluxo-de-caixa").html(`<div class="loading-cubo"></div>`);

        //let tk = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWNjZXNzIjp0cnVlLCJ1c2VySWQiOjgzMjA3LCJsaWNlbnNlSWQiOjU5NjgsImRhdGV0aW1lIjoiMjAxOS0xMS0xNCAxNzoyNjowMCIsInZhbGlkX3VudGlsIjoiMjAxOS0xMS0xNSAwNToyNjowMCJ9.T4FtrJCQLWhiJltGeLP5vlDL9YA61a9RzYU78C9jyaU";
        let tk = localStorage.getItem("tk");

        fetch(domain+`api/fluxo-de-caixa/dados?dataInicio=${inicio}&dataFim=${fim}&tk=`+tk,{
             headers: {
                    "x-access-token":tk,
                     'Accept': 'application/json',
                     'Content-Type': 'application/json'
             }
             }).then((data) => {
               	return data.json();
             }).then((dados) => {
                dadosTabela = [];
                anosMeses = {};
                FormaPagamento = [];
                DataPagamento  = [];
                Categorias      = [];
                PrimeiraData  = null;
                ano         = null;
                mes         = null;

                dadosTabela = dados.result;
                PorPlanoDeContas = dados.PorPlanoDeContas;

                dados.PorPlanoDeContas.forEach((data) => {
                      if(Categorias.indexOf(data.Categoria) === -1){
                          Categorias.push(data.Categoria);
                      }
                });

                dados.result.forEach((data) => {
                    if(FormaPagamento.indexOf(data.FormaPagamento) === -1){
                        FormaPagamento.push(data.FormaPagamento);
                    }
                    if(DataPagamento.indexOf(data.DataPagamento) === -1){
                        DataPagamento.push(data.DataPagamento);
                    }

                    dataPga = moment(data.DataPagamento);

                    if(!anosMeses[dataPga.year()]){
                        anosMeses[dataPga.year()] = {};
                    }
                    anosMeses[dataPga.year()][dataPga.month()] = dataPga;
                });

                primeiraData = moment(DataPagamento[0]);

                ano = primeiraData.year();
                mes = primeiraData.month();
                DataPagamento.sort();
                preecheAnos();
                preecheMeses();
                atualizaTabela();
             });
    }

    changeAnos = (_ano) =>{
        ano = _ano;
        mes = Number(Object.keys(anosMeses[ano])[0]);
        preecheMeses();
        atualizaTabela();
    }

    changeMeses = (_mes) =>{
        mes = _mes;
        atualizaTabela();
    }

    preecheAnos = () =>{
          let anos = "<select class='form-control' onchange='changeAnos(this.value)'>";
            Object.keys(anosMeses).forEach((value)=>{
                anos +=`<option>${value}</option>`;
            });
          anos += "</select>";
          $(".ano").html(anos);
    }

    preecheMeses = () =>{
          let meses = "<select class='form-control' onchange='changeMeses(this.value)'>";
            Object.keys(anosMeses[ano]).forEach((value)=>
            {
                meses +=`<option value="${value}">${mesesDescricao[value]}</option>`;
            });
          meses += "</select>";
          $(".mes").html(meses);
    }

    function addDays(date, days) {
      var result = new Date(date);
      result.setDate(result.getDate() + days);
      return result;
    }

    function atualizaTabela(){
        let formatos = {
            formatoHorizontal:atualizarTabelaHorizontal
        };

       $(".formatoSemanalFiltros").hide();

        formatos[formatoSelecionado]();
    }



    atualizarTabelaHorizontal = () => {
        let dados = dadosTabela;
        let dadosPorPlanoDeContas = PorPlanoDeContas;
        let DataPagamento = [];
        let FormaPagamento = [];
        let _acumuladoAnterior = 0;

        dadosTabela.every((a)=>{
           if(a.acumulado){
              _acumuladoAnterior = a.acumuladoAnterior;

              return false;
           }
           return true;
        });

        dados.forEach((data) => {
            if(DataPagamento.indexOf(data.DataPagamento) === -1){
                DataPagamento.push(data.DataPagamento);
            }
            if(FormaPagamento.indexOf(data.FormaPagamento) === -1){
                FormaPagamento.push(data.FormaPagamento);
            }
        });

        html = "";
        thsDatas = "";
        thsTipos = "";

        DataPagamento.forEach((data) => {
            thsDatas += `<th colspan="2">${moment(data, "YYYY-MM-DD").format("DD/MM/YYYY")}</th>`;
            thsTipos += `<th  class="header-tr" >Previsto</th>`;
            thsTipos += `<th  class="header-tr" >Realizado</th>`;
        });

        let dadosBody = "";
        let totalAcumulado = "";

        {
            totalAcumulado += `<tr style="border-bottom: 15px solid #FFFFFF"><td class="header-tr"><B>Saldo Anterior</B></td>`;
            let acumuladoAnterior = _acumuladoAnterior;
            DataPagamento.forEach((DataPagamento) => {
                let result = dados.find((d) => {
                    return d.DataPagamento === DataPagamento
                });

                if(result){
                    if(result.acumuladoAnterior){
                        acumuladoAnterior = result.acumuladoAnterior;
                    }

                    totalAcumulado += `<td class="Previsto" colspan="2" title="Acumulado"><b>${acumuladoAnterior.toLocaleString('pt-BR', {
                                                         style: 'currency',
                                                         currency: 'BRL',
                                                       })}</b></td>`;
                }
                if(!result){
                    totalAcumulado += `<td  class="Previsto" colspan="2"></td>`;
                }
            });

            totalAcumulado += `</td></tr>`;
        }


        dadosBody += `<tr class="header-tr-tipo entradas"><th   COLSPAN="100%" style="text-align: left">Entradas - Forma de Pagamento</th ></tr>`;

        FormaPagamento.forEach((data) => {
            dadosBody += `<tr class="entradas"><td class="header-tr">${data}</td>`;
            DataPagamento.forEach((DataPagamento) => {
                ['Previsto','Realizado'].forEach((tipo)=>{
                    let result = dados.find((d) => {
                        return d.DataPagamento === DataPagamento && d.FormaPagamento === data && d.CD === 'D' && tipo === d.Tipo
                    });

                    if(result){
                        dadosBody += `<td class="${tipo}" title="${result.Invoices.join(" | ")}">${result.ValorMovements.toLocaleString('pt-BR', {
                                         style: 'currency',
                                         currency: 'BRL',
                                       })}</td>`;
                    }
                    if(!result){
                        dadosBody += `<td  class="${tipo}"></td>`;
                    }
                })
            });

            dadosBody += `</td></tr>`;
        });

        dadosBody += `<tr class="header-tr-tipo entradas"><th   COLSPAN="100%" style="text-align: left">Entradas - Plano de Contas</th ></tr>`;

        Categorias.forEach((data) => {
            dadosBody += `<tr class="entradas"><td class="header-tr">${data}</td>`;

            DataPagamento.forEach((DataPagamento) => {

                ['Previsto','Realizado'].forEach((tipo)=>{
                    let result = dadosPorPlanoDeContas.find((d) => {
                        return d.DataPagamento === DataPagamento && d.Categoria === data && d.CD === 'D' && tipo === d.Tipo
                    });

                    if(result){
                        dadosBody += `<td class="${tipo}" >${result.Valor.toLocaleString('pt-BR', {
                                         style: 'currency',
                                         currency: 'BRL',
                                       })}</td>`;
                    }
                    if(!result){
                        dadosBody += `<td  class="${tipo}"></td>`;
                    }
                })
            });

            dadosBody += `</td></tr>`;
        });

        {
            dadosBody += `<tr class="entradas"><td class="header-tr">Total</td>`;

            DataPagamento.forEach((DataPagamento) => {
                ['Previsto','Realizado'].forEach((tipo)=>{
                    let Total = 0;

                    let result = dados.filter((d) => {return d.DataPagamento === DataPagamento && d.CD === 'D' && tipo === d.Tipo});
                    result.forEach((d) => {
                               Total  +=  d.ValorMovements;
                    });

                    dadosBody += `<td class="${tipo}" title="Acumulado">${Total.toLocaleString('pt-BR', {
                                                         style: 'currency',
                                                         currency: 'BRL',
                                                       })}</td>`;
                })
            });

            dadosBody += `</td></tr>`;
        }

        dadosBody += `<tr class="header-tr-tipo saidas"><TH  COLSPAN="100%" style="text-align: left">Saídas - Forma de Pagamento</TH></tr>`;

        FormaPagamento.forEach((data) => {
            dadosBody += `<tr class="saidas"><td class="header-tr">${data}</td>`;

            DataPagamento.forEach((DataPagamento) => {

                ['Previsto','Realizado'].forEach((tipo)=>{
                    let result = dados.find((d) => {
                        return d.DataPagamento === DataPagamento && d.FormaPagamento === data && d.CD === 'C' && tipo === d.Tipo
                    });

                    if(result){
                        dadosBody += `<td class="${tipo}" title="${result.Invoices.join(" | ")}">${result.ValorMovements.toLocaleString('pt-BR', {
                                         style: 'currency',
                                         currency: 'BRL',
                                       })}</td>`;
                    }
                    if(!result){
                        dadosBody += `<td  class="${tipo}"></td>`;
                    }
                })
            });

            dadosBody += `</td></tr>`;
        });

        dadosBody += `<tr class="header-tr-tipo saidas"><th   COLSPAN="100%" style="text-align: left">Saídas - Plano de Contas</th ></tr>`;

        Categorias.forEach((data) => {
            dadosBody += `<tr class="saidas"><td class="header-tr">${data}</td>`;

            DataPagamento.forEach((DataPagamento) => {

                ['Previsto','Realizado'].forEach((tipo)=>{
                    let result = dadosPorPlanoDeContas.find((d) => {
                        return d.DataPagamento === DataPagamento && d.Categoria === data && d.CD === 'C' && tipo === d.Tipo
                    });

                    if(result){
                        dadosBody += `<td class="${tipo}" >${result.Valor.toLocaleString('pt-BR', {
                                         style: 'currency',
                                         currency: 'BRL',
                                       })}</td>`;
                    }
                    if(!result){
                        dadosBody += `<td  class="${tipo}"></td>`;
                    }
                })
            });

            dadosBody += `</td></tr>`;
        });

        {
            dadosBody += `<tr class="saidas"><td class="header-tr">Total</td>`;

            DataPagamento.forEach((DataPagamento) => {
                ['Previsto','Realizado'].forEach((tipo)=>{
                    let Total = 0;

                    let result = dados.filter((d) => {return d.DataPagamento === DataPagamento && d.CD === 'C' && tipo === d.Tipo});
                    result.forEach((d) => {
                               Total  +=  d.ValorMovements;
                    });

                    dadosBody += `<td class="${tipo}" title="Acumulado">${Total.toLocaleString('pt-BR', {
                                                         style: 'currency',
                                                         currency: 'BRL',
                                                       })}</td>`;
                })
            });

            dadosBody += `</td></tr>`;
         }

         {
                dadosBody += `<tr style="border-top: 12px solid #ffff;"><td class="header-tr">Total do Dia</td>`;

                DataPagamento.forEach((DataPagamento) => {

                    ['Previsto','Realizado'].forEach((tipo)=>{
                    let Total = 0;

                    let result = dados.filter((d) => {return d.DataPagamento === DataPagamento && tipo === d.Tipo});
                    result.forEach((d) => {
                               if(d.CD === 'C'){
                                   Total  +=  d.ValorMovements;

                               }

                               if(d.CD === 'D'){
                                   Total  -=  d.ValorMovements;
                               }
                    });
                    dadosBody += `<td class="${tipo}" title="Acumulado">${(Total*-1).toLocaleString('pt-BR', {
                                                         style: 'currency',
                                                         currency: 'BRL',
                                                       })}</td>`;
                    });
                });

                dadosBody += `</td></tr>`;
            }

        {
            dadosBody += `<tr  style="border-top: 12px solid #ffff;"><td class="header-tr"><b>Saldo Final</b></td>`;
            let acumulado = _acumuladoAnterior      ;
            DataPagamento.forEach((DataPagamento) => {
                let result = dados.find((d) => {
                    return d.DataPagamento === DataPagamento
                });

                if(result){
                    if(result.acumulado){
                        acumulado = result.acumulado;
                    }

                    dadosBody += `<td class="Previsto" colspan="2" title="Acumulado"><b>${acumulado.toLocaleString('pt-BR', {
                                                        style: 'currency',
                                                        currency: 'BRL',

                                                       })}</b></td>`;

                }
                if(!result){
                    dadosBody += `<td  class="previsto"></td>`;
                    dadosBody += `<td  class="realizado"></td>`;
                }
            });

            dadosBody += `</td></tr>`;
        }

        html = `<table class="table table-bordered table-condensed">
                    <thead>
                        ${totalAcumulado}
                        <tr class="header-tr"><td rowspan="2"></td>${thsDatas}</tr>
                        <tr>${thsTipos}</tr>
                    </thead>
                    <tbody>${dadosBody}
                    </tbody>
                </table>`;

        document.getElementById("fluxo-de-caixa").innerHTML = html;
    }

    loadDados();

</script>
<%'=request.QueryString %>
<!--#include file="disconnect.asp"-->