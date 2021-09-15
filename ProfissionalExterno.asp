<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from ProfissionalExterno where id="&req("I"))
%>
<form method="post" id="frm" name="frm" action="save.asp">
<%=header(req("P"), "Cadastro de Profissional Externo", reg("sysActive"), req("I"), req("Pers"), "Follow")%>

<br>
<div class="panel">
<div class="panel-body">
<div class="">
                <input type="hidden" name="I" value="<%=req("I")%>" />
                <input type="hidden" name="P" value="<%=req("P")%>" />
<br>
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
                                <img id="avatarFoto" src="uploads/<%=reg("Foto")%>" class="img-thumbnail" width="100%" />
                                <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="far fa-trash"></i></button>
                            </div>
                        </div>
                        <span class="label label-xlg label-light arrowed-in-right arrowed-in">
                            <%=quickField("cor", "Cor", "Cor de identifica&ccedil;&atilde;o", 12, reg("Cor"), "select * from Cores", "Cor", "")%>
                        </span>
                    </div>
                </div>
                <div class="col-md-10">
                    <div class="row">
                        <%=quickField("simpleSelect", "TratamentoID", "T&iacute;tulo", 2, reg("TratamentoID"), "select * from tratamento order by Tratamento", "Tratamento", "")%>
                        <%=quickField("text", "NomeProfissional", "Nome", 5, reg("NomeProfissional"), "", "", " required")%>
                        <%=quickField("simpleSelect", "EspecialidadeID", "Especialidade", 4, reg("EspecialidadeID"), "select * from especialidades WHERE sysActive=1 order by Especialidade", "Especialidade", "")%>
                    <div class="col-md-1 <%=hideInactive %>">
                        <label for="Ativo">Ativo</label><br />
                            <div class="switch round">
                                <input <% If reg("Ativo")="on" or isnull(reg("Ativo")) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo" type="checkbox" />
                                <label for="Ativo"></label>
                            </div>
                    </div>
                    </div>
                    <div class="row">
                        <%=quickField("simpleSelect", "Sexo", "Sexo", 2, reg("Sexo"), "select * from Sexo where sysActive=1", "NomeSexo", "")%>
                        <%=quickField("datepicker", "Nascimento", "Nascimento", 3, reg("Nascimento"), "input-mask-date", "", "")%>
                        <%= quickField("text", "CPF", "CPF", 3, reg("CPF"), " input-mask-cpf", "", "") %>
                        <%= quickField("simpleSelect", "Conselho", "Conselho", 2, reg("Conselho"), "select * from conselhosprofissionais order by codigo", "codigo", "") %>
                        <%= quickField("text", "DocumentoConselho", "Registro", 2, reg("DocumentoConselho"), "", "", "") %>
                        <%= quickField("text", "UFConselho", "UF", 2, reg("UFConselho"), "", "", "") %>
                        <div class="col-md-3">
                            <%=selectInsert("Grupo", "GrupoID", reg("GrupoID"), "profissionaisgrupos", "NomeGrupo", "", "", "") %>
                        </div>
                        <%= quickField("simpleSelect", "TipoPrestadorID", "Tipo de Prestador de Serviço", 3, reg("TipoPrestadorID"), "select * from cliniccentral.tipoprestadorservico order by 1", "descricao", "") %>

                        </div>
                        <hr />
                        <div class="row">
                            <%= quickField("text", "Cep", "Cep", 3, reg("cep"), "input-mask-cep", "", "") %>
                            <%= quickField("text", "Endereco", "Endere&ccedil;o", 5, reg("endereco"), "", "", "") %>
                            <%= quickField("text", "Numero", "N&uacute;mero", 2, reg("numero"), "", "", "") %>
                            <%= quickField("text", "Complemento", "Compl.", 2, reg("complemento"), "", "", "") %>
                        </div>
                        <div class="row">
                            <%= quickField("text", "Bairro", "Bairro", 3, reg("bairro"), "", "", "") %>
                            <%= quickField("text", "Cidade", "Cidade", 3, reg("cidade"), "", "", "") %>
			    <%= quickField("text", "ZonaAtendimento", "Região / Zona", 2, reg("ZonaAtendimento"), "", "", "") %>
                            <%= quickField("text", "Estado", "Estado", 2, reg("estado"), "", "", "") %>
                            <%= quickField("simpleSelect", "Pais", "Pa&iacute;s", 2, reg("Pais"), "select * from Paises where sysActive=1 order by NomePais", "NomePais", "") %>
                        </div>
                        <div class="row">
                            <%= quickField("phone", "Tel1", "Telefone", 4, reg("tel1"), "", "", "") %>
                            <%= quickField("mobile", "Cel1", "Celular", 4, reg("cel1"), "", "", "") %>
                            <%= quickField("email", "Email1", "E-mail", 4, reg("email1"), "", "", "") %>
                            <%= quickField("phone", "Tel2", "&nbsp;", 4, reg("tel2"), "", "", "") %>
                            <%= quickField("mobile", "Cel2", "&nbsp;", 4, reg("cel2"), "", "", "") %>
                            <%= quickField("email", "Email2", "&nbsp;", 4, reg("email2"), "", "", "") %>
                        </div>
			<div class="row">
			    <%= quickField("simpleSelect", "AssociacaoResponsavel", "Responsável de contato", 2, reg("AssociacaoID")&"_"&reg("ResponsavelContato"), "SELECT * FROM (SELECT CONCAT('5_',id) id,NomeProfissional responsavelContato FROM profissionais WHERE sysActive=1 AND Ativo = 'on' AND NomeProfissional IS NOT NULL AND NomeProfissional <> '' UNION ALL SELECT CONCAT('4_',id) id,NomeFuncionario responsavelContato FROM funcionarios WHERE sysActive=1 AND Ativo = 'on' AND NomeFuncionario IS NOT NULL AND NomeFuncionario <> '') t ORDER BY responsavelContato", "responsavelContato", "") %>
			    <input type="hidden" name="AssociacaoID" id="AssociacaoID" value="<%=reg("AssociacaoID")%>" />
			    <input type="hidden" name="ResponsavelContato" id="ResponsavelContato" value="<%=reg("ResponsavelContato")%>" />
			</div>
                        <div class="row">
                            <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 6, reg("Obs"), "", "", " rows=4") %>
                            <div class="col-md-6">
                            	<div class="row clearfix form-actions">
				    <%= quickField("text", "Login", "Login", 6, reg("Login"), "", "", "") %>
                                    <%= quickField("text", "Senha", "Senha", 6, reg("Senha"), "", "", "") %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
</div>
</div>
</div>
</form>
<script type="text/javascript">
$(document).ready(function(e) {
	$('#AssociacaoResponsavel').change(function(){
		associacaoResponsavel = $('#AssociacaoResponsavel').val();
		let arrayResponsavel = associacaoResponsavel.split('_');
		let associacaoId = arrayResponsavel[0];
		let responsavelContato = arrayResponsavel[1];
		$('#AssociacaoID').val(associacaoId);
		$('#ResponsavelContato').val(responsavelContato);
	});
	<%call formSave("frm", "save", "")%>
});


$("#Cep").keyup(function(){
	getEndereco();
});
var resultadoCEP
function getEndereco() {
//alert()
//	alert(($("#Cep").val() *= '_'));
	var temUnder = /_/i.test($("#Cep").val())
	if(temUnder == false){
		$.getScript("webservice-cep/cep.php?cep="+$("#Cep").val(), function(){
			if(resultadoCEP["logradouro"]!=""){
				$("#Endereco").val(unescape(resultadoCEP["logradouro"]));
				$("#Bairro").val(unescape(resultadoCEP["bairro"]));
				$("#Cidade").val(unescape(resultadoCEP["cidade"]));
				$("#Estado").val(unescape(resultadoCEP["uf"]));
				$("#Numero").focus();
			}else{
				$("#Endereco").focus();
			}
		});				
	}			
}

function replaceAll(string, token, newtoken) {
	while (string.indexOf(token) != -1) {
 		string = string.replace(token, newtoken);
	}
	return string;
}

jQuery(function($) {

	//editables on first profile page
	$.fn.editable.defaults.mode = 'inline';
	$.fn.editableform.loading = "<div class='editableform-loading'><i class='light-blue icon-2x icon-spinner icon-spin'></i></div>";
	$.fn.editableform.buttons = '<button type="submit" class="btn btn-info editable-submit"><i class="far fa-ok icon-white"></i></button>'+
								'<button type="button" class="btn editable-cancel"><i class="far fa-remove"></i></button>';

	//editables
	$('#username').editable({
		type: 'text',
		name: 'username'
	});


	var countries = [];
	$.each({ "CA": "Canada", "IN": "India", "NL": "Netherlands", "TR": "Turkey", "US": "United States"}, function(k, v) {
		countries.push({id: k, text: v});
	});

	var cities = [];
	cities["CA"] = [];
	$.each(["Toronto", "Ottawa", "Calgary", "Vancouver"] , function(k, v){
		cities["CA"].push({id: v, text: v});
	});
	cities["IN"] = [];
	$.each(["Delhi", "Mumbai", "Bangalore"] , function(k, v){
		cities["IN"].push({id: v, text: v});
	});
	cities["NL"] = [];
	$.each(["Amsterdam", "Rotterdam", "The Hague"] , function(k, v){
		cities["NL"].push({id: v, text: v});
	});
	cities["TR"] = [];
	$.each(["Ankara", "Istanbul", "Izmir"] , function(k, v){
		cities["TR"].push({id: v, text: v});
	});
	cities["US"] = [];
	$.each(["New York", "Miami", "Los Angeles", "Chicago", "Wysconsin"] , function(k, v){
		cities["US"].push({id: v, text: v});
	});

	var currentValue = "NL";
	$('#country').editable({
		type: 'select2',
		value : 'NL',
		source: countries,
		success: function(response, newValue) {
			if(currentValue == newValue) return;
			currentValue = newValue;

			var new_source = (!newValue || newValue == "") ? [] : cities[newValue];

			//the destroy method is causing errors in x-editable v1.4.6
			//it worked fine in v1.4.5
			/**
			$('#city').editable('destroy').editable({
				type: 'select2',
				source: new_source
			}).editable('setValue', null);
			*/

			//so we remove it altogether and create a new element
			var city = $('#city').removeAttr('id').get(0);
			$(city).clone().attr('id', 'city').text('Select City').editable({
				type: 'select2',
				value : null,
				source: new_source
			}).insertAfter(city);//insert it after previous instance
			$(city).remove();//remove previous instance

		}
	});

	$('#city').editable({
		type: 'select2',
		value : 'Amsterdam',
		source: cities[currentValue]
	});



	$('#signup').editable({
		type: 'date',
		format: 'yyyy-mm-dd',
		viewformat: 'dd/mm/yyyy',
		datepicker: {
			weekStart: 1
		}
	});

	$('#age').editable({
		type: 'spinner',
		name : 'age',
		spinner : {
			min : 16, max:99, step:1
		}
	});

	//var $range = document.createElement("INPUT");
	//$range.type = 'range';
	$('#login').editable({
		type: 'slider',//$range.type == 'range' ? 'range' : 'slider',
		name : 'login',
		slider : {
			min : 1, max:50, width:100
		},
		success: function(response, newValue) {
			if(parseInt(newValue) == 1)
				$(this).html(newValue + " hour ago");
			else $(this).html(newValue + " hours ago");
		}
	});

	$('#about').editable({
		mode: 'inline',
		type: 'wysiwyg',
		name : 'about',
		wysiwyg : {
			//css : {'max-width':'300px'}
		},
		success: function(response, newValue) {
		}
	});



	// *** editable avatar *** //
	try {//ie8 throws some harmless exception, so let's catch it

		//it seems that editable plugin calls appendChild, and as Image doesn't have it, it causes errors on IE at unpredicted points
		//so let's have a fake appendChild for it!
		if( /msie\s*(8|7|6)/.test(navigator.userAgent.toLowerCase()) ) Image.prototype.appendChild = function(el){}

		var last_gritter
		$('#avatar').editable({
			type: 'image',
			name: 'avatar',
			value: null,
			image: {
				//specify ace file input plugin's options here
				btn_choose: 'Inserir Foto',
				droppable: true,
				/**
				//this will override the default before_change that only accepts image files
				before_change: function(files, dropped) {
					return true;
				},
				*/

				//and a few extra ones here
				name: 'avatar',//put the field name here as well, will be used inside the custom plugin
				max_size: 110000,//~100Kb
				on_error : function(code) {//on_error function will be called when the selected file has a problem
					if(last_gritter) $.gritter.remove(last_gritter);
					if(code == 1) {//file format error
						last_gritter = $.gritter.add({
							title: 'File is not an image!',
							text: 'Please choose a jpg|gif|png image!',
							class_name: 'gritter-error gritter-center'
						});
					} else if(code == 2) {//file size rror
						last_gritter = $.gritter.add({
							title: 'File too big!',
							text: 'Image size should not exceed 100Kb!',
							class_name: 'gritter-error gritter-center'
						});
					}
					else {//other error
					}
				},
				on_success : function() {
					$.gritter.removeAll();
				}
			},
			url: function(params) {
				// ***UPDATE AVATAR HERE*** //
				//You can replace the contents of this function with examples/profile-avatar-update.js for actual upload


				var deferred = new $.Deferred

				//if value is empty, means no valid files were selected
				//but it may still be submitted by the plugin, because "" (empty string) is different from previous non-empty value whatever it was
				//so we return just here to prevent problems
				var value = $('#avatar').next().find('input[type=hidden]:eq(0)').val();
				if(!value || value.length == 0) {
					deferred.resolve();
					return deferred.promise();
				}


				//dummy upload
				setTimeout(function(){
					if("FileReader" in window) {
						//for browsers that have a thumbnail of selected image
						var thumb = $('#avatar').next().find('img').data('thumb');
						if(thumb) $('#avatar').get(0).src = thumb;
					}

					deferred.resolve({'status':'OK'});

					if(last_gritter) $.gritter.remove(last_gritter);
					last_gritter = $.gritter.add({
						title: 'Avatar Updated!',
						text: 'Uploading to server can be easily implemented. A working example is included with the template.',
						class_name: 'gritter-info gritter-center'
					});

				 } , parseInt(Math.random() * 800 + 800))

				return deferred.promise();
			},

			success: function(response, newValue) {
			}
		})
	}catch(e) {}



	//another option is using modals
	$('#avatar2').on('click', function(){
		var modal =
		'<div class="modal hide fade">\
			<div class="modal-header">\
				<button type="button" class="close" data-dismiss="modal">&times;</button>\
				<h4 class="blue">Change Avatar</h4>\
			</div>\
			\
			<form class="no-margin">\
			<div class="modal-body">\
				<div class="space-4"></div>\
				<div style="width:75%;margin-left:12%;"><input type="file" name="file-input" /></div>\
			</div>\
			\
			<div class="modal-footer center">\
				<button type="submit" class="btn btn-small btn-success"><i class="far fa-ok"></i> Submit</button>\
				<button type="button" class="btn btn-small" data-dismiss="modal"><i class="far fa-remove"></i> Cancel</button>\
			</div>\
			</form>\
		</div>';


		var modal = $(modal);
		modal.modal("show").on("hidden", function(){
			modal.remove();
		});

		var working = false;

		var form = modal.find('form:eq(0)');
		var file = form.find('input[type=file]').eq(0);
		file.ace_file_input({
			style:'well',
			btn_choose:'Click to choose new avatar',
			btn_change:null,
			no_icon:'icon-user',
			thumbnail:'small',
			before_remove: function() {
				//don't remove/reset files while being uploaded
				return !working;
			},
			before_change: function(files, dropped) {
				var file = files[0];
				if(typeof file === "string") {
					//file is just a file name here (in browsers that don't support FileReader API)
					if(! (/\.(jpe?g|png|gif)$/i).test(file) ) return false;
				}
				else {//file is a File object
					var type = $.trim(file.type);
					if( ( type.length > 0 && ! (/^image\/(jpe?g|png|gif)$/i).test(type) )
							|| ( type.length == 0 && ! (/\.(jpe?g|png|gif)$/i).test(file.name) )//for android default browser!
						) return false;

					if( file.size > 110000 ) {//~100Kb
						return false;
					}
				}

				return true;
			}
		});

		form.on('submit', function(){
			if(!file.data('ace_input_files')) return false;

			file.ace_file_input('disable');
			form.find('button').attr('disabled', 'disabled');
			form.find('.modal-body').append("<div class='center'><i class='icon-spinner icon-spin bigger-150 orange'></i></div>");

			var deferred = new $.Deferred;
			working = true;
			deferred.done(function() {
				form.find('button').removeAttr('disabled');
				form.find('input[type=file]').ace_file_input('enable');
				form.find('.modal-body > :last-child').remove();

				modal.modal("hide");

				var thumb = file.next().find('img').data('thumb');
				if(thumb) $('#avatar2').get(0).src = thumb;

				working = false;
			});


			setTimeout(function(){
				deferred.resolve();
			} , parseInt(Math.random() * 800 + 800));

			return false;
		});

	});



	//////////////////////////////
	$('#profile-feed-1').slimScroll({
	height: '250px',
	alwaysVisible : true
	});

	$('.profile-social-links > a').tooltip();

	$('.easy-pie-chart.percentage').each(function(){
	var barColor = $(this).data('color') || '#555';
	var trackColor = '#E2E2E2';
	var size = parseInt($(this).data('size')) || 72;
	$(this).easyPieChart({
		barColor: barColor,
		trackColor: trackColor,
		scaleColor: false,
		lineCap: 'butt',
		lineWidth: parseInt(size/10),
		animate:false,
		size: size
	}).css('color', barColor);
	});

	///////////////////////////////////////////

	//show the user info on right or left depending on its position
	$('#user-profile-2 .memberdiv').on('mouseenter', function(){
		var $this = $(this);
		var $parent = $this.closest('.tab-pane');

		var off1 = $parent.offset();
		var w1 = $parent.width();

		var off2 = $this.offset();
		var w2 = $this.width();

		var place = 'left';
		if( parseInt(off2.left) < parseInt(off1.left) + parseInt(w1 / 2) ) place = 'right';

		$this.find('.popover').removeClass('right left').addClass(place);
	}).on('click', function() {
		return false;
	});


	///////////////////////////////////////////
	$('#user-profile-3')
	.find('input[type=file]').ace_file_input({
		style:'well',
		btn_choose:'Change avatar',
		btn_change:null,
		no_icon:'icon-user',
		thumbnail:'large',
		droppable:true,
		before_change: function(files, dropped) {
			var file = files[0];
			if(typeof file === "string") {//files is just a file name here (in browsers that don't support FileReader API)
				if(! (/\.(jpe?g|png|gif)$/i).test(file) ) return false;
			}
			else {//file is a File object
				var type = $.trim(file.type);
				if( ( type.length > 0 && ! (/^image\/(jpe?g|png|gif)$/i).test(type) )
						|| ( type.length == 0 && ! (/\.(jpe?g|png|gif)$/i).test(file.name) )//for android default browser!
					) return false;

				if( file.size > 110000 ) {//~100Kb
					return false;
				}
			}

			return true;
		}
	})
	.end().find('button[type=reset]').on(ace.click_event, function(){
		$('#user-profile-3 input[type=file]').ace_file_input('reset_input');
	})
	.end().find('.date-picker').datepicker().next().on(ace.click_event, function(){
		$(this).prev().focus();
	})



	////////////////////
	//change profile
	$('[data-toggle="buttons"] .btn').on('click', function(e){
		var target = $(this).find('input[type=radio]');
		var which = parseInt(target.val());
		$('.user-profile').parent().addClass('hide');
		$('#user-profile-'+which).parent().removeClass('hide');
	});
});
</script>

<script src="assets/js/ace-elements.min.js"></script>
<script type="text/javascript">
//js exclusivo avatar
<%
Parametros = "P="&req("P")&"&I="&req("I")&"&Col=Foto"
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
