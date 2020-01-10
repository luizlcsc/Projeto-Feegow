                    <div class="panel" id="p1">
                        <div class="panel-heading">
                            <span class="panel-title"><%'= getResource("name") %>Convênios do Paciente</span>
                    
                            <span class="panel-controls">
                            <a class="panel-control-collapse hidden" href="#"></a>
                            </span>
                        </div>
                        <div class="panel-body pn">
                        
                            <div class="widget-main padding-6 no-padding-left no-padding-right">
                             <script>
                                function getConvenioDetails(campo){
                                    let convenioID = $("#ConvenioID"+campo).val();

                                    if(convenioID){
                                       $.post("ConvenioDetails.asp?ConvenioID="+convenioID, "", function(data){
                                       let dados =  eval(data);
                                       if(dados){
                                               $("#Matricula"+campo).attr("pattern",".{"+dados.MinimoDigitos+","+dados.MaximoDigitos+"}");
                                               $("#Matricula"+campo).attr("title","O padrão da matrícula deste convênio está configurado para o de minimo de "+dados.MinimoDigitos+" e o maximo de "+dados.MaximoDigitos+" caracteres");
                                           }
                                       });
                                    }
                                }
                                </script>
                                <table class="table">
                                    <thead>
                                        <tr class="">
                                            <th width="12%">Convênio</th>
                                            <th width="12%">Plano</th>
                                            <th width="22%">Matrícula / Carteirinha</th>
                                            <th width="18%">Token Carteirinha</th>
                                            <th width="18%">Validade</th>
                                            <th width="21%">Titular</th>
                                            <th width="1%"></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <%
									Numero = 0
									while Numero<3
										Numero=Numero+1
                                        
										%>
                                    	<tr>
                                        	<td><%=selectInsert("", "ConvenioID"&Numero, reg("ConvenioID"&Numero), "convenios", "NomeConvenio", "onchange='getConvenioDetails("&Numero&");'", "empty", "")%>
                                            </td>
                                        	<td><%=selectInsert("", "PlanoID"&Numero, reg("PlanoID"&Numero), "conveniosplanos", "NomePlano", "", "", "ConvenioID"&Numero)%></td>
                                        	<td nowrap><%=quickField("text", "Matricula"&Numero, "", 12, reg("Matricula"&Numero), " lt ", "", "")%></td>
                                            <td><%=quickField("text", "Token"&Numero, "", 12, reg("Token"&Numero), " lt ", "", "")%></td>
                                        	<td><%=quickField("datepicker", "Validade"&Numero, "", 12, reg("Validade"&Numero), " input-mask-date ", "", "")%></td>
                                        	<td><%=quickField("text", "Titular"&Numero, "", 12, reg("Titular"&Numero), "", "", "")%></td>
                                        	<td>
                                                <button id="btnElegibilidade<%=Numero %>" title="Verificar elegibilidade" class="btn btn-xs btn-warning" onclick="verificaElegibilidade(<%=Numero %>)" type="button">
                                                    <i id="icoElegibilidade<%=Numero %>" class="fa fa-compress"></i>
                                                </button>
                                            <script type="text/javascript"> getConvenioDetails("<%=Numero%>"); </script>

                                        	</td>
                                        </tr>
                                        <%
									wend
									%>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>