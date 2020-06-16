<!--#include file="connect.asp"--><!--#include file="validar.asp"--><!--#include file="md5.asp"--><%

response.ContentType="text/XML"


RLoteID = replace(request.QueryString("I"),".xml", "")
set lote = db.execute("select * from tisslotes where id="&RLoteID)
'set guias = db.execute("select g.*, p.NomePaciente from tissguiasadt as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&lote("id"))
set guias = db.execute("select g.*, p.NomePaciente from tissguiasadt as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&lote("id")&" order by g.NGuiaPrestador")
if not guias.eof then
	RegistroANS = TirarAcento(guias("RegistroANS"))
	CodigoNaOperadora = TirarAcento(guias("CodigoNaOperadora"))
    if session("Banco")="clinic3882" then
        db_execute("update tissguiasadt gs set "&_
        " gs.Procedimentos=(select sum(ValorTotal) from tissprocedimentossadt where GuiaID="& guias("id") &"), "&_
        " gs.TaxasEAlugueis=(select sum(ValorTotal) from tissguiaanexa where GuiaID="& guias("id") &" AND CD=7), "&_
        " gs.Materiais=(select sum(ValorTotal) from tissguiaanexa where GuiaID="& guias("id") &" AND CD=3), "&_
        " gs.OPME=(select sum(ValorTotal) from tissguiaanexa where GuiaID="& guias("id") &" AND CD=8), "&_
        " gs.Medicamentos=(select sum(ValorTotal) from tissguiaanexa where GuiaID="& guias("id") &" AND CD=2), "&_
        " gs.GasesMedicinais=(select sum(ValorTotal) from tissguiaanexa where GuiaID="& guias("id") &" AND CD=1) "&_
        " where id="& guias("id"))
        db_execute("update tissguiasadt set TotalGeral=(ifnull(Procedimentos,0)+ifnull(TaxasEAlugueis,0)+ifnull(Materiais,0)+ifnull(OPME,0)+ifnull(Medicamentos,0)+ifnull(GasesMedicinais,0)) where id="& guias("id"))
        set guias = db.execute("select g.*, p.NomePaciente from tissguiasadt as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&lote("id")&" order by g.NGuiaPrestador")
    end if
end if
NLote = TirarAcento(lote("Lote"))
Data = mydatetiss(lote("sysDate"))
Hora = myTimeTISS( lote("sysDate") )

response.write("<?xml version=""1.0"" encoding=""ISO-8859-1""?>")

response.Charset="utf-8"

versaoTISS = "2.02.01"


prefixo = "00000000000000000000"&NLote
prefixo = right(prefixo, 20)

%>
<ans:mensagemTISS xsi:schemaLocation="http://www.ans.gov.br/padroes/tiss/schemastissV2_02_01.xsd" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <ans:cabecalho>
        <ans:identificacaoTransacao>
            <ans:tipoTransacao>ENVIO_LOTE_GUIAS</ans:tipoTransacao>
            <ans:sequencialTransacao><%=NLote%></ans:sequencialTransacao>
            <ans:dataRegistroTransacao><%=Data%></ans:dataRegistroTransacao>
            <ans:horaRegistroTransacao><%=Hora%></ans:horaRegistroTransacao>
        </ans:identificacaoTransacao>
        <ans:origem>
            <ans:codigoPrestadorNaOperadora>
				<%
                CodigoNaOperadora = trim(CodigoNaOperadora&" ")
                CodigoNaOperadora = TirarAcento(replace(replace(replace(replace(replace(CodigoNaOperadora, ".", ""), "-", ""), ",", ""), "_", ""), " ", ""))
                if CalculaCPF(CodigoNaOperadora)=true then
                    tipoCodigoNaOperadora = "CPF"
                elseif CalculaCNPJ(CodigoNaOperadora)=true then
                    tipoCodigoNaOperadora = "CNPJ"
                else
                    tipoCodigoNaOperadora = "codigoPrestadorNaOperadora"
                end if

                tipoCodigoNaOperadoraContratadoSolicitante = "codigoPrestadorNaOperadora"
                set TipoContratoSQL = db.execute("SELECT IdentificadorCNPJ FROM contratosconvenio WHERE ConvenioID="&guias("ConvenioID")&" AND CodigoNaOperadora='"&CodigoNaOperadora&"'")
                if not TipoContratoSQL.eof then
                    if TipoContratoSQL("IdentificadorCNPJ")="S" then
                        tipoCodigoNaOperadoraContratadoSolicitante = "cnpjContratado"
                    end if
                end if
                %>
                <%="<ans:" & tipoCodigoNaOperadora & ">" & CodigoNaOperadora &"</ans:" & tipoCodigoNaOperadora &">"%>
            </ans:codigoPrestadorNaOperadora>
        </ans:origem>
        <ans:destino>
            <ans:registroANS><%=RegistroANS%></ans:registroANS>
        </ans:destino>
        <ans:versaoPadrao><%=versaoTISS %></ans:versaoPadrao>
    </ans:cabecalho>
    <ans:prestadorParaOperadora>
        <ans:loteGuias>
            <ans:numeroLote><%=NLote%></ans:numeroLote>
            <ans:guias>
            <ans:guiaFaturamento>
				<%'inicia as guias
				hash = "ENVIO_LOTE_GUIAS"&NLote&Data&Hora&CodigoNaOperadora&RegistroANS&versaoTISS&NLote
				while not guias.eof
					'response.Write("{"&guias("NGuiaPrestador")&"}")
					Contratado = TirarAcento(guias("Contratado"))
					if Contratado=0 then
						set emp = db.execute("select NomeEmpresa, CNES from empresa where NomeEmpresa<>''")
						if not emp.eof then
							NomeContratado = TirarAcento(emp("NomeEmpresa"))
							CNESContratado = TirarAcento(emp("CNES"))
						end if
					elseif Contratado<0 then
						set fil = db.execute("select UnitName, CNES from sys_financialcompanyunits where id="&Contratado*(-1))
						if not fil.eof then
							NomeContratado = TirarAcento(fil("UnitName"))
							CNESContratado = TirarAcento(fil("CNES"))
						end if
					else
						set prof = db.execute("select NomeProfissional from profissionais where id="&Contratado)
						if not prof.eof then
							NomeContratado = TirarAcento(prof("NomeProfissional"))
							CNESContratado = "9999999"
						end if
					end if
				
					RegistroANS = TirarAcento(guias("RegistroANS"))
					NGuiaPrestador = TirarAcento(guias("NGuiaPrestador"))
					NGuiaPrincipal = TirarAcento(guias("NGuiaPrincipal"))
					NGuiaOperadora = TirarAcento(guias("NGuiaOperadora"))
					DataAutorizacao = mydatetiss(guias("DataAutorizacao"))
					Senha = TirarAcento(guias("Senha"))
					DataValidadeSenha = mydatetiss(guias("DataValidadeSenha"))
					NumeroCarteira = TirarAcento(guias("NumeroCarteira"))
					AtendimentoRN = TirarAcento(guias("AtendimentoRN"))
					NomePaciente = TirarAcento(guias("NomePaciente"))
					ContratadoSolicitanteID = TirarAcento(guias("ContratadoSolicitanteID"))
					if guias("tipoContratadoSolicitante")="I" then
						if ContratadoSolicitanteID=0 then
							set emp = db.execute("select NomeEmpresa, CNES from empresa where NomeEmpresa<>''")
							if not emp.eof then
								NomeContratadoSolicitante = TirarAcento(emp("NomeEmpresa"))
								CNESContratadoSolicitante = TirarAcento(emp("CNES"))
							end if
						elseif ContratadoSolicitanteID<0 then
							set fil = db.execute("select UnitName, CNES from sys_financialcompanyunits where id="&ContratadoSolicitanteID*(-1))
							if not fil.eof then
								NomeContratadoSolicitante = TirarAcento(fil("UnitName"))
								CNESContratadoSolicitante = TirarAcento(fil("CNES"))
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
					ProfissionalSolicitanteID = TirarAcento(guias("ProfissionalSolicitanteID"))
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
						ConselhoProfissionalSolicitante = TirarAcento(consol("TISS"))
						SiglaConselhoProfissionalSolicitante = TirarAcento(consol("codigo"))
					end if
					NumeroNoConselhoSolicitante = TirarAcento(guias("NumeroNoConselhoSolicitante"))
					set coduf = db.execute("select codigo from estados where sigla like '"&guias("UFConselhoSolicitante")&"'")
					if not coduf.eof then
						CodigoUFConselhoSolicitante = TirarAcento(coduf("codigo"))
					end if
					UFConselhoSolicitante = guias("UFConselhoSolicitante")
					CodigoCBOSolicitante = TirarAcento(guias("CodigoCBOSolicitante"))
					DataSolicitacao = mydatetiss(guias("DataSolicitacao"))
					CaraterAtendimentoID = TirarAcento(guias("CaraterAtendimentoID"))
					IndicacaoClinica = TirarAcento(guias("IndicacaoClinica"))
					ContExecCodigoNaOperadora = TirarAcento(guias("CodigoNaOperadora"))
					ContExecCodigoNaOperadora = TirarAcento(replace(replace(replace(replace(replace(ContExecCodigoNaOperadora, ".", ""), "-", ""), ",", ""), "_", ""), " ", ""))
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
							CNESContratado = TirarAcento(emp("CNES"))
						end if
					elseif Contratado<0 then
						set fil = db.execute("select UnitName, CNES from sys_financialcompanyunits where id="&Contratado*(-1))
						if not fil.eof then
							NomeContratado = TirarAcento(fil("UnitName"))
							CNESContratado = TirarAcento(fil("CNES"))
						end if
					else
						set prof = db.execute("select NomeProfissional from profissionais where id="&Contratado)
						if not prof.eof then
							NomeContratado = TirarAcento(prof("NomeProfissional"))
							CNESContratado = "9999999"
						end if
					end if
					TipoAtendimentoID = TirarAcento(zEsq(guias("TipoAtendimentoID"),2))
					IndicacaoAcidenteID = TirarAcento(guias("IndicacaoAcidenteID"))
					MotivoEncerramentoID = TirarAcento(guias("MotivoEncerramentoID"))
					if MotivoEncerramentoID=0 then MotivoEncerramentoID="" end if
					TipoConsultaID = TirarAcento(guias("TipoConsultaID"))
					'==============================================================================================================================================================================
					if guias("CodigoCNES")="" then CodigoCNES=TirarAcento(CNESContratado) else CodigoCNES=TirarAcento(guias("CodigoCNES")) end if
					NomeProfissional=TirarAcento(NomeProfissional)

					if guias("planoID")&""<>"" then
						set plano = db.execute("select * from conveniosplanos where id="&guias("planoID"))
						if not plano.eof then
							NomePlano = plano("NomePlano")
						end if
					end if

					if CaraterAtendimentoID&""<>"" then
						if CaraterAtendimentoID&"" = "1" then
							CaraterAtendimentoSigla = "E"
						end if
						if CaraterAtendimentoID&"" = "2" then
							CaraterAtendimentoSigla = "U"
						end if
					end if
					
					'set atend = db.execute("select DataHora from atendimentos where id="&guias("AtendimentoID"))
					'if not atend.eof then
					'	datahora = atend("DataHora")
					'	dataHoraAtendimento = mydatetiss(datahora)&"T"&myTimeTISS(datahora)
					'end if
					datahora = guias("sysDate")
					dataHoraAtendimento = mydatetiss(datahora)&"T"&myTimeTISS(datahora)
                    TipoSaida="5"
					CodigoCBOSolicitante = Left(CodigoCBOSolicitante,4)&"."&Right(CodigoCBOSolicitante,2)
					hash = hash&RegistroANS&DataSolicitacao&NGuiaPrestador&NGuiaPrincipal&NGuiaOperadora&DataAutorizacao&Senha&DataValidadeSenha&NumeroCarteira&NomePaciente&NomePlano&ContratadoSolicitanteCodigoNaOperadora&NomeContratadoSolicitante&NomeProfissionalSolicitante&SiglaConselhoProfissionalSolicitante&NumeroNoConselhoSolicitante&UFConselhoSolicitante&CodigoCBOSolicitante&ContExecCodigoNaOperadora&NomeContratado&CodigoCNES&IndicacaoClinica&CaraterAtendimentoSigla&dataHoraAtendimento&TipoSaida&TipoAtendimentoID
					%>
                <ans:guiaSP_SADT>
                    <ans:identificacaoGuiaSADTSP>
                        <ans:identificacaoFontePagadora>
                            <ans:registroANS><%=RegistroANS%></ans:registroANS>
                        </ans:identificacaoFontePagadora>
                        <ans:dataEmissaoGuia><%= DataSolicitacao %></ans:dataEmissaoGuia>
                        <ans:numeroGuiaPrestador><%= NGuiaPrestador %></ans:numeroGuiaPrestador>
                        <%if NGuiaPrincipal<>"" then%><ans:guiaPrincipal><%= NGuiaPrincipal %></ans:guiaPrincipal><%end if%>
                    </ans:identificacaoGuiaSADTSP>
                    <%
					if NGuiaOperadora<>"" OR DataAutorizacao<>"" OR Senha<>"" OR DataValidadeSenha<>"" then
					%>
                    <ans:dadosAutorizacao>
                        <%if NGuiaOperadora<>"" then%><ans:numeroGuiaOperadora><%= NGuiaOperadora %></ans:numeroGuiaOperadora><%end if%>
                        <%if DataAutorizacao<>"" then%><ans:dataAutorizacao><%= DataAutorizacao %></ans:dataAutorizacao><% End If %>
                        <%if Senha<>"" then%><ans:senhaAutorizacao><%= Senha %></ans:senhaAutorizacao><% End If %>
                        <%if DataValidadeSenha<>"" then%><ans:validadeSenha><%= DataValidadeSenha %></ans:validadeSenha><% End If %>
                    </ans:dadosAutorizacao>
                    <%
					end if
					%>
                    <ans:dadosBeneficiario>
                        <ans:numeroCarteira><%= NumeroCarteira %></ans:numeroCarteira>
                        <ans:nomeBeneficiario><%= NomePaciente %></ans:nomeBeneficiario>
						<ans:nomePlano><%= NomePlano %></ans:nomePlano>
                    </ans:dadosBeneficiario>
                    <ans:dadosSolicitante>
                        <ans:contratado>
							<ans:identificacao>
								<%="<ans:" & tipoCodigoNaOperadoraContratadoSolicitante & ">" & ContratadoSolicitanteCodigoNaOperadora &"</ans:" & tipoCodigoNaOperadoraContratadoSolicitante &">"%>
                            </ans:identificacao>
							<ans:nomeContratado><%= NomeContratadoSolicitante %></ans:nomeContratado>
                        </ans:contratado>
						<ans:profissional>
                            <ans:nomeProfissional><%= NomeProfissionalSolicitante %></ans:nomeProfissional>
							<ans:conselhoProfissional>
								<ans:siglaConselho><%= SiglaConselhoProfissionalSolicitante %></ans:siglaConselho>
								<ans:numeroConselho><%= NumeroNoConselhoSolicitante %></ans:numeroConselho>
								<ans:ufConselho><%= UFConselhoSolicitante %></ans:ufConselho>
							</ans:conselhoProfissional>
                            <ans:cbos><%= CodigoCBOSolicitante %></ans:cbos>
                        </ans:profissional>
                    </ans:dadosSolicitante>
					<ans:prestadorExecutante>
                        <ans:identificacao>
                            <%="<ans:" &tipoContrato &">"&ContExecCodigoNaOperadora &"</ans:"&tipoContrato&">"%>
                        </ans:identificacao>
						<ans:nomeContratado><%= NomeContratado %></ans:nomeContratado>
                        <ans:numeroCNES><%= CodigoCNES %></ans:numeroCNES>
                    </ans:prestadorExecutante>

					<%if IndicacaoClinica<>"" then%><ans:indicacaoClinica><%= IndicacaoClinica %></ans:indicacaoClinica><% End If %>
                    <ans:caraterAtendimento><%= CaraterAtendimentoSigla %></ans:caraterAtendimento>
                    <%if dataHoraAtendimento<>"" then%><ans:dataHoraAtendimento><%= dataHoraAtendimento %></ans:dataHoraAtendimento><% End If %>
                    <ans:tipoSaida><%= TipoSaida %></ans:tipoSaida>
                    <ans:tipoAtendimento><%= TipoAtendimentoID %></ans:tipoAtendimento>

                    <%
					set procs = db.execute("select * from tissprocedimentossadt where GuiaiD="&guias("id"))
                    if not procs.eof then
                    %>
                    <ans:procedimentosRealizados>
                    <%
					while not procs.eof
						Data = mydatetiss(procs("Data"))
						HoraInicio = myTimeTISS(procs("HoraInicio"))
						HoraFim = myTimeTISS(procs("HoraFim"))
						TabelaID = TirarAcento(procs("TabelaID"))
						if TabelaID="99" or TabelaID="0" then
							TabelaID="00"
						end if
						CodigoProcedimento = TirarAcento(procs("CodigoProcedimento"))
						Descricao = TirarAcento(procs("Descricao"))
						Descricao = left(Descricao, 60)
						Quantidade = TirarAcento(procs("Quantidade"))
						
						ViaID = TirarAcento(procs("ViaID"))
						Select Case ViaID
							Case 1:
								ViaID = "U"
							Case 2:
								ViaID = "M"
							Case 3:
								ViaID = "D"
						End Select

						TecnicaID = TirarAcento(procs("TecnicaID"))
						Select Case TecnicaID
							Case 1:
								TecnicaID = "C"
							Case 2:
								TecnicaID = "V"
						End Select

						Fator = treatvaltiss(1)
						ValorUnitario = treatvaltiss( procs("Fator")*procs("ValorUnitario") )
						ValorTotal = treatvaltiss(procs("ValorTotal"))
						
						%>
                        <ans:procedimentos>
                            <%
							set eq = db.execute("select e.*, p.NomeProfissional, grau.Codigo as GrauParticipacao, est.codigo as UF from tissprofissionaissadt as e left join profissionais as p on p.id=e.ProfissionalID left join estados as est on est.sigla like e.UFConselho left join cliniccentral.tissgrauparticipacao as grau on grau.id=e.GrauParticipacaoID where GuiaID="&guias("id"))
							if not eq.eof then
							%>
							<ans:equipe>
							<%
							while not eq.eof
								GrauParticipacao = TirarAcento(eq("GrauParticipacao")&"")
								if GrauParticipacao="" or isnull(GrauParticipacao) then GrauParticipacao="" end if
								CodigoNaOperadoraOuCPF = TirarAcento(eq("CodigoNaOperadoraOuCPF"))
								if CodigoNaOperadoraOuCPF="" then CodigoNaOperadoraOuCPF="-" end if

								if CalculaCPF(CodigoNaOperadoraOuCPF)=true then
									tipoContrato = "cpf"
								'elseif CalculaCNPJ(CodigoNaOperadoraOuCPF)=true then
								'	tipoContrato = "cnpjContratado"
								else
									tipoContrato = "codigoPrestadorNaOperadora"
								end if

								NomeProfissional = TirarAcento(eq("NomeProfissional")&" ")
								set cons = db.execute("select * from conselhosprofissionais where id = '"&eq("ConselhoID")&"'")
								if cons.eof then ConselhoProfissional = 6 else ConselhoProfissional=TirarAcento(cons("TISS")) end if
								DocumentoConselho = TirarAcento(eq("DocumentoConselho"))
								SiglaConselho = cons("codigo")
								UF = TirarAcento(eq("UF"))
								UFConselho = TirarAcento(eq("UFConselho"))
								CodigoCBO = TirarAcento(eq("CodigoCBO"))

								if CodigoNaOperadoraOuCPF = "-" then
									SiglaConselhoProf = SiglaConselho
									DocumentoConselhoProf = DocumentoConselho
									UFConselhoProf = UFConselho
								end if
								CodigoCBO = Left(CodigoCBO,4)&"."&Right(CodigoCBO,2)
								hash = hash & CodigoNaOperadoraOuCPF&SiglaConselhoProf&DocumentoConselhoProf&UFConselhoProf&NomeProfissional&SiglaConselho&DocumentoConselho&UFConselho&CodigoCBO&GrauParticipacao
							%>
								<ans:membroEquipe>
									<ans:codigoProfissional>
										<% if CodigoNaOperadoraOuCPF <> "-" then%>
										<%="<ans:"&tipoContrato&">"& CodigoNaOperadoraOuCPF &"</ans:"&tipoContrato&">"%>
										<% else %>
										<ans:siglaConselho><%= SiglaConselhoProf %></ans:siglaConselho>
										<ans:numeroConselho><%= SiglaConselhoProf %></ans:numeroConselho>
										<ans:ufConselho><%= UFConselhoProf %></ans:ufConselho>
										<% end if %>
									</ans:codigoProfissional>
									<ans:identificacaoProfissional>
										<ans:nomeExecutante><%= NomeProfissional %></ans:nomeExecutante>
										<ans:conselhoProfissional>
											<ans:siglaConselho><%= SiglaConselho %></ans:siglaConselho>
											<ans:numeroConselho><%= DocumentoConselho %></ans:numeroConselho>
											<ans:ufConselho><%= UFConselho %></ans:ufConselho>
										</ans:conselhoProfissional>
										<ans:codigoCBOS><%= CodigoCBO%></ans:codigoCBOS>
									</ans:identificacaoProfissional>
									<ans:posicaoProfissional><%= GrauParticipacao %></ans:posicaoProfissional>
								</ans:membroEquipe>
                            <%
							eq.movenext
							wend
							eq.close
							set eq = nothing
							%>
                            </ans:equipe>
							<%
							end if
							hash = hash &CodigoProcedimento&TabelaID&Descricao&Data&HoraInicio&HoraFim&Quantidade&ViaID&TecnicaID&Fator&ValorUnitario&ValorTotal
							%>
							<ans:procedimento>
                                <ans:codigo><%=  CodigoProcedimento%></ans:codigo>
                                <ans:tipoTabela><%= TabelaID %></ans:tipoTabela>
                                <%if Descricao<>"" then%><ans:descricao><%= Descricao %></ans:descricao><%end if%>
                            </ans:procedimento>
                            <%if Data<>"" then%><ans:data><%= Data %></ans:data><% End If %>
                            <%if HoraInicio<>"" then%><ans:horaInicio><%= HoraInicio %></ans:horaInicio><% End If %>
                            <%if HoraFim<>"" then%><ans:horaFim><%= HoraFim %></ans:horaFim><% End If %>
                            <ans:quantidadeRealizada><%= Quantidade %></ans:quantidadeRealizada>
                            <ans:viaAcesso><%= ViaID %></ans:viaAcesso>
                            <ans:tecnicaUtilizada><%= TecnicaID %></ans:tecnicaUtilizada>
                            <ans:reducaoAcrescimo><%= Fator %></ans:reducaoAcrescimo>
                            <ans:valor><%= ValorUnitario %></ans:valor>
                            <ans:valorTotal><%= ValorTotal %></ans:valorTotal>

                        </ans:procedimentos>
                        <%
					procs.movenext
					wend
					procs.close
					set procs=nothing
					%>
                    </ans:procedimentosRealizados>
                    <%
                    end if
					set desp = db.execute("select * from tissguiaanexa where GuiaID="&guias("id"))
					if not desp.eof then
					%>
                    <ans:outrasDespesas>
                    	<%
						while not desp.eof
							CD = desp("CD")
							Data = mydatetiss(desp("Data"))
							HoraInicio = myTimeTISS(desp("HoraInicio"))
							HoraFim = myTimeTISS(desp("HoraFim"))
							TabelaProdutoID = zeroEsq(TirarAcento(desp("TabelaProdutoID")), 2)
							CodigoProduto = TirarAcento(desp("CodigoProduto"))
							Quantidade = treatvaltiss(desp("Quantidade"))
							UnidadeMedidaID = zEsq(desp("UnidadeMedidaID"), 3)
							Fator = treatvaltiss(desp("Fator"))
							ValorUnitario = treatvaltiss(desp("ValorUnitario"))
							ValorTotal = treatvaltiss(desp("ValorTotal"))
							Descricao = TirarAcento(desp("Descricao"))
                            Descricao = replace(Descricao, chr(186), "")
                            Descricao = left(Descricao, 60)
							RegistroANVISA = TirarAcento(desp("RegistroANVISA"))
							CodigoNoFabricante = TirarAcento(desp("CodigoNoFabricante"))
							AutorizacaoEmpresa = TirarAcento(desp("AutorizacaoEmpresa"))
							
							hash = hash &CodigoProduto&TabelaProdutoID&Descricao&CD&Data&HoraInicio&HoraFim&Fator&Quantidade&ValorUnitario&ValorTotal
						%>
                        <ans:despesa>
                            <ans:identificadorDespesa>
							    <ans:codigo><%= CodigoProduto %></ans:codigo>
                                <ans:tipoTabela><%= TabelaProdutoID %></ans:tipoTabela>
                                <%if Descricao<>"" then%><ans:descricao><%= Descricao %></ans:descricao><%end if%>
							</ans:identificadorDespesa>
                            <ans:tipoDespesa><%= CD %></ans:tipoDespesa>
                            <ans:dataRealizacao><%= Data %></ans:dataRealizacao>
                            <%if HoraInicio<>"" then%><ans:horaInicial><%= HoraInicio %></ans:horaInicial><% End If %>
                            <%if HoraFim<>"" then%><ans:horaFinal><%= HoraFim %></ans:horaFinal><% End If %>
							<%if Fator<>"" then%><ans:reducaoAcrescimo><%= Fator %></ans:reducaoAcrescimo><% End If %>
							<ans:quantidade><%= Quantidade %></ans:quantidade>
							<ans:valorUnitario><%= ValorUnitario %></ans:valorUnitario>
							<ans:valorTotal><%= ValorTotal %></ans:valorTotal>
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
					
					hash = hash & Procedimentos&Diarias&TaxasEAlugueis&Materiais&Medicamentos&GasesMedicinais&TotalGeral&Observacoes
					%>
                    <ans:valorTotal>
                        <ans:servicosExecutados><%= Procedimentos %></ans:servicosExecutados>
                        <ans:diarias><%= Diarias %></ans:diarias>
                        <ans:taxas><%= TaxasEAlugueis %></ans:taxas>
                        <ans:materiais><%= Materiais %></ans:materiais>
                        <ans:medicamentos><%= Medicamentos %></ans:medicamentos>
                        <ans:gases><%= GasesMedicinais %></ans:gases>
                        <ans:totalGeral><%= TotalGeral %></ans:totalGeral>
                    </ans:valorTotal>
                    <%if Observacoes<>"" then%><ans:observacao><%= Observacoes %></ans:observacao><% End If %>
                </ans:guiaSP_SADT>
                <%
				guias.movenext
				wend
				guias.close
				set guias=nothing

				'finaliza as guias%>
            </ans:guiaFaturamento>
            </ans:guias>
        </ans:loteGuias>
    </ans:prestadorParaOperadora>
    <ans:epilogo>
        <ans:hash><%= md5(hash) %></ans:hash>
    </ans:epilogo>
</ans:mensagemTISS>
<%
Response.AddHeader "Content-Disposition", "attachment; filename=" & prefixo & "_" & md5(hash)&".xml"
%>