<%
'ON ERROR RESUME NEXT

if getForm("Tipo")=4 or getForm("Tipo")=3 then
	FTipo = "L"
else
	FTipo = "AE"
end if
session("FP"&FTipo) = FormID
%>
<input type="hidden" name="FormID" id="FormID" value="<%=formID%>" />
<input type="hidden" name="ModeloID" id="ModeloID" value="<%=ModeloID%>" />
<%
if FormID<>"N" then
	set preen = db.execute("select * from `_"&ModeloID&"` where id="&FormID)
	if not preen.eof then
		Data = preen("DataHora")
		Profissional = preen("sysUser")
		preenchido = "S"
		set formPerm = db.execute("select * from buipermissoes where FormID="&ModeloID)
		if formPerm.eof then
			if preen("sysUser")<>session("User") and preen("sysUser")<>0 then
				negadoX = "S"
			else
				negadoX = "N"
			end if
		else
			if (autForm(ModeloID, "AO", "","")=true and preen("sysUser")<>session("User")) or (autForm(ModeloID, "AP", "","")=true and preen("sysUser")=session("User")) then
				negadoX = "N"
			else
				negadoX = "S"
			end if
		end if
	end if
	%>
    <h5>Data: <%=formatdatetime(Data, 2)%><br>
    Profissional: <%=nameInTable(Profissional)%></h5>
	<%
end if
%>
<div id="folha">
<%

set pac = db.execute("select p.*, ec.EstadoCivil, s.NomeSexo as Sexo, g.GrauInstrucao, o.Origem from pacientes as p left join estadocivil as ec on ec.id=p.EstadoCivil left join sexo as s on s.id=p.Sexo left join grauinstrucao as g on g.id=p.GrauInstrucao left join origens as o on o.id=p.Origem where p.id="&PacienteID)
set pFor=db.execute("select * from buiCamposForms where FormID like '"&req("ModeloID")&"' order by Ordem, id")
while not pFor.EOF
	if preenchido="S" then
'		response.Write("{"&pFor("id")&"}")
		valor = preen(""&pFor("id")&"")
	else
		valor = pFor("ValorPadrao")
	end if
	
	
	valor = replaceTags(valor, PacienteID, session("User"), session("UnidadeID"))
	
	

	AlturaLi=60
	if pFor("Tamanho")=1 then
		LarguraLi="100%"
	elseif pFor("Tamanho")=2 then
		LarguraLi="50%"
	elseif pFor("Tamanho")=3 then
		LarguraLi="75%"
	else
		LarguraLi="25%"
	end if
	if pFor("TipoCampoID")=8 then
		if isNull(pFor("MaxCarac")) or not isNumeric(pFor("MaxCarac")) then
			Linhas=2
		else
			Linhas=pFor("MaxCarac")
		end if
		NumeroDivsQuebrado=Linhas/2
		NumeroDivs=cint(NumeroDivsQuebrado)
		if NumeroDivs<NumeroDivsQuebrado then
			NumeroDivs=NumeroDivs+1
		end if
		AlturaLi=AlturaLi*NumeroDivs
	end if
%>
<div class="campos" id="<%=pFor("id")%>" style="width:<%=LarguraLi%>; min-height:40px; top:<%=pFor("pTop")%>px; left:<%=pFor("pLeft")%>px;<%
if pFor("TipoCampoID")=11 then
	if isNumeric(pFor("MaxCarac")) then
		response.Write("height:"&pFor("MaxCarac")&"px")
	else
		response.Write("height:250px")
	end if
end if%>">
<%
if FormID<>"N" then
	set plemb = db.execute("select * from buiformslembrarme where PacienteID="&PacienteID&" and ModeloID="&ModeloID&" and FormID="&FormID&" and CampoID="&pFor("id"))
	if plemb.EOF then
		lembchecado = ""
	else
		lembchecado = " checked=""checked"""
	end if
end if
%>
<%if pFor("TipoCampoID")<>3 and pFor("TipoCampoID")<>12 then%><span class="badge badge-light lembrar"><i class="far fa-flag red"></i> <input class="ace postvalue" type="checkbox" id="lembrarme_<%=pFor("id")%>" name="lembrarme_<%=pFor("id")%>"<%= lembchecado %> /><span class="lbl"> Lembrar-me disso</span></span><%end if%>
	<%
	if TipoTitulo="B" or isNull(TipoTitulo) then
		abreDivTitulo="<div style=""padding-bottom:2px;"">"
		fechaDivTitulo="</div>"
	else
		abreDivTitulo=""
		fechaDivTitulo=""
	end if
	if pFor("TipoCampoID")<>10 then
		response.Write(abreDivTitulo&"<label>"&pFor("RotuloCampo")&"</label>"&fechaDivTitulo)
	end if
	if pFor("TipoCampoID")=1 then
	%>
    <div class="form-group"><input type="text" value="<%=valor%>" class="form-control postvalue" name="campo_<%=pFor("id")%>" size="<%=pFor("Largura")%>" maxlength="<%=pFor("MaxCarac")%>" placeholder="<%=pFor("Texto")%>"></div>
    <%
	elseif pFor("TipoCampoID")=2 then
	%>
    <div class="form-group"><%= quickField("datepicker", "campo_"&pFor("id"), "", "", valor, "postvalue", "", "") %>
     <%=pFor("Texto")%></div>
	<%
	elseif pFor("TipoCampoID")=3 then
		if valor="" or isnull(valor) then
			divDisplayUploadFoto = "block"
			divDisplayFoto = "none"
		else
			divDisplayUploadFoto = "none"
			divDisplayFoto = "block"
		end if
		Tamanho = pFor("Tamanho")

		if Tamanho=1 then
			alturaFoto = 500
			larguraFoto = 720
		elseif Tamanho=2 then
			alturaFoto = 375
			larguraFoto = 540
		elseif Tamanho=3 then
			alturaFoto = 250
			larguraFoto = 360
		elseif Tamanho=4 then
			alturaFoto = 125
			larguraFoto = 180
		end if
		%>
		<tr>
			<td></td>
			<td>
	        <div style="width:<%= larguraFoto %>px; height:<%= alturaFoto %>px; text-align:center; vertical-align:middle; border:1px solid #F4F4F4; padding:3px">
                <div id="<%=pFor("id")%>divDisplayUploadFoto" style="display:<%=divDisplayUploadFoto%>">
                    <input type="file" name="<%=pFor("id")%>" id="<%=pFor("id")%>" class="fotoForm" />
                </div>
                <div id="<%=pFor("id")%>divDisplayFoto" style="display:<%= divDisplayFoto %>">
                    <img id="<%=pFor("id")%>avatarFoto" src="uploads/<%=valor%>" style="max-width:<%= larguraFoto-10 %>px; max-height:<%= alturaFoto-10 %>px; width:auto; height: auto;" />
                    <span style="position:absolute; margin-left:-57px; margin-top:8px; float:left">
                    <button type="button" class="btn btn-xs btn-success" title="Editar Imagem" onclick="return launchEditor('<%=pFor("id")%>avatarFoto', 'uploads/<%=valor%>');"><i class="far fa-pencil"></i></button>
                    <button type="button" class="btn btn-xs btn-danger" onclick="formRemoveFoto(<%=pFor("id")%>);"><i class="far fa-trash"></i></button>
                    </span>
                </div>
            </div>
			</td>
		</tr>
		<%
	'CHECKBOX
	elseif pFor("TipoCampoID")=4 then
		if pFor("Checado")="S" then
			abreDiv="<div>"
			fechaDiv="</div>"
		else
			abreDiv=""
			fechaDiv=""
		end if
		set pOptions=db.execute("select * from buiOpcoesCampos where CampoID="&pFor("id")&" order by id")
		while not pOptions.eof
			response.Write(abreDiv)
			if preenchido="S" then
				if instr(valor, "."&pOptions("id")&".")>0 then
					checado = "checked=""checked"""
				else
					checado = ""
				end if
			else
				if pOptions("Selecionado")="S" then
					checado = "checked=""checked"""
				else
					checado = ""
				end if
			end if

			%>
			<label><input class="ace postvalue checkbox" title="checkbox-<%=pFor("id")%>" type="checkbox" name="campo_<%=pFor("id")%>" value=".<%=pOptions("id")%>." <%= checado %>><span class="lbl"> <%=pOptions("Nome")%></span>&nbsp;&nbsp;</label>&nbsp;
			<%
			response.Write(fechaDiv)
		pOptions.movenext
		wend
		pOptions.close
		set pOptions=nothing
	'RADIO
	elseif pFor("TipoCampoID")=5 then
		if pFor("Checado")="S" then
			abreDiv="<div>"
			fechaDiv="</div>"
		else
			abreDiv=""
			fechaDiv=""
		end if
		set pOp=db.execute("select * from buiOpcoesCampos where CampoID="&pFor("id")&" order by id")
		while not pOp.EOF
			if preenchido="S" then
				if valor=cstr(pOp("id")) then
					checado = "checked=""checked"""
				else
					checado = ""
				end if
			else
				if pOp("Selecionado")="S" then
					checado = "checked=""checked"""
				else
					checado = ""
				end if
			end if
			response.Write(abreDiv)
			%><label><input type="radio" class="ace postvalue" name="campo_<%=pFor("id")%>" value="<%=pOp("id")%>" <%=checado%>><span class="lbl"> <%=pOp("Nome")%></span>&nbsp;&nbsp;</label>
			<%
			response.Write(fechaDiv)
		pOp.moveNext
		wend
		pOp.close
		set pOp=nothing
	elseif pFor("TipoCampoID")=6 then
	%>
    <div class="form-group">
    <select name="campo_<%=pFor("id")%>" class="form-control postvalue" align="absmiddle">
    	<%
		set pOp=db.execute("select * from buiOpcoesCampos where CampoID="&pFor("id")&" order by id")
		while not pOp.EOF
			if preenchido="S" then
				if valor=cstr(pOp("id")) then
					checado = "selected=""selected"""
				else
					checado = ""
				end if
			else
				if pOp("Selecionado")="S" then
					checado = "selected=""selected"""
				else
					checado = ""
				end if
			end if
		%><option value="<%=pOp("id")%>"<%=checado%>><%=pOp("Nome")%></option>
        <%
		pOp.moveNext
		wend
		pOp.close
		set pOp=nothing
		%>
    </select></div>
	<%
	elseif pFor("TipoCampoID")=7 then
	%>
	<input type="button" class="btn btn-primary" value="<%=pFor("RotuloCampo")%>">
	<%
	elseif pFor("TipoCampoID")=8 then
	  if left(Valor, 6)="{\rtf1" then



		Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
		objWinHttp.Open "GET", "http://localhost/weegow/feegowclinic/RTFtoHTML.php?banco="&session("banco")&"&tabela=_"&ModeloID&"&coluna="&pFor("id")&"&id="&FormID,False
		objWinHttp.Send
		strHTML = objWinHttp.ResponseText
		Set objWinHttp = Nothing
		Valor = trim(Valor)
		if pFor("Checado")="S" then
			Valor = replace(strHTML, chr(10), "<br>")
		else
			Valor = strHTML
		end if
		db_execute("update `_"&ModeloID&"` set `"&pFor("id")&"`='"&rep(Valor)&"' where id="&FormID)
	  end if
	  
	  'response.Write("http://localhost/feegowclinic/RTFtoHTML.php?banco="&session("banco")&"&tabela=_"&ModeloID&"&coluna="&pFor("id")&"&id="&FormID)
	  %>
      <textarea class="form-control postvalue" name="campo_<%=pFor("id")%>" id="campo_<%=pFor("id")%>" cols="<%=pFor("Largura")%>" rows="<%=Linhas%>"><%=valor%></textarea>
    	<%
		if pFor("Checado")="S" and Linhas>4 then
			%><script type="text/javascript">
            $(function () {
                CKEDITOR.config.height = <%
				if isnumeric(Linhas) and Linhas<>"" then
					response.Write(Linhas*18)
				else
					response.Write(200)
				end if
					%>;
                $('#campo_<%=pFor("id")%>').ckeditor();
				
				CKEDITOR.instances['campo_<%=pFor("id")%>'].on('blur', function() {saveForm( 'campo_<%=pFor("id")%>' );});
            });
			</script>
			<%
		end if
	'TABELA
	elseif pFor("TipoCampoID")=9 then
		CampoID=pFor("id")
		Texto=pFor("Texto")
		if isNumeric(pFor("Linhas")) and not isNull(pFor("Linhas")) and not isNull(pFor("Colunas")) and isNumeric(pFor("Colunas")) then
			l=pFor("Linhas")
			c=pFor("Colunas")
		else
			l=0
			c=0
		end if
		colunas=c
		linhas=l
		splLinhas=split(trim(Texto&" "),"^|;")
		numeroLinhasSPL=ubound(splLinhas)+1
%>
<table border="0" cellpadding="1" cellspacing="1" bgcolor="#DDE4FF" width="100%">
<%		while linhas>0
			%><tr><%
			while colunas>0
				if linhas=l then
					estiloTH=" background-color:#DDE4FF; font-weight:bold;"
				else
					estiloTH=""
				end if
				%><td><input type="text" class="form-control postvalue" style="<%=estiloTH%>" value="<%
				if linhas<=numeroLinhasSPL then
					splColunas=split(splLinhas(linhas-1),"^|")
					numeroColunasSPL=ubound(splColunas)+1
					if colunas<=numeroColunasSPL then
						response.Write(splColunas(colunas-1))
					end if
				end if
				%>" /></td><%
				colunas=colunas-1
			wend
			if colunas=0 then
				colunas=c
			end if
			%></tr><%
			linhas=linhas-1
		wend
%></table><%
	'TITULO
	elseif pFor("TipoCampoID")=10 then
		%>
		<h2 style="margin:0; padding:0"><%=pFor("RotuloCampo")%></h2>
		<%
		if pFor("Checado")="" or isNull(pFor("Checado")) then
		%>
		<hr />
		<%end if%>
		<%=replace(pFor("Texto")&" ", chr(10), "<br />")%>
		<%
	elseif pFor("TipoCampoID")=11 then
		if pFor("Checado")="B" then
			img="Barras"
		elseif pFor("Checado")="P" then
			img="Pizza"
		else
			img="Linhas"
		end if
		response.Write("<center><img src=""newImages/"&img&".png"" border=0/></center>")
	elseif pFor("TipoCampoID")=12 then
		%><iframe width="820" src="audiometria.asp?ModeloID=<%=ModeloID%>&FormID=<%=FormID%>&PacienteID=<%=PacienteID%>&field=<%=pFor("id")%>" frameborder="0" scrolling="no" height="600"></iframe><%
	end if
	%>
</div>
<%
pFor.moveNext
wend
pFor.close
set pFor=nothing
%>
</div>
<script type="text/javascript">

jQuery(function($){
	$(".postvalue").change(function(){
		/*
		$.post("saveForm.asp",{
			field:$(this).attr('name'),
			value:$(this).val(),
			checked:$(this).attr('checked'),
			checkbox:$("input[title='"+$(this).attr('title')+"']").serialize(),
			FormID:$("#FormID").val(),
			ModeloID:$("#ModeloID").val(),
			PacienteID:<%=PacienteID%>
		},
		function(data, status){
			eval(data);
		});
		*/
	
		$.ajax({
			type:"POST",
			url:"saveForm.asp",
			data: {
			field:$(this).attr('name'),
			value:$(this).val(),
			checked:$(this).attr('checked'),
			checkbox:$("input[title='"+$(this).attr('title')+"']").serialize(),
			FormID:$("#FormID").val(),
			ModeloID:$("#ModeloID").val(),
			PacienteID:<%=PacienteID%>
				},
			success: function(data, status){
				eval(data);
			},
			error: function(xhr, status, error){
				alert("ATENÇÃO: Ocorreu um erro ao tentar salvar este formulário. Por favor, entre em contato com a Feegow Technologies para solucionar o problema.");
			}
		});
	
		
		
	});
});

function saveForm(ElementID){
		$.post("saveForm.asp",{
			field:ElementID,
			value:$("#"+ElementID).val(),
			FormID:$("#FormID").val(),
			ModeloID:$("#ModeloID").val(),
			PacienteID:<%=PacienteID%>
		},
		function(data, status){
			eval(data);
		});
}

<!--#include file="jQueryFunctions.asp"-->
</script>


<script type="text/javascript">
//js exclusivo avatar
function formRemoveFoto(idFoto){
	if(confirm('Tem certeza de que deseja excluir esta imagem?')){
		$.ajax({
			type:"POST",
			url:"FormFotoUploadSave.asp?FTipo=<%=FTipo%>&PacienteID=<%=PacienteID%>&FormID="+$("#FormID").val()+"&ModeloID=<%=ModeloID%>&Col="+idFoto+"&Action=Remove",
			success:function(data){
				$("#"+idFoto+"divDisplayUploadFoto").css("display", "block");
				$("#"+idFoto+"divDisplayFoto").css("display", "none");
				$("#"+idFoto+"avatarFoto").attr("src", "uploads/");
//				$("#"+idFoto).ace_file_input('reset_input');
				eval(data);
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
		
		
		$(".fotoForm").change(function() {
			var idFoto = $(this).attr('id');
			var submit_url = "FormFotoUpload.php?FTipo=<%=FTipo%>&PacienteID=<%=PacienteID%>&FormID="+$("#FormID").val()+"&ModeloID=<%=ModeloID%>&Col="+idFoto;
			//if(!file_input.data('ace_input_files')){alert('nada'); return false};//no files selected
			
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
						//alert(idFoto);
						$("#"+idFoto+"avatarFoto").attr("src", result.url);
						$("#"+idFoto+"divDisplayUploadFoto").css("display", "none");
						$("#"+idFoto+"divDisplayFoto").css("display", "block");
						$("#FormID").val(result.FormID);
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
	

$(document).ready(function(){
	<%=chamaScript%>
});
<%
if negadoX="S" then
	%>$(".postvalue").attr("disabled", "disabled");<%
end if
%>
</script>
