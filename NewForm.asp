<!--#include file="connect.asp"-->
<!--#include file="modalNarrow.asp"-->
<!--#include file="modal.asp"-->

<link rel="stylesheet" type="text/css" media="all" href="assets/css/curva.css" />
<script src="assets/js/grafico.js"></script>
<script src="curvaJS.asp"></script>


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

#demo-1 ul{
    border: 1px solid #CCC;
    min-height:1000px;
}
.gs-w:hover{
    border:1px dotted #0094ff!important;
}
</style>
<%
tableName = "buiforms"
I = req("I")
	if I="N" then
		sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
		set vie = db.execute(sqlVie)
		if vie.eof then
			db_execute("insert into "&tableName&" (sysUser, sysActive) values ("&session("User")&", 0)")
			set vie = db.execute(sqlVie)
			db_execute("CREATE TABLE `_"&vie("id")&"` ("&_
			"`id` INT(11) NOT NULL AUTO_INCREMENT,"&_
			"`PacienteID` INT(11) NULL DEFAULT NULL,"&_
			"`DataHora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"&_
			"`sysUser` INT(11) NULL,"&_
            "`DHUp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, "&_
			"PRIMARY KEY (`id`)), "&_
			"INDEX `PacienteID` (`PacienteID`) USING BTREE, "&_
			"INDEX `sysUser` (`sysUser`) USING BTREE;")
		end if
		response.Redirect("?P=newform&I="&vie("id")&"&Pers="&req("Pers"))
	else
		set data = db.execute("select * from "&tableName&" where id="&I)
		if data.eof then
			response.Redirect("?P=newform&I=N&Pers="&req("Pers"))
		end if
	end if

set reg = db.execute("select * from buiforms where id="&I)
%>

    
    <%' call quickField("editor", "Cabecalho", "Cabe&ccedil;alho", 10, Cabecalho, "100", "", "") %>
    
    

<input type="hidden" name="DadosAlterados" id="DadosAlterados" value="" />
<form method="post" id="frmForm" name="frmForm" action="save.asp">
<%=header("buiforms", "Edição de Modelo Formulário", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
	<input type="hidden" name="NewForm" value="1" />
	<input type="hidden" name="I" value="<%=I%>" />
	<input type="hidden" name="P" value="buiforms" />
    <div class="panel mt10">
        <div class="panel-body">
    	    <%=quickField("text", "Nome", "Nome do Formul&aacute;rio", 4, reg("Nome"), "", "", " required")%>
    	    <%=quickField("simpleSelect", "Tipo", "Tipo", 2, reg("Tipo"), "select * from buitiposforms where sysActive=1 order by NomeTipo", "NomeTipo", "")%>
    	    <%=quickField("multiple", "Especialidade", "Especialidades", 4, reg("Especialidade"), "select * from especialidades order by especialidade", "especialidade", " data-placeholder='Selecione as especialidades'")%>
            <div class="col-md-2">
                <%
                recursoPermissaoUnimed = recursoAdicional(12)

                if (recursoPermissaoUnimed=4 and aut("permissoesformulariosI")=1) or recursoPermissaoUnimed<>4 then
                %>
        	    <label>&nbsp;</label><br /><button type="button" class="btn btn-warning btn-block" onclick="permissoes()"><i class="far fa-lock"></i> Permiss&otilde;es</button>
        	    <%end if%>
            </div>
        </div>
    </div>


    <div class="row">
        <div class="col-md-12">
            <!--#include file="drag.asp"-->
        </div>
    </div>
    <div style="height:400px"></div>
</form>

<script type="text/javascript">
	$(document).ready(function ()
	{
/*		$(function() {
			$(".campos").draggable({ snap: '.campos', snapMode: 'outer' });
		});*/
		<%call formSave("frmForm", "save", "$(""#DadosAlterados"").attr('value', '');")%>
	});


window.onbeforeunload = function (e) {
	if($("#DadosAlterados").val()=="S"){
		  var message = "Dados foram alterados.\n\nTem certeza de que deseja sair sem salvar?.",
		  e = e || window.event;
		  // For IE and Firefox
		  if (e) {
			e.returnValue = message;
		  }
		
		  // For Safari
		  return message;
	}
};
$(".form-control").change(function(){
	$("#DadosAlterados").val("S");
});

function estilo(){
	$.post("formEstilo.asp?FormID=<%=I%>", '', function(data, status){

		$("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
		$("#modal-table").modal('show');
		setTimeout(function(){$("#modal").html(data);}, 1000);

	});
}

function refLay(){
	$.post("gridster.asp?I=<%=req("I")%>", "", function(data, status){ $("#divLay").html(data) });
}

function editField(I){
	$.post("editField.asp?I="+I, '', function(data, status){ 
		$("#modal-table").modal("show");
		$("#modal").html(data);
	 });
}

function menu(GrupoID){
	$.post("menuForms.asp?GrupoID="+GrupoID, '', function(data, status){ $("#modal-narrow").modal("show"); $("#modal-narrow-content").html(data) });
}
function addRow(CampoID, FormID, Acao){
	$.post("addRow.asp?CampoID="+CampoID+"&FormID="+FormID+"&Acao="+Acao, '', function(data, status){ eval(data) });
}

/*
$(".btn-20").click(function(){
	$.post("teste.asp", '', function(data, status){ 
	gridster[0].disable(); 
	gridster[0].disable_resize();
	$(".imagem").html(data);
	$(".imagem").focus();
	})
});
*/
function permissoes(){
	$.post("formPermissoes.asp?F=<%=I%>", '', function(data, status){
  		   $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
		   $("#modal-table").modal('show');
		   setTimeout(function(){$("#modal").html(data);}, 1000);
	});
}

$("#Prior").change(function(){
    $.post("saveFormModel.asp?I=<%= I %>", $("#Prior").serialize(), function (data) { eval(data) });
});

</script>
