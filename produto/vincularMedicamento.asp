<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<style type="text/css">
    #vincularMedicamento .panel-heading{
        display: flex;
        justify-content: space-between;
    }
    #vincularMedicamento .form-control{
        width: inherit;
    }
    #vincularMedicamento .ordem{
        width:50%
    }
    #vincularMedicamento .formFlex{
        display: flex;
        align-items: center;
    }
</style>
<script src="produto/medicamentosVinculados.js"></script>
<div id='vincularMedicamento' class="panel">
    <div class='panel-heading'>
        <span>Vincular Medicamento</span>
        <div class='actionArea'>
            <button class="btn btn-primary" onclick="medicamentosVinculados.newRow()"><i class="far fa-plus"></i> Adicionar Exeção</button>
            <button class="btn btn-success" onclick="medicamentosVinculados.salvarVinculacao()"><i class="far fa-save"></i> Salvar</button>
        </div>
    </div>
    <div id='vinculos' class="panel-body">
        <div class="formFlex">
            <label class="col-md-4 control-label">Medicamento prescrito</label>
            <div class='col-md-8'>
                <select id='prescrito' class="form-control col-md-12" disabled>
                </select>
            </div>
        </div>
        
    </div>
</div>

<script language="javascript">

    medicamentosVinculados.init({
        medicamentoPrescritoID : <%response.write(req("I"))%>,
        actionWarp : 'vinculos'

    },'')

    showSalvar(false)
</script>