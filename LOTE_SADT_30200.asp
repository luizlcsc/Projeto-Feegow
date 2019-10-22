<!--#include file="connect.asp"--><!--#include file="validar.asp"--><!--#include file="md5.asp"--><%

response.ContentType="text/XML"


RLoteID = replace(request.QueryString("I"),".xml", "")
set lote = db.execute("select * from tisslotes where id="&RLoteID)
'set guias = db.execute("select g.*, p.NomePaciente from tissguiasadt as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&lote("id"))
set guias = db.execute("select g.*, p.NomePaciente from tissguiasadt as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&lote("id")&" order by g.NGuiaPrestador")
if not guias.eof then
	RegistroANS = trim(guias("RegistroANS"))
	CodigoNaOperadora = trim(guias("CodigoNaOperadora"))
end if
NLote = lote("Lote")
Data = mydatetiss(lote("sysDate"))
Hora = myTimeTISS( lote("sysDate") )

response.write("<?xml version=""1.0"" encoding=""ISO-8859-1""?>")

response.Charset="utf-8"


%>
<ans:mensagemTISS xsi:schemaLocation="http://www.ans.gov.br/padroes/tiss/schemas tissV3_02_00.xsd" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <ans:cabecalho>
        <ans:identificacaoTransacao>
            <ans:tipoTransacao>ENVIO_LOTE_GUIAS</ans:tipoTransacao>
            <ans:sequencialTransacao><%=NLote%></ans:sequencialTransacao>
            <ans:dataRegistroTransacao><%=Data%></ans:dataRegistroTransacao>
            <ans:horaRegistroTransacao><%=Hora%></ans:horaRegistroTransacao>
        </ans:identificacaoTransacao>
        <ans:origem>
            <ans:identificacaoPrestador>
				<%
                CodigoNaOperadora = trim(CodigoNaOperadora&" ")
                CodigoNaOperadora = replace(replace(replace(replace(replace(CodigoNaOperadora, ".", ""), "-", ""), ",", ""), "_", ""), " ", "")
                if CalculaCPF(CodigoNaOperadora)=true then
                    tipoCodigoNaOperadora = "CPF"
                elseif CalculaCNPJ(CodigoNaOperadora)=true then
                    tipoCodigoNaOperadora = "CNPJ"
                else
                    tipoCodigoNaOperadora = "codigoPrestadorNaOperadora"
                end if
                %>
                <ans:<%=tipoCodigoNaOperadora%>><%=CodigoNaOperadora%></ans:<%=tipoCodigoNaOperadora%>>
            </ans:identificacaoPrestador>
        </ans:origem>
        <ans:destino>
            <ans:registroANS><%=RegistroANS%></ans:registroANS>
        </ans:destino>
        <ans:versaoPadrao>3.02.00</ans:versaoPadrao>
    </ans:cabecalho>
    <ans:prestadorParaOperadora>
        <ans:loteGuias>
            <ans:numeroLote><%=NLote%></ans:numeroLote>
            <ans:guiasTISS>
				<%'inicia as guias
				hash = "ENVIO_LOTE_GUIAS"&NLote&Data&Hora&CodigoNaOperadora&RegistroANS&"3.02.00"&NLote
				while not guias.eof
					'response.Write("{"&guias("NGuiaPrestador")&"}")
					Contratado = guias("Contratado")
					if Contratado=0 then
						set emp = db.execute("select NomeEmpresa, CNES from empresa where NomeEmpresa<>''")
						if not emp.eof then
							NomeContratado = TirarAcento(emp("NomeEmpresa"))
							CNESContratado = emp("CNES")
						end if
					elseif Contratado<0 then
						set fil = db.execute("select UnitName, CNES from sys_financialcompanyunits where id="&Contratado*(-1))
						if not fil.eof then
							NomeContratado = TirarAcento(fil("UnitName"))
							CNESContratado = fil("CNES")
						end if
					else
						set prof = db.execute("select NomeProfissional from profissionais where id="&Contratado)
						if not prof.eof then
							NomeContratado = TirarAcento(prof("NomeProfissional"))
							CNESContratado = "9999999"
						end if
					end if
				
					RegistroANS = trim(guias("RegistroANS"))
					NGuiaPrestador = trim(guias("NGuiaPrestador"))
					NGuiaPrincipal = trim(guias("NGuiaPrincipal"))
					NGuiaOperadora = trim(guias("NGuiaOperadora"))
					DataAutorizacao = mydatetiss(guias("DataAutorizacao"))
					Senha = trim(guias("Senha"))
					DataValidadeSenha = mydatetiss(guias("DataValidadeSenha"))
					NumeroCarteira = trim(guias("NumeroCarteira"))
					AtendimentoRN = guias("AtendimentoRN")
					NomePaciente = TirarAcento(guias("NomePaciente"))
					ContratadoSolicitanteID = guias("ContratadoSolicitanteID")
					if guias("tipoContratadoSolicitante")="I" then
						if ContratadoSolicitanteID=0 then
							set emp = db.execute("select NomeEmpresa, CNES from empresa where NomeEmpresa<>''")
							if not emp.eof then
								NomeContratadoSolicitante = TirarAcento(emp("NomeEmpresa"))
								CNESContratadoSolicitante = emp("CNES")
							end if
						elseif ContratadoSolicitanteID<0 then
							set fil = db.execute("select UnitName, CNES from sys_financialcompanyunits where id="&ContratadoSolicitanteID*(-1))
							if not fil.eof then
								NomeContratadoSolicitante = TirarAcento(fil("UnitName"))
								CNESContratadoSolicitante = fil("CNES")
							end if
						else
							set prof = db.execute("select NomeProfissional from profissionais where id="&ContratadoSolicitanteID)
							if not prof.eof then
								NomeContratadoSolicitante = TirarAcento(prof("NomeProfissional"))
								CNESContratadoSolicitante = "9999999"
							end if
						end if
					else
						set context = db.execute("select * from contratadoexterno where id="&ContratadoSolicitanteID)
						if not context.eof then
							NomeContratadoSolicitante = TirarAcento(contExt("NomeContratado"))
						end if
					end if
					ContratadoSolicitanteCodigoNaOperadora = TirarAcento(guias("ContratadoSolicitanteCodigoNaOperadora"))
					if ContratadoSolicitanteCodigoNaOperadora="" then ContratadoSolicitanteCodigoNaOperadora="-" end if
					ProfissionalSolicitanteID = guias("ProfissionalSolicitanteID")
					if guias("tipoProfissionalSolicitante")="I" then
						set prof = db.execute("select NomeProfissional from profissionais where id="&ProfissionalSolicitanteID)
					else
						set prof = db.execute("select NomeProfissional from profissionalexterno where id="&ProfissionalSolicitanteID)
					end if
					if not prof.eof then
						NomeProfissionalSolicitante = TirarAcento(prof("NomeProfissional"))
					end if
					set consol = db.execute("select * from conselhosprofissionais where id="&guias("ConselhoProfissionalSolicitanteID"))
					if not consol.eof then
						ConselhoProfissionalSolicitante = consol("TISS")
					end if
					NumeroNoConselhoSolicitante = TirarAcento(guias("NumeroNoConselhoSolicitante"))
					set coduf = db.execute("select codigo from estados where sigla like '"&guias("UFConselhoSolicitante")&"'")
					if not coduf.eof then
						CodigoUFConselhoSolicitante = coduf("codigo")
					end if
					CodigoCBOSolicitante = TirarAcento(guias("CodigoCBOSolicitante"))
					DataSolicitacao = mydatetiss(guias("DataSolicitacao"))
					CaraterAtendimentoID = trim(guias("CaraterAtendimentoID"))
					IndicacaoClinica = TirarAcento(guias("IndicacaoClinica"))
					ContExecCodigoNaOperadora = trim(guias("CodigoNaOperadora"))
					ContExecCodigoNaOperadora = replace(replace(replace(replace(replace(ContExecCodigoNaOperadora, ".", ""), "-", ""), ",", ""), "_", ""), " ", "")
					if CalculaCPF(CodigoNaOperadora)=true then
						tipoContrato = "cpfContratado"
					elseif CalculaCNPJ(CodigoNaOperadora)=true then
						tipoContrato = "cnpjContratado"
					else
						tipoContrato = "codigoPrestadorNaOperadora"
					end if
					Contratado = guias("Contratado")
					if Contratado=0 then
						set emp = db.execute("select NomeEmpresa, CNES from empresa where NomeEmpresa<>''")
						if not emp.eof then
							NomeContratado = TirarAcento(emp("NomeEmpresa"))
							CNESContratado = emp("CNES")
						end if
					elseif Contratado<0 then
						set fil = db.execute("select UnitName, CNES from sys_financialcompanyunits where id="&Contratado*(-1))
						if not fil.eof then
							NomeContratado = TirarAcento(fil("UnitName"))
							CNESContratado = fil("CNES")
						end if
					else
						set prof = db.execute("select NomeProfissional from profissionais where id="&Contratado)
						if not prof.eof then
							NomeContratado = TirarAcento(prof("NomeProfissional"))
							CNESContratado = "9999999"
						end if
					end if
					TipoAtendimentoID = zEsq(guias("TipoAtendimentoID"),2)
					IndicacaoAcidenteID = guias("IndicacaoAcidenteID")
					MotivoEncerramentoID = guias("MotivoEncerramentoID")
					if MotivoEncerramentoID=0 then MotivoEncerramentoID="" end if
					TipoConsultaID = guias("TipoConsultaID")
					'==============================================================================================================================================================================
					if guias("CodigoCNES")="" then CodigoCNES=CNESContratado else CodigoCNES=trim(guias("CodigoCNES")) end if
					NomeProfissional=TirarAcento(NomeProfissional)
					
					hash = hash&RegistroANS&NGuiaPrestador&NGuiaPrincipal&NGuiaOperadora&DataAutorizacao&Senha&DataValidadeSenha&NumeroCarteira&AtendimentoRN&NomePaciente&ContratadoSolicitanteCodigoNaOperadora&NomeContratadoSolicitante&NomeProfissionalSolicitante&ConselhoProfissionalSolicitante&NumeroNoConselhoSolicitante&CodigoUFConselhoSolicitante&CodigoCBOSolicitante&DataSolicitacao&CaraterAtendimentoID&IndicacaoClinica&ContExecCodigoNaOperadora&NomeContratado&CodigoCNES&TipoAtendimentoID&IndicacaoAcidenteID&TipoConsultaID&MotivoEncerramentoID
					%>
                <ans:guiaSP-SADT>
                    <ans:cabecalhoGuia>
                        <ans:registroANS><%=RegistroANS%></ans:registroANS>
                        <ans:numeroGuiaPrestador><%= NGuiaPrestador %></ans:numeroGuiaPrestador>
                        <%if NGuiaPrincipal<>"" then%><ans:guiaPrincipal><%= NGuiaPrincipal %></ans:guiaPrincipal><%end if%>
                    </ans:cabecalhoGuia>
                    <%
					if NGuiaOperadora<>"" OR DataAutorizacao<>"" OR Senha<>"" OR DataValidadeSenha<>"" then
					%>
                    <ans:dadosAutorizacao>
                        <%if NGuiaOperadora<>"" then%><ans:numeroGuiaOperadora><%= NGuiaOperadora %></ans:numeroGuiaOperadora><%end if%>
                        <%if DataAutorizacao<>"" then%><ans:dataAutorizacao><%= DataAutorizacao %></ans:dataAutorizacao><% End If %>
                        <%if Senha<>"" then%><ans:senha><%= Senha %></ans:senha><% End If %>
                        <%if DataValidadeSenha<>"" then%><ans:dataValidadeSenha><%= DataValidadeSenha %></ans:dataValidadeSenha><% End If %>
                    </ans:dadosAutorizacao>
                    <%
					end if
					%>
                    <ans:dadosBeneficiario>
                        <ans:numeroCarteira><%= NumeroCarteira %></ans:numeroCarteira>
                        <ans:atendimentoRN><%= AtendimentoRN %></ans:atendimentoRN>
                        <ans:nomeBeneficiario><%= NomePaciente %></ans:nomeBeneficiario>
                    </ans:dadosBeneficiario>
                    <ans:dadosSolicitante>
                        <ans:contratadoSolicitante>
                            <ans:codigoPrestadorNaOperadora><%= ContratadoSolicitanteCodigoNaOperadora %></ans:codigoPrestadorNaOperadora>
                            <ans:nomeContratado><%= NomeContratadoSolicitante %></ans:nomeContratado>
                        </ans:contratadoSolicitante>
                        <ans:profissionalSolicitante>
                            <ans:nomeProfissional><%= NomeProfissionalSolicitante %></ans:nomeProfissional>
                            <ans:conselhoProfissional><%= ConselhoProfissionalSolicitante %></ans:conselhoProfissional>
                            <ans:numeroConselhoProfissional><%= NumeroNoConselhoSolicitante %></ans:numeroConselhoProfissional>
                            <ans:UF><%= CodigoUFConselhoSolicitante %></ans:UF>
                            <ans:CBOS><%= CodigoCBOSolicitante %></ans:CBOS>
                        </ans:profissionalSolicitante>
                    </ans:dadosSolicitante>
                    <ans:dadosSolicitacao>
                        <ans:dataSolicitacao><%= DataSolicitacao %></ans:dataSolicitacao>
                        <ans:caraterAtendimento><%= CaraterAtendimentoID %></ans:caraterAtendimento>
                        <%if IndicacaoClinica<>"" then%><ans:indicacaoClinica><%= IndicacaoClinica %></ans:indicacaoClinica><% End If %>
                    </ans:dadosSolicitacao>
                    <ans:dadosExecutante>
                        <ans:contratadoExecutante>
                            <%="<ans:" &tipoContrato &">"&ContExecCodigoNaOperadora &"</ans:"&tipoContrato&">"%>
                            <ans:nomeContratado><%= NomeContratado %></ans:nomeContratado>
                        </ans:contratadoExecutante>
                        <ans:CNES><%= CodigoCNES %></ans:CNES>
                    </ans:dadosExecutante>
                    <ans:dadosAtendimento>
                        <ans:tipoAtendimento><%= TipoAtendimentoID %></ans:tipoAtendimento>
                        <ans:indicacaoAcidente><%= IndicacaoAcidenteID %></ans:indicacaoAcidente>
                        <ans:tipoConsulta><%= TipoConsultaID %></ans:tipoConsulta>
                        <%if MotivoEncerramentoID<>"" then%><ans:motivoEncerramento><%= MotivoEncerramentoID %></ans:motivoEncerramento><% End If %>
                    </ans:dadosAtendimento>
                    <ans:procedimentosExecutados>
                    <%
					set procs = db.execute("select * from tissprocedimentossadt where GuiaiD="&guias("id"))
					while not procs.eof
						Data = mydatetiss(procs("Data"))
						HoraInicio = myTimeTISS(procs("HoraInicio"))
						HoraFim = myTimeTISS(procs("HoraFim"))
						TabelaID = procs("TabelaID")
						if TabelaID="99" then
							TabelaID="00"
						end if
						CodigoProcedimento = TirarAcento(procs("CodigoProcedimento"))
						Descricao = TirarAcento(procs("Descricao"))
						Quantidade = procs("Quantidade")
						ViaID = procs("ViaID")
						TecnicaID = procs("TecnicaID")
						Fator = treatvaltiss(procs("Fator"))
						ValorUnitario = treatvaltiss(procs("ValorUnitario"))
						ValorTotal = treatvaltiss(procs("ValorTotal"))
						
						hash = hash & Data&HoraInicio&HoraFim&TabelaID&CodigoProcedimento&Descricao&Quantidade&ViaID&TecnicaID&Fator&ValorUnitario&ValorTotal
						%>
                        <ans:procedimentoExecutado>
                            <%if Data<>"" then%><ans:dataExecucao><%= Data %></ans:dataExecucao><% End If %>
                            <%if HoraInicio<>"" then%><ans:horaInicial><%= HoraInicio %></ans:horaInicial><% End If %>
                            <%if HoraFim<>"" then%><ans:horaFinal><%= HoraFim %></ans:horaFinal><% End If %>
                            <ans:procedimento>
                                <ans:codigoTabela><%= TabelaID %></ans:codigoTabela>
                                <ans:codigoProcedimento><%= CodigoProcedimento %></ans:codigoProcedimento>
                                <ans:descricaoProcedimento><%= Descricao %></ans:descricaoProcedimento>
                            </ans:procedimento>
                            <ans:quantidadeExecutada><%= Quantidade %></ans:quantidadeExecutada>
                            <ans:viaAcesso><%= ViaID %></ans:viaAcesso>
                            <ans:tecnicaUtilizada><%= TecnicaID %></ans:tecnicaUtilizada>
                            <ans:reducaoAcrescimo><%= Fator %></ans:reducaoAcrescimo>
                            <ans:valorUnitario><%= ValorUnitario %></ans:valorUnitario>
                            <ans:valorTotal><%= ValorTotal %></ans:valorTotal>
                            <%
							set eq = db.execute("select e.*, p.NomeProfissional, grau.Codigo as GrauParticipacao, est.codigo as UF from tissprofissionaissadt as e left join profissionais as p on p.id=e.ProfissionalID left join estados as est on est.sigla like e.UFConselho left join cliniccentral.tissgrauparticipacao as grau on grau.id=e.GrauParticipacaoID where GuiaID="&guias("id"))
							while not eq.eof
								GrauParticipacao = eq("GrauParticipacao")
								if GrauParticipacao="" or isnull(GrauParticipacao) then GrauParticipacao="00" end if
								CodigoNaOperadoraOuCPF = trim(eq("CodigoNaOperadoraOuCPF"))
								if CodigoNaOperadoraOuCPF="" then CodigoNaOperadoraOuCPF="-" end if


								if CalculaCPF(CodigoNaOperadoraOuCPF)=true then
									tipoContrato = "cpfContratado"
								'elseif CalculaCNPJ(CodigoNaOperadoraOuCPF)=true then
								'	tipoContrato = "cnpjContratado"
								else
									tipoContrato = "codigoPrestadorNaOperadora"
								end if



								NomeProfissional = TirarAcento(eq("NomeProfissional")&" ")
								set cons = db.execute("select * from conselhosprofissionais where id="&eq("ConselhoID"))
								if cons.eof then ConselhoProfissional = 6 else ConselhoProfissional=cons("TISS") end if
								DocumentoConselho = eq("DocumentoConselho")
								UF = eq("UF")
								CodigoCBO = eq("CodigoCBO")
								hash = hash & GrauParticipacao&CodigoNaOperadoraOuCPF&NomeProfissional&ConselhoProfissional&DocumentoConselho&UF&CodigoCBO
							%>
                            <ans:equipeSadt>
                                <ans:grauPart><%= GrauParticipacao %></ans:grauPart>
                                <ans:codProfissional>
                                    <%="<ans:"&tipoContrato&">"& CodigoNaOperadoraOuCPF &"</ans:"&tipoContrato&">"%>
                                </ans:codProfissional>
                                <ans:nomeProf><%= NomeProfissional %></ans:nomeProf>
                                <ans:conselho><%= ConselhoProfissional %></ans:conselho>
                                <ans:numeroConselhoProfissional><%= DocumentoConselho %></ans:numeroConselhoProfissional>
                                <ans:UF><%= UF %></ans:UF>
                                <ans:CBOS><%= CodigoCBO %></ans:CBOS>
                            </ans:equipeSadt>
                            <%
							eq.movenext
							wend
							eq.close
							set eq = nothing
							%>
                        </ans:procedimentoExecutado>
                        <%
					procs.movenext
					wend
					procs.close
					set procs=nothing
					%>
                    </ans:procedimentosExecutados>
                    <%
					set desp = db.execute("select * from tissguiaanexa where GuiaID="&guias("id"))
					if not desp.eof then
					%>
                    <ans:outrasDespesas>
                    	<%
						while not desp.eof
							CD = zEsq(desp("CD"), 2)
							Data = mydatetiss(desp("Data"))
							HoraInicio = myTimeTISS(desp("HoraInicio"))
							HoraFim = myTimeTISS(desp("HoraFim"))
							TabelaProdutoID = desp("TabelaProdutoID")
							CodigoProduto = trim(desp("CodigoProduto"))
							Quantidade = treatvaltiss(desp("Quantidade"))
							UnidadeMedidaID = zEsq(desp("UnidadeMedidaID"), 3)
							Fator = treatvaltiss(desp("Fator"))
							ValorUnitario = treatvaltiss(desp("ValorUnitario"))
							ValorTotal = treatvaltiss(desp("ValorTotal"))
							Descricao = TirarAcento(desp("Descricao"))
							RegistroANVISA = TirarAcento(desp("RegistroANVISA"))
							CodigoNoFabricante = TirarAcento(desp("CodigoNoFabricante"))
							AutorizacaoEmpresa = TirarAcento(desp("AutorizacaoEmpresa"))
							
							hash = hash & CD&Data&HoraInicio&HoraFim&TabelaProdutoID&CodigoProduto&Quantidade&UnidadeMedidaID&Fator&ValorUnitario&ValorTotal&Descricao&RegistroANVISA&CodigoNoFabricante&AutorizacaoEmpresa
						%>
                        <ans:despesa>
                            <ans:codigoDespesa><%= CD %></ans:codigoDespesa>
                            <ans:servicosExecutados>
                                <%if Data<>"" then%><ans:dataExecucao><%= Data %></ans:dataExecucao><% End If %>
                                <%if HoraInicio<>"" then%><ans:horaInicial><%= HoraInicio %></ans:horaInicial><% End If %>
                                <%if HoraFim<>"" then%><ans:horaFinal><%= HoraFim %></ans:horaFinal><% End If %>
                                <ans:codigoTabela><%= TabelaProdutoID %></ans:codigoTabela>
                                <ans:codigoProcedimento><%= CodigoProduto %></ans:codigoProcedimento>
                                <ans:quantidadeExecutada><%= Quantidade %></ans:quantidadeExecutada>
                                <ans:unidadeMedida><%=UnidadeMedidaID%></ans:unidadeMedida>
                                <ans:reducaoAcrescimo><%= Fator %></ans:reducaoAcrescimo>
                                <ans:valorUnitario><%= ValorUnitario %></ans:valorUnitario>
                                <ans:valorTotal><%= ValorTotal %></ans:valorTotal>
                                <ans:descricaoProcedimento><%= Descricao %></ans:descricaoProcedimento>
                                <%if RegistroANVISA<>"" then%><ans:registroANVISA><%= RegistroANVISA %></ans:registroANVISA><% End If %>
                                <%if CodigoNoFabricante<>"" then%><ans:codigoRefFabricante><%= CodigoNoFabricante %></ans:codigoRefFabricante><% End If %>
                                <%if AutorizacaoEmpresa<>"" then%><ans:autorizacaoFuncionamento><%= AutorizacaoEmpresa %></ans:autorizacaoFuncionamento><% End If %>
                            </ans:servicosExecutados>
                        </ans:despesa>
                        <%
						desp.movenext
						wend
						desp.close
						set desp=nothing
						%>
                    </ans:outrasDespesas>
                    <%
					end if
					
					Observacoes = guias("Observacoes")
					Observacoes = TirarAcento(Observacoes)
					Procedimentos = treatvaltiss(guias("Procedimentos"))
					Diarias = "0.00"
					TaxasEAlugueis = treatvaltiss(guias("TaxasEAlugueis"))
					Materiais = treatvaltiss(guias("Materiais"))
					Medicamentos = treatvaltiss(guias("Medicamentos"))
					OPME = treatvaltiss(guias("OPME"))
					GasesMedicinais = treatvaltiss(guias("GasesMedicinais"))
					TotalGeral = treatvaltiss(guias("TotalGeral"))
					
					hash = hash & Observacoes&Procedimentos&Diarias&TaxasEAlugueis&Materiais&Medicamentos&OPME&GasesMedicinais&TotalGeral
					%>
                    <%if Observacoes<>"" then%><ans:observacao><%= Observacoes %></ans:observacao><% End If %>
                    <ans:valorTotal>
                        <ans:valorProcedimentos><%= Procedimentos %></ans:valorProcedimentos>
                        <ans:valorDiarias><%= Diarias %></ans:valorDiarias>
                        <ans:valorTaxasAlugueis><%= TaxasEAlugueis %></ans:valorTaxasAlugueis>
                        <ans:valorMateriais><%= Materiais %></ans:valorMateriais>
                        <ans:valorMedicamentos><%= Medicamentos %></ans:valorMedicamentos>
                        <ans:valorOPME><%= OPME %></ans:valorOPME>
                        <ans:valorGasesMedicinais><%= GasesMedicinais %></ans:valorGasesMedicinais>
                        <ans:valorTotalGeral><%= TotalGeral %></ans:valorTotalGeral>
                    </ans:valorTotal>
                </ans:guiaSP-SADT>
                <%
				guias.movenext
				wend
				guias.close
				set guias=nothing

				'finaliza as guias%>
            </ans:guiasTISS>
        </ans:loteGuias>
    </ans:prestadorParaOperadora>
    <ans:epilogo>
        <ans:hash><%= md5(hash) %></ans:hash>
    </ans:epilogo>
</ans:mensagemTISS>
<%
Response.AddHeader "Content-Disposition", "attachment; filename="&md5(hash)&".xml"
%>