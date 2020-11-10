<!--#include file="connect.asp"-->
<% Response.Codepage = 65001 %>
<%
response.CharSet = "utf-8"


set conf = db.execute("select * from sys_config")
OmitirValorGuiaConfig = conf("OmitirValorGuia")
OmitirValorGuia = ""
if OmitirValorGuiaConfig&""<>"" then
    if instr(OmitirValorGuiaConfig, "|"&session("User")&"|")>0 then
        OmitirValorGuia = "1"
    end if

end if



set guia = db.execute("select g.*, cons.TISS as ConselhoTISS from tissguiaconsulta as g left join conselhosprofissionais as cons on cons.id=g.Conselho where g.id="&request.QueryString("I"))
if not guia.eof then
	set conv = db.execute("select * from convenios where id="&guia("ConvenioID"))
	if not conv.EOF then
		NomeConvenio = ucase(conv("NomeConvenio"))
		Foto = conv("Foto")
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
	set prof = db.execute("select * from profissionais where id="&guia("ProfissionalID"))
	if not prof.eof then
		NomeProfissional = ucase(prof("NomeProfissional"))
	end if
	NGuiaPrestador = guia("NGuiaPrestador")
	RegistroANS = guia("RegistroANS")
	NGuiaOperadora = guia("NGuiaOperadora")
	NumeroCarteira = guia("NumeroCarteira")
	ValidadeCarteira = guia("ValidadeCarteira")
	AtendimentoRN = guia("AtendimentoRN")
	CNS = guia("CNS")
	CodigoNaOperadora = guia("CodigoNaOperadora")
	CodigoCNES = guia("CodigoCNES")
	Conselho = guia("ConselhoTISS")
	DocumentoConselho = guia("DocumentoConselho")
	UFConselho = guia("UFConselho")

	if session("Banco")="clinic5856" or session("Banco")="clinic100000"  then
	    set UFSQL = db.execute("SELECT codigo FROM estados WHERE sigla='"&UFConselho&"'")

	    if not UFSQL.eof then
	        UFConselho = UFSQL("codigo")
        end if

        Conselho = zeroEsq(Conselho, 2)
	end if

	CodigoCBO = guia("CodigoCBO")
	IndicacaoAcidenteID = guia("IndicacaoAcidenteID")
	DataAtendimento = guia("DataAtendimento")
	TipoConsultaID = guia("TipoConsultaID")
	TabelaID = guia("TabelaID")
	CodigoProcedimento = guia("CodigoProcedimento")
	ValorProcedimento = guia("ValorProcedimento")
	Observacoes = guia("Observacoes")
	
end if
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
	<title>FEEGOW CLINIC - Impress&atilde;o de Guia</title>
</head>
<body>

	<style>
	html, body {font-size:10px; margin:0; padding:0;height:100%; font-family:Segoe UI,Verdana,Tahoma,Arial,sans-serif;}
	.td_texto		{font-size:16px; color:#000000; text-align:left; line-height:25px; background-color:silver; border:1px solid silver; border-left:0; border-right:0; padding-left:9px}
	.celula_guia	{font-size:12px; color:#000000; border:1px solid #000000; background-color:#ffffff; height:50px;}
	.campo_titulo	{font-size:12px; color:#000000; border:none; padding-left:3px; height:15px;}
	.campo_texto	{font-size:14px; color:#000000; border:none; padding-left:3px; padding-right:3px;}
	.campo_texto2	{font-size:14px; color:#000000; border:none; padding-left:3px; padding-right:3px; text-align:right}
	.campo_texto3	{font-size:14px; color:#000000; border:none; padding-left:3px; padding-right:3px; text-align:center}
	.celula_item	{border:1px solid #000000;}
	</style>
<a style="position:fixed; background-color:#0CF; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px; display:none" href="javascript:print();" class="print" rel="areaImpressao">
	<img src="assets/img/printer.png" border="0" alt="IMPRIMIR" title="IMPRIMIR" align="absmiddle"> <strong>IMPRIMIR</strong>
</a>
	<table cellpadding="0" cellspacing="0" align="center" style="border:1px solid #666666">
	<tr><td>
	<table width="100%" height="100"><tr>
	<td width="240" style="font-size:12px; overflow:hidden"><strong><%if len(Foto)>2 then%><img src="<%=arqEx(Foto, "Perfil")%>" width="120" /><%else%><%= NomeConvenio %><%end if%></strong></td>
	<td align="center" nowrap style="font-size:22px; font-weight:bold">GUIA DE CONSULTA</td>
	<td width="240" align="center" nowrap>
                    <% if isnumeric(req("I")) and req("I")<>"" then
                        barcode = ccur(req("I"))+1111111111
                        %>
                    <iframe frameborder="0" scrolling="no" width="280" height="25" src="CodBarras.asp?NumeroCodigo=<%= barcode %>&BPrint=hdn"></iframe>
                    <br />
                    <% end if %>

        2-N&deg; Guia no Prestador<BR><span style="font-size:14px; font-weight:bold"><%=NGuiaPrestador%></span></td>
	</tr></table>
	</td></tr>
	<tr><td>
	<table cellpadding="0" cellspacing="0">
	<tr>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="160">
	<tr><td class="campo_titulo">1-Registro ANS</td></tr>
	<tr><td class="campo_texto"><%=RegistroANS%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="240">
	<tr><td class="campo_titulo">3-N&deg; da Guia Atribu&iacute;do pela Operadora</td></tr>
	<tr><td class="campo_texto"><%=NGuiaOperadora%></td></tr>
	</table>
	</td>
	</tr></table></td></tr>
	<tr><td height="2"></td></tr>
	<tr><td class="td_texto">Dados do Benefici&aacute;rio</td></tr>
	<tr><td height="2"></td></tr>
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="250">
	<tr><td class="campo_titulo">4-N&uacute;mero da Carteira</td></tr>
	<tr><td class="campo_texto"><%=NumeroCarteira%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">	
	<table cellpadding="0" cellspacing="0" height="100%" width="130">
	<tr><td class="campo_titulo">5-Validade da Carteira</td></tr>
	<tr><td class="campo_texto2"><%=ValidadeCarteira%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="120">
	<tr><td class="campo_titulo">6-Atendimento a RN</td></tr>
	<tr><td class="campo_texto3"><%=AtendimentoRN%></td></tr>
	</table>	
	</td>
	</tr></table></td></tr>
	<tr><td height="2"></td></tr>
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td width="2"></td>
	<td class="celula_guia">	
	<table cellpadding="0" cellspacing="0" height="100%" width="600">
	<tr><td class="campo_titulo">7-Nome</td></tr>
	<tr><td class="campo_texto"><%=NomePaciente%></td></tr>
	</table>	
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="160">
	<tr><td class="campo_titulo">8-Cart&atilde;o Nacional de Sa&uacute;de</td></tr>
	<tr><td class="campo_texto"><%=CNS%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	</tr></table></td></tr>
	<tr><td height="2"></td></tr>
	<tr><td class="td_texto">Dados do Contratado</td></tr>
	<tr><td height="2"></td></tr>
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="135">
	<tr><td class="campo_titulo">9-C&oacute;digo na Operadora</td></tr>
	<tr><td class="campo_texto"><%=CodigoNaOperadora%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="520">
	<% if getConfig("NaoExibirNomeContratado") <> 1 then %>
	<tr><td class="campo_titulo">10-Nome do Contratado</td></tr>
	<tr><td class="campo_texto"><%=NomeContratado%></td></tr>
	<% end if %>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="101">
	<tr><td class="campo_titulo">11-C&oacute;digo CNES</td></tr>
	<tr><td class="campo_texto"><%=CodigoCNES%></td></tr>
	</table>
	</td>
	</tr></table></td></tr>
	<tr><td height="2"></td></tr>
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="383">
	<tr><td class="campo_titulo">12-Nome do Profissional Executante</td></tr>
	<tr><td class="campo_texto"><%=NomeProfissional%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="80">
	<tr><td class="campo_titulo">13-Conselho</td></tr>
	<tr><td class="campo_texto3"><%=Conselho%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="142">
	<tr><td class="campo_titulo">14-N&uacute;mero no Conselho</td></tr>
	<tr><td class="campo_texto"><%=DocumentoConselho%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="50">
	<tr><td class="campo_titulo">15-UF</td></tr>
	<tr><td class="campo_texto"><%=ucase(UFConselho)%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="93">
	<tr><td class="campo_titulo">16-C&oacute;digo CBO</td></tr>
	<tr><td class="campo_texto"><%=CodigoCBO%></td></tr>
	</table>
	</td>
	</tr></table></td></tr>
	<tr><td height="2"></td></tr>
	<tr><td class="td_texto">Dados do Atendimento / Procedimento Realizado</td></tr>
	<tr><td height="2"></td></tr>
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="334">
	<tr><td class="campo_titulo">17-Indica&ccedil;&atilde;o de Acidente (acidente ou doen&ccedil;a relacionada)</td></tr>
	<tr><td class="campo_texto3"><%=IndicacaoAcidenteID%></td></tr>
	</table>
	</td>
	</tr></table></td></tr>
	<tr><td height="2"></td></tr>
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="160">
	<tr><td class="campo_titulo">18-Data do Atendimento</td></tr>
	<tr><td class="campo_texto"><%=DataAtendimento%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="170">
	<tr><td class="campo_titulo">19-Tipo de Consulta</td></tr>
	<tr><td class="campo_texto3"><%=TipoConsultaID%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="78">
	<tr><td class="campo_titulo">20-Tabela</td></tr>
	<tr><td class="campo_texto3"><%=TabelaID%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="170">
	<tr><td class="campo_titulo">21-C&oacute;digo do Procedimento</td></tr>
	<tr><td class="campo_texto"><%=CodigoProcedimento%></td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="100%" width="170">
	<tr><td class="campo_titulo">22-Valor do Procedimento</td></tr>
	<tr><td class="campo_texto2">
	<% if OmitirValorGuia="" then response.write(formatnumber(ValorProcedimento,2)) end if%></td></tr>
	</table>
	</td>
	</tr></table></td></tr>
	<tr><td height="2"></td></tr>
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" cellspacing="0" height="120" width="764">
	<tr><td class="campo_titulo">23-Observa&ccedil;&otilde;es</td></tr>
	<tr><td class="campo_texto" valign="top"><%=Observacoes%></td></tr>
	</table>
	</td>
	</tr></table>	
	</td></tr>
	<tr><td height="2"></td></tr>	
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" height="100%" cellspacing="0" width="380">
	<tr><td class="campo_titulo">24-Assinatura do Profissional Executante</td></tr>
	<tr><td class="campo_texto">&nbsp;</td></tr>
	</table>
	</td>
	<td width="2"></td>
	<td class="celula_guia">
	<table cellpadding="0" height="100%" cellspacing="0" width="380">
	<tr><td class="campo_titulo">25-Assinatura do Benefici&aacute;rio ou Respons&aacute;vel</td></tr>
	<tr><td class="campo_texto">&nbsp;</td></tr>
	</table>
	</td>
	<td width="2"></td>
	</tr></table></td></tr>
	<tr><td height="2"></td></tr>
	</table>
</body>
</html>
<script type="text/javascript">
	window.print();
	window.addEventListener("afterprint", function(event) { window.close(); });
	window.onafterprint();
</script>