/* ----------------------------------------------------------------------------------------------------------------------
	JS PARA CARREGAR A TABELA
---------------------------------------------------------------------------------------------------------------------- */

var extratoPaginacao = function() {
    var $opts = {};
    var _optsDefaults = {
        'seletor'               : '',
        'seletorPaginacao'      : '',
        'seletorDetalhamento'   : '',
        'form'                  : '',
        'dados'                 : null,
        'paginaAtual'           : 1,
        'saldoAnterior'         : 0,
        'qtdpPagina'            : 20,
        'paginas'               : 0,
        'busca'                 : '',
        'endpoint'              : '',
        'valorAnterior'         : 0,
        'resumo'                : [],
        'types'                 : [     
            {'id':1,'nome':'Dinheiro'},
            {'id':2,'nome':'Cheque'},
            {'id':3,'nome':'Transferência'},
            {'id':4,'nome':'Boleto'},
            {'id':5,'nome':'DOC'},
            {'id':6,'nome':'TED'},
            {'id':7,'nome':'Transferência Bancária'},
            {'id':8,'nome':'Cartão de Crédito'},
            {'id':9,'nome':'Cartão de Débito'},
            {'id':10,'nome':'Cartão de Crédito'},
            {'id':15,'nome':'PIX'},
        ]
    };

    function init(opts) {
        revomeZeroMov();
        $opts = setDefaults(opts, _optsDefaults);
        travaForm();
        varificaDados()
    }

    function mudaPagina(pag = 1) {
        if($opts.paginaAtual === $opts.paginas && pag === $opts.paginaAtual){
            return false
        }
        $opts.paginaAtual = pag
        getDados(pag)
    }

    function primeiraLinha (){
        let html = `
            <table class="table table-striped table-bordered table-hover table-condensed">
            <thead>
                <tr class="success">
                    <th></th>
                    <th>#</th>
                    <th>Data</th>
                    <th>Conta</th>
                    <th>Forma</th>
                    <th>Descrição</th>
                    <th nowrap="">Lançado por</th>
                    <th>Valor</th>
                    <th>Saldo</th>
                    <th>Total</th>
                    <th></th>
                </tr>
            </thead>
            <tr>
                <th></th>
                <th class="saldo-anterior-td" colspan="7">SALDO ANTERIOR</th>
                <th class="text-right column-number" data-value="${$opts.saldoAnterior}" data-formated-value="${$opts.saldoAnterior}"> ${formatMoney($opts.saldoAnterior)}</th>
                <th class="text-right">${formatMoney($opts.valorAnterior)}</th>
            <td></td>
        </tr>`
        return html

    }

    function montaPagina() {
        let html = ''
        html += primeiraLinha()
        let valorAnterior =  parseFloat(treatComma(nullTozero($opts.valorAnterior))).toFixed(2) || 0
        let saldoAnteriorAlt = parseFloat(treatComma(nullTozero($opts.saldoAnterior))).toFixed(2) || 0 
        $opts.dados.map((ele) => {
                console.log(ele)
            let acao = ""
            let valor = 0
            let entrada = false
            html += `<tr>`

            if(parseFloat(treatComma(nullTozero(ele.entrada))) >= parseFloat(treatComma(nullTozero(ele.saida)))){
                acao = "Recebimento";
                valor = parseFloat(treatComma(nullTozero(ele.entrada)))
                entrada = true
            }else{
                acao = "Pagamento";
                valor = parseFloat(treatComma(nullTozero(ele.saida)))
                entrada = false
            }
            if(entrada){
                saldoAnteriorAlt    = parseFloat(saldoAnteriorAlt+valor).toFixed(2)
                valorAnterior       = parseFloat(valorAnterior+valor).toFixed(2)
            }else{
                saldoAnteriorAlt    = parseFloat(saldoAnteriorAlt-valor).toFixed(2)
                valorAnterior       = parseFloat(valorAnterior-valor).toFixed(2)
            }

            let linha = `
                <td></td>
                <td><code>${ele.movementid}</code></td>
                <td>${ele.data}</td>
                <td>${ele.nome}</td>
                <td><img width="18" src="assets/img/${ele.tipopagamento}C.png">&nbsp;<small>${ele.tipoPagamentoNome}</small></td>
                <td>${acao}</td>
                <td>${ele.lancadoPor}</td>
                <td>${ formatMoney(valor) }</td>
                <td>${ formatMoney(saldoAnteriorAlt) }</td>
                <td>${ formatMoney(valorAnterior) }</td>
                <td>${ actionBtns(ele.movementid)}</td>
                `
            html += '</tr>'



            html+=linha
        })

        $(`#${$opts.seletor}`).html(html)
    }

    function actionBtns (){
        html= `<div class="action-buttons">
                    <a style="float: right;" href="javascript:modalPaymentAttachments('13730655');" title="Anexar um arquivo"> <i class="fa fa-paperclip bigger-140 white"></i></a>
                    <a href="#" onclick="modalPaymentDetails('13730655')">
                        <i class="fa fa-search-plus bigger-130"></i>
                    </a>
                    <a class="red" onclick="xMov(13730655, 'extrato');" role="button" href="#">
                        <i class="fa fa-trash bigger-130"></i>
                    </a>
                </div>`
        return html
    }

    function montaPaginacao() {
        $('#autoPaginacao').children().detach()
        let html = `<ul class="pagination">`
        html += `<li class="page-item" onClick="extratoPaginacao.mudaPagina(1)"><a class="page-link" href="#">Primeira</a></li>`

        
        min = ($opts.paginaAtual - 5) <= 1 ? 1 : ($opts.paginaAtual - 5)
        max = min + 10 > $opts.paginas ? $opts.paginas : min + 10        
        
        for (let index = min; index <= max; index++) {
            let linha = `<li class="page-item ${$opts.paginaAtual==index?'active':''}" onClick="extratoPaginacao.mudaPagina(${index})"  ${$opts.paginaAtual==index?'disabled':''} ><a class="page-link" href="#">${index}</a></li>`
            html += linha
        }
        html += `<li class="page-item" onClick="extratoPaginacao.mudaPagina(${$opts.paginas})"><a class="page-link" href="#">Ultima</a></li>`
        html += `</ul>`
        $('#autoPaginacao').append(html)

    }

    function getDados(pagina){
        let filter = $("#"+$opts.form).serialize()
        pagina = "&pagina="+pagina
        qtdPerPage = "&qtdPerPage="+$opts.qtdpPagina
        let params = filter+pagina+qtdPerPage
        
        requisicao($opts.endpoint,params,(data)=>{
            $opts.dados = data.dadosDaPagina || [];
            $opts.paginas = data.paginas || 1;
            $opts.qtdpPagina = data.qtdpPagina || 20;
            $opts.saldoAnterior = data.saldoAnterior || 0;
            let valorAnterior  = data.totaloffset || 0;
            $opts.valorAnterior = parseFloat(valorAnterior)
            if (data.resumo) {
                $opts.resumo = data.resumo[0]
            }
            montaPaginacao()
            montaPagina()
            detalhamento()
            varificaDados()
        })
    }

    function filter() {
        getDados(1)
        $(`#${$opts.seletor}`).html(`
            <div id="extrato" class="panel-body">
                <center><em>Selecione acima a conta, o paciente, o funcionário ou o profissional para ver o extrato.</em></center>
            </div>
        `)
    }

    function detalhamento(){
        let html = `
        <table class="table table-striped table-bordered table-hover table-condensed">
            <thead>
                <tr>
                    <th colspan='4'><b>Resumo</b></th>
                </tr>
                <tr>
                    <th>Tipo</th>
                    <th>Entradas <i class="fas fa-arrow-up entrada"></i></th>
                    <th>Saidas <i class="fas fa-arrow-down saida"></i></th>
                    <th>Resultado</th>
                </tr>
            </thead>
            <tbody>`
            $opts.types.map(ele=>{
                html += `<tr>
                    <td><img width="18" src="assets/img/${ele.id}C.png">${ele.nome}</td>
                    <td>${formatMoney(addZero($opts.resumo['entrada'+ele.id]))}</td>
                    <td>${formatMoney(addZero($opts.resumo['saida'+ele.id]))}</td>
                    <td>${formatMoney(addZero(parseFloat(nullTozero($opts.resumo['entrada'+ele.id])).toFixed(2) - parseFloat(nullTozero($opts.resumo['saida'+ele.id])).toFixed(2)))}</td>
                </tr>`
            })
 
           html+=`
            </tbody>
       </table>`
        $(`#${$opts.seletorDetalhamento}`).html(html)

    }
    function toggleDetalhamento(){
        let open = $(`#${$opts.seletorDetalhamento}`).parent().hasClass("aberto") 

        if(!open){
            $(`#${$opts.seletorDetalhamento}`).parent().addClass('aberto')
        }else{
            $(`#${$opts.seletorDetalhamento}`).parent().removeClass('aberto')
        }
    }

    function setDefaults(params, defaults) {
        var recursive = true;
        return $.extend(recursive, {}, defaults, params);
    }

    function revomeZeroMov(){
        requisicao('financeiro/zerarMovs',"",(data)=>{
            return false
        })
        return true;
    }

    function travaForm(){
        $(`#${$opts.form}`).submit((ev)=>{
            ev.preventDefault()
        })
        return true;
    }

    function requisicao(endpoint,parametros,callback=false){
        $.ajax({
            method: "GET",
            url: `${endpoint}.asp?${parametros}`
        })
        .done(function( data ) {
            data = JSON.parse(data)
            if(typeof(callback) === "function"){
                callback(data)
            }
        });
    }

    function varificaDados(){
        if($opts.dados === null || $opts.dados ==="" ){
            $(`#${$opts.seletorDetalhamento}`).parent().addClass("hide")
        }else{
            $(`#${$opts.seletorDetalhamento}`).parent().addClass("show")
        }
    }

    
    function nullTozero(val){
        if(val === ""){
            return "0,0"
        }
        return val
    }

    function treatComma(val){
        return val.toString().replace(",",".")
    }

    function addZero(val){
        val = nullTozero(val)
        val = treatComma(val)
        if( val.toString().indexOf( "." ) !== -1 ){
            return val
        }else{
            return val+".00"
        }
    }

    function formatMoney(val) {
        return val.toLocaleString('pt-br',{style: 'currency', currency: 'BRL'});
    }


    /**
     * Funções externadas
     */
    return {
        init: init,
        mudaPagina: mudaPagina,
        filter,
        toggleDetalhamento
    };
}()