<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->

<style>
    #documentosWarper .row{
        display: flex;
        align-items: center;
    }
    #panelDoc .panel-heading{
        display: flex;
        justify-content: space-between;
    }
</style>

<div id='panelDoc' class='panel'>
    <div class='panel-heading'>
        <span>Tipos de documentos</span>
        <div class='actionArea'>
            <button class="btn btn-success" onclick="documentosSalvar()"><i class="far fa-plus"></i> Salvar documentos</button>
        </div>
    </div>
    <div id='documentosWarper' class="panel-body">

    </div>
</div>


<script type="text/javascript">
    var tipos = []
    var Gprotocolo = null

    function getDocumentos(protocolo){
        Gprotocolo = protocolo
        $.get( `ProtocolosDocumentosgetDocumentos.asp?protocolo=${protocolo}` )
        .done(function(data) {
            data = JSON.parse(data)
            $('#documentosWarper').html('')
            data.map(doc=>{
                addLine(doc)
            })
            block()
        })
        if(tipos.length == 0){
            let localTipos = '<%= recordToJSON(db.execute("select id,NomeArquivo from tipos_de_arquivos where sysActive=1")) %>' ;
            tipos  =  JSON.parse(localTipos)
        }
    }

    function addDocumentos(protocolo){
        addLine()
    }

    function addLine(preset=false){
        let linhas = $($('#documentosWarper .row')).length
        let linha = `linha_${linhas+1}`
        let html = `
        <div class='row ${linha}' >
            <div class="form-group col-md-6">
                <label for="NomeArquivo">Tipo de Arquivo</label>
                <select name="tipos" class="form-control">
                    <option>Selecionar tipo</option>
                    ${ tipos.map(tipo=>{
                        return `<option ${(preset?(preset.id == tipo.id?'selected':''):'')} value='${tipo.id}'>${tipo.NomeArquivo}</option>`    
                    }).join('')}
                </select>
            </div>
            <div class='col-md-2'>
                <button class='btn btn-danger btn-xs'><i class="far fa-trash"></i></button>
            </div>
        </div>`
        $('#documentosWarper').append(html)

        $(`.${linha} button`).click((event)=>{
            event.preventDefault()
            apagarRelacao(linha)
        })
    }
    function documentosSalvar() {
        event.preventDefault()
        apagarRelacoes((data)=>{
            let linhas = $('div[class^="row linha_"]')
            linhas.map((key,linha)=>{
                let tipo = $(linha).find('select').val()
                salvarAssoc(tipo)
            })
        })

        new PNotify({
            title: 'Documentos cadastrados com sucesso',
            type: 'success',
            delay: 1500
        });

    }

    function apagarRelacoes(callback){
        $.get( `ProtocolosDocumentosRemoveAssoc.asp?protocolo=${Gprotocolo}&tipo=` )
        .done(function(data) {
            callback(true)
        })
    }

    function salvarAssoc(tipo){
        $.get( `ProtocolosDocumentosSalvarDoc.asp?protocolo=${Gprotocolo}&tipo=${tipo}` )
        .done(function(data) {
            callback(true)
        })
    }
    function apagarRelacao(seletor){
        event.preventDefault()

        let tipo = $(`.${seletor} select`).val()
        $.get( `ProtocolosDocumentosRemoveAssoc.asp?protocolo=${Gprotocolo}&tipo=${tipo}` )
        .done(function(data) {
            getDocumentos(Gprotocolo)
        })
    }
</script>