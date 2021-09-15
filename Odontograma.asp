<!--#include file="connect.asp"-->

<div class="row">
    <div class="col-xs-12">

        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title"> Odontograma
                </span>
            </div>
            <div class="panel-body">
                <div class="col-md-3">
                    <div class="btn-group btn-block">
                        <button type="button" class="btn btn-primary btn-block dropdown-toggle" style="display:none" data-toggle="dropdown"
                                aria-expanded="false">
                            <i class="far fa-plus"></i> Odontograma
                        </button>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <div class="col-xs-12" id="odontograma-conteudo"></div>




</div>
<script type="text/javascript">

    $.get('https://components-legacy.feegow.com/index.php/odontograma/odontogramaAtendimento?P=<%=req("I")%>&U=<%=session("User")%>&L=<%=session("Banco")%>',
    function (data) {
        $("#odontograma-conteudo").html(data);
    });

    $('#btn-abrir-modal-odontograma').on('click', function () {
//        P = pacienteid
//        B = clinic * 999
//        O = operation
//        P = profissionalid
//        U = usuarioid
//        I = id da invoice/atendimeto/sla
        var first = $conteudoParaOdontograma.is(':empty');
        $('#feegow-odontograma-carregando').css('display', 'block');
        $conteudoParaOdontograma.html('').css('display', 'none');
        $odontogramaModal.modal('show');

        $.get('https://components-legacy.feegow.com/index.php/odontograma/odontogramaAtendimento?P=<%=req("I")%>&B=2898099&O=Invoice&U=<%=session("User")%>&I=<%=InvoiceID%>&load_all=' + first +'&L=<%=session("Banco")%>',
            function (data) {
                setTimeout(function () {
                    $('#feegow-odontograma-carregando').fadeOut(function () {
                        $conteudoParaOdontograma.html(data).fadeIn();
                    });
                }, 200);
            });

        $odontogramaModal.modal('show');
    });

</script>