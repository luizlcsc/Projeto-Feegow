<!--#include file="connect.asp"-->

<div class="row">
    <div class="col-xs-12">

        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">Formulário SUS</span>
            </div>
            <div class="panel-body">
                <div class="col-md-3">

                    <div class="btn-group btn-block">
                        <button type="button" class="btn btn-primary btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                            <i class="far fa-plus"></i> Inserir
                            <span class="caret ml5"></span>
                        </button>
                        <ul class="dropdown-menu" role="menu">

                            <li><a href="javascript:InserirSUS('PA');"><i class="far fa-plus"></i> Procedimento ambulatorial</a></li>
                            <li><a href="javascript:InserirSUS('APAC');"><i class="far fa-plus"></i> Procedimento de alta complexidade</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div class="col-xs-12">
        <div id="timeline" class="timeline-single mt30">


        </div>
    </div>
</div>
<script type="text/javascript">
    var $modal = $("#modal-table");

	$.ajax({
        url:'../feegow_components/sus/listar?pacienteId=<%=req("I")%>&I=N',
        success:function(data){
            $("#timeline").html(data);
        }
    });

    function InserirSUS(Tipo){
    	$.ajax({
    		url:'../feegow_components/sus?pacienteId=<%=req("I")%>&I=N&Tipo='+Tipo,
    		success:function(data){
    			$("#modal").html(data);
    		}
    	});
    	$modal.modal('show');
    };
</script>