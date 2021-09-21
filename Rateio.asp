<!--#include file="modal.asp"-->
<style type="text/css">
.tags, .chosen-container {
	width:100%!important;
}
.select-group{
	background: none;
	border: none;
	padding: 0;
	margin: 0;
	height: 16px;
}

.tree .tree-folder {
    cursor: default;
}
</style>

<script type="text/javascript">
    $(".crumb-active a").html("Regras de Repasse");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("configuração das regras que serão aplicadas para repasses de recebimentos");
    $(".crumb-icon a span").attr("class", "far fa-puzzle-piece");
</script>

<br />
<div class="panel">
    <div class="panel-body">
        <!-- PAGE CONTENT BEGINS -->

        <div class="row">
            <div class="col-sm-12">
                <div class="widget-box">
                    <div class="widget-header header-color-blue2">
                        <h4 class="lighter smaller">Configuração da árvore de exceções</h4>
                    </div>

                    <div class="widget-body">
                        <div class="widget-main padding-8" id="arvorerateio">
                        <%=server.Execute("arvorerateio.asp")%>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-sm-12">
                <div class="widget-box">
                    <div class="widget-header header-color-blue2">
                        <h4 class="lighter smaller">Descontos adicionais no repasse de acordo com a forma de recebimento</h4>
                    </div>

                    <div class="widget-body">
                        <div class="widget-main padding-8" id="">
                            <div class="row">
                                <div class="col-xs-12">
                                    <button type="button" onclick="repasseDesconto(0)" class="btn-xs btn btn-primary pull-right">
                                        <i class="far fa-plus"></i> Adicionar
                                    </button>
                                </div>
                            </div>
                            <hr />
                            <div class="row">
                                <div class="col-xs-12" id="repassesDescontos">
                                    <%=server.Execute("repassesDescontos.asp")%>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script type="text/javascript">
            var $assets = "assets";//this will be used in fuelux.tree-sampledata.js
        </script>

        <!-- PAGE CONTENT ENDS -->
    </div><!-- /.col -->
</div><!-- /.row -->




<script type="text/javascript">
function fRateio(T, I, A){
	$.ajax({
	   type:"GET",
	   url:"modalRateioFuncoes.asp?T="+T+"&I="+I+"&A="+A,
	   success:function(data){
		   $("#modal").html("Carregando...");
		   $("#modal-table").modal('show');
		   setTimeout(function(){$("#modal").html(data);}, 1000);
	   }
   });
}

function repasseDesconto(I) {
    $("#modal").html("Carregando...");
    $("#modal-table").modal("show");
    $.get("repasseDesconto.asp?I=" + I, function (data) {
        $("#modal").html(data);
    });
}

function removeDominio(I){
	var msg = 'Tem certeza de que deseja remover esta regras e todas as regras a ela atreladas?';
	if(confirm(msg)){
			   $.ajax({
			   type:"POST",
			   url:"removeRateioDominio.asp?I="+I,
			   success:function(data){
				   ajxContent('arvorerateio', '', 1, 'arvorerateio');
			   }
			   });
	}
}

$(document).ready(function() {
  setTimeout(function() {
    $("#toggle_sidemenu_l").click()
  }, 500);
})
</script>
<button type="button" class="hidden" onClick="ajxContent('arvorerateio', '', 1, 'arvorerateio');">Atualiza</button>

		<script src="assets/js/ace-elements.min.js"></script>
		<script src="assets/js/ace.min.js"></script>
