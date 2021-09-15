<!--#include file="connect.asp"-->
<%
PacienteID = req("P")
%>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">
            <span class="far fa-bar-chart"></span>Curvas de Evolução
        </span>
        <span class="panel-controls">
            <button type="button" class="btn btn-sm btn-success" onclick="curvaValores()"><i class="far fa-plus"></i> Valores </button>
            <div id="divCurvaValores" class="panel" style="width:620px; border:1px solid #ccc; position:absolute; margin-left:-552px; background-color:#fff; z-index:1000; cursor:default; display:none">
            </div>
        </span>
    </div>
    <div class="panel-body">
        <iframe id="frmAltura" src="curva_chart.asp?P=<%= PacienteID %>" scrolling="no" width="100%" frameborder=0  height="1000"></iframe>
    </div>
</div>
<script type="text/javascript">
    function curvaValores(A, I){
        $("#divCurvaValores").slideDown();
        $.post("curvavalores.asp?PacienteID=<%= PacienteID %>&A="+ A +"&I="+I, $("#frmCurvaValores").serialize(), function(data){ $("#divCurvaValores").html(data) });
    }
</script>