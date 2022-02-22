		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		
        <link href="assets/css/coreBoot.css" rel="stylesheet" type="text/css" />

	    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
		<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
        <script src="ckeditornew/adapters/jquery.js"></script>
        <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
        <style type="text/css">
		@media print {
            
		  .hidden-print {
               
			display: none !important;
		  }
          
            .areaImpressao{
                page-break-after: always;
            }
          
           
		}
            .termica table{
                
                 table-layout:fixed;
            }
            .termica .data td{display: block; width: 100%}
            .termica  td.caixa:nth-child(odd) {
/*    max-width: 170px;*/
}
            
           .termica .caixa:nth-child(even) {
/*    max-width: 100px;*/
}
             .termica{
                 font-size: 11px;
                 width: 80mm;
                
            }
            body{
                background-color: #fff;
            }
            .termica td{font-size:11px}
            .termica p{font-size: 11px;}
              .termica .conteudoEspecial span{
                 font-weight: 800;

            }
              .termica .caixa {
                
                overflow: hidden !important;     
                font-size: 11px;
            }
            .termica #dataP, .termica #dataV{
                
                margin-bottom: 50px;
                display: block;
            }
            .termica img{width: 100px !important; margin: 0 auto; height: auto!important;}

		</style>
<!--#include file="connect.asp"-->

<div class="hidden-print" style="position:fixed; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px;">
    <button type="button" class="btn btn-primary" onClick="print()"><i class="far fa-print"></i> IMPRIMIR</button>
</div>
<div class="row">
<%
response.Charset="utf-8"

Vias = "1, 2"

ViasSplit = split(Vias, ", ")

colMd = "12"

for i=0 to ubound(ViasSplit)

        set getImpressos = db.execute("select * from Impressos")
        MarcaDagua = ""
        if not getImpressos.EOF then
            Cabecalho = getImpressos("Cabecalho")

            Rodape = getImpressos("Rodape")
            Prescricoes = getImpressos("Prescricoes")
            set timb = db.execute("select * from papeltimbrado where profissionais like '%|ALL|%' AND sysActive=1")
            if not timb.eof then
                Cabecalho = timb("Cabecalho")
                Margens = "margin-left:"&timb("mLeft")&"px;margin-top:"&timb("mTop")&"px;margin-bottom:"&timb("mBottom")&"px;margin-right:"&timb("mRight")&"px;"
                if session("Banco") = "clinic1805" or session("Banco") = "clinic100000" or session("Banco") = "clinic2410" then
                'if timb("MarcaDagua")<>"" or not isnull(timb("MarcaDagua"))  then
                    MarcaDagua = "background-image: url('https://clinic.feegow.com.br/uploads/"&replace(session("Banco"), "clinic", "")&"/Arquivos/"&timb("MarcaDagua")&"')"
                end if
                   Cabecalho = replaceTags(timb("Cabecalho"), 0, session("UserID"), session("UnidadeID"))
                   Rodape = replaceTags(timb("Rodape"), 0, session("UserID"), session("UnidadeID"))
            end if
            if lcase(session("table"))="profissionais" then
   
   
                set timb = db.execute("select * from papeltimbrado where profissionais like '%|"&session("idInTable")&"|%' and sysActive=1")
                if not timb.eof then
                    Cabecalho = replaceTags(timb("Cabecalho"), 0, session("UserID"), session("UnidadeID"))
                    Rodape = replaceTags(timb("Rodape"), 0, session("UserID"), session("UnidadeID"))
                end if
            end if
        end if

        Cabecalho = unscapeOutput(Cabecalho)
        Rodape = unscapeOutput(Rodape)


%>

    <div class="col-md-<%=colMd%>">
<div class="customPrint areaImpressao">
<%
set reg=db.execute("select * from PacientesPrescricoes where id="&req("PrescricaoID"))
if not reg.EOF then
	set user = db.execute("select * from sys_users where id="&session("User"))
	if not user.EOF then
		if lcase(user("Table"))="profissionais" then
			set pro = db.execute("select p.*, c.descricao from profissionais as p left join conselhosprofissionais as c on p.Conselho=c.id where p.id="&user("idInTable"))
			if not pro.EOF then
				set Trat = db.execute("select * from tratamento where id = '"&pro("TratamentoID")&"'")
				if not Trat.eof then
					Tratamento = trat("Tratamento")
				end if
				NomeProfissional = Tratamento&" "&pro("NomeProfissional")
				DocumentoProfissional = pro("descricao")&": "&pro("DocumentoConselho")&"-"&pro("UFConselho")
			end if
		end if
	end if



    if session("UnidadeID")="0" then
        set cli = db.execute("select * from empresa WHERE id=1 order by id")
    else
        set cli = db.execute("select * from sys_financialcompanyunits WHERE id="&session("Unidadeid")&" order by id")
    end if
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
		EnderecoPaciente = pac("Endereco")&", "&pac("Numero")&" "&pac("Complemento")&". "&pac("Cidade")&" - "&pac("Estado")
		NomeSocial = pac("NomeSocial")
	end if
end if

if session("Banco")="clinic3882" then
    cssCabRod = "--" 
else
    cssCabRod = "none"
end if
%>
<style type="text/css">
.caixa{
	border:2px solid #000;
	padding: 15px;
}

</style>
<table width="100%" height="98%" border="0" cellpadding="5" cellspacing="12">
  <tr style="display:<%= cssCabRod%>" class="cabecalhoTimbrado">
      <td colspan="2"><%= cabecalho %></td>
  </tr>
  <tr>
    <th colspan="2" scope="row" align="center"><h3>Receituário de controle especial</h3></th>
  </tr>
  <tr>
    <td width="50%" scope="row" class="caixa">Identificação do emitente<br>
      <%= NomeProfissional %><br>
      <%= DocumentoProfissional %><br>
      <%= EnderecoClinica %><br>
      <%= CidadeClinica %>&nbsp;<%= EstadoClinica %><br>
      Telefone: <%= Tel1Clinica %>&nbsp;<%'= Tel2Clinica %></td>
    <td width="50%" class="caixa">1a. via para retenção da farmácia ou drogaria<br>
      2a. via para orientação ao paciente</td>
  </tr>
  <tr>
    <td colspan="2" scope="row" class="pt15">
    	<p><strong>Nome: </strong><%= NomePaciente%><br />
    	<%
    	if(isnull(NomeSocial) or NomeSocial="")then
            NomeSocial = ""
        else
        %>
    	<strong>Nome Social: </strong><%= NomeSocial%><br />
    	<%
    	end if
    	%>
    	<strong>Endereço: </strong><%= EnderecoPaciente %></p>
    </td>
  </tr>
  <tr>
    <td height="99%"  class="conteudoEspecial"colspan="2" scope="row"><%=reg("Prescricao")%></td>
  </tr>
  <tr >
    <td align="right" class="centered" scope="row">&nbsp;</td>
    <td align="center" scope="row" class="especialAssinatura" nowrap><p>
	<%
'	if session("Banco")<>"clinic107" then
		%>
		<span class="dataP"><%= CidadeClinica %>, <%=day(date())%> de <%= monthname(month(date())) %> de <%= year(date()) %>.</span>
        <span class="dataV" style="display:none">_______________, ____ de ________________ de _______.</span>
        </p>
        <%
'	end if
	%>
    <p><br>
    <hr style="border:none; border-top:2px solid #000; margin:0;"><br>
    <%= NomeProfissional %>
    </p></td>
  </tr>
  <tr>
    <td align="justify" valign="top" class="caixa" scope="row">Indicação do comprador<br>
      Nome:......................................................... ..................................................................... RG:....................................................... Emissor:.......................................... Endereço:.................................................... Cidade:.............................................. UF:.................. <span class="noBreak">Telefone: .............................</span></td>
    <td valign="top" class="caixa" scope="row"><p>Identificação do fornecedor</p>
    <p>&nbsp;</p>
    <table border="0" width="100%" class="data">
    	<tr>
        	<td align="center" width="50%">
            	_______________<br>
                Assinatura farmacêutico
            </td>
            <td align="center"  width="50%">
            	Data: ..../..../.......
            </td>
        </tr>
    </table>
    </td>
  </tr>
  <tr style="display:<%= cssCabRod%>" class="rodapeTimbrado">
      <td colspan="2"><%= Rodape %></td>
  </tr>
</table>
</div>
</div>
<%
next
%>
</div>

<style>
    .noBreak{
       white-space: nowrap;
    }


</style>
<script language="javascript">
function Datar(checked){
	if(checked==true){
		$('.dataP').css("display",'block');
		$('.dataV').css("display",'none');
	}else{
		$('.dataV').css("display",'block');
		$('.dataP').css("display",'none');
	}
}


function Timbrado(checked){
	if(checked==true){
		$('.cabecalhoTimbrado').css("display",'');
		$('.rodapeTimbrado').css("display",'');
	}else{
		$('.cabecalhoTimbrado').css("display",'none');
		$('.rodapeTimbrado').css("display",'none');
	}
}
    
    
    
function Vertical(checked){
	if(checked==true){
        
        $( ".areaImpressao" ).addClass( "termica" );

     
        
    
        
	}else{
        
         $( ".areaImpressao" ).removeClass( "termica" );
	

	}
}
</script>


