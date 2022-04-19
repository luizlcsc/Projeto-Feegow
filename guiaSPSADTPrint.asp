<!--#include file="connect.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" type="text/css" media="all" href="assets/css/tiss.css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><% if session("banco") = "clinic10402" then %>Solicitação<% else %>Guia<% end if %> de SP/SADT</title>
</head>
<style type="text/css">
body{
/*	background-repeat:no-repeat;
	background-image:url(./../digitalizar0001.jpgX);
	background-size:100% auto;
	background-position:0 -13px;*/
}
.imprimirGuia {
    right:10px; 
    bottom:50px;
    position:fixed;
}
.imprimirGuia button {
    background-color: #3bafda;
    color: #ffffff;
    border:none;
    padding:5px;
    border-radius:2px;
    margin-top:22px;
}
@media print {
    .imprimirGuia{
        display:none;
    }
}

.main{
    page-break-after: always;
}
</style>

<body>

<%
LoteID = req("LoteID")&""
TipoExibicao = req("TipoExibicao")
AutoPrintAnexa = getConfig("AutoPrintGuiaAnexa")

whereGuias = " AND id="&req("I")
if isnumeric(LoteID) then
  whereGuias = " AND LoteID="&LoteID
end if

if TipoExibicao="Pedido" then
  set GuiaSQL = db.execute("SELECT id FROM pedidossadt WHERE 1 AND id="& req("PedidoSADTID"))
else
  set GuiaSQL = db.execute("SELECT id FROM tissguiasadt WHERE 1"&whereGuias)
end if

while not GuiaSQL.eof 
  GuiaID = GuiaSQL("id")
  
  if TipoExibicao="Pedido" then
      GuiaID = 0
      db_execute("update pedidossadt set ConvenioID="& treatvalzero(req("ConvenioIDPedidoSADT")) &", ProfissionalID="&treatvalzero(req("ProfissionalID"))&", Data="&mydatenull(req("DataSolicitacao"))&", IndicacaoClinica='"& req("IndicacaoClinicaPedidoSADT") &"', Observacoes='"& req("ObservacoesPedidoSADT") &"', ProfissionalExecutante='"& req("ProfissionalExecutanteIDPedidoSADT") &"' where id="& req("PedidoSADTID"))
      set procs = db.execute("select pps.*, ps.ConvenioID, pac.ConvenioID1, pac.ConvenioID2, pac.ConvenioID3, ps.PacienteID, ps.ProfissionalID, ps.IndicacaoClinica, ps.Observacoes, pac.NomePaciente, pac.Matricula1, pac.Matricula2, pac.Matricula3, pac.Validade1, ps.`Data` from pedidossadtprocedimentos pps LEFT JOIN pedidossadt ps ON pps.PedidoID=ps.id LEFT JOIN pacientes pac ON pac.id=ps.PacienteID where pps.PedidoID="& req("PedidoSADTID"))
      if not procs.EOF then
        if procs("ConvenioID") = procs("ConvenioID1") then
          NumeroCarteira = procs("Matricula1")
        elseif procs("ConvenioID") = procs("ConvenioID2") then
          NumeroCarteira = procs("Matricula2")
        elseif procs("ConvenioID") = procs("ConvenioID3") then
          NumeroCarteira = procs("Matricula3")
        end if
          set conv = db.execute("select * from convenios where id='"& procs("ConvenioID")&"'")
          if not conv.EOF then
              ConvenioID = conv("id")
              NomeConvenio = ucase(conv("NomeConvenio"))
              Foto = conv("Foto")
              RegistroANS = conv("RegistroANS")
          end if
          PacienteID = procs("PacienteID")
          NomePaciente = procs("NomePaciente")
          ValidadeCarteira = procs("Validade1")
          IndicacaoClinica = procs("IndicacaoClinica")
          Observacoes = procs("Observacoes")
          DataSolicitacao = procs("Data")
          set profSol = db.execute("select p.*, e.CodigoTISS, cons.TISS ConselhoProfissionalSolicitanteTISS from profissionais p LEFT JOIN especialidades e ON e.id=p.EspecialidadeID LEFT JOIN conselhosprofissionais cons ON cons.id=p.Conselho where p.id='"& procs("ProfissionalID") &"'")
          if not profSol.eof then
              NomeProfissionalSolicitante = profSol("NomeProfissional")
              ConselhoProfissionalSolicitanteTISS = profSol("ConselhoProfissionalSolicitanteTISS")
              NumeroNoConselhoSolicitante=profSol("DocumentoConselho")
              UFConselhoSolicitante=profSol("UFConselho")
              CodigoCBOSolicitante=profSol("CodigoTISS")
          end if
      end if
  else
      set procs = db.execute("select * from tissprocedimentossadt where GuiaID="&GuiaID&" order by id")
  end if
  'on error resume next
  set conf = db.execute("select * from sys_config")
  OmitirValorGuiaConfig = conf("OmitirValorGuia")
  OmitirValorGuia = ""
  if OmitirValorGuiaConfig&""<>"" then
      if instr(OmitirValorGuiaConfig, "|"&session("User")&"|")>0 then
          OmitirValorGuia = "1"
      end if
  end if
  set guia = db.execute("select g.*, cons.TISS as ConselhoProfissionalSolicitanteTISS from tissguiasadt as g left join conselhosprofissionais as cons on cons.id=g.ConselhoProfissionalSolicitanteID where g.id="& treatvalzero(GuiaID))
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
        if guia("Contratado")&""<>"" then
              set pcont = db.execute("select NomeProfissional from profissionais where id="&guia("Contratado"))
              if not pcont.eof then
                  NomeContratado = ucase(pcont("NomeProfissional"))
              end if
          else
              NomeContratado = ""
      end if
    end if
  '	set prof = db.execute("select * from profissionais where id="&guia("ProfissionalID"))
  '	if not prof.eof then
  '		NomeProfissional = ucase(prof("NomeProfissional"))
  '	end if
  '	NomeConvenio=guia("NomeConvenio")
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
        if Contratado&""<>"" then
              set pContratado = db.execute("select * from profissionais where id="&Contratado)
              if not pContratado.eof then
                  NomeContratadoExecutante = pContratado("NomeProfissional")
              end if
          else
              NomeContratadoExecutante = ""
          end if
    end if
    if Contratado=0 AND recursoAdicional(12)=4 then
        NomeContratadoExecutante = ""
    end if
    CodigoCNESExecutante=guia("CodigoCNES")
    TipoAtendimentoID=guia("TipoAtendimentoID")
    IndicacaoAcidenteID=guia("IndicacaoAcidenteID")
    TipoConsultaID=guia("TipoConsultaID")
    MotivoEncerramentoID=guia("MotivoEncerramentoID")
    DataSerie01=guia("DataSerie01")
    DataSerie02=guia("DataSerie02")
    DataSerie03=guia("DataSerie03")
    DataSerie04=guia("DataSerie04")
    DataSerie05=guia("DataSerie05")
    DataSerie06=guia("DataSerie06")
    DataSerie07=guia("DataSerie07")
    DataSerie08=guia("DataSerie08")
    DataSerie09=guia("DataSerie09")
    DataSerie10=guia("DataSerie10")
    Observacoes=guia("Observacoes")
    Procedimentos=guia("Procedimentos")
    if isnull(Procedimentos) then Procedimentos=0 end if
    TaxasEAlugueis=guia("TaxasEAlugueis")
    if isnull(TaxasEAlugueis) then TaxasEAlugueis=0 end if
    Materiais=guia("Materiais")
    if isnull(Materiais) then Materiais=0 end if
    OPME=guia("OPME")
    if isnull(OPME) then OPME=0 end if
    Medicamentos=guia("Medicamentos")
    if isnull(Medicamentos) then Medicamentos=0 end if
    GasesMedicinais=guia("GasesMedicinais")
    if isnull(GasesMedicinais) then GasesMedicinais=0 end if
    TotalGeral=guia("TotalGeral")
end if
  %>


  <div class="main">
    <table width="100%" border="0">
      <tbody>
        <tr>
          <td>
          <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <tr>
                  <td width="23%" height="40"><strong><%if len(Foto)>2 then%><img src="<%=arqEx(Foto, "Perfil")%>" id="logo" /><%else%><%= NomeConvenio %><%end if%></strong></td>
                  <td width="48%" nowrap="nowrap"><h2><% if session("banco") = "clinic10402" then %>SOLICITAÇÃO<% else %>GUIA<% end if %> DE SERVIÇO PROFISSIONAL / SERVIÇO AUXILIAR DE<br />
                  DIAGNÓSTICO E TERAPIA - SP/SADT </h2></td>
                  <td align="center" nowrap="nowrap" class="numcard">
                      <% if isnumeric(GuiaID) and GuiaID<>"" then
                          barcode = ccur(GuiaID)+2222222222
                          %>
                      <iframe frameborder="0" scrolling="no" width="280" height="25" src="CodBarras.asp?NumeroCodigo=<%= barcode %>&BPrint=hdn"></iframe>
                      <br />
                      <% end if %>
                      2- Nº Guia no Prestador &nbsp;&nbsp;<span style="font-size:13px; font-weight:bold;">
                      <%=NGuiaPrestador%></span></td>
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
    <label>3 - Número da Guia Principal</label>
    <%=NGuiaPrincipal%>
  </td>
  </tr>
              </tbody>
            </table>
          </td>
        </tr>
        <tr class="first">
          <td><table width="81%">
              <tr class="first-line info">
                <td width="16%" class="dataauto campo"><label>4 - Data da Autorização</label>
                  <%=DataAutorizacao%></td>
                <td width="35%" class="senha campo"><label>5 - Senha</label>
                  <%=Senha%></td>
                <td width="15%" class="datavalidade campo"><label>6 - Data de Validade da Senha</label>
                  <%=DataValidadeSenha%></td>
                <td width="34%" class="dataemissao campo"><label>7 - Número da Guia Atribuído pela Operadora</label>
                  <%=NGuiaOperadora%></td>
              </tr>
          </table></td>
        </tr>
  <tr>
  <td>
  <table width="100%"><tr><td class="thead titulo">Dados do Beneficiário</td></tr></table>
  </td>
  </tr>
  <tr class="second">
          <td>
          <table width="100%">
            <tbody>
                <tr class="second-line info">
  <td width="24%" class="campo">
  <label>8 - Número da Carteira</label>
  <%=NumeroCarteira%>
  </td>
  <td width="13%" class="campo">
  <label>9 - Validade da Carteira</label>
  <%=ValidadeCarteira%>
  </td>
  <td width="37%" class="campo">
  <label>10 - Nome</label>
  <%=NomePaciente%>
  </td>
  <td width="18%" class="campo">
  <label>11 - Cartão Nacional de Saúde</label>
  <%=CNS%>
  </td>
  <td width="8%" nowrap="nowrap" class="campo">
  <label>12-Atendimento a RN</label>
  <%=AtendimentoRN%>
  </td>

  </tr>
              </tbody>
            </table>
          </td>
        </tr>
        
        <tr>
  <td>
  <table width="100%"><tr><td class="thead titulo">Dados do  Solicitante</td></tr></table>
  </td>
  <tr class="third">
          <td>
          <table width="100%">
            <tbody>
                <tr class="third-line info">
  <td width="20%" class="campo">
  <label>13 - Código na Operadora</label>
  <%=ContratadoSolicitanteCodigoNaOperadora%>
  </td>
  <td width="80%" class="campo">
  <label>14 - Nome do Contratado</label>
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
  <%
  if session("Banco")="clinic5856" or session("Banco")="clinic100000"  then
      set UFSQL = db.execute("SELECT codigo FROM estados WHERE sigla='"&UFConselhoSolicitante&"'")
      if not UFSQL.eof then
          UFConselhoSolicitante = UFSQL("codigo")
      end if
      ConselhoProfissionalSolicitanteTISS= zeroEsq(ConselhoProfissionalSolicitanteTISS, 2)
  end if
  %>
  <td width="29%" class="campo">
  <label>15 - Nome do Profissional Solicitante</label>
  <%=NomeProfissionalSolicitante%>
  </td>
  <td width="10%" nowrap="nowrap" class="campo">
  <label>16 - Conselho Profissional</label>
  <%=ConselhoProfissionalSolicitanteTISS%>
  </td>
  <td width="17%" class="campo">
  <label>17 - Número no Conselho</label>
  <%=NumeroNoConselhoSolicitante%>
  </td>

  <td width="5%" class="campo">
  <label>18 - UF</label>
  <%=UFConselhoSolicitante%>
  </td>
  <td width="8%" class="campo">
  <label>19 - Código CBO</label>
  <%=CodigoCBOSolicitante%>
  </td>
  <td width="31%" class="campo">
  <label>20 - Assinatura do Profissional Solicitante</label>
  &nbsp;
  </td>

  </tr>
              </tbody>
            </table>
          </td>
        </tr>
        
        <tr>
  <td>
  <table width="100%"><tr><td class="thead titulo">Dados da  Solicitação / Procedimentos ou Itens Assistenciais Solicitados</td></tr></table>
  </td>
        </tr>

  <tr class="fifth">
          <td>
          <table width="100%">
            <tbody>
                <tr class="fifth-line info">
  <td width="9%" nowrap="nowrap" class="campo">
  <label>21 - Caráter do atendimento</label>
  <%=CaraterAtendimentoID%>
  </td>
  <td width="8%" nowrap="nowrap" class="campo">
  <label>22 - Data da Solicitação</label>
  <%=DataSolicitacao%>
  </td>

  <td width="83%" class="campo">
  <label>23 - Indicação Clínica</label>
  <%=IndicacaoClinica%>
  </td>


  </tr>
              </tbody>
            </table>
          </td>
        </tr>
        
        
        <tr class="sixth">
          <td>


  <table width="100%"><tr><td>

          <table width="100%" class="campo">
            <tbody class="proc">
                <tr class="sixt-line border">
                <td></td>
                  <td width="5%" nowrap="nowrap" class="tabela border-lad"><label>24 - Tabela Aut.</label></td>
                  <td width="5%" nowrap="nowrap" class="codproc border-lad"><label>25 - Código do Procedimento</label></td>
                  <td width="80%" class="desc border-lad"><label>26 - Descrição</label></td>
                  <td width="5%" nowrap="nowrap" class="qtdsolic border-lad"><label>27 - Qtde. Solic.</label></td>
                  <td width="5%" nowrap="nowrap" class="qtdaut "><label>28 - Qtde.</label></td>
        </tr>
      <%
      c=0
      
      while not procs.eof
        c=c+1
        %>
              <tr class="sixt-line border">
          <td nowrap="nowrap"><%=c%> - </td>
                  <td class="linha"><%=procs("TabelaID")%></td>
                  <td class="linha"><%=procs("CodigoProcedimento")%></td>
                  <td nowrap="nowrap" class="linha"><%=procs("Descricao")%></td>
                  <td nowrap="nowrap" class="linha "><%=procs("Quantidade")%></td>
                  <td nowrap="nowrap" class="linha "><%=procs("Quantidade")%></td>
          </tr>
        <%
      procs.movenext
      wend
      procs.close
      set procs=nothing
      
      while c<5
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

  </td></tr></table>


          </td>
        </tr>
        <tr>
  <td>
  <table width="100%"><tr><td class="thead titulo">Dados do Contratante Executante</td></tr></table>
  </td>
        </tr>
      <tr class="third">
          <td>
          <table width="100%">
            <tbody>
                <tr class="third-line info">
                  <td width="15%" class="campo"><label>29 - Código na Operadora</label><%=CodigoNaOperadora%></td>
                  <td width="74%" class="campo"><label>30 - Nome do Contratado</label><%=NomeContratadoExecutante%></td>
          <td width="11%" class="campo"><label>31 - Código CNES</label><%=CodigoCNESExecutante%></td>
          </tr>
              </tbody>
            </table>
          </td>
        </tr>
      <tr>
  <td>
  <table width="100%"><tr><td class="thead titulo">Dados do Atendimento</td></tr></table>
  </td>
      </tr>
      <tr class="third">
          <td>
        <table width="47%">
          <tbody>
                    <tr class="third-line info">
                      <td width="15%" nowrap="nowrap" class="campo"><label>32 - Tipo de Atendimento</label><%
                      if len(TipoAtendimentoID)=1 then
                          response.Write(0)
                      end if%><%=TipoAtendimentoID%>
                      </td>
                      <td width="36%" nowrap="nowrap" class="campo"><label>33 - Indicação de Acidente  (acidente ou doen&ccedil;a relacionada) </label><%=IndicacaoAcidenteID%></td>
                      <td width="13%" nowrap="nowrap" class="campo"><label>34 - Tipo de Consulta</label><%=TipoConsultaID%></td>
                      <td width="36%" nowrap="nowrap" class="campo"><label>35 - Motivo do Encerramento do Atendimento</label><%=MotivoEncerramentoID%></td>
                    </tr>
          </tbody>
        </table>
      </td>
    </tr>
    <tr>
  <td>
  <table width="100%"><tr><td class="thead titulo">Dados da Execução / Procedimentos e Exames Realizados</td></tr></table>
  </td>
      </tr>
      <tr class="sixth">
      <td>




  <table width="100%"><tr><td>


          <table width="100%" class="campo">
            <tbody class="proc">
                <tr class="sixt-line border">
                  <td width="2%"></td>
                  <td width="7%" class="dataproc border-lad"><label>36 - Data</label></td>
                  <td width="8%" nowrap="nowrap" class="horainicial border-lad"><label>37 - Hora Inicial</label></td>
                  <td></td>
                  <td width="7%" nowrap="nowrap" class="horafinal border-lad"><label>38 - Hora Final</label></td>
                  <td width="6%" nowrap="nowrap" class="tabproc border-lad"><label>39 - Tabela</label></td>
                  <td width="15%" nowrap="nowrap" class="codproc border-lad"><label>40 - Código do Procedimento</label></td>
                  <td width="7%" nowrap="nowrap" class="descproc border-lad"><label>41 - Descrição</label></td>
                  <td width="5%" nowrap="nowrap" class="qtdaut border-lad"><label>42 - Qtde.</label></td>
                  <td width="4%" nowrap="nowrap" class="viaproc border-lad"><label>43 - Via</label></td>
                  <td width="5%" nowrap="nowrap" class="tecproc border-lad"><label>44 - Tec.</label></td>
                  <td width="12%" nowrap="nowrap" class="fatorproc border-lad"><label>45 - Fator Red. Acresc.</label></td>
                  <td width="11%" nowrap="nowrap" class="valorproc border-lad"><label>46 - Valor Unitário (R$)</label></td>
                  <td width="11%" nowrap="nowrap" class="valtotalproc "><label>47 - Valor Total (R$)</label></td>
                </tr>
      <%
      c=0
      set procs = db.execute("select * from tissprocedimentossadt where GuiaID="& treatvalzero(GuiaID) &" order by id")
      while not procs.eof
        if procs("ProfissionalID") <> 0 then
        c=c+1
        HoraInicio = procs("HoraInicio")
        if not isnull(HoraInicio) and isdate(HoraInicio) then HoraInicio=formatdatetime(HoraInicio,4) end if
        HoraFim = procs("HoraFim")
        if not isnull(HoraFim) and isdate(HoraFim) then HoraFim=formatdatetime(HoraFim,4) end if
        
        
        if not isnull(procs("Fator")) and not isnull(procs("ValorUnitario")) then
          ValorTotal = procs("ValorTotal")*procs("Fator")
        else
          ValorTotal = procs("ValorTotal")
        end if
        if isnull(ValorTotal) then
          ValorTotal = 0
        end if
        ValorTotal = ValorTotal* procs("Quantidade")
        Fator = procs("Fator")
        if Fator&""<>"" then
            Fator = formatnumber(Fator, 2)
        end if
        %>
                  <tr class="sixt-line border">
                      <td nowrap="nowrap" class="num border-lad"><%=c%> - </td>
                      <td class="linha"><%=procs("Data")%></td>
                    <td class="linha"><%=HoraInicio%></td>
                    <td>a</td>
                      <td class="linha"> <%=HoraFim%></td>
                      <td class="linha"><%=procs("TabelaID")%></td>
                      <td class="linha"><%=procs("CodigoProcedimento")%></td>
                      <td nowrap="nowrap" class="linha"><%=left(procs("Descricao"),43)%></td>
                      <td class="linha"><%=formatnumber(procs("Quantidade"),2)%></td>
                      <td class="linha"><%=procs("ViaID")%></td>
                      <td class="linha"><%=procs("TecnicaID")%></td>
                      <td class="linha"><%=Fator%></td>
                      <td class="linha"><% if OmitirValorGuia="" then response.write(formatnumber(procs("ValorUnitario"),2)) end if%></td>
                      <td class="linha"><% if OmitirValorGuia="" then response.write(formatnumber(procs("ValorTotal"),2)) end if%></td>
                  </tr>
        <%
        end if
        procs.movenext
        wend
        procs.close
        set procs=nothing
        
        while c<5
          c=c+1
          %>
                  <tr class="sixt-line border">
                      <td nowrap="nowrap"><%=c%> - </td>
                      <td class="linha"></td>
                      <td class="linha"></td>
                      <td>a</td>
                      <td class="linha"></td>
                      <td class="linha"></td>
                      <td class="linha"></td>
                      <td class="linha"></td>
                      <td class="linha"></td>
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



  </td></tr></table>





          </td>
        </tr>
        <tr>
  <td>
  <table width="100%"><tr><td class="thead titulo">Identificação do(s) Profissional(is) Executante(s)</td></tr></table>
  </td>
  </tr>

  <tr class="sixth">
          <td>

  <table width="100%"><tr><td>


          <table width="100%" class="campo">
            <tbody class="proc">
                <tr class="sixt-line border">
                  <td nowrap="nowrap" class="dataproc border-lad"><label>48 - Seq. Ref.</label></td>
                  <td nowrap="nowrap" class="horainicial border-lad"><label>49 - Grau Part.</label></td>
                  <td nowrap="nowrap" class="horafinal border-lad"><label>50 - Código na Operadora/CPF</label></td>
                  <td nowrap="nowrap" class="tabproc border-lad"><label>51 - Nome do Profissional</label></td>
                  <td nowrap="nowrap" class="codproc border-lad"><label>52 - Conselho Prof.</label></td>
                  <td nowrap="nowrap" class="descproc border-lad"><label>53 - Número do Conselho</label></td>
                  <td nowrap="nowrap" class="qtdaut border-lad"><label>54 - UF</label></td>
                  <td nowrap="nowrap" class="viaproc"><label>55 - Código CBO</label></td>
              </tr>
      <%
      c=0
      set profs = db.execute("select t.*, p.NomeProfissional, cons.TISS as ConselhoTISS, grau.codigo as grauparticipacao from tissprofissionaissadt as t left join cliniccentral.tissgrauparticipacao as grau on grau.id=t.grauparticipacaoid left join profissionais as p on t.ProfissionalID=p.id left join conselhosprofissionais as cons on cons.id=p.Conselho where t.GuiaID="& treatvalzero(GuiaID))
      while not profs.eof
        c=c+1
        GrauParticipacao=profs("grauparticipacao")
        'if GrauParticipacao=100 then
        '    GrauParticipacao="00"
        'end if
        UFConselho = profs("UFConselho")
              ConselhoTISS = profs("ConselhoTISS")
              if session("Banco")="clinic5856" or session("Banco")="clinic100000"  then
                  set UFSQL = db.execute("SELECT codigo FROM estados WHERE sigla='"&UFConselho&"'")
                  if not UFSQL.eof then
                      UFConselho = UFSQL("codigo")
                  end if
                  ConselhoTISS = zeroEsq(ConselhoTISS, 2)
              end if
        %>
              <tr class="sixt-line border">
                  <td nowrap="nowrap" class="linha"><%=profs("Sequencial")%></td>
                  <td nowrap="nowrap" class="linha"><%=GrauParticipacao%></td>
                  <td nowrap="nowrap" class="linha"><%=profs("CodigoNaOperadoraOuCPF")%></td>
                  <td nowrap="nowrap" class="linha"><%=profs("NomeProfissional")%></td>
                  <td nowrap="nowrap" class="linha"><%=ConselhoTISS%></td>
                  <td nowrap="nowrap" class="linha"><%=profs("DocumentoConselho")%></td>
                  <td nowrap="nowrap" class="linha"><%=UFConselho%></td>
                  <td nowrap="nowrap" class="linha"><%=profs("CodigoCBO")%></td>
        </tr>
            <%
      profs.movenext
      wend
      profs.close
      set profs=nothing
      
      while c<4
        c=c+1
        %>
  <tr class="sixt-line border">
      <td class="linha">&nbsp;</td>
      <td class="linha">&nbsp;</td>
      <td class="linha">&nbsp;</td>
      <td class="linha">&nbsp;</td>
      <td class="linha">&nbsp;</td>
      <td class="linha">&nbsp;</td>
      <td class="linha">&nbsp;</td>
      <td class="linha">&nbsp;</td>
  </tr>

        <%
      wend
      %>

              </tbody>
            </table>

  </td></tr></table>


          </td>
        </tr>
        <tr class="sixth">
          <td>


  <table width="100%"><tr><td>


          <table width="100%" class="campo">
            <tbody class="proc">
              <tr><td colspan="10">56 - Data de Realização de Procedimentos em Série &nbsp; 57 - Assinatura do Beneficiário</td></tr>
                  <tr class="sixt-line border">
                      <td width="13%" class="linha"><%=DataSerie01%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                      <td width="13%" class="linha"><%=DataSerie02%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                      <td width="13%" class="linha"><%=DataSerie03%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                      <td width="13%" class="linha"><%=DataSerie04%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                      <td width="13%" class="linha"><%=DataSerie05%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                  </tr>
                  <tr class="sixt-line border">
                      <td width="13%" class="linha"><%=DataSerie06%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                      <td width="13%" class="linha"><%=DataSerie07%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                      <td width="13%" class="linha"><%=DataSerie08%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                      <td width="13%" class="linha"><%=DataSerie09%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                      <td width="13%" class="linha"><%=DataSerie10%>&nbsp;</td>
                      <td width="7%" class="linha">&nbsp;</td>
                  </tr>
              </tbody>
            </table>

  </td></tr></table>


          </td>
        </tr>
  <tr>
  <td><table width="100%" border="0">
    <tbody>
      <tr>
        <td class="campo" bgcolor="#999"><label>58 - Observação / Justificativa</label>
          <%=Observacoes%></td>
      </tr>
    </tbody>
  </table></td>
  </tr>

  <tr class="fourth">
          <td>
          <table width="100%">
            <tbody>
                <tr class="fourth-line info">
  <td class="campo">
  <label>59 - Total de Procedimentos (R$)</label>
  <% if OmitirValorGuia="" and TipoExibicao<>"Pedido" then response.write(formatnumber(Procedimentos,2)) end if%>
  </td>
  <td class="campo">
  <label>60 - Total de Taxas e Aluguéis (R$)</label>
  <% if OmitirValorGuia="" and TipoExibicao<>"Pedido" then response.write(formatnumber(TaxasEAlugueis,2)) end if%>
  </td>
  <td class="campo">
  <label>61 - Total de Materiais (R$)</label>
  <% if OmitirValorGuia="" and TipoExibicao<>"Pedido" then response.write(formatnumber(Materiais,2)) end if%>
  </td>

  <td class="campo">
  <label>62 - Total de OPME (R$)</label>
  <% if OmitirValorGuia="" and TipoExibicao<>"Pedido" then response.write(formatnumber(OPME,2)) end if%>
  </td>
  <td class="campo">
  <label>63 - Total de Medicamentos (R$)</label>
  <% if OmitirValorGuia="" and TipoExibicao<>"Pedido" then response.write(formatnumber(Medicamentos,2)) end if%>
  </td>
  <td class="campo">
  <label>64 - Total de Gases Medicinais (R$)</label>
  <% if OmitirValorGuia="" and TipoExibicao<>"Pedido" then response.write(formatnumber(GasesMedicinais,2)) end if%>
  </td>

  <td class="campo">
  <label>65 - Total Geral (R$)</label>
  <% if OmitirValorGuia="" and TipoExibicao<>"Pedido" then response.write(formatnumber(TotalGeral,2)) end if%>
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
  <td width="35%" class="campo">
  <label>66 - Assinatura do Responsável pela Autorização</label>
  &nbsp;
  </td>
  <td width="33%" class="campo">
  <label>67 - Assinatura do Beneficiário ou Responsável</label>
  &nbsp;
  </td>
  <td width="32%" class="campo">
  <label>68 - Assinatura do Contratado</label>
  &nbsp;
  </td>



  </tr>
              </tbody>
            </table>
          </td>
        </tr>
    </tbody>
    </table>
  </div>
<%
  if isnull(TotalGeral) then TotalGeral=0 end if
      set vcaAnexa = db.execute("select * from tissguiaanexa where GuiaID="&guia("id"))

      if not vcaAnexa.EOF then
        if AutoPrintAnexa&""="1" then
            %>
          <!--#include file="GuiaAnexa.asp"-->
            <%
        else
        %>
        <script>
        window.parent.anexa();
        </script>
        <div class="imprimirGuia">
            <button type="button" onclick="location.href='printGuiaAnexa.asp?I=<%= guia("id") %>'">IMPRIMIR GUIA ANEXA</button>
        </div>
        <%
        end if
      end if
    
    
GuiaSQL.movenext
wend
GuiaSQL.close
set GuiaSQL=nothing
%>
</body>
</html>
<script type="text/javascript">
  window.print();
	window.addEventListener("afterprint", function(event) { window.close(); });
	window.onafterprint();
<%
if TipoExibicao="Pedido" then
    %>
    window.opener.pront('timeline.asp?PacienteID=<%= PacienteID %>&Tipo=|Pedido|');
    <%
End If
%>
</script>
