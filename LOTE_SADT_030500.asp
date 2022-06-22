<!--#include file="connect.asp"--><!--#include file="validar.asp"--><!--#include file="md5.asp"--><%

response.ContentType="text/XML"


RLoteID = replace(req("I"),".xml", "")
set lote = db.execute("select * from tisslotes where id="&RLoteID)

orderByVar = "order by g.NGuiaPrestador"

LoteOrdem = lote("ordem")&""

if LoteOrdem="Paciente" then
    orderByVar = "order by p.NomePaciente"
elseif LoteOrdem = "Data" then
    orderByVar = "order by g.sysDate"
elseif LoteOrdem = "Solicitacao" then
    orderByVar = "order by g.DataSolicitacao"
end if
'set guias = db.execute("select g.*, p.NomePaciente from tissguiasadt as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&lote("id"))
set guias = db.execute("select g.*, p.NomePaciente from tissguiasadt as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&lote("id")&" "&orderByVar)
if not guias.eof then
	RegistroANS = TirarAcento(guias("RegistroANS"))
	CodigoNaOperadora = TirarAcento(guias("CodigoNaOperadora"))
end if
NLote = TirarAcento(lote("Lote"))
Data = mydatetiss(lote("sysDate"))
Hora = myTimeTISS( lote("sysDate") )

response.write("<?xml version=""1.0"" encoding=""ISO-8859-1""?>")
Response.CodePage = 28591
response.Charset="utf-8"

versaoTISS = "3.05.00"


prefixo = "00000000000000000000"&NLote
prefixo = right(prefixo, 20)

%>
<ans:mensagemTISS xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:schemaLocation="http://www.ans.gov.br/padroes/tiss/schemas/tissV3_05_00.xsd" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas">
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
                CodigoNaOperadora = TISS__FormataConteudo(TISS__RemoveCaracters(CodigoNaOperadora))
                CodigoNaOperadoraValida = CodigoNaOperadora
                if CalculaCPF(CodigoNaOperadoraValida)=true then
                    tipoCodigoNaOperadora = "CPF"
                elseif CalculaCNPJ(CodigoNaOperadoraValida)=true then
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
            </ans:identificacaoPrestador>
        </ans:origem>
        <ans:destino>
            <ans:registroANS><%=RegistroANS%></ans:registroANS>
        </ans:destino>
        <ans:Padrao><%=versaoTISS %></ans:Padrao>
    </ans:cabecalho>
    <ans:prestadorParaOperadora>
        <ans:loteGuias>
            <ans:numeroLote><%=NLote%></ans:numeroLote>
            <ans:guiasTISS>
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
					NumeroCarteira = TISS__FormataConteudoCustom(guias("NumeroCarteira"), true, "", "", "", 20)
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
					end if
                    ConselhoProfissionalSolicitante = zeroEsq(ConselhoProfissionalSolicitante, 2)
					NumeroNoConselhoSolicitante = TirarAcento(guias("NumeroNoConselhoSolicitante"))
					set coduf = db.execute("select codigo from estados where sigla like '"&guias("UFConselhoSolicitante")&"'")
					if not coduf.eof then
						CodigoUFConselhoSolicitante = TirarAcento(coduf("codigo"))
					end if
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
					if guias("TipoConsultaID")&""="" or guias("TipoConsultaID")=0 then
							TipoConsultaID = ""
						else
							TipoConsultaID = TirarAcento(guias("TipoConsultaID")&"")
						end if
					'==============================================================================================================================================================================
					if guias("CodigoCNES")="" then CodigoCNES=TirarAcento(CNESContratado) else CodigoCNES=TirarAcento(guias("CodigoCNES")) end if
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
                            <%="<ans:" & tipoCodigoNaOperadoraContratadoSolicitante & ">" & ContratadoSolicitanteCodigoNaOperadora &"</ans:" & tipoCodigoNaOperadoraContratadoSolicitante &">"%>
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
                        <%if TipoConsultaID<>"" then%><ans:tipoConsulta><%= TipoConsultaID %></ans:tipoConsulta><%end if%>
                        <%if MotivoEncerramentoID<>"" then%><ans:motivoEncerramento><%= MotivoEncerramentoID %></ans:motivoEncerramento><% End If %>
                    </ans:dadosAtendimento>
                    <ans:procedimentosExecutados>
                    <%
                    sequencialItem = 1

					set procs = db.execute("select tps.*, proc.ProcedimentoSeriado from tissprocedimentossadt tps INNER JOIN procedimentos proc ON proc.id=tps.ProcedimentoID where tps.GuiaiD="&guias("id"))
					while not procs.eof
						ProcedimentoSeriado=procs("ProcedimentoSeriado")
						Data = mydatetiss(procs("Data"))
						Quantidade = TirarAcento(procs("Quantidade"))
						Fator = treatvaltiss(procs("Fator"))
						ValorUnitario = procs("ValorUnitario")
						ValorTotal = procs("ValorTotal")

						set SerieSQL = db.execute("SELECT "&mydatenull(procs("Data"))&" as Data")
                        if Quantidade&"" <> "" then
                            'response.write("("&Quantidade&")")
                            if ProcedimentoSeriado&"" = "S" and ccur(Quantidade)>0 then
                                sqlSerie = "SELECT DATE(DATA)DATA FROM ( "&_
                                             "SELECT IFNULL(DataSerie01, "&mydatenull(procs("Data"))&") Data FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie02 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie03 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie04 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie05 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie06 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie07 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie08 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie09 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             "UNION ALL  "&_
                                             "SELECT DataSerie10 FROM tissguiasadt WHERE id="&guias("id")&" "&_
                                             " "&_
                                             ")t "&_
                                             " "&_
                                             "WHERE DATA IS NOT null"
                                set SerieSQL = db.execute(sqlSerie)

                                Quantidade=1
                                ValorTotal=ValorUnitario
                            end if
                        end if

						ValorUnitario = treatvaltiss(ValorUnitario)
						ValorTotal = treatvaltiss(ValorTotal)

						while not SerieSQL.eof
						Data = mydatetiss(SerieSQL("Data"))

						HoraInicio = myTimeTISS(procs("HoraInicio"))
						HoraFim = myTimeTISS(procs("HoraFim"))
						TabelaID = TirarAcento(procs("TabelaID"))

						if TabelaID="99" OR TabelaID="0" then
							TabelaID="00"
						end if

						CodigoProcedimento = TirarAcento(procs("CodigoProcedimento"))
						Descricao = left(TirarAcento(procs("Descricao")),150)

						ViaID = TirarAcento(procs("ViaID"))&""
						TecnicaID = TirarAcento(procs("TecnicaID"))&""

						hash = hash & sequencialItem & Data&HoraInicio&HoraFim&TabelaID&CodigoProcedimento&Descricao&Quantidade&ViaID&TecnicaID&Fator&ValorUnitario&ValorTotal
						%>
                        <ans:procedimentoExecutado>
                            <ans:sequencialItem><%= sequencialItem %></ans:sequencialItem>
                            <%if Data<>"" then%><ans:dataExecucao><%= Data %></ans:dataExecucao><% End If %>
                            <%if HoraInicio<>"" then%><ans:horaInicial><%= HoraInicio %></ans:horaInicial><% End If %>
                            <%if HoraFim<>"" then%><ans:horaFinal><%= HoraFim %></ans:horaFinal><% End If %>
                            <ans:procedimento>
                                <ans:codigoTabela><%= TabelaID %></ans:codigoTabela>
                                <ans:codigoProcedimento><%= CodigoProcedimento %></ans:codigoProcedimento>
                                <ans:descricaoProcedimento><%= Descricao %></ans:descricaoProcedimento>
                            </ans:procedimento>
                            <ans:quantidadeExecutada><%= Quantidade %></ans:quantidadeExecutada>
														<%if ViaID<>"" then%>
                            <ans:viaAcesso><%= ViaID %></ans:viaAcesso>
														<%
														end if
														if TecnicaID<>"" then
														%>
                            <ans:tecnicaUtilizada><%= TecnicaID %></ans:tecnicaUtilizada>
														<%end if%>
                            <ans:reducaoAcrescimo><%= Fator %></ans:reducaoAcrescimo>
                            <ans:valorUnitario><%= ValorUnitario %></ans:valorUnitario>
                            <ans:valorTotal><%= ValorTotal %></ans:valorTotal>
                            <%
							set eq = db.execute("select e.*, p.NomeProfissional, grau.Codigo as GrauParticipacao, est.codigo as UF from tissprofissionaissadt as e left join profissionais as p on p.id=e.ProfissionalID left join estados as est on est.sigla like e.UFConselho left join cliniccentral.tissgrauparticipacao as grau on grau.id=e.GrauParticipacaoID where GuiaID="&guias("id"))
							while not eq.eof
								GrauParticipacao = TirarAcento(eq("GrauParticipacao")&"")
								if GrauParticipacao="" or isnull(GrauParticipacao) then GrauParticipacao="" end if
								CodigoNaOperadoraOuCPF = replace(replace(replace(replace(replace(TirarAcento(eq("CodigoNaOperadoraOuCPF")), ".", ""), "-", ""), ",", ""), "_", ""), " ", "")
								if CodigoNaOperadoraOuCPF="" then CodigoNaOperadoraOuCPF="-" end if


								if CalculaCPF(CodigoNaOperadoraOuCPF)=true then
									tipoContrato = "cpfContratado"
								'elseif CalculaCNPJ(CodigoNaOperadoraOuCPF)=true then
								'	tipoContrato = "cnpjContratado"
								else
									tipoContrato = "codigoPrestadorNaOperadora"
								end if



								NomeProfissional = TirarAcento(eq("NomeProfissional")&" ")
								set cons = db.execute("select * from conselhosprofissionais where id="&treatvalzero(eq("ConselhoID")))
								if cons.eof then 
                                    ConselhoProfissional = 6 
                                else 
                                    ConselhoProfissional=TirarAcento(cons("TISS")) 
                                end if
                                ConselhoProfissional = zeroEsq(ConselhoProfissional, 2)

								DocumentoConselho = TirarAcento(eq("DocumentoConselho"))
								UF = TirarAcento(eq("UF"))
								CodigoCBO = TirarAcento(eq("CodigoCBO"))
								hash = hash & GrauParticipacao&CodigoNaOperadoraOuCPF&NomeProfissional&ConselhoProfissional&DocumentoConselho&UF&CodigoCBO
							%>
                            <ans:equipeSadt>
                                <%if GrauParticipacao<>"" then %>
                                    <ans:grauPart><%= GrauParticipacao %></ans:grauPart>
                                <%end if %>
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
                        sequencialItem=sequencialItem+1
							%>
                        </ans:procedimentoExecutado>
                        <%
						SerieSQL.movenext
						wend
						set SerieSQL=nothing
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
							TabelaProdutoID = zeroEsq(TirarAcento(desp("TabelaProdutoID")), 2)
							CodigoProduto = TirarAcento(desp("CodigoProduto"))
							Quantidade = treatvaltiss(desp("Quantidade"))
							UnidadeMedidaID = zEsq(desp("UnidadeMedidaID"), 3)
							Fator = treatvaltiss(desp("Fator"))
							ValorUnitario = treatvaltiss(desp("ValorUnitario"))
							ValorTotal = treatvaltiss(desp("ValorTotal"))
							Descricao = TirarAcento(desp("Descricao"))
							RegistroANVISA = TirarAcento(desp("RegistroANVISA"))
							CodigoNoFabricante = TirarAcento(desp("CodigoNoFabricante"))
							AutorizacaoEmpresa = TirarAcento(desp("AutorizacaoEmpresa"))
							
							hash = hash & sequencialItem&CD&Data&HoraInicio&HoraFim&TabelaProdutoID&CodigoProduto&Quantidade&UnidadeMedidaID&Fator&ValorUnitario&ValorTotal&Descricao&RegistroANVISA&CodigoNoFabricante&AutorizacaoEmpresa
						%>
                        <ans:despesa>
                            <ans:sequencialItem><%= sequencialItem %></ans:sequencialItem>
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
                        sequencialItem=sequencialItem+1
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
Response.AddHeader "Content-Disposition", "attachment; filename=" & prefixo & "_" & md5(hash)&".xml"
%>