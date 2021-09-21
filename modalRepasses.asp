<!--#include file="connect.asp"-->
<div class="modal-header">
	<h4 class="lighter blue">Informe/confirme os itens abaixo</h4>
</div>
<form method="post" action="" id="frmRR">
<div class="modal-body">
    <div class="row"><div class="col-md-12">
    <%
	I=req("I")
	set inv = db.execute("select * from sys_financialinvoices where id="&I)
	if not inv.eof then
		if inv("FormaID")=0 or isnull(inv("FormaID")) then
			FormaID = "P"
		else
			FormaID = "P"&inv("FormaID")&"_"&inv("ContaRectoID")
		end if
	end if
    if req("F")="S" then
        %>
        <h5>Profissionais participantes</h5>
        <table class="table table-striped table-bordered">
        <thead>
            <tr>
                <th>Servi&ccedil;o</th>
                <th>Fun&ccedil;&atilde;o</th>
                <th>Profissional</th>
            </tr>
        </thead>
        <%
        'Lista os itens para lançar os rateios que estiverem pendentes
        set itensF = db.execute("select ii.*, p.NomeProcedimento from itensinvoice ii left join procedimentos p on p.id=ii.ItemID where ii.Tipo='S' and ii.Executado='S' and ii.InvoiceID="&I)
        while not itensF.eof
            'str = str&dominioRepasse(FormaID, itens("ProfissionalID"), itens("ItemID"))&"\n"
            DominioID = dominioRepasse(FormaID, itensF("ProfissionalID"), itensF("ItemID"))
            set fun = db.execute("select * from rateiofuncoes where DominioID="&DominioID&" and FM='F' and ContaPadrao=''")
            while not fun.eof
				muid = itensF("id")&"_"&fun("id")
				ContaCredito = fun("ContaPadrao")

				set verificaRateio = db.execute("select ContaCredito from rateiorateios where FuncaoID="&fun("id")&" and ItemInvoiceID="&itensF("id"))
				if not verificaRateio.eof then
					ContaCredito = verificaRateio("ContaCredito")
				end if
                %>
                <tr>
                    <td>
                    	<input type="hidden" name="itensF" value="<%=muid%>" />
						<%=itensF("NomeProcedimento")%>
                    </td>
                    <td><%=fun("Funcao")%></td>
                    <td><%call simpleSelectCurrentAccounts("ContaCredito"&muid, "5, 4, 2", ContaCredito, "","")%></td>
                </tr>
                <%
            fun.movenext
            wend
            fun.close
            set fun=nothing
        itensF.movenext
        wend
        itensF.close
        set itensF=nothing
        %>
        </table>
        <%
    end if


    if req("M")="S" then
        %>
        <h5>Materiais utilizados</h5>
        <table class="table table-striped table-bordered">
        <thead>
            <tr>
                <th>Servi&ccedil;o</th>
                <th>Produto</th>
                <th>Quantidade Utilizada</th>
                <th>Estoque</th>
                <th>Conta Cr&eacute;dito</th>
            </tr>
        </thead>
        <%
        I=req("I")
        'Lista os itens para lançar os rateios que estiverem pendentes
        set itensF = db.execute("select ii.*, p.NomeProcedimento from itensinvoice ii left join procedimentos p on p.id=ii.ItemID where ii.Tipo='S' and ii.Executado='S' and ii.InvoiceID="&I)
        while not itensF.eof
            'str = str&dominioRepasse(FormaID, itens("ProfissionalID"), itens("ItemID"))&"\n"
            DominioID = dominioRepasse(FormaID, itensF("ProfissionalID"), itensF("ItemID"))
            set fun = db.execute("select rf.*, p.NomeProduto from rateiofuncoes rf left join produtos p on p.id=rf.ProdutoID where rf.DominioID="&DominioID&" and rf.FM='M' and rf.Variavel='S'")
            while not fun.eof
				muid = itensF("id")&"_"&fun("id")
				Quantidade = fun("Quantidade")
				
				set verificaRateio = db.execute("select Quantidade from rateiorateios where FuncaoID="&fun("id")&" and ItemInvoiceID="&itensF("id"))
				if not verificaRateio.eof then
					Quantidade = verificaRateio("Quantidade")
				end if
				
				
				if not isnull(Quantidade) then Quantidade = formatnumber(Quantidade,2) end if
                %>
                <tr>
                    <td>
                    	<input type="hidden" name="itensM" value="<%=muid%>" />
						<%=itensF("NomeProcedimento")%>
                    </td>
                    <td><%=fun("NomeProduto")%></td>
                    <td><%= quickField("text", "Quantidade"&muid, "", 5, Quantidade, "input-mask-brl text-right", "", "") %></td>
                    <td id="muid<%=muID%>">
                    <%
					set vcBaixado = db.execute("select id from estoquelancamentos where ItemInvoiceID="&itensF("id")&" and FuncaoRateioID="&fun("id"))
					if not vcBaixado.eof then
						%>
                        <button type="button" class="btn btn-xs btn-success"><i class="far fa-upload"></i> Baixado</button>
                        <%
					else
						%>
                        <div class="btn-group">
                        <button class="btn btn-danger btn-xs dropdown-toggle" data-toggle="dropdown">
                        <i class="far fa-download"></i> Baixar <span class="far fa-caret-down icon-on-right"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-danger">
                        <%
                        set lanc = db.execute("select distinct Validade, Lote from estoquelancamentos where ProdutoID="&fun("ProdutoID"))
                        while not lanc.eof
                            Quantidade = quantidadeEstoque(fun("ProdutoID"), lanc("Lote"), lanc("Validade"))
                            if Quantidade>0 then
                                %>
                                    <li><a href="javascript:lancar('<%=muid%>', '<%=lanc("Lote")%>', '<%=lanc("Validade")%>');">Lt. <%=lanc("Lote")%>, Val. <%=lanc("Validade")%> - Disp.: <%=Quantidade &" "& lcase(unidade)%></a><li>
                                <%
                            end if
                        lanc.movenext
                        wend
                        lanc.close
                        set lanc = nothing
                        %>
                        </ul>
                        </div>
                        <%
					end if
					%>
                    </td>
                    <td><%call simpleSelectCurrentAccounts("ContaCredito"&muid, "00, 5, 4, 2, 1", fun("ContaPadrao"), "","")%></td>
                    </tr>
                <%
            fun.movenext
            wend
            fun.close
            set fun=nothing
        itensF.movenext
        wend
        itensF.close
        set itensF=nothing
        %>
        </table>
        <%
    end if
    %>
    </div></div>
</div>
<div class="modal-footer">
	<button class="btn btn-success"><i class="far fa-check"></i> Confirmar</button>
</div>
</form>
<script>
$("#frmRR").submit(function(){
	$.post("saveRR.asp?I=<%=id%>", $("#frmRR").serialize(), function(data, status){ eval(data) });
	return false;
});
</script>
<!--#include file="disconnect.asp"-->