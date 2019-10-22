<!--#include file="connect.asp"-->
<h4>Propostas Emitidas</h4>

<form method="get" target="_blank" action="PrintStatement.asp" id="PropostaForm">
	<input type="hidden" name="R" value="rPropostas">
    <div class="row">
        <%= quickfield("datepicker", "DataDe", "Emitida de", 2, dateadd("m", -1, date()), "", "", "") %>
        <%= quickfield("datepicker", "DataAte", "até", 2, date(), "", "", "") %>
        <%=quickfield("multiple", "Status", "Status", 2, "|1|2|3|4|5|", "select id, NomeStatus from propostasstatus", "NomeStatus", " required ") %>
        <%= quickfield("empresaMulti", "UnidadeID", "Unidades", 3, session("Unidades"), "", "", "") %>
        <div class="col-md-3">
            Agrupar por<br />
            <div class="radio-custom radio-info"><input type="radio" name="Agrupar" id="AgruparStatus" value="Status" checked /><label for="AgruparStatus">Status atual</label></div>
            <div class="radio-custom radio-info"><input type="radio" name="Agrupar" id="AgruparUsuario" value="Usuario" /><label for="AgruparUsuario">Usuário emitente</label></div>
            <div class="radio-custom radio-info hidden"><input type="radio" name="Agrupar" id="AgruparProcedimento" value="Procedimento" /><label for="AgruparProcedimento">Procedimento</label></div>
        </div>
        <div class="2">
            <button class="btn btn-info mt25 btnSubmit" type="button">Gerar</button>
        </div>
    </div>
</form>
<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
    function formatDate(DateStr) {
        DateStr = DateStr.replaceAll("/","-");
        var DateArr = DateStr.split("-");
        var NewDate = DateArr[2]+"-"+DateArr[1]+"-"+DateArr[0];

        return new Date(NewDate);
    }

    $(".btnSubmit").click(function() {
        var DataDe = formatDate($("#DataDe").val());
        var DataAte = formatDate($("#DataAte").val());

        var timeDiff = Math.abs(DataAte.getTime() - DataDe.getTime());
        var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));

        if("<%=session("Banco")%>" === "clinic1651" && diffDays > 8){
            alert("Diminua o intervalo de tempo.");
        }else{
            $("#PropostaForm").submit();
        }
    });

    String.prototype.replaceAll = function(search, replacement) {
        var target = this;
        return target.replace(new RegExp(search, 'g'), replacement);
    };
</script>