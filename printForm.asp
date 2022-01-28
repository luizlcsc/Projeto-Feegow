<!--#include file="connect.asp"-->
		<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
		
        <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.15.4/css/all.css" integrity="sha384-rqn26AG5Pj86AF4SO72RK5fyefcQ/x32DNQfChxWvbXIyXFePlEktwD18fEz+kQU" crossorigin="anonymous">
        
		<link rel="stylesheet" href="assets/css/jquery-ui-1.10.3.custom.min.css" />
		<link rel="stylesheet" href="assets/css/chosen.css" />
		<link rel="stylesheet" href="assets/css/datepicker.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-timepicker.css" />
		<link rel="stylesheet" href="assets/css/daterangepicker.css" />
		<link rel="stylesheet" href="assets/css/colorpicker.css" />
		<link rel="stylesheet" href="assets/css/jquery.gritter.css" />
		<link rel="stylesheet" href="assets/css/select2.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-editable.css" />

        <!-- fonts -->

		<link rel="stylesheet" href="assets/css/ace-fonts.css" />

		<!-- ace styles -->

		<link rel="stylesheet" href="assets/css/ace.css" />
		<link rel="stylesheet" href="assets/css/ace-rtl.min.css" />
		<link rel="stylesheet" href="assets/css/ace-skins.min.css" />

		<!--[if lte IE 8]>

		<script src="assets/js/ace-extra.min.js"></script>
        <!-- colocado por feegow para calendario funcionar -->
    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
    <script type="text/javascript" src="assets/js/jquery.validate.min.js"></script>
	
	<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
	<script src="ckeditors/adapters/jquery.js"></script>
	
	<script type="text/javascript" src="assets/js/qtip/jquery.qtip.js"></script>
		<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->

		<!--[if lt IE 9]>
		<script src="assets/js/html5shiv.js"></script>
		<script src="assets/js/respond.min.js"></script>
        -->

<link rel="stylesheet" href="ckeditornew/contents.css" />
<style type="text/css">
#folha{
		font-family: Arial, sans-serif;
		list-style-type: none;
		margin: 0px;
		padding: 0px;
		width: 760px;
		height:1200px;
		background-color:#FFFFFF;
		border:1px solid #fff;
		position:relative;
}
.campos{
		position:absolute;
		margin: 0;
		border: 2px dotted #fff;
		text-align: center;
		padding: 10px;
		background-color: #fff;
		text-align:left;
		min-height:80px!important;
}
.lembrar{
	position:absolute;
	right:0;
	display:none;
}
.campos:hover .lembrar{
	display:block;
}
.campo:hover .lembrar{
	display:block;
}
.gridster .gs-w {
    cursor:default!important;
}

<% if session("Banco")="clinic84" then %>
.gs-w{
    border:none!important;
    border-width:0!important;
}

.gridster li {
    font-size:17pt!important;
    font-family:Calibri!important;
}

<% end if %>

</style>
<style type="text/css" media="print">
.print{
	display:none;
}
</style>
<a style="position:fixed; background-color:#0CF; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px;" href="#" onclick="print();" class="print" rel="areaImpressao">
	<img src="assets/img/printer.png" border="0" alt="IMPRIMIR" title="IMPRIMIR" align="absmiddle"> <strong>IMPRIMIR</strong>
</a>
<%
on error resume next
FormID = req("FormID")
PacienteID = req("PacienteID")
ModeloID = req("ModeloID")
set getForm = db.execute("select * from buiforms where id="&req("ModeloID"))


if getForm("Tipo")=4 then   '---Verifica se é tipo laudo para pegar o modelo
    LaudoID = req("LaudoID")
    set getLaudos = db.execute("SELECT l.*, p.NomeProcedimento FROM laudos l LEFT JOIN procedimentos p ON p.id=l.ProcedimentoID WHERE l.id="&LaudoID)
    if not getLaudos.EOF then
        ProcedimentoID = getLaudos("ProcedimentoID")
        NomeProcedimento = getLaudos("NomeProcedimento")
        ProfissionalID = getLaudos("ProfissionalID")
        Tabela = getLaudos("Tabela")
        TabelaID = getLaudos("IDTabela")

'response.write(ProfissionalID)
        set getModLaudo = db.execute("SELECT * FROM laudosmodelos WHERE sysActive=1 AND (Procedimentos like '%|ALL|%' OR Procedimentos = '' OR Procedimentos like '%|"&ProcedimentoID&"|%') AND (UnidadeID like '%|ALL|%' OR UnidadeID = '' OR UnidadeID like '%|"&session("UnidadeID")&"|%')")
        if not getModLaudo.EOF then
            Cabecalho = getModLaudo("Cabecalho")
            Rodape = getModLaudo("Rodape")

            '--> Tags Adicionais
            '------> Código do Atendimento
            Cabecalho = replace(Cabecalho, "[Atendimento.ID]", right("0000000"&LaudoID,7))
            Rodape = replace(Rodape, "[Atendimento.ID]", right("0000000"&LaudoID,7))

            '------> Nome do Procedimento
            Cabecalho = replace(Cabecalho, "[Procedimento.Nome]", NomeProcedimento)
            Rodape = replace(Rodape, "[Procedimento.Nome]", NomeProcedimento)

            '------> Profissional Executante
            NomeProfissionalExecutante = ""
            DocumentoProfissionalExecutante = ""
            DataExecucao = ""
            AssinaturaProfissionalExecutante = ""
            if Tabela="tissprocedimentossadt" then
                set getTissProf = db.execute("SELECT tp.Data ,p.NomeProfissional, t.Tratamento, c.descricao Conselho, p.DocumentoConselho, p.UFConselho, p.Assinatura FROM tissprocedimentossadt tp LEFT JOIN profissionais p ON tp.ProfissionalID=p.id LEFT JOIN tratamento t ON t.id=p.TratamentoID LEFT JOIN conselhosprofissionais c ON c.id=p.conselho WHERE tp.ProcedimentoID="&ProcedimentoID&" AND tp.id="&TabelaID)
                if not getTissProf.EOF then
                    NomeProfissionalExecutante = getTissProf("Tratamento")&" "&getTissProf("NomeProfissional")
                    DocumentoProfissionalExecutante = getTissProf("Conselho")&": "&getTissProf("DocumentoConselho")&" - "&getTissProf("UFConselho")
                    DataExecucao = getTissProf("Data")
                    if getTissProf("Assinatura")&""<>"" then
                        AssinaturaProfissionalExecutante = " <img style='max-height:100px' src='./../uploads/"&getTissProf("Assinatura")&"' class='img-thumbnail' />"
                    else
                        AssinaturaProfissionalExecutante = ""
                    end if
                end if
            elseif Tabela="itensinvoice" then
                set getInvProf = db.execute("SELECT ii.DataExecucao ,p.NomeProfissional, t.Tratamento, c.descricao Conselho, p.DocumentoConselho, p.UFConselho, p.Assinatura FROM itensinvoice ii LEFT JOIN profissionais p ON ii.ProfissionalID=p.id LEFT JOIN tratamento t ON t.id=p.TratamentoID LEFT JOIN conselhosprofissionais c ON c.id=p.conselho WHERE ii.ItemID="&ProcedimentoID&" AND ii.Executado='S' AND ii.id="&TabelaID)
                if not getInvProf.EOF then
                    NomeProfissionalExecutante = getInvProf("Tratamento")&" "&getInvProf("NomeProfissional")
                    DocumentoProfissionalExecutante = getInvProf("Conselho")&": "&getInvProf("DocumentoConselho")&" - "&getInvProf("UFConselho")
                    DataExecucao = getInvProf("DataExecucao")

                    if getInvProf("Assinatura")&""<>"" then
                        AssinaturaProfissionalExecutante = " <img style='max-height:100px' src='./../uploads/"&getInvProf("Assinatura")&"' class='img-thumbnail'  />"
                    else
                        AssinaturaProfissionalExecutante = ""
                    end if
                end if
            end if
            Cabecalho = replace(Cabecalho, "[ProfissionalExecutante.Nome]", NomeProfissionalExecutante)
            Rodape = replace(Rodape, "[ProfissionalExecutante.Nome]", NomeProfissionalExecutante)
            Cabecalho = replace(Cabecalho, "[ProfissionalExecutante.Documento]", DocumentoProfissionalExecutante)
            Rodape = replace(Rodape, "[ProfissionalExecutante.Documento]", DocumentoProfissionalExecutante)
            Cabecalho = replace(Cabecalho, "[ProfissionalExecutante.Assinatura]", AssinaturaProfissionalExecutante)
            Rodape = replace(Rodape, "[ProfissionalExecutante.Assinatura]", AssinaturaProfissionalExecutante)
            Cabecalho = replace(Cabecalho, "[Data.Execucao]", DataExecucao)
            Rodape = replace(Rodape, "[Data.Execucao]", DataExecucao)

            '------> Profissional Laudador
            set getProf = db.execute("SELECT p.NomeProfissional, t.Tratamento, c.descricao Conselho, p.DocumentoConselho, p.UFConselho, p.Assinatura FROM profissionais p LEFT JOIN tratamento t ON t.id=p.TratamentoID LEFT JOIN conselhosprofissionais c ON c.id=p.conselho WHERE p.id="&ProfissionalID)
            if not getProf.EOF then
                NomeProfissionalLaudador = getProf("Tratamento")&" "&getProf("NomeProfissional")
                DocumentoProfissionalLaudador = getProf("Conselho")&": "&getProf("DocumentoConselho")&" - "&getProf("UFConselho")

                if getProf("Assinatura")&""<>"" then
                    AssinaturaProfissionalLaudador = " <img src='./../uploads/"&getProf("Assinatura")&"' class='img-thumbnail' style='max-height:100px;' />"
                else
                    AssinaturaProfissionalLaudador = ""
                end if


                Cabecalho = replace(Cabecalho, "[ProfissionalLaudador.Nome]", NomeProfissionalLaudador)
                Rodape = replace(Rodape, "[ProfissionalLaudador.Nome]", NomeProfissionalLaudador)
                Cabecalho = replace(Cabecalho, "[ProfissionalLaudador.Documento]", DocumentoProfissionalLaudador)
                Rodape = replace(Rodape, "[ProfissionalLaudador.Documento]", DocumentoProfissionalLaudador)
                Cabecalho = replace(Cabecalho, "[ProfissionalLaudador.Assinatura]", AssinaturaProfissionalLaudador)
                Rodape = replace(Rodape, "[ProfissionalLaudador.Assinatura]", AssinaturaProfissionalLaudador)
            end if

            '--> Tags Principais
            Cabecalho = replaceTags(Cabecalho, PacienteID, session("UserID"), session("UnidadeID"))
            Rodape = replaceTags(Rodape, PacienteID, session("UserID"), session("UnidadeID"))
            Cabecalho = replateTagsPaciente(Cabecalho, PacienteID)
            Rodape = replateTagsPaciente(Rodape, PacienteID)

        end if
    end if

else
	set getImpressos = db.execute("select * from Impressos")
	if not getImpressos.EOF and (session("Banco")="clinic811" or session("Banco")="clinic1014" or session("Banco")="clinic3882" or session("Banco")="clinic5351" or session("Banco")="clinic5968") then
		Cabecalho = getImpressos("Cabecalho")
		Rodape = getImpressos("Rodape")
		Prescricoes = getImpressos("Prescricoes")
        Unidade = session("UnidadeID")
        set timb = db.execute("select * from papeltimbrado where sysActive=1 AND (profissionais like '%|ALL|%' OR profissionais like '%|"&session("idInTable")&"|%')  AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
        if not timb.eof then
            Cabecalho = replaceTags(timb("Cabecalho"), 0, session("UserID"), session("UnidadeID"))
            Rodape = replaceTags(timb("Rodape"), 0, session("UserID"), session("UnidadeID"))
            Margens = "margin-left:"&timb("mLeft")&"px;margin-top:"&timb("mTop")&"px;margin-bottom:"&timb("mBottom")&"px;margin-right:"&timb("mRight")&"px;"
        end if
        if lcase(session("table"))="profissionais" then
            set timb = db.execute("select * from papeltimbrado where sysActive=1 AND (profissionais like '%|ALL|%' OR profissionais like '%|"&session("idInTable")&"|%')  AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
            if not timb.eof then
                Cabecalho = replaceTags(timb("Cabecalho"), 0, session("UserID"), session("UnidadeID"))
                Rodape = replaceTags(timb("Rodape"), 0, session("UserID"), session("UnidadeID"))
            end if
        end if
	end if
end if
	%>
<style>
@media print {

  /*html, body { height:100%;}*/
  /*thead { display: table-header-group; }*/
  /*tfoot { display: table-footer-group;  }*/

        #footer {
     display: block;
     position: fixed;
     bottom: 0;
     width: 100%;
  }
  .rodape{
  width: 100%;
  }
}

body{<%=Margens%>}
</style>
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
               <td><br><br><br><br><br><br>&nbsp;</td> <!-- FAVOR NÃO TIRAR POR NENHUM MOTIVO -->
           </tr>
        </tfoot>
        <tbody>
            <tr class="corpoForm">
                <td valign="top" class="conteudo-formulario">
            <%
            if getForm("Versao")=1 then
				%>
				<!--#include file="printOldForm.asp"-->
                <%
			elseif getForm("Versao")=2 then

			    if getForm("useHTML") = "1" then
                    %>
                    <!--#include file="printNewHTMLForm.asp"-->
                    <%
			    else
			        %>
                    <!--#include file="printNewForm.asp"-->
                    <%
			    end if
			end if
			%>
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




		<script src="assets/js/bootstrap.min.js"></script>
		<script src="assets/js/typeahead-bs2.min.js"></script>
		<script src="assets/js/jquery.maskMoney.js" type="text/javascript"></script>

		<!-- page specific plugin scripts -->
		<script src="assets/js/jquery-ui-1.10.3.custom.min.js"></script>
		<script src="assets/js/jquery.ui.touch-punch.min.js"></script>
		<script src="assets/js/jquery.gritter.min.js"></script>
        <script src="assets/js/jquery.slimscroll.min.js"></script>
		<script src="assets/js/jquery.hotkeys.min.js"></script>
		<script src="assets/js/bootstrap-wysiwyg.min.js"></script>
  		<script src="assets/js/select2.min.js"></script>
        <script src="assets/js/jquery.easy-pie-chart.min.js"></script>
		<script src="assets/js/jquery.sparkline.min.js"></script>
		<script src="assets/js/flot/jquery.flot.min.js"></script>
		<script src="assets/js/flot/jquery.flot.pie.min.js"></script>
		<script src="assets/js/flot/jquery.flot.resize.min.js"></script>
			<!-- table scripts -->
		<script src="assets/js/jquery.dataTables.min.js"></script>
		<script src="assets/js/bootbox.min.js"></script>
		<script src="assets/js/jquery.dataTables.bootstrap.js"></script>


		<!--[if lte IE 8]>
		  <script src="assets/js/excanvas.min.js"></script>
		<![endif]-->

		<script src="assets/js/chosen.jquery.min.js"></script>
		<script src="assets/js/fuelux/fuelux.spinner.min.js"></script>
		<script src="assets/js/date-time/bootstrap-datepicker.min.js"></script>
		<script src="assets/js/date-time/bootstrap-timepicker.min.js"></script>
		<script src="assets/js/date-time/moment.min.js"></script>
		<script src="assets/js/date-time/daterangepicker.min.js"></script>
		<script src="assets/js/bootstrap-colorpicker.min.js"></script>
		<script src="assets/js/jquery.knob.min.js"></script>
		<script src="assets/js/jquery.autosize.min.js"></script>
		<script src="assets/js/jquery.inputlimiter.1.3.1.min.js"></script>
		<script src="assets/js/jquery.maskedinput.min.js"></script>
		<script src="assets/js/bootstrap-tag.min.js"></script>
		<script src="assets/js/x-editable/bootstrap-editable.min.js"></script>
		<script src="assets/js/x-editable/ace-editable.min.js"></script>
        <script type="text/javascript" src="assets/js/bootstrap-datetimepicker.min.js"></script> 
        <script type="text/javascript" src="assets/js/bootstrap-datetimepicker.pt-BR.js"></script> 

		<!-- ace scripts -->

		<script src="assets/js/ace-elements.min.js"></script>
		<script src="assets/js/ace.min.js"></script>

<script >
    $(document).ready(function() {
        if('<%=req("LaudoID")%>'!==''){
            window.print();
            window.addEventListener("afterprint", function(event) { window.close(); });
            window.onafterprint();
        }
    });
</script>