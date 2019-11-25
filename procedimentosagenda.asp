<!--#include file="connect.asp"-->
<%
Acao = ref("A")
LocalID = ref("LocalID")
Convenios = ref("Convenios")
GradeApenasConvenios = ref("GradeApenasConvenios")
GradeApenasProcedimentos = ref("GradeApenasProcedimentos")
EquipamentoID = ref("EquipamentoID")
rdValorPlano= ref("Forma")
ConvenioID= ref("ConvenioSelecionado")
PlanoID = ""

if Acao="I" then
    n = ref("I")
    call linhaAgenda(n, ProcedimentoID, Tempo, rdValorPlano, Valor, PlanoID, ConvenioID, Convenios, EquipamentoID, LocalID, GradeApenasProcedimentos, GradeApenasConvenios)
end if
%>
<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->

$(function(){
    $(".valorprocedimento, .linha-procedimento").on('change', function(){

                somarValores();
            });
    <% if EquipamentoID&"" <> "" and EquipamentoID&""<> "0" then %>
        $('#EquipamentoID<%=n %>').select2("destroy");
        $('#EquipamentoID<%=n %>').removeClass("select2-single");
        $('#EquipamentoID<%=n %>').hide();
    <% end if %>
});

$(document)
</script>