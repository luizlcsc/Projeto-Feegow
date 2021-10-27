<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalComparar.asp"-->
<%


call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from Pacientes where id="&req("I"))
%>
<input type="hidden" name="DadosAlterados" id="DadosAlterados" value="" />
<form method="post" id="frm" name="frm" action="save.asp">
	<input type="hidden" name="I" value="<%=req("I")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />
    <div class="row">
        <div class="col-md-8">
            <ul class="breadcrumb">
                <li>
                    <i class="far fa-dashboard home-icon"></i>
                    <a href="?P=Home&Pers=1">In&iacute;cio</a>
                </li>
                <li>
                    <%=inicioA%><%=resourceName%><%=fimA%>
                </li>
                <li class="active">Edi&ccedil;&atilde;o de Registro</li>
            </ul><!-- .breadcrumb -->
        </div>
        <div class="col-md-2">
        <%
		if (reg("sysActive")=1 and aut("pacientesA")=1) or (reg("sysActive")=0 and aut("pacientesI")=1) then
		%>
            <button class="btn btn-block btn-primary" id="save">
                <i class="far fa-save"></i> Salvar
            </button>
        <%
		end if
		%>
        </div>
        <div class="col-md-2">
            <button type="button" id="btnFicha" class="btn btn-block btn-info">
                <i class="far fa-print"></i> Imprimir Ficha
            </button>
        </div>
    </div>
    <hr />
<%
if reg("Foto")="" or isnull(reg("Foto")) then
	divDisplayUploadFoto = "block"
	divDisplayFoto = "none"
else
	divDisplayUploadFoto = "none"
	divDisplayFoto = "block"
end if
%>
<div class="clearfix form-actions no-margin">
	<div class="col-md-2" id="divAvatar">
            <div id="divDisplayUploadFoto" style="display:<%=divDisplayUploadFoto%>">
                <input type="file" name="Foto" id="Foto" />
            </div>
            <div id="divDisplayFoto" style="display:<%= divDisplayFoto %>">
	            <img id="avatarFoto" src="uploads/<%=reg("Foto")%>" class="img-thumbnail" width="100%" />
                <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="far fa-trash"></i></button>
            </div>
    </div>
    <div class="col-md-10">
        <div class="row">
            <%=quickField("text", "NomePaciente", "Nome", 4, reg("NomePaciente"), "", "", " required")%>
            <%=quickField("datepicker", "Nascimento", "Nascimento", 3, reg("Nascimento"), "input-mask-date", "", "")%>
            <%=quickField("simpleSelect", "Sexo", "Sexo", 1, reg("Sexo"), "select * from Sexo where sysActive=1", "NomeSexo", "")%>
            <%=quickField("simpleSelect", "CorPele", "Cor da Pele", 2, reg("CorPele"), "select * from CorPele where sysActive=1", "NomeCorPele", "")%>
            <div class="col-md-2" id="divContador">
            	<%server.Execute("atender.asp")%>
            </div>
        </div>
        <div class="row" id="DadosComplementares">
            <div class="col-md-4"><br />
            	<span class="label label-xlg label-info arrowed-in-right arrowed-in block" id="Idade"><%call Idade(reg("Nascimento"))%></span>
            </div>
			<%= quickField("text", "Altura", "Altura", 2, reg("Altura"), " input-mask-brl text-right", "", "") %>
            <%= quickField("text", "Peso", "Peso", 2, reg("Peso"), "input-mask-brl text-right", "", "") %>
            <%= quickField("text", "IMC", "IMC", 2, reg("IMC"), "text-right", "", " readonly") %>
            <div class="col-md-2">
            	<label>Prontu&aacute;rio<br /></label>
                <input type="text" class="form-control text-right" value="<%=reg("id")%>" disabled="disabled" />
            </div>
        </div>
	</div>
</div>
<div class="tabbable tabs-left">
    <ul class="nav nav-tabs" id="myTab3">
        <li class="active">
            <a data-toggle="tab" class="mainTab" href="#Dados">
                <i class="blue icon-user bigger-110"></i>
                <span class="hidden-480">Dados Principais</span>
            </a>
        </li>
		<%
		if aut("formsae")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="abaForms" href="#forms" onclick="PacientesForms('AE');">
                <i class="far fa-bar-chart bigger-110"></i>
                <span class="hidden-480">Anamnese e Evolu&ccedil;&otilde;es</span>
            </a>
        </li>
		<%
		end if
		if aut("formsl")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" href="#forms" onclick="PacientesForms('L');">
                <i class="far fa-align-justify bigger-110"></i>
                <span class="hidden-480">Laudos</span>
            </a>
        </li>
		<%
		end if
		if aut("diagnosticos")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="tabDiagnosticos" href="#divDiagnosticos">
                <i class="far fa-stethoscope bigger-110"></i>
                <span class="hidden-480">Diagn&oacute;sticos &raquo; <small>CID-10</small></span>
            </a>
        </li>
        <%
		end if
		if aut("prescricoes")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="abaPrescricoes" href="#prescricoes">
                <i class="far fa-beaker bigger-110"></i>
                <span class="hidden-480">Prescri&ccedil;&otilde;es</span>
            </a>
        </li>
		<%
		end if
		if aut("atestados")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="abaAtestados" href="#atestados">
                <i class="far fa-foursquare bigger-110"></i>
                <span class="hidden-480">Atestados</span>
            </a>
        </li>
		<%
		end if
		if aut("pedidosexame")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="abaPedidos" href="#pedidosexame">
                <i class="far fa-hospital bigger-110"></i>
                <span class="hidden-480">Pedidos de Exame</span>
            </a>
        </li>
		<%
		end if
		if aut("imagens")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="tabImagens" href="#divImagens">
                <i class="far fa-camera bigger-110"></i>
                <span class="hidden-480">Imagens</span>
            </a>
        </li>
		<%
		end if
		if aut("arquivos")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="tabArquivos" href="#divArquivos">
                <i class="far fa-file bigger-110"></i>
                <span class="hidden-480">Arquivos</span>
            </a>
        </li>
		<%
		end if
		if aut("agenda")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" href="#HistoricoPaciente" onclick="agendamentos(<%=req("I")%>);">
                <i class="far fa-calendar bigger-110"></i>
                <span class="hidden-480">Agendamentos</span>
            </a>
        </li>
		<%
		end if
		if aut("recibos")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="tabRecibos" href="#divRecibos">
                <i class="far fa-edit bigger-110"></i>
                <span class="hidden-480">Recibos</span>
            </a>
        </li>
		<%
		end if
		if aut("guias")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" href="#tiss">
                <i class="far fa-exchange"></i>
                <span class="hidden-480">Guias TISS</span>
            </a>
        </li>
		<%
		end if
		if aut("contapac")=1 then
		%>
        <li>
            <a data-toggle="tab" class="tab" id="tabExtrato" href="#divExtrato">
                <i class="far fa-money"></i>
                <span class="hidden-480">Extrato</span>
            </a>
        </li>
        <%
		end if
		%>
    </ul>

    <div class="tab-content">
        <div id="Dados" class="tab-pane in active">
        	<div class="row">
            	<div class="col-md-8">
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
                        <div class="col-md-2">
	                        <%= selectInsert("Pa&iacute;s", "Pais", reg("Pais"), "paises", "NomePais", "", "", "") %>
                        </div>
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
                        <%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 6, reg("Observacoes"), "", "", "") %>
                        <%= quickField("memo", "Pendencias", "Pend&ecirc;ncias", 6, reg("Pendencias"), "", "", "") %>
                    </div>
                </div>
                <div class="col-md-4">
                	<blockquote class="">
                    <div class="row">
                        <%= quickField("text", "Profissao", "Profiss&atilde;o", 6, reg("profissao"), "", "", "") %>
                        <%= quickField("simpleSelect", "GrauInstrucao", "Escolaridade", 6, reg("grauinstrucao"), "select * from GrauInstrucao where sysActive=1 order by GrauInstrucao", "GrauInstrucao", "") %>
                        <%= quickField("text", "Documento", "RG", 6, reg("Documento"), "", "", "") %>
                        <%= quickField("text", "CPF", "CPF", 6, reg("CPF"), " input-mask-cpf", "", "") %>
                        <%= quickField("text", "Naturalidade", "Naturalidade", 6, reg("Naturalidade"), "", "", "") %>
						<%= quickField("simpleSelect", "EstadoCivil", "Estado Civil", 6, reg("estadocivil"), "select * from EstadoCivil where sysActive=1 order by EstadoCivil", "EstadoCivil", "") %>
                        <%= quickField("simpleSelect", "Origem", "Origem", 6, reg("Origem"), "select * from Origens where sysActive=1 order by Origem", "Origem", "") %>
                        <%= quickField("text", "IndicadoPor", "Indica&ccedil;&atilde;o", 6, reg("IndicadoPor"), "", "", "") %>
                        <%= quickField("text", "Religiao", "Religi&atilde;o", 6, reg("Religiao"), "", "", "") %>
                        <%
						set tab = db.execute("select * from TabelaParticular where sysActive=1")
						if tab.EOF then
							%><input type="hidden" name="Tabela" value="0" id="Tabela" /><%
						else
							response.Write(quickField("select", "Tabela", "Tabela", 6, Tabela, "select * from TabelaParticular where Ativo='on' and sysActive=1", "NomeTabela", ""))
						end if
						%>
                    </div>
                    </blockquote>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
	            	<!--#include file="PacientesConvenio.asp"-->
                </div>
            </div>
            <div class="row">
            	<div class="col-md-6">
					<%call Subform("PacientesRetornos", "PacienteID", req("I"),"frm")%>
                </div>
            	<div class="col-md-6">
					<%call Subform("PacientesRelativos", "PacienteID", req("I"), "frm")%>
                </div>
            </div>
        </div>

        <div id="prescricoes" class="tab-pane min-tabs">
			<!--#include file="PacientesPrescricoes.asp"-->
        </div>
        <div id="atestados" class="tab-pane min-tabs">
			<!--#include file="PacientesAtestados.asp"-->
        </div>
        <div id="pedidosexame" class="tab-pane min-tabs">
			<!--#include file="PacientesPedidosExame.asp"-->
        </div>
        <div id="forms" class="tab-pane min-tabs">
			Carregando...
        </div>
        <div id="HistoricoPaciente" class="tab-pane min-tabs">
			Carregando...
        </div>
        <div id="divExtrato" class="tab-pane min-tabs">
			Carregando...
        </div>
        <div id="divRecibos" class="tab-pane min-tabs">
			Carregando...
        </div>
        <div id="divDiagnosticos" class="tab-pane min-tabs">
			Carregando...
        </div>
        <div id="divImagens" class="tab-pane min-tabs">
            <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=req("I")%>&Tipo=I"></iframe>
			<div id="albumImagens">
				Carregando...
            </div>
        </div>
        <div id="divArquivos" class="tab-pane min-tabs">
            <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=req("I")%>&Tipo=A"></iframe>
			<div id="albumArquivos">
				Carregando...
            </div>
        </div>
        <div align="center" id="tiss" class="tab-pane min-tabs">
			<img src="assets/img/naodisponivel.png" width="550" height="243" />
        </div>
    </div>
</div>
</form>
<script type="text/javascript">
function atender(AgendamentoID, PacienteID, Acao){
	$.ajax({
		type:"POST",
		url:"atender.asp?Atender="+AgendamentoID+"&I="+PacienteID+"&Acao="+Acao,
		success:function(data){
			$("#divContador").html(data);
		}
	});
}

$(document).ready(function(e) {
	<%call formSave("frm", "save", "$(""#DadosAlterados"").attr('value', '');")%>
});

$("#tabDiagnosticos").click(function(){
	cid10(0);
});
function cid10(X){
	$.ajax({
		type:"POST",
		url:"Diagnosticos.asp?PacienteID=<%=req("I")%>&X="+X,
		success:function(data){
			$("#divDiagnosticos").html(data);
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
	$.ajax({
		type:"POST",
		url:"Imagens.asp?PacienteID=<%=req("I")%>&X="+X,
		success:function(data){
			$("#albumImagens").html(data);
		}
	});
}

function atualizaArquivos(X){
	$.ajax({
		type:"POST",
		url:"Arquivos.asp?PacienteID=<%=req("I")%>&X="+X,
		success:function(data){
			$("#albumArquivos").html(data);
		}
	});
}

$("#tabImagens").click(function(){
	atualizaAlbum(0);
});

$("#tabArquivos").click(function(){
	atualizaArquivos(0);
});

$("#tabExtrato").click(function(){
	$.ajax({
		type:"POST",
		url:"Statement.asp?T=3_<%=req("I")%>",
		success:function(data){
			$("#divExtrato").html(data);
		}
	});
});

$("#Nascimento").change(function(){
	Idade($("#Nascimento").val());
})	


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
});
$(".tab").click(function(){
	$("#DadosComplementares").slideUp();
	$("#divAvatar").removeClass("col-md-2");
	$("#divAvatar").addClass("col-md-1");
	$("#divDisplayUploadFoto").css("display", "none");
});
function PacientesForms(Tipo){
	$.ajax({
		type: "POST",
		url: "PacientesForms.asp?PacienteID=<%=req("I")%>&Tipo="+Tipo,
		success:function(data){
			$("#forms").html(data);
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
</script>

<script src="../assets/js/ace-elements.min.js"></script>
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

<%
set lembrarme = db.execute("select * from buiformslembrarme where PacienteID="&req("I"))
if not lembrarme.EOF then
	%>
	$( document ).ready(function() {
	<%
	while not lembrarme.EOF
		Valor = ""
		set Campo = db.execute("select * from buicamposforms where id="&lembrarme("CampoID"))
		if not Campo.EOF then
			set Registro = db.execute("select * from `_"&lembrarme("ModeloID")&"` where id="&lembrarme("FormID"))
			if not Registro.EOF then
				if Campo("TipoCampoID")=4 then
					ValoresChecados = Registro(""&Campo("id")&"")
					splValoresChecados = split(ValoresChecados, ".")
					for i=0 to ubound(splValoresChecados)
						if isnumeric(splValoresChecados(i)) and splValoresChecados(i)<>"" then
							set pVal = db.execute("select * from buiopcoescampos where id = '"&splValoresChecados(i)&"'")
							if not pVal.EOF then
								Valor = Valor&pVal("Nome")&"<br />"
							end if
						end if
					next
				elseif Campo("TipoCampoID")=5 or Campo("TipoCampoID")=6 then
					set ValOp = db.execute("select * from buiopcoescampos where id = '"&replace( Registro(""&Campo("id")&"") , "|", "")&"'")
					Valor = ValOp("Nome")
				else
					Valor = Registro(""&Campo("id")&"")
				end if
				%>
				$.gritter.add({
						title: '<%=Campo("RotuloCampo")%>',
						text: '<%=Valor%>',
						image: 'assets/img/flag.png',
						sticky: true,
						time: '',
						class_name: 'gritter-danger '
					});
				<%
			end if
		end if
	lembrarme.movenext
	wend
	lembrarme.close
	set lembrarme = nothing
	%>
			return false;
		});
	<%
end if
%>

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

<!--#include file="disconnect.asp"-->
