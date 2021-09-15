<!--#include file="connect.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from Contatos where id="&req("I"))
%>
<form method="post" id="frm" name="frm" action="save.asp">
	<%=header(req("P"), "CONTATO", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
	<input type="hidden" name="I" value="<%=req("I")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />
<div class="row">
	<%=quickField("text", "NomeContato", "Nome", 4, reg("NomeContato"), "", "", " required")%>
    <%=quickField("simpleSelect", "Sexo", "Sexo", 1, reg("Sexo"), "select * from Sexo where sysActive=1", "NomeSexo", "")%>
    <%
	set unit = db.execute("select * from sys_financialcompanyunits order by UNitName")
	if unit.eof then
		%><input type="hidden" name="UnidadeID" value="0" /><%
	else
		%>
	<div class="col-md-4">
    	<label>Unidade</label><br />
    	<select name="UnidadeID">
        <option value="0">Empresa principal</option>
        <%
		set unit = db.execute("select * from sys_financialcompanyunits order by UNitName")
		while not unit.eof
			%>
			<option value="<%=unit("id")%>"<% If unit("id")=reg("UnidadeID") Then %> selected="selected"<% End If %>><%=unit("UnitName")%></option>
			<%
		unit.movenext
		wend
		unit.close
		set unit=nothing
		%>
        </select>
    </div>
    <%
	end if
	%>
</div>
<div class="row">
    <%= quickField("text", "Cep", "Cep", 3, reg("cep"), "input-mask-cep", "", "") %>
    <%= quickField("text", "Endereco", "Endere&ccedil;o", 5, reg("endereco"), "", "", "") %>
    <%= quickField("text", "Numero", "N&uacute;mero", 2, reg("numero"), "", "", "") %>
    <%= quickField("text", "Complemento", "Compl.", 2, reg("complemento"), "", "", "") %>
</div>
<div class="row">
    <%= quickField("text", "Bairro", "Bairro", 4, reg("bairro"), "", "", "") %>
    <%= quickField("text", "Cidade", "Cidade", 4, reg("cidade"), "", "", "") %>
    <%= quickField("text", "Estado", "Estado", 2, reg("estado"), "", "", "") %>
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
    <%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, reg("Observacoes"), "", "", " rows='10'") %>
</div>
</form>
<script type="text/javascript">
$(document).ready(function(e) {
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
<!--#include file="disconnect.asp"-->