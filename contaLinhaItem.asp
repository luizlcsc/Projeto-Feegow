            <tr class="<%=tipoLinha%>linha"<%
                if ultimaDataFatura<>inv("DataFatura") then
                    %> data-datafatura="<%=mydatejunto(inv("DataFatura")) %>" <%
                end if
                
                 %>>
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
              <td width="30%" id="V<%=replace(replace(replace(identII, "|", ""), ";", ""), "/", "")%>"><%=Descricao%></td>
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
              <td>
                  <% if medkit=1 then %>
                      <button type="button" onclick="modalEstoque('<%= ItemID %>', '', '')" class="btn btn-xs btn-alert"><i class="far fa-medkit"></i></button>
                  <% end if %>
              </td>
              <td width="10%">
              <%
			  if tipoLinha="u" then
			  	%>	
                Particular
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
              &nbsp;</td>
              <td class="text-right" width="20%">
              <%

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
			  if tipoLinha="u" then

                if recursoAdicional(24)=4 then
                set labAutenticacao = db.execute("SELECT * FROM labs_autenticacao WHERE UnidadeID="&treatvalzero(inv("UnidadeID")))
                    if not labAutenticacao.eof then

                    matrixColor = "warning"
                    set soliSQL = db.execute("SELECT * FROM labs_solicitacoes  WHERE success='S' AND InvoiceID="&treatvalzero(inv("id")))
                    foiIntegrado = 0
                    if not soliSQL.eof then
                        matrixColor = "success"
                        foiIntegrado  = 1
                    end if

                    set executados = db.execute("select count(*) as totalexecutados from itensinvoice where InvoiceID="&inv("id")&" AND Executado!='S'")
                    set temintegracao = db.execute("select count(*) as temintegracao from itensinvoice ii inner join procedimentos p on ii.ItemId = p.id  where InvoiceID="&inv("id")&" and p.IntegracaoPleres = 'S'")
                    
                    sqllaboratorios = "SELECT lab.id labID, lab.NomeLaboratorio, count(*) total "&_
                                      " FROM cliniccentral.labs AS lab "&_
                                      " INNER JOIN labs_procedimentos_laboratorios AS lpl ON (lpl.labID = lab.id) "&_
                                      " INNER JOIN procedimentos AS proc ON (proc.id  = lpl.procedimentoID) "&_
                                      " INNER JOIN itensinvoice ii ON (ii.ItemID = proc.id) "&_
                                      " WHERE proc.TipoProcedimentoID = 3 AND ii.InvoiceID ='"&inv("id")&"'"&_
                                      "  GROUP BY 1,2 "

                    set laboratorios = db.execute(sqllaboratorios)

                    sqlintegracao = "SELECT le.LabID "&_
                                    "   FROM labs_invoices_exames lie "&_
                                    "  INNER JOIN cliniccentral.labs_exames le ON (le.id = lie.LabExameID) "&_
                                    "  WHERE lie.InvoiceID  ='"&inv("id")&"' order by 1 limit 1"
                    'response.write(sqlintegracao)
                    set integracao = db.execute(sqlintegracao)

                    totallabs=0
                    multiploslabs = 0
                    contintegracao = 0
                    laboratorioid = 4
                    NomeLaboratorio = ""
                    informacao = ""                   

                    if  not laboratorios.eof then
                        while not laboratorios.eof ' recordcount estava retornando -1 então...
                            totallabs = totallabs +1
                            laboratorios.movenext
                        wend 
                        laboratorios.movefirst
                        if totallabs > 1 then
                            multiploslabs = 1
                            'informacao = "<p> Os <strong>PROCEDIMENTOS</strong> desta conta estão vinculados a laboratórios diferentes. Por favor verifique a<strong> CONFIGURAÇÃO DOS PROCEDIMENTOS ou separe os procedimentos</strong>. <p>"
                            informacao = ""

                        else 
                            laboratorioid = laboratorios("labID")
                            NomeLaboratorio = laboratorios("NomeLaboratorio")
                        end if
                    end if 

                     if not integracao.eof then 
                         laboratorioid = integracao("labid")
                         multiploslabs = 0
                    end if

                    if CInt(temintegracao("temintegracao")) > 0 then
                    %>
                        <script>
                        setTimeout(function() {
                            $("#btn-pleres").css("display", "none");
                        }, 1000)
                        </script>
                        <div class="btn-group" id="btnIntegracao_<%=inv("id")%>">
                            <% if multiploslabs = 1 and foiIntegrado = 0 then %> 
                                <button type="button" onclick="abrirSelecaoLaboratorio('<%=inv("id")%>','<%=CInt(temintegracao("temintegracao")) %>')" class="btn btn-danger btn-xs" title="Laboratórios Multiplos">
                                    <i class="far fa-flask"></i>
                                </button>
                            <% else %> 
                                <button type="button" onclick="abrirIntegracao('<%=inv("id")%>','<%=laboratorioid%>', '<%=CInt(temintegracao("temintegracao")) %>')" class="btn btn-<%=matrixColor%> btn-xs" id="btn-abrir-modal-matrix<%=inv("id")%>" title="Abrir integração com Laboratório <%=NomeLaboratorio %>">
                                    <i class="far fa-flask"></i>
                                </button>    
                            <% end if %>
                        </div>
                    <%
			        end if
			    end if
              end if
			  	set mov = db.execute("select id, ifnull(ValorPago, 0) ValorPago, Value, Date, CD, CaixaID from sys_financialmovement where InvoiceID="&inv("id")&" AND Type='Bill' ORDER BY Date")
				set executados = db.execute("select count(*) as totalexecutados from itensinvoice where InvoiceID="&inv("id")&" AND Executado!='S'")
				'set temintegracao = db.execute("select count(*) as temintegracao from itensinvoice ii inner join procedimentos p on ii.ItemId = p.id  where InvoiceID="&inv("id")&" and p.IntegracaoPleres = 'S'")
				
				while not mov.eof
                  response.Write( btnParcela(mov("id"), mov("ValorPago"), mov("Value"), mov("Date"), mov("CD"), mov("CaixaID")) )
				mov.movenext
				wend
				mov.close
				set mov=nothing
			  end if
			  %>
			  </td>
              <td></td>
            </tr>