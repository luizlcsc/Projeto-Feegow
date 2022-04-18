<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Expires" content="-1">
	<title>Anexo de Outras Despesas</title>
<style>
#logo {
	max-width:140px;
	max-height:40px;
}
.linha {
	height:12px;
}
.guia-anexa-content{
    page-break-after: always;
}
</style>
<link rel="stylesheet" type="text/css" media="all" href="assets/css/tiss.css" />
</head>
<%
set guia = db.execute("select g.*, cons.TISS as ConselhoProfissionalSolicitanteTISS from tissguiasadt as g left join conselhosprofissionais as cons on cons.id=g.ConselhoProfissionalSolicitanteID where g.id="&GuiaID)
if not guia.eof then
	set conv = db.execute("select * from convenios where id="&guia("ConvenioID"))
	if not conv.EOF then
		Foto=conv("Foto")
		NomeConvenio = ucase(conv("NomeConvenio"))
	end if
	set pac = db.execute("select NomePaciente from pacientes where id="&guia("PacienteID"))
	if not pac.eof then
		NomePaciente = ucase(pac("NomePaciente"))
	end if
	if guia("Contratado")=0 then
		set pcont = db.execute("select * from empresa")
		if not pcont.eof then
			NomeContratado = ucase(pcont("NomeEmpresa"))
		end if
	elseif guia("Contratado")<0 then
		set pcont = db.execute("select * from sys_financialcompanyunits where id="&(guia("Contratado")*(-1)))
		if not pcont.eof then
			NomeContratado = ucase(pcont("UnitName"))
		end if
	else
		set pcont = db.execute("select NomeProfissional from profissionais where id="&guia("Contratado"))
		if not pcont.eof then
			NomeContratado = ucase(pcont("NomeProfissional"))
		end if
	end if
'	set prof = db.execute("select * from profissionais where id="&guia("ProfissionalID"))
'	if not prof.eof then
'		NomeProfissional = ucase(prof("NomeProfissional"))
'	end if
'	NomeConvenio=guia("NomeConvenio")

	ContratadoSolicitanteID=guia("ContratadoSolicitanteID")
	if ContratadoSolicitanteID=0 then
		set pContratadoSolicitanteID = db.execute("select * from empresa")
		NomeContratadoSolicitante = pContratadoSolicitanteID("NomeEmpresa")
	elseif ContratadoSolicitanteID<0 then
		set pContratadoSolicitanteID = db.execute("select * from sys_financialcompanyunits where id="&(ContratadoSolicitanteID*(-1)))
		if not pContratadoSolicitanteID.eof then
			NomeContratadoSolicitante = pContratadoSolicitanteID("UnitName")
		end if
	else
		set pContratadoSolicitanteID = db.execute("select * from profissionais where id="&ContratadoSolicitanteID)
		if not pContratadoSolicitanteID.eof then
			NomeContratadoSolicitante = pContratadoSolicitanteID("NomeProfissional")
		end if
	end if

	ProfissionalSolicitanteID=guia("ProfissionalSolicitanteID")
	set ProfissionalSolicitante = db.execute("select * from profissionais where id="&ProfissionalSolicitanteID)
	if not ProfissionalSolicitante.eof then
		NomeProfissionalSolicitante = ProfissionalSolicitante("NomeProfissional")
	end if

	NGuiaPrestador=guia("NGuiaPrestador")
	RegistroANS=guia("RegistroANS")
	NGuiaPrincipal=guia("NGuiaPrincipal")
	DataAutorizacao=guia("DataAutorizacao")
	Senha=guia("Senha")
	DataValidadeSenha=guia("DataValidadeSenha")
	NGuiaOperadora=guia("NGuiaOperadora")
	NumeroCarteira=guia("NumeroCarteira")
	ValidadeCarteira=guia("ValidadeCarteira")
'	NomePaciente=guia("NomePaciente")
	CNS=guia("CNS")
	AtendimentoRN=guia("AtendimentoRN")
	ContratadoSolicitanteCodigoNaOperadora=guia("ContratadoSolicitanteCodigoNaOperadora")
	ConselhoProfissionalSolicitanteTISS=guia("ConselhoProfissionalSolicitanteTISS")
	NumeroNoConselhoSolicitante=guia("NumeroNoConselhoSolicitante")
	UFConselhoSolicitante=guia("UFConselhoSolicitante")
	CodigoCBOSolicitante=guia("CodigoCBOSolicitante")
	CaraterAtendimentoID=guia("CaraterAtendimentoID")
	DataSolicitacao=guia("DataSolicitacao")
	IndicacaoClinica=guia("IndicacaoClinica")
	CodigoNaOperadora=guia("CodigoNaOperadora")
	Contratado=guia("Contratado")
	if Contratado=0 then
		set pContratado = db.execute("select * from empresa")
		NomeContratadoExecutante = pContratado("NomeEmpresa")
	elseif Contratado<0 then
		set pContratado = db.execute("select * from sys_financialcompanyunits where id="&(Contratado*(-1)))
		if not pContratado.eof then
			NomeContratadoExecutante = pContratado("UnitName")
		end if
	else
		set pContratado = db.execute("select * from profissionais where id="&Contratado)
		if not pContratado.eof then
			NomeContratadoExecutante = pContratado("NomeProfissional")
		end if
	end if
	CodigoCNESExecutante=guia("CodigoCNES")
	TipoAtendimentoID=guia("TipoAtendimentoID")
	IndicacaoAcidenteID=guia("IndicacaoAcidenteID")
	TipoConsultaID=guia("TipoConsultaID")
	MotivoEncerramentoID=guia("MotivoEncerramentoID")
	Observacoes=guia("Observacoes")
	Procedimentos=guia("Procedimentos")
	TaxasEAlugueis=guia("TaxasEAlugueis")
	Materiais=guia("Materiais")
	OPME=guia("OPME")
	Medicamentos=guia("Medicamentos")
	GasesMedicinais=guia("GasesMedicinais")
	TotalGeral=guia("TotalGeral")

	set vcaAnexa = db.execute("select * from tissguiaanexa where GuiaID="&guia("id"))
	if not vcaAnexa.EOF then
		%>
		<script>
		window.parent.anexa();
		</script>
		<%
	end if
end if
%>
<body>
	<div class="guia-anexa-content">
	<table cellpading="0" class="campo" bgcolor="white" cellspacing="0" width="100%">
        <tr>
            <td>
                <table height="80" width="100%">
		  			<tr>
						<td width="1%" align="center" data-teste="<%= Foto %> <%= len(Foto) %>" style="font-size:18px; font-weight:bold"><% if len(Foto)>2 then %><img src="<%=arqEx(Foto, "Perfil")%>" id="logo" /><%else%><%= NomeConvenio %><%end if%></td>
						<td style="font-size:18px; font-weight:bold" align="center">ANEXO DE OUTRAS DESPESAS<br /><span style="font-size:13px">(para Guia de SP/SADT e Resumo de Interna&ccedil;&atilde;o)</span>
                        </td>
                    </tr>
                </table>
			</td>
        </tr>
        <tr>
        	<td>
            	<table width="50%">
	                <tr>
    	                <td class="campo" width="7%"><label>1 - Registro ANS</label><%=RegistroANS%></td>
        	            <td class="campo" width="28%"><label>2 – N&uacute;mero da Guia Referenciada</label><%=NGuiaPrestador%></td>
            	    </tr>
                </table>
            </td>
        </tr>
        <tr>
        	<td>
            	<table width="100%">
					<tr><td class="thead campo">Dados do Contratado Executante</td></tr>
                </table>
            </td>
        </tr>
		<tr>
        	<td>
            	<table width="100%">
                    <tr>
                        <td class="campo" width="18%"><label>3 - C&oacute;digo na Operadora</label><%=CodigoNaOperadora%></td>
                        <td class="campo"><label>4 - Nome do Contratado</label><%=NomeContratadoExecutante%></td>
                        <td class="campo" width="9%"><label>5 - C&oacute;digo CNES</label><%=CodigoCNESExecutante%></td>
                    </tr>
				</table>
			</td>
        </tr>
        <tr>
        	<td>
            	<table width="100%">
        			<tr><td class="thead campo">Despesas Realizadas</td></tr>
                </table>
            </td>
        </tr>
		<tr>
        	<td>
				<table width="100%">
                	<tr>
                    	<td class="campo">
                            <table><tr>
                                <td width="1%"></td>
                                <td nowrap="nowrap">6-CD</td>
                                <td nowrap="nowrap">7-Data</td>
                                <td nowrap="nowrap">8-Hora Inicial</td>
                                <td nowrap="nowrap">9-Hora Final</td>
                                <td nowrap="nowrap">10-Tabela</td>
                                <td nowrap="nowrap">11-C&oacute;digo do Item</td>
                                <td nowrap="nowrap">12-Qtde.</td>
                                <td nowrap="nowrap">13-Unidade de Medida</td>
                                <td nowrap="nowrap">14-Fator Red./Acresc</td>
                                <td nowrap="nowrap">15-Valor Unit&aacute;rio - R$</td>
                                <td nowrap="nowrap">16-Valor Total - R$</td>
                            </tr>
                            <tr>
                                <td></td>
                                <td colspan="3" nowrap="nowrap">17-Registro ANVISA do Material</td>
                                <td colspan="5" nowrap="nowrap">18-Refer&ecirc;ncia do material no fabricante</td>
                                <td colspan="3" nowrap="nowrap">19-N&deg; Autoriza&ccedil;&atilde;o de Funcionamento</td>
                            </tr>
                            <%
                            c=0
                            set anex = db.execute("select ga.*, p.NomeProduto Descricao from tissguiaanexa as ga left join produtos p on p.id=ga.ProdutoID where GuiaID="&GuiaID)
                            while not anex.eof
                                c=c+1
                                if isnull(anex("HoraInicio")) then HoraInicio="" else HoraInicio=formatdatetime(anex("HoraInicio"),4) end if
                                if isnull(anex("HoraFim")) then HoraFim="" else HoraFim=formatdatetime(anex("HoraFim"),4) end if
                                %>
                                <tr>
                                    <td><%=c%>-</td>
                                    <td width="20" valign="top" class="linha" align="right"><%=zEsq(anex("CD"),2)%></td>
                                    <td width="75" valign="top" class="linha" align="right"><%=anex("Data")%></td>
                                    <td width="50" valign="top" class="linha" align="right"><%=HoraInicio%></td>
                                    <td width="50" valign="top" class="linha" align="right"><%=HoraFim%></td>
                                    <td width="35" valign="top" class="linha" align="right"><%=zeroEsq(anex("TabelaProdutoID"), 2)%></td>
                                    <td valign="top" class="linha" align="right"><%=anex("CodigoProduto")%></td>
                                    <td width="35" valign="top" class="linha" align="right"><%=formatnumber(anex("Quantidade"),2)%></td>
                                    <td width="70" valign="top" class="linha" align="right"><%=zeroEsq(anex("UnidadeMedidaID"), 3)%></td>
                                    <td width="55" valign="top" class="linha" align="right"><%=formatnumber(anex("Fator"),2)%></td>
                                    <td width="55" valign="top" class="linha" align="right"><%=formatnumber(anex("ValorUnitario"),2)%></td>
                                    <td width="55" valign="top" class="linha" align="right"><%=formatnumber(anex("ValorTotal"),2)%></td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td valign="top" colspan="3" class="linha"><%=anex("RegistroAnvisa")%></td>
                                    <td valign="top" colspan="5" class="linha"><%=anex("CodigoNoFabricante")%></td>
                                    <td colspan="3" valign="top" class="linha"><%=anex("AutorizacaoEmpresa")%></td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td nowrap="nowrap">20-Descri&ccedil;&atilde;o</td>
                                    <td colspan="11" class="linha"><%=anex("Descricao")%></td>
                                </tr>
                                <%
                            anex.movenext
                            wend
                            anex.close
                            set anex=nothing
                            
                            while c<10
                                c=c+1
                                %>
                                <tr>
                                    <td><%=c%>-</td>
                                    <td width="20" valign="top" class="linha"></td>
                                    <td width="75" valign="top" class="linha"></td>
                                    <td width="50" valign="top" class="linha"></td>
                                    <td width="50" valign="top" class="linha"></td>
                                    <td width="35" valign="top" class="linha"></td>
                                    <td valign="top" class="linha"></td>
                                    <td width="35" valign="top" class="linha"></td>
                                    <td width="70" valign="top" class="linha"></td>
                                    <td width="55" valign="top" class="linha"></td>
                                    <td width="55" valign="top" class="linha"></td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td valign="top" class="linha"></td>
                                    <td valign="top" class="linha"></td>
                                    <td colspan="3" valign="top" class="linha"></td>
                                    <td width="800" colspan="9" valign="top" class="linha"></td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td nowrap="nowrap">20-Descri&ccedil;&atilde;o</td>
                                    <td colspan="10" class="linha"></td>
                                </tr>
                                <%
                            wend
                            %>
                            </table>
        				</td>
                    </tr>
                </table>
            </td>
        </tr>
		<tr>
        	<td>
            	<table width="100%">
                	<tr>
				      <td width="14%" class="campo"><label>21-Gases Medicinais (R$)</label><%=fn(GasesMedicinais)%></td>
					  <td width="14%" class="campo"><label>22-Medicamentos (R$)</label><%=fn(Medicamentos)%></td>
					  <td width="14%" class="campo"><label>23-Materiais (R$)</label><%=fn(Materiais)%></td>
					  <td width="14%" class="campo"><label>24-OPME (R$)</label><%=fn(OPME)%></td>
					  <td width="14%" class="campo"><label>25-Taxas e Alugu&eacute;is (R$)</label><%=fn(TaxasEAlugueis)%></td>
					  <td width="14%" class="campo"><label>26-Di&aacute;rias (R$)</label>0,00</td>
					  <td width="16%" class="campo"><label>27-Total Geral (R$)</label><%=fn(TotalGeral-Procedimentos)%></td>
					</tr>
				</table>		
			</td>
		</tr>
	</table>
	<div style="page-break-after:avoid;font-size:1;margin:0;border:0;"><span style="visibility: hidden;">&nbsp;</span></div>
	</div>
</body>
</html>
<script>
  window.print();
	window.addEventListener("afterprint", function(event) { window.close(); });
	window.onafterprint();
</script>