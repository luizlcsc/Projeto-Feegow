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
        <h3 style="margin-top: 5px !important">R$  <%= fn(soma) %></h3>
        <input type="hidden" name="Soma" id="Soma" value="<%=soma %>" />
    </b>
</div>
<% IF false THEN %>
<span style="display: none">
<% END IF %>
    <%=quickfield("currency", "ValorBaixar", "Valor a baixar", 2, "", "", " disabled ", " disabled ") %>
<% IF false THEN %>
</span>
<% END IF %>



<%=quickfield("datepicker", "DataCredito", "Data do crédito", 2, "", " text-right", "", " onclick='$(`#DataOriginal`).prop(`checked`, false)' ") %>
<div class="col-md-2 pt30">
    <input type="checkbox" name="DataOriginal" id="DataOriginal" value="S" checked> Usar data original
</div>

<div class="col-md-1">
    <label>&nbsp;</label><br />
    <button type="button" class="btn btn-md btn-success" onclick="baixarTudo()"><i class="far fa-check"></i> Baixar</button>
</div>

<script type="text/javascript">

    function formatNumber(num,fix){
        if(!num){
            return null;
        }
        return Number(num).toLocaleString('de-DE', {
         minimumFractionDigits: fix,
         maximumFractionDigits: fix
       });
    }
    function toNumber(num){
        if(!num){
            return null;
        }
        return Number(num.replace(".","").replace(",","."));
    }

    function recalcValorBaixar(){
        var ParTotal = 0;

        $("[name='parcCC']:checked").each((a,b) => {
            ParTotal += toNumber($(b).parents("tr").find("[name^='ValorCredito']").val(),2)
        });

        $("#ValorBaixar").val(formatNumber(ParTotal));
    }

    recalcValorBaixar()


    $("#ValorBaixar").on("keyup", function () {
        $.post("recalcCartaoLote.asp", $("input[name=parcCC], input[name^=ValorCheio], #ValorBaixar, #DataCredito, #Soma").serialize(), function (data) {
            eval(data)
        });
    });

    var arraysProcessos = [];
    function baixarTudo(){
        var dataCredito = $("#DataCredito").val();
        arraysProcessos = [];
        $("[name='parcCC']:checked").each((k,item)=>{
          arraysProcessos.push({
             value:$(item).attr("value"),
             parcelas:$(item).attr("parcelas"),
             parcela:$(item).attr("parcela"),
             dataCredito: dataCredito
          })
        });



        nextProcesso();
    }

    function nextProcesso(){

        let item = arraysProcessos.shift();

        if(!item){
            new PNotify({
                title: 'Processo concluído!',
                text: '',
                type: 'success',
                delay: 1000
            });
            return;
        }
        //setTimeout(() =>nextProcesso(),1500);
        baixa(item.value, 'B', item.parcela, item.parcela, "", item.dataCredito);
    }

$("#DataOriginal").change(function(){
    if($(this).prop("checked")==true){
        $("#DataCredito").val("");
    } else {
        $("#DataCredito").val("<%= date() %>");
    }
});

<!--#include file="JQueryFunctions.asp"-->
</script>