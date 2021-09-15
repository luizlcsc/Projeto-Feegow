<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%

tipo = req("I")

if tipo = "N" then
    NomeArquivo = ""
    Obrigatorio = 0
    Existe = 0
else
    sql = "select NomeArquivo, Obrigatorio from tipos_de_arquivos where id="&treatvalzero(tipo)
    set tipo = db.execute(sql)
    if not tipo.eof then
        NomeArquivo = tipo("NomeArquivo")
        Obrigatorio = tipo("Obrigatorio")
        Existe = 1
    end if
end if


%>
<style type="text/css">
    #tipoDeArquivo .panel-heading{
        display: flex;
        justify-content: space-between;
    }
    #tipoDeArquivoForm{
        display:flex
    }
    .checkStyle{
        display:flex;
        align-items: center;
    }
</style>


<div id='tipoDeArquivo' class="panel">
    <div class="panel-heading">
        <span class="panel-title">Cadastro de tipo de arquivo</span>
         <div class='actionArea'>
            <button class="btn btn-success" onclick="saveTipo()"><i class="far fa-save"></i> Salvar</button>
        </div>
    </div>
    <div class="panel-body">
        <form id='tipoDeArquivoForm'>
            <div class="form-group col-md-6">
                <label for="NomeArquivo">Tipo de Arquivo</label>
                <input type="text" name="NomeArquivo" class="form-control" id="NomeArquivo" value='<%= NomeArquivo %>'>
            </div>
             <div class="form-group col-md-2 checkStyle">
                <label class="checkbox-inline">
                    <input type="checkbox" name="Obrigatorio"  id="Obrigatorio" <% if Obrigatorio =1 then  response.write(" checked ") end if  %> >Obrigatório
                </label>
            </div>
        </form>
    </div>
</div>


<script language="javascript">
    let acao = '<%= req("I")%>' ;

    console.log(acao)

    function saveTipo(){
        let NomeArquivo=$('#NomeArquivo').val()
        let Obrigatorio= $('#Obrigatorio').prop('checked')

        if(Obrigatorio){
            Obrigatorio=1
        }else{
            Obrigatorio=0
        }

        let target = 'tipoArquivo/updateTipoArquivo.asp'
        let params = '?id=<%=req("I")%>&NomeArquivo='+NomeArquivo+'&Obrigatorio='+Obrigatorio+'&Existe=<%=Existe%>'

        if(acao){
            target = 'tipoArquivo/saveTipoArquivo.asp'
        }

        $.get( target+params )
        .done(function(data) {
            new PNotify({
                title: 'Tipo de arquivo atualizado com sucesso',
                type: 'success',
                delay: 1500
            });
            let url = window.location.href
            url = "./?P=tipos_de_arquivos&Pers=Follow"
            window.location.href = url
        })
    }


</script>