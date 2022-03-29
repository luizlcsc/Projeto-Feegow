<tr class="<%=tipoLinha%>linha"<%
    if ultimaDataFatura<>inv("DataFatura") then
        %> data-datafatura="<%=mydatejunto(inv("DataFatura")) %>" <%
    end if  %>>
    <td width="10%" nowrap class="text-center">
        <%
        if tipoLinha="s" then
            response.Write( "<i class=""far fa-angle-right""></i>" )
        else
            response.Write( linkData )
        end if

        identII = ";" & ProfissionalID & "|" & ProcedimentoID &"|"& DataExecucao &";"
        %>
    </td>
    <td width="30%" id="V<%=replace(replace(replace(identII, "|", ""), ";", ""), "/", "")%>">
        <%=Descricao%>
    </td>
    <td width="20%">
        <%
        medkit = 0
        if check=1 then
            if Executado="S" then
                desabilitar = " disabled "
                if aut("profissionalcontaA")=1 then
                    desabilitar = " "
                end if

                checado = "<i class=""far fa-check green""></i>  "
                'set exec = db.execute("select * from profissionais where id="&treatvalzero(ProfissionalID))
                'if not exec.eof then
                    if Associacao=0 or isnull(Associacao) then
                        Associacao = 5
                    end if
                    Executor = left(accountName(Associacao, ProfissionalID)&" ", 15) & " - " & DataExecucao
                'else
                '	Executor = "Excluído"
                'end if
            else
                checado = ""
                Executor = "Não executado"
            end if

            if ii("Tipo")="S" or ii("Tipo")="P" or not isnull(DataCancelamento) then
                if Executado = "C" or not isnull(DataCancelamento) then
                    %>
                        <span class="label label-danger"><i class="far fa-times"></i> Cancelado</span>
                    <%
                else 
                    medkit = 1
                    %>
                    <button type="button" class="btn btn-block btn-xs btn-default" name="Executado" data-value="<%=ItemID %>" <%=desabilitar%>><%=checado%> <%=Executor%></button>
                    <%
                end if
            end if
            if len(Observacoes)>2 then
                response.Write "<em><small>"&Observacoes&"</small></em>"
            end if
        else
            %>
            &nbsp;
            <%
        end if
       
        %>
    </td>
    <td width="10%">
        <%
        if tipoLinha="u" then
            %>	
            <span class="badge badge-success">  Particular </span>
            <%
        end if
        %>
    </td>
    <td class=" text-right" width="10%">
        <%
        if tipoLinha="u" then
        response.Write( fn(inv("ValorTotal")) )
        else
        response.Write( fn(ii("Valor")) )
        end if
        %>
        &nbsp;
    </td>
    <td  width="20%" colspan =2 class="text-right">
        
        <%
        if tipoLinha="u" then
            if medkit=1 then 
                %>
                <button type="button" onclick="modalEstoque('<%= ItemID %>', '', '')" class="btn btn-xs btn-alert"><i class="far fa-medkit"></i></button>
                <% 
            end if 
            if recursoAdicional(8)=4 then
                sqlBoletos = "SELECT coalesce(sum(boletos_emitidos.DueDate > now() and StatusID = 1),0) as aberto"&_
                            "       ,coalesce(sum(now() > boletos_emitidos.DueDate and StatusID <> 3),0) as vencido"&_
                            "       ,coalesce(sum(StatusID  = 3),0) as pago"&_
                            "       ,COUNT(*) as totalboletos"&_
                            " FROM sys_financialinvoices"&_
                            " JOIN boletos_emitidos ON boletos_emitidos.InvoiceID = sys_financialinvoices.id"&_
                            " WHERE TRUE"&_
                            " AND boletos_emitidos.InvoiceID = "&inv("id")
                set Boletos = db.execute(sqlBoletos)
                BoletoHtml = ""
                IF (Boletos("aberto") > "0") THEN
                    BoletoHtml = " <i class='far fa-barcode text-primary'></i> "
                END IF

                IF (Boletos("vencido") > "0") THEN
                    BoletoHtml = " <i class='far fa-barcode text-danger'></i> "
                END IF
            %>
            <%=BoletoHtml%>
            <%
            end if        
            response.write(retornaBotaoIntegracaoLaboratorial ("sys_financialinvoices", InvoiceID))  
            set mov = db_execute("select id, ifnull(ValorPago, 0) ValorPago, Value, Date, CD, CaixaID from sys_financialmovement where InvoiceID="&inv("id")&" AND Type='Bill' ORDER BY Date")
            set executados = db_execute("select count(*) as totalexecutados from itensinvoice where InvoiceID="&inv("id")&" AND Executado!='S'")                            
            while not mov.eof
                response.Write( btnParcela(mov("id"), mov("ValorPago"), mov("Value"), mov("Date"), mov("CD"), mov("CaixaID")) )
                mov.movenext
            wend
            mov.close
            set mov=nothing
        end if
        
        %>
    </td>
    <!--<td></td>-->
</tr>