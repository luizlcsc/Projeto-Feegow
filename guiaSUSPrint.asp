<!--#include file="connect.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" type="text/css" media="all" href="assets/css/tiss.css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Guia SUS</title>
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

    input, textarea{
        border: 0;
    }
}

body, input{
    font-size: 10px;
}
.black{
    font-size: 12px;
}
label{
    font-weight: 600;
}
table, td{border:1px solid #ccc; padding:2px; text-align:center; vertical-align: middle; font-family: sans-serif;}
.black{background: rgba(50,50,50,1.00); color:#fff; text-align:center;}
input[type="text"] {width:100%; }
label{display:block;  text-align:left; margin: 0 5px}
textarea{width:100%; }
.nob{border:0}
.nob td{ border: 0}
.inline{display:inline-block; max-width:40%}
.small{width:20%}


</style>


<%

'on error resume next

set conf = db.execute("select * from sys_config")
OmitirValorGuia = conf("OmitirValorGuia")

set guia = db.execute("select g.*, cons.TISS as ConselhoProfissionalSolicitanteTISS from tissguiasadt as g left join conselhosprofissionais as cons on cons.id=g.ConselhoProfissionalSolicitanteID where g.id="& treatvalzero(req("I")))
if not guia.eof then
	set conv = db.execute("select * from convenios where id="&guia("ConvenioID"))
	if not conv.EOF then
		NomeConvenio = ucase(conv("NomeConvenio"))
		Foto = conv("Foto")
	end if
	set pac = db.execute("select * from pacientes where id="&guia("PacienteID"))
	if not pac.eof then
		NomePaciente = ucase(pac("NomePaciente"))
        PacienteID = pac("id")
        NomePaciente = pac("NomePaciente")
        Sexo = pac("Sexo")
        Nascimento = pac("Nascimento")
        PacienteTelefone = pac("Cel1")
        PacienteCidade = pac("Cidade")
        PacienteEstado = pac("Estado")
        PacienteEndereco = pac("Endereco")
        PacienteCep = pac("Cep")
        CNS = pac("CNS")
        NumeroCarteira = pac("Matricula1")
        ValidadeCarteira = pac("Validade1")
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
		ConselhoProfissionalSolicitante = ProfissionalSolicitante("DocumentoConselho")
		CPFProfissionalSolicitante = ProfissionalSolicitante("CPF")
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
	if CNS<>"" then
	    CNS=guia("CNS")
	end if
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
	if isnull(TotalGeral) then TotalGeral=0 end if

	set vcaAnexa = db.execute("select * from tissguiaanexa where GuiaID="&guia("id"))
	if not vcaAnexa.EOF then
		%>
		<script>
		window.parent.anexa();
		</script>
    <div class="imprimirGuia">
        <button type="button" onclick="location.href='GuiaAnexa.asp?I=<%= guia("id") %>'">IMPRIMIR GUIA ANEXA</button>
    </div>
		<%
	end if
end if
%>


<body>
<div class="main">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tbody>
      <tr>
        <td><img src="images/sus.png" style="max-height: 50px"></td>
        <td colspan="2">LAUDO PARA AUTORIZAÇÃO DE PROCEDIMENTOS AMBULATORIAL</td>

      </tr>
      <tr>
        <td colspan="3" class="black">IDENTIFICAÇÃO DO ESTABELECIMENTO DE SAÚDE(SOLICITANTE)</td>

      </tr>  <tr>
  	  <td colspan="2"><label>1- NOME DO ESTABELECIMENTO DE SAÚDE SOLICITANTE</label>
       <INPUT type="TEXT" class="full" value="
<%=NomeContratadoSolicitante%>">
       </td>
        <td><label>2-CNES</label>
        <INPUT TYPE="TEXT" value="<%=CodigoCNESExecutante%>">
        </td>
      </tr>
       <tr>
  	  <td colspan="3" class="black">IDENTIFICAÇÃO DO PACIENTE
       </td>

      </tr>


      <tr>
        <td COLSPAN="2">

        <LABEL> 3- NOME DO PACIENTE</LABEL>
        <INPUT TYPE="TEXT" value="<%=NomePaciente%>">
        </td>

        <td><LABEL>4- Nº DO PRONTUÁRIO</LABEL>
        <INPUT TYPE="TEXT" value="<%=PacienteID%>">

        </td>
      </tr>
      <tr>
        <td><LABEL>5- CARTÃO NACIONAL DE SAÚDE (CNS)</LABEL>

        <INPUT TYPE="TEXT" value="<%=CNS%>">
        </td>
        <td>
  	<LABEL>6 - DATA DE NASCIMENTO
  		</LABEL>
  		<INPUT type="text" value="<%=Nascimento%>">


       </td>
        <td>
        <LABEL>7 - SEXO</LABEL>
        <LABEL FOR="masc" class="inline">Masc<INPUT type="CHECKBOX" name="masc" <% if Sexo="1" then %> checked <%end if%>></LABEL>
        <LABEL FOR="fem" class="inline">Fem<INPUT type="CHECKBOX" name="fem" <% if Sexo="2" then %> checked <%end if%>></LABEL>


        </td>
      </tr>
      <tr>
        <td COLSPAN="2">
  	<label>8- NOME DA MÃE OU RESPONSÁVEL</label>
      	<INPUT type="TEXT">
       </td>
        <td><LABEL> 9- TELEFONE DE CONTATO</LABEL>
        <INPUT type="TEXT" value="<%=PacienteTelefone%>">
        </td>

      </tr>
      <tr>
        <td COLSPAN="3">

        <LABEL>10- ENDEREÇO (RUA, Nº, BAIRRO)</LABEL>
        <INPUT TYPE="TEXT"  value="<%=PacienteEndereco%>">
        </td>

      </tr>
      <tr>
        <td><label>11- Município de residência</label>
        <input type="text" value="<%=PacienteCidade%>">
        </td>
        <td>
        	<label>12- Cod. IBGE Município</label>
        	  <input type="text" value="<%=PacienteIBGE%>">

        </td>
        <td>
  		<table  width="100%" border="0" cellspacing="0" cellpadding="0" class="nob">
  			<tr>
  				<td>
  					<label> 13- UF</label>
  					<input type="text" value="<%=PacienteEstado%>">

  				</td>


  				<td>
  						<label> 14- CEP</label>
  						<input type="text" value="<%=PacienteCep%>">


  				</td>
  			</tr>

  		</table>

     </td>
      </tr>
      <tr>
        <td colspan="3" class="black">PROCEDIMENTO SOLICITADO</td>
        <%
        set ProcedimentoSQL = db.execute("SELECT * FROM tissprocedimentossadt WHERE GuiaID="&req("I"))
        %>
      </tr>
      <tr>

        <td><label>15 - CÓDIGO DE PROCEDIMENTO PRINCIPAL</label>
        <INPUT type="TEXT" value="<%=ProcedimentoSQL("CodigoProcedimento")%>"></td>
        <td><label>16 - NOME DE PROCEDIMENTO PRINCIPAL</label>
        <INPUT type="TEXT" value="<%=ProcedimentoSQL("Descricao")%>"></td>
        <td class="small"><label>17 - QTDE</label>
        <INPUT type="TEXT" value="<%=ProcedimentoSQL("Quantidade")%>"></td>
      </tr>
      <tr>
   <td colspan="3" class="black">PROCEDIMENTO(S) SECUNDÁRIOS</td>
      </tr>
      <tr>
         <td><label>18 - CÓDIGO DE PROCEDIMENTO PRINCIPAL</label>
        <INPUT type="TEXT"></td>
        <td><label>19 - NOME DE PROCEDIMENTO PRINCIPAL</label>
        <INPUT type="TEXT"></td>
        <td class="small"><label>20 - QTDE</label>
        <INPUT type="TEXT"></td>
      </tr>
          <tr>
         <td><label>21 - CÓDIGO DE PROCEDIMENTO PRINCIPAL</label>         <INPUT type="TEXT"></td>
        <td><label>22 - NOME DE PROCEDIMENTO PRINCIPAL</label>        <INPUT type="TEXT"></td>
        <td class="small"><label>23 - QTDE</label>        <INPUT type="TEXT"></td>
      </tr>
          <tr>
         <td><label>24 - CÓDIGO DE PROCEDIMENTO PRINCIPAL</label>         <INPUT type="TEXT"></td>
        <td><label>25 - NOME DE PROCEDIMENTO PRINCIPAL</label>        <INPUT type="TEXT"></td>
        <td class="small"><label>26 - QTDE</label>        <INPUT type="TEXT"></td>
      </tr>
          <tr>
         <td><label>27 - CÓDIGO DE PROCEDIMENTO PRINCIPAL</label>         <INPUT type="TEXT"></td>
        <td><label>28 - NOME DE PROCEDIMENTO PRINCIPAL</label>        <INPUT type="TEXT"></td>
        <td class="small"><label>29 - QTDE</label>        <INPUT type="TEXT"></td>
      </tr>
          <tr>
         <td><label>30 - CÓDIGO DE PROCEDIMENTO PRINCIPAL</label>         <INPUT type="TEXT"></td>
        <td><label>31 - NOME DE PROCEDIMENTO PRINCIPAL</label>        <INPUT type="TEXT"></td>
        <td class="small"><label>32 - QTDE</label>        <INPUT type="TEXT"></td>
      </tr>

          <tr>
   <td colspan="3" class="black">JUSTIFICATIVA DOS PROCEDIMENTO(S) SOLICITADOS</td>
      </tr>
              <tr>
         <td><label>33 - DESCRIÇÃO DO DIAGNÓSTICO</label>         <INPUT type="TEXT"></td>
        <td colspan="2">

        <TABLE  width="100%" border="0" cellspacing="0" cellpadding="0" class="nob">
        	<TR>

        		<TD>
        			<label>34 - CID 10 PRINCIPAL</label>         <INPUT type="TEXT">

        		</TD>
        			<TD>
        			<label>35 - CID 10 SECUNDÁRIO</label>         <INPUT type="TEXT">

        		</TD>
        			<TD>
        			<label>36 - CID 10 CAUSAS ASSOCIADAS</label>         <INPUT type="TEXT">

        		</TD>
        	</TR>

        </TABLE>


        </td>

      </tr>

             <tr>
   <td colspan="3"><LABEL>37 - OBSERVAÇÕES</LABEL>
     <TEXTAREA  ROWS="1"><%=Observacoes%></TEXTAREA>

     </td>
      </tr>

             <tr>
   <td colspan="3" class="black">SOLICITAÇÃO</td>
      </tr>
      <TR>

      	<TD colspan="2">

      		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="nob">
      			<TR>
      				<TD><label>38 - NOME DO PROFISSIONAL SOLICITANTE</label>         <INPUT type="TEXT" value="<%=NomeProfissionalSolicitante%>"></TD>
      				<TD><label>39 - CID 10 CAUSAS ASSOCIADAS</label>         <INPUT type="TEXT"></TD>
      			</TR>

      			<tr>
      				<td >
      					<label>40 - documento</label>



      				 <label class="inline">
      				        <input type="checkbox" name="DOCUMENTO" value="CNS" id="DOCUMENTO_0">
      				        CNS</label>
    				     <label class="inline">
      				        <input type="checkbox" name="DOCUMENTO" value="CPF" id="DOCUMENTO_1" checked>
      				        CPF</label>


     				      </td>
      					<td ><label>41 - Nº DOCUMENTO (CNS/CPF) DO PROFISSIONAL SOLICITANTE</label>    					  <INPUT type="TEXT" value="<%=CPFProfissionalSolicitante%>">

     				  </td>
      			</tr>
      		</table>

      	</TD>

      		<TD rowspan="2" >
      		<label>42 - ASSINATURA E CARIMBO (Nº REGISTRO DO CONSELHO)</label>    					  <TEXTAREA><%=DocumentoProfissionalSolicitante%></TEXTAREA>


      	</TD>

      </TR>

                <tr>
   <td colspan="3" class="black">AUTORIZAÇÃO</td>
      </tr>

      <TR>
      	<TD>

      		<label>43 - NOME DO PROFISSIONAL SOLICITANTE</label>
      		<INPUT type="TEXT" >
      	</TD>
      	<TD>
      		<label>44 - COD. ORGÃO EMISSOR</label>
      		<INPUT type="TEXT">

      	</TD>
      	<TD rowspan="2">
      		<label>49 - Nº DA AUTORIZAÇÃO (APAC)</label>
  			<textarea></textarea>
      	</TD>

      </TR>
      <tr>
      	<td>

      				<label>45 - DOCUMENTO</label>
      			 <label class="inline">
      				        <input type="checkbox" name="DOCUMENTO" value="CNS" id="DOCUMENTO_0">
      				        CNS</label>
    				     <label class="inline">
      				        <input type="checkbox" name="DOCUMENTO" value="CPF" id="DOCUMENTO_1">
      				        CPF</label>
      	</td>
      	<td>
      				<label>46 - Nº DOCUMENTO (CNS/CPF) DO PROFISSIONAL AUTORIZADOR</label>
      		<INPUT type="TEXT">
      	</td>


      </tr>
      <TR>

      	<TD>
      		<label>47 - DATA DA AUTORIZAÇÃO</label>
      		<INPUT type="TEXT" value="<%=DataAutorizacao%>">
      	</TD>
      	<TD>
      	<label>48 - ASSINATURA E CARIMBO (Nº DO REGISTRO DO CONSELHO)</label>
      		<INPUT type="TEXT">

      	</TD>
      	<TD>

      		<label>50 - PERÍODO DE VALIDADE DA APAC</label>
      		<INPUT type="DATE" class="inline"> a <INPUT type="DATE" class="inline">

      	</TD>

      </TR>
                    <tr>
   <td colspan="3" class="black">IDENTIFICAÇÃO DO ESTABELECIMENTO DE SAÚDE (EXECUTANTE)</td>
      </tr>
      <TR>

      	<TD colspan="2">
      			<label>51 - NOME FANTASIA DO ESTABELECIMENTO DE SAÚDE EXECUTANTE</label>
      		<INPUT type="TEXT">
      	</TD>
      	<TD>
      			<label>52 - CNES</label>
      		<INPUT type="TEXT">

      	</TD>

      </TR>
    </tbody>
  </table>

</div>
</body>
</html>
<script type="text/javascript">
    print()
</script>