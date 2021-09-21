<!--#include file="connect.asp"-->

<%

DocumentoTipo = ref("DocumentoTipo")
DocumentoID = ref("DocumentoID")
ProfissionalID = ref("ProfissionalID")

set DocumentoTipoID = db.execute("select id from cliniccentral.tipoprontuario t where t.Tipo ='"&DocumentoTipo&"'")
if not DocumentoTipoID.eof then
    sql = "select * from arquivocompartilhamento where ProfissionalID="&ProfissionalID&" and CategoriaID="&DocumentoTipoID("id")&" and DocumentoID="&DocumentoID
    'response.write sql
    set result =  db.execute(sql)
    if not result.eof then
        Compartilhados = result("Compartilhados")
    end if
end if

%>
<div class="row">
    <div class="col-md-12">
        <form id="frmCompartilharPront" name="frmCompartilharPront" >
            <div class="panel">
                <div class="panel-heading">
                    <span class="panel-title">
                        <i class="far fa-group"></i>Escolha os profissionais que podem ver este arquivo
                    </span>
                    <span class="panel-controls">
                        <button id="btnSalvarCompartilharPront" type="submit" class="btn btn-sm btn-primary"> <i class="far fa-save"></i> Salvar </button>
                    </span>
                </div>
                <div class="panel-body">
                    <div class="panel panel-default">
                    <div class="row">
                        <div class="col-md-12">
                            <%= quickfield("multiple", "Compartilhados" , "  ", 16, Compartilhados , "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais  WHERE sysActive=1 AND Ativo='on'  ORDER BY Ordem, NomeProfissional)t;", "NomeProfissional", " empty ")%>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script>

$(document).ready(function(){
    
});

$("#frmCompartilharPront").submit(function(){

    $.post("SaveCompartilhamento.asp?T=arquivo",{
           CompartilhamentoID: 3,
           DocumentoTipo:'<%=DocumentoTipo%>', 
           DocumentoID:<%=DocumentoID%>, 
           Compartilhados:$("#Compartilhados").val()+"", 
           ProfissionalID:<%=ProfissionalID%>
           },
           function(data,status){
               if (status == "success"){
                    showMessageDialog("Salvo com sucesso", "success");
                    closeComponentsModal();
                    reloadTimeline();
                }else{
                    showMessageDialog("Erro ao Salvar alterações tente novamente mais tarde", "danger");
                }
            });

	return false;
});

<!--#include file="jQueryFunctions.asp"-->

</script>