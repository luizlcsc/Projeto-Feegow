<%
response.Charset="utf-8"
%>
<!--#include file="connect.asp"-->

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

TipoEncaminhamento = req("TipoEncaminhamento")
EncaminhamentoID = req("EncaminhamentoID")

set getImpressos = db.execute("select * from encaminhamentosmodelos WHERE Tipo like '|"&TipoEncaminhamento&"|' ORDER BY id DESC")
if not getImpressos.EOF then
    ConteudoEncaminhamento = replaceTags(getImpressos("Conteudo")&"", req("PacienteID"), session("User"), session("UnidadeID"))
    PapelTimbradoID = getImpressos("PapelTimbradoID")
    set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND pt.id="&PapelTimbradoID)
    if not timb.eof then
        Cabecalho = timb("Cabecalho")
        Margens = "padding-left:"&timb("mLeft")&"px;padding-top:"&timb("mTop")&"px;padding-bottom:"&timb("mBottom")&"px;padding-right:"&timb("mRight")&"px;"
        Cabecalho = replaceTags(timb("Cabecalho"), 0, session("UserID"), session("UnidadeID"))
        Rodape = replaceTags(timb("Rodape"), 0, session("UserID"), session("UnidadeID"))

        if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
        if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
        if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
        if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

    end if
end if

Cabecalho = unscapeOutput(Cabecalho)
Rodape = unscapeOutput(Rodape)


'-----> Substituindo as tags do conteudo
set getEncaminhamento = db.execute("select * from protocolosencaminhamentos where sysActive=1 AND id="&EncaminhamentoID)
if not getEncaminhamento.eof then
    Motivo = getEncaminhamento("Motivo")&""
    Obs = getEncaminhamento("Obs")&""
    FormID = getEncaminhamento("FormID")
    ProfissionalID = getEncaminhamento("ProfissionalID")
    EspecialidadeID = getEncaminhamento("EspecialidadeID")
    LicencaID = getEncaminhamento("LicencaID")
    ConteudoEncaminhamento = replace(ConteudoEncaminhamento, "[Encaminhamento.Motivo]", Motivo)
    ConteudoEncaminhamento = replace(ConteudoEncaminhamento, "[Encaminhamento.Obs]", Obs)

    if EspecialidadeID<>0 then
        set getEspecialidadeEncaminhada = db.execute("SELECT COALESCE(especialidade, nomeEspecialidade) especialidade FROM cliniccentral.especialidades_correcao WHERE id="&EspecialidadeID)
        if not getEspecialidadeEncaminhada.eof then
            NomeEspecialidade = "Especialidade: "&getEspecialidadeEncaminhada("especialidade")
        end if
    end if

    if LicencaID<>0 then
        set getProfissionalEncaminhado = db.execute("SELECT NomeProfissional FROM clinic"&LicencaID&".profissionais WHERE id="&ProfissionalID)
        if not getProfissionalEncaminhado.eof then
            NomeProfissional = "<br>Profissional: " & getProfissionalEncaminhado("NomeProfissional")
        end if
        set getDadosEmpresa = db.execute("SELECT Endereco, Cep, Numero, Complemento, Bairro, Tel1 FROM clinic"&LicencaID&".empresa WHERE id=1")
        if not getDadosEmpresa.eof then
            if getDadosEmpresa("Endereco")&""<>"" then
                Endereco = "<br>Endereço: "& getDadosEmpresa("Endereco")  &" "& getDadosEmpresa("Numero")  &" "& getDadosEmpresa("Complemento")  &" "& getDadosEmpresa("Bairro")  &" -  "&  getDadosEmpresa("Cep")
            end if
            if getDadosEmpresa("Tel1")&""<>"" then
                TelefoneContato = "<br>Telefone: "&getDadosEmpresa("Tel1")
            end if
        end if
        TextoEncaminhamento = NomeEspecialidade & NomeProfissional & TelefoneContato & Endereco
        ConteudoEncaminhamento = replace(ConteudoEncaminhamento, "[Encaminhamento.Encaminhado]", TextoEncaminhamento)

    end if
    ConteudoEncaminhamento = replace(ConteudoEncaminhamento, "[Encaminhamento.Encaminhado]", NomeEspecialidade)



    set getDiagnostico = db.execute("select pc.id, GROUP_CONCAT(CONCAT(t.CID10_Cd1, ' - ' , t.termo) SEPARATOR '<br>') Diagnosticos from pacientesciap pc "&_
                                    "LEFT JOIN buicamposforms cf ON cf.id=pc.CampoID "&_
                                    "LEFT JOIN cliniccentral.tesauro t ON t.id=pc.CiapID "&_
                                    "WHERE cf.Estruturacao like '%|Diagnóstico|%' AND pc.FormID="&FormID)
    if not getDiagnostico.eof then
        Diagnosticos = getDiagnostico("Diagnosticos")&""
        ConteudoEncaminhamento = replace(ConteudoEncaminhamento, "[Paciente.ProntuarioDiagnosticos]", Diagnosticos)
        ConteudoEncaminhamento = replace(ConteudoEncaminhamento, "[Paciente.ProntuarioDiagnosticoAtual]", Diagnosticos)
    end if

    set getPrescricoes = db.execute("SELECT GROUP_CONCAT(med.NomeMedicamento SEPARATOR '<br>') Medicamentos FROM memed_prescricoes pp "&_
                                    "LEFT JOIN cliniccentral.medicamentos2 med ON med.id=pp.MedicamentoID "&_
                                    "WHERE sysActive=1 AND FormID="&FormID)
    if not getPrescricoes.eof then
        Prescricoes = getPrescricoes("Medicamentos")&""
        ConteudoEncaminhamento = replace(ConteudoEncaminhamento, "[Paciente.ProntuarioPrescricoes]", Prescricoes)
    end if

end if

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

#areaImpressao td.conteudo-encaminhamento, #areaImpressao .corpoCarimbo td{
    <%=Margens%>
}
.rodape {
    bottom:0px;
    width:100%;
 }
 #footer{
     width:100%;

 }
.conteudo-encaminhamento, .conteudo-encaminhamento td, .conteudo-encaminhamento span, .conteudo-encaminhamento strong, #Carimbo, #Carimbo span, #Carimbo strong {
    <%= fontFamily %>
    <%= fontSize %>
    <%= fontColor %>
    <%= lineHeight %>
}
</style>
<%
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
</script>
<table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0">
    <thead>
        <tr class="cabecalho">
            <td>
                <%= Cabecalho %>
            </td>
        </tr>
    </thead>
    <tfoot>
       <tr>
           <td><br><br></td> <!-- FAVOR NÃO TIRAR POR NENHUM MOTIVO -->
       </tr>
    </tfoot>
    <tbody>
    <tr class="corpoencaminhamento">
    	<td height="99%" valign="top" class="conteudo-encaminhamento">

            <%= ConteudoEncaminhamento%>


        </td>
    </tr>
    <tr class="corpoCarimbo">
    	<td>
           <div id="Carimbo" style="text-align:center">
            ___________________________________<br />
                <%= NomeProfissional %><br />
                <%= DocumentoProfissional %>
            </div>
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
