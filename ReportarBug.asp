<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%

Tela = req("Tela")
Parametros = req("query")

Reportar = ref("Reportar")

if tela <> "" then
    set TelaSQL = db.execute("SELECT id FROM cliniccentral.videoaula WHERE Recurso='"&Tela&"'")
    if not TelaSQL.eof then
        TelaID = TelaSQL("id")
    end if
end if

if Reportar&""="1" then

     Reportar = ref("Reportar")
     TelaOriginal = ref("TelaOriginal")
     TelaID = ref("TelaID")
     DescricaoErro = ref("DescricaoErro")
     Parametros = ref("Parametros")

    dbc.execute("INSERT INTO `cliniccentral`.`bugs` (`Descricao`, `UnidadeID`, `Parametros`, `TelaID`, `sysUser`, `LicencaID`, `TelaOriginal`) VALUES ('"&DescricaoErro&"', "&treatvalzero(session("UnidadeID"))&", '"&Parametros&"', "&treatvalzero(TelaID)&", "&session("User")&", "&LicenseID&", '"&TelaOriginal&"'); ")

    response.write("OK")
    Response.End
end if

%>
<div class="row">
    <div class="col-md-12">
        <h3><i class="far fa-bug"></i> Reportar um bug</h3>
        <p>Nos avise sobre um problema ou funcionalidade com erro.</p>
    </div>

    <%= quickField("simpleSelect", "LocalErro", "Onde está o problema?", 6, TelaID, "select * from cliniccentral.videoaula where 1 order by Informacoes", "Informacoes", "") %>

    <%=quickfield("memo", "ReportErro", "O que ocorreu?", 12, "", "", "", "")%>

    <div class="col-md-12 mt10">
        <div class="alert alert-default">
            <strong><i class="far fa-concierge-bell"></i> Dica: </strong>
             Forneça o máximo de detalhes do ocorrido. Dessa forma conseguiremos lhe auxiliar da forma mais eficiente.
             <br>
             <br>
             <i>Ex: "Não consigo criar um agendamento para <strong>hoje</strong> na agenda do <strong>Dr. João</strong>."</i>
        </div>
    </div>

</div>

<div class="row">
    <div class="col-md-2 col-md-offset-10 mt15">
        <button onclick="ReportarErro()" type="button" class="btn btn-success"><i class="far fa-save"></i> Reportar</button>
    </div>
</div>

<script >

function ReportarErro(){
    $.post("ReportarBug.asp", {
        Reportar: 1,
        TelaOriginal: "<%=Tela%>",
        TelaID: $("#LocalErro").val(),
        DescricaoErro: $("#ReportErro").val(),
        Parametros: '<%=Parametros%>',
    }, function (data){
        showMessageDialog("Vamos investigar isso o mais rápido possível. Se precisar de ajuda, entre em contato com o time de sucesso. ", "success", "Obrigado por relatar este bug.");
        closeComponentsModal();
    });
}

<!--#include file="jQueryFunctions.asp"-->
</script>