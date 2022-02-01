<!--#include file="connect.asp"-->
<%
 set getImpressos = db.execute("select * from Impressos")
MarcaDagua = ""
if not getImpressos.EOF then
    Cabecalho = getImpressos("Cabecalho")

    Rodape = replaceTags(getImpressos("Rodape"), 0, session("UserID"), session("UnidadeID"))

    Prescricoes = getImpressos("Prescricoes")
    set timb = db.execute("select * from papeltimbrado where sysActive=1 AND profissionais like '%|ALL|%'")
    if not timb.eof then
        Cabecalho = timb("Cabecalho")
        Margens = "padding-left:"&timb("mLeft")&"px;padding-top:"&timb("mTop")&"px;padding-bottom:"&timb("mBottom")&"px;padding-right:"&timb("mRight")&"px;"
        if session("Banco") = "clinic1805" or session("Banco") = "clinic100000" or session("Banco") = "clinic2410" or session("Banco") = "clinic5445" then
            MarcaDagua = "background-image: url('https://clinic.feegow.com.br/uploads/"&timb("MarcaDagua")&"')"
        end if
        Rodape = replaceTags(timb("Rodape"), 0, session("UserID"), session("UnidadeID"))
    end if

    ProfissionalID = req("ProfissionalID")

    if lcase(session("table"))="profissionais" and (ProfissionalID="" or ProfissionalID="0") then
        ProfissionalID = session("idInTable")
    end if

    set timb = db.execute("select * from papeltimbrado where sysActive=1 AND (profissionais like '%|"&ProfissionalID&"|%' or coalesce(profissionais,'')='' or profissionais like '&|ALL|&' ) ORDER BY profissionais like '%|"&ProfissionalID&"|%' desc")
    if not timb.eof then
        Cabecalho = timb("Cabecalho")
        Rodape = timb("Rodape")
    end if
end if

Cabecalho = unscapeOutput(Cabecalho)
Rodape = unscapeOutput(Rodape)


set pac = db.execute("select * from pacientes where id="&req("PacienteID"))

if pac("Sexo")=1 then
	Sexo="MASCULINO"
elseif pac("Sexo")=2 then
	Sexo="Feminino"
end if
if pac("Altura")<>"" and isnumeric(pac("Altura")) then
	Altura = pac("Altura")&"m"
end if
if pac("Peso")<>"" and isnumeric(pac("Peso")) then
	Peso = pac("Peso")&"kg"
end if
Endereco = pac("Endereco")
if pac("Numero")<>"" then
	Endereco = Endereco&", "&pac("Numero")
end if
if pac("Complemento")<>"" then
	Endereco = Endereco&", "&pac("Complemento")
end if

if pac("Tel1")<>"" and pac("Tel2")<>"" then
	Separador = " / "
end if
Telefone = pac("Tel1")&Separador&pac("Tel2")

if pac("Cel1")<>"" and pac("Cel2")<>"" then
	Separador = " / "
end if
Celular = pac("Cel1")&Separador&pac("Cel2")

if pac("Email1")<>"" and pac("Email2")<>"" then
	Separador = " / "
end if
Email = pac("Email1")&Separador&pac("Email2")

set estciv = db.execute("select * from estadocivil where id like '"&pac("EstadoCivil")&"'")
if not estciv.eof then
	EstadoCivil = estciv("EstadoCivil")
end if

set esc = db.execute("select * from grauinstrucao where id like '"&pac("GrauInstrucao")&"'")
if not esc.eof then
	Escolaridade = esc("GrauInstrucao")
end if

set org = db.execute("select * from origens where id like '"&pac("Origem")&"'")
if not org.eof then
	Origem = org("Origem")
	if pac("Origem")=1 and pac("IndicadoPor")<>"" then
		Origem = Origem&": "&pac("IndicadoPor")
	end if
end if
%>



		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />

        <link href="assets/skin/default_skin/css/fgw.css" rel="stylesheet" type="text/css" />

	    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
		<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
        <script src="ckeditornew/adapters/jquery.js"></script>
        <style type="text/css">
		@media print {
		  .hidden-print {
			display: none !important;
		  }
		}
		body{
        background-color: #fff!important;
        }
        #timeline .timeline-icon{
            border-radius: 0!important;
            background: transparent!important;
            box-shadow: none!important;
        }
        .panel-controls{
            display: none!important;
        }
        #timeline{
            text-align: left;
        }
        .timeline-add{
            display: none;
        }

        @page {
          size: A4;
          margin: 5%;
          padding: 0 0 10%;
        }

		</style>
<div id="ImpressaoConteudo" style="page-break-after: always;">
<div class="hidden-print" style="position:fixed; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px;">
    <button type="button" class="btn btn-primary" onClick="PrintFicha()"><i class="far fa-print" style="color:#fff"></i> IMPRIMIR</button>
</div>

<table width="100%" height="100%">
<tr><td><%= Cabecalho %></td></tr>
<tr><td valign="top" height="99%">
        <h3 align="center"><strong>Ficha do Paciente</strong></h3>
        <br>
        <table width="100%" class="table table-condensed table-bordered">
          <tr>
            <td width="25%" valign="top" scope="row">Nome<br />
            <strong><%= ucase(pac("NomePaciente")) %></strong></td>
            <td width="25%" valign="top">Sexo<br />
              <strong><%= Sexo %></strong></td>
            <td width="25%" valign="top">Data de Cadastro<br />
              <strong><%= pac("sysDate") %></strong></td>
            <td width="25%" valign="top">Prontu&aacute;rio<br />
              <strong>			<%
              if getConfig("AlterarNumeroProntuario") = 1 then
              'if session("banco")="clinic1612" or session("banco")="clinic5868" or session("banco")="clinic3859" then
				Prontuario = pac("idImportado")
				else
						Prontuario = pac("id")
					end if
					response.Write(Prontuario)
				%>
</strong></td>
          </tr>
          <tr>
            <td valign="top" scope="row">Nascimento<br />
            <strong><%= pac("Nascimento") %> <%if not isnull(pac("Nascimento")) then%>   -  <%= idade(pac("Nascimento"))%><%end if%></strong></td>
            <td valign="top">Altura<br />
            <strong><%= Altura %></strong></td>
            <td valign="top">Peso<br />
            <strong><%= Peso %></strong></td>
            <td valign="top">IMC<br />
              <strong><%= pac("IMC") %></strong></td>
          </tr>
          <tr>
            <td colspan="3" valign="top" scope="row">Endere&ccedil;o<br>
            <strong><%= ucase(Endereco) %></strong></td>
            <td valign="top">Bairro<br>
            <strong><%= ucase(pac("Bairro")) %></strong></td>
          </tr>
          <tr>
            <td valign="top" scope="row">Cidade<br>
            <strong><%= ucase(pac("Cidade")) %></strong></td>
            <td valign="top" scope="row">UF<br>
              <strong><%= ucase(pac("Estado")) %></strong></td>
            <td valign="top">Pa&iacute;s<br>
            <strong>BRASIL</strong></td>
            <td valign="top">Cep<br>
            <strong><%= pac("Cep") %></strong></td>
          </tr>
          <tr>
            <td valign="top" scope="row">Telefone<br>
            <strong><%= Telefone %></strong></td>
            <td valign="top">Celular<br>
              <strong><%= Celular %></strong></td>
            <td colspan="2" valign="top">E-mail<br>
              <strong><%= Email%></strong></td>
          </tr>
          <tr>
            <td valign="top" scope="row">RG<br>
              <strong><%= ucase(pac("documento")) %></strong></td>
            <td valign="top">CPF<br>
              <strong><%= ucase(pac("cpf")) %></strong></td>
            <td valign="top">Estado Civil<br>
              <strong><%= ucase(EstadoCivil) %></strong></td>
            <td valign="top">Naturalidade<br>
            <strong><%= ucase(pac("Naturalidade")) %></strong></td>
          </tr>
          <tr>
            <td valign="top" scope="row">Escolaridade<br>
            <strong><%= ucase(Escolaridade) %></strong></td>
            <td valign="top">Profiss&atilde;o<br>
            <strong><%= ucase(pac("Profissao")) %></strong></td>
            <td colspan="2" valign="top">Origem<br>
            <strong><%= ucase(Origem) %></strong></td>
          </tr>
			<%
			if not isnull(pac("ConvenioID1")) and pac("ConvenioID1")<>0 then
			%>
          <tr>
            <td colspan="4" valign="top" scope="row">
                <table width="100%" class="table table-condensed">
                  <tr>
                      <td scope="row">Conv&ecirc;nio</td>
                      <td>Plano</td>
                      <td>Matr&iacute;cula / Carteirinha</td>
                      <td>Validade</td>
                      <td>Titular</td>
                  </tr>
                  <%
				  	set pConv = db.execute("select id, NomeConvenio from convenios where id="&pac("ConvenioID1"))
					if not pConv.eof then
						NomeConvenio = pConv("NomeConvenio")
						set pPlan = db.execute("select * from conveniosplanos where id like '"&pac("PlanoID1")&"'")
						if not pPlan.EOF then
							NomePlano = pPlan("NomePlano")
						else
							NomePlano = ""
						end if
					else
						NomeConvenio = ""
						NomePlano = ""
					end if
				  %>
                <tr>
                      <td scope="row"><strong><%= ucase(NomeConvenio&"") %></strong></td>
                      <td><strong><%=ucase(NomePlano&" ")%></strong></td>
                      <td><strong><%=ucase(pac("Matricula1"))%></strong></td>
                      <td><strong><%=pac("Validade1")%></strong></td>
                      <td><strong><%=ucase(pac("Titular1"))%></strong></td>
                    </tr>
                </table>
            </td>
          </tr>
            <% End If
			set ret = db.execute("select * from pacientesretornos where not isnull(Data) and PacienteID="&pac("id"))
			set rel = db.execute("select * from pacientesrelativos where not Nome like '' and PacienteID="&pac("id"))
			if not ret.eof or not rel.eof then
				if ret.eof or rel.eof then
					colspan = "4"
				else
					colspan = "2"
				end if
			%>
          <tr>
          	<%
			if not ret.EOF then
			%>
            <td colspan="<%=colspan%>" valign="top" scope="row">Programa&ccedil;&atilde;o de Retorno
              <table width="100%" class="table table-condensed">
                <tr>
                  <td scope="row">Data</td>
                  <td>Motivo</td>
                </tr>
                <%
				while not ret.eof
				%>
                <tr>
                  <td scope="row"><strong><%= ret("Data")%></strong></td>
                  <td><strong><%=ucase(ret("Motivo"))%></strong></td>
                </tr>
                <%
				ret.movenext
				wend
				ret.close
				set ret=nothing
				%>
            </table></td>
            <%end if
			if not rel.eof then
			%>
            <td colspan="<%=colspan%>" valign="top" scope="row">Pessoas Relacionadas
              <table width="100%" class="table table-condensed">
                <tr>
                  <td scope="row">Nome</td>
                  <td>Relacionamento</td>
                </tr>
                <%
				while not rel.eof
				%>
                <tr>
                  <td scope="row"><strong><%=ucase(rel("Nome"))%></strong></td>
                  <td><strong><%=ucase(rel("Relacionamento"))%></strong></td>
                </tr>
                <%
				rel.movenext
				wend
				rel.close
				set rel=nothing
				%>
            </table></td>
            <%end if%>
          </tr>
          <%
		  end if
		  %>
          <tr>
            <td colspan="2" valign="top" scope="row">Observa&ccedil;&otilde;es<br>
              <strong><%= ucase(pac("Observacoes")) %></strong></td>
            <td colspan="2" valign="top" scope="row">Pend&ecirc;ncias<br>
              <strong><%= ucase(pac("Pendencias")) %></strong></td>
          </tr>
        </table>
        <br />
        <p align="center"><strong><%=date()%></strong></p>
</td></tr>
<tr><td><%= Rodape %></td></tr>
</table>


<%

Opts = req("Opts")
if Opts<>"" then
%>

<div id="ConteudoAdicional">
<div id="ConteudoTimeline" style="page-break-after: always;"></div>
<div id="ConteudoLogs" style="page-break-after: always;"></div>
</div>

<script >
    var DataDe = "<%=req("DataDe")%>";
    var DataAte = "<%=req("DataAte")%>";

    $.get("timeline.asp?ComEstilo=S&SemLimit=S&PacienteID=<%=req("PacienteID")%>&Tipo=<%=Opts%>&DataDe="+DataDe+"&DataAte="+DataAte, function(data) {
        setTimeout(function() {
          if(data.indexOf("class=\"timeline-item") > -1){
              $("#ConteudoTimeline").html(data);
          }
        }, 100);
    });
</script>
<%
end if


%>
</div>
<script >


function PrintFicha() {
        // $.get("SalvaReciboImpressao.asp", data);
        print();
}

</script>