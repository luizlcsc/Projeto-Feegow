
<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<style type="text/css">
    #vincularMedicamentoConvenio .panel-heading{
        display: flex;
        justify-content: space-between;
    }
    .modalConvenio table{
        width:100%
    }
    .clearText{
        color: transparent;
        pointer-events: none;
    }
    #planosSelect.container-fluid{
        margin-right: 0;
        margin-left: 0;
        padding-left: 0;
        padding-right: 0;
        border: 1px solid #dedede;
        padding: 10px 0;
    }
</style>
<script src="convenio/utilitarios.js"></script>
<script src="convenio/medicamentosConvenio.js"></script>

<div id='vincularMedicamentoConvenio' class="panel">
    <div class='panel-heading'>
        <span>Cadastro de Medicamento por Convênio</span>
        <div class='actionArea'>
            <button class="btn btn-primary" onclick="medicamentosConvenio.modalMedicamentos('Criar')"><i class="far fa-plus"></i> Inserir</button>
        </div>
    </div>
    <div id='medicamentoConvenio' class="panel-body">
        <table class="table table-striped">
            <thead>
                <th>Convenios</th>
                <th>Medicamento prescrito</th>
                <th>Medicamento Referência</th>
                <th>Ações</th>
            </thead>
            <tbody id='targetMedicamentos'>
            </tbody>
        </table>
    </div>
</div>





<script language="javascript">

    medicamentosConvenio.init({
        'seletor': 'vincularMedicamentoConvenio'
    },{utilitarios,loadInfos})

    $(document).ready(function(){
        $(".crumb-active a").html("Medicamento Por Convenio");
        $(".crumb-icon a span").attr("class", "far fa-");
    });

    function loadInfos(){
        utilitarios.request('convenio/getMedicamentos','',(data)=>{
            data = JSON.parse(data)
            $('#targetMedicamentos').html('')
            data.map(linha=>{
                montaLinha(linha)
            })
        })
    }
    loadInfos()

    function montaLinha(linha){

        let html = `
            <tr id='linha_${linha.id}' data-id='${linha.idDelete}'>
                <td class="convenios" data-convenios='${linha.convenios}'>${linha.conveniosnomes}</td>
                <td data-prescrito='${linha.produtoPrescrito}'>${linha.produtoPrescritoNome}</td>
                <td data-referencia='${linha.produtoReferencia}'>${linha.produtoReferenciaNome}</td>
                <td>
                    <button class='btn btn-warning btn-xs' onClick='medicamentosConvenio.modalMedicamentos("Editar",${linha.id})'><i class="far fa-pencil"></i> Editar</button>
                    <button class='btn btn-danger btn-xs' onClick='medicamentosConvenio.removeDireto(${linha.id})'><i class="far fa-trash"></i> Apagar</button>
                </td>
            </tr>
        `
        $('#targetMedicamentos').append(html)
    }


</script>