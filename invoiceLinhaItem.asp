﻿<%
set InvoiceSQL = db.execute("select * from sys_financialinvoices where id="&treatvalzero(InvoiceID))
%>
<tr id="row<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%> data-id="<%=id%>">
    <td>
    	<input type="hidden" name="AtendimentoID<%=id%>" id="AtendimentoID<%=id%>" value="<%=AtendimentoID%>">
    	<input type="hidden" name="AgendamentoID<%=id%>" id="AgendamentoID<%=id%>" value="<%=AgendamentoID%>">
		<%=quickField("text", "Quantidade"&id, "", 4, Quantidade, " text-right disable", "", " required onkeyup=""recalc($(this).attr('id'))""")%><input type="hidden" name="inputs" value="<%= id %>">
        <input type="hidden" name="Tipo<%=id %>" value="<%=Tipo %>" />
    </td>
        <%
        if Tipo="S" then
            ItemInvoiceID = id
            ProdutoInvoiceID = ""

            DisabledRepasse = ""
            TemRepasseGerado=False
            set RepasseSQL = db.execute("SELECT id FROM rateiorateios WHERE ItemContaAPagar is not null and ItemInvoiceID="&ItemInvoiceID)

            if not RepasseSQL.eof then
                TemRepasseGerado=True
                DisabledRepasse=" disabled"
            end if

            if TemRepasseGerado then
            %>
            <input type="hidden" name="RepasseGerado<%= id %>" value="S" />
            <%
            end if
            %>
            <input type="hidden" name="PacoteID<%= id %>" value="<%= PacoteID %>" />
            <td colspan="2"><%= selectInsert("", "ItemID"&id, ItemID, "procedimentos", "NomeProcedimento", " onchange="" parametrosInvoice("&id&", this.value);"" data-row='"& id &"' "&DisabledRepasse, " required ", "") %>
                                <%if session("Odonto")=1 then
                    %>
                    <textarea class="hidden" name="OdontogramaObj<%=id %>" id="OdontogramaObj<%=id %>"><%=OdontogramaObj %></textarea>
                    <%
                  end if %>


            </td>
            <td nowrap="nowrap" >
            <% if  Executado<>"C" then %>
                <span class="checkbox-custom checkbox-primary"><input type="checkbox" class="checkbox-executado" name="Executado<%=id%>" id="Executado<%=id%>" value="S"<%if Executado="S" then%> checked="checked"<%end if%> /><label for="Executado<%=id%>"> Executado</label></span>
            <% end if %>
                <%
                if id>0 and (session("Banco")="clinic5760" or session("Banco")="clinic105" or session("Banco")="clinic100000" or session("Banco")="clinic4421" or session("Banco")="clinic5856" or session("Banco")="clinic5445" or session("Banco")="clinic5968" or session("Banco")="clinic5857" or session("Banco")="clinic6118" or session("Banco")="clinic6273" or session("Banco")="clinic5563" or session("Banco")="clinic6346" or session("Banco")="clinic2665" or session("Banco")="clinic6289" or session("Banco")="clinic5563" or session("Banco")="clinic6451" or session("Banco")="clinic6256") then
                    set vcaPagto = db.execute("select ifnull(sum(Valor), 0) TotalPagoItem from itensdescontados where ItemID="& id)
                    TotalPagoItem = ccur(vcaPagto("TotalPagoItem"))

                    if TotalPagoItem>=ccur(Quantidade*(ValorUnitario+Acrescimo-Desconto)) and Executado="C" then
                        %>
                        <span class="label label-danger">Cancelado</span>
                        <% '<span class="checkbox-custom checkbox-danger"><input type="checkbox" name="Cancelado id" id="Cancelado id" value="C" checked="checked" /><label for="Cancelado id"> Cancelado</label></span> %>
                        <%
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
                <div class="radio-custom radio-primary">
                    <input type="radio" name="Executado<%=id %>" id="Executado<%=id %>C" value="C" <%if Executado="C" then %> checked <%end if %> /><label for="Executado<%=id %>C">Conjunto</label>
                </div>
                <div class="radio-custom radio-primary">
                    <input type="radio" name="Executado<%=id %>" id="Executado<%=id %>U" value="U" <%if Executado="U" then %> checked <%end if %> /><label for="Executado<%=id %>U">Unidade</label>
                </div>
            </td>

            <td ><%= selectInsert("", "ItemID"&id, ItemID, "produtos", "NomeProduto", " onchange=""parametrosProduto("&id&", this.value);""", " required", "") %></td>
<td>
                                        <%'= quickfield("simpleSelect", "CategoriaID"&id, "", 5, CategoriaID, "SELECT t1.id, concat( ifnull(t2.name, ''), ' -> ', t1.name) Categoria FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.id = t1.category LEFT JOIN sys_financialexpensetype AS t3 ON t3.id = t2.category LEFT JOIN sys_financialexpensetype AS t4 ON t4.id = t3.category where t1.Nivel=(select max(Nivel) from sys_financialexpensetype) order by t2.name, t1.name", "Categoria", "") %>
                                        <%=selectInsert("", "CategoriaID"&id, CategoriaID, TabelaCategoria, "Name", "data-exibir="""&LimitarPlanoContas&"""", "", "")%></td>
            <%
        elseif Tipo="O" then
            ItemInvoiceID = id
            ProdutoInvoiceID = ""
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
            <td><%=quickField("text", "Descricao"&id, "", 4, Descricao, " ", "", " placeholder='Descri&ccedil;&atilde;o...' required maxlength='50'")%></td>
            <td >
                <%'= quickfield("simpleSelect", "CategoriaID"&id, "", 5, CategoriaID, "SELECT t1.id, concat( ifnull(t2.name, ''), ' -> ', t1.name) Categoria FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.id = t1.category LEFT JOIN sys_financialexpensetype AS t3 ON t3.id = t2.category LEFT JOIN sys_financialexpensetype AS t4 ON t4.id = t3.category where t1.Nivel=(select max(Nivel) from sys_financialexpensetype) order by t2.name, t1.name", "Categoria", "") %>
                <%=selectInsert("", "CategoriaID"&id, CategoriaID, TabelaCategoria, "Name", "data-exibir="""&LimitarPlanoContas&"""", "", "")%></td>
            <td>
                <%=selectInsert("", "CentroCustoID"&id, CentroCustoID, "CentroCusto", "NomeCentroCusto", "", "", "")%></td>
            <script>
                $("#hCentroCusto").html("Centro de Custo");
                $("#hPlanoContas").html("Plano de Contas");
            </script>
            <%
        end if



        ValorUnitarioReadonly = " "
        notEdit = " "

        if ValorUnitario<>"" and ValorUnitario<>0 and TemRegrasDeDesconto and Tipo="S" and isnull(InvoiceSQL("FixaID")) then
            ValorUnitarioReadonly=" readonly"
            notEdit = " notedit "
        end if

        if aut("valordoprocedimentoA")=0 and Tipo="S" then
            ValorUnitarioReadonly=" readonly"
            notEdit = " notedit "
        end if
        %>
    <td><%=quickField("currency", "ValorUnitario"&id, "", 4, fn(ValorUnitario), " " & notEdit & " CampoValorUnitario text-right disable", "", " onkeyup=""recalc($(this).attr('id'))""" & ValorUnitarioReadonly)%></td>
    <td><%=quickField("text", "Desconto"&id, "", 4, fn(Desconto), " CampoDesconto input-mask-brl text-right disable", "", " data-desconto='"&fn(Desconto)&"' onkeyup=""recalc($(this).attr('id'))""")%></td>
    <td><%=quickField("text", "Acrescimo"&id, "", 4, fn(Acrescimo), " input-mask-brl text-right disable", "", " data-acrescimo='"&fn(Acrescimo)&"' onkeyup=""recalc($(this).attr('id'))""")%></td>
    <td class="text-right" data-valor="<%= fn( Subtotal) %>" id="sub<%=id%>" nowrap>R$ <%= fn( Subtotal) %></td>
    <td><button
    <% if id<0 then %>
    disabled title="Salve a conta para lançar no estoque"
    <%else %>
    title="Lançamentos de estoque"
    <% end if %>
    onclick="modalEstoque('<%=ItemInvoiceID %>', '<%=ItemID %>', '<%= ProdutoInvoiceID %>')" id="btn<%= ProdutoInvoiceID %>" type="button" class="btn btn-alert btn-block btn-sm"><i class="fa fa-medkit"></i></button></td>
    <td><button type="button" id="xili<%= ItemInvoiceID %>" class="btn btn-sm btn-danger disable" onClick="itens('<%=Tipo%>', 'X', '<%=id%>')"><i class="fa fa-remove"></i></button></td>
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
            <th class="text-right" colspan="2">Valor Pago</th>
            <th class="text-right" colspan="2"></th>
        </tr>
        <%
        while not vcaGuia.eof
            TipoGuia = vcaGuia("TipoGuia")
            set g = db.execute("select g.*, pac.NomePaciente from tiss"&TipoGuia&" g LEFT JOIN pacientes pac ON pac.id=g.PacienteID where g.id="&vcaGuia("GuiaID"))
            if not g.eof then
            %>
            <tr>
                <td colspan="2">Guia <%=g("NGuiaPrestador") %></td>
                <td colspan="4">Paciente: <%=g("NomePaciente") %></td>
                <td class="text-right" colspan="2">R$ <%=fn(g("ValorPago")) %></td>
                <td class="text-right" colspan="2"></td>
            </tr>
            <%
            end if
        vcaGuia.movenext
        wend
        vcaGuia.close
        set vcaGuia = nothing
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
    <td colspan="9">
        <div class="row">
    	    <div class="col-xs-3">
			    <label>Profissional</label><br>
			    <%
			    if PacoteID&""="" then
			        onchangeProfissional = " onchange=""espProf("& id &");"" "
			    end if

			    ExecutanteTipos = "5, 8, 2"
			    if session("Banco")="clinic6118" then
                    ExecutanteTipos = "5"
			    end if
			    %>
                <%=simpleSelectCurrentAccounts("ProfissionalID"&id, ExecutanteTipos, Associacao&"_"&ProfissionalID, ExecucaoRequired&" "&onchangeProfissional&DisabledRepasse)%>
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
                %>
                <%= quickField("simpleSelect", "EspecialidadeID"&id, "Especialidade", 2, EspecialidadeID, sqlEspecialidades, "especialidade" , DisabledRepasse&" no-select2 "&camposRequired) %>
                </div>
                <%= quickField("datepicker", "DataExecucao"&id, "Data da Execu&ccedil;&atilde;o", 2, DataExecucao, "", "", ""&ExecucaoRequired&DisabledRepasse) %>
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
end if





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
            'ValorTotal =DadosRepasseSQL("ValorTotal")
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
%>
<script>
$(function(){
    $(".notedit").on('keydown', function() {
       return false
    });
})

document.onkeyup  = function(evt) {
    if(evt.keyCode == 13){
        var proc = $("#VariosProcedimentos").is(':checked');
        if(proc == true){
            var todospreenchidos = 1;
            var i = 1;
            $("select[name^='ItemID-']").each(function(){
                console.log($(this).attr("id"));
                var value = $(this).val();

                if(value == 0) todospreenchidos = 0;
                i++;
            });

            let elem = document.activeElement;
            let labelid = elem.getAttribute("aria-labelledby");
            let result = labelid.match( /select2-ItemID-([0-9]+)-container/ig );

            if(labelid != null && result != null && result.length > 0){
                if(todospreenchidos == 1){
                    itens('S', 'I', 0, '', function(){
                        $("select[name=ItemID-"+i+"]").select2('open');
                        $("select[name=ItemID-"+i+"]").focus();
                    });
                }
            }
        }
    }
};



</script>