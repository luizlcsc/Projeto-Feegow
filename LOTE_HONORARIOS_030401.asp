<!--#include file="connect.asp"--><!--#include file="validar.asp"--><!--#include file="md5.asp"--><%

response.ContentType="text/XML"


RLoteID = replace(req("I"),".xml", "")
set lote = db.execute("select * from tisslotes where id="&RLoteID)
set guias = db.execute("select g.*, p.NomePaciente, COALESCE(l.nomelocal, g.ContratadoLocalNome) ContratadoLocalNome from tissguiahonorarios as g "&_
"left join locaisexternos as l on l.id=g.LocalExternoID "&_
"left join pacientes as p on p.id=g.PacienteID "&_
"where g.LoteID="&lote("id")&" order by g.NGuiaPrestador")

if not guias.eof then
	RegistroANS = TirarAcento(guias("RegistroANS"))
	CodigoNaOperadora = TirarAcento(guias("CodigoNaOperadora"))
end if
NLote = TirarAcento(lote("Lote"))
Data = mydatetiss(lote("sysDate"))
Hora = myTimeTISS( lote("sysDate") )

    response.write("<?xml version=""1.0"" encoding=""ISO-8859-1""?>")

response.Charset="utf-8"

versaoTISS = "3.04.01"


prefixo = "00000000000000000000"&NLote
prefixo = right(prefixo, 20)

%>
<ans:mensagemTISS xsi:schemaLocation="http://www.ans.gov.br/padroes/tiss/schemas tissV3_04_01.xsd" xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
                CodigoNaOperadora = TirarAcento(replace(replace(replace(replace(replace(CodigoNaOperadora, ".", ""), "-", ""), ",", ""), "_", ""), " ", ""))
                if CalculaCPF(CodigoNaOperadora)=true then
                    tipoCodigoNaOperadora = "CPF"
                elseif CalculaCNPJ(CodigoNaOperadora)=true then
                    tipoCodigoNaOperadora = "CNPJ"
                else
                    tipoCodigoNaOperadora = "codigoPrestadorNaOperadora"
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
				hash = "ENVIO_LOTE_GUIAS" & NLote & Data & Hora & CodigoNaOperadora & RegistroANS & versaoTISS & NLote
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
					NGuiaSolicitacaoInternacao = TirarAcento(guias("NGuiaSolicitacaoInternacao"))
					NGuiaOperadora = TirarAcento(guias("NGuiaOperadora"))
					Senha = TirarAcento(guias("Senha"))
					NumeroCarteira = TirarAcento(guias("NumeroCarteira"))
					AtendimentoRN = TirarAcento(guias("AtendimentoRN"))
					NomePaciente = TirarAcento(guias("NomePaciente"))
					ContExecCodigoNaOperadora = TirarAcento(guias("CodigoNaOperadora"))
                    ContratadoLocalCodigoNaOperadora = TirarAcento(guias("ContratadoLocalCodigoNaOperadora"))
                    ContratadoLocalNome = TirarAcento(guias("ContratadoLocalNome"))
                    ContratadoLocalCNES = TirarAcento(guias("ContratadoLocalCNES"))
                    DataInicioFaturamento = mydatetiss(guias("DataInicioFaturamento"))
                    DataFimFaturamento = mydatetiss(guias("DataFimFaturamento"))
					ContExecCodigoNaOperadora = TirarAcento(replace(replace(replace(replace(replace(ContExecCodigoNaOperadora, ".", ""), "-", ""), ",", ""), "_", ""), " ", ""))
					if CalculaCPF(CodigoNaOperadora)=true then
						tipoContrato = "cpfContratado"
					elseif CalculaCNPJ(CodigoNaOperadora)=true then
						tipoContrato = "codigonaOperadora"
					else
						tipoContrato = "codigonaOperadora"
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

                    tipoCodigoNaOperadoraContratadoSolicitante = "codigoPrestadorNaOperadora"
                    
					if guias("CodigoCNES")="" then CodigoCNES=TirarAcento(CNESContratado) else CodigoCNES=TirarAcento(guias("CodigoCNES")) end if
					NomeProfissional=TirarAcento(NomeProfissional)

                    if CalculaCNPJ(ContratadoLocalCodigoNaOperadora)=true then
                        rotuloLocal = "cnpjLocalExecutante"
                    else
                        rotuloLocal = "codigoNaOperadora"
                    end if

					hash = hash & RegistroANS & NGuiaPrestador & NGuiaSolicitacaoInternacao & Senha & NGuiaOperadora & NumeroCarteira & NomePaciente & AtendimentoRN & ContratadoLocalCodigoNaOperadora & ContratadoLocalNome & ContratadoLocalCNES & ContExecCodigoNaOperadora & NomeContratado & CodigoCNES & DataInicioFaturamento & DataFimFaturamento
					%>
                <ans:guiaHonorarios>
                    <ans:cabecalhoGuia>
                        <ans:registroANS><%=RegistroANS%></ans:registroANS>
                        <ans:numeroGuiaPrestador><%= NGuiaPrestador %></ans:numeroGuiaPrestador>
                    </ans:cabecalhoGuia>
                    <% if NGuiaSolicitacaoInternacao<>"" then %><ans:guiaSolicInternacao><%=NGuiaSolicitacaoInternacao %></ans:guiaSolicInternacao><%end if %>
                    <% if Senha<>"" then%><ans:senha><%= Senha %></ans:senha><% End If %>
                    <%if NGuiaOperadora<>"" then%><ans:numeroGuiaOperadora><%= NGuiaOperadora %></ans:numeroGuiaOperadora><%end if%>
                    <ans:beneficiario>
                        <ans:numeroCarteira><%= NumeroCarteira %></ans:numeroCarteira>
                        <ans:nomeBeneficiario><%= NomePaciente %></ans:nomeBeneficiario>
                        <ans:atendimentoRN><%= AtendimentoRN %></ans:atendimentoRN>
                    </ans:beneficiario>

                    <ans:localContratado>
                        <ans:codigoContratado>
                            <ans:<%= rotuloLocal %>><%=ContratadoLocalCodigoNaOperadora %></ans:<%= rotuloLocal %>>
                        </ans:codigoContratado>
                        <ans:nomeContratado><%=ContratadoLocalNome %></ans:nomeContratado>
                        <ans:cnes><%=ContratadoLocalCNES%></ans:cnes>
                    </ans:localContratado>
                    <ans:dadosContratadoExecutante>
                            <%="<ans:codigonaOperadora>"&ContExecCodigoNaOperadora &"</ans:codigonaOperadora>"%>
                            <ans:nomeContratadoExecutante><%= NomeContratado %></ans:nomeContratadoExecutante>
                             <ans:cnesContratadoExecutante><%= CodigoCNES %></ans:cnesContratadoExecutante>
                    </ans:dadosContratadoExecutante>
                    <%'if DataInicioFaturamento<>"" and DataFimFaturamento<>"" then %>
                    <ans:dadosInternacao>
                        <%if DataInicioFaturamento<>"" then %><ans:dataInicioFaturamento><%=DataInicioFaturamento %></ans:dataInicioFaturamento><%end if %>
                        <%if DataFimFaturamento<>"" then %><ans:dataFimFaturamento><%=DataFimFaturamento %></ans:dataFimFaturamento><%end if %>
                    </ans:dadosInternacao>
                    <%'end if %>
                    <ans:procedimentosRealizados>
                    <%
                    sequencialItem = 1

					set procs = db.execute("select * from tissprocedimentoshonorarios where GuiaiD="&guias("id"))
					while not procs.eof
						Data = mydatetiss(procs("Data"))
						HoraInicio = myTimeTISS(procs("HoraInicio"))
						HoraFim = myTimeTISS(procs("HoraFim"))
						TabelaID = TirarAcento(procs("TabelaID"))
						if TabelaID="99" or TabelaID="101" or TabelaID="0" then
							TabelaID="00"
						end if
						CodigoProcedimento = TirarAcento(procs("CodigoProcedimento"))
						Descricao = TirarAcento(procs("Descricao"))
						Quantidade = TirarAcento(procs("Quantidade"))
						ViaID = TirarAcento(procs("ViaID"))
						TecnicaID = TirarAcento(procs("TecnicaID"))
						Fator = treatvaltiss(procs("Fator"))
						ValorUnitario = treatvaltiss( procs("ValorUnitario") )
						ValorTotal = treatvaltiss(procs("ValorTotal"))

						hash = hash & sequencialItem &  Data & HoraInicio & HoraFim & TabelaID & CodigoProcedimento & Descricao & Quantidade & ViaID & TecnicaID & Fator & ValorUnitario & ValorTotal
						%>
                        <ans:procedimentoRealizado>
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
                            <ans:viaAcesso><%= ViaID %></ans:viaAcesso>
                            <ans:tecnicaUtilizada><%= TecnicaID %></ans:tecnicaUtilizada>
                            <ans:reducaoAcrescimo><%= Fator %></ans:reducaoAcrescimo>
                            <ans:valorUnitario><%= ValorUnitario %></ans:valorUnitario>
                            <ans:valorTotal><%= ValorTotal %></ans:valorTotal>
                            <%
							
                            ProfissionalExecutante = procs("ProfissionalID")
                            AssociacaoProfissionalExecutante = procs("Associacao")

                            'obtém o profissional de repasse, caso não encontre, listará todos
                            set eq = db.execute("select e.*, p.NomeProfissional, grau.Codigo as GrauParticipacao, est.codigo as UF from tissprofissionaishonorarios as e left join profissionais as p on p.id=e.ProfissionalID left join estados as est on est.sigla = e.UFConselho left join cliniccentral.tissgrauparticipacao as grau on grau.id=e.GrauParticipacaoID where ProfissionalID="&treatvalzero(ProfissionalExecutante)&" AND Associacao="&treatvalzero(AssociacaoProfissionalExecutante)&" AND GuiaID="&guias("id"))
                            if eq.eof then
							    set eq = db.execute("select e.*, p.NomeProfissional, grau.Codigo as GrauParticipacao, est.codigo as UF from tissprofissionaishonorarios as e left join profissionais as p on p.id=e.ProfissionalID left join estados as est on est.sigla = e.UFConselho left join cliniccentral.tissgrauparticipacao as grau on grau.id=e.GrauParticipacaoID where GuiaID="&guias("id"))
                            end if

							while not eq.eof
								GrauParticipacao = TirarAcento(eq("GrauParticipacao"))
								if GrauParticipacao="" or isnull(GrauParticipacao) then GrauParticipacao="00" end if
								CodigoNaOperadoraOuCPF = TirarAcento(eq("CodigoNaOperadoraOuCPF"))
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
								if cons.eof then
                                    ConselhoProfissional = 6
                                else
                                    ConselhoProfissional=TirarAcento(cons("TISS"))
                                end if
                                ConselhoProfissional = zeroEsq(ConselhoProfissional, 2)

								DocumentoConselho = TirarAcento(eq("DocumentoConselho"))
								UF = TirarAcento(eq("UF"))
								CodigoCBO = TirarAcento(eq("CodigoCBO"))
								hash = hash & GrauParticipacao & CodigoNaOperadoraOuCPF & NomeProfissional & ConselhoProfissional & DocumentoConselho & UF & CodigoCBO
							%>
                            <ans:profissionais>
                                <ans:grauParticipacao><%= GrauParticipacao %></ans:grauParticipacao>
                                <ans:codProfissional>
                                    <%="<ans:"&tipoContrato&">"& CodigoNaOperadoraOuCPF &"</ans:"&tipoContrato&">"%>
                                </ans:codProfissional>
                                <ans:nomeProfissional><%= NomeProfissional %></ans:nomeProfissional>
                                <ans:conselhoProfissional><%= ConselhoProfissional %></ans:conselhoProfissional>
                                <ans:numeroConselhoProfissional><%= DocumentoConselho %></ans:numeroConselhoProfissional>
                                <ans:UF><%= UF %></ans:UF>
                                <ans:CBO><%= CodigoCBO %></ans:CBO>
                            </ans:profissionais>
                            <%
							eq.movenext
							wend
							eq.close
							set eq = nothing
							%>
                        </ans:procedimentoRealizado>
                        <%
                        sequencialItem=sequencialItem+1
					procs.movenext
					wend
					procs.close
					set procs=nothing

					Observacoes = guias("Observacoes")
					Observacoes = TirarAcento(Observacoes)
					valorTotalHonorarios = treatvaltiss(guias("Procedimentos"))
					dataEmissaoGuia = mydatetiss(guias("DataEmissao"))

					hash = hash & Observacoes & valorTotalHonorarios & dataEmissaoGuia
					%>
                    </ans:procedimentosRealizados>
                    <%if Observacoes<>"" then%><ans:observacao><%= Observacoes %></ans:observacao><% End If %>
                    <ans:valorTotalHonorarios><%=valorTotalHonorarios %></ans:valorTotalHonorarios>
                    <ans:dataEmissaoGuia><%=dataEmissaoGuia %></ans:dataEmissaoGuia>
                </ans:guiaHonorarios>
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
'if request.ServerVariables("REMOTE_ADDR")<>"::1" then
    Response.AddHeader "Content-Disposition", "attachment; filename=" & prefixo & "_" & md5(hash)&".xml"
'end if
%>