<!--#include file="connect.asp"-->

<div class="tabbable">
	<ul class="nav nav-tabs" id="myTab">
		<li class="active">
			<a data-toggle="tab" href="#NovaProposta">
				<i class="blue far fa-plus"></i>
				Nova
			</a>
		</li>

		<li>
			<a data-toggle="tab" href="#ListaPropostas">
				<i class="far fa-list"></i> Anteriores
			</a>
		</li>

		<li class="dropdown hidden">
			<a data-toggle="dropdown" class="dropdown-toggle" href="#">
				Ajustes &nbsp;
				<i class="far fa-caret-down bigger-110 width-auto"></i>
			</a>

			<ul class="dropdown-menu dropdown-info">
				<li>
					<a data-toggle="tab" href="#dropdown1">@fat</a>
				</li>

				<li>
					<a data-toggle="tab" href="#dropdown2">@mdo</a>
				</li>
			</ul>
		</li>
	</ul>

	<div class="tab-content">
		<div id="NovaProposta" class="tab-pane in active row">
			<div class="col-xs-8">


<!--#include file="propostatabela.asp"-->



            </div>

            <div class="col-xs-4">
                <div class="widget-box transparent">
                    <div class="widget-header widget-header-small">
                        <h4 class="blue smaller">
                            <i class="far fa-beaker icon-beaker orange"></i>
                            Itens da Proposta
                        </h4>
            
                        <div class="widget-toolbar action-buttons">
                            
                                <a class="blue tooltip-info" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar medicamento ou f&oacute;rmula para futuras prescri&ccedil;&otilde;es" data-rel="tooltip" data-placement="top" title="" onclick="modalMedicamento('', 0)">
                                    <i class="far fa-plus icon-plus blue"></i>
                                </a>
                            
                        </div>
                    </div>
            
                    <div class="widget-body">
                        <div class="widget-main padding-8">
                            
            				<div class="row">
                                <div class="input-group">
                                <input id="FiltroProItens" class="form-control input-sm refina" autocomplete="off" placeholder="Filtrar procedimento..." type="text">
                                <span class="input-group-btn">
                                <button class="btn btn-sm btn-default" onclick="ListaProItens($('#FiltroProItens').val(), '', '')" type="button">
                                <i class="far fa-filter icon-filter bigger-110"></i>
                                Buscar
                                </button>
                                </span>
                                </div>
            				</div>
                            <div class="row">
                                <div id="ListaProItens" class="profile-feed" style="overflow:scroll; height:270px; overflow-x:hidden;" data-height="270">
                                    Carregando...
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            
                <div class="hr hr2 hr-double"></div>
            
                <div class="space-6"></div>
            </div>


		</div>

		<div id="ListaPropostas" class="tab-pane">
			<p>Food truck fixie locavore, accusamus mcsweeney's marfa nulla single-origin coffee squid.</p>
		</div>
	</div>
</div>

<script>

function ListaProItens(Filtro, X, Aplicar){
	$("#ListaProItens").html('Buscando...');
	$.post("ListaProItens.asp?Filtro="+Filtro,{
		   X: X,
		   Aplicar: Aplicar
		   },function(data,status){
	  $("#ListaProItens").html(data);
	});
}

$('#FiltroProItens').keypress(function(e){
    if ( e.which == 13 ){
		ListaProItens($('#FiltroProItens').val(), '', '');
		return false;
	}
});


ListaProItens('', '', '');
</script>