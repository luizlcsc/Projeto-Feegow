<%
hiddenValor = ""


if (session("Banco")="clinic4456" and lcase(session("Table"))="profissionais" and not session("Admin")=1) or aut("valordoprocedimentoV")<>1 then
    hiddenValor = " hidden "
end if

IF NOT (Prioridade > 0) THEN
    Prioridade = 1
END IF
agendamentoBtnDisabled = "disabled"
if ItemID&""<>"" then
    procedimentosConfigsSQL = "select NaoNecessitaAgendamento from procedimentos where id="&ItemID
    set procedimentosConfigs =  db.execute(procedimentosConfigsSQL)
    if not procedimentosConfigs.eof then
        if procedimentosConfigs("NaoNecessitaAgendamento") = "S" then
            agendamentoBtnDisabled=""
        end if
    end if
    procedimentosConfigs.close
    set procedimentosConfigs = nothing  
end if
%>

<tr id="row<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%> Ordem="<%=Ordem%>" class="proposta-item-procedimentos">
    <% IF getConfig("ExibirPrioridadeDePropostas") = "1" THEN %>
    <td>
        <a href="javascript:void(0)" onclick="movTr('down',this)"><i class="far fa-caret-up" aria-hidden="true"></i></a>
        <a href="javascript:void(0)" onclick="movTr('up',this)"><i class="far fa-caret-down" aria-hidden="true"></i></a>
    </td>
    <td class="td-prioridades">
        <button type="button" class="btn btn-default" onclick="changePrioridade(this)" <%=desabilitarProposta%>>
            <input type="hidden" class="prioridade-proposta" name="Prioridade<%=id%>" value="<%=Prioridade%>"> <span class="prioridade-text"><%=Prioridade%></span>
        </button>
    </td>
    <% END IF %>
    <td>
    	<input type="hidden" name="propostaItem" value="<%=id%>">
    	<% IF PacoteID > 0 THEN %>
    	    <input type="hidden" name="pacoteID<%=id%>" value="<%=PacoteID%>">
    	<% END IF %>
    	<input type="hidden" class="ordem-proposta" name="ordem<%=id%>" value="<%=Ordem%>">
		<%=quickField("text", "Quantidade"&id, "", 4, Quantidade, " text-right disable input-sm", "", desabilitarProposta&" required onkeyup=""recalc($(this).attr('id'))""")%><input type="hidden" name="inputs" value="<%= id %>"></td>
        <%
        if Tipo="S" or Tipo="P" then
            %>
            <td colspan="2" style="max-width: 330px">
                <div class='dflex'>
                    <div style="width: 100%">
                        <%= selectInsert("", "ItemID"&id, ItemID, "procedimentos", "NomeProcedimento", " onchange="" """&desabilitarProposta, " required", "") %>
                    </div>
                    <div class='dflex colunflex executantes' <% IF not moduloCallCenter THEN%> style="display:none" <% END IF %>>
                        <label>Executante</label>
                        
                        <input type='checkbox' onClick='toggleLine(<%=id%>)' <% IF ProfissionalExecutanteID <> "" THEN%> checked <% END IF %>/>
                    </div>
                </div>
                <% IF moduloCallCenter or ProfissionalExecutanteID <> "" THEN%>
                    <div class="profi<%=id%> openAllProfissional" >
                        <% ExecucaoRequired = " required empty " %>
                        <label class='mt5'>Profissional Executante</label>
                        <div>
                            <%=simpleSelectCurrentAccountsFilterOption("ProfissionalLinhaID"&id, "5, 8, 2", ProfissionalExecutanteID, ExecucaoRequired&" "&onchangeProfissional&DisabledRepasse,ItemID) %>
                        </div>

                    </div>
                 <% END IF %>
            </td>

            <%
            if session("Odonto")=1 then
            %>
                <textarea class="hidden" name="OdontogramaObj<%=id %>" id="OdontogramaObj<%=id %>"><%=OdontogramaObj %></textarea>
            <%
            end if 
        elseif Tipo="O" then
			set data = db.execute("select * from propostas where id="&PropostaID)
			if not data.eof then
				TabelaCategoria = "sys_financialincometype"
			end if
            %>
            <td><%=quickField("text", "Descricao"&id, "", 4, Descricao, " disable", "", " placeholder='Descri&ccedil;&atilde;o...' required"&desabilitarProposta)%></td>
            <td width="200"><%=selectInsert("", "CategoriaID"&id, CategoriaID, TabelaCategoria, "Name", "", " placeholder='Categoria...'", ""&desabilitarProposta)%></td>
            <%
        end if

        ValorUnitarioReadonly = ""

        if ValorUnitario<>"" and ValorUnitario<>0 and TemRegrasDeDesconto then
            ValorUnitarioReadonly=" readonly"
        end if
        %>
        <td><div class="<%=hiddenValor%>"><%=quickField("currency", "ValorUnitario"&id, "", 4, formatnumber(ValorUnitario,2), " input-sm text-right ValorUnitario disable", "", " required onkeyup=""recalc($(this).attr('id'))"""&ValorUnitarioReadonly&desabilitarProposta)%></div></td>
        <td>
            <div class="input-group <%=hiddenValor%>">
                <%=quickField("text", "Desconto"&id, "", 4, formatnumber(Desconto,2), " input-mask-brl PropostaDesconto text-right disable input-sm", "", " onkeyup=""recalc($(this).attr('id'))"" style=""width:55%; max-width: 85px;float:left;min-width:10px"""&desabilitarProposta)%>
                <select onchange="recalc($(this).attr('id'))" style="max-width: 85px;width: 35%;padding:0;min-width: 10px;" name="DescontoTipo<%=id%>" id="DescontoTipo<%=id%>" class="form-control input-sm DescontoTipo" <%=desabilitarProposta%>>
                    <option value="V">R$</option>
                    <option <% if TipoDesconto="P" then %>selected<% end if %> value="P">%</option>
                </select>
            </div>
        </td>
        <td>
            <div class="<%=hiddenValor%>"><%=quickField("text", "Acrescimo"&id, "", 4, formatnumber(Acrescimo,2), " input-mask-brl text-right disable input-sm", "", " onkeyup=""recalc($(this).attr('id'))"""&desabilitarProposta)%></div>
        </td>
        <td>
            <div class="text-right <%=hiddenValor%>" id="sub<%=id%>" nowrap>R$ <%= formatnumber( Subtotal ,2) %></div>
        </td>
        <td class="text-center">
        <button onclick="agendar(<%=ItemID%>, <%=id%>)" class="btn btn-xs btn-success" <%=agendamentoBtnDisabled%>> <i class="fa fa-calendar"></i> </button>
        <button type="button" class="btn btn-xs btn-danger disable <%=escondeProposta%>" onClick="itens('<%=Tipo%>', 'X', '<%=id%>')"><i class="far fa-remove "></i></button></td>
    </td>
</tr>
<script >
    <%
    if AvisoAgenda&""<>"" then
    %>

    showMessageDialog('<%=replace(replace(AvisoAgenda, chr(10), "\n"), chr(13), "")%>', "warning");

    <%
    end if
    %>
    
</script>