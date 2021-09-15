<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<% 
guiaId = req("guiaId")
tabela = req("tabela")
inputValorPago = req("valor")

count = 0
countGuias = 0
if(UCase(tabela) = UCase("GuiaHonorarios")) then 
    set lotesEnv = db.execute("SELECT * FROM tissprocedimentoshonorarios WHERE GuiaID = "&guiaId&"")
    set tissGuia = db.execute("SELECT *, procedimentos as TotalGeral FROM tissguiahonorarios WHERE id = "&guiaId&"")
    despesas = empty

    
    set countRows = db.execute("SELECT count(*) as id FROM tissprocedimentoshonorarios WHERE GuiaID = "&guiaId&"")
    if not countRows.eof then
        countGuias = CInt(countRows("id"))
    end if
end if

if(UCase(tabela) = UCase("GuiaSADT")) then
    set lotesEnv = db.execute("SELECT * FROM tissprocedimentossadt WHERE GuiaID = "&guiaId&"")
    set despesas = db.execute("SELECT * FROM tissguiaanexa WHERE GuiaID = "&guiaId&"")
    set tissGuia = db.execute("SELECT * FROM tissguiasadt WHERE id = "&guiaId&"")

    

    set countRows = db.execute("SELECT count(*) as id FROM tissprocedimentossadt WHERE GuiaID = "&guiaId&"")
    if not countRows.eof then
        countGuias = CInt(countRows("id"))
    end if

end if

%>

<div style="float: right; margin-bottom: 10px;"><b>Total geral atualmente:</b> R$<%= fn(tissGuia("TotalGeral")) %></div>

<form id="procedimentos_atualizacao" name="procedimentos_atualizacao">   
    <input type="hidden" name="guiaId" value="<%=guiaId%>" />
    <input type="hidden" name="tabela" value="<%=tabela%>" />
<table width="100%" class="table table-striped table-bordered table-condensed">
  <thead>
    <tr>
        <th width="60" align="center" nowrap="">Motivo de Glosa</th>
        <th width="65" align="center" nowrap="">Nome do procedimento</th>
        <th width="65" align="center" nowrap="">Data da execucão</th>
        <th width="60" align="center" nowrap="">Valor total</th>
        <th width="60" align="center" nowrap="">Valor pago</th>
    </tr>
  </thead>
  <tbody> 
<%
dim count

if countGuias <= 1 then
    valorPago = inputValorPago
end if


while not lotesEnv.EOF

    valorPago = lotesEnv("ValorPago")
%>

    <tr>
        <input type="hidden" name="ProcedimentoID" value="<%=lotesEnv("id")%>" />
        <td align="center">
        <% CodigoGlosa = lotesEnv("CodigoGlosa")%>
        <%=quickField("multiple", "CodigoGlosa"&lotesEnv("id"), "", 2,CodigoGlosa, "SELECT id, concat(Codigo,' - ',Descricao) Descricao FROM cliniccentral.tabelaglosas", "Descricao", " semVazio no-select2")%></td>
        <td align="center"><%=lotesEnv("Descricao")%></td>
        <td align="center"><%=lotesEnv("Data")%></td>
        <td align="center"><%=fn(lotesEnv("ValorTotal"))%></td>
        <td align="center"><%=quickfield("currency", "ValorPago"&lotesEnv("id"), "", 3, valorPago, " valor-pago-field", "", " text-right") %></td>
    </tr>
<%
count = count + 1
lotesEnv.movenext
wend
lotesEnv.close
set lotesEnv=nothing
%>  
    </tbody>
</table>
<br>
<% 
 if (VarType(despesas) <> 0)  then
        if (not despesas.EOF) then %> 
            <table width="100%" class="table table-striped table-bordered table-condensed">
                <thead>
                    <tr>
                        <th width="65" align="center" nowrap="">Código do produto</th>
                        <th width="65" align="center" nowrap="">Nome do produto</th>
                        <th width="60" align="center" nowrap="">Quantidade</th>  
                        <th width="60" align="center" nowrap="">Valor total</th>    
                        <th width="60" align="center" nowrap="">Valor pago</th>      
                    </tr>
                </thead>
                <tbody>
                <% while not despesas.EOF %>
                    <tr>
                        <input type="hidden" name="GuiaIDAnexa" value="<%=despesas("id")%>" />
                        <td align="center"><%=despesas("CodigoProduto")%></td>
                        <td align="center"><%=despesas("Descricao")%></td>
                        <td align="center"><%=despesas("Quantidade")%></td> 
                        <td align="center"><%=fn(despesas("ValorTotal"))%></td> 
                        <% if despesas("ValorPago") <> "" then %>
                        <td align="center"><%=quickfield("currency", "ValorPagoGuia"&despesas("id"), "", 3, despesas("ValorPago"), " valor-pago-field " , "", " text-right  ") %></td>
                        <% else %>
                        <td align="center"><%=quickfield("currency", "ValorPagoGuia"&despesas("id"), "", 3, despesas("ValorTotal"), " valor-pago-field " , "", " text-right  ") %></td>
                        <% end if%>

                    </tr>
                <% 
                count = count + 1
                despesas.movenext
                wend
                despesas.close
                set despesas=nothing
                %>   
                </tbody>
            </table>
        <% end if
    end if %>
    <button style="margin: 10px 0px 0px 0px;" onclick="atualizarProcedimentos()" type="button" class="btn btn-primary btn-md"><i class="far fa-save"></i> Salvar</button>
    <span style="float: right; margin-top: 10px; " id="calculo_total"><b>Valor total:0,00</b></span>
</form> 

<script>
    let valorCalculoTotal = 0;
    
    calcularValortotal();

    $("#procedimentos_atualizacao input[name^=ValorPago]").change(function () {
        calcularValortotal();
    });

    $("#procedimentos_atualizacao input[name^=ValorPago]").keyup(function () {
        calcularValortotal();
    });

    $("#procedimentos_atualizacao input[name^=ValorPagoGuia]").keyup(function () {
        calcularValortotal();
    });

    $("#procedimentos_atualizacao input[name^=ValorPagoGuia]").change(function () {
        calcularValortotal();
    });


    function calcularValortotal()
    {
        valorCalculoTotal = 0;
        let listElements = document.getElementById('procedimentos_atualizacao').elements;
        for (var element of listElements) {
            if(element.type === 'hidden' || element.type === 'button'){
                continue;	
            }
            
            let valorPadrao = element.value.replace(".","").replace(",","");
            let valor = parseFloat(valorPadrao);

            if(isNaN(valor)){
                continue;
            }
            
            valorCalculoTotal += valor;    
        } 

        let valorFormatado = formatReal(valorCalculoTotal);
        document.getElementById("calculo_total").innerHTML = `<b>Valor total:</b> R$${valorFormatado}`;
    }

    function formatReal(int)
    {
            var tmp = int+'';
            tmp = tmp.replace(/([0-9]{2})$/g, ",$1");
            if( tmp.length > 6 )
                    tmp = tmp.replace(/([0-9]{3}),([0-9]{2}$)/g, ".$1,$2");

            return tmp;
    }

    function atualizarProcedimentos() 
    {
        var dataString = $('#procedimentos_atualizacao').serialize();

        $.ajax({
                type: "POST",
                url: "SalvaProcedimentos.asp",
                data:  dataString,
                success: function(data) {
                    lancamentoValorPago(data.guia_id, data.tipo_guia, data.total_pago, statusId=data.status_id);

                    closeComponentsModal();
                    
                    
                },
                error: function(resposeText){    
                },
        });
    }
</script>
<script>
    <!--#include file="jQueryFunctions.asp"-->
</script>