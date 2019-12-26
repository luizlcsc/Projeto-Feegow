            <tr class="<%=tipoLinha%>linha"<%
                if ultimaDataFatura<>inv("DataFatura") then
                    %> data-datafatura="<%=mydatejunto(inv("DataFatura")) %>" <%
                end if
                
                 %>>
              <td width="10%" nowrap class="text-center">
			  <%
			  if tipoLinha="s" then
			  	response.Write( "<i class=""fa fa-angle-right""></i>" )
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

						checado = "<i class=""fa fa-check green""></i>  "
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
                    if ii("Tipo")="S" or ii("Tipo")="P" then
                        if Executado = "C" then 
                        %>
                            <span class="label label-danger">Cancelado</span>
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
                      <button type="button" onclick="modalEstoque('<%= ItemID %>', '', '')" class="btn btn-xs btn-alert"><i class="fa fa-medkit"></i></button>
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
                       BoletoHtml = " <i class='fa fa-barcode text-primary'></i> "
                    END IF

                    IF (Boletos("vencido") > "0") THEN
                       BoletoHtml = " <i class='fa fa-barcode text-danger'></i> "
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
                    set soliSQL = db.execute("SELECT * FROM labs_solicitacoes WHERE InvoiceID="&treatvalzero(inv("id")))
                    if not soliSQL.eof then
                        matrixColor = "success"
                    end if

                    set executados = db.execute("select count(*) as totalexecutados from itensinvoice where InvoiceID="&inv("id")&" AND Executado!='S'")
                    set temintegracao = db.execute("select count(*) as temintegracao from itensinvoice ii inner join procedimentos p on ii.ItemId = p.id  where InvoiceID="&inv("id")&" and p.IntegracaoPleres = 'S'")
                    'set laboratorios = db.execute("SELECT labID FROM labs_procedimentos_laboratorios WHERE procedimentoID = '" & ProcedimentoID &"'")
                    set laboratorios = db.execute("SELECT * FROM cliniccentral.labs AS lab INNER JOIN labs_procedimentos_laboratorios AS lpl ON (lpl.labID = lab.id) WHERE lpl.procedimentoID ="& treatvalzero(ProcedimentoID) )
                    
                    laboratorioid = 1
                    NomeLaboratorio = ""
                    if  not laboratorios.eof then
                        laboratorioid = laboratorios("labID")
                        NomeLaboratorio = laboratorios("NomeLaboratorio")
                    end if 

                    if CInt(temintegracao("temintegracao")) > 0 then
                    %>
                        <script>
                        setTimeout(function() {
                            $("#btn-pleres").css("display", "none");
                        }, 1000)
                        </script>
                        <div class="btn-group">
                            <% if laboratorioid = "1" then %>
                                <button type="button" onclick="abrirMatrix('<%=inv("id")%>')" class="btn btn-<%=matrixColor%> btn-xs" id="btn-abrir-modal-matrix" title="Abrir integração com <%=NomeLaboratorio %>">
                                    <i class="fa fa-flask"></i>
                                </button>
                            <% else %>
                                <button type="button" onclick="abrirDiagBrasil('<%=inv("id")%>','<%=laboratorios("labID")%>')" class="btn btn-<%=matrixColor%> btn-xs" id="btn-abrir-modal-matrix" title="Abrir integração com <%=NomeLaboratorio %>">
                                    <i class="fa fa-flask"></i>
                                </button>    
                            <% end if %>
                        </div>
                    <%
			        end if
			    end if
              end if
			  	set mov = db.execute("select id, ifnull(ValorPago, 0) ValorPago, Value, Date, CD, CaixaID from sys_financialmovement where InvoiceID="&inv("id")&" AND Type='Bill' ORDER BY Date")
				set executados = db.execute("select count(*) as totalexecutados from itensinvoice where InvoiceID="&inv("id")&" AND Executado!='S'")
				set temintegracao = db.execute("select count(*) as temintegracao from itensinvoice ii inner join procedimentos p on ii.ItemId = p.id  where InvoiceID="&inv("id")&" and p.IntegracaoPleres = 'S'")
				
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