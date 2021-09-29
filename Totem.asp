<!--#include file="connect.asp"-->



<div class="text-center">
    <br />
    <br />
    <img src="logo/altaclinicas.png" />
    <br />

    <hr />
    <br />

    <button id="btnGerar" style="width:500px; height:100px;" type="button" onclick="saveGuiche('Sta', 0, 'Imprimir')" class="btn btn-lg btn-primary">IMPRIMIR SENHA DE ATENDIMENTO</button>
    <h1 id="divImprimir" class="hidden"><i class="far fa-circle-o-notch fa-spin"></i> IMPRIMINDO SENHA...</h1>
</div>

<script type="text/javascript">
    function saveGuiche(Action, Ticket, Val) {
        $("#btnGerar").addClass("hidden");
        $("#divImprimir").removeClass("hidden");
        $.post("saveGuiche.asp", {
            Action: Action,
            Ticket: Ticket,
            Val: Val
        }, function (data) {
            eval(data);
        });
    }
</script>