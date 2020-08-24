<!--#include file="connect.asp"-->
<%
PacienteID = req("P")
%>

<div class="bs-component">
    <div class="panel">
    <div class="panel-heading">
        <span class="panel-title">
            <span class="fa fa-bar-chart"></span>Curvas de Evolução</span>
        </span>
        <span class="panel-controls">
            <button type="button" class="btn btn-sm btn-success" onclick="curvaValores()"><i class="fa fa-plus"></i> Valores </button>
            <div id="divCurvaValores" class="panel" style="width:500px; border:1px solid #ccc; position:absolute; margin-left:-420px; background-color:#fff; z-index:1000; cursor:default; display:none">
            </div>
        </span>
    </div>
    <div class="panel-body">
        <ul class="nav nav-pills mb20 pull-right">
        <li class="active">
            <a href="#tab17_1" data-toggle="tab">Crescimento</a>
        </li>
        <li>
            <a href="#tab17_2" data-toggle="tab">Peso</a>
        </li>
        <li>
            <a href="#tab17_3" data-toggle="tab">Perímetro Cefálico</a>
        </li>
        <li>
            <a href="#tab20_4" data-toggle="tab">imc</a>
        </li>
        </ul>
        <div class="clearfix"></div>
        <div class="tab-content br-n pn">
        <div id="tab17_1" class="tab-pane active">
            <div class="row">
            <div class="col-md-12">
                <p class="text-center">
                    <iframe id="frmAltura" src="Curva_Chart.asp?P=<%= PacienteID %>&T=1" scrolling="no" width="840" frameborder=0 height="450"></iframe>
                </p>
            </div>
            </div>
        </div>
        <div id="tab17_2" class="tab-pane">
            <div class="row">
            <div class="col-md-12">
                <p class="text-center">
                    <iframe id="frmPeso" src="Curva_Chart.asp?P=<%= PacienteID %>&T=10" scrolling="no" width="840" frameborder=0 height="450"></iframe>
                </p>
            </div>
            </div>
        </div>
        <div id="tab17_3" class="tab-pane">
            <div class="row">
            <div class="col-md-12">
                <p class="text-center">
                    <iframe id="frmPerimetro" src="Curva_Chart.asp?P=<%= PacienteID %>&T=16" scrolling="no" width="840" frameborder=0 height="450"></iframe>
                </p>
            </div>
            </div>
        </div>
        <div id="tab20_4" class="tab-pane">
            <div class="row">
            <div class="col-md-12">
                <p class="text-center">
                    <iframe id="frmPerimetro" src="Curva_Chart.asp?P=<%= PacienteID %>&T=15" scrolling="no" width="840" frameborder=0 height="450"></iframe>
                </p>
            </div>
            </div>
        </div>
        </div>
    </div>
    </div>
<div id="source-button" class="btn btn-primary btn-xs" style="display: none;">&lt; &gt;</div></div>
<script type="text/javascript">
function curvaValores(A, I){
    $("#divCurvaValores").slideDown();
    $.post("curvavalores.asp?PacienteID=<%= PacienteID %>&A="+ A +"&I="+I, $("#frmCurvaValores").serialize(), function(data){ $("#divCurvaValores").html(data) });
}
</script>