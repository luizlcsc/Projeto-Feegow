<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Permissões");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Compartilhar Prontuário");
    $(".crumb-icon a span").attr("class", "far fa-share-alt");
</script>

<%
id = req("I")
set tipoProntuario = db.execute("select id, NomeCategoria from cliniccentral.tipoProntuario where sysActive=1")
%>

<form method="post" id="frmCompartilharPront" name="frmCompartilharPront" >
    <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">
                    <i class="far fa-share-alt"></i>Compartilhar Prontuário
                </span>
                <span class="panel-controls">
                    <button id="btnSalvarCompartilharPront" type="submit" class="btn btn-sm btn-primary"> <i class="far fa-save"></i> Salvar </button>
                </span>
            </div>
        <div class="panel-body">
        <div class="panel panel-default">
            <div class="row">
                <div class="col-md-12 qf">
                    <table class="table table-fixed">
                        <thead>
                            <tr class="info">
                                <th width="20%">TIPO ARQUIVO</th>
                                <th width="30%">COMPARTILHAMENTO</th>
                                <th width="60%">PROFISSIONAIS</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        i=1
                        while not tipoProntuario.eof
                        set result =  db.execute("select * from prontuariocompartilhamento where ProfissionalID="&id&" and CategoriaID ="&tipoProntuario("id")&" ")
                        tipo= ""
                        profissionais = ""

                        if not result.eof then
                            tipo = result("TipoCompartilhamentoID")
                            profissionais = result("Compartilhados")
                        end if
                        
                        %>
                            <tr>
                                <td >
                                    <%=tipoProntuario("NomeCategoria")%>
                                </td>
					            <td >
                                    <%= quickfield("simpleSelect", "RegraCompartilhamento"&tipoProntuario("id") , " ", 12, tipo , "select id, Nome from cliniccentral.tipocompartilhamento", "Nome", " semVazio "" onchange=""habilitaProfssionais("&tipoProntuario("id")&");""") %>
                                </td>
                                <td >
                                    <%= quickfield("multiple", "Profissionais"&tipoProntuario("id") , " ", 12, profissionais , "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais WHERE sysActive=1 AND Ativo='on' ORDER BY Ordem, NomeProfissional)t;", "NomeProfissional", " empty ")%>
                                    <span class="exibicao-profissional-<%=tipoProntuario("id")%>"></span>
                                </td>
                            </tr>
                        <%
                            i=i+1
                        tipoProntuario.movenext
                        wend
                        tipoProntuario.close
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
                <div class="row">

                </div>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->

$(document).ready(function(){
    $("select[id*=RegraCompartilhamento]").each(function(i) {
        habilitaProfssionais(i+1);
    });
});

$("#frmCompartilharPront").submit(function(){
    $.post("SaveCompartilhamento.asp?I=<%=id%>", $("#frmCompartilharPront").serialize(), function(data, status)
    { 
        eval(data); 
        if (status == "success"){
            showMessageDialog("Salvo com sucesso", "success");
        }else{
            showMessageDialog("Erro ao Salvar alterações tente novamente mais tarde", "danger");
        }

    });
    
	return false;
});

function habilitaProfssionais(control){
    var $exibicaoProfissional = $(".exibicao-profissional-"+control),
        regra = $("#RegraCompartilhamento"+control).val();

    $("#qfprofissionais"+control +"  > div > button").hide();
    $exibicaoProfissional.show();
    //$("#qfprofissionais"+control +"  > div > button").addClass('disabled');

    if(regra == 1){
        $exibicaoProfissional.html("Todos");
    }
    if(regra == 2){
        $exibicaoProfissional.html("Somente o próprio");
    }

    if(regra==3){
        $("#qfprofissionais"+control +"   > div > button").show();
        $exibicaoProfissional.hide();
       // $("#qfprofissionais"+control +"   > div > button").removeClass('disabled');
    }else{
        $exibicaoProfissional.show();
    }
}

</script>