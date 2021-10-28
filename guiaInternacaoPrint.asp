<!--#include file="connect.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" type="text/css" media="all" href="assets/css/tiss.css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Guia de Solicitação de Internação</title>
</head>
<style>
body{
/*	background-repeat:no-repeat;
	background-image:url(./../digitalizar0001.jpgX);
	background-size:100% auto;
	background-position:0 -13px;*/
}
</style>


<%
function CidGuia(CidID)
CidGuia = 0
if CidID&""<>"" then
    set CodigoCid =  db.execute("SELECT Codigo FROM cliniccentral.cid10 WHERE id="&CidID)
    if not CodigoCid.eof then
        CidGuia = CodigoCid("Codigo")
    end if
end if

end function

TipoExibicao = req("TipoExibicao")

set guia = db.execute("select g.*, cons.TISS as ConselhoProfissionalSolicitanteTISS from tissguiainternacao as g left join conselhosprofissionais as cons on cons.id=g.ConselhoProfissionalSolicitanteID where g.id="& treatvalzero(req("I")))
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
	ContratadoSolicitanteID=guia("ContratadoSolicitanteID")
	if guia("tipoContratadoSolicitante")="I" then
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
	else
		set pContExt = db.execute("select * from contratadoexterno where id="&guia("ContratadoSolicitanteID"))
		if not pContExt.eof then
			NomeContratadoSolicitante = pContExt("NomeContratado")
		end if
	end if

	ProfissionalSolicitanteID=guia("ProfissionalSolicitanteID")
	if guia("tipoProfissionalSolicitante")="I" then
		sqlPS = "select * from profissionais where id="&ProfissionalSolicitanteID
	else
		sqlPS = "select * from profissionalexterno where id="&ProfissionalSolicitanteID
	end if
	set ProfissionalSolicitante = db.execute(sqlPS)
	if not ProfissionalSolicitante.eof then
		NomeProfissionalSolicitante = ProfissionalSolicitante("NomeProfissional")
	end if

	NGuiaPrestador=guia("NGuiaPrestador")
	RegistroANS=guia("RegistroANS")
	DataAutorizacao=guia("DataAutorizacao")
	Senha=guia("Senha")
	DataValidadeSenha=guia("DataValidadeSenha")
	NGuiaOperadora=guia("NGuiaOperadora")
	NumeroCarteira=guia("NumeroCarteira")
	ValidadeCarteira=guia("ValidadeCarteira")
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
    CodigoCNES=guia("CodigoCNES")
    IndicacaoAcidenteID=guia("IndicacaoAcidenteID")
	Observacoes=guia("Observacoes")
	Procedimentos=guia("Procedimentos")
	if isnull(Procedimentos) then Procedimentos=0 end if
    NomeHospitalSol=guia("NomeHospitalSol")

    if not isnull(guia("LocalExternoID")) then
        set LocalExternoSQL = db.execute("select * from locaisexternos where id="&treatvalzero(guia("LocalExternoID")))
        if not LocalExternoSQL.eof then
            NomeHospitalSol = LocalExternoSQL("nomelocal")
            if CodigoNaOperadora="" then
                CodigoNaOperadora = LocalExternoSQL("cnpj")
            end if

        end if
    end if

    DataSugInternacao=guia("DataSugInternacao")
    TipoInternacao=guia("TipoInternacao")
    RegimeInternacao=guia("RegimeInternacao")
    QteDiariasSol=guia("QteDiariasSol")
    PrevUsoOPME=guia("PrevUsoOPME")
    PrevUsoQuimio=guia("PrevUsoQuimio")
    Cid1=CidGuia(guia("Cid1"))
    Cid2=CidGuia(guia("Cid2"))
    Cid3=CidGuia(guia("Cid3"))
    Cid4=CidGuia(guia("Cid4"))
    DataAdmisHosp=guia("DataAdmisHosp")
    QteDiariasAut=guia("QteDiariasAut")
    TipoAcomodacao=guia("TipoAcomodacao")
    CodigoOperadoraAut=guia("CodigoOperadoraAut")
    NomeHospitalAut=guia("NomeHospitalAut")






end if
%>


<body>
<div class="main">
  <table width="100%" border="0">
    <tbody>
      <tr>
        <td>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tbody>
              <tr>
                <td width="23%" height="40"><strong><%if len(Foto)>2 then%><img src="<%=arqEx(Foto, "Perfil")%>" id="logo" /><%else%><%= NomeConvenio %><%end if%></strong></td>
                <td width="48%" nowrap="nowrap"><h2>GUIA  DE SOLICITAÇÃO<br />
                 DE INTERNAÇÃO </h2></td>
                <td align="center" nowrap="nowrap" class="numcard">2- Nº Guia no Prestador &nbsp;&nbsp;<span style="font-size:13px; font-weight:bold;"><%=NGuiaPrestador%></span></td>
              </tr>
            </tbody>
        </table>
        </td>
      </tr>

      <tr class="first">
        <td>
        <table width="37%">
          <tbody>
              <tr class="first-line info">
                <td width="25%" class="reg campo">
                    <label>1 - Registro ANS</label>
                    <%=RegistroANS%>
                </td>
                <td width="75%" class="nguia campo">
                <label>3 - Número da Guia Atribuído pela Operadora</label>
                <%=NGuiaOperadora%>
                </td>
              </tr>
           </tbody>
        </table>
        </td>
      </tr>
      <tr class="first">
        <td>
            <table width="95%">
                <tr class="first-line info">
                  <td width="15%" class="dataauto campo"><label>4 - Data da Autorização</label>
                    <%=DataAutorizacao%></td>
                  <td width="60%" class="senha campo"><label>5 - Senha</label>
                    <%=Senha%></td>
                  <td width="25%" class="datavalidade campo"><label>6 - Data de Validade da Senha</label>
                    <%=DataValidadeSenha%></td>
                </tr>
            </table>
        </td>
      </tr>

<tr>
    <td>
        <table width="100%"><tr><td class="thead titulo">Dados do Beneficiário</td></tr></table>
    </td>
</tr>
<tr class="second">
        <td>
        <table width="90%">
          <tbody>
              <tr class="second-line info">
                <td width="60%" class="campo">
                    <label>7 - Número da Carteira</label>
                    <%=NumeroCarteira%>
                </td>
                <td width="30%" class="campo">
                    <label>8 - Validade da Carteira</label>
                    <%=ValidadeCarteira%>
                </td>
                <td width="10%" nowrap="nowrap" class="campo">
                    <label>9-Atendimento a RN</label>
                    <%=AtendimentoRN%>
                </td>
                </tr>
            </tbody>
          </table>
        </td>
</tr>
<tr class="second">
        <td>
        <table width="100%">
          <tbody>
              <tr class="second-line info">
                <td width="60%" class="campo">
                    <label>10 - Nome</label>
                    <%=NomePaciente%>
                </td>
                <td width="40%" class="campo">
                    <label>11 - Cartão Nacional de Saúde</label>
                    <%=CNS%>
                </td>
               </tr>
          </tbody>
        </table>
    </td>
</tr>


<tr>
    <td>
        <table width="100%">
            <tr>
            <td class="thead titulo">Dados do Contratado Solicitante</td>
            </tr>
        </table>
    </td>
</tr>
<tr class="third">
    <td>
    <table width="100%">
      <tbody>
          <tr class="third-line info">
            <td width="30%" class="campo">
                <label>12 - Código na Operadora</label>
                <%=ContratadoSolicitanteCodigoNaOperadora%>
            </td>
            <td width="70%" class="campo">
                <label>13 - Nome do Contratado</label>
                <%=NomeContratadoSolicitante%>
            </td>
          </tr>
        </tbody>
      </table>
    </td>
</tr>
<tr class="fourth">
    <td>
    <table width="100%">
      <tbody>
          <tr class="fourth-line info">
            <td width="40%" class="campo">
                <label>14 - Nome do Profissional Solicitante</label>
                <%=NomeProfissionalSolicitante%>
            </td>
            <td width="10%" nowrap="nowrap" class="campo">
                <label>15 - Conselho Profissional</label>
                <%=ConselhoProfissionalSolicitanteTISS%>
            </td>
            <td width="30%" class="campo">
                <label>16 - Número no Conselho</label>
                <%=NumeroNoConselhoSolicitante%>
            </td>
            <td width="5%" class="campo">
                <label>17 - UF</label>
                <%=UFConselhoSolicitante%>
            </td>
            <td width="15%" class="campo">
                <label>18 - Código CBO</label>
                <%=CodigoCBOSolicitante%>
            </td>
          </tr>
      </tbody>
    </table>
    </td>
</tr>

<tr>
    <td>
        <table width="100%">
            <tr>
            <td class="thead titulo">Dados do Hospital / Local Solicitado / Dados da Internação</td>
            </tr>
        </table>
    </td>
</tr>

<tr class="fifth">
    <td>
        <table width="100%">
          <tbody>
              <tr class="fifth-line info">
                <td width="35%" nowrap="nowrap" class="campo">
                    <label>19 - Código na Operadora / CNPJ</label>
                    <%=CodigoNaOperadora%>
                </td>
                <td width="45%" nowrap="nowrap" class="campo">
                    <label>20 - Nome do Hospital / Local Solicitado</label>
                    <%=NomeHospitalSol%>
                </td>
                <td width="20%" class="campo">
                    <label>21 - Data sugerida para internação</label>
                    <%=DataSugInternacao%>
                </td>
              </tr>
          </tbody>
        </table>
    </td>
</tr>
<tr class="fifth">
    <td>
        <table width="100%">
          <tbody>
              <tr class="fifth-line info">
                <td width="17%" nowrap="nowrap" class="campo">
                    <label>22 - Caráter do atendimento</label>
                    <%=CaraterAtendimentoID%>
                </td>
                <td width="12%" nowrap="nowrap" class="campo">
                    <label>23 - Tipo de Internação</label>
                    <%=TipoInternacao%>
                </td>
                <td width="15%" class="campo">
                    <label>24 - Regime de Internação</label>
                    <%=RegimeInternacao%>
                </td>
                <td width="18%" class="campo">
                    <label>25 - Qtde. Diárias Solicitadas</label>
                    <%=QteDiariasSol%>
                </td>
                <td width="18%" class="campo">
                    <label>26 - Previsão de uso de OPME</label>
                    <%=PrevUsoOPME%>
                </td>
                <td width="20%" class="campo">
                    <label>27 - Previsão de uso de quimioterápico</label>
                    <%=PrevUsoQuimio%>
                </td>
              </tr>
          </tbody>
        </table>
    </td>
</tr>
<tr class="fifth">
    <td>
        <table width="100%">
          <tbody>
              <tr class="fifth-line info">
                <td width="100%" class="campo" style="height: 100px !important;">
                    <label>28 - Indicação Clínica</label>
                    <%=IndicacaoClinica%>
                </td>
              </tr>
          </tbody>
        </table>
    </td>
</tr>
<tr class="fifth">
    <td>
        <table width="100%">
          <tbody>
              <tr class="fifth-line info">
                <td width="15%" nowrap="nowrap" class="campo">
                    <label>29 - CID 10 Principal</label>
                    <%=Cid1%>
                </td>
                <td width="15%" nowrap="nowrap" class="campo">
                    <label>30 - CID 10 (2)</label>
                    <%=Cid2%>
                </td>
                <td width="15%" class="campo">
                    <label>31 - CID 10 (3)</label>
                    <%=Cid3%>
                </td>
                <td width="15%" class="campo">
                    <label>32 - CID 10 (4)</label>
                    <%=Cid4%>
                </td>
                <td width="40%" class="campo">
                    <label>33 - Indicação de Acidente (acidente ou doença relacionada)</label>
                    <%=IndicacaoAcidenteID%>
                </td>
              </tr>
          </tbody>
        </table>
    </td>
</tr>




<tr>
    <td>
        <table width="100%"><tr><td class="thead titulo">Procedimentos Solicitados</td></tr></table>
    </td>
</tr>
<tr class="sixth">
	<td>
        <table width="100%"><tr><td>
        <table width="100%" class="campo">
          <tbody class="proc">
              <tr class="sixt-line border">
              	<td width="2%"></td>
                <td width="5%" nowrap="nowrap" class="tabproc border-lad"><label>34 - Tabela</label></td>
                <td width="13%" nowrap="nowrap" class="codproc border-lad"><label>35 - Código do Procedimento</label></td>
                <td width="40%" nowrap="nowrap" class="descproc border-lad"><label>36 - Descrição</label></td>
                <td width="10%" nowrap="nowrap" class="qtdaut border-lad"><label>37 - Qtde. Solic</label></td>
                <td width="10%" nowrap="nowrap" class="qtdaut border-lad"><label>38 - Qtde. Aut</label></td>
              </tr>
		<%
		c=0
		set procs = db.execute("select * from tissprocedimentosinternacao where GuiaID="& treatvalzero(req("I")) &" order by id")
		while not procs.eof
			c=c+1
			%>
                <tr class="sixt-line border">
                    <td nowrap="nowrap" class="num border-lad"><%=c%> - </td>
                    <td class="linha"><%=procs("TabelaID")%></td>
                    <td class="linha"><%=procs("CodigoProcedimento")%></td>
                    <td nowrap="nowrap" class="linha"><%=left(procs("Descricao"),43)%></td>
                    <td class="linha"><%=procs("Quantidade")%></td>
                    <td class="linha"><%=procs("QuantidadeAutorizada")%></td>
                </tr>
                <%
			procs.movenext
			wend
			procs.close
			set procs=nothing

			while c<12
				c=c+1
				%>
                <tr class="sixt-line border">
                    <td nowrap="nowrap"><%=c%> - </td>
                    <td class="linha"></td>
                    <td class="linha"></td>
                    <td class="linha"></td>
                    <td class="linha"></td>
                    <td class="linha"></td>
                </tr>
                <%
			wend
			%>
            </tbody>
          </table>
          </td>
          </tr></table>
    </td>
</tr>

<tr>
    <td>
        <table width="100%"><tr><td class="thead titulo">Dados da Autorização</td></tr></table>
    </td>
</tr>
<tr class="third">
    <td>
        <table width="70%">
            <tbody>
              <tr class="third-line info">
                <td width="35%" nowrap="nowrap" class="campo">
                    <label>39 - Data Provável da Admissão Hospitalar</label>
                    <%=DataAdmisHosp%>
                </td>
                <td width="30%" nowrap="nowrap" class="campo">
                    <label>40 - Qtde. Diarias Autorizadas</label>
                    <%=QteDiariasAut%>
                </td>
                <td width="35%" nowrap="nowrap" class="campo">
                    <label>41 - Tipo da Acomodação Autorizada</label>
                    <%=TipoAcomodacao%>
                </td>
              </tr>
            </tbody>
        </table>
    </td>
</tr>
<tr class="third">
    <td>
        <table width="100%">
            <tbody>
              <tr class="third-line info">
                <td width="35%" nowrap="nowrap" class="campo">
                    <label>42 - Código na Operadora / CNPJ autorizado</label>
                    <%=CodigoOperadoraAut%>
                </td>
                <td width="30%" nowrap="nowrap" class="campo">
                    <label>43 - Nome do Hospital / Local Autorizado</label>
                    <%=NomeHospitalAut%>
                </td>
                <td width="35%" nowrap="nowrap" class="campo">
                    <label>44 - Código CNES</label>
                    <%=CodigoCNES%>
                </td>
              </tr>
            </tbody>
        </table>
    </td>
</tr>
<tr class="third">
    <td>
        <table width="100%" border="0">
            <tbody>
                <tr>
                <td class="campo"  style="height: 40px;"><label>45 - Observação / Justificativa</label>
                <%=Observacoes%>
                </td>
                </tr>
            </tbody>
        </table>
    </td>
</tr>
<tr class="third">
    <td>
        <table width="100%">
            <tbody>
              <tr class="third-line info">
                <td width="25%" nowrap="nowrap" class="campo">
                    <label>46 - Data de Solicitação</label>
                    <%=DataSolicitacao%>
                </td>
                <td width="25%" nowrap="nowrap" class="campo">
                    <label>47 - Assinatura do Profissional Solicitante</label>
                </td>
                <td width="25%" nowrap="nowrap" class="campo">
                    <label>48 - Assinatura do Beneficiário ou Responsável</label>
                </td>
                <td width="25%" nowrap="nowrap" class="campo">
                    <label>49 - Assinatura do Responsável pela Autorização</label>
                </td>
              </tr>
            </tbody>
        </table>
    </td>
</tr>

</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</div>
</body>
</html>
<script type="text/javascript">
    print();
    <%
    if TipoExibicao="Pedido" then
        %>
        window.opener.pront('timeline.asp?PacienteID=<%= PacienteID %>&Tipo=|Pedido|');
        <%
    End If
    %>
</script>