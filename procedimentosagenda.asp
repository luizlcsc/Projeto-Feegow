<!--#include file="connect.asp"-->

<%
Acao = ref("A")
LocalID = ref("LocalID")
Convenios = ref("Convenios")
GradeApenasConvenios = ref("GradeApenasConvenios")
GradeApenasProcedimentos = ref("GradeApenasProcedimentos")
EquipamentoID = ref("EquipamentoID")
rdValorPlano= ref("Forma")
ConvenioID= ref("ConvenioSelecionado")&""
PlanoID = ref("PlanoSelecionado")&""
linhas = ref("linhas")
if ConvenioID = ""then
ConvenioID = 0
end if
if linhas = "" then
    linhas = ref("I")
end if

if Acao="I" then

    call linhaAgenda(linhas, ProcedimentoID, Tempo, rdValorPlano, Valor, PlanoID, ConvenioID, Convenios, EquipamentoID, LocalID, GradeApenasProcedimentos, GradeApenasConvenios)
end if
%>
<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->
$(function(){
    $('select[id^="ConvenioID"],input[id^="rdValorPlanoP"]').change(ele=>{
        let convenio = $(ele.target).val()
        if(convenio){
            let linha = '<%=linhas%>';
           $('#ProcedimentoID'+linha).attr("data-camposuperior","ConvenioID"+linha)
           s2aj("ProcedimentoID"+linha, 'procedimentos', 'NomeProcedimento', 'ConvenioID'+linha, '','agenda');
        }
    })
    // console.log("<%=linhas%>")
    $(".valorprocedimento, .linha-procedimento").on('change', function(){
        somarValores();
        // dispEquipamento();

    });
    $("#Tempo<%=linhas%>").change(function(){
        dispEquipamento();
    })
    function dispEquipamento(){
        $.post("AgendaParametros.asp?tipo=Equipamento", $("#formAgenda").serialize(), function(data){
            eval(data);
        });
    }
});

$(document)
</script>