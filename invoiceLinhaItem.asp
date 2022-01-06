<%

    set InvoiceSQL = db.execute("select * from sys_financialinvoices where id="&treatvalzero(InvoiceID))
    'Caso exista alguma integração para este ítem desabilitar o botão
    sqlintegracao = " SELECT lia.id, lie.StatusID FROM labs_invoices_amostras lia "&_
				" inner JOIN labs_invoices_exames lie ON lia.id = lie.AmostraID "&_
				" WHERE lia.InvoiceID = "&treatvalzero(InvoiceID)&" AND lia.ColetaStatusID <> 5 "
    set integracaofeita = db.execute(sqlintegracao)

    ExecutantesTipos = "5, 8, 2"
    if session("Banco")="clinic6118" then
        ExecutantesTipos = "5"
    end if

%>
<tr id="row<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%> data-id="<%=id%>" data-imposto="<%=imposto%>">
    <td>
    	<input type="hidden" name="AtendimentoID<%=id%>" id="AtendimentoID<%=id%>" value="<%=AtendimentoID%>">
    	<input type="hidden" name="AgendamentoID<%=id%>" id="AgendamentoID<%=id%>" value="<%=AgendamentoID%>">
		<%=quickField("text", "Quantidade"&id, "", 4, Quantidade, " text-right disable", "", " required onkeyup=""recalc($(this).attr('id'))"""&disabled)%><input type="hidden" name="inputs" value="<%= id %>">
        <input type="hidden" name="Tipo<%=id %>" value="<%=Tipo %>" />
    </td>
        <%
        if Tipo="S" then
            ItemInvoiceID = id
            ProdutoInvoiceID = ""

            DisabledNaoAlterarExecutante = " "
            NaoAlterarExecutante=False
            set RepasseSQL = db.execute("SELECT id FROM rateiorateios WHERE ItemContaAPagar is not null and ItemInvoiceID="&ItemInvoiceID)

            if not RepasseSQL.eof then
                NaoAlterarExecutante=True
                DisabledNaoAlterarExecutante=" disabled"
            end if

            if NaoPermitirAlterarExecutante and Executado="S" then
                NaoAlterarExecutante=True
                DisabledNaoAlterarExecutante=" disabled"
            end if

            %>
            <input type="hidden" id="PacoteID<%= id %>" name="PacoteID<%= id %>" value="<%= PacoteID %>" />
            <td colspan="2">
            <%
            if NaoAlterarExecutante then
                %>
                <input type="hidden" name="NaoAlterarExecutante" value="S" />
                <input type="hidden" name="RepasseGerado<%= id %>" value="S" />
                <input type="hidden" name="ItemID<%= id %>" value="<%=ItemID%>" />
                <%
            end if
            %>
            <%= selectInsert("", "ItemID"&id, ItemID, "procedimentos", "NomeProcedimento", " onchange="" onChangeProcedimento("&id&", this.value);"" data-row='"& id &"' "&DisabledNaoAlterarExecutante, " required ", "") %>
                    <%if session("Odonto")=1 then
                    %>
                    <textarea class="hidden" name="OdontogramaObj<%=id %>" id="OdontogramaObj<%=id %>"><%=OdontogramaObj %></textarea>
                    <%
                  end if %>


            </td>
            <td nowrap="nowrap" >
            <% if  Executado<>"C" then

                if NaoAlterarExecutante then
                    %>
                    <input type="hidden" name="Executado<%= id %>" value="S" />
                    <%
                end if

            %>
                <span class="checkbox-custom checkbox-primary"><input type="checkbox" class="checkbox-executado" name="Executado<%=id%>" id="Executado<%=id%>" value="S"<%if Executado="S" then%> checked="checked"<%end if%> <%=DisabledNaoAlterarExecutante%> /><label for="Executado<%=id%>"> Executado</label></span>
            <% end if %>
                <%
                if id>0 then
                    if Executado="C" then
                        set vcaPagto = db.execute("select ifnull(sum(Valor), 0) TotalPagoItem from itensdescontados where ItemID="& id)
                        TotalPagoItem = ccur(vcaPagto("TotalPagoItem"))

                        if TotalPagoItem>=ccur(Quantidade*(ValorUnitario+Acrescimo-Desconto)) then
                        %>
                         <input type="hidden" value="C" name="Cancelado<%=id%>">
                        <span class="label label-danger">Cancelado</span>
                        <% '<span class="checkbox-custom checkbox-danger"><input type="checkbox" name="Cancelado id" id="Cancelado id" value="C" checked="checked" /><label for="Cancelado id"> Cancelado</label></span> %>
                        <%
                        end if
                    end if
                end if
                %>
            </td>
            <%
        elseif Tipo="M" or Tipo="K" then
            ItemInvoiceID = ""
            ProdutoInvoiceID = id
            if not InvoiceSQL.eof then
                if InvoiceSQL("CD")="C" then
                    TabelaCategoria = "sys_financialincometype"
                    LimitarPlanoContas=""
                else
                    TabelaCategoria = "sys_financialexpensetype"
                    EscondeFormas = 1
                    II = "0_0"
                end if
            end if
            %>
            <td  nowrap>
            <div class="col-md-4 produtoRow">
                <div class="radio-custom radio-primary">
                    <input type="radio" name="Executado<%=id %>" id="Executado<%=id %>C" value="C" <%if Executado="C" then %> checked <%end if %> /><label for="Executado<%=id %>C">Conjunto</label>
                </div>
                <div class="radio-custom radio-primary">
                    <input type="radio" name="Executado<%=id %>" id="Executado<%=id %>U" value="U" <%if Executado="U" then %> checked <%end if %> /><label for="Executado<%=id %>U">Unidade</label>
                </div>
            </div>
    <div class="col-md-8 mt5"><%= selectInsert("", "ItemID"&id, ItemID, "produtos", "NomeProduto", " onchange=""parametrosProduto("&id&", this.value);""", " required", "") %></div></td>
    <td colspan="2">

            <%=selectInsert("", "CategoriaID"&id, CategoriaID, TabelaCategoria, "Name", "data-exibir="""&LimitarPlanoContas&"""", "", "")%> </td>

            <%
        elseif Tipo="O" then
            ItemInvoiceID = id
            ProdutoInvoiceID = ""
			if not InvoiceSQL.eof then
				if InvoiceSQL("CD")="C" and imposto = 0 then
					TabelaCategoria = "sys_financialincometype"
					LimitarPlanoContas=""
				else
					TabelaCategoria = "sys_financialexpensetype"
					EscondeFormas = 1
					II = "0_0"
				end if
			end if
            %>
            <td><%=quickField("text", "Descricao"&id, "", 4, Descricao, " ", "", " placeholder='Descri&ccedil;&atilde;o...' required maxlength='50' "&disabled)%></td>
                <% if imposto = 0 then%>
                    <td><%=selectInsert("", "CategoriaID"&id, CategoriaID, TabelaCategoria, "Name", "data-exibir="""&LimitarPlanoContas&"""", "", "")%></td>
                    <td><%=selectInsert("", "CentroCustoID"&id, CentroCustoID, "CentroCusto", "NomeCentroCusto", "", "", "")%></td>
                    <script>
                        $("#hCentroCusto").html("Centro de Custo");
                        $("#hPlanoContas").html("Plano de Contas");
                    </script>
                <% else%>
                    <td hidden ><%=quickField("select", "CategoriaID"&id, "", 12, CategoriaID, TabelaCategoria, "Name", "")%></td>
                    <td><%=quickField("select", "CategoriaIDS"&id, "", 12, CategoriaID, TabelaCategoria, "Name", " disabled  ")%></td>
                    <td hidden ><%=quickField("select", "CentroCustoID"&id, "", 12, CentroCustoID, "centrocusto" , "NomeCentroCusto", " ")%></td>
                    <td><%=quickField("select", "CentroCustoIDS"&id, "", 12, CentroCustoID, "centrocusto" , "NomeCentroCusto", " disabled ")%></td>
                <% end if%>
            <%
        end if



        ValorUnitarioReadonly = " "
        notEdit = " "

        if ValorUnitario<>"" and ValorUnitario<>0 and TemRegrasDeDesconto and Tipo="S" and isnull(InvoiceSQL("FixaID")) then
            ValorUnitarioReadonly=" readonly"
            notEdit = " notedit "
        end if

        if (aut("valordoprocedimentoA")=0 and Tipo="S")then
            ValorUnitarioReadonly=" readonly"
            notEdit = " notedit "
        end if
    if imposto = 1 then 
        %>
    <td>
        <div class="input-group">
            <div class="input-group-btn">
                <button type="button" class="btn btn-default btn-descontox" data-toggle="dropdown" aria-expanded="false"
                    style="width: 41px !important;">R$</button>
            </div>
            <div hidden>
                <%=quickField("currency", "ValorUnitario"&id, "", 4, fn(ValorUnitario), " " & notEdit & " CampoValorUnitario text-right", "", " onkeyup=""syncValuePercentReais($(this))""" & ValorUnitarioReadonly)%>
            </div>
            <div class="fake col-md-4 CampoDesconto input-mask-brl text-right disabled"><%=fn(ValorUnitario)%></div>
        </div>
    </td>
    <% else %>
        <td><%=quickField("currency", "ValorUnitario"&id, "", 4, fn(ValorUnitario), " " & notEdit & " CampoValorUnitario text-right", "", " onkeyup=""syncValuePercentReais($(this))""" & ValorUnitarioReadonly)%></td>
    <% end if %>
    <% if imposto = 1 then %>
    <td>
        <div class="input-group">
            <div class="input-group-btn">
                <button type="button" class="btn btn-default btn-descontox" data-toggle="dropdown" aria-expanded="false"
                    style="width: 41px !important;">R$</button>
            </div>
            <%=quickField("text", "Desconto"&id, "", 4, fn(Desconto), " CampoDesconto input-mask-brl text-right hidden", "", " data-desconto='"&fn(Desconto)&"'hidden onkeyup=""setInputDescontoEmPorcentagem(this)""")%>
            <div class="fake col-md-4 CampoDesconto input-mask-brl text-right disabled"><%=fn(Desconto)%></div>
        </div>
    </td>
    <% else %>
    <td>
        <div class="input-group">
            <div class="input-group-btn">
                <button type="button" class="btn btn-default dropdown-toggle btn-desconto" data-toggle="dropdown" aria-expanded="false"
                    style="width: 41px !important;">R$</button>
                <ul class="dropdown-menu dropdown-info pull-right">
                    <li><a href="javascript:void(0)" onclick="mudarFormatoDesconto(this)" class="dropdown-item">%</a></li>
                </ul>
            </div>
            <%=quickField("text", "Desconto"&id, "", 4, fn(Desconto), " CampoDesconto input-mask-brl text-right disable", "", " data-desconto='"&fn(Desconto)&"' onkeyup=""setInputDescontoEmPorcentagem(this)""" &DescontoReadonly)%>
            <%=quickField("text", "PercentDesconto"&id, "", 4, "0.00", " PercentDesconto input-mask-brl text-right disable", "", "style='display:none' data-desconto='0.00' onkeyup=""setInputDescontoEmReais(this)""")%>
        </div>
    </td>
    <% end if %>
    <% if imposto = 1 then %>
    <td>
        <div class="input-group">
            <div class="input-group-btn">
                <button type="button" class="btn btn-default btn-descontox" data-toggle="dropdown" aria-expanded="false"
                    style="width: 41px !important;">R$</button>
            </div>
            <div hidden>
                <%=quickField("text", "Acrescimo"&id, "", 4, fn(Acrescimo), " input-mask-brl text-right", "", " data-acrescimo='"&fn(Acrescimo)&"' onkeyup=""recalc($(this).attr('id'))""")%>
            </div>
            <div class="fake col-md-4 CampoDesconto input-mask-brl text-right disabled"><%=fn(Acrescimo)%></div>
        </div>
    </td>
    <% else %>
        <td><%=quickField("text", "Acrescimo"&id, "", 4, fn(Acrescimo), " input-mask-brl text-right disable", "", " data-acrescimo='"&fn(Acrescimo)&"' onkeyup=""recalc($(this).attr('id'))""")%></td>
    <% end if %>




    <td class="text-right" data-valor="<%= fn( Subtotal) %>" id="sub<%=id%>" nowrap>R$ <%= fn( Subtotal) %></td>
    <td><button
    <% if id<0 then %>
    disabled title="Salve a conta para lançar no estoque"
    <%else %>
    title="Lançamentos de estoque"
    <% end if %>
    onclick="modalEstoque('<%=ItemInvoiceID %>', '<%=ItemID %>', '<%= ProdutoInvoiceID %>')" id="btn<%= ProdutoInvoiceID %>" type="button" class="btn btn-alert btn-block btn-sm"><i class="far fa-medkit"></i></button></td>
    <td>
        <%
        PodeExcluirItem = True
        if ItemInvoiceID&""<>"" then
            set vcaRep = db.execute("select rr.id from rateiorateios rr where rr.ItemInvoiceID="& ItemInvoiceID &" AND NOT ISNULL(rr.ItemContaAPagar)")
            if not vcaRep.eof then
                PodeExcluirItem = False

                if aut("repassesV")=1 then
                %>
                <button title="Repasses Gerados" onclick="repasses('ItemInvoiceID', <%= ItemInvoiceID %>)" type="button" class="btn btn-sm btn-dark">
                    <i class="far fa-puzzle-piece"></i>
                </button>
                <%
                end if
            end if
        end if

        if not integracaofeita.eof then
            PodeExcluirItem = False
        end if

        if PodeExcluirItem then %>
        <span class="d-inline-block" tabindex="0" data-toggle="tooltip" title="<%=titleNotaFiscal%>">
            <button type="button" id="xili<%= ItemInvoiceID %>"  class="btn btn-sm btn-danger disable <%=desabilitarExclusaoItem%>" onClick="itens('<%=Tipo%>', 'X', '<%=id%>')"><i class="far fa-remove"></i></button>
        </span>
        <%
        end if
        %>
    </td>
    <td>
    <% if Tipo="S" then

    %>
        <div class="btn-group">
            <button type="button" class="btn btn-info btn-sm  dropdown-toggle" data-toggle="dropdown" title="Gerar recibo" aria-expanded="false"><i class="far fa-print"></i></button>
            <ul class="dropdown-menu dropdown-info pull-right">
                <li><a href="javascript:printProcedimento($('#ItemID<%=id %>').val(),$('#AccountID').val().split('_')[1], $('#ProfissionalID<%=id %>').val(),$('#DataExecucao<%=id %>').val(),'Protocolo')"><i class="far fa-plus"></i> Protocolo de laudo </a></li>
                <li><a href="javascript:printProcedimento($('#ItemID<%=id %>').val(),$('#AccountID').val().split('_')[1], $('#ProfissionalID<%=id %>').val(),$('#DataExecucao<%=id %>').val(),'Impresso')"><i class="far fa-plus"></i> Impresso </a></li>
                <li><a href="javascript:printProcedimento($('#ItemID<%=id %>').val(),$('#AccountID').val().split('_')[1], $('#ProfissionalID<%=id %>').val(),$('#DataExecucao<%=id %>').val(),'Etiqueta')"><i class="far fa-plus"></i> Etiqueta </a></li>
                <li><a href="javascript:printProcedimento($('#ItemID<%=id %>').val(),$('#AccountID').val().split('_')[1], $('#ProfissionalID<%=id %>').val(),$('#DataExecucao<%=id %>').val(),'Preparos')"><i class="far fa-plus"></i> Preparos </a></li>
            </ul>
        </div>
    <%end if%>
    </td>
</tr>
<% IF getConfig("ObrigarPlanoDeContas") THEN %>
<script>
    $("[name^=CategoriaID]").attr("required","required")
</script>
<% END IF %>
<%
if req("T")="D" then
    'aqui lista os itens caso seja a fatura do cartao
    set ItensFaturaCartaoSQL = db.execute("SELECT fcpi.* FROM sys_financialcreditcardpaymentinstallments fcpi WHERE ItemInvoiceID="&treatvalzero(id))
    if not ItensFaturaCartaoSQL.eof then
        %>
        <thead>
            <tr class="success">
                <th colspan="1">Data</th>
                <th colspan="2"><small>Conta</small></th>
                <th colspan="3"><small>Descrição</small></th>
                <th colspan="1"><small>Qtd. Itens</small></th>
                <th colspan="1"><small>Parcela</small></th>
                <th colspan="2"><small>Valor</small></th>
                <th></th>
            </tr>
        </thead>
        <%
        while not ItensFaturaCartaoSQL.eof
            set NumeroParcelasSQL = db.execute("SELECT count(id) NumeroParcelas FROM sys_financialcreditcardpaymentinstallments WHERE TransactionID = "&ItensFaturaCartaoSQL("TransactionID"))
            NumeroParcelas = NumeroParcelasSQL("NumeroParcelas")
            set MovementSQL = db.execute("SELECT fdp.InstallmentID FROM sys_financialcreditcardpaymentinstallments fcpi  LEFT JOIN sys_financialcreditcardtransaction fct ON fct.id = fcpi.TransactionID LEFT JOIN sys_financialmovement fm ON fm.id = fct.MovementID LEFT JOIN sys_financialdiscountpayments fdp ON fdp.MovementID = fm.id WHERE fcpi.id = "&ItensFaturaCartaoSQL("id"))

            if not MovementSQL.eof then
                InstallmentID = MovementSQL("InstallmentID")
                if not isnull(InstallmentID) then
                    set InvoiceSQL = db.execute("SELECT fi.AssociationAccountID, fi.AccountID, count(ii.id) QuantidadeItens, GROUP_CONCAT( CASE ii.Tipo WHEN 'O' THEN ii.Descricao WHEN 'M' THEN p.NomeProduto END) Descricoes, fm.InvoiceID FROM sys_financialmovement fm LEFT JOIN itensinvoice ii ON ii.InvoiceID = fm.InvoiceID LEFT JOIN produtos p ON p.id = ii.ItemID LEFT JOIN sys_financialinvoices fi ON fi.id = ii.InvoiceID WHERE fm.id="&InstallmentID)
                    if not InvoiceSQL.eof then
                        InvoiceID = InvoiceSQL("InvoiceID")

                        if not isnull(InvoiceID) then
                            ContaItem = accountName(InvoiceSQL("AssociationAccountID"), InvoiceSQL("AccountID"))
                            DescricaoItem = InvoiceSQL("Descricoes")
                            QuantidadeItens = InvoiceSQL("QuantidadeItens")
                        else
                            ContaItem = ""
                            Descricao = ""
                            QuantidadeItens = ""
                        end if
                    end if
                end if
                %>
                <tr>
                    <td colspan="1"><%=ItensFaturaCartaoSQL("DateToPay")%></td>
                    <td colspan="2"><%=ContaItem%></td>
                    <td colspan="3"><a href="?P=invoice&I=<%=InvoiceID%>&A=&Pers=1&T=D" target="_blank"><%=DescricaoItem%></a></td>
                    <td colspan="1"><%=QuantidadeItens%></td>
                    <td colspan="1"><%=ItensFaturaCartaoSQL("Parcela")%>/<%=NumeroParcelas%></td>
                    <td colspan="3">R$ <%=fn(ItensFaturaCartaoSQL("Value"))%></td>
                </tr>
                <%
            end if
        ItensFaturaCartaoSQL.movenext
        wend
        ItensFaturaCartaoSQL.close
        set ItensFaturaCartaoSQL=nothing
        %>
<script >
    setTimeout(function() {
        var $linhaFatura = $("#invoiceItens").find("[id^='row']").eq("0");
        $linhaFatura.find("input").attr("readonly",true);
        $linhaFatura.find("[name^='Desconto'], [name^='Acrescimo']").attr("readonly",false);
        $linhaFatura.find(".btn-danger, .btn-alert").attr("disabled",true);
    }, 250);
</script>
        <%
    end if
end if

if req("T")="C" then
    set vcaGuia = db.execute("select * from tissguiasinvoice where ItemInvoiceID="&id)
    if not vcaGuia.eof then
        %>
        <tr>
            <th colspan="2">Guia</th>
            <th colspan="4">Paciente</th>
            <th class="text-right">Valor Guia</th>
            <th class="text-right" colspan="2">Valor Pago</th>
            <th class="text-right" colspan="2"></th>
        </tr>
        <%
            TotalGuias = 0
            TotalPago = 0
        while not vcaGuia.eof
            TipoGuia = vcaGuia("TipoGuia")
            idGuia = vcaGuia("id")
            set g = db.execute("select g.*, pac.NomePaciente from tiss"&TipoGuia&" g LEFT JOIN pacientes pac ON pac.id=g.PacienteID where g.id="&vcaGuia("GuiaID"))

            
            TotalGeral = 0
            if TipoGuia<>"guiaconsulta" and TipoGuia<>"guiahonorarios" then
                TotalGeral = g("TotalGeral")
            elseif TipoGuia="guiahonorarios" then
                TotalGeral = g("Procedimentos")
            else
                TotalGeral = g("ValorProcedimento")
            end if

            if fn(g("ValorPago")) = 0 then
                estilo = " text-danger "
            elseif fn(TotalGeral) <> fn(g("ValorPago")) then
                estilo = " text-warning "
            else
                estilo = " text-success "
            end if

            if not g.eof then
            %>
            <tr class="js-del-linha" id="<%= idGuia %>">
                <td colspan="2">Guia <%=g("NGuiaPrestador") %></td>
                <td colspan="4">Paciente: <%=g("NomePaciente") %></td>
                <td class="text-right">R$ <%=fn(TotalGeral) %></td>
                <td class="text-right '<%=estilo%>'" colspan="2">R$ <%=fn(g("ValorPago")) %></td>
                <td class="text-right" colspan="2">
                    <button type="button" class="btn btn-sm btn-danger deletaGuia" data-id="<%= idGuia %>">
                        <i class="far fa-remove"></i>
                    </button>
                </td>
            </tr>
            <%
            TotalGuias = (TotalGuias + TotalGeral)
            TotalPago = (TotalPago + g("ValorPago"))
            end if
        vcaGuia.movenext
        wend
        vcaGuia.close
        set vcaGuia = nothing

        if TotalPago = 0 then
            estilo = " text-danger "
        elseif TotalGuias <> TotalPago then
            estilo = " text-warning "
        else
            estilo = " text-success "
        end if
                    %>
            <tr class="js-del-linha" id="<%= idGuia %>">
                <th colspan="6">Total Guias</th>
                <th class="text-right" colspan="1">R$ <%=fn(TotalGuias) %></th>
                <th class="text-right '<%=estilo%>'" colspan="2" >R$ <%= fn(TotalPago) %></th>
                <th class="text-right" colspan="2">
                </th>
            </tr>
            <%
    end if
end if


if req("T")<>"D" then

ExecucaoRequired = " required"
if Executado<>"S" then
    ExecucaoRequired=""
end if
%>
<tr id="row2_<%=id%>"<%if Executado<>"S" then%> class="hidden div-execucao"<%else %> class="div-execucao"<%end if%> data-id="<%=id%>">
	<td></td>
    <td colspan="10">
        <div class="row">
    	    <div class="col-xs-3">
			    <label>Profissional</label><br>
			    <%
			    'if PacoteID&""="" then
			        onchangeProfissional = " onchange=""espProf("& id &");"" "
			    'end if

			    if NaoAlterarExecutante then
                    %>
                    <input type="hidden" name="ProfissionalID<%= id %>" value="<%=Associacao&"_"&ProfissionalID%>" />
                    <%
                end if
			    %>
                <%=simpleSelectCurrentAccounts("ProfissionalID"&id, ExecutantesTipos, Associacao&"_"&ProfissionalID, ExecucaoRequired&" "&onchangeProfissional&DisabledNaoAlterarExecutante, "")%>
			    <%'=selectInsertCA("", "ProfissionalID"&id, Associacao&"_"&ProfissionalID, "5, 8, 2", " onchange=""setTimeout(function()calcRepasse("& id &"), 500)""", "", "")%>
            </div>
            <%if Tipo="S" then
                if DataExecucao&"" = "" then
                    DataExecucao=date()
                end if
            %>
            <div id="divEspecialidadeID<%= id %>">
                <%
                if ProfissionalID<> "" then
                    sqlEspecialidades = "select esp.EspecialidadeID id, e.especialidade from (select EspecialidadeID from profissionais where id="& ProfissionalID &" and not isnull(EspecialidadeID) union all	select EspecialidadeID from profissionaisespecialidades where profissionalID="& ProfissionalID &" and not isnull(EspecialidadeID)) esp left join especialidades e ON e.id=esp.EspecialidadeID"

                    if Associacao=8 then
                        sqlEspecialidades = "select e.id, e.especialidade FROM profissionalexterno p "&_
                                            "INNER JOIN especialidades e ON e.id=p.EspecialidadeID "&_
                                            "WHERE p.id="&ProfissionalID
                    end if

                else
                    sqlEspecialidades = "select * from especialidades order by especialidade"
                end if

                 if session("Banco")="clinic6118" then
                    if Executado<>"S" then
                        camposRequired=""
                    else
                        camposRequired=" required empty"
                    end if
                end if

			    if NaoAlterarExecutante then
                    %>
                    <input type="hidden" name="EspecialidadeID<%= id %>" value="<%=EspecialidadeID%>" />
                    <%
                end if

                if EspecialidadeID&""="" or EspecialidadeID&""="0" then
                    camposRequired=""
                end if

                if Associacao<>2 then
                    response.write(quickField("simpleSelect", "EspecialidadeID"&id, "Especialidade", 2, EspecialidadeID, sqlEspecialidades, "especialidade" , DisabledNaoAlterarExecutante&" empty no-select2 "&camposRequired))
                end if
                %>
                </div>
                <%
			    if NaoAlterarExecutante then
                    %>
                    <input type="hidden" name="DataExecucao<%= id %>" value="<%=DataExecucao%>" />
                    <%
                end if
                %>
                <%= quickField("datepicker", "DataExecucao"&id, "Data da Execu&ccedil;&atilde;o", 2, DataExecucao, "", "", ""&ExecucaoRequired&DisabledNaoAlterarExecutante) %>
                <%= quickField("text", "HoraExecucao"&id, "In&iacute;cio", 1, HoraExecucao, " input-mask-l-time", "", "") %>
                <%= quickField("text", "HoraFim"&id, "Fim", 1, HoraFim, " input-mask-l-time", "", "") %>
                <%= quickField("text", "Descricao"&id, "Observações", 3, Descricao, "", "", " maxlength='50'") %>
            <%end if %>
        </div>
        <div class="row" id="rat<%=id%>">
        <%
		Row = id
		if Executado="S" then
            set getFun = db.execute("select * from itensinvoiceoutros where ItemInvoiceID="& Row)
            while not getFun.eof
                call subitemRepasse(getFun("Tipo"), getFun("Funcao"), getFun("tipoValor"), getFun("ValorUnitario"), getFun("Conta"), getFun("ProdutoID"), getFun("ValorUnitario"), getFun("Quantidade"), getFun("Variavel"), getFun("ValorVariavel"), getFun("ContaVariavel"), getFun("ProdutoVariavel"), getFun("TabelasPermitidas"), getFun("FuncaoEquipeID"), getFun("FuncaoID"), getFun("id"))
            getFun.movenext
            wend
            getFun.close
            set getFun = nothing
		end if
		%>

        </div>
    </td>
</tr>
<%
else
    if False then
        set vcaHono = db.execute("select * from iihonorarios where ItemInvoiceID="& treatvalzero(id))
        if not vcaHono.eof then
            %>
            <tr>
                <td></td>
                <td colspan="4">
                    <table class="table table-condensed">
                        <tr class="success">
                            <th>Data</th>
                            <th>Tempo</th>
                            <th>Valor</th>
                        </tr>
                        <%
                        while not vcaHono.eof
                            %>
                            <tr>
                                <td><a href="./?P=agenda-1&Pers=1&ProfissionalID=<%= vcaHono("ProfissionalID") &"&Data="& vcaHono("Data") %>" target="_blank"> <%= vcaHono("Data") %></a></td>
                                <td>Tempo: <%= dateAdd("n", vcaHono("Minutos"), "00:00") %></td>
                                <td>Valor: <%= fn(vcaHono("Valor")) %></td>
                            </tr>
                            <%
                        vcaHono.movenext
                        wend
                        vcaHono.close
                        set vcaHono=nothing
                        %>
                    </table>
                </td>
            </tr>
            <%
        end if
    end if
end if




if InvoiceSQL("CD")<>"C" then
'set vcaRep = db.execute("select rr.*, rr.Funcao, rr.TipoValor, rr.Valor, p.NomeProcedimento, pac.NomePaciente, (ii.Quantidade * (ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal from rateiorateios rr LEFT JOIN itensinvoice ii on ii.id=rr.ItemInvoiceID LEFT JOIN procedimentos p on p.id=ii.ItemID LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID LEFT JOIN pacientes pac on pac.id=i.AccountID WHERE rr.ItemContaAPagar="&treatvalzero(id))
set vcaRep = db.execute("select rr.* FROM rateiorateios rr WHERE rr.ItemContaAPagar="&treatvalzero(id)&" or  rr.ItemContaAReceber="&treatvalzero(id)&"")
crr = 0

TemRepasse = False

if not vcaRep.eof then
TemRepasse=True
%>
<thead>
    <tr class="success">
        <th colspan="1">Data</th>
        <th colspan="1">Tipo </th>
        <th colspan="2"><small>Procedimento</small></th>
        <th colspan="2"><small>Paciente</small></th>
        <th colspan="1"><small>Regra</small></th>
        <th colspan="1"><small>Valor</small></th>
        <th colspan="1"><small>Valor final</small></th>
        <th></th>
    </tr>
</thead>
<%
while not vcaRep.eof
    linkFonte = ""
    NomePaciente = ""
    NomeProcedimento = ""
    if not isnull(vcaRep("ItemGuiaID")) then
        TipoRegra = "Guia SP/SADT"
        set DadosRepasseSQL = db.execute("SELECT p.NomePaciente,proc.NomeProcedimento, tgc.Data FROM tissprocedimentossadt tgc LEFT JOIN tissguiasadt tg ON tg.id = tgc.GuiaID LEFT JOIN pacientes p ON p.id = tg.PacienteID LEFT JOIN procedimentos proc ON proc.id = tgc.ProcedimentoID WHERE tgc.id="&vcaRep("ItemGuiaID"))

        if not DadosRepasseSQL.eof then
            NomeProcedimento = DadosRepasseSQL("NomeProcedimento")
            NomePaciente =DadosRepasseSQL("NomePaciente")
            DataAtendimento = DadosRepasseSQL("Data")
            'ValorTotal = DadosRepasseSQL("ValorTotal")
        end if
    end if
    if not isnull(vcaRep("GuiaConsultaID")) then
        TipoRegra = "Guia de Consulta"
        set DadosRepasseSQL = db.execute("SELECT p.NomePaciente,proc.NomeProcedimento, tgc.DataAtendimento FROM tissguiaconsulta tgc LEFT JOIN pacientes p ON p.id = tgc.PacienteID LEFT JOIN procedimentos proc ON proc.id = tgc.ProcedimentoID WHERE tgc.id="&vcaRep("GuiaConsultaID"))

        if not DadosRepasseSQL.eof then
            NomeProcedimento = DadosRepasseSQL("NomeProcedimento")
            NomePaciente =DadosRepasseSQL("NomePaciente")
            DataAtendimento = DadosRepasseSQL("DataAtendimento")
            'ValorTotal =DadosRepasseSQL("ValorTotal")
        end if
    end if
    if not isnull(vcaRep("ItemHonorarioID")) then
        TipoRegra = "Guia de Honorário"
        set DadosHonorarioSQL = db.execute("SELECT proc.NomeProcedimento, p.NomePaciente, tph.ValorTotal, tph.Data as DataHonorario FROM tissguiahonorarios tgh INNER JOIN tissprocedimentoshonorarios tph ON tgh.id=tph.GuiaID LEFT JOIN procedimentos proc ON proc.id = tph.ProcedimentoID LEFT JOIN  pacientes p ON p.id=tgh.PacienteID WHERE tph.id=" & vcaRep("ItemHonorarioID"))
        if not DadosHonorarioSQL.eof then
            NomeProcedimento = DadosHonorarioSQL("NomeProcedimento")
            NomePaciente =DadosHonorarioSQL("NomePaciente")
            ValorTotal =DadosHonorarioSQL("ValorTotal")
            DataAtendimento = DadosHonorarioSQL("DataHonorario")
            linkFonte = "<a href='./?P=Invoice&Pers=1&CD=C&I="& InvoiceID &"' target='_blank'>"
        end if
    end if
    if not isnull(vcaRep("ItemInvoiceID")) then
        TipoRegra = "Particular"

        set DadosRepasseSQL = db.execute("SELECT proc.NomeProcedimento, ii.DataExecucao, p.NomePaciente,(ii.Quantidade * (ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal,ii.ValorUnitario, ii.InvoiceID FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id = ii.InvoiceID LEFT JOIN pacientes p ON p.id=i.AccountID LEFT JOIN procedimentos proc ON proc.id = ii.ItemID WHERE ii.id="&vcaRep("ItemInvoiceID"))
        if not DadosRepasseSQL.eof then
            NomeProcedimento = DadosRepasseSQL("NomeProcedimento")
            NomePaciente =DadosRepasseSQL("NomePaciente")
            ValorTotal =DadosRepasseSQL("ValorTotal")
            DataAtendimento = DadosRepasseSQL("DataExecucao")
            linkFonte = "<a href='./?P=Invoice&Pers=1&CD=C&I="& DadosRepasseSQL("InvoiceID") &"' target='_blank'>"
        else
            NomeProcedimento = "<i>Conta excluída<i>"
        end if
    end if

    tipoValor = vcaRep("TipoValor")
    if tipoValor="V" then
        pre = "R$ "
        suf = ""
    else
        pre = ""
        suf = "%"
    end if
    ValorFinal = calculaRepasse(vcaRep("id"), vcaRep("Sobre"), ValorTotal, vcaRep("Valor"), vcaRep("TipoValor"))
    if vcaRep("TipoValor")="P" then
        ' ValorFinal = ""
    end if
    crr = crr+1
    %>
    <tr>
        <td><small><%= DataAtendimento %></small></td>
        <td><%=TipoRegra%></td>
        <td colspan="2"><small><%= linkFonte & NomeProcedimento%></small></td>
        <td colspan="2"><small><%=NomePaciente %></small></td>
        <td colspan="1"><small><%=vcaRep("Funcao") %></small></td>
        <td colspan="1"><small><%=pre & fn(vcaRep("Valor")) & suf %></small></td>
        <td colspan="1"><small><%= fn(ValorFinal)%></small></td>
        <td></td>
    </tr>
    <%
vcaRep.movenext
wend
vcaRep.close
set vcaRep=nothing
end if
if crr>0 then
    %>
    <script>
        $("#xili<%= ItemInvoiceID %>").addClass("hidden");
    </script>
    <%
end if

if TemRepasse and aut("|repassesA|")=0 then
    %>
    <script>
        setTimeout(function() {
          disable(true);
          $("#ExisteRepasse").val("S");
        }, 100);
    </script>
    <%
end if

end if
%>
