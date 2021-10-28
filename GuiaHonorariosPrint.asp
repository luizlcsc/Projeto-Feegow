<!--#include file="connect.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<meta http-equiv="Cache-Control" content="no-cache" />
	<title></title>
</head>
<body>

<%
'on error resume next
    response.charset="utf-8"
set guia = db.execute("select g.*, le.nomelocal as LocalExterno from tissguiahonorarios as g left join locaisexternos le on le.id = g.LocalExternoID where g.id="&req("I"))
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
'	set prof = db.execute("select * from profissionais where id="&guia("ProfissionalID"))
'	if not prof.eof then
'		NomeProfissional = ucase(prof("NomeProfissional"))
'	end if
'	NomeConvenio=guia("NomeConvenio")


	NGuiaPrestador=guia("NGuiaPrestador")
    NGuiaSolicitacaoInternacao = guia("NGuiaSolicitacaoInternacao")
    Senha = guia("Senha")
	RegistroANS=guia("RegistroANS")
	NGuiaOperadora=guia("NGuiaOperadora")
	NumeroCarteira=guia("NumeroCarteira")
    ContratadoLocalCodigoNaOperadora = guia("ContratadoLocalCodigoNaOperadora")
    ContratadoLocalNome = guia("ContratadoLocalNome")
	LocalExterno = guia("LocalExterno")
    ContratadoLocalCNES = guia("ContratadoLocalCNES")
    DataInicioFaturamento = guia("DataInicioFaturamento")
    DataFimFaturamento = guia("DataFimFaturamento")
    Observacoes = guia("Observacoes")
    Procedimentos = guia("Procedimentos")
    DataEmissao = guia("DataEmissao")
'	NomePaciente=guia("NomePaciente")
	CNS=guia("CNS")
	AtendimentoRN=guia("AtendimentoRN")
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
	Procedimentos=guia("Procedimentos")
	if isnull(Procedimentos) then Procedimentos=0 end if

end if
%>
	<style type="text/css">
	    html, body {font-size:10px; margin:0; padding:0;height:100%; font-family:Segoe UI,Verdana,Tahoma,Arial,sans-serif;}
	    .td_texto		{font-size:16px; color:#000000; text-align:left; line-height:25px; background-color:silver; border:1px solid silver; border-left:0; border-right:0; padding-left:9px}
	    .celula_guia	{font-size:12px; color:#000000; border:1px solid #000000; background-color:#ffffff; height:45px;}
	    .campo_titulo	{font-size:12px; color:#000000; border:none; padding-left:3px; height:15px;}
	    .campo_texto	{font-size:12px; color:#000000; border:none; padding-left:3px; padding-right:3px;}
	    .campo_texto2	{font-size:12px; color:#000000; border:none; padding-left:3px; padding-right:3px; text-align:right}
	    .campo_texto3	{font-size:12px; color:#000000; border:none; padding-left:3px; padding-right:3px; text-align:center}
	    .celula_item	{border:1px solid #000000; height:20px; font-size:11px}
	    p.breakhere		{page-break-after:always;}


    @media print and (orientation: landscape) {
         @page {
            margin: 3mm 6.35mm;
         }
     }

     @media print and (orientation: portrait ) {
          @page{
            margin: 3mm 6.35mm;
          }
      }



    @media print and (orientation: landscape) {

           table{
                height: auto !important;
           }
           .subtable{
                height: auto !important;
                border-collapse: collapse;
           }
           .subtable td{
                 border: 1px solid #4f4f4f !important;
           }
           .campo_titulo{font-size:11px; color:#000000; border:none; padding-left:3px; height:10px;}
           .campo_texto {font-size:11px;}

           .celula_guia {
               font-size: 10px;
               color: #000000;
               border: 1px solid #000000;
               background-color: #ffffff;
               height: 31px !important;
           }
           .table_main{
              width: 980px !important;
           }
           .td_texto {
               font-size: 12px;
               color: #000000;
               text-align: left;
               line-height: 12px;
               background-color: silver;
               border: 1px solid silver;
               border-left: 0;
               border-right: 0;
               padding-left: 9px;
           }
           .celula_item {
               border: 1px solid #000000;
               height: 15px;
               font-size: 11px;
           }
    }
	</style>

		<table cellpading="0" class="table_main" cellspacing="0" width="980" align="center" bgcolor="white" style="border:1px solid #444444">
		<tr><td>
		<table width="100%" height="100">
		<tbody>
              <tr>
                <td width="23%" height="40"><strong><%if len(Foto)>2 then%><img src="<%=arqEx(Foto, "Perfil")%>" id="logo" style="max-width: 150px"/><%else%><%= NomeConvenio %><%end if%></strong></td>
                <td width="48%" nowrap="nowrap"><h2>GUIA DE HONORÁRIOS INDIVIDUAIS</h2></td>
                <td align="center" nowrap="nowrap" class="numcard">
                    <% if isnumeric(req("I")) and req("I")<>"" then
                        barcode = ccur(req("I"))+3333333333
                        %>
                    <iframe frameborder="0" scrolling="no" width="280" height="25" src="CodBarras.asp?NumeroCodigo=<%= barcode %>&BPrint=hdn"></iframe>
                    <br />
                    <% end if %>

                    2-Nº Guia no Prestador <br><span style="font-size:13px; font-weight:bold;"><%=NGuiaPrestador%></span></td>
               </tr>
        </tbody>
        </table>
		</td></tr>
		<tr><td><table cellpadding="0" cellspacing="0"><tr>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="210">
		<tr><td class="campo_titulo">1-Registro ANS</td></tr>
		<tr><td class="campo_texto"><%=registroANS %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="270">
		<tr><td class="campo_titulo">3-Nº da Guia de Solicitação de Internação</td></tr>
		<tr><td class="campo_texto"><%=NGuiaSolicitacaoInternacao %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="212">
		<tr><td class="campo_titulo">4-Senha</td></tr>
		<tr><td class="campo_texto"><%=Senha %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="270">
		<tr><td class="campo_titulo">5-Nº da Guia Atribuído pela Operadora</td></tr>
		<tr><td class="campo_texto"><%=NGuiaOperadora %></td></tr>
		</table>
		</td>
		</tr></table></td></tr>
		<tr><td class="td_texto">Dados do Beneficiário</td></tr>
		<tr><td><table cellpadding="0" cellspacing="0"><tr>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="180">
		<tr><td class="campo_titulo">6-Número da Carteira</td></tr>
		<tr><td class="campo_texto"><%=NumeroCarteira %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="666">
		<tr><td class="campo_titulo">7-Nome</td></tr>
		<tr><td class="campo_texto"><%=NomePaciente %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="120">
		<tr><td class="campo_titulo">8-Atendimento a RN</td></tr>
		<tr><td class="campo_texto"><%=AtendimentoRN %></td></tr>
		</table>
		</td>
		</tr></table></td></tr>
		<tr><td class="td_texto">Dados do Contratado (onde foi executado o procedimento)</td></tr>
		<tr><td><table cellpadding="0" cellspacing="0"><tr>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="180">
		<tr><td class="campo_titulo">9-Código na Operadora</td></tr>
		<tr><td class="campo_texto"><%=ContratadoLocalCodigoNaOperadora %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="666">
		<tr><td class="campo_titulo">10-Nome do Hospital/Local</td></tr>
		<tr><td class="campo_texto"><%=LocalExterno %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="120">
		<tr><td class="campo_titulo">11-Código CNES</td></tr>
		<tr><td class="campo_texto"><%=ContratadoLocalCNES %></td></tr>
		</table>
		</td>
		</tr></table></td></tr>
		<tr><td class="td_texto">Dados do Contratado Executante</td></tr>
		<tr><td><table cellpadding="0" cellspacing="0"><tr>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="180">
		<tr><td class="campo_titulo">12-Código na Operadora</td></tr>
		<tr><td class="campo_texto"><%=CodigoNaOperadora %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="666">
		<tr><td class="campo_titulo">13-Nome do Contratado</td></tr>
		<tr><td class="campo_texto"><%=NomeContratadoExecutante %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="120">
		<tr><td class="campo_titulo">14-Código CNES</td></tr>
		<tr><td class="campo_texto"><%=CodigoCNESExecutante %></td></tr>
		</table>
		</td>
		</tr></table></td></tr>
		<tr><td class="td_texto">Dados da Internação</td></tr>
		<tr><td><table cellpadding="0" cellspacing="0"><tr>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="180">
		<tr><td class="campo_titulo">15-Data Início Faturamento</td></tr>
		<tr><td class="campo_texto"><%=DataInicioFaturamento %></td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="180">
		<tr><td class="campo_titulo">16-Data Fim Faturamento</td></tr>
		<tr><td class="campo_texto"><%=DataFimFaturamento %></td></tr>
		</table>
		</td>
		</tr></table></td></tr>
		<tr><td class="td_texto">Procedimentos Realizados</td></tr>
		<tr><td><table width="100%" class="subtable">
		<tr>
		<td class="celula_item" align="center" width="20">&nbsp;</td>
		<td class="celula_item" align="center" width="65">Data</td>
		<td class="celula_item" align="center" width="65">Hora Inicial</td>
		<td class="celula_item" align="center" width="60">Hora Final</td>
		<td class="celula_item" align="center" width="40">Tabela</td>
		<td class="celula_item" align="center" width="70">Código</td>
		<td class="celula_item" align="center">Descrição</td>
		<td class="celula_item" align="center" width="40">Qtde</td>
		<td class="celula_item" align="center" width="35">Via</td>
		<td class="celula_item" align="center" width="35">Téc</td>
		<td class="celula_item" align="center" width="50">Fator</td>
		<td class="celula_item" align="center" width="80">Valor Unitário</td>
		<td class="celula_item" align="center" width="60">Valor Total</td>
		</tr>
		<%
            c = 0
             set procs = db.execute("select * from tissprocedimentoshonorarios where GuiaID="&req("I"))
             while not procs.eof
                TabelaID = procs("TabelaID")


                if TabelaID="101" then
                    TabelaID="00"
                end if
              c = c+1
             %>
				<tr>
				<td class="celula_item" align="center" width="20"><%=c %></td>
				<td class="celula_item" align="center" width="65">&nbsp;<%=procs("Data") %></td>
				<td class="celula_item" align="center" width="65">&nbsp;<%=ft(procs("HoraInicio")) %></td>
				<td class="celula_item" align="center" width="60">&nbsp;<%=ft(procs("HoraFim")) %></td>
				<td class="celula_item" align="center" width="40">&nbsp;<%=TabelaID %></td>
				<td class="celula_item" align="center" width="70">&nbsp;<%=procs("CodigoProcedimento") %></td>
				<td class="celula_item" align="center">&nbsp;<%=procs("Descricao") %></td>
				<td class="celula_item" align="center" width="40">&nbsp;<%=procs("Quantidade") %></td>
				<td class="celula_item" align="center" width="35">&nbsp;<%=procs("ViaID") %></td>
				<td class="celula_item" align="center" width="35">&nbsp;<%=procs("TecnicaID") %></td>
				<td class="celula_item" align="center" width="50">&nbsp;<%=fn(procs("Fator")) %></td>
				<td class="celula_item" align="center" width="80">&nbsp;<%=fn(procs("ValorUnitario")) %></td>
				<td class="celula_item" align="center" width="60">&nbsp;<%=fn(procs("ValorTotal")) %></td>
				</tr>
			 <%
            procs.movenext
            wend
            procs.close
            set procs = nothing
            while c<10
             c = c+1
             %>
				<tr>
				<td class="celula_item" align="center" width="20"><%=c %></td>
				<td class="celula_item" align="center" width="65">&nbsp;</td>
				<td class="celula_item" align="center" width="65">&nbsp;</td>
				<td class="celula_item" align="center" width="60">&nbsp;</td>
				<td class="celula_item" align="center" width="40">&nbsp;</td>
				<td class="celula_item" align="center" width="70">&nbsp;</td>
				<td class="celula_item" align="center">&nbsp;</td>
				<td class="celula_item" align="center" width="40">&nbsp;</td>
				<td class="celula_item" align="center" width="35">&nbsp;</td>
				<td class="celula_item" align="center" width="35">&nbsp;</td>
				<td class="celula_item" align="center" width="50">&nbsp;</td>
				<td class="celula_item" align="center" width="80">&nbsp;</td>
				<td class="celula_item" align="center" width="60">&nbsp;</td>
				</tr>
			 <%
            wend
         %>

		</table></td></tr>
		<tr><td class="td_texto">Identificação do(s) Profissional(is) Executante(s)</td></tr>
		<tr><td><table width="100%" class="subtable">
		<tr>
		<td class="celula_item" align="center" width="50">Seq. Ref.</td>
		<td class="celula_item" align="center" width="70">Grau Part.</td>
		<td class="celula_item" align="center">Nome do Profissional</td>
		<td class="celula_item" align="center" width="140">Cod. na Operadora/CPF</td>
		<td class="celula_item" align="center" width="60">Conselho</td>
		<td class="celula_item" align="center" width="95">Nº no Conselho</td>
		<td class="celula_item" align="center" width="30">UF</td>
		<td class="celula_item" align="center" width="75">Código CBO</td>
		</tr>

		<%
		c=0
		set profs = db.execute("select t.*, p.NomeProfissional, cons.TISS as ConselhoTISS, grau.codigo as grauparticipacao from tissprofissionaishonorarios as t left join cliniccentral.tissgrauparticipacao as grau on grau.id=t.grauparticipacaoid left join profissionais as p on t.ProfissionalID=p.id left join conselhosprofissionais as cons on cons.id=p.Conselho where t.GuiaID="&req("I"))
		while not profs.eof
			c=c+1
			GrauParticipacao=profs("grauparticipacao")
            'if GrauParticipacao=100 then
            '    GrauParticipacao="00"
            'end if

            UFConselho = profs("UFConselho")
            ConselhoTISS=profs("ConselhoTISS")

            if session("Banco")="clinic5856" or session("Banco")="clinic100000"  then
                set UFSQL = db.execute("SELECT codigo FROM estados WHERE sigla='"&UFConselho&"'")

                if not UFSQL.eof then
                    UFConselho = UFSQL("codigo")
                end if

                ConselhoTISS=zeroEsq(ConselhoTISS, 2)
            end if

			%>
            <tr class="sixt-line border">
                <td class="celula_item" align="center" width="50"><%=c%></td>
                <td class="celula_item" align="center" width="70"><%=GrauParticipacao%></td>
                <td class="celula_item" align="center"><%=profs("NomeProfissional")%></td>
                <td class="celula_item" align="center" width="140"><%=profs("CodigoNaOperadoraOuCPF")%></td>
                <td class="celula_item" align="center" width="60"><%=ConselhoTISS%></td>
                <td class="celula_item" align="center" width="95"><%=profs("DocumentoConselho")%></td>
                <td class="celula_item" align="center" width="30"><%=UFConselho%></td>
                <td class="celula_item" align="center" width="75"><%=profs("CodigoCBO")%></td>
			</tr>
           <%
		profs.movenext
		wend
		profs.close
		set profs=nothing

		while c<5
			c=c+1
			%>
				<tr>
				<td class="celula_item" align="center" width="50"><%=c %></td>
				<td class="celula_item" align="center" width="70">&nbsp;</td>
				<td class="celula_item" align="center">&nbsp;</td>
				<td class="celula_item" align="center" width="140">&nbsp;</td>
				<td class="celula_item" align="center" width="60">&nbsp;</td>
				<td class="celula_item" align="center" width="95">&nbsp;</td>
				<td class="celula_item" align="center" width="30">&nbsp;</td>
				<td class="celula_item" align="center" width="75">&nbsp;</td>
				</tr>
			<%
        wend
        %>
		</table></td></tr>
		<tr><td>
		<table cellpadding="0" cellspacing="0"><tr>
		<td class="celula_guia" valign="top">
		<table cellpadding="0" cellspacing="0" height="100%" width="800">
		<tr><td class="campo_titulo">37-Observações</td></tr>
		<tr><td class="campo_texto">
            <%=Observacoes %>
            &nbsp;</td></tr>
		</table>
		</td>
		<td width="2"></td>
		<td valign="top">
		<table cellpadding="0" cellspacing="0">
		<tr><td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="170">
		<tr><td class="campo_titulo">38-Valor total dos honorários</td></tr>
		<tr><td class="campo_texto">&nbsp;<%=fn(Procedimentos) %></td></tr>
		</table>
		</td></tr>
		<tr><td height="1"></td></tr>
		<tr><td class="celula_guia">
		<table cellpadding="0" cellspacing="0" height="100%" width="170">
		<tr><td class="campo_titulo">39-Data de Emissão</td></tr>
		<tr><td class="campo_texto">&nbsp;<%=DataEmissao %></td></tr>
		</table>
		</td></tr>
		</table>
		</td>
		</tr>
		<tr><td height="1"></td></tr>
		<tr><td class="celula_guia" colspan="2">
		<table cellpadding="0" cellspacing="0" height="100%" width="100%">
		<tr><td class="campo_titulo">40-Assinatura do Profissional Executante</td></tr>
		<tr><td class="campo_texto">&nbsp;</td></tr>
		</table>
		</td></tr>
		</table>
		</td></tr>
		</table>

<script>
<%'if request.ServerVariables("REMOTE_HOST")<>"::1" then%>print();<%' End If %>
</script></body>
</html>
