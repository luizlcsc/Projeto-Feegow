<%
response.Charset="utf-8"
%>
<!--#include file="connect.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->

		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		
        <link href="assets/css/coreBoot.css" rel="stylesheet" type="text/css" />

	    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
		<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
        <script src="ckeditornew/adapters/jquery.js"></script>
        <style type="text/css">
		@media print {
		  .hidden-print {
			display: none !important;
		  }
		}
		</style>




        
        <div class="hidden-print" style="position:fixed; color:#FFF!important; right:14px; z-index:10000000; text-decoration:none; padding:5px;">
            <button type="button" class="btn btn-primary" onClick="print()"><i class="far fa-print" style="color:#fff"></i> IMPRIMIR</button>
        </div>
<div id="areaImpressao">
<%
set reg=db.execute("select * from pacientesatestados where id="&req("AtestadoID"))
if not reg.EOF then
	set user = db.execute("select * from sys_users where id="&session("User"))
	if not user.EOF then
		if lcase(user("Table"))="profissionais" then
			set pro = db.execute("select * from profissionais where id="&user("idInTable"))
			if not pro.EOF then
				set Trat = db.execute("select * from tratamento where id = '"&pro("TratamentoID")&"'")
				if not Trat.eof then
					Tratamento = trat("Tratamento")
				end if
				NomeProfissional = Tratamento&" "&pro("NomeProfissional")
				set codigoConselho = db.execute("select * from conselhosprofissionais where id = '"&pro("Conselho")&"'")
				if not codigoConselho.eof then
					DocumentoProfissional = codigoConselho("codigo")&": "&pro("DocumentoConselho")&"-"&pro("UFConselho")
				end if
			end if
		end if
	end if
	DDMMAAAA = date()
	Extenso = formatdatetime(date(), 1)
	Hora = time()

	set cli = db.execute("select * from sys_financialcompanyunits order by id")
	if not cli.eof then
		'*****************>>>>>>>>>> depois colocar um select pra mudar a unidade
		EnderecoClinica = cli("Endereco")&", "&cli("Numero")&" "&cli("Complemento")
		CidadeClinica = cli("Cidade")
		EstadoClinica = cli("Estado")
		Tel1Clinica = cli("Tel1")
		Tel2Clinica = cli("Tel2")
	end if

	set pac = db.execute("select * from pacientes where id="&reg("PacienteID"))
	if not pac.EOF then
		NomePaciente = pac("NomePaciente")
		EnderecoPaciente = pac("Endereco")&", "&pac("Numero")&" "&pac("Complemento")
		BairroPaciente = pac("Bairro")
		CidadePaciente = pac("Cidade")
		EstadoPaciente = pac("Estado")
		EmailPaciente = pac("Email1")
		TelefonePaciente = pac("Tel1")
		NomeSocial = pac("NomeSocial")
		if isDate(pac("Nascimento")) then
			IdadePaciente = Idade(pac("Nascimento"))
		end if
	end if
end if

        set getImpressos = db.execute("select * from Impressos")
        if not getImpressos.EOF then
            Cabecalho = getImpressos("Cabecalho")
            Rodape = getImpressos("Rodape")
            Atestados = getImpressos("Atestados")
            Unidade = session("UnidadeID")
            set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND (pt.profissionais like '%|ALL|%' OR pt.profissionais like '%|"&session("idInTable")&"|%')  AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
            if not timb.eof then
                Cabecalho = timb("Cabecalho")
                Margens = "padding-left:"&timb("mLeft")&"px;padding-top:"&timb("mTop")&"px;padding-bottom:"&timb("mBottom")&"px;padding-right:"&timb("mRight")&"px;"
                if session("Banco") = "clinic1805" or session("Banco") = "clinic100000" or session("Banco") = "clinic2410" or session("Banco") = "clinic5445" or session("Banco") = "clinic6017" or session("Banco") = "clinic5873" or session("Banco") = "clinic5958" or session("Banco") = "clinic6081" then
                'if timb("MarcaDagua")<>"" or not isnull(timb("MarcaDagua"))  then
                    MarcaDagua = "background-image: url('https://clinic.feegow.com.br/uploads/"&replace(session("Banco"), "clinic", "")&"/Arquivos/"&timb("MarcaDagua")&"')"
                end if
                   Cabecalho = timb("Cabecalho")
                   Rodape = timb("Rodape")

                    if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
                    if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
                    if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
                    if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

            end if
            if lcase(session("table"))="profissionais" then
                set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND pt.profissionais like '%|"&session("idInTable")&"|%'  AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
                if not timb.eof then
                   Cabecalho = timb("Cabecalho")
                   Rodape = timb("Rodape")

                    if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
                    if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
                    if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
                    if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

                end if
            end if
        end if
        
        Cabecalho = unscapeOutput(Cabecalho)
        Rodape = unscapeOutput(Rodape)


'strVarPac = "[Paciente.Nome]|^[Paciente.NomeSocial]|^[Paciente.Idade]|^[Paciente.Endereco]|^[Paciente.Bairro]|^[Paciente.Cidade]|^[Paciente.Estado]|^[Paciente.Email]|^[Paciente.Telefone]|^[Data.DDMMAAAA]|^[Data.Extenso]|^[Sistema.Hora]"
strVarPac = "[Paciente.Nome]|^"&NomeSocial&"|^[Paciente.Idade]|^[Paciente.CPF]|^[Paciente.Prontuario]|^[Paciente.Endereco]|^[Paciente.Numero]|^[Paciente.Cidade]|^[Paciente.Estado]|^[Paciente.Cep]|^[Paciente.Nascimento]|^[Paciente.Sexo]|^[Paciente.Cor]|^[Paciente.Altura]|^[Paciente.Peso]|^[Paciente.IMC]|^[Paciente.Religiao]|^[Paciente.Tel1]|^[Paciente.Tel2]|^[Paciente.Cel1]|^[Paciente.Cel2]|^[Paciente.Email1]|^[Paciente.Email2]|^[Paciente.Profissao]|^[Paciente.Documento]|^[Paciente.EstadoCivil]|^[Paciente.Origem]|^[Paciente.IndicadoPor]|^[Paciente.Observacoes]|^[Paciente.Convenio]|^[Paciente.Matricula]|^[Paciente.Validade]"
strVarSis = "[Data.DDMMAAAA]|^[Data.Extenso]|^[Sistema.Hora]"
strVarPro = "[Profissional.Nome]|^[Profissional.Documento]"

'strValPac = NomePaciente&"|^"&IdadePaciente&"|^"&EnderecoPaciente&"|^"&BairroPaciente&"|^"&CidadePaciente&"|^"&EstadoPaciente&"|^"&EmailPaciente&"|^"&TelefonePaciente&"|^"&DDMMAAAA&"|^"&Extenso&"|^"&Hora
strValPac = NomePaciente&"|^"&IdadePaciente&"|^"&CPFPaciente&"|^"&ProntuarioPaciente&"|^"&EnderecoPaciente&"|^"&NumeroPaciente&"|^"&CidadePaciente&"|^"&EstadoPaciente&"|^"&CepPaciente&"|^"&Nascimento&"|^"&SexoPaciente&"|^"&CorPaciente&"|^"&AlturaPaciente&"|^"&PesoPaciente&"|^"&IMCPaciente&"|^"&ReligiaoPaciente&"|^"&Tel1Paciente&"|^"&Tel2Paciente&"|^"&Cel1Paciente&"|^"&Cel2Paciente&"|^"&Email1Paciente&"|^"&Email2Paciente&"|^"&ProfissaoPaciente&"|^"&DocumentoPaciente&"|^"&EstadoCivilPaciente&"|^"&OrigemPaciente&"|^"&IndicadoPorPaciente&"|^"&ObservacoesPaciente&"|^"&ConvenioPaciente&"|^"&MatriculaPaciente&"|^"&ValidadePaciente

strValSis = NomePaciente&"|^"&IdadePaciente&"|^"&CPFPaciente&"|^"&ProntuarioPaciente&"|^"&EnderecoPaciente&"|^"&NumeroPaciente&"|^"&CidadePaciente&"|^"&EstadoPaciente&"|^"&CepPaciente&"|^"&Nascimento&"|^"&SexoPaciente&"|^"&CorPaciente&"|^"&AlturaPaciente&"|^"&PesoPaciente&"|^"&IMCPaciente&"|^"&ReligiaoPaciente&"|^"&Tel1Paciente&"|^"&Tel2Paciente&"|^"&Cel1Paciente&"|^"&Cel2Paciente&"|^"&Email1Paciente&"|^"&Email2Paciente&"|^"&ProfissaoPaciente&"|^"&DocumentoPaciente&"|^"&EstadoCivilPaciente&"|^"&OrigemPaciente&"|^"&IndicadoPorPaciente&"|^"&ObservacoesPaciente&"|^"&ConvenioPaciente&"|^"&MatriculaPaciente&"|^"&ValidadePaciente

strValPro = NomePaciente&"|^"&IdadePaciente&"|^"&CPFPaciente&"|^"&ProntuarioPaciente&"|^"&EnderecoPaciente&"|^"&NumeroPaciente&"|^"&CidadePaciente&"|^"&EstadoPaciente&"|^"&CepPaciente&"|^"&Nascimento&"|^"&SexoPaciente&"|^"&CorPaciente&"|^"&AlturaPaciente&"|^"&PesoPaciente&"|^"&IMCPaciente&"|^"&ReligiaoPaciente&"|^"&Tel1Paciente&"|^"&Tel2Paciente&"|^"&Cel1Paciente&"|^"&Cel2Paciente&"|^"&Email1Paciente&"|^"&Email2Paciente&"|^"&ProfissaoPaciente&"|^"&DocumentoPaciente&"|^"&EstadoCivilPaciente&"|^"&OrigemPaciente&"|^"&IndicadoPorPaciente&"|^"&ObservacoesPaciente&"|^"&ConvenioPaciente&"|^"&MatriculaPaciente&"|^"&ValidadePaciente

spl = split(strVarPac, "|^")
spl2 = split(strValPac, "|^")
'for i=0 to ubound(spl)
'	Atestados = replace(Atestados, spl(i), spl2(i))
'next

Cabecalho= tagsConverte(Cabecalho,"PacienteID_"&reg("PacienteID"),"")
Rodape= tagsConverte(Rodape,"PacienteID_"&reg("PacienteID"),"")
%>
<style>
@media print {

  /*html, body { height:100%;}*/
  thead { display: table-header-group; }
  tfoot { display: table-footer-group;  }

        #footer {
     /*display: block;*/
     position: fixed;
     bottom: 0;
     width: 100%;
  }
  .rodape{
  width: 100%;
  }
}

#areaImpressao .corpoAtestado td, #areaImpressao .corpoCarimbo td{
    <%=Margens%>
}
.rodape {
    bottom:0px;
    width:100%;
 }
 #footer{
     width:100%;

 }
.conteudo-atestado, .conteudo-atestado td, .conteudo-atestado span, .conteudo-atestado strong, #Carimbo, #Carimbo span, #Carimbo strong {
    <%= fontFamily %>
    <%= fontSize %>
    <%= fontColor %>
    <%= lineHeight %>
}
</style>
<%
Atestados = replaceTags(Atestados, reg("PacienteID"), session("User"), session("UnidadeID"))
        if MarcaDagua <> "" then
            %>
<style>


#areaImpressao{
    <%=MarcaDagua%>;
    background-size: 450px;
    background-repeat: no-repeat;
    background-position: center center;
    min-height:80%;
}

.conteudo-prescricao{
    padding: 35px;
}

h1, h2, h3, h4, h5, p{
    padding: 0;
}

body, td, th{
    padding: 0;
}

body{
    padding: 0;
}
/*2250*/
/*150*/
</style>
            <%
        end if

        %>

<script language="javascript">
function Carimbo(checked){
	if(checked==true){
		document.getElementById('Carimbo').style.display='block';
	}else{
		document.getElementById('Carimbo').style.display='none';
	}
}

function TimbradoAtestado(checked){
	if(checked==true){
		document.getElementById('footer').style.display='block';
        document.getElementById('CabecalhoTimbrado').style.display='block';
	}else{
		document.getElementById('footer').style.display='none';
        document.getElementById('CabecalhoTimbrado').style.display='none';
	}
}
</script>
<table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0">
    <thead>
        <tr class="cabecalho">
            <td>
                <div id='CabecalhoTimbrado'>
                    <%= Cabecalho %>
                </div>
            </td>
        </tr>
    </thead>
    <tfoot>
       <tr>
           <td><br><br></td> <!-- FAVOR NÃO TIRAR POR NENHUM MOTIVO -->
       </tr>
    </tfoot>
    <tbody>
    <tr class="corpoAtestado">
    	<td height="99%" valign="top" class="conteudo-atestado">

            <%= Atestados %>
            <% LimaAspasDuplasAtestado = unscapeOutput(reg("Atestado")&"")%>
            <%= replaceTags(LimaAspasDuplasAtestado, reg("PacienteID"), session("User"), session("UnidadeID"))%>
            <%
            if session("Banco")="clinic4285" then
                LinkGerado = "https://app.feegow.com/main/ValidaAtestado.asp?I="&req("AtestadoID") * 99999 &"&L=AAAW-"&replace(session("Banco"),"clinic","") * 987&"&F=992837772819"
                %>
                <%'=LinkGerado%>
                <br><br><br>
                <img style="float: right;" src="https://chart.googleapis.com/chart?cht=qr&chs=150x150&chld=L|1&chl=<%=LinkGerado%>" alt="">
                <%
            end if
            %>




            <% if session("Banco")="clinic3882" or session("Banco")="clinic105" then %>
                   <div id="Carimbo" style="text-align:center">
                    ___________________________________<br />
                        <%= NomeProfissional %><br />
                        <%= DocumentoProfissional %>
                    </div>
            <% end if %>

        </td>
    </tr>
    <tr class="corpoCarimbo">
    	<td>
<% if session("Banco")<>"clinic3882" and session("Banco")<>"clinic105" then %>
                   <div id="Carimbo" style="text-align:center">
                    ___________________________________<br />
                        <%= NomeProfissional %><br />
                        <%= DocumentoProfissional %>
                    </div>
<% end if %>
			<br /><br /><br />
		</td>
    </tr>
    </tbody>
</table>
<table id="footer">
    <tr>
        <td class="rodape">
            <%= Rodape %>
        </td>
    </tr>
</table>
</div>
<script src="assets/js/jquery-1.6.2.min.js"></script>
