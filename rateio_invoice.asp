<!--#include file="connect.asp"-->
<%
InvoiceID = req("InvoiceID")
readonly = ""

if aut("|rateiocontaspagarA|") = 0 then
    readonly = " readonly "
end if
%>

<table class="table table-condensed">
<tr>
    <th style="padding-bottom: 20px">EMPRESA</th>
    <th style="width: 300px;padding-left:30px;padding-bottom:20px">
        <%
        TipoValor = "P"
        CompanyUnitNfeID = ""
        set tv = db.execute("select TipoValor, CompanyUnitNfeID from invoice_rateio ir where ir.InvoiceID="&InvoiceID&" limit 1")
        while  not tv.eof
            'TipoValor = tv("TipoValor")
            TipoValor = "P"
            CompanyUnitNfeID = tv("CompanyUnitNfeID")
            tv.movenext
        wend
        tv.close
        call quickfield("simpleSelect", "TipoValor", "", 2, TipoValor, "SELECT 'P' as id, 'PORCENTAGEM' as valor UNION ALL SELECT 'V' as id, 'VALOR' as valor", "valor", "") 
        %>
        <!--<input type="hidden" name="TipoValor" id="TipoValor" value="P">-->
    </th>
    <!--<th style="padding-left:30px;padding-bottom:20px">UNIDADE NFE</th>-->
</tr>
<%
set empresas = db.execute("select NomeFantasia, porcentagem from empresa e left join invoice_rateio ir on ir.InvoiceID="&InvoiceID&" AND CompanyUnitID=0  where sysActive=1")
while not empresas.eof
    %>
    <tr>
        <td><%=empresas("NomeFantasia")%></td>
        <td style="padding-left:30px">
            <input type="text" name="porcentagem" value="<%=fn(empresas("porcentagem"))%>" <%=readonly%> class="porcentagem form-control input-mask-brl">
            <input type="hidden" name="porcentagemid" value="0" class="porcentagemid">
        </td>
        <td style="width: 200px">
            <span class="valorparciallinha"></span>
        </td>
        <!--<td style="padding-left:70px">
            <input type="radio" name="CompanyUnitNfeID" value="0" <%
                'if CompanyUnitNfeID="0" then
                '    response.write("checked")
                'end if
            %>>
        </td>-->
        </tr>
    <%
empresas.movenext
wend
empresas.close
%>
<%

sqlUnidades = "Select COALESCE(p.Unidades, f.Unidades) Unidades from sys_users u left join profissionais p on u.idInTable = p.id and `Table` = 'profissionais' left join funcionarios f on u.idInTable = f.id and `Table` = 'funcionarios'  where u.id = " & Session("User")
set allUnidades = db.execute(sqlUnidades)
txtUnidades = ""
if not allUnidades.eof then 
    txtUnidades = allUnidades("Unidades")
end if

txtUnidades = Replace(txtUnidades, "|", "")
set filiais = db.execute("select sf.id, NomeFantasia, porcentagem from sys_financialcompanyunits sf left join invoice_rateio ir on ir.InvoiceID="&InvoiceID&" AND CompanyUnitID=sf.id  where not isnull(UnitName) and sysActive=1 and sf.id in ("&txtUnidades&") order by UnitName") 
'set filiais = db.execute("select sf.id, NomeFantasia, porcentagem from sys_financialcompanyunits sf left join invoice_rateio ir on ir.InvoiceID="&InvoiceID&" AND CompanyUnitID=sf.id  where not isnull(UnitName) and sysActive=1 order by UnitName")
while not filiais.eof
    %><tr><td><%=filiais("NomeFantasia")%></td>
        <td style="padding-left:30px">
            <input type="text" name="porcentagem" value="<%=fn(filiais("porcentagem"))%>" <%=readonly%> class="porcentagem form-control input-mask-brl">
            <input type="hidden" name="porcentagemid" value="<%=filiais("id")%>" class="porcentagemid">
        </td>
        <td style="width: 100px">
            <span class="valorparciallinha"></span>
        </td>
        <!--<td style="padding-left:70px">
            <input type="radio" name="CompanyUnitNfeID" value="<%=filiais("id")%>" <%
                'if CompanyUnitNfeID=filiais("id") then
                '    response.write("checked")
                'end if
            %>>
        </td>-->
        </tr>
    <%
filiais.movenext
wend
filiais.close
set filiais=nothing
%>
<tr>
    <td></td>
    <td>
        <b>
            Valor da conta: <span id="valorconta"></span>
            <br>
            Valor do rateio: <span id="valorrateioconta"></span>
        </b>
    </td>
</tr>
</table>
<% if aut("|rateiocontaspagarA|") = 1 then %>
<div class="row">
    <div class="col-md-12">
        <input type="button" class="pull-right btn btn-primary salvarrateio" value="Salvar">
    </div>
</div>
<% end if %>
<div class="row">
    <div class="col-md-12">
        <div id="errorateio"></div>
    </div>
</div>
</div>

<script>
<!--#include file="jQueryFunctions.asp"-->
$(function(){

$("#valorconta").text( $("#total").text() )
atualizarValorRateio();

$(".porcentagem").on("change", function(){
    atualizarValorRateio()
})
function atualizarValorRateio(){
    var total = 0;
    var TipoValor = $("#TipoValor").val();
    var valorInvoice = changeValue($("#valorconta").text())
    
    $(".porcentagem").each(function(i, value){
        var valor = 0;
        if(value.value != ""){
            valor = changeValue(value.value);
            if(TipoValor == "V"){
                total = total + valor;
            }else if(TipoValor == "P"){
                valor = valorInvoice * valor / 100;
                total = total + valor;
            }
        }
        $(this).closest('tr').find(".valorparciallinha").text("R$ " + valor.toFixed(2).toString().replace(".", ","));
    });
    
    var totalTxt = total.toFixed(2).toString().replace(".", ",")
    $("#valorrateioconta").text("R$ " + totalTxt )
}
function changeValue(valor){
    valor = valor.replace("R$ ", "")
    valor = valor.replace(".", "")
    valor = valor.replace(",", ".")
    valor = parseFloat(valor)
    return valor;
}

$(".salvarrateio").on('click', function(){
    $("#errorateio").html("");
    var TipoValor = $("#TipoValor").val();
    if(TipoValor == 0){
        $("#errorateio").html("<div class='alert alert-danger'>Escolha um tipo</div>");
        return ;
    }
    var porcentagens = 0;
    var porcentagens2 = 0;
    var porcentagemValue = "";
    var porcentagemId = "";
    var CompanyUnitNfeID = "";

    //CompanyUnitNfeID = $("input[name='CompanyUnitNfeID']:checked").val();
    //if(CompanyUnitNfeID == undefined){
    //    $("#errorateio").html("<div class='alert alert-danger'>Escolha uma unidade para gerar a nota fiscal</div>");
    //    return ;
    //}

    var Valorinvoice = changeValue($("#total").text());

    $(".porcentagem").each(function(i, value){
        if(value.value != ""){
            valor = changeValue(value.value)
            porcentagens2 += parseFloat(valor);

            if (TipoValor == "V"){
                valor = valor / parseFloat(Valorinvoice)
                porcentagens += parseFloat(valor);
                valor = parseFloat(valor.toFixed(4)) * 100
            }else{
                porcentagens += parseFloat(valor);
            }
            
            porcentagemValue += valor + "|";
        }else{
            porcentagemValue += value.value + "|";
        }
        
    });

    if(TipoValor == "P" && ( (parseFloat(porcentagens) < 99.9 || parseFloat(porcentagens) > 101) && parseFloat(porcentagens) > 0.01)){
        $("#errorateio").html("<div class='alert alert-danger'>A porcentagem deve somar 100%</div>");
        return ;
    }

    

    if(TipoValor == "V" && Valorinvoice != porcentagens2){
        $("#errorateio").html("<div class='alert alert-danger'>A soma dos valores deve ser igual ao valor da invoice</div>");
        return ;
    }

    $(".porcentagemid").each(function(i, value){
        porcentagemId += value.value + "|";
    });

    TipoValor = "P"
    console.log(porcentagemValue)
    $.post('invoice-rateio-save.asp',{
        porcentagem : porcentagemValue,
        invoiceId : '<%=InvoiceID%>',
        //CompanyUnitNfeID: CompanyUnitNfeID,
        porcentagemid : porcentagemId,
        tipoValor : TipoValor
    }, function(result) {
        $("#errorateio").html("<div class='alert alert-info'>" + result + "</div>");
    });
});

});
</script>
