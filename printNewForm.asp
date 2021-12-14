<%
response.Charset="utf-8"
%>
		<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		<!--link rel="stylesheet" href="assets/css/animate.css" />-->

		<!--[if IE 7]>
		  <link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" />
		<![endif]-->



<link rel="stylesheet" type="text/css" href="site/jquery.gridster.css">
<link rel="stylesheet" type="text/css" href="site/demo.css">
<link rel="stylesheet" type="text/css" href="buiforms.css">
<script type="text/javascript" src="assets/js/jquery.min.js"></script>
<script src="site/jquery.gridster.js" type="text/javascript" charset="utf-8"></script>
	<!-- fonts -->


<style type="text/css">
.imagem {
	background-image:url(assets/img/imagem.png);
	background-repeat:no-repeat;
	background-position:center;
	height:85%;
}
.btn-20 {
	width:20px;
}
.tabTit {
	background:none;
	border:none;
	font-weight:bold;
	width:100%;
}
.memorando{
	height:calc(100% - 20px)!important;
	height: -webkit-calc(100% - 20px);
	height: -moz-calc(100% - 20px);
}

table thead tr th, table tbody tr td {
	padding:1px!important;
}
table tbody tr td input {
	border:none!important;
}

.campo p{
    line-height: 150%;
}
</style>
<%
if getForm("Tipo")=4 or getForm("Tipo")=3 then
	FTipo = "L"
else
	FTipo = "AE"
end if
session("FP"&FTipo) = FormID
%>
<input type="hidden" name="FormID" id="FormID" value="<%=formID%>" />
<input type="hidden" name="ModeloID" id="ModeloID" value="<%=ModeloID%>" />
<script>
  var gridster = [];
</script>

<!--#include file="connect.asp"-->
<%
	I = req("ModeloID")
%>
<!--#include file="newFormEstilo.asp"-->
  <div id="demo-0" class="gridster" style="width:880px">
    <ul>
    <%
	set campos = db.execute("select c.*, f.LadoALado from buicamposforms c LEFT JOIN buiforms f on f.id=c.FormID where c.FormID="&I&" and c.GrupoID=0 and c.TipoCampoID not in(7, 11) order by c.Ordem")
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
	  Ordem = campos("Ordem")
	  ValorPadrao = ""
	  if UsarPreenchido="S" and TipoCampoID<>9 and TipoCampoID<>13 then
	  		if FieldExists(f,""&campos("id")&"") then
	      		ValorPadrao = f(""&campos("id")&"")
			end if
	  else
		  ValorPadrao = campos("ValorPadrao")
	  end if
	  GrupoID = campos("GrupoID")
	  Largura = campos("Largura")

	  set getImpressos = db.execute("select * from Impressos")
      MarcaDagua = ""
      if not getImpressos.EOF then

          Unidade = session("UnidadeID")
          set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND (pt.profissionais like '%|ALL|%' OR pt.profissionais LIKE '%|"&session("idInTable")&"|%') AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
          if not timb.eof then
                  if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
                  if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
                  if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
                  if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

          end if
          if lcase(session("table"))="profissionais" then
              set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND pt.profissionais like '%|"&session("idInTable")&"|%' AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
              if not timb.eof then
                  if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
                  if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
                  if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
                  if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

              end if
          end if
      end if
      %>
<style>
.ready .campo{
    <%=fontFamily%>
}
</style>
      <%
	  
	  if TipoCampoID=15 then
	  	if UsarPreenchido="S" then
			ValorPadrao = f(""&campos("ValorPadrao")&"")
		else
		  	ValorPadrao = 12345567890
		end if
	  end if
	  if TipoCampoID=5 and ValorPadrao="" then
	  	set valpad = db.execute("select * from buiopcoescampos where CampoID="&campos("id")&" and Selecionado='S'")
		if not valpad.eof then
		  	ValorPadrao = valpad("id")
		end if
	  end if
	  
	  if not isnull(ValorPadrao) then
	  	ValorPadrao = replaceTags(ValorPadrao, PacienteID, session("UserID"), session("UnidadeID"))
	  end if

		if TipoCampoID=3 then
			form_imgSRC = arqEx(ValorPadrao,"FORMULARIOS")&"&imageFallback=FALSE&dimension=full"
		end if
	  %>
      <!--#include file="formsCompiladorCampoPreenchidoPrint.asp"-->
	  <%
campos.movenext
wend
campos.close
set campos=nothing
%>
</ul>
</div>
<script>
var gridster0 = null;
var gridster1 = null;

  $(function(){
	gridster0 = $("#demo-0 > ul").gridster({
		namespace: '#demo-0',
		widget_base_dimensions: [50, 25],
		widget_margins: [4, 4]
	}).data('gridster').disable();
	<%
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
					console.log('draggable start')
					setTimeout(function () {
					}, 1000)
				}
			}
		}).data('gridster');
	<%
	next
	%>
  });
$(".campoInput").change(function(){
	$.post("saveNewForm.asp?FormID="+ $("#FormID").val() +"&ModeloID=<%=ModeloID%>&PacienteID=<%=PacienteID%>&CampoID="+$(this).attr('data-campoid'), {Valor:$(this).val()}, function(data, status){ eval(data) });
});
$(".memorando").blur(function(){
	$.post("saveNewForm.asp?FormID="+ $("#FormID").val() +"&ModeloID=<%=ModeloID%>&PacienteID=<%=PacienteID%>&CampoID="+$(this).attr('data-campoid'), {Valor:$(this).html()}, function(data, status){ eval(data) });
});
$(".campoCheck").click(function(){
	var vars = [];
	$.each($("input[name='"+$(this).attr('name')+"']:checked"), function(){            
		vars.push($(this).val());
	});
	$.post("saveNewForm.asp?FormID="+ $("#FormID").val() +"&ModeloID=<%=ModeloID%>&PacienteID=<%=PacienteID%>&CampoID="+$(this).attr('data-campoid'), {Valor:vars.join(", ")}, function(data, status){ eval(data) });
});

function saveTabVal(n, v){
	$.post("saveTabVal.asp?valPar="+n, {valor:v}, function(data, status){  });
}

function addRowPreen(CampoID, Acao, ValID){
	$.post("addRowPreen.asp?CampoID="+CampoID+"&ModeloID=<%=I%>&ValID="+ValID+"&FormPreenID="+ $("#FormID").val() +"&Acao="+Acao, '', function(data, status){ $("#tb_"+CampoID).html(data) });
}

</script>