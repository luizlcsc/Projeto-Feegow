<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<style type="text/css">
    .card{
        border: 1px solid #333;
        border-radius: 7px;
        padding: 0!important;
        margin: 0 10px 10px;
        flex: 0 48%;
    }
    .card-header {
        padding: 10px;
        background-color: #217dbb;
        color: white;
        border-radius: 7px 7px 0 0 ;  
        display: flex;
        justify-content: space-between
    }
    .card-body{
        padding:10px;
    }
    .warp-colapse {
        position: relative;
        cursor: pointer;
    }
    .warp-colapse >*{
       pointer-events:none
    }
    i.arrow {
        border-top: 5px solid transparent;
        border-left: 5px solid transparent;
        border-bottom: 5px solid transparent;
        border-right: 5px solid transparent;
        width: 5px;
        height: 5px;
        line-height: 5px;
        position: absolute;
        right: 10px;
        top: 5px;
    }
    i.left{
        border-right: 5px solid black;
    }
    i.bottom{
        border-top: 5px solid black;
    }
    .moreInfo {
        height: auto;
    }
    .resultados{
        padding: 10px 0;
        display: flex;
        justify-content: start;
        position: relative;
        flex-wrap: wrap;
    }
    .footer{
        background-color: #dedede;
        padding: 10px;
        border-radius: 0 0 7px 7px;
        display:flex;
        align-items: center;
    }
    .valor, .recebimento {
        pointer-events:none
    }
    
    .editarValor input, .editarValor button {
        height: 20px;
        line-height: 0px;
    }
    .footer .glyphicon{
        margin-right:10px
    }
    .btn-warp{
        display: flex;
        justify-content: space-between;
        width: 96%;
    }
    ul#dropdownModal {
        display:none;
        position: absolute;
        width: 94%;
        background-color: #a9a6a6;
        z-index: 3;
        box-shadow: 2px 5px 7px 1px #a9a6a6a8;
        list-style: none;
    }
    ul#dropdownModal li {
        padding: 5px 0;
        cursor: pointer;
    }
    #TipoN,#tabelaPreco,#valorN{
        width:96%
    }
    .modal-body .panel-body > div{
        margin-bottom: 15px;
    }
    .warp-valor{
        display: flex;
        justify-content: space-between;
        width: 100%;  
    }
    .editarValor{
        display:none;
        justify-content: space-between;
        width: 100%;
    }
    .visualizarValor{
        cursor: pointer;
    }
</style>
<div class="panel">
    <div id='procedimentoId' class='hidden'></div>
    <div class="panel-body">
        <%= quickfield("simpleSelect", "Tipo", "Tipo", 4, "", "select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda' ORDER BY 1 DESC ", "Tipo", " no-select2 semVazio required ") %>
        <%= quickfield("multiple", "TabelasParticulares", "Tabelas Particulares", 4, "", "select * from tabelaparticular where  "&franquia(" COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE) AND ")&" sysActive=1 order by NomeTabela", "NomeTabela", "") %>
        <%= quickfield("multiple", "Especialidades", "Especialidades", 4, "", "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>
        <%=quickField("simpleSelect", "Unidade", "Unidade", 4, "", "SELECT concat('|',id,'|') as id,NomeFantasia FROM vw_unidades "&franquia(" WHERE COALESCE(cliniccentral.overlap(concat('|',id,'|'),COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE) ")&" order by 2 ", "NomeFantasia", " semVazio ")%>
        <%=quickField("simpleSelect", "Status", "Status",4, "on", "SELECT 'on' id , 'Ativo' ativo UNION SELECT '', 'Inativo' ", "ativo", " ")%>
        <div class="col-md-4">
            <label>&nbsp;</label><br/>
            <div class='btn-warp'>
                <button type='submit' class='btn btn-primary' onClick='filterTabelaPreco()'>Filtrar</button>
                <button id='criarVariacao' type='submit' class='btn btn-success'>Inserir variação</button>
            </div>
        </div>
    </div>
    <div class='resultados'>
        
    </div>
</div>
<!-- Modal -->
<div class="modal fade" id="modalCriarvariacao" tabindex="-1" role="dialog" aria-labelledby="modalCriarvariacao">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">Inserir variação para o procedimento <span id='procedimento'></span></h4>
      </div>
      <div class="modal-body">
        <div class="panel">
            <div class="panel-body">
                <%= quickfield("simpleSelect", "TipoN", "Tipo", 6, "", "select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda'", "Tipo", " no-select2 semVazio required ") %>
                <div class="form-group col-md-6">
                    <label for="tabelaPreco">Tabela de preço</label>
                    <input name="tabelaPreco" type="text" class="form-control" id="tabelaPreco">
                    <ul id='dropdownModal'>

                    </ul>
                </div>
                <%
                    sqlProfissionais = "select id, NomeProfissional from profissionais where sysActive=1 and ativo='on' UNION ALL select concat('2_', id), concat(NomeFornecedor, ' - Fornecedor') from fornecedores where sysActive=1 and (TipoPrestadorID is null or TipoPrestadorID=1) and Ativo='on' UNION ALL (select concat('8_', id), concat(NomeProfissional, ' - Externo') from profissionalexterno where sysActive=1 order by NomeProfissional limit 1000)"
                    sqlProfissionais = " select id, NomeProfissional,profissionais.Unidades                    "&chr(13)&_
                                    " from profissionais                                                    "&chr(13)&_
                                    " where sysActive = 1                                                   "&chr(13)&_
                                    "   and ativo = 'on'                                                    "&chr(13)&_
                                    " UNION ALL                                                             "&chr(13)&_
                                    " select concat('2_', id), concat(NomeFornecedor, ' - Fornecedor'),null "&chr(13)&_
                                    " from fornecedores                                                     "&chr(13)&_
                                    " where sysActive = 1                                                   "&chr(13)&_
                                    "   and (TipoPrestadorID is null or TipoPrestadorID = 1)                "&chr(13)&_
                                    "   and Ativo = 'on'                                                    "&chr(13)&_
                                    " UNION ALL                                                             "&chr(13)&_
                                    " (select concat('8_', id), concat(NomeProfissional, ' - Externo'),null "&chr(13)&_
                                    "  from profissionalexterno                                             "&chr(13)&_
                                    "  where sysActive = 1                                                  "&chr(13)&_
                                    "  order by NomeProfissional                                            "&chr(13)&_
                                    "  limit 1000)                                                          "

                    sqlProfissionais = "SELECT * FROM ("&sqlProfissionais&") AS t "&franquia(" WHERE COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")
                %>

                <%= quickfield("multiple", "TabelasParticularesN", "Tabelas Particulares", 6, "", "select * from tabelaparticular where  sysActive=1 order by NomeTabela", "NomeTabela", "") %>
                <%= quickfield("multiple", "EspecialidadesN", "Especialidades", 6, "", "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>
                <%= quickField("multiple", "UnidadeN", "Unidade", 6, "", "SELECT concat(id,'') as id,NomeFantasia FROM vw_unidades "&franquia(" WHERE COALESCE(cliniccentral.overlap(concat('|',id,'|'),COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE) ")&" order by 2 ", "NomeFantasia", " empty ")%>
                <%= quickfield("datepicker", "InicioN", "Vigência de", 3, "", "", "", "") %>
                <%= quickfield("datepicker", "FimN", "até", 3, "", "", "", "") %>
                <%= quickfield("multiple", "ProfissionaisN", "Executantes", 6, "", sqlProfissionais, "NomeProfissional", "") %>
                <input type='hidden' value='criar' id='acao'/>
                <div class="form-group col-md-3">
                    <label for="valorN">Valor</label>
                    <input name="valorN" type="text" class="form-control" id="valorN">
                </div>
                <div class="form-group col-md-3">
                    <label for="recebimentoN">Recebimento Parcial</label>
                    <input name="recebimentoN" type="text" class="form-control" id="recebimentoN">
                </div>
            </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" onClick='actionTabela()'>Salvar</button>
      </div>
    </div>
  </div>
</div>

<script>
<!--#include file="../jQueryFunctions.asp"-->

    // trigger para o modal de ciação de variação
    $('#criarVariacao').on('click',()=>{
        event.preventDefault()
        let procedimento = $('#NomeProcedimento').val()
        $('span#procedimento').html(procedimento)    
        $('#valorN').maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true});
        $('#recebimentoN').maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true});
        clear()
        $('#modalCriarvariacao').modal('toggle')

    })

    // traz os dados para montar os cards
    function filterTabelaPreco(filtro=true,montacard=true){

        event.preventDefault()

        let procedimento = $('#NomeProcedimento').val()
        let tipo = ''
        let unidades = ''
        let tabelas = ''
        let especialidades = ''
        let status = ''
        let tabelaPreco = ''
        if(filtro){
            tipo = $('#Tipo').val()
            unidades = emptyValue($('#Unidade').val())
            tabelas = emptyValue($('#TabelasParticulares').val())
            especialidades = emptyValue($('#Especialidades').val())
            status = ($('#Status').val()=="on"?1:0)
        }
        let obj = {
            procedimento,
            tipo,
            unidades,
            tabelas,
            especialidades,
            status,
            tabelaPreco
        }
        ajaxTofilter(obj,(data)=>{
            data = JSON.parse(data)
            $('.resultados').html('')

            data.forEach(card => {
                if(montacard){
                    montaCard(card)
                }else{
                    return(data)
                }   
            });
            $('.visualizarValor').on('click',(e)=>{
                let seletor = e.target
                $(seletor).parent().children('.visualizarValor').css('display','none')
                $(seletor).parent().children('.editarValor').css('display','flex')
                $(seletor).parent().children('.editarValor').find('input').maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true});
            })
            $(function () {
                $('[data-toggle="tooltip"]').tooltip()
            })
        })
       
    }

    //request para getFitro
    function ajaxTofilter (obj,callback){
        let {
            procedimento,
            tipo,
            unidades,
            tabelas,
            especialidades,
            status,
            tabelaPreco
        } = obj
        $.get( `procedimentos/getfiltro.asp?procedimento=${procedimento}&tipo=${tipo}&unidades=${unidades}&tabelas=${tabelas}&especialidades=${especialidades}&status=${status}&tabelaPreco=${tabelaPreco}`)
        .done(function(data) {
            callback(data)
        })
    }

    //monta o html dos cards
    function montaCard(card){
        // NomeProcedimento: "10 SESSÃO"
        // NomeTabela: "teste"
        // RecebimentoParcial: "20"
        // Tipo: "V"
        // Valor: "60,03"
        // especialidades: " Acupuntura, Alergologia e Imunologia"
        // especialidadesId: " 137, 112"
        // fim: "30/08/2022"
        // id: "1"
        // idTabelaValor: "1"
        // inicio: "07/08/2020"
        // profissionais: " Neli Pereira Gonzalez Ludoz, Fabio Rodrigues"
        // profissionaisId: "|8_3|,|1|"
        // tabelasParticulares: "Desconto Convenio"
        // tabelasParticularesId: "1"
        // unidades: "CHAGAS MEDICAL"
        // unidadesId: "0"
        let html = `
        <div class="card tabelaPreco col-md-6">
            <div class="card-header">
                <span>Tabela de Preço: ${card.NomeTabela}</span>
                <span><strong>Vigencia</strong>: ${card.inicio} a ${card.fim}</span>
            </div>
            <div class="card-body">
                <h5 class="card-title">Tabela Particular: ${card.tabelasParticulares}</h5>
                <div class='moreInfo'>
                    <p><strong>Profissionais</strong>: ${card.profissionais}</p>
                    <p><strong>Especialidades</strong>: ${card.especialidades}</p>
                    <p><strong>Unidades</strong>: ${card.unidades}</p>
                </div>
            </div>
            <div class='footer'>
                <span class="glyphicon glyphicon-info-sign" aria-hidden="true" data-toggle="tooltip" data-placement="top" title="Click no valor para habilitar a edição"></span> 
                <div class='warp-valor visualizarValor'>
                    <span class='valor'>Valor: R$ ${fixMoney(card.Valor)}</span>   
                    <span class='recebimento'>Recebimento Parcial: R$ ${fixMoney(card.RecebimentoParcial)}</span>   
                    <div></div>
                </div>
                <div class='warp-valor editarValor' data-id="${card.idTabelaValor}">
                    <span>Valor: <input class='valorI' name='valor' type='txt' value='${fixMoney(card.Valor)}'/> </span>
                    <span>Recebimento Parcial: <input class='RecebimentoParcialI' name='recebimento' type='txt' value='${fixMoney(card.RecebimentoParcial)}'/> </span>
                    <button type='submit' class='btn btn-primary salvaValor' onClick='attValor(${card.idTabelaValor})'>Salvar</button>
                </div>
            </div>
        </div>
        `
        $('.resultados').append(html)

    }

    //normaliza o valor undefined para vazio
    function emptyValue(value){
        if(value==null){
            return ''
        }else{
            return value
        }
    }

    // inicia o filtro ao carregar a pagina
    //filterTabelaPreco(false)
    getProcedimentoId()

    // função para normalizar o valor de monetário
    function fixMoney (valor){
        if(!valor){
            return ""
        }

        if(valor.indexOf(',') > 0){
            if((valor.split(',')[1]).length == 1){
                return valor + '0'
            }
        }else{
            return valor + ',00'
        }
        return valor
    }

    // função para atualizar o valor do procedimento em uma tabela de preço especifica
    function attValor (tabelaPrecoId){
        let valor = $(`*[data-id="${tabelaPrecoId}"]`).find('input.valorI').val()
        let recebimento = $(`*[data-id="${tabelaPrecoId}"]`).find('input.RecebimentoParcialI').val()

        if(!valor){
            event.preventDefault()
            new PNotify({
                title: 'Ocorreu um erro!',
                type: 'danger',
                delay: 3000
            });
            return false
        }else{
            let obj = {
                tabelaPrecoId,
                valor,
                recebimento
            }
            ajaxToUpdate(obj,(data)=>{
                valor.toString()
                $(`*[data-id="${tabelaPrecoId}"]`).parent().children('.visualizarValor').children('.valor').html('Valor: R$ '+fixMoney(valor))
                $(`*[data-id="${tabelaPrecoId}"]`).parent().children('.visualizarValor').children('.recebimento').html('Valor: R$ '+fixMoney(recebimento))
                $(`*[data-id="${tabelaPrecoId}"]`).parent().children('.visualizarValor').css('display','flex')
                $(`*[data-id="${tabelaPrecoId}"]`).parent().children('.editarValor').css('display','none')
            })
        }
    }
    // update valor
    function ajaxToUpdate(obj,callback){
        let {
            tabelaPrecoId,
            valor,
            recebimento
        } = obj
        $.get( `procedimentos/attValor.asp?tabelaId=${tabelaPrecoId}&valor=${valor.replace(/\./g,'').replace(',','.')}&recebimento=${recebimento.replace('.','').replace(',','.')}`)
        .done(function(data) {
            if(data){
                callback(data)
            }
        })
    }
    function clearDots (){
    }

    // *************************************************************** MODAL

    //mostra dropdown quando clica na tabela de preço
    $('#tabelaPreco').focusin((e)=>{
        requestDrop(false)
    })

    // some com o dropdown quando clica fora da tabela de preço
    $('#tabelaPreco').parent().focusout((e)=>{
        setTimeout(() => { 
            $('#dropdownModal').css('display','none')
        }, 100);
    })

    // adiciona evento ao escrever nome na tabela de preço
    $('#tabelaPreco').keyup( (e)=>{
        clear(false)
        $('#acao').val('criar')
    })

    //pesquisa as tabelas de preço preexistentes
    function requestDrop (filtro=true){
        // let procedimento = $('#NomeProcedimento').val() 
        let procedimento = '' 
        let tipo = '' 
        let unidades = '' 
        let tabelas = '' 
        let especialidades = '' 
        let status = '' 
        let tabelaPreco = ''
        if(filtro){
            tipo = $('.modal-body #TipoN').val()
            unidades = emptyValue($('.modal-body #UnidadeN').val())
            tabelas = emptyValue($('.modal-body #TabelasParticularesN').val())
            especialidades = emptyValue($('.modal-body #EspecialidadesN').val())
            status = "on"
        }
        let obj = {
            procedimento,
            tipo,
            unidades,
            tabelas,
            especialidades,
            status,
            tabelaPreco
        }
        ajaxTofilter(obj,(data)=>{
            data = JSON.parse(data)
            montaDrop(data)
        })
  
    }

    // monta o dropdown das tabelas de preço
    function montaDrop(data){
        let html =''
        data.map((tabela)=>{
            let obj = {
                tableId:tabela.idTabelaValor,
                tableName:tabela.NomeTabela
            }
            html  += `<li id='${tabela.idTabelaValor}' class="dropSelect" >${tabela.NomeTabela}</li>`
        })
        $('#dropdownModal').children().detach()
        $('#dropdownModal').append(html)
        $('#dropdownModal').css('display','block')

        $('.dropSelect').on('click', (e)=>{
            let valor = $(e.target).html()
            let id = e.target.id
            clear()
            $('#tabelaPreco').val(valor)
            $('#tabelaPreco').attr('data-id',id)
            requestBlockFiltered(e.target.id)
        })
    }

    // pesquisa dados de tabela preexistentes
    function requestBlockFiltered(id){
        $('#dropdownModal').css('display','none')
        let procedimento = '' 
        let tipo = ''
        let unidades = ''
        let tabelas = ''
        let especialidades = ''
        let status = ''
        let tabelaPreco = id
        let obj = {
            procedimento,
            tipo,
            unidades,
            tabelas,
            especialidades,
            status,
            tabelaPreco
        }
        ajaxTofilter(obj,(data)=>{
            data = JSON.parse(data)
            console.log(data)
            console.log(parseInt(data[0].procedimentoId))
            console.log(parseInt($('#procedimentoId').html()))
            if(parseInt(data[0].procedimentoId) == parseInt($('#procedimentoId').html())){
                blockFiltered(data[0],true)
            }else{
                blockFiltered(data[0],false)
            }
        })
    }

    // Preseleciona os campos baseado em uma tabla de preços preexistente
    function blockFiltered(dados,type){
        $('#TipoN').val(dados.Tipo)
        $('#TipoN').attr('disabled',true)
        if(dados.tabelasParticularesId){
            $('#qftabelasparticularesn').find('select').val('|'+dados.tabelasParticularesId+"|")
            $('#qftabelasparticularesn').find('.multiselect').attr('title',dados.tabelasParticulares)
            $('#qftabelasparticularesn').find('.multiselect').html(dados.tabelasParticulares+'<b class="caret"></b>')
            $('#qftabelasparticularesn').find('ul.multiselect-container li').not('.multiselect-item').find('input[value="|'+dados.tabelasParticularesId+'|"]').prop('checked',true)
            $('#qftabelasparticularesn').find('.multiselect').attr('disabled',true)
        
        }
        if(dados.especialidadesId){
            multiSelect('#qfespecialidadesn',dados.especialidadesId,dados.especialidades)
        }
        if(dados.unidadesId){
            multiSelect('#qfunidaden',dados.unidadesId,dados.unidades)
        }
        if(dados.fim && dados.inicio){
            $("#InicioN").val(dados.inicio)
            $('#InicioN').attr('disabled',true)
            $("#FimN").val(dados.fim)
            $('#FimN').attr('disabled',true)
        }
        if(dados.profissionaisId){
            multiSelect('#qfprofissionaisn',dados.profissionaisId,dados.profissionais)
        }
        console.log(type)
        if(type){
            $('#valorN').val(fixMoney(dados.Valor))
            $('#recebimentoN').val(fixMoney(dados.RecebimentoParcial))
            $('#acao').val('editar')
        }else{
            $('#acao').val('add')
        }
    }

    function multiSelect(seletor,id,name) {
        //multi
        let arrayIds = id.split(',')
        let arrayNomes = name.split(',')

        let multiplos  = false
    

        let selectedIds = []
        arrayIds.map((elemento)=>{
            elemento = elemento.replace("|",'').replace("|",'').replace(' ','')
            selectedIds.push("|"+elemento+"|") 
            $(seletor).find('ul.multiselect-container li').not('.multiselect-item').find('input[value="|'+elemento+'|"]').prop('checked',true)

        })
        $(seletor).find('select').val(selectedIds)
        $(seletor).find('.multiselect').attr('title',name)
        if(arrayIds.length > 1){
            $(seletor).find('.multiselect').html(`${arrayIds.length} selecionado(s) <b class="caret"></b>`)
        }else{
            $(seletor).find('.multiselect').html(name+'<b class="caret"></b>')
        }
        $(seletor).find('.multiselect').attr('disabled',true)
    }

    // limpa os bloqueios
    function clear(tabela=true){
        //tipo
        $('#TipoN').attr('disabled',false)

        if(tabela){
            $('#tabelaPreco').val('')
            $('#tabelaPreco').attr('data-id','')
        }
        //tabelas particulares
        $('#qftabelasparticularesn').find('select').val('')
        $('#qftabelasparticularesn').find('.multiselect').attr('title','')
        $('#qftabelasparticularesn').find('.multiselect').html('Selecione <b class="caret"></b>')
        $('#qftabelasparticularesn').find('ul.multiselect-container li').not('.multiselect-item').find('input').prop('checked',false)
        $('#qftabelasparticularesn').find('.multiselect').attr('disabled',false)

        //especialidades
        $('#qfespecialidadesn').find('select').val('')
        $('#qfespecialidadesn').find('.multiselect').attr('title','')
        $('#qfespecialidadesn').find('.multiselect').html('Selecione <b class="caret"></b>')
        $('#qfespecialidadesn').find('ul.multiselect-container li').not('.multiselect-item').find('input').prop('checked',false)
        $('#qfespecialidadesn').find('.multiselect').attr('disabled',false)

        //unidades
        $('#qfunidaden').find('select').val('')
        $('#qfunidaden').find('.multiselect').attr('title','')
        $('#qfunidaden').find('.multiselect').html('Selecione <b class="caret"></b>')
        $('#qfunidaden').find('ul.multiselect-container li').not('.multiselect-item').find('input').prop('checked',false)
        $('#qfunidaden').find('.multiselect').attr('disabled',false)

        //profissionais
        $('#qfprofissionaisn').find('select').val('')
        $('#qfprofissionaisn').find('.multiselect').attr('title','')
        $('#qfprofissionaisn').find('.multiselect').html('Selecione <b class="caret"></b>')
        $('#qfprofissionaisn').find('ul.multiselect-container li').not('.multiselect-item').find('input').prop('checked',false)
        $('#qfprofissionaisn').find('.multiselect').attr('disabled',false)
        
        // vigencia
        $("#InicioN").val('')
        $('#InicioN').attr('disabled',false)
        $("#FimN").val('')
        $('#FimN').attr('disabled',false)

        //valor
        $('#valorN').val('')
        $('#recebimentoN').val('')

    }
    

    // verifica se irá salvar ou atualizar a tabela
    function actionTabela(){
        let tabela = $('#tabelaPreco').val()
        let tabelaId = $('#tabelaPreco').attr('data-id')
        let valor = $('#valorN').val()
        let recebimento = $('#recebimentoN').val()
        let acao = $('#acao').val()

        let validar = [
            {
                valor:tabela,
                msg:'O campo tabela de preço deve estar preenchido!'
            },
            {
                valor:valor,
                msg:'O campo valor deve estar preenchido!'
            }, 
        ]
        let validacao = validarModal(validar)

        if(!validacao){
            return false
        }
        validacao=true

        if(acao=='criar'){
            let inicio = formatarData($('#InicioN').val())
            let fim = formatarData($('#FimN').val())

            validar = [
                {
                    valor:inicio,
                    msg:'O campo de data inicial da vigência deve estar preenchido!'
                }, 
                {
                    valor:fim,
                    msg:'O campo de data final da vigência deve estar preenchido!'
                }
            ]
            validacao = validarModal(validar)

            if(!validacao){
                return false
            }

            let tabelasParticulares = emptyValue($('#TabelasParticularesN').val())
            let profissionais = emptyValue($('#ProfissionaisN').val())
            let especialidades = emptyValue($('#EspecialidadesN').val())
            let unidades = (emptyValue($('#UnidadeN').val())===''?"|0|":$('#UnidadeN'))
            let tipo = $('#TipoN').val()
            let procedimento = $('#NomeProcedimento').val()
            
            criarTabela (tabela,inicio,fim,tabelasParticulares,profissionais,especialidades,unidades,tipo,valor,recebimento,procedimento)
        
        }else if(acao=='editar'){
            let obj = {
                tabelaId,
                valor,
                recebimento
            }
            ajaxToUpdate(obj,()=>{
                clear()
                $('#modalCriarvariacao').modal('toggle')
                filterTabelaPreco(false)
            })
        }else{

            $.get( `procedimentos/addProcedimentoNaTabelaDePreco.asp?tabelaId=${tabelaId}&valor=${valor.replace(/\./g,'').replace(',','.')}&recebimento=${recebimento.replace(/\./g,'').replace(',','.')}&procedimento=${$('#procedimentoId').html()}`)
            .done(function(data) {
                clear()
                $('#modalCriarvariacao').modal('toggle')
                filterTabelaPreco(false)
            })
        }
    }

    function criarTabela (tabelaNome,inicio,fim,tabelasParticulares,profissionais,especialidades,unidades,tipo,valor,recebimento,procedimento) {

        let url = `procedimentos/criarTabelaPreco.asp?tabelaNome=${tabelaNome}&inicio=${inicio}&fim=${fim}&tabelasParticulares=${tabelasParticulares}&profissionais=${profissionais}&especialidades=${especialidades}&unidades=${unidades}&tipo=${tipo}&valor=${valor.replace(/\./g,'').replace(',','.')}&recebimento=${recebimento.replace('.','').replace(',','.')}&procedimento=${procedimento}`

        $.get(url)
        .done(function(data) {
            if(data){
                clear()
                $('#modalCriarvariacao').modal('toggle')
                filterTabelaPreco(false)
            }
        })
    }

    function validarModal(validar){
        validar.map((teste)=>{
            if(!teste.valor){
                event.preventDefault()
                new PNotify({
                    title: teste.msg,
                    type: 'danger',
                    delay: 5000
                });
                return false
            }
        })
        return true
    }

    function formatarData(data) {
        var dateArray = data.split('/');
        var dia = dateArray[0]
        var mes = dateArray[1]
        var ano = dateArray[2]

        var data = ano + "-" + mes + "-" + dia;

        return data;
    };

    function getProcedimentoId(){
        let procedimento = $('#NomeProcedimento').val()
        $.get( `procedimentos/getProcedimentoId.asp?procedimento=${procedimento}`)
        .done(function(data) {
            data = JSON.parse(data)[0]
            $('#procedimentoId').html(data.procedimentos)
        })
    }
</script>