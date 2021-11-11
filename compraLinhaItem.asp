<%
percentual = CalculaMinAprovacao(id)
%>

<tr id="row<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%> data-id="<%=id%>" class="invoice-linha-item" >
    <td>
		<%=quickField("text", "Quantidade"&id, "", 4, Quantidade, " quantidade text-right disable", "", " required onkeyup=""recalcular(this)""")%><input type="hidden" name="inputs" value="<%= id %>">
        <input type="hidden" name="Tipo<%=id %>" value="<%=Tipo %>" />
    </td>
        <%
        if Tipo="M" then
            ItemCompraID = ""
            ProdutoCompraID = id
            %>
            <td  nowrap>
                <div class="radio-custom radio-primary">
                    <input type="radio" name="Executado<%=id %>" id="Executado<%=id %>C" value="C" <%if Executado="C" then %> checked <%end if %> /><label for="Executado<%=id %>C">Conjunto</label>
                </div>
                <div class="radio-custom radio-primary">
                    <input type="radio" name="Executado<%=id %>" id="Executado<%=id %>U" value="U" <%if Executado="U" then %> checked <%end if %> /><label for="Executado<%=id %>U">Unidade</label>
                </div>
            </td>
            <td colspan="2" class="produtos">
            <style>
                .produtos .select2-selection--single{
                    max-width: 100% !important;
                    width: 100%;
                }
            </style>
            <%= selectInsert("", "ItemID"&id, ItemID, "produtos", "NomeProduto", " onchange=""parametrosProduto("&id&", this.value);""", " required", "") %></td>
            <%
        elseif Tipo="O" then
            ItemCompraID = id
            ProdutoCompraID = ""
            TabelaCategoria = "sys_financialexpensetype"
            EscondeFormas = 1
            II = "0_0"
            %>
            <td ><%=quickField("text", "Descricao"&id, "", 4, Descricao, " disable", "", " placeholder='Descri&ccedil;&atilde;o...' required maxlength='50'")%></td>
            <td width="200">
                <%=selectInsert("", "CategoriaID"&id, CategoriaID, TabelaCategoria, "Name", "data-exibir="""&LimitarPlanoContas&"""", "", "")%></td>
            <td width="200">
                <%=selectInsert("", "CentroCustoID"&id, CentroCustoID, "CentroCusto", "NomeCentroCusto", "", "", "")%></td>
            <script>
                $("#hCentroCusto").html("Centro de Custo");
                $("#hPlanoContas").html("Plano de Contas");
            </script>
            <%
        end if

        ValorUnitarioReadonly = ""

        if ValorUnitario<>"" and ValorUnitario<>0 and TemRegrasDeDesconto then
            ValorUnitarioReadonly=" readonly"
        end if
        %>
    <td><%=quickField("currency", "ValorUnitario"&id, "", 4, fn(ValorUnitario), " CampoValorUnitario text-right disable", "", " onkeyup=""recalcular(this)""" & ValorUnitarioReadonly)%></td>
    <td class="hidden"><%=quickField("text", "Desconto"&id, "", 4, fn(Desconto), " CampoDesconto input-mask-brl text-right disable", "", " onkeyup=""recalc($(this).attr('id'))""")%></td>
    <td class="text-right"  nowrap>R$ <span class="subtotal" id="sub<%=id%>"><%= fn( Subtotal) %></span></td>
    <td class="text-center" nowrap>
    <div style="position: relative;z-index: 1000;top: 19px;color: #fff;">
        <%=percentual%>%
    </div>
    <div class="progress" style="margint-top: -19px">
          <div class="progress-bar progress-bar-primary progress-bar-striped" style="width: <%=percentual%>%;;"></div>
          <div class="progress-bar progress-bar-default progress-bar" style="width: <%=100-percentual%>%;"></div>
        </div></td>
    <td><button type="button" id="xili<%= ItemCompraID %>" class="btn btn-sm btn-danger disable" onClick="itens('<%=Tipo%>', 'X', '<%=id%>')"><i class="far fa-remove"></i></button></td>
</tr>
<script>
function recalcular(arg){
    let quantidade = $(arg).parents('tr').find("[name^='Quantidade']").val();
    let valor = $(arg).parents('tr').find("[name^='ValorUnitario']").val();
    valor = valor.replace(".","").replace(",",".")

    $(arg).parents("tr").find("[id^='sub']").html(formatNumber(valor*quantidade,2));

    recalc();
}

function recalc(){
        let total = 0;
        $(".subtotal").each((a,tag)=>{
                total += Number($(tag).html().replace(".","").replace(",","."))
        });
        $("#total").html("R$"+formatNumber(total,2));
};

function formatNumber(num,fix){
        if(!num){
            return "0,00";
        }
        return Number(num).toLocaleString('de-DE', {
         minimumFractionDigits: fix,
         maximumFractionDigits: fix
       });
}

</script>
<%

if crr>0 then
    %>
    <script>
        $("#xili<%= ItemCompraID %>").addClass("hidden");
    </script>
    <%
end if
%>