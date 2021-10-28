<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
PacienteID = req("p")
%>
<div class="panel-heading">
<span class="panel-title">
<i class="far fa-stethoscope"></i>
Diagn&oacute;sticos
<small>
<i class="far fa-double-angle-right"></i>
- hist&oacute;rico
</small>
</span>
</div>

<div class="panel-body">
	<div class="col-xs-12 col-md-8" id="ListaDiagnosticos">
		<!--#include file="ListaDiagnosticos.asp"-->
    </div>
    <div class="col-xs-12 col-md-4">
        <div class="panel">
            <div class="panel-heading">
              <span class="panel-title">
                    <i class="far fa-stethoscope"></i> Busca na CID-10
              </span>

            </div>

            <div class="panel-menu">




                        <div class="input-group">
                        <input id="FiltroCID" class="form-control input-sm refina" autocomplete="off" placeholder="Filtrar doen&ccedil;a..." type="text">
                        <span class="input-group-btn">
                        <button id="btnMF" class="btn btn-sm btn-default" onclick="ListaCID($('#FiltroCID').val(), '')" type="button">
                        <i class="far fa-filter icon-filter bigger-110"></i>
                        Buscar
                        </button>
                        </span>
                        </div>




            </div>
            <div class="panel-body  scroller-md scroller-pn pn scroller scroller-active" style="overflow-y: scroll!important;">
                <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                    <tbody id="ListaCID">
                        <tr>
                            <td>
                                <!--Carregando...-->
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>


        <div class="hr hr2 hr-double"></div>

        <div class="space-6"></div>
    </div>
</div>
<div class="panel-footer text-right">
        <button class="btn btn-primary btn-fechar-diagnostico" type="button"><i class="far fa-save"></i> <span class="btn-save-form-text">Salvar</span></button>
</div>

<div class="row">
    <div class="col-md-12">
    </div>
</div>
<script type="text/javascript">
 $(".btn-fechar-diagnostico").click("click", function () {
    $(".mfp-close").click();
    $("#tabDiagnosticos").click();
});

$("#btnDiagnostico").click(function(){
	$.ajax({
		type:"POST",
		url:"saveDiagnostico.asp",
		data:$("#frm").serialize(),
		success:function(data){

            gtag('event', 'novo_diagnostico', {
                'event_category': 'diagnostico',
                'event_label': "Prontuário > Diagnósticos > Salvar",
            });

			cid10(0);
		}
	});
});


$('#FiltroCID').keypress(function(e){
    if ( e.which == 13 ){
		ListaCID($('#FiltroCID').val(), '');
		return false;
	}
});


function ListaCID(Filtro, Aplicar){
	$.post("ListaCID.asp?p=<%=PacienteID%>", {
		   Filtro: Filtro,
		   Aplicar: Aplicar
		   },function(data,status){
	  $("#ListaCID").html(data);
	});
}


<!--#include file="jQueryFunctions.asp"-->
</script>