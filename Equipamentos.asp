<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<style>
.listaUnidades{
	list-style-type:none;
	margin-left:10px;
}
.listaUnidades li span{
	font-size:12px!important;
}
</style>
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))

Aba = request.QueryString("Aba")

if Aba="" then
	ativoCadastro = " class=""active"""
	ativoHorarios = ""
	chamaScript = ""
	tabCadastro = " in active"
	tabHorarios = ""
elseif Aba="Horarios" then
	ativoCadastro = ""
	ativoHorarios = " class=""active"""
	if versaoAgenda()=1 then
		chamaScript = "ajxContent('Horarios-1', "&req("I")*(-1)&", 1, 'divHorarios');"
	else
		chamaScript = "ajxContent('Horarios', "&req("I")*(-1)&", 1, 'divHorarios');"
	end if
	tabCadastro = ""
	tabHorarios = " in active"
end if
%>


<br />
<div class="panel">
    <div class="panel-body">
        <div class="tabbable">
            <div class="tab-content">
                <div id="divCadastroEquipamento" class="tab-pane<%=tabCadastro%>">




                    <form method="post" id="frm" name="frm" action="save.asp">
<%=header(req("P"), "Cadastro de Equipamento", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
                        <input type="hidden" name="I" value="<%=req("I")%>" />
                        <input type="hidden" name="P" value="<%=req("P")%>" />
                    <div class="row">
                        <div class="col-md-2" id="divAvatar">
                            <div class="row">
                                <div class="col-md-12">
							        <%
                                    if reg("Foto")="" or isnull(reg("Foto")) then
                                        divDisplayUploadFoto = "block"
                                        divDisplayFoto = "none"
                                    else
                                        divDisplayUploadFoto = "none"
                                        divDisplayFoto = "block"
                                    end if
                                    %>
                                    <div id="divDisplayUploadFoto" style="display:<%=divDisplayUploadFoto%>">
                                        <input type="file" name="Foto" id="Foto" />
                                    </div>
                                    <div id="divDisplayFoto" style="display:<%= divDisplayFoto %>">
                                        <img id="avatarFoto" src="/uploads/<%= replace(session("Banco"), "clinic", "") &"/Perfil/"& reg("Foto")%>" class="img-thumbnail" width="100%" />
                                        <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="fa fa-trash"></i></button>
                                    </div>
                                </div>
                            </div>


                        </div>
                        <div class="col-md-10">
                            <div class="row">
                                <%=quickField("text", "NomeEquipamento", "Nome do Equipamento", 4, reg("NomeEquipamento"), "", "", " required")%>
                                <%=quickField("empresa", "UnidadeID", "Unidade", 3, reg("UnidadeID"), "", "", "")%>
                                <%=quickField("text", "Pacs_id", "Identificação no PACS", 2, reg("Pacs_id"), "", "", " ")%>
                                <div class="col-md-1 col-md-offset-2">
                                    <label>
                                        Ativo
                                        <br />
                                        <div class="switch round">
                                            <input type="checkbox" <% If reg("Ativo")="on" or isnull(reg("Ativo")) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo">
                                            <label for="Ativo">Label</label>
                                        </div>

                                    </label>
                                </div>
                            </div>
                                <hr class="short alt" />
                                <div class="row">
                                    <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 6, reg("Obs"), "", "", "") %>
                                </div>
                            </div>
                        </div>

                    </form>
                </div>
                <div id="divHorarios" class="tab-pane<%=tabHorarios%>">
			        Carregando...
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});



</script>

<script src="assets/js/ace-elements.min.js"></script>
<script type="text/javascript">
//js exclusivo avatar
<%
Parametros = "P="&request.QueryString("P")&"&I="&request.QueryString("I")&"&Col=Foto&L="& replace(session("Banco"), "clinic", "")
%>
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
	

$(document).ready(function(){
	<%=chamaScript%>
});

<%
if req("GT")="Permissoes" then
	%>
	$(document).ready(function(e) {
        $("#gtPermissoes").click();
    });
	<%
end if
%>
</script>

<!--#include file="disconnect.asp"-->