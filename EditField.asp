<!--#include file="connect.asp"-->
<script type="text/javascript">

    function myFunction(i) {
      /* Get the text field */
      var copyText = document.getElementById(i);

      /* Select the text field */
      copyText.select();

      /* Copy the text inside the text field */
      document.execCommand("copy");

      /* Alert the copied text */
    //      alert("Texto copiado: " + copyText.value);
            new PNotify({
            title: '<i class="far fa-copy"></i> Texto copiado!',
            text: copyText.value,
            type: 'success'
        });

    }
</script>
<%

'ALTER TABLE `buitabelastitulos`	ADD COLUMN `tp1` VARCHAR(11) NULL DEFAULT NULL AFTER `c20`,	ADD COLUMN `tp2` VARCHAR(11) NULL DEFAULT NULL AFTER `tp1`,	ADD COLUMN `tp3` VARCHAR(11) NULL DEFAULT NULL AFTER `tp2`,	ADD COLUMN `tp4` VARCHAR(11) NULL DEFAULT NULL AFTER `tp3`,	ADD COLUMN `tp5` VARCHAR(11) NULL DEFAULT NULL AFTER `tp4`,	ADD COLUMN `tp6` VARCHAR(11) NULL DEFAULT NULL AFTER `tp5`,	ADD COLUMN `tp7` VARCHAR(11) NULL DEFAULT NULL AFTER `tp6`,	ADD COLUMN `tp8` VARCHAR(11) NULL DEFAULT NULL AFTER `tp7`,	ADD COLUMN `tp9` VARCHAR(11) NULL DEFAULT NULL AFTER `tp8`,	ADD COLUMN `tp10` VARCHAR(11) NULL DEFAULT NULL AFTER `tp9`,	ADD COLUMN `tp11` VARCHAR(11) NULL DEFAULT NULL AFTER `tp10`,	ADD COLUMN `tp12` VARCHAR(11) NULL DEFAULT NULL AFTER `tp11`,	ADD COLUMN `tp13` VARCHAR(11) NULL DEFAULT NULL AFTER `tp12`,	ADD COLUMN `tp14` VARCHAR(11) NULL DEFAULT NULL AFTER `tp13`,	ADD COLUMN `tp15` VARCHAR(11) NULL DEFAULT NULL AFTER `tp14`,	ADD COLUMN `tp16` VARCHAR(11) NULL DEFAULT NULL AFTER `tp15`,	ADD COLUMN `tp17` VARCHAR(11) NULL DEFAULT NULL AFTER `tp16`,	ADD COLUMN `tp18` VARCHAR(11) NULL DEFAULT NULL AFTER `tp17`,	ADD COLUMN `tp19` VARCHAR(11) NULL DEFAULT NULL AFTER `tp18`,	ADD COLUMN `tp20` VARCHAR(11) NULL DEFAULT NULL AFTER `tp19`

pCampoSQL = " select buiCamFor.*,arq.sysActive,arq.id AS arquivos_id from buiCamposForms buiCamFor "&chr(13)&_
            " LEFT JOIN arquivos arq ON arq.NomeArquivo=buiCamFor.ValorPadrao"&chr(13)&_
            " where buiCamFor.id="&req("I")
set pCampo=db.execute(pCampoSQL)
ValorPadrao = pCampo("ValorPadrao")
TipoCampoID=pCampo("TipoCampoID")
FormID = pCampo("FormID")
Formula = pCampo("Formula")
sysActive = replace(treatValZero(pCampo("sysActive")&""),"'","")
arquivos_id = pCampo("arquivos_id")

InformacaoCampo = pCampo("InformacaoCampo")
set pTipoCampo=db.execute("select * from cliniccentral.buiTiposCamposForms where id="&TipoCampoID)
%>
<div class="panel-heading">
    <button class="bootbox-close-button close" data-dismiss="modal" type="button">&times;</button>
    <h4 class="modal-title"><img align="absmiddle" src="images/campo<%=TipoCampoID%>.jpg" /> Edi&ccedil;&atilde;o de Campo <small>&raquo; <%=pTipoCampo("TipoCampo")%></small></h4>
</div>
<div class="panel-body">
    <div class="bootbox-body">

        <%
            hidden = "hidden"
            ' 1 -> text
            ' 4 -> Checkbox
            ' 5 -> Rádio
            ' 6 -> Seleção
            ' 8 -> Memorando
            IF TipoCampoID = 1 or TipoCampoID = 4 or TipoCampoID = 5 or TipoCampoID = 6 or TipoCampoID = 8 or TipoCampoID = 16 or TipoCampoID = 17 THEN
                hidden = ""
            END IF
        %>

<form name="frmec1" id="frmec1" action="" method="post">
	<div class="row">
    	<%=quickField("text", "RotuloCampo", "T&iacute;tulo", 6, pCampo("RotuloCampo"), "", "", "")%>
    	<%=quickField("text", "Ordem", "Ordem", 2, pCampo("Ordem"), "", "", "")%>
    	<%if TipoCampoID=1 or TipoCampoID=2 or TipoCampoID=4 or TipoCampoID=5 or TipoCampoID=6 or TipoCampoID=8 or TipoCampoID=16 or TipoCampoID=17 then%>
        <div class="col-md-4 <%=hidden%>"><label>&nbsp;</label><br>
        	<label><input type="checkbox" class="ace" name="Obrigatorio" value="S"<%if pCampo("Obrigatorio")="S" then%> checked<%end if%>/><span class="lbl mb20">
            Campo obrigatório</span></label>
        </div>
        <%end if%>
    </div>
    <% IF TipoCampoID = 1 OR TipoCampoID = 2 OR TipoCampoID = 8 OR TipoCampoID = 17 THEN
        IF TipoCampoID = 1 THEN
            sqlExtra = "1, 7, 29, 30"
        ELSEIF TipoCampoID = 2 THEN
            sqlExtra = "10"
        ELSE
            sqlExtra = "2"
        END IF
    %>
    <div class="row">
    	<div class="col-xs-12" id="InformacaoCampoDiv"><br>
            <label for="InformacaoCampo">Informa&ccedil;&atilde;o do Campo</label>
            <select name="InformacaoCampo" id="InformacaoCampo" class="form-control">
                <option value="NULL">--- NENHUMA ---</option>
            <%
            set pFormsPadrao=db.execute("SELECT * FROM `cliniccentral`.`form_campos_padrao` WHERE TipoCampoID IN ("&sqlExtra&") AND (sysActive = 1 OR LicencaID = '"&replace(session("Banco"), "clinic", "")&"') ORDER BY NomeCampo")
            while not pFormsPadrao.EOF
                %>
                <option value="<%=pFormsPadrao("id")%>" <%IF pFormsPadrao("id") = InformacaoCampo THEN%> selected <%END IF%>><%=pFormsPadrao("NomeCampo")%></option>
                <%
            pFormsPadrao.movenext
            wend
            pFormsPadrao.close
            set pFormsPadrao=nothing
            %>
            <option value="-1">--- NOVA ---</option>
            </select>
        </div>
        <div class="NovaInformacaoCampoDiv col-xs-4" style="display: none"><br>
        <label for="novaInfoNome">Nova Informa&ccedil;&atilde;o</label>
            <input type="text" class="form-control" name="novaInfoNome" id="novaInfoNome">
        </div>
        <div class="NovaInformacaoCampoDiv col-xs-4" style="display: none"><br>
        <label for="novaInfoTipo">Tipo</label>
            <select name="novaInfoTipo" id="novaInfoTipo" class="form-control">
            <%
            set pFormsPadraoTipo=db.execute("SELECT * FROM `cliniccentral`.`sys_resourcesfieldtypes` WHERE id IN ("&sqlExtra&")")
            while not pFormsPadraoTipo.EOF
                %>
                <option value="<%=pFormsPadraoTipo("id")%>"><%=pFormsPadraoTipo("label")%></option>
                <%
            pFormsPadraoTipo.movenext
            wend
            pFormsPadraoTipo.close
            set pFormsPadraoTipo=nothing
            %>
            </select>
        </div>
    </div>
    <script>
        $("#InformacaoCampo").change(function() {
            let informacaoCampo = $("#InformacaoCampo").val();
            if(informacaoCampo == -1) {
                $("#InformacaoCampoDiv").removeClass("col-xs-12").addClass("col-xs-4");
                $(".NovaInformacaoCampoDiv").show();
            } else {
                $("#InformacaoCampoDiv").removeClass("col-xs-4").addClass("col-xs-12");
                $(".NovaInformacaoCampoDiv").hide();
            }
        });
    </script>
    <% END IF %>
    <div class="row">
    	<div class="col-xs-12"><br>
            <label><input type="checkbox" class="ace" name="AvisoFechamento" value="1"<%if pCampo("AvisoFechamento")=1 then%> checked<%end if%>/><span class="lbl">
            Enviar esta informa&ccedil;&atilde;o para recepção ao finalizar atendimento</span></label>

        </div>
        <% if TipoCampoID = 16 then %>
        <div class="col-xs-12"><br>
            <label><input type="checkbox" class="ace" name="EnviarDadosCID" value="1"<%if pCampo("EnviarDadosCID")=1 then%> checked<%end if%>/><span class="lbl">
            Enviar o CID para a aba Diagnóstico CID-10

        </div>
        <%end if %>
    </div>
        <hr class="sort alt">
    <div class="row">
        <%
		if TipoCampoID=4 or TipoCampoID=5 then
		%>
			<div class="col-md-6">
              <label>Organização dos itens</label><br />
			  <select name="Checado" id="Checado" class="form-control">
			  <option value="S"<%if pCampo("Checado")="S" then%> selected="selected"<% End If %>>Um por linha</option>
			  <option value=""<%if pCampo("Checado")="" then%> selected="selected"<% End If %>>Lado a lado</option>
			  </select>
			</div>
		<%
		end if
		%>
    </div>
	<%
    if TipoCampoID=8 or TipoCampoID=17 then
	%>
    <div class="row">
        <div style="float: right">
            <div class="btn-group">	  <button class="btn dropdown-toggle btn-xs btn-info" data-toggle="dropdown">Campos do Formulário <span class="caret"></span></button>
                 <ul class="dropdown-menu">
                 <% sql = "SELECT NomeCampo,COALESCE(NULLIF(RotuloCampo,''),NomeCampo) AS RotuloCampo FROM buicamposforms WHERE NULLIF(NomeCampo,'') IS NOT NULL AND FormID = "&FormID
                    set camposForms = db.execute(sql)
                    while NOT camposForms.EOF
                 %>
                   <li><a href="javascript:macroJS('ValorPadrao', '[Forms.<%=camposForms("NomeCampo")%>]')"><%=camposForms("RotuloCampo")%></a></li>
                   <%
                       camposForms.movenext
                       wend
                   %>
                 </ul>
            </div>
        </div>
    	<%=quickField("memo", "ValorPadrao", "Valor Padr&atilde;o", 12, ValorPadrao, "", "", "")%>
		<script>
        $(function () {
            CKEDITOR.config.shiftEnterMode= CKEDITOR.ENTER_P;
            CKEDITOR.config.enterMode= CKEDITOR.ENTER_BR;
            CKEDITOR.config.height = 300;
            $('#ValorPadrao').ckeditor();
        });

        function chama(checado){
            if(checado==true){
                $('#ValorPadrao').ckeditor();
            }else{
                CKEDITOR.instances['ValorPadrao'].destroy();
            }
        }
        </script>
    </div>
	
    <%RecursoTag = "AnamnesesEvolucoes"%>
    <!--#include file="Tags.asp"-->
	<%
    end if
    if TipoCampoID=11 then
    %>
    <div class="row">
    	<div class="col-xs-12">Tipo:</div>
        <div class="col-xs-4"><label><input type="radio" class="ace" name="Grafico" value="L" onclick="document.getElementById('Checado').value=this.value;alterarEixos($('#ValorPadrao').val());" id="GraficoLinhas"<%if isNull(pCampo("Checado")) or pCampo("Checado")="L" then%> checked="checked"<%end if%> /><img src="newImages/Linhas.png" align="absmiddle" /><span class="lbl"> Linhas</span></label></div>
		<div class="col-xs-4"><label><input type="radio" class="ace" name="Grafico" value="B" onclick="document.getElementById('Checado').value=this.value;alterarEixos($('#ValorPadrao').val());" id="GraficoBarras"<%if pCampo("Checado")="B" then%> checked="checked"<%end if%> /><span class="lbl"><img src="newImages/Barras.png" align="absmiddle" /> Barras</span></label></div>
        <div class="col-xs-4"><label><input type="radio" class="ace" name="Grafico" value="P" onclick="document.getElementById('Checado').value=this.value;alterarEixos($('#ValorPadrao').val());" id="GraficoPizza"<%if pCampo("Checado")="P" then%> checked="checked"<%end if%> /><span class="lbl"><img src="newImages/Pizza.png" align="absmiddle" /> Pizza</span></label></div>
        <input type="hidden" name="Checado" id="Checado" value="<%if isNull(pCampo("Checado")) then%>L<% Else %><%=pCampo("Checado")%><% End If %>" />
    </div>
    <br><br>

    <script>
        function alterarEixos(valorPadrao) {
            let checado = $("#Checado").val();
            $.ajax({
                type:"POST",
                url:"CompiladorGrafico.asp?Opt=PreencherCamposX&ValorPadrao="+valorPadrao+"&Checado="+checado+"&ValorAtual=<%=pCampo("EixoX")%>",
                success:function(data) {
                    $("#EixoX").empty();
                    $("#EixoX").html(data);
                }
            });

            $.ajax({
                type:"POST",
                url:"CompiladorGrafico.asp?Opt=PreencherCamposY&ValorPadrao="+valorPadrao+"&Checado="+checado+"&ValorAtual=<%=pCampo("EixoY")%>",
                success:function(data) {
                    $("#EixoY").empty();
                    $("#EixoY").html(data);
                    if (checado === "L") {
                        let valEixoY = '<%=pCampo("EixoY")%>';
                        let arrEixoY = valEixoY.split(', ');
                        $("#EixoY").prop("multiple", true);
                        $('#EixoY').val(arrEixoY);
                    } else {
                        $("#EixoY").prop("multiple", false);
                    }

                }
            });
        }

        alterarEixos($("#ValorPadrao").val());

    </script>

    <div class="row">
		<div class="col-md-12">
        	Tabela de Valores
        </div>
        <div class="col-md-12">
            <select name="ValorPadrao" id="ValorPadrao" class="form-control" onchange="alterarEixos(this.value)">
                <%
                set pTabs=db.execute("select * from buiCamposForms where TipoCampoID=9 and FormID="&pCampo("FormID")&" order by RotuloCampo")
                while not pTabs.EOF
                    %><option value="<%=pTabs("id")%>"<%if cstr(pTabs("id"))=ValorPadrao then%> selected="selected"<%end if%>><%=pTabs("RotuloCampo")%></option>
                    <%
                pTabs.movenext
                wend
                pTabs.close
                set pTabs=nothing
                %>
            </select>
        </div>
    </div>
    <br><br>
    <%
        set dadosEixos=db.execute(   " SELECT                                               "&chr(13)&_
                                     " CONCAT(                                              "&chr(13)&_
                                     " 	IF(c1 <> '', CONCAT('c1', '$%|', c1), ''),          "&chr(13)&_
                                     " 	IF(c2 <> '', CONCAT('$%|', 'c2', '$%|', c2), ''),   "&chr(13)&_
                                     " 	IF(c3 <> '', CONCAT('$%|', 'c3', '$%|', c3), ''),   "&chr(13)&_
                                     " 	IF(c4 <> '', CONCAT('$%|', 'c4', '$%|', c4), ''),   "&chr(13)&_
                                     " 	IF(c5 <> '', CONCAT('$%|', 'c5', '$%|', c5), ''),   "&chr(13)&_
                                     " 	IF(c6 <> '', CONCAT('$%|', 'c6', '$%|', c6), ''),   "&chr(13)&_
                                     " 	IF(c7 <> '', CONCAT('$%|', 'c7', '$%|', c7), ''),   "&chr(13)&_
                                     " 	IF(c8 <> '', CONCAT('$%|', 'c8', '$%|', c8), ''),   "&chr(13)&_
                                     " 	IF(c9 <> '', CONCAT('$%|', 'c9', '$%|', c9), ''),   "&chr(13)&_
                                     " 	IF(c10 <> '', CONCAT('$%|', 'c10', '$%|', c10), ''),"&chr(13)&_
                                     " 	IF(c11 <> '', CONCAT('$%|', 'c11', '$%|', c11), ''),"&chr(13)&_
                                     " 	IF(c12 <> '', CONCAT('$%|', 'c12', '$%|', c12), ''),"&chr(13)&_
                                     " 	IF(c13 <> '', CONCAT('$%|', 'c13', '$%|', c13), ''),"&chr(13)&_
                                     " 	IF(c14 <> '', CONCAT('$%|', 'c14', '$%|', c14), ''),"&chr(13)&_
                                     " 	IF(c15 <> '', CONCAT('$%|', 'c15', '$%|', c15), ''),"&chr(13)&_
                                     " 	IF(c16 <> '', CONCAT('$%|', 'c16', '$%|', c16), ''),"&chr(13)&_
                                     " 	IF(c17 <> '', CONCAT('$%|', 'c17', '$%|', c17), ''),"&chr(13)&_
                                     " 	IF(c18 <> '', CONCAT('$%|', 'c18', '$%|', c18), ''),"&chr(13)&_
                                     " 	IF(c19 <> '', CONCAT('$%|', 'c19', '$%|', c19), ''),"&chr(13)&_
                                     " 	IF(c20 <> '', CONCAT('$%|', 'c20', c20), '')        "&chr(13)&_
                                     " ) AS titulos                                         "&chr(13)&_
                                     " FROM buitabelastitulos                               "&chr(13)&_
                                     " WHERE CampoID = "&treatvalnull(pCampo("ValorPadrao")))

        if not dadosEixos.eof then
            dadosEixosValores = dadosEixos("titulos")
        end if
        dadosEixosValores=""
        dadosEixosValores = split(dadosEixosValores, "$%|")
    %>
    <div class="row">
		<div class="col-md-6">
        	Eixo X
        </div>
		<div class="col-md-6">
        	Eixo Y
        </div>
        <div class="col-md-6">
            <select name="EixoX" id="EixoX" class="form-control">
                <%

                    for x = 0 to UBound(dadosEixosValores)
                        %>
                        <option value="<%=dadosEixosValores(x)%>" <%if pCampo("EixoX")=dadosEixosValores(x) then%> selected="selected"<%end if%>><%=dadosEixosValores(x+1)%></option>
                        <%
                        x=x+1
                    Next
                %>
            </select>
        </div>
        <div class="col-md-6">
            <select name="EixoY" id="EixoY" class="form-control">
                <%
                for x = 0 to UBound(dadosEixosValores)
                    %>
                    <option value="<%=dadosEixosValores(x)%>" selected <%if (InStr(AuxEixoY, (dadosEixosValores(x)&"$%|")) > 0) then%> selected="selected"<%end if%>><%=dadosEixosValores(x+1)%></option>
                    <%
                    x=x+1
                Next
                %>
            </select>
        </div>
    </div>
<%
end if
'if pCampo("TipoCampoID")<4 or pCampo("TipoCampoID")=8 then
if 1=2 then
%>
<tr>
  <td nowrap="nowrap"></td>
  <td><label><input type="checkbox" class="ace" name="Obrigatorio" value="S" id="Obrigatorio"<%if pCampo("Obrigatorio")="S" then%> checked="checked"<%end if%> /><span class="lbl">Preenchimento obrigat&oacute;rio</span></label></td>
</tr>
<%
end if
if TipoCampoID=1 or TipoCampoID=2 or TipoCampoID=6 then
	%>
    <div class="row">
        <%=quickField("text", "MaxCarac", "M&aacute;x. Caracteres", 4, pCampo("MaxCarac"), "", "", " maxlength=""3""")%>
        <%=quickField("text", "Texto", "Texto Complementar", 8, pCampo("Texto"), "", "", "")%>
    </div>
    <div class="row mt15">
        <div class="col-md-9">
            <label for="ValorPadrao">Valor Padrão</label><br />

            <input type="text" class="form-control" name="ValorPadrao" id="ValorPadrao" value="<%= ValorPadrao %>" />
            
            <%RecursoTag = "AnamnesesEvolucoes"%>
            <!--#include file="Tags.asp"-->
        </div>
        <div class="col-md-3">
            <button type="button" class="btn btn-block btn-alert mt20" onclick="$('#divFormula').slideToggle()">Configurar Fórmula <i class="far fa-chevron-down"></i></button>
        </div>

    </div>
    <hr class="short alt" />
    <div class="row mt15" style="display:none" id="divFormula">
        <div class="col-md-12">
            <h4>Configurar Fórmula</h4>
            <div class="row">
                <%= quickfield("memo", "Formula", "Fórmula", 8, Formula, "", "", " rows=8 ") %>
                <div class="col-md-4">
                    <label>Campos para cálculo</label><br />
                    <div style="border:#777 1px dotted; height:171px; overflow-x:hidden; overflow-y:scroll">
                        <%
                        set pcampos = db.execute("select id, NomeCampo from buicamposforms where FormID="& FormID &" AND id<>"& req("I"))
                        while not pcampos.eof
                            %>
                            <input readonly type="text" style="cursor:copy" class="form-control" value="[<%= pcampos("NomeCampo") %>]" id="copy<%= pcampos("id") %>" onclick="myFunction('copy<%= pcampos("id") %>')" />
                            <%
                        pcampos.movenext
                        wend
                        pcampos.close
                        set pcampos = nothing
                            %>
                    </div>
                </div>
            </div>
            <div class="row mt10">
                <div class="col-md-12">
                    <em>Você também pode utilizar fórmulas especiais, como DPP([nomedocampo]) por exemplo, que calcula a Data Provável de Parto.
                        <br />
                        Consulte nosso suporte para mais detalhes sobre fórmulas de calculadoras.
                    </em>
                </div>
            </div>
        </div>


    </div>
<%
end if

if TipoCampoID=15 then
	%>
    <div class="row">
		<%=quickField("simpleSelect", "ValorPadrao", "Valor Padr&atilde;o", 6, ValorPadrao, "select id, RotuloCampo from buicamposforms where TipoCampoID in (1) and FormID="& FormID, "RotuloCampo", "")%>
        <div class="col-md-6">
            <hr class="short alt" />
            
            <%RecursoTag = "AnamnesesEvolucoes"%>
            <!--#include file="Tags.asp"-->
        </div>
    </div>
	<%
end if

if TipoCampoID=10 then
%>
<tr>
  <td nowrap="nowrap">Separador  t&iacute;tulo</td>
  <td>
  <select name="Checado" id="Checado" class="form-control">
  <option value=""<%if pCampo("Checado")="" or isNull(pCampo("Checado")) then%> selected="selected"<% End If %>>Exibir linha</option>
  <option value="S"<%if pCampo("Checado")="S" then%> selected="selected"<% End If %>>N&atilde;o exibir linha</option>
  </select>  </td>
</tr>
<tr>
  <td>Texto</td>
  <td><textarea name="Texto" id="Texto" class="form-control" rows="4"><%=trim(replace(pCampo("Texto")&" ","<br/>",chr(10)))%></textarea></td>
</tr>
<%
end if
if TipoCampoID=14 then
	%>
	<tr>
    	<td>
        	<label>Tipo de Curva:</label><br>
            <label><input type="radio" onClick="$('#RotuloCampo').val('Curva de Crescimento')" class="ace" name="ValorPadrao" value="Crescimento"<%if ValorPadrao="Crescimento" then%> checked<% End If %>> <span class="lbl"> Curva de Crescimento</span></label>
            <label><input type="radio" onClick="$('#RotuloCampo').val('Peso por Idade')" class="ace" name="ValorPadrao" value="Peso"<%if ValorPadrao="Peso" then%> checked<% End If %>> <span class="lbl"> Peso por Idade</span></label>
            <label><input type="radio" onClick="$('#RotuloCampo').val('Perímetro Cefálico')" class="ace" name="ValorPadrao" value="Cefalico"<%if ValorPadrao="Cefalico" then%> checked<% End If %>> <span class="lbl"> Per&iacute;metro Cef&aacute;lico</span></label>
        </td>
    </tr>
	<%
end if
%>
</form>
<%
if TipoCampoID=3 then
	
	'Parametros = "P=buiCamposForms&I="&pCampo("id")&"&Col=ValorPadrao&L="&replace(session("Banco"), "clinic", "")
	%>
    <!--#include file="./Classes/imagens.asp"-->
	<tr>
    	<td>Imagem padr&atilde;o</td>
        <td>

	<div class="col-md-12">
            
    
            <div id="divDisplayFoto">
                <%
                if ValorPadrao&""<>"" AND sysActive=1  then
               'imgSRC = "/uploads/"&replace(session("Banco"), "clinic", "")&"/Perfil/"&ValorPadrao *** SRC ANTIGO
                form_imgSRC = replace(imgSRC("FORMULARIOS",ValorPadrao&"&dimension=full"),"renderMode=download","renderMode=redirect")
                %>
                    <img src="<%=form_imgSRC%>" height="150" class="img-thumbnail" id="assinatura-img"/>
                    <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="far fa-trash"></i></button>
                <%
                else
                dropZone_SRC = "dropzone.php?PacienteID=0&Tipo=A&FormularioID="&pCampo("id")&"&Pasta=Formularios&L="&replace(session("Banco"),"clinic","")
                %>
                    <iframe width="100%" height="170" frameborder="0" scrolling="no" src="<%=dropZone_SRC%>"></iframe>
                <%
                end if
                %>  

                
            </div>
            <div class="row"><div class="col-xs-6">
	            <button type="button" class="btn btn-xs btn-success btn-block" style="display:none" id="take-photo"><i class="far fa-check"></i></button>
            </div><div class="col-xs-6">
	            <button type="button" style="display:none" id="cancelar" onclick="return cancelar();" class="btn btn-block btn-xs btn-danger"><i class="far fa-remove"></i></button>
            </div></div>
    </div>

<script type="text/javascript">
//js exclusivo avatar
function removeFoto(){
	if(confirm('Tem certeza de que deseja excluir esta imagem?')){
        $.ajax({
			type:"POST",
			url:"FotoUploadSave.asp?Col=sysActive&FileName=-1&I=<%=arquivos_id%>&P=arquivos&Action=Remove",
			success:function(data){
                /*
				$("#divDisplayUploadFoto").css("display", "block");
				$("#divDisplayFoto").css("display", "none");
				$("#avatarFoto").attr("src", "/uploads/<%=replace(session("Banco"), "clinic", "")%>/Perfil/");
                $("#Foto").ace_file_input('reset_input');
                */
                saveEdit(<%=pCampo("id")%>, '', '', 0, 'S');

			}
		});
        
	}
}

$(function() {
	var $form = $('#frm');
	var file_input = $form.find('#Foto');
	var upload_in_progress = false;
	
	file_input.ace_file_input({
		style : 'well',
		btn_choose : 'Sem foto',
		btn_change: null,
		droppable: true,
		thumbnail: 'large',

		before_remove: function() {
			if(upload_in_progress)
				return false;//if we are in the middle of uploading a file, don't allow resetting file input
			return true;
		},

		before_change: function(files, dropped) {
			var file = files[0];
			if(typeof file == "string") {//files is just a file name here (in browsers that don't support FileReader API)
				if(! (/\.(jpe?g|png|gif)$/i).test(file) ) {
					alert('Please select an image file!');
					return false;
				}
			}
			else {
				var type = $.trim(file.type);
				if( ( type.length > 0 && ! (/^image\/(jpe?g|png|gif)$/i).test(type) )
						|| ( type.length == 0 && ! (/\.(jpe?g|png|gif)$/i).test(file.name) )//for android's default browser!
					) {
						alert('Please select an image file!');
						return false;
					}

				if( file.size > 1100000 ) {//~1000Kb
					alert('File size should not exceed 1mb!');
					return false;
				}
			}

			return true;
		}
	});
	
	
	$("#Foto").change(function() {
		var submit_url = "FotoUpload.php?<%=Parametros%>";
		if(!file_input.data('ace_input_files')) return false;//no files selected
		
		var deferred ;
		if( "FormData" in window ) {
			//for modern browsers that support FormData and uploading files via ajax
			var fd = new FormData($form.get(0));
		
			//if file has been drag&dropped , append it to FormData
			if(file_input.data('ace_input_method') == 'drop') {
				var files = file_input.data('ace_input_files');
				if(files && files.length > 0) {
					fd.append(file_input.attr('name'), files[0]);
					//to upload multiple files, the 'name' attribute should be something like this: myfile[]
				}
			}

			upload_in_progress = true;
			deferred = $.ajax({
				url: submit_url,
				type: $form.attr('method'),
				processData: false,
				contentType: false,
				dataType: 'json',
				data: fd,
				xhr: function() {
					var req = $.ajaxSettings.xhr();
					if (req && req.upload) {
						req.upload.addEventListener('progress', function(e) {
							if(e.lengthComputable) {	
								var done = e.loaded || e.position, total = e.total || e.totalSize;
								var percent = parseInt((done/total)*100) + '%';
								//percentage of uploaded file
							}
						}, false);
					}
					return req;
				},
				beforeSend : function() {
				},
				success : function(data) {
					
				}
			})

		}
		else {
			//for older browsers that don't support FormData and uploading files via ajax
			//we use an iframe to upload the form(file) without leaving the page
			upload_in_progress = true;
			deferred = new $.Deferred
			
			var iframe_id = 'temporary-iframe-'+(new Date()).getTime()+'-'+(parseInt(Math.random()*1000));
			$form.after('<iframe id="'+iframe_id+'" name="'+iframe_id+'" frameborder="0" width="0" height="0" src="about:blank" style="position:absolute;z-index:-1;"></iframe>');
			$form.append('<input type="hidden" name="temporary-iframe-id" value="'+iframe_id+'" />');
			$form.next().data('deferrer' , deferred);//save the deferred object to the iframe
			$form.attr({'method' : 'POST', 'enctype' : 'multipart/form-data',
						'target':iframe_id, 'action':submit_url});

			$form.get(0).submit();
			
			//if we don't receive the response after 60 seconds, declare it as failed!
			setTimeout(function(){
				var iframe = document.getElementById(iframe_id);
				if(iframe != null) {
					iframe.src = "about:blank";
					$(iframe).remove();
					
					deferred.reject({'status':'fail','message':'Timeout!'});
				}
			} , 60000);
		}
		////////////////////////////
		deferred.done(function(result){
			upload_in_progress = false;
			
			if(result.status == 'OK') {
				if(result.resultado=="Inserido"){
					$("#avatarFoto").attr("src", result.url);
					$("#divDisplayUploadFoto").css("display", "none");
					$("#divDisplayFoto").css("display", "block");
				}
				//alert("File successfully saved. Thumbnail is: " + result.url)
			}
			else {
				alert("File not saved. " + result.message);
			}
		}).fail(function(res){
			upload_in_progress = true;
			alert("Erro ao subir arquivo.");
			//console.log(result.responseText);
		});

		deferred.promise();
		return false;
		
	});
	
	$form.on('reset', function() {
		file_input.ace_file_input('reset_input');
	});


	if(location.protocol == 'file:') alert("For uploading to server, you should access this page using a webserver.");

});

</script>
        </td>
    </tr>
	<%
end if
%>
</table>
<form method="post" action="" name="frmec2" id="frmec2">
<%
if TipoCampoID=4 or TipoCampoID=5 or TipoCampoID=6 then
%>
<div class="row">
  <div id="ValoresCampos" class="col-md-12"><%=Server.Execute("ValoresCampos.asp")%></div></td>
</div>
<%
end if
if TipoCampoID=9 then
	InformaAjaxTabela="<!--[ChamaTabela]-->"
	%>
    <div class="row">
		<div class="col-md-3"><label>N&uacute;mero de Colunas</label><br />
			<input name="Largura" type="text" class="form-control" id="Largura" value="<%=pCampo("Largura")%>" size="2" maxlength="2" />
    	</div>
    </div>
    <div class="row">
        <div class="col-md-12">
            <table class="table table-condensed table-bordered">
                <thead>
                    <tr class="info">
                        <th>TÍTULO: </th>
                        <%
                        set pTit = db.execute("select * from buitabelastitulos where CampoID="& req("I"))
                        c = 0
                        while c<20 and c<ccur(pCampo("Largura"))
                            c = c+1
                            %>
                            <th><input class="form-control" size="5" name="etit<%= c %>" value="<%= pTit("c"& c) %>" /></th>
                            <%
                        wend
                        %>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th>TIPO: </th>
                        <%
                        set pTit = db.execute("select * from buitabelastitulos where CampoID="& req("I"))
                        c = 0
                        while c<20 and c<ccur(pCampo("Largura"))
                            c = c+1
                            %>
                            <td>
                                <%= quickfield("simpleSelect", "tipo"&c, "", 4, pTit("tp"&c), "select 'text' id, 'Texto' Descricao UNION select 'number', 'Inteiro' UNION select 'decimal', 'Decimal' UNION select 'datepicker', 'Data'", "Descricao", " semVazio no-select2 ") %>
                            </td>
                            <%
                        wend
                        %>

                    </tr>
                </tbody>
            </table>
        </div>
    </div>
	<%
end if
%>
</form>
<div class="panel-footer mt25 text-right">
  <button type="button" class="btn btn-primary" onclick="saveEdit(<%=pCampo("id")%>, '<%=req("W")%>', '<%=req("F")%>', 0, 'S');"><i class="far fa-save"></i>Salvar</button>
  <%
  if TipoCampoID=4 or TipoCampoID=5 or TipoCampoID=6 then
  	%><button type="button" class="btn btn-success" onclick="addOption('A', <%=req("I")%>);"><i class="far fa-plus"></i> Adicionar Op&ccedil;&atilde;o</button><%
  end if
  %>
</div>

  </div>
</div>

<script>
function saveEdit(I, W, F, O, DisNo){
    let InformacaoCampo = $("#InformacaoCampo").val();
    let novaInfoNome = $("#novaInfoNome").val();
    if (InformacaoCampo == "-1" && novaInfoNome === "") {
        alert("Informe um nome para a nova informação.");
        return;
    }
    
	$.post("formsSalvaEdicao.asp?I="+I+"&W=0&F="+F+"&O="+O, $("#frmec1, #frmec2").serialize(), function(data, status){ eval(data); });

}
function addOption(A, I){
	$.post("ValoresCampos.asp?I="+I+"&A="+A, '', function(data, status){
		$("#ValoresCampos").html(data);
	});
}
function updateOption(A, I, CI){
    let nomeValor = $('#NomeOpcao'+CI).val();
    let valorValor = $('#ValorOpcao'+CI).val();
	$.post("ValoresCampos.asp?I="+I+"&CI="+CI+"&A="+A+"&Check="+$('#CheckOpcao'+CI).prop('checked'),
    {
        Nome:nomeValor,
        Valor:valorValor
    },
    function(data, status) {
		if(A=="X"){
			$('#ValoresCampos').html(data);
		}
	});
}
</script>

<%=InformaAjaxTabela%>