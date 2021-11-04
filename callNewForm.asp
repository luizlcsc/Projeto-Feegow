<!--#include file="./Classes/TagsConverte.asp"-->
<style type="text/css">
#iProntCont .imagem {
	background-image:url(assets/img/imagem.png);
	background-repeat:no-repeat;
	background-position:center;
	height:85%;
}
#iProntCont .btn-20 {
	width:20px;
}
#iProntCont .tabTit {
	background:none;
	border:none;
	font-weight:bold;
	width:100%;
}
#iProntCont .memorando{
	border:1px solid #CCC;
}

#iProntCont table thead tr th, #iProntCont table tbody tr td {
	padding:1px!important;
}
#iProntCont table tbody tr td input {
	border:none!important;
}

#iProntCont .lembrar {
    top: -4px;
    height: 27px;
    color: #fff;
    border-radius: 4px;
    backdrop-filter: blur(10px);
    background-color: #aeaeae73;
    
    padding: 5px;
    font-weight: 500;
}
#iProntCont .lembrar.checkbox-custom input[type=checkbox]:checked + label:after {
    color: #666;
}
#iProntCont .tbl {
    width:100%;
}
</style>

<%
if getForm("Tipo")=4 or getForm("Tipo")=3 then
	FTipo = "L"
else
	FTipo = "AE"
end if
session("FP"&FTipo) = FormID

buiFormID = FormID

FormInativo = false
if FormID <> "N" then
    set getFormPreenchido = db.execute("SELECT sysActive FROM buiformspreenchidos WHERE sysActive = -1 AND id = "&FormID)
    if not getFormPreenchido.eof then
		FormInativo = true
    end if
end if

'Duplica o formulário se o atual for Inativo ou se a configuração para "Gerar novo formulário ao editar" estiver habilitada
if getConfig("GerarNovoFormulario")=1 or FormInativo = true then
    buiFormID="N"
end if
%>
<input type="hidden" name="FormID" id="FormID" value="<%=buiFormID%>" />
<input type="hidden" name="ModeloID" id="ModeloID" value="<%=ModeloID%>" />
<input type="hidden" name="Alterado" id="Alterado" value="" />
<script type="text/javascript">
  var gridster = [];
  var idsCk = [];
</script>
<%
set lau = db.execute("select * from buiformspreenchidos where id = '"&FormID&"'")
if not lau.EOF then
	ProfissionaisLaudar = lau("ProfissionaisLaudar")&" "
	Laudado = lau("LaudadoEm")
	LaudadoPor = lau("LaudadoPor")
end if

if getForm("Tipo")=4 then
	if FormID<>"N" and isnumeric(FormID) then
		set lau = db.execute("select * from buiformspreenchidos where id = '"&FormID&"'")
		if not lau.EOF then
			ProfissionaisLaudar = lau("ProfissionaisLaudar")&" "
			Laudado = lau("LaudadoEm")
			LaudadoPor = lau("LaudadoPor")
		end if
	end if
	%>
    <div class="row tray-bin btn-dimmer mb20 hidden">
    	<%=quickField("multiple", "ProfissionaisLaudar", "Profissionais a laudar", 5, ProfissionaisLaudar, "select '0' id, '' NomeProfissional UNION ALL select id, NomeProfissional from profissionais where sysActive=1 order by NomeProfissional", "NomeProfissional", "")%>
        <div class="col-md-4 checkbox-custom checkbox-primary"><br><input type="checkbox" class="campoInput" name="Laudado" id="Laudado" value="S"<% If not isnull(Laudado) and Laudado<>"" Then %> checked<%end if%>><label for="Laudado"> Laudado</label></div>
    </div>
	<%
end if

'-> Permissoes do form
if FormID<>"N" then
	set preen = db.execute("select * from `_"&ModeloID&"` where id="&FormID)
	if not preen.eof then
		preenchido = "S"
		set formPerm = db.execute("select * from buipermissoes where FormID="&ModeloID)
		if formPerm.eof then
			if preen("sysUser")<>session("User") and preen("sysUser")<>0 then
				negadoX = "S"
			else
				negadoX = "N"
			end if
		else
		    DataHora=preen("DataHora")

		    if isnull(DataHora) then
		        DataHora=date()
		    end if

			if (autForm(ModeloID, "AO", "")=true and preen("sysUser")<>session("User")) or (autForm(ModeloID, "AP", "")=true and preen("sysUser")=session("User")) OR (formatdatetime(DataHora,2)=formatdatetime(date(),2) and preen("sysUser")=session("User") ) then
				negadoX = "N"
			else
				negadoX = "S"
			end if
		end if
		NomeProfissional = nameInTable(preen("sysUser"))
		if NomeProfissional<>"" then
			NomeProfissional = NomeProfissional &", "
		end if
		DataHora = preen("DataHora")
		if not isnull(DataHora) and isdate(DataHora) then
			DataHora = formatdatetime(DataHora, 1)
		end if
		%>
        <script type="text/javascript">
            $("#nomeProfissionalPreen").html("<i class='far fa-user-md'></i> <%=NomeProfissional & DataHora%>")
        </script>
		<%
	end if
	set lbm = db.execute("select group_concat( concat('|', CampoID, '|') ) LembrarmeS from buiformslembrarme WHERE FormID="&FormID)
	LembrarmeS = lbm("LembrarmeS")
end if
'<- Permissoes do form
%>

<div id="divLay">
<%
	I = ModeloID
%>
<!--include file="newFormEstilo.asp"-->
  <div id="demo-0" class="gridster">
    <ul>
    <%
	set campos = db.execute("select c.*, f.LadoALado from buicamposforms c LEFT JOIN buiforms f on f.id=c.FormID where c.FormID="&I&" and c.GrupoID=0 and c.TipoCampoID not in(7) order by c.Ordem")
if FormID<>"N" and isnumeric(FormID) then
	set f = db.execute("select * from `_"&ModeloID&"` where id="&FormID&" limit 1")
	if not f.EOF then
		UsarPreenchido = "S"
	end if
end if
while not campos.eof
	  TipoCampoID = campos("TipoCampoID")
	  RotuloCampo = campos("RotuloCampo")
	  Checado = campos("Checado")
	  CampoID = campos("id")
	  Texto = campos("Texto")
	  pTop = campos("pTop")
	  pLeft = campos("pLeft")
	  Colunas = campos("Colunas")
	  Linhas = campos("Linhas")
	  LadoALado = campos("LadoALado")
	  Obrigatorio = campos("Obrigatorio")
	  Ordem = campos("Ordem")
	  if UsarPreenchido="S" and TipoCampoID<>9 and TipoCampoID<>13 and TipoCampoID<>10 and TipoCampoID<>15 and TipoCampoID<>11 then
	      ValorPadrao = f(""&campos("id")&"")
	  else
		  ValorPadrao = campos("ValorPadrao")
	  end if
	  GrupoID = campos("GrupoID")
	  Largura = campos("Largura")

	  if TipoCampoID=15 then
	  	CampoAssociado = campos("ValorPadrao")
		if isnumeric(CampoAssociado) and FormID<>"N" and isnumeric(FormID) then
			set vcaCampoAssociado = db.execute("select id from buicamposforms where id="&CampoAssociado)
			if not vcaCampoAssociado.EOF then
				ValorPadrao = f(""&CampoAssociado&"")
			end if
		end if
	  end if
	  if TipoCampoID=5 and ValorPadrao="" then
	  	set valpad = db.execute("select * from buiopcoescampos where CampoID="&campos("id")&" and Selecionado='S'")
		if not valpad.eof then
		  	ValorPadrao = valpad("id")
		end if
	  end if

	  if not isnull(ValorPadrao) then
			'CONVERSOS TAGS NOVO || 30/06/2020 - Rafael Maia ||
			'ProfissionalLaudadorID=replace(req("pl"),"5_","")
			
			ValorPadrao = tagsConverte(ValorPadrao,"PacienteID_"&PacienteID&"|ProfissionalSessao_"&session("User")&"|UnidadeSessao_"&session("UnidadeID"),"")
			'CONVERSOR TAGS ANTIGO
			'ValorPadrao = replaceTags(ValorPadrao, PacienteID, session("UserID"), session("UnidadeID"))
	  end if
	  %>
      <!--#include file="formsCompiladorCampoPreenchido.asp"-->
	  <%
campos.movenext
wend
campos.close
set campos=nothing


%>
</ul>
</div>
</div>

<style>
.tableFixHead          { overflow-y: auto;}
.tableFixHead thead th { position: sticky; top: 0; z-index: 9999 }
table  { border-collapse: collapse; width: 100%; }

.suggest-active{
    background-color: #d6d6d6!important;
}
.suggest-item{
    cursor: pointer;
    background-color: #f8f8f8;
    padding: 5px;
    border:1px solid #dddddd;
}

.suggest-content{
    border-bottom: 1px solid #d5d5d5;
    position: absolute;
    width:300px;
}
</style>

<script type="text/javascript">


function fRow(C, L, A){
    if(A=='I'){
        var cont = $("#lmodel"+C).html();
        i = $(".tblH"+C).length*(-1);
        str = replaceAll(cont, 'RPL', i);
        $("#fmodel"+C).before("<tr>"+ str +"</tr>");

        $(".datepicker").mask("99/99/9999");
        $(".decimal").maskMoney({thousands: "", decimal: ","});

    }else if(A=='X'){
        //    $("#r"+ C + "_" + L ).remove();
        $("#tblH" + C + "_" + L).closest("tr").remove();
        $("#tblRem"+C).val( $("#tblRem"+C).val() + ", " + L );
    }
}

function replaceAll(str, de, para){
    var pos = str.indexOf(de);
    while (pos > -1){
        str = str.replace(de, para);
        pos = str.indexOf(de);
    }
    return (str);
}


var gridster0 = null;
var gridster1 = null;

  $(function(){
      <%
      if device()="" then
      %>
	gridster0 = $("#demo-0 > ul").gridster({
		namespace: '#demo-0',
		widget_base_dimensions: [50, 25],
		widget_margins: [4, 4]
	}).data('gridster').disable();
	<%
	    end if
	splGrupos = split(strGrupos, "|")
	for ig=1 to ubound(splGrupos)
	%>
	   gridster<%=splGrupos(ig)%> = $("#demo-<%=splGrupos(ig)%> > ul").gridster({
			namespace: '#demo-<%=splGrupos(ig)%>',
			widget_base_dimensions: [40, 20],
			widget_margins: [4, 4],
			draggable: {
				items: ".items<%=splGrupos(ig)%>",
				start: function () {
					// console.log('draggable start')
					setTimeout(function () {
					}, 1000)
				}
			}
		}).data('gridster');
	<%
	next
	%>
  });
<%
if device()="" then
%>
$("#demo-0 ul").css("left", "50%");
$("#demo-0 ul").css("margin-left", "-406px");
<%
else
%>
$("#demo-0 ul").css("padding-left", "0");
<%
end if
%>

<%=ckrender%>
if(typeof idsCk !== "undefined"){
    String.prototype.replaceAll = function(search, replacement) {
        var target = this;
        return target.replace(new RegExp(search, 'g'), replacement);
    };

    getUrl("autocomplete/get-frases",{}, function (data) {
        idsCk.forEach(function (value) {
                var editor = CKEDITOR.inline(value, {
                    skin: 'office2013',
                    itemsArray: data,
                    floatSpaceDockedOffsetY: 30

                });
        });
    });


}

function editCurva(CampoID){
	$("#modal").html('Carregando...');
	$("#modal-table").modal("show");
	$.post("modalEditaCurva.asp?FormPID="+$("#FormID").val()+"&ModeloID="+$("#ModeloID").val()+"&CampoID="+CampoID+"&PacienteID=<%=PacienteID%>", '', function(data, status){
		$("#modal").html(data);
	});
}
    <%
    on error resume next

    set cpFormula = db.execute("select id, Formula from buicamposforms where Formula like '%[%' and FormID=" & ModeloID)
    while not cpFormula.eof
        Formula = cpFormula("Formula") & ""
        Formula = replace(replace(Formula, "'", ""), "\", "")
        splCP = split(Formula, "[")
        for i=0 to ubound(splCP)
            if instr(splCP(i), "]")>0 then
                spl2 = split(splCP(i), "]")
                NomeCampo = spl2(0)
                NomesCampos = NomesCampos & ", '"& NomeCampo &"'"
            end if
        next
    cpFormula.movenext
    wend
    cpFormula.close
    set cpFormula = nothing
    if NomesCampos<>"" then
        NomesCampos = right(NomesCampos, len(NomesCampos) - 2)
        set pids = db.execute("select group_concat( concat('#input_', id)) inputs from buicamposforms where NomeCampo IN(" & NomesCampos & ") AND FormID=" & ModeloID)
        %>
        $("<%= pids("inputs") %>").on('keyup blur', function () {

            $.post("formCalc.asp?Input="+ $(this).attr("id"), $(".campoInput, .campoCheck, .tbl").serialize(), function (data) {
                eval(data);
            });
        });
        <%
    end if
    recursoPermissaoUnimed = recursoAdicional(12)
    %>

    function act(IDCol) {
        <% if recursoPermissaoUnimed=4 then %>
        $.post("act.asp?IDCol="+IDCol+"&FPID="+$("#FormID").val()+"&tipoForm="+$("#tipoForm").val()+"&FormID=<%=ModeloID%>", $(".campoInput").serialize(), function(data){
            eval(data);
        });
        <% end if %>
    }
    $(".datepicker").mask("99/99/9999");
    $(".decimal").maskMoney({thousands: "", decimal: ","});

<!--#include file="jqueryfunctions.asp"-->
</script>