<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalComparar.asp"-->


<%
    if req("Agenda")="" then
    %>
    <link rel="stylesheet" href="vendor/plugins/dropzone/css/dropzone.css">
    <!--#include file="mfp.asp"-->
    <link rel="stylesheet" type="text/css" href="site/jquery.gridster.css">
    <link rel="stylesheet" type="text/css" href="site/demo.css">
    <link rel="stylesheet" type="text/css" href="buiforms.css">
    <script src="site/jquery.gridster.js" type="text/javascript" charset="utf-8"></script>
    <%
end if


if lcase(session("Table"))="profissionais" then
    set profAba=db.execute("SELECT AbaProntuario FROM profissionais WHERE id="&session("idInTable"))
    if not profAba.eof then
        AbaProntuario=profAba("AbaProntuario")
        if AbaProntuario<>"" or not isnull(AbaProntuario) then
            %>
            <script>
            $(document).ready(function(){
                    $("#<%=AbaProntuario%>").click();
                })
            </script>
            <%
        end if
    end if

end if
%>


<div class="alert alert-warning hidden">
    <i class="far fa-exclamation-triangle red"></i> ATENÇÃO: Usuário também está acessando os dados deste paciente. Tenha cuidado para que os dados não sejam sobrescritos.
</div>
<%
omitir = ""
if session("Admin")=0 then
	set omit = db.execute("select * from omissaocampos")
	while not omit.eof
		tipo = omit("Tipo")
		grupo = omit("Grupo")
		if Tipo="P" and lcase(session("Table"))="profissionais" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
			omitir = omitir&lcase(omit("Omitir"))
		elseif Tipo="F" and lcase(session("Table"))="funcionarios" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
			omitir = omitir&lcase(omit("Omitir"))
		elseif Tipo="E" and lcase(session("Table"))="profissionais" then
			set prof = db.execute("select EspecialidadeID from profissionais where id="&session("idInTable"))
			if not prof.eof then
				if instr(grupo, "|"&prof("EspecialidadeID")&"|")>0 then
					omitir = omitir&lcase(omit("Omitir"))
				end if
			end if
		end if
	omit.movenext
	wend
	omit.close
	set omit = nothing
end if
%>
<style>
video {
	width:100%;
}

@media print{
    body, #main, #main:before{
        background-color:#fff!important;
    }

    .timeline-add, #content-footer,#topbar{
        display: none;
    }
}
</style>
<%
if req("Agenda")="" then
	%><!--#include file="PacientesCompleto.asp"--><%
else
	%><!--#include file="PacientesCompleto.asp"--><%
end if
%>
<script type="text/javascript">
function verificaElegibilidade(N){
    $.post("verificaElegibilidade.asp?I=<%=req("I")%>", {
    ConvenioID: $("#ConvenioID"+N).val(),
    CNS: $("#CNS").val(),
    IdentificacaoBeneficiario: $("#IdentificacaoBeneficiario").val(),
    Matricula: $("#Matricula"+N).val(),
    Validade: $("#Validade"+N).val(),
    NomePaciente: $("#NomePaciente").val()
    }, function(data){
        eval(data);
    });
}



function atender(AgendamentoID, PacienteID, Acao, Solicitacao){
	$.ajax({
		type:"POST",
		data:$("#frmFimAtendimento").serialize(),
		url:"atender.asp?Atender="+AgendamentoID+"&I="+PacienteID+"&Acao="+Acao+"&Solicitacao="+Solicitacao,
		success:function(data){
			$("#divContador").html(data);
		}
	});
}

$(document).ready(function(e) {
    <%call formSave("frm", "save", "$(""#DadosAlterados"").attr('value', ''); $(""#searchPacienteID"").val( $(""#NomePaciente"").val() ); $(""#ageTel1"").val( $(""#Tel1"").val() ); $(""#ageCel1"").val( $(""#Cel1"").val() ); $(""#ageEmail1"").val( $(""#Email1"").val() ); $(""#ageTabela"").val( $(""#Tabela"").val() ); $(""#myTab4 a[href=#dadosAgendamento]"").click()")%>
});

function cid10(X){
	$.ajax({
		type:"POST",
		url:"Diagnosticos.asp?p=<%=req("I")%>&X="+X,
		success:function(data){
			$("#modal-form .panel").html(data);
		}
	});
}

$("#tabRecibos").click(function(){
	$.ajax({
		type:"POST",
		url:"Recibos.asp?PacienteID=<%=req("I")%>",
		success:function(data){
			$("#divRecibos").html(data);
		}
	});
});

function duplicate(file){
	$.ajax({
		type:"POST",
		url:"duplicate.php?file="+file,
		success:function(data){
			atualizaAlbum(0);
		}
	});
}

function atualizaAlbum(X){
    //apenas chamar pront
	$.ajax({
		type:"POST",
		url:"Imagens.asp?PacienteID=<%=req("I")%>&X="+X,
		success:function(data){
		    $("#ImagensPaciente").html(data);
		}
	});
}

	function atualizaArquivos(X){
        //apenas chamar pront
	$.ajax({
		type:"POST",
		url:"Arquivos.asp?PacienteID=<%=req("I")%>&X="+X,
		success:function(data){
			$("#ArquivosPaciente").html(data);
		}
	});
}

	function r90(f, id){
	    var dt = new Date().getTime();
	    $.get("/feegow_components/rotate_img?img="+f+ "&l=<%=replace(session("Banco"),"clinic","")%>", function(data){
	        var $el = $("img[data-id="+id+"]");

	        var originalSource = $el.attr("data-src");
	        console.log($el)
	        console.log(originalSource)

	        $el.attr("src", originalSource + "?" + dt );
	    });
	}

$("#Nascimento").change(function(){
	Idade($("#Nascimento").val());
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
					if(resultadoCEP["pais"]==1){
					    $("#Pais").html("<option value='1'>Brasil</option>").val(1).change();
					}
					$("#Numero").focus();
				}else{
					$("#Endereco").focus();
				}
			});
		}
}

$("#Altura").keyup(function(){
	imc();
});
$("#Peso").keyup(function(){
	imc();
});
function imc(){
	var val = replaceAll($("#Peso").val(), ",", ".") / ( replaceAll($("#Altura").val(), ",", ".") * replaceAll($("#Altura").val(), ",", ".") )
	var val = parseInt(val)
	$("#IMC").val(val);
}

function agendamentos(PacienteID){
	$.ajax({
		type:"POST",
		url:"HistoricoPaciente.asp?PacienteID="+PacienteID,
		success:function(data){
			$("#HistoricoPaciente").html(data);
		}
	});
}

$(".mainTab").click(function(){
	$("#DadosComplementares").slideDown();
	$("#divAvatar").removeClass("col-md-1");
	$("#divAvatar").addClass("col-md-2");
	if($("#avatarFoto").attr("src")=="uploads/"){
		$("#divDisplayUploadFoto").css("display", "block");
	}
	$("#resumoConvenios").addClass("hidden");
	$("#pront, .tray-left").addClass("hidden");
	$("#Dados, #p1, #pPacientesRetornos, #pPacientesRelativos, #dCad, .alerta-dependente, #Servicos").removeClass("hidden");
	//$("#save").removeClass("hidden");
});
$(".tab").click(function(){
	$("#DadosComplementares").slideUp();
	$("#divAvatar").removeClass("col-md-2");
	$("#divAvatar").addClass("col-md-1");
	$("#divDisplayUploadFoto").css("display", "none");
	$("#resumoConvenios").removeClass("hidden");
	$("#pront, .tray-left").removeClass("hidden");
	$("#Dados, #p1, #pPacientesRetornos, #pPacientesRelativos, #dCad, .alerta-dependente, #Servicos").addClass("hidden");
    //$("#save").addClass("hidden");
});
function pront(U){
	$.ajax({
		type: "POST",
		url: U,
		success:function(data){
			$("#pront").html(data);
		}
	});
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

$("#btnFicha").click(function(){
	$.ajax({
		url:'imprimirFicha.asp?PacienteID=<%=req("I")%>',
		success:function(data){
			$("#modal").html(data);
		}
	});
	$("#modal-table").modal('show');
});
$("#btnCompartilhar").click(function(){
	$.ajax({
		url:'compartilhar.asp?PacienteID=<%=req("I")%>',
		success:function(data){
			$("#modal").html(data);
		}
	});
	$("#modal-table").modal('show');
});
$("#btnLancamentoRetroativo").click(function(){
	$.ajax({
		url:'LancamentoRetroativo.asp?PacienteID=<%=req("I")%>',
		success:function(data){
			$("#modal").html(data);
		}
	});
	$("#modal-table").modal('show');
});
</script>

<%if request.ServerVariables("REMOTE_ADDR")<>"127.0.0.1" then %>
<script src="../feegow_components/assets/feegow-theme/vendor/plugins/datatables/media/js/jquery.dataTables.js"></script>
<%end if %>
<script src="assets/js/ace-elements.min.js"></script>
<script type="text/javascript">
//js exclusivo avatar
<%
Parametros = "P="&req("P")&"&I="&req("I")&"&Col=Foto&L="& replace(session("Banco"), "clinic", "")
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


function itemPacientesConvenios(tbn, act, reg, cln, idc, frm){
	$.ajax({
		type: "POST",
		url: "callpacientesconvenios.asp?tbn="+tbn+"&act="+act+"&reg="+reg+"&cln="+cln+"&idc="+idc+"&frm="+frm,
		data: $('#'+frm).serialize(),
		success: function( data )
		{
			$("#div"+tbn).html(data);
		}
	});
}

	window.onbeforeunload = function (e) {
if($("#DadosAlterados").val()=="S"){
	  var message = "Dados do pacientes foram alterados.\n\nTem certeza de que deseja sair sem salvar?.",
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
</script>


  <script src="js/say-cheese.js"></script>
  <script type="text/javascript">

      function Idade(Nascimento){
          $.ajax({
              type: "POST",
              url: "Idade.asp?Nascimento="+Nascimento,
              success: function( data )
              {
                  $(".crumb-link").html(data);
              }
          });
      }
      $("#NomePaciente").change(function(){
          $(".crumb-active a").html( $(this).val() );
      });

      var SayCheese2 = function() {

      };

      var sayCheese = new SayCheese('#divAvatar', { snapshot: true });

		$('#clicar').on('click', function(evt) {
	      //  var sayCheese = new SayCheese('#divAvatar', { snapshot: true });
			sayCheese.on('start', function() {
			  $('#take-photo').on('click', function(evt) {
				sayCheese.takeSnapshot();
				$.post("uploader.php?P=pacientes&I=<%=req("I")%>&Col=Foto&L=<%= replace(session("Banco"), "clinic", "") %>", $("#takeUpload").serialize(), function(data, status){ eval(data) });
			});
        });


		function cancelar(){
			sayCheese.on('stop', function(evt) {
			$( "video" ).remove();
			});
		sayCheese.stop();
		//alert("toaqui");return false;
		//$('#photo').html('');
		}




        sayCheese.on('error', function(error) {
          var alert = $('<div>');
          alert.addClass('alert alert-error').css('margin-top', '20px');

          if (error === 'NOT_SUPPORTED') {
            alert.html("<strong></strong> ERRO: Seu navegador não possui suporte a captura direta! <br>Para utilizar este recurso, utilize o Google Chrome!");
          } else if (error === 'AUDIO_NOT_SUPPORTED') {
            alert.html("<strong>:(</strong> seu navegador não possui suporte a áudio!");
          } else {
            alert.html("<strong>:(</strong> você precisa clicar em 'permitir' para usar está função!");
          }

          $('#divAvatar').html(alert);

        });

        sayCheese.on('snapshot', function(snapshot) {
			$('#divAvatar').hide();
        	var img = document.createElement('img');

          $(img).on('load', function() {
            $('#photo').val(img);
          });
          img.src = snapshot.toDataURL('image/jpg');
          $("#photo-data").val(snapshot.toDataURL('image/jpg'));

          $('#photo').empty();
          $('#photo').html(img);
        });

        sayCheese.start();
		$("#divDisplayUploadFoto").css("display", "none");
		$("#cancelar, #take-photo").css("display", "block");
  });

function stopVideo(){
	$("#cancelar, #take-photo").css("display", "none");
	$("#divDisplayUploadFoto").css("display", "block");
}

<%
      set obriga = db.execute("select * from obrigacampos where Tipo='Paciente' and ( Obrigar is not null or Obrigar <> '')")
      if not obriga.eof then
        Obr = obriga("Obrigar")
        splObr = split(Obr, ", ")
        for o=0 to ubound(splObr)
            %>
      $("#<%=replace(splObr(o), "|", "") %>").prop("required", true);
        <%
        next
      end if
       %>



</script>
<form id="takeUpload" action="" method="POST">
    <input id="photo-data" name="photo-data" type="hidden">
</form>

<%
set memed = db.execute("select * from memed_tokens where sysActive='1' and sysUser ="&session("User"))

if not memed.eof then
%>

<script
    type="text/javascript"
    src="https://memed.com.br/modulos/plataforma.sinapse-prescricao/build/sinapse-prescricao.min.js"
    data-token="<%=memed("Token")%>"
    data-color="#217dbb">
</script>
<script>
    function openMemed () {
       MdHub.command.send('plataforma.prescricao', 'setPaciente', {
         nome: $("#NomePaciente").val(),
         telefone: $("#Cel1").val().replace("-","").replace("(","").replace(")","").replace(" ",""),
         endereco: $("#Endereco").val(),
         cidade: $("#Cidade").val(),
         idExterno:'<%=session("Banco")%>' +  '-' + '<%=req("I")%>'
       });

       console.log('<%=session("Banco")%>' +  '-' + '<%=req("I")%>');
       setTimeout(function() {
         MdHub.module.show('plataforma.prescricao');
         MdHub.event.add('prescricaoSalva', function prescricaoSalvaCallback(idPrescricao) {
             postUrl('prescription/memed/save-prescription', {
                 prescriptionId: idPrescricao,
                 patientId: '<%=req("I")%>'
             }, function (data) {
                 console.log(data);
             })
         });
       } , 500);
    }
</script>
<% end if %>



<!--#include file="disconnect.asp"-->

<%
    if req("Agenda")="" then
    %>
    <script src="vendor/plugins/dropzone/dropzone.min.js"></script>
    <script src="assets/js/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="js/editor.js"></script>
    <script src="vendor/plugins/mixitup/jquery.mixitup.min.js"></script>
    <script src="vendor/plugins/fileupload/fileupload.js"></script>
    <script src="vendor/plugins/holder/holder.min.js"></script>
    <%
end if
%>