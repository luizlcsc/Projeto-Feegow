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

<div id='vincularMedicamento' class="panel">
    <div class='panel-heading'>
        <span>Vincular Medicamento</span>
        <div class='actionArea'>
            <button class="btn btn-primary" onclick="newRow()"><i class="fa fa-plus"></i> Adicionar Exeção</button>
            <button class="btn btn-success" onclick="salvarVinculacao()"><i class="fa fa-save"></i> Salvar</button>
        </div>
    </div>
    <div class="panel-body">
        <div class="formFlex">
            <label class="col-md-4 control-label">Medicamento prescrito</label>
            <div class='col-md-8'>
                <select class="form-control col-md-12" disabled>
                    <option>1</option>
                </select>
            </div>
        </div>
        <div class="formFlex mt20">
            <label class="col-md-4 control-label">Medicamento Padrão</label>
            <div class='col-md-8'>
                <select class="form-control col-md-10" disabled>
                    <option>1</option>
                </select>
                <div class='btn-area col-md-3'>
                    <input type="number" class="form-control col-md-6 ordem" id="order" placeholder="Ordem">
                    <button class='btn btn-danger col-md-6'><i class="fa fa-trash"></i> Apagar</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script language="javascript">

</script>