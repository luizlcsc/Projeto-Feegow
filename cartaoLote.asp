<!--#include file="connect.asp"-->
<%

spl = split(ref("parcCC"), ", ")

soma = 0
for i=0 to ubound(spl)
    valorCheio = ccur(ref("ValorCheio" & spl(i)))
    soma = soma + valorCheio
    'response.Write( "." & valorCheio &"<br>")
next

%>
<div class="col-md-2">
    <b>
        Valor cheio:
        <h3 class="mb0">R$  <%= fn(soma) %></h3>
        <input type="hidden" name="Soma" id="Soma" value="<%=soma %>" />
    </b>
</div>
<%=quickfield("currency", "ValorBaixar", "Valor a baixar", 2, "", "", "", "") %>
<%=quickfield("datepicker", "DataCredito", "Data do crédito", 2, date(), " text-right", "", "") %>
<div class="col-md-1">
    <label>&nbsp;</label><br />
    <button type="button" class="btn btn-md btn-success"><i class="far fa-check"></i> Baixar</button>
</div>
<div class="col-md-4" id="lalala">

</div>

<script type="text/javascript">
    $("#ValorBaixar").on("keyup", function () {
        $.post("recalcCartaoLote.asp", $("input[name=parcCC], input[name^=ValorCheio], #ValorBaixar, #DataCredito, #Soma").serialize(), function (data) {
            $("#lalala").html(data);
        });
    });

<!--#include file="JQueryFunctions.asp"-->
</script>