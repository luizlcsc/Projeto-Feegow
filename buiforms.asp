<!--#include file="connect.asp"-->
<style type="text/css">
.modal-dialog{
	width:80%;
	min-width:380px;
	max-width:990px;
}
</style>
<div id="modal-table" class="modal fade" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" id="modal">
        Carregando...
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<%
id = req("I")

if req("Convert")="1" then
	db_execute("update buiforms set Versao=2 where id="&id)
	db_execute("update buicamposforms set pleft=4, ptop=2, colunas=7, linhas=3 where FormID="&id)
end if

tableName = req("P")
if id="N" then
	sqlVie = "select id, sysUser, sysActive, Versao from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
	set vie = db_execute(sqlVie)
	if vie.eof then
		db.execute("insert into "&tableName&" (sysUser, sysActive, Versao) values ("&session("User")&", 0, 2)")
		set vie = db.execute(sqlVie)
		sqlCreate = " CREATE TABLE `_"&vie("id")&"` (                                                          	"&chr(13)&_
					" 	`id` INT(11) NOT NULL AUTO_INCREMENT,                                       			"&chr(13)&_
					" 	`PacienteID` INT(11) NULL DEFAULT NULL,                                     			"&chr(13)&_
					" 	`DataHora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,                    			"&chr(13)&_
					" 	`sysUser` INT(11) NULL DEFAULT NULL,                                        			"&chr(13)&_
					" 	`DHUp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,			"&chr(13)&_
					" 	PRIMARY KEY (`id`) USING BTREE,                                             			"&chr(13)&_
					" 	index `PacienteID` (`PacienteID`),                                          			"&chr(13)&_
					" 	index `sysUser` (`sysUser`)                                                 			"&chr(13)&_
					" )                                                                            				"

		db_execute(sqlCreate)
	else
		if vie("Versao")=1 then
			db_execute("update buiforms set Versao=2 where id="&vie("id"))
		end if
	end if
	if vie("Versao")=1 then
		response.Redirect("?P="&tableName&"&I="&vie("id")&"&Pers="&req("Pers"))
	elseif vie("Versao")=2 then
		response.Redirect("?P=newform&I="&vie("id")&"&Pers="&req("Pers"))
	end if
else
	set data = db.execute("select * from "&tableName&" where id="&id)
	if data.eof then
		response.Redirect("?P="&tableName&"&I=N&Pers="&req("Pers"))
	end if
end if
set reg = db.execute("select * from buiforms where id="&req("I"))
if reg("Versao")=2 then
	response.Redirect("?P=newform&I="&reg("id")&"&Pers="&req("Pers"))
end if
%>
<input type="hidden" name="DadosAlterados" id="DadosAlterados" value="" />
<form method="post" id="frmForm" name="frmForm" action="save.asp">
	<input type="hidden" name="I" value="<%=req("I")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />
    <div class="row">
        <div class="col-md-10">
            <ul class="breadcrumb">
                <li>
                    
                    </li>
            </ul><!-- .breadcrumb -->
        </div>
        <div class="col-md-2">
        <%
		if (reg("sysActive")=1 and aut(lcase(req("P"))&"A")=1) or (reg("sysActive")=0 and aut(lcase(req("P"))&"I")=1) then
		%>
            <button class="btn btn-block btn-primary" id="save">
                <i class="icon-save"></i> Salvar
            </button>
        <%
		end if
		%>
        </div>
	</div>
    <div class="row">
    	<%=quickField("text", "Nome", "Nome do Formul&aacute;rio", 4, reg("Nome"), "", "", " required")%>
    	<%=quickField("simpleSelect", "Tipo", "Tipo", 3, reg("Tipo"), "select * from cliniccentral.buitiposforms where sysActive=1 order by NomeTipo", "NomeTipo", "")%>
    	<%=quickField("multiple", "Especialidade", "Especialidades", 3, reg("Especialidade"), "select * from especialidades order by especialidade", "especialidade", " data-placeholder='Selecione as especialidades'")%>
        <div class="col-md-2">
        	<label>&nbsp;</label><br /><button type="button" class="btn btn-warning btn-sm btn-block" onclick="permissoes()"><i class="far fa-lock"></i> Permiss&otilde;es</button>
        </div>
    </div>
    <hr />
</form>

<style type="text/css">
	#folha {
		font-family: Arial, sans-serif;
		list-style-type: none;
		margin: 0px;
		padding: 0px;
		width: 760px;
		height:1200px;
		background-color:#FFFFFF;
		border:1px solid #000;
		position:relative;
/*		padding:7px;*/
	}
	.campos {
		cursor: move;
		position:absolute;
		margin: 0;
		border: 2px dotted #F7F7F7;
		text-align: center;
		padding: 10px;
		background-color: #fff;
		text-align:left;
		min-height:80px!important;
	}
	.campos:hover {
		border:2px dotted #999999;
	}
	.EditaCampo {
		display:none;
		padding:7px;
		width:600px;
		height:400px;
		margin-left:-300px;
		margin-top:-200px;
		background-color:#FFF;
		left:50%;
		top:50%;
		position:fixed;
		border:3px solid #999;
		overflow:scroll;
		overflow-x:hidden;
		z-index:10000000000000;
		-webkit-border-radius: 10px;
		-moz-border-radius: 10px;
		border-radius: 10px;
		box-shadow: 1px 2px 6px rgba(0, 0, 0, 0.5);
		-moz-box-shadow: 1px 2px 6px rgba(0, 0, 0, 0.5);
		-webkit-box-shadow: 1px 2px 6px rgba(0, 0, 0, 0.5);
	}
	#Ferramentas {
		position:fixed;
		width:155px;
		right:0;
		background-color:#f3f3f3;
		padding:3px;
		list-style:none;
	}
	#Ferramentas li {
		background-color:#FFFFFF;
		margin:2px;
		padding:7px;
		font-weight:bold;
		cursor:pointer;
		float:left;
	}
	#Salvando {
		position:fixed;
		background-color:#FFFFFF;
		bottom:0;
		right:0;
		display:none;
		border:1px dotted #CCC;
		padding:3px;
		font-weight:bold;
		transition: all 0.25s ease-in-out;
	}
	#Atualizando {
		height:40px;
		display:none;
		padding:7px;
		width:140px;
		background-color:#FFF;
		border:1px solid #777;
		left:50%;
		top:50%;
		margin-left:-45px;
		margin-top:-30px;
		position:fixed;
		border:3px solid #999;
		z-index:10000000000001;
	}
</style>

<script language="javascript" src="ajax.js"></script>
<script language="javascript" src="fcnAJX.js"></script>
<script language="javascript" src="ajxFrm.js" charset="utf-8"></script>
<!--#include file="connect.asp"-->
<!--#include file="modalnarrow.asp"-->

<div class="row">
  <form class="form-inline" id="corpoform">

<%
response.Charset="utf-8"
FormID = req("I")
NomeForm=replace(ref("NomeForm"),"'","")
if ref("E")="E" then
	if NomeForm="" then
		erro="Preencha o nome do formul&aacute;rio."
	end if
	set vca=db.execute("select * from buiForms where Nome like '"&NomeForm&"'")
	if not vca.EOF then
		erro="J&aacute; existe um formul&aacute;rio com este nome."
	end if
	if erro<>"" then
		response.Write("<strong style=""color:#ff0000"">"&erro&"</strong>")
	else
		if FormID="" then
			db_execute("insert into buiForms (Nome) values ('"&NomeForm&"')")
			set pUlt=db.execute("select * from buiForms order by id desc LIMIT 1")
			db_execute("CREATE  TABLE _"&pult("id")&" (`id` INT NOT NULL AUTO_INCREMENT , PRIMARY KEY (`id`) ) ENGINE = MyISAM DEFAULT CHARACTER SET = utf8")
			response.Redirect("?F="&pUlt("id")&"&Open=Re")
		else
			set pF=db.execute("select * from buiForms where id = '"&replace(FormID,"'","''")&"'")
			''db_execute("ALTER TABLE `"&W&"_"&pF("Nome")&"` RENAME TO  `"&W&"_"&replace(ref("NomeForm"),"'","")&"`")
			''db_execute("update buiForms set Nome='"&replace(ref("NomeForm"),"'","''")&"' where id = '"&replace(FormID,"'","''")&"'")
			%><script language="javascript">alert('N�o sei o que deveria acontecer aqui (DefaultForm.asp, Linha 51)');</script><%
		end if
	end if
end if
if FormID<>"" then
	set pF=db.execute("select * from buiForms where id = '"&replace(FormID,"'","''")&"'")
	if not pF.EOF then
		NomeForm=pF("Nome")
		TipoTitulo=pF("TipoTitulo")
		Especialidade=pF("Especialidade")
	end if
end if

	%><ul id="Ferramentas" class="campos">
	<li style="background-color:#093; width:100%; color:#fff; font-weight:bold">
    	INSERIR CAMPO
    </li>
	<%
	set pFields=db.execute("select * from cliniccentral.buitiposcamposforms where id<>7 order by id")
	while not pFields.EOF
		%><li onClick="criaCampo(<%=pFields("id")%>, 0, 'A', '<%=FormID%>', $(window).scrollTop());"><span class="tooltip-error" title="" data-placement="top" data-rel="tooltip" data-original-title="<%=pFields("TipoCampo")%>"><img align="absmiddle" src="./images/campo<%=pFields("id")%>.jpg" /></span></li><%
	pFields.moveNext
	wend
	pFields.close
	set pFields=nothing
	%>
		<li style="width:100%; display:none"><label><input type="checkbox" id="TipoTitulo" value="S" onChange="propForm(<%=FormID%>);"<%if TipoTitulo="L" then%> checked="checked"<%end if%> /> 
		T&iacute;tulos ao lado </label>
		</li>
</ul><%

if FormID<>"" then
	%>

  <div id="EditaCampo" class="EditaCampo"></div>
  <div id="Atualizando"><img src="newImages/atualizando.gif" border="0" align="absmiddle" /> Processando...</div>
    <div id="CamposForm"></div>

<script language="javascript">
criaCampo(0, 0, 'V', '<%=FormID%>', 0)
</script>
<%end if%>

</form>
</div>
<a href="./?<%=request.QueryString%>&Convert=1" class="btn btn-xs btn-warning">Converter Formul&aacute;rio</a>
<div id="Salvando">

</div>
<script>
	$(document).ready(function ()
	{
		$(function() {
			$(".campos").draggable({ snap: '.campos', snapMode: 'outer' });
		});
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
function permissoes(){
	$.post("formPermissoes.asp?F=<%=FormID%>", '', function(data, status){
  		   $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
		   $("#modal-table").modal('show');
		   setTimeout(function(){$("#modal").html(data);}, 1000);
	});
}
</script>
