<!DOCTYPE html>
<!--#include file="connect.asp"-->
<%
set pCampo=db.execute("select * from buiCamposForms where id = '"&req("I")&"'")
TipoCampoID=pCampo("TipoCampoID")
set pTipoCampo=db.execute("select * from cliniccentral.buiTiposCamposForms where id="&TipoCampoID)
%>
<div class="modal-header">
    <button class="bootbox-close-button close" data-dismiss="modal" type="button">&times;</button>
    <h4 class="modal-title"><img align="absmiddle" src="images/campo<%=TipoCampoID%>.jpg" /> Edi&ccedil;&atilde;o de Campo <small>&raquo; <%=server.HTMLEncode(pTipoCampo("TipoCampo"))%></small></h4>
</div>
<div class="modal-body">
    <div class="bootbox-body">

<form name="frmec1" id="frmec1" action="" method="post">
<table width="100%">
<tr>
  <td width="16%">
Texto </td>
  <td width="84%">
<input type="text" class="form-control" name="RotuloCampo" size="40" value="<%=pCampo("RotuloCampo")%>" id="RotuloCampo" /></td></tr>
<%
if TipoCampoID=1 then
	%>
	<tr><td>Largura do campo</td>
	<td><input type="Largura" class="form-control" value="<%=pCampo("Largura")%>" name="Largura" id="Largura" /></td></tr>
	<%
end if
if TipoCampoID=8 then
%>
<tr>
  <td nowrap="nowrap">N&uacute;mero de Linhas</td>
  <td><input type="text" name="MaxCarac" size="10" class="form-control" maxlength="10" value="<%=pCampo("MaxCarac")%>" id="MaxCarac" /></td>
</tr>
<tr><td nowrap="nowrap" colspan="2">
Valor Padr&atilde;o<br>
<textarea name="ValorPadrao" class="form-control" cols="40" rows="3" id="ValorPadrao"><%=pCampo("ValorPadrao")%></textarea>
	<script>
	$(function () {  
		CKEDITOR.config.height = 300;
<%
if pCampo("Checado")="S" then
	%>
		$('#ValorPadrao').ckeditor();
	<%
end if%>
	});
	
	function chama(checado){
		if(checado==true){
			$('#ValorPadrao').ckeditor();
		}else{
			CKEDITOR.instances['ValorPadrao'].destroy();
		}
	}
	</script>
</td></tr>
<tr>
  <td></td>
  <td nowrap="nowrap">
    <label><input type="checkbox" name="Checado" class="ace" value="S" id="Checado"<%if pCampo("Checado")="S" then%> checked="checked"<%end if%> onclick="chama($(this).prop('checked'))" /><span class="lbl"> Usar editor especial</span></label>
  </td>
</tr>
<%
end if
if TipoCampoID=11 then
%>
<tr>
  <td nowrap="nowrap">Altura</td>
  <td><input type="text" name="MaxCarac" size="10" maxlength="3" value="<% If isNull(pCampo("MaxCarac")) or pCampo("MaxCarac")="" Then %>250<%else%><%=pCampo("MaxCarac")%><% End If %>" id="MaxCarac" /></td>
</tr>
<tr>
  <td>Tipo</td>
  <td>
    <label><input type="radio" class="ace" name="Grafico" value="L" onclick="document.getElementById('Checado').value=this.value;" id="GraficoLinhas"<%if isNull(pCampo("Checado")) or pCampo("Checado")="L" then%> checked="checked"<%end if%> /><img src="newImages/Linhas.png" align="absmiddle" /><span class="lbl"> Linhas</span></label>
	<label><input type="radio" class="ace" name="Grafico" value="B" onclick="document.getElementById('Checado').value=this.value;" id="GraficoBarras"<%if pCampo("Checado")="B" then%> checked="checked"<%end if%> /><span class="lbl"><img src="newImages/Barras.png" align="absmiddle" /> Barras</span></label>
	<label><input type="radio" class="ace" name="Grafico" value="P" onclick="document.getElementById('Checado').value=this.value;" id="GraficoPizza"<%if pCampo("Checado")="P" then%> checked="checked"<%end if%> /><span class="lbl"><img src="newImages/Pizza.png" align="absmiddle" /> Pizza</span></label>
	<input type="hidden" name="Checado" id="Checado" value="<%if isNull(pCampo("Checado")) then%>L<% Else %><%=pCampo("Checado")%><% End If %>" />
  </td>
</tr>
<tr>
  <td>Tabela de Valores</td>
  <td>
  	<select name="ValorPadrao" id="ValorPadrao" class="form-control">
		<%
		set pTabs=db.execute("select * from buiCamposForms where TipoCampoID=9 and FormID="&pCampo("FormID")&" order by RotuloCampo")
		while not pTabs.EOF
			%><option value="<%=pTabs("id")%>"<%if cstr(pTabs("id"))=pCampo("ValorPadrao") then%> selected="selected"<%end if%>><%=pTabs("RotuloCampo")%></option>
			<%
		pTabs.movenext
		wend
		pTabs.close
		set pTabs=nothing
		%>
  	</select>
  </td>
</tr>
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
if TipoCampoID=1 then
%>
<tr>
  <td nowrap="nowrap">M&aacute;x. Carac.</td>
  <td><input type="text" name="MaxCarac" class="form-control" size="10" maxlength="10" value="<%=pCampo("MaxCarac")%>" id="MaxCarac" /></td>
</tr>
<%
End If
if TipoCampoID=1 or TipoCampoID=2 then
%>
<tr><td nowrap="nowrap">
Valor Padr&atilde;o
</td><td>
<input type="text" name="ValorPadrao" class="form-control" size="40" value="<%=pCampo("ValorPadrao")%>" id="ValorPadrao" />
</td></tr>
<tr><td nowrap="nowrap">
Texto Complementar
</td><td>
<input type="text" name="Texto" class="form-control" size="40" value="<%=pCampo("Texto")%>" id="Texto" />
</td></tr>
<%
end if
if TipoCampoID=4 or TipoCampoID=5 then
%>
<tr>
  <td nowrap="nowrap">Organiza&ccedil;&atilde;o</td>
  <td>
  <select name="Checado" id="Checado" class="form-control">
  <option value="S"<%if pCampo("Checado")="S" then%> selected="selected"<% End If %>>Um por linha</option>
  <option value=""<%if pCampo("Checado")="" then%> selected="selected"<% End If %>>Lado a lado</option>
  </select>  </td>
</tr>
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
%>
<tr>
  <td nowrap="nowrap">Largura</td>
  <td>
  <select id="Tamanho" name="Tamanho" class="form-control">
  <option value="1"<%if pCampo("Tamanho")="1" then%> selected="selected"<%end if%>>100%</option>
  <option value="3"<%if pCampo("Tamanho")="3" then%> selected="selected"<%end if%>>75%</option>
  <option value="2"<%if pCampo("Tamanho")="2" then%> selected="selected"<%end if%>>50%</option>
  <option value="4"<%if pCampo("Tamanho")="4" then%> selected="selected"<%end if%>>25%</option>
  </select></td>
</tr>
</table>
</form>
<%
if TipoCampoID=3 then
	if pCampo("ValorPadrao")="" or isnull(pCampo("ValorPadrao")) then
		divDisplayUploadFoto = "block"
		divDisplayFoto = "none"
	else
		divDisplayUploadFoto = "none"
		divDisplayFoto = "block"
	end if
	Parametros = "P=buiCamposForms&I="&pCampo("id")&"&Col=ValorPadrao"
	%>
	<tr>
    	<td>Imagem padr&atilde;o</td>
        <td>
        <form id="frm" method="post" name="frm" action="">
            <div id="divAvatar">
                    <div id="divDisplayUploadFoto" style="display:<%=divDisplayUploadFoto%>">
                        <input type="file" name="Foto" id="Foto" />
                    </div>
                    <div id="divDisplayFoto" style="display:<%= divDisplayFoto %>">
                        <img id="avatarFoto" src="uploads/<%=pCampo("ValorPadrao")%>" class="img-thumbnail" width="100%" />
                        <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; margin-left:-27px; margin-top:8px;"><i class="far fa-trash"></i></button>
                    </div>
            </div>
		</form>
        </td>
    </tr>
	<%
end if
%>
<form method="post" action="" name="frmec2" id="frmec2">
<table width="100%">
<%
if TipoCampoID=4 or TipoCampoID=5 or TipoCampoID=6 then
%>
<tr>
  <td>Valores</td>
  <td><div id="ValoresCampos" style="height:190px; overflow:scroll"><%=Server.Execute("ValoresCampos.asp")%></div></td>
</tr>
<%
end if
if TipoCampoID=9 then
	InformaAjaxTabela="<!--[ChamaTabela]-->"
%>
<tr><td>N&deg; de Colunas</td><td><input name="Colunas" type="text" class="form-control" id="Colunas" onkeyup="chamaTabela(<%=req("I")%>);" value="<%=pCampo("Colunas")%>" size="2" maxlength="2" /></td></tr>
<tr><td>N&deg; de Linhas</td><td><input name="Linhas" type="text" class="form-control" id="Linhas" onkeyup="chamaTabela(<%=req("I")%>);" value="<%=pCampo("Linhas")%>" size="2" maxlength="2" /></td></tr>
<tr>
  <td colspan="2"><div id="FormTabelaArray" style="height:190px; overflow:scroll"></div></td>
</tr>
<%
end if
%>
</table>
</form>
<div class="clearfix form-actions">
  <button type="button" class="btn btn-primary" onclick="salvaEdicao(<%=pCampo("id")%>, '<%=req("W")%>', '<%=req("F")%>', 0, 'S');"><i class="far fa-save"></i>Salvar</button>
  <%
  if TipoCampoID=4 or TipoCampoID=5 or TipoCampoID=6 then
  	%><input type="button" class="btn btn-success" value="Adicionar Op&ccedil;&atilde;o" onclick="adicionaOpcao('A', <%=req("I")%>);" /><%
  end if
  %>
</div>

  </div>
</div>

<script type="text/javascript">
//js exclusivo avatar
function removeFoto(){
	if(confirm('Tem certeza de que deseja excluir esta imagem?')){
		$.ajax({
			type:"POST",
			url:"FotoUploadSave.asp?<%=Parametros%>&Action=Remove",
			success:function(data){
				$("#divDisplayUploadFoto").css("display", "block");
				$("#divDisplayFoto").css("display", "none");
				$("#avatarFoto").attr("src", "uploads/");
				$("#Foto").ace_file_input('reset_input');
			}
		});
	}
}

	$(function() {
		var $form = $('#frm');
		var file_input = $form.find('input[type=file]');
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
					/*if(! (/\.(jpe?g|png|gif)$/i).test(file) ) {
						alert('Please select an image file!');
						return false;
					}*/
				}
				else {
					var type = $.trim(file.type);
					/*if( ( type.length > 0 && ! (/^image\/(jpe?g|png|gif)$/i).test(type) )
							|| ( type.length == 0 && ! (/\.(jpe?g|png|gif)$/i).test(file.name) )//for android's default browser!
						) {
							alert('Please select an image file!');
							return false;
						}

					if( file.size > 110000 ) {//~100Kb
						alert('File size should not exceed 100Kb!');
						return false;
					}*/
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
				alert("There was an error");
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
	
function salvaEdicao(I, W, F, O, DisNo)
{
	$.ajax({
		type:"POST",
		url:"formsSalvaEdicao.asp?I="+I+"&W=0&F="+F+"&O="+O,
		data:$("#frmec1, #frmec2").serialize(),
		success: function(data){
			eval(data);
			if(document.getElementById('Linhas')!=null)
			{
				 arrJS(I);
			}
			criaCampo(I, W, 'V', F);
			if(DisNo=='S'){
				///***document.getElementById('EditaCampo').style.display='none';
				$("#modal-narrow").modal("hide");
			}
		}
	});
}
</script>

<%=InformaAjaxTabela%>