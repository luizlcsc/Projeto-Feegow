<style type="text/css">
	#folha {
		font-family: Arial, sans-serif;
		list-style-type: none;
		margin: 0px;
		padding: 0px;
		width: 730px;
		height:1200px;
		background-color:#FFFFFF;
		border:1px solid #000;
	}
	.campos {
		cursor: move;
		position:absolute;
		margin: 0;
		border: 1px dotted #999999;
		text-align: center;
		padding: 5px;
		background-color: #fff;
		text-align:left;
		min-height:65px!important;
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
		background-color:#CCC;
		padding:3px;
		list-style:none;
	}
	#Ferramentas li {
		background-color:#FFFFFF;
		margin:2px;
		padding:2px;
		font-weight:bold;
		cursor:pointer;
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

<script type="text/javascript" src="js/jquery-1.2.6.js"></script>
<script type="text/javascript" src="js/ui.core.js"></script>
<script type="text/javascript" src="js/ui.draggable.js"></script>

<script language="javascript" src="ajax.js"></script>
<script language="javascript" src="fcnAJX.js"></script>
<script language="javascript" src="ajxFrm.js" charset="utf-8"></script>
<style type="text/css">
<!--
body {
	background-color: #F4F4F4;
	margin:7px;
	margin: 0;
}
#tabela tr:hover
{
	background-color:#E0F5FC;
}
-->
</style>
<!--#include file="connect.asp"-->
</head>
<body>
<%
response.Charset="utf-8"
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
		if req("F")="" then
			db_execute("insert into buiForms (Nome) values ('"&NomeForm&"')")
			set pUlt=db.execute("select * from buiForms order by id desc LIMIT 1")
			db_execute("CREATE  TABLE _"&pult("id")&" (`id` INT NOT NULL AUTO_INCREMENT , PRIMARY KEY (`id`) ) ENGINE = MyISAM DEFAULT CHARACTER SET = utf8")
			response.Redirect("?F="&pUlt("id")&"&Open=Re")
		else
			set pF=db.execute("select * from buiForms where id = '"&replace(req("F"),"'","''")&"'")
			''db_execute("alter TABLE `"&W&"_"&pF("Nome")&"` RENAME TO  `"&W&"_"&replace(ref("NomeForm"),"'","")&"`")
			''db_execute("update buiForms set Nome='"&replace(ref("NomeForm"),"'","''")&"' where id = '"&replace(req("F"),"'","''")&"'")
			%><script language="javascript">alert('N�o sei o que deveria acontecer aqui (DefaultForm.asp, Linha 51)');</script><%
		end if
	end if
end if
if req("F")<>"" then
	set pF=db.execute("select * from buiForms where id = '"&replace(req("F"),"'","''")&"'")
	if not pF.EOF then
		NomeForm=pF("Nome")
		TipoTitulo=pF("TipoTitulo")
		Especialidade=pF("Especialidade")
	end if
end if

	%><ul id="Ferramentas" class="campos">
	
  <li>
  <div align="center" style="padding:4px; background-color:#096; color:#FFF; cursor:pointer; font-weight:bold" onClick="document.getElementById('Especialidades').style.display='block';">
  Especialidades
  </div>
  <div id="Especialidades" style="display:none; background-color:#FFF; border:#999 4px solid; width:300px; height:203px; padding:1px; position:absolute; margin-left:-150px;">
    <div>
    <input type="button" value="FECHAR" style="width:97%;" onClick="document.getElementById('Especialidades').style.display='none';" />
    </div>
    <div style="width:280px; height:175px; padding:1px; overflow:scroll; overflow-x:hidden">
    <table width="100%">
    <%
	set pesps=db.execute("select * from especialidades where not especialidade like '' order by especialidade")
	while not pesps.eof
	%><tr><td><input type="checkbox" id="esp<%=pesps("id")%>" onClick="especialidades(<%=req("F")%>, <%=pesps("id")%>)"<%if inStr(Especialidade,"|"&pesps("id")&"|")>0 then%> checked="checked"<%end if%> /></td><td><%=pesps("especialidade")%></td></tr>
    <%
	pesps.movenext
	wend
	pesps.close
	set pesps=nothing%>
    </table>
    </div>
  </div>
  </li>
	
	
		<li><label><input type="checkbox" id="TipoTitulo" value="S" onChange="propForm(<%=req("F")%>);"<%if TipoTitulo="L" then%> checked="checked"<%end if%>> 
		T&iacute;tulos ao lado </label>
		</li>
	<%
	set pFields=db.execute("select * from cliniccentral.buiTiposCamposForms where id<>3 and id<>7 order by id")
	while not pFields.EOF
		%><li onClick="criaCampo(<%=pFields("id")%>, 0, 'A', '<%=req("F")%>');"><img align="absmiddle" src="./images/campo<%=pFields("id")%>.jpg"> <%=pFields("TipoCampo")%></li><%
	pFields.moveNext
	wend
	pFields.close
	set pFields=nothing
	%>
</ul><%

if req("F")<>"" then
	%>

  <div id="EditaCampo" class="EditaCampo"></div>
  <div id="Atualizando"><img src="newImages/atualizando.gif" border="0" align="absmiddle"> Processando...</div>
    <div id="CamposForm"></div>
</div>

<script language="javascript">
criaCampo(0, 0, 'V', '<%=req("F")%>')

/*
var i=0;
var x="";
var numero=document.getElementById('numero').value;
while (i<numero)
  {
	  var x=x + "The number is " + i + "<br>";
	  i++;
  }
  alert(x);*/
</script>
<%end if%>
<div id="Salvando">

</div>
<script>
	$(document).ready(function ()
	{
		$(function() {
			$(".campos").draggable({ snap: '.campos', snapMode: 'outer' });
		});
	});



</script>
