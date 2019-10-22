<!--#include file="connect.asp"--><!--#include file="validar.asp"--><!--#include file="md5.asp"--><%
response.ContentType="text/XML"

'response.Write(request.QueryString("I"))
RLoteID = replace(request.QueryString("I"),".xml", "")
set lote = db.execute("select * from tisslotes where id="&RLoteID)
set guias = db.execute("select g.*, p.NomePaciente, c.TISS as ConselhoProfissional, e.codigo as CodigoUFConselho, pro.NomeProfissional from tissguiaconsulta as g left join pacientes as p on p.id=g.PacienteID left join conselhosprofissionais as c on c.id=g.Conselho left join estados as e on e.sigla like g.UFConselho left join profissionais as pro on pro.id=g.ProfissionalID where g.LoteID="&lote("id"))
if not guias.eof then
	RegistroANS = trim(guias("RegistroANS"))
	CodigoNaOperadora = trim(guias("CodigoNaOperadora"))
end if
NLote = lote("Lote")
Data = mydatetiss(lote("sysDate"))
Hora = formatdatetime( lote("sysDate") ,3)
%><?xml version="1.0" encoding="ISO-8859-1"?>
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
				<ans:codigoPrestadorNaOperadora><%=CodigoNaOperadora%></ans:codigoPrestadorNaOperadora>
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
					Contratado = guias("Contratado")
					if Contratado=0 then
						set emp = db.execute("select NomeEmpresa, CNES from empresa where NomeEmpresa<>''")
						if not emp.eof then
							NomeContratado = emp("NomeEmpresa")
							CNESContratado = emp("CNES")
						end if
					elseif Contratado<0 then
						set fil = db.execute("select UnitName, CNES from sys_financialcompanyunits where id="&Contratado*(-1))
						if not fil.eof then
							NomeContratado = fil("UnitName")
							CNESContratado = fil("CNES")
						end if
					else
						set prof = db.execute("select NomeProfissional from profissionais where id="&Contratado)
						if not prof.eof then
							NomeContratado = prof("NomeProfissional")
							CNESContratado = "9999999"
						end if
					end if
				
					RegistroANS = trim(guias("RegistroANS"))
					NGuiaPrestador = trim(guias("NGuiaPrestador"))
					NGuiaOperadora = trim(guias("NGuiaOperadora"))
					NumeroCarteira = trim(guias("NumeroCarteira"))
					AtendimentoRN = guias("AtendimentoRN")
					NomePaciente = trim(guias("NomePaciente"))
					CodigoNaOperadora = trim(guias("CodigoNaOperadora"))
					CodigoNaOperadora = replace(replace(replace(replace(replace(CodigoNaOperadora, ".", ""), "-", ""), ",", ""), "_", ""), " ", "")
					if CalculaCPF(CodigoNaOperadora)=true then
						tipoContrato = "cpfContratado"
					elseif CalculaCNPJ(CodigoNaOperadora)=true then
						tipoContrato = "cnpjContratado"
					else
						tipoContrato = "codigoPrestadorNaOperadora"
					end if
					if guias("CodigoCNES")="" then CodigoCNES=CNESContratado else CodigoCNES=trim(guias("CodigoCNES")) end if
					ConselhoProfissional = guias("ConselhoProfissional")
					DocumentoConselho = trim(guias("DocumentoConselho"))
					CodigoUFConselho = guias("CodigoUFConselho")
					CodigoCBO = trim(guias("CodigoCBO"))
					IndicacaoAcidente = guias("IndicacaoAcidenteID")
					DataAtendimento = mydatetiss(guias("DataAtendimento"))
					TipoConsulta = guias("TipoConsultaID")
					CodigoTabela = guias("TabelaID")
					CodigoProcedimento = trim(guias("CodigoProcedimento"))
					ValorProcedimento = treatvaltiss(guias("ValorProcedimento"))
					NomeProfissional = guias("NomeProfissional")
					if not isnull(NomeProfissional) then NomeProfissional=trim(NomeProfissional) end if
					
					hash = hash&RegistroANS&NGuiaPrestador&NGuiaOperadora&NumeroCarteira&AtendimentoRN&NomePaciente&CodigoNaOperadora&NomeContratado&CodigoCNES&NomeProfissional&ConselhoProfissional&DocumentoConselho&CodigoUFConselho&CodigoCBO&IndicacaoAcidente&DataAtendimento&TipoConsulta&CodigoTabela&CodigoProcedimento&ValorProcedimento
					%>
                <ans:guiaConsulta>
					<ans:cabecalhoConsulta>
						<ans:registroANS><%=RegistroANS%></ans:registroANS>
						<ans:numeroGuiaPrestador><%=NGuiaPrestador%></ans:numeroGuiaPrestador>
					</ans:cabecalhoConsulta><%
					if NGuiaOperadora<>"" then%>
					<ans:numeroGuiaOperadora><%=NGuiaOperadora%></ans:numeroGuiaOperadora><%
					end if%>
					<ans:dadosBeneficiario>
						<ans:numeroCarteira><%=NumeroCarteira%></ans:numeroCarteira>
						<ans:atendimentoRN><%=AtendimentoRN%></ans:atendimentoRN>
						<ans:nomeBeneficiario><%=NomePaciente%></ans:nomeBeneficiario>
					</ans:dadosBeneficiario>
					<ans:contratadoExecutante>
						<ans:<%=tipoContrato%>><%=CodigoNaOperadora%></ans:><%=tipoContrato%>>
						<ans:nomeContratado><%=NomeContratado%></ans:nomeContratado>
						<ans:CNES><%=CodigoCNES%></ans:CNES>
					</ans:contratadoExecutante>
					<ans:profissionalExecutante><%
						if NomeProfissional<>"" and not isnull(NomeProfissional) then
						%>
	                    <ans:nomeProfissional><%=NomeProfissional%></ans:nomeProfissional><%
						end if%>
						<ans:conselhoProfissional><%=ConselhoProfissional%></ans:conselhoProfissional>
						<ans:numeroConselhoProfissional><%=DocumentoConselho%></ans:numeroConselhoProfissional>
						<ans:UF><%=CodigoUFConselho%></ans:UF>
						<ans:CBOS><%=CodigoCBO%></ans:CBOS>
					</ans:profissionalExecutante>
					<ans:indicacaoAcidente><%=IndicacaoAcidente%></ans:indicacaoAcidente>
					<ans:dadosAtendimento>
						<ans:dataAtendimento><%=DataAtendimento%></ans:dataAtendimento>
						<ans:tipoConsulta><%=TipoConsulta%></ans:tipoConsulta>
						<ans:procedimento>
							<ans:codigoTabela><%=CodigoTabela%></ans:codigoTabela>
							<ans:codigoProcedimento><%=CodigoProcedimento%></ans:codigoProcedimento>
							<ans:valorProcedimento><%=ValorProcedimento%></ans:valorProcedimento>
						</ans:procedimento>
					</ans:dadosAtendimento>
				</ans:guiaConsulta>
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
		<ans:hash><%=md5(hash)%></ans:hash>
	</ans:epilogo>
</ans:mensagemTISS>
<!--#include file="disconnect.asp"-->