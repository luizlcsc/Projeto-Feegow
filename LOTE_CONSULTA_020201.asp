<!--#include file="connect.asp"--><!--#include file="validar.asp"--><!--#include file="md5.asp"--><%

response.ContentType="text/XML"

RLoteID = replace(request.QueryString("I"),".xml", "")
set lote = db.execute("select * from tisslotes where id="&RLoteID)
set guias = db.execute("select g.*, p.NomePaciente, c.codigo as ConselhoProfissionalSigla, pla.NomePlano, g.UFConselho as CodigoUFConselho, pro.NomeProfissional from tissguiaconsulta as g left join conveniosplanos pla on pla.id=g.PlanoID left join pacientes as p on p.id=g.PacienteID left join conselhosprofissionais as c on c.id=g.Conselho left join estados as e on e.sigla like g.UFConselho left join profissionais as pro on pro.id=g.ProfissionalID where g.LoteID="&lote("id")&" order by NGuiaPrestador")
if not guias.eof then
	RegistroANS = trim(guias("RegistroANS"))
	CodigoNaOperadora = trim(guias("CodigoNaOperadora"))
end if
NLote = lote("Lote")
Data = mydatetiss(lote("sysDate"))
Hora = formatdatetime( lote("sysDate") ,3)

    padraoTISS = "2.02.01"

    prefixo = "00000000000000000000"&NLote
    prefixo = right(prefixo, 20)
%><?xml version="1.0" encoding="ISO-8859-1"?>
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
			</ans:codigoPrestadorNaOperadora>
		</ans:origem>
		<ans:destino>
			<ans:registroANS><%=RegistroANS%></ans:registroANS>
		</ans:destino>
		<ans:versaoPadrao><%=padraoTISS %></ans:versaoPadrao>
	</ans:cabecalho>
	<ans:prestadorParaOperadora>
		<ans:loteGuias>
			<ans:numeroLote><%=NLote%></ans:numeroLote>
            <ans:guias>
			<ans:guiaFaturamento>
				<%'inicia as guias
				hash = "ENVIO_LOTE_GUIAS"&NLote&Data&Hora&CodigoNaOperadora&RegistroANS&padraoTISS&NLote
				while not guias.eof
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
					NGuiaOperadora = trim(guias("NGuiaOperadora"))
					NumeroCarteira = trim(guias("NumeroCarteira"))
					AtendimentoRN = guias("AtendimentoRN")
					NomePaciente = TirarAcento(guias("NomePaciente"))
					CodigoNaOperadora = trim(guias("CodigoNaOperadora"))
					CodigoNaOperadora = replace(replace(replace(replace(replace(CodigoNaOperadora, ".", ""), "-", ""), ",", ""), "_", ""), " ", "")
					if CalculaCPF(CodigoNaOperadora)=true then
						tipoContrato = "CPF"
					elseif CalculaCNPJ(CodigoNaOperadora)=true then
						tipoContrato = "CNPJ"
					else
						tipoContrato = "codigoPrestadorNaOperadora"
					end if
					if guias("CodigoCNES")="" then CodigoCNES=CNESContratado else CodigoCNES=trim(guias("CodigoCNES")) end if
					ConselhoProfissional = guias("ConselhoProfissionalSigla")
					DocumentoConselho = trim(guias("DocumentoConselho"))
					CodigoUFConselho = guias("CodigoUFConselho")
					CodigoCBO = trim("2231.05")
					IndicacaoAcidente = guias("IndicacaoAcidenteID")
					DataAtendimento = mydatetiss(guias("DataAtendimento"))
					TipoConsulta = guias("TipoConsultaID")
					CodigoTabela = guias("TabelaID")
					if CodigoTabela="99" then
						CodigoTabela="00"
					end if
                    NomePlano = guias("NomePlano")
                    ValidadeCarteira = mydatetiss(guias("ValidadeCarteira"))
					CodigoProcedimento = trim(guias("CodigoProcedimento"))
					ValorProcedimento = ""
					NomeProfissional = TirarAcento(guias("NomeProfissional"))
					if not isnull(NomeProfissional) then NomeProfissional=trim(NomeProfissional) end if


                    CIDNomeTabela="CID-10"
                    codigoDiagnostico="I10"
                    descricaoDiagnostico=" "
                    tipoDoenca="C"
                    tempoReferidoValor="30"
                    unidadeTempo="D"

                    hashCid = CIDNomeTabela&codigoDiagnostico&descricaoDiagnostico&tipoDoenca&tempoReferidoValor&unidadeTempo
                    IndicacaoAcidente=""
                    TipoSaida="5"

					hash = hash&RegistroANS&DataAtendimento&NGuiaOperadora&NGuiaPrestador&NumeroCarteira&NomePaciente &NomePlano&ValidadeCarteira&CodigoNaOperadora&NomeContratado& CodigoCNES&NomeProfissional&ConselhoProfissional&DocumentoConselho& CodigoUFConselho&CodigoCBO& hashCid &   DataAtendimento&CodigoTabela&CodigoProcedimento&TipoConsulta&TipoSaida
					%>
                <ans:guiaConsulta>
					<ans:identificacaoGuia>
                        <ans:identificacaoFontePagadora>
                            <ans:registroANS><%=RegistroANS%></ans:registroANS>
                        </ans:identificacaoFontePagadora>
                        <ans:dataEmissaoGuia><%= DataAtendimento %></ans:dataEmissaoGuia><%
                        if NGuiaOperadora<>"" then%>
                        <ans:numeroGuiaOperadora><%=NGuiaOperadora%></ans:numeroGuiaOperadora><%
                        end if%>
                        <ans:numeroGuiaPrestador><%=NGuiaPrestador%></ans:numeroGuiaPrestador>
                    </ans:identificacaoGuia>
					<ans:beneficiario>
						<ans:numeroCarteira><%=NumeroCarteira%></ans:numeroCarteira>
						<ans:nomeBeneficiario><%=NomePaciente%></ans:nomeBeneficiario>
						<ans:nomePlano><%=NomePlano%></ans:nomePlano>
						<ans:validadeCarteira><%=ValidadeCarteira%></ans:validadeCarteira>
					</ans:beneficiario>
					<ans:dadosContratado>
					    <ans:identificacao>
                            <%="<ans:"&tipoContrato&">"&CodigoNaOperadora&"</ans:"&tipoContrato&">"%>
					    </ans:identificacao>
                        <ans:nomeContratado><%=NomeContratado%></ans:nomeContratado>
						<ans:numeroCNES><%=CodigoCNES%></ans:numeroCNES>
					</ans:dadosContratado>
					<ans:profissionalExecutante><%
						if NomeProfissional<>"" and not isnull(NomeProfissional) then
						%>
	                    <ans:nomeProfissional><%=NomeProfissional%></ans:nomeProfissional><%
						end if%>
						<ans:conselhoProfissional>
						    <ans:siglaConselho><%=ConselhoProfissional%></ans:siglaConselho>
                            <ans:numeroConselho><%=DocumentoConselho%></ans:numeroConselho>
                            <ans:ufConselho><%=CodigoUFConselho%></ans:ufConselho>
						</ans:conselhoProfissional>

						<ans:cbos><%=CodigoCBO%></ans:cbos>
					</ans:profissionalExecutante>

                    <ans:hipoteseDiagnostica>
                        <ans:CID>
                            <ans:nomeTabela><%=CIDNomeTabela%></ans:nomeTabela>
                            <ans:codigoDiagnostico><%=codigoDiagnostico%></ans:codigoDiagnostico>
                            <ans:descricaoDiagnostico><%=descricaoDiagnostico%></ans:descricaoDiagnostico>
                        </ans:CID>
                        <ans:tipoDoenca><%=tipoDoenca%></ans:tipoDoenca>
                        <ans:tempoReferidoEvolucaoDoenca>
                            <ans:valor><%=tempoReferidoValor%></ans:valor>
                            <ans:unidadeTempo><%=unidadeTempo%></ans:unidadeTempo>
                        </ans:tempoReferidoEvolucaoDoenca>
                    </ans:hipoteseDiagnostica>
					<ans:dadosAtendimento>
						<ans:dataAtendimento><%=DataAtendimento%></ans:dataAtendimento>
						<ans:procedimento>
							<ans:codigoTabela><%=CodigoTabela%></ans:codigoTabela>
							<ans:codigoProcedimento><%=CodigoProcedimento%></ans:codigoProcedimento>
						</ans:procedimento>
                        <ans:tipoConsulta><%=TipoConsulta%></ans:tipoConsulta>
                        <ans:tipoSaida><%=TipoSaida%></ans:tipoSaida>
					</ans:dadosAtendimento>
				</ans:guiaConsulta>
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
		<ans:hash><%=md5(hash)%></ans:hash>
	</ans:epilogo>
</ans:mensagemTISS>
<%
Response.AddHeader "Content-Disposition", "attachment; filename=" & prefixo & "_" & md5(hash)&".xml"
%>
<!--#include file="disconnect.asp"-->