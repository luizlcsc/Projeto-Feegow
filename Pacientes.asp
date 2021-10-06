<!--#include file="functions.asp"-->
<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<% IF req("ValidarCertificado") <> "" and req("AgendamentoID")<>"" THEN

    db.execute("SET @sysUSER = "&session("User")&";")
    db.execute("SET @pacienteID = "&req("PacienteID")&";")
    db.execute("SET @atendimentoID = (SELECT id FROM atendimentos WHERE AgendamentoID = "&treatvalzero(req("AgendamentoID"))&" LIMIT 1);")

    sql = " SELECT count(*) > 0 as qtd,'ATENDIMENTO'                                      "&chr(13)&_
          " FROM atendimentos as A                                                        "&chr(13)&_
          " LEFT JOIN dc_pdf_assinados B on A.id = B.DocumentoID and tipo = 'ATENDIMENTO' "&chr(13)&_
          " WHERE true                                                                    "&chr(13)&_
          "   AND A.id = @atendimentoID                                                   "&chr(13)&_
          "   AND A.PacienteID = @pacienteID                                              "&chr(13)&_
          "   AND B.id is not null                                                        "&chr(13)&_
          "   AND A.sysUser= @sysUSER                                                     "

    set Atendimento = db.execute(sql)

    IF Atendimento("qtd") = "1" THEN
        response.write("true")
        response.end
    END IF

    sql = " SELECT SUM(quantidade) as qtd FROM (                                   "&chr(13)&_
          " SELECT count(*) AS quantidade,'ATESTADO'                                      "&chr(13)&_
          " FROM pacientesatestados as A                                                  "&chr(13)&_
          " LEFT JOIN dc_pdf_assinados B on A.id = B.DocumentoID and tipo = 'ATESTADO'    "&chr(13)&_
          " WHERE true                                                                    "&chr(13)&_
          "   AND A.AtendimentoID = @atendimentoID                                        "&chr(13)&_
          "   AND A.PacienteID = @pacienteID                                              "&chr(13)&_
          "   AND B.id is null                                                            "&chr(13)&_
          "   AND a.sysActive = 1                                                         "&chr(13)&_
          "   AND A.sysUser= @sysUSER                                                     "&chr(13)&_
          " UNION                                                                         "&chr(13)&_
          " SELECT count(*),'PEDIDO_EXAME'                                                "&chr(13)&_
          " FROM pacientespedidos as A                                                    "&chr(13)&_
          " LEFT JOIN dc_pdf_assinados B on A.id = B.DocumentoID and tipo = 'PEDIDO_EXAME'"&chr(13)&_
          " WHERE true                                                                    "&chr(13)&_
          "   AND A.PacienteID = @pacienteID                                              "&chr(13)&_
          "   AND A.AtendimentoID = @atendimentoID                                        "&chr(13)&_
          "   AND B.id is null                                                            "&chr(13)&_
          "   AND a.sysActive = 1                                                         "&chr(13)&_
          "   AND A.sysUser= @sysUSER                                                     "&chr(13)&_
          " UNION                                                                         "&chr(13)&_
          " SELECT count(*),'PRESCRICAO'                                                  "&chr(13)&_
          " FROM pacientesprescricoes as A                                                "&chr(13)&_
          " LEFT JOIN dc_pdf_assinados B on A.id = B.DocumentoID and tipo = 'PRESCRICAO'  "&chr(13)&_
          " WHERE true                                                                    "&chr(13)&_
          "   AND A.PacienteID = @pacienteID                                              "&chr(13)&_
          "   AND A.AtendimentoID = @atendimentoID                                        "&chr(13)&_
          "   AND B.id is null                                                            "&chr(13)&_
          "   and A.sysUser= @sysUSER                                                     "&chr(13)&_
          "   AND a.sysActive = 1) as t;                                                  "

    set Atendimento = db.execute(sql)

    IF Atendimento("qtd") = "0"  THEN
        response.write("true")
        response.end
    END IF

    response.write("false")
    response.end
END IF

IF req("Acao") = "CancelarTelemedicina" AND session("AtendimentoTelemedicina")&""<>"" THEN
    set ate = db.execute("SELECT id FROM atendimentos WHERE AgendamentoID = "&session("AtendimentoTelemedicina"))
    db.execute("DELETE FROM atendimentoonline WHERE AgendamentoID = "&session("AtendimentoTelemedicina"))
    db.execute("DELETE FROM atendimentos WHERE AgendamentoID = "&session("AtendimentoTelemedicina"))
    db.execute("UPDATE agendamentos SET StaID=6 WHERE id = "&session("AtendimentoTelemedicina"))
    IF NOT ate.EOF THEN
        session("Atendimentos") = replace(session("Atendimentos"), "|"&ate("id")&"|", "")
    END IF
    session("AtendimentoTelemedicina") = ""
    response.Redirect("./?P=Pacientes&Pers=1&I="&req("I"))
    response.end
END IF

sqlArquivo = 	" select count(tda.id) as qtd_arquivoInvalido, group_concat(distinct tda.NomeArquivo ORDER BY  tda.NomeArquivo ASC SEPARATOR ', ') as descricao	"&chr(13)&_
				" 	from pacientesprotocolos pp                                                           												"&chr(13)&_
				" 	join pacientesprotocolosmedicamentos ppm on ppm.PacienteProtocoloID = pp.id           												"&chr(13)&_
				" 	join protocolos_documentos pd on ppm.ProtocoloID  = pd.protocoloID                    												"&chr(13)&_
				" 	join tipos_de_arquivos tda on tda.id = pd.tipoDocumentoID                             												"&chr(13)&_
				" 	left join arquivos a on a.TipoArquivoID = tda.id                                      												"&chr(13)&_
				" 	where tda.sysActive =1                                                                  												"&chr(13)&_
				" 	and a.id is null or a.Validade <= now()                                               												"

 arquivoVencido = recordToJSON(db.execute(sqlArquivo))

%>

<!--#include file="modal.asp"-->
<!--#include file="modalComparar.asp"-->
<%
isProposta = req("isProposta")
if isProposta = "S" then
%>
<script>
$(function(){
	$("#tabPropostas").trigger("click")
});
</script>
<%
end if
%>

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
if session("Admin")=1 then
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
<%
if session("MasterPwd")&""="S" then
    %>
.sensitive-data{
    filter: blur(6px);
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    -khtml-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
}
    <%
end if
%>
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

#btn-gerar-contrato{
    margin-top: 20px !important;
}
#TabelaID{
  /* margin-top: 0px !important;*/
}
.infoPreco{
    display: none;
    position: absolute;
    bottom: 100%;
    left: -100%;
    background-color: white;
    border: 1px solid #217dbb;
    flex-direction: column;
    padding: 10px;
    border-radius: 7px;
    width: auto;
    min-width: calc( 150% + 100px);
    z-index: 10;
}
.infoPreco:after {
	content: "";
	height: 5px;
	width: 5px;
	position: absolute;
	bottom: -11px;
	left: 17%;
	border-left: 5px solid transparent;
	border-right: 5px solid transparent;
	border-top: 5px solid #217dbb;
	border-bottom: 5px solid transparent;
}
.hoverPreco{
	display:flex!important
}
i.infoBtnPreco {
	float:left;
	color: #217dbb;
}
</style>
<%
if req("Agenda")="" then
	%><!--#include file="PacientesCompleto.asp"--><%
else
	%><!--#include file="PacientesCompleto.asp"--><%
end if
%>

<script src="//unpkg.com/vanilla-masker@1.1.1/lib/vanilla-masker.js"></script>
<script>
	function inputHandler(masks, max, event) {
		var c = event.target;
		var v = c.value.replace(/\D/g, '');
		var m = c.value.length > max ? 1 : 0;
		VMasker(c).unMask();
		VMasker(c).maskPattern(masks[m]);
		c.value = VMasker.toPattern(v, masks[m]);
	}

	var docMask = ['999.999.999-99', '99.999.999/9999-99'];
	var doc = document.querySelector("#pPacientesRelativos input[name^='CPF']");

	doc.addEventListener('input', inputHandler.bind(undefined, docMask, 14), false);
	doc.addEventListener('change', function(arg){
		if(!((arg.target.value+"").length == 14 || (arg.target.value+"").length == 18)){
			arg.target.value = ""
		}
	});

</script>

<script type="text/javascript">
function showMessage(text, state, title) {
	var states = {
		0: {
			"class": "gritter-error",
			"type": "danger",
			"label": "Erro no envio da guia!"
		},
		1: {
			"class": "gritter-warning",
			"type": "warning",
			"label": "Guia glosada!"
		},
		2: {
			"class": "gritter-success",
			"type": "success",
			"label": typeof title !== "undefined" ? title : "Guia autorizada!"
		},
		3: {
			"class": "gritter-success",
			"type": "info",
			"label": "Status da guia"
		},
		4: {
			"class": "gritter-warning",
			"type": "warning",
			"label": "Arquivo(s) obrigatório(s) vencido(s)"
		}
	};
	// && !PNotify
	if (PNotify) {
		//    pnotify
		console.log('CALLING PNOTIFY')
		new PNotify({
			title: states[state].label,
			text: text,
			type: states[state].type // all contextuals available(info,system,warning,etc)
		});
	} else {
		$.gritter.add({
			// (string | mandatory) the heading of the notification
			title: states[state].label,
			// (string | mandatory) the text inside the notification
			text: text,
			class_name: states[state].class,
			time: 5000
		});
	}
};
/**
 * Função para Autorizar Internações
 */
function verificaElegibilidade(N) {
	var baseUrl = domain + "autorizador-tiss/";
	var $btn = $("#btnElegibilidade"+N);
	var $ico = $("#icoElegibilidade"+N);
	//$ico.removeClass('btn btn-xs btn-warning');
	$ico.addClass('fas fa-circle-notch fa-spin');
	$btn.attr("disable", true);
	$.ajax({
		type: "GET",
		url: baseUrl + "verificaElegibilidadeBeneficiario",
		data: {	ConvenioID: $("#ConvenioID"+N).val(),
				CNS: $("#CNS").val(),
				IdentificacaoBeneficiario: $("#IdentificacaoBeneficiario").val(),
				Matricula: $("#Matricula"+N).val(),
				Validade: $("#Validade"+N).val(),
				NomePaciente: $("#NomePaciente").val()
				},
		success: function (data) {
			var message = "",
			state = 0;
			//$ico.toggleClass('btn btn-xs btn-warning');
			$ico.removeClass('fas fa-circle-notch fa-spin');
			$btn.attr("disable", false);
			// situações possíveis de retorno
			//	0- Erro no envio da guia
			//	1- Guia Glosada
			//	2- Processo autorizado
			//	3- Retona o status da guia
			//  4 - Plano não possui este método

			switch (data.Sucesso) {
				case 0:
					message = data.Mensagem;
					state = 0;
					break;
				case 1:
					message  = data.Mensagem;
					state = 1;
					break;
				case 2:
					if (data.QuantidadeAutorizada > data.QuantidadeSolicitada) {
						message = 'Todos os <B>'+ data.QuantidadeAutorizada+'</B> procedimentos Autorizados!';
					} else {
						// exibir mensagem informando que alguns procedimentos não foram autorizados e os motivos
						message = 'ATENÇÃO! <BR>Alguns procedimentos não foram autorizados! <BR>';
						message += 'Código: ' + data.CodigoGlosa + ' Motivo: ' + data.Glosa;
						state  = 1;
					}
					message  = data.Mensagem;
					state = 2;
					break;
				case 3:
					message  = data.Mensagem;
					state = 3;
					break;
				case 4:
				    message = 'ATENÇÃO! <BR>Esta operação <strong>NÃO ESTÁ DISPONÍVEL</strong> para este convênio! <BR>';
					state  = 1;
			}
			if (data.CodigoGlosa!=''){
				message += '<BR> Código Glosa: ' + data.CodigoGlosa + '<BR> Motivo Glosa: ' + data.Glosa;
			}
			showMessage(message, state);
		},
		error: function () {
			showMessage("Tente Verificar pelo portal da operadora.", 0);
		}
	});
};

function elegibilidade(N, codigoPrestadorNaOperadora){
    $.post("/feegow_components/index.php/Autorizador_tiss/verificaelegibilidade?I=<%=req("I")%>&U=<%=session("User")%>", {
			guideId: "0",
			I: <%=req("I")%>,
			U: <%=session("User")%>,
            gConvenioID : $("#ConvenioID"+N).val(),
            NumeroCarteira : $("#Matricula"+N).val(),
            IdentificadorBeneficiario : $("#NomePaciente").val(),
			ValidadeCarteira : $("#Validade"+N).val(),
			codigoPrestadorNaOperadora : codigoPrestadorNaOperadora
    }, function(data) {
		if(data.Mensagem == "S")
			alert("Paciente elegível");
		else
			alert("Paciente não elegível");
    });
}

var validar = false;
<% IF getConfig("ValidarDocumentosCertificado") = 1 THEN %>
    validar = true;
<% END IF %>

function atender(AgendamentoID, PacienteID, Acao, Solicitacao){

    var atenderF = () => {
        $.ajax({
        		type:"POST",
        		data:$("#frmFimAtendimento").serialize(),
        		url:"atender.asp?Atender="+AgendamentoID+"&I="+PacienteID+"&Acao="+Acao+"&Solicitacao="+Solicitacao,
        		success:function(data){
        			$("#divContador").html(data);
        		}
        });
    }

	const $assinaturaAuto = $("#AssinaturaAuto");

	if($assinaturaAuto){
		if($assinaturaAuto.prop("checked")){
			assinarAtendimento(function(){
				atenderF();
			});

			return
		}
	}

    if(validar){
         $.ajax({
            type:"POST",
            data:$("#frmFimAtendimento").serialize(),
            url:"Pacientes.asp?ValidarCertificado=1&AgendamentoID="+AgendamentoID+"&PacienteID="+PacienteID,
            success:function(data){
                if (data === 'false'){
                    new PNotify({
                            title: '<i class="far fa-warning"></i> Certificado Digital',
                            text: `Para finalizar o atendimento,o usuário deverá certificar os documentos.`,
                            type: 'danger'
                        });
                    return;
                }
                atenderF();
            }
         });
         return;
    }

    atenderF();

}

function verificaArquivos(){
	let arquivoVencido = JSON.parse('<%= arquivoVencido %>')[0];
	if(arquivoVencido.qtd_arquivoInvalido >0){
		showMessage(`Este paciente tem ${arquivoVencido.qtd_arquivoInvalido} arquivo${arquivoVencido.qtd_arquivoInvalido>1?'s':''} vencido${arquivoVencido.qtd_arquivoInvalido>1?'s':''} ou faltantes sendo ele${arquivoVencido.qtd_arquivoInvalido>1?'s':''} : ${arquivoVencido.descricao}`,4,`Arquivo${arquivoVencido.qtd_arquivoInvalido>1?'s':''} obrigatório${arquivoVencido.qtd_arquivoInvalido>1?'s':''} vencido${arquivoVencido.qtd_arquivoInvalido>1?'s':''} ou faltantes` )
	}
}

$(document).ready(function(e) {
	var dadosPacienteFicha=null
	$("#save").click(function(e){
		e.preventDefault();

		$("#frm").find("select:required").css({"display": "","opacity": "0"});
		$("#frm").find("select:required option[value='0']").val("");
		dadosPacienteFicha= $("#frm");

		if(dadosPacienteFicha[0].reportValidity()){
			$("#frm").submit();
		}else{
			return false;
		}
	});

    <%call formSave("frm", "save", "$(""#DadosAlterados"").attr('value', ''); callbackAgendamentoPaciente(); ")%>

	function callbackAgendamentoPaciente() {
		console.log(dadosPacienteFicha)
		<%
		if req("Agenda")<>"" then
		%>
			var camposAAtualizar = ["Tel1", "Cel1", "Email1", "Tabela"];

			camposAAtualizar.forEach(function(campoAAtualizar) {
				var v =  dadosPacienteFicha.find("#"+campoAAtualizar ).val() ;
				$(" #age"+campoAAtualizar ).val(v);
			});

			$.get("AgendamentoCheckin.asp", {id: '<%=req("AgendamentoID")%>'}, function(data) {
				$(".checkin-conteudo-paciente").html(data);
			});

			$(" #searchPacienteID" ).val( $(" #NomePaciente" ).val() );

			$("#myTab4 a[href=#dadosAgendamento]").click();
		<%
		end if
		%>
	}
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
	$("#Dados, #p1, #pPacientesRetornos, #pPacientesRelativos, #dCad, .alerta-dependente, #Servicos, #block-care-team, #block-programas-saude").removeClass("hidden");
    $("#rbtns").fadeIn();
	//$("#save").removeClass("hidden");
});
$(".tab").click(function(){
	$("#DadosComplementares").slideUp();
	$("#divAvatar").removeClass("col-md-2");
	$("#divAvatar").addClass("col-md-1");
	$("#divDisplayUploadFoto").css("display", "none");
	$("#resumoConvenios").removeClass("hidden");
	$("#pront, .tray-left").removeClass("hidden");
	$("#Dados, #p1, #pPacientesRetornos, #pPacientesRelativos, #dCad, .alerta-dependente, #Servicos, #block-care-team, #block-programas-saude").addClass("hidden");
    //$("#save").addClass("hidden");
});

$(".menu-aba-pacientes-dados-principais" ).click(function() {
  	$("#pacientesDadosComplementares").show();
});
$("#tabExtrato").click(function() {
  	$("#pacientesDadosComplementares").hide();
});

function pront(U){
    $("#rbtns").fadeOut();
	$("#pacientesDadosComplementares").hide();
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
	$('#user-profile-3').find('input[type=file]').ace_file_input({
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
<%
Parametros = "P="&req("P")&"&I="&req("I")&"&Col=Foto&L="& replace(session("Banco"), "clinic", "")
%>
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

		$("#Foto").change(async function() {

		    await uploadProfilePic({
		        $elem: $("#Foto"),
		        userId: "<%=req("I")%>",
		        db: "<%= LicenseID %>",
		        table: 'pacientes',
		        content: file_input.data('ace_input_files')[0] ,
		        contentType: "form"
		    });

			if(!file_input.data('ace_input_files')) return false;//no files selected
		});

		$form.on('reset', function() {
			file_input.ace_file_input('reset_input');
		});

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
      //novo envio de foto tirada do paciente
    let endpointupload =  async (objct) => {
        await uploadProfilePic({
            $elem: $("#Foto"),
            userId: "<%=req("I")%>",
            db:"<%= LicenseID %>",
            table:'pacientes',
            content: objct ,
            contentType: "base64",
            elem:$('#divDisplayFoto img')
        });
    };


       //change to feegow-api
      var sayCheese = new SayCheese('#divAvatar', { snapshot: true });

		$('#clicar').on('click', function(evt) {
	      //  var sayCheese = new SayCheese('#divAvatar', { snapshot: true });
			sayCheese.on('start', function() {
			  $('#take-photo').on('click', function(evt) {
                sayCheese.takeSnapshot();
                let objct = {};
                objct.userType = 'pacientes';
                objct.userId = "<%=req("I")%>";
                objct.licenca = "<%= replace(session("Banco"), "clinic", "") %>";
                objct.upload_file = $("input[name='photo-data']").val();
                objct.folder_name = "Perfil";
                endpointupload(objct);

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
      set obriga = db.execute("select * from obrigacampos where Tipo='Paciente' and Obrigar like '%|%'")
      if not obriga.eof then
        Obr = obriga("Obrigar")
        splObr = split(Obr, ", ")
        for o=0 to ubound(splObr)
            %>

            setTimeout(function(){
                <%
                if replace(splObr(o), "|", "")="Tel1" then
                %>
                console.log($("#<%=replace(splObr(o), "|", "") %>").parents(".qf"))
                <%
                end if
                %>
                if(!$("#<%=replace(splObr(o), "|", "") %>").parents(".qf").hasClass("hidden")){
                    $("#<%=replace(splObr(o), "|", "") %>").prop("required", true);
                }
					$("label[for='<%=replace(splObr(o), "|", "") %>']").append(` <i class='fas fa-asterisk text-danger input-required-asterisk' ></i>`);
            }, 500);
			<%
        next
      end if
       %>


</script>
<form id="takeUpload" action="" method="POST">
    <input id="photo-data" name="photo-data" type="hidden">
</form>

<!--#include file="Classes/Memed.asp"-->

<script>
    function handleFormOpenError(t, p, m, i, a, FormID, CampoID){
            showMessageDialog("Ocorreu um erro ao abrir este registro. Tente novamente mais tarde.");

            gtag('event', 'erro_500', {
                'event_category': 'erro_prontuario',
                'event_label': "Erro ao abrir prontuário. Dados: " + JSON.stringify([t, p, m, i, a, FormID, CampoID]),
            });
    }

	<%
	FormularioNaTimeline = getConfig("FormularioNaTimeline")

	if FormularioNaTimeline then
		InserirDinamico = "|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|"
	end if

    IF FormularioNaTimeline THEN
    %>
    function iPront(t, p, m, i, a, FormID, CampoID) {
        if (t == 'AE' || t == 'PrescricaoAELDiagnosticoAtestadoImagensArquivosPedido') {
            $(".timeline-add").slideUp();
            divAff = "#divProtocolo";
            scr = "protocolo";
        } else if (t == 'L') {
            mfpform('#modal-form');
            divAff = "#modal-form .panel";
            scr = "iPront";
        }else{
            //mfp('#modal-form');
            $("#modal-table").modal("show");
            divAff = "#modal";
            scr = "iPront";
        }
        var pl = $("#ProfissionalLaudadorID").val();
        $(divAff).html("<center><i class='far fa-2x fa-circle-o-notch fa-spin'></i></center>");
        $.get(scr + ".asp?pl=" + pl + "&t=" + t + "&p=" + p + "&m=" + m + "&i=" + i + "&a=" + a + "&FormID=" + FormID + "&CampoID=" + CampoID, function (data) {
            $(divAff).html(data);
        }).fail(function (data){
            handleFormOpenError(t, p, m, i, a, FormID, CampoID);
        });
    }

    <%
    ELSE
    %>
        function iPront(t, p, m, i, a, FormID, CampoID) {
            $("#modal-form .panel").html("<center><i class='far fa-2x fa-circle-o-notch fa-spin'></i></center>");
            if(t=='AE'||t=='L'){
                try{
                    $.magnificPopup.open({
                            removalDelay: 500,
                            closeOnBgClick:false,
                            modal: true,
                            items: {
                                src: '#modal-form'
                            },
                            // overflowY: 'hidden', //
                            callbacks: {
                                beforeOpen: function(e) {
                                    this.st.mainClass = "mfp-zoomIn";
                                }
                            }
                        });
                }catch (e) {
                    alert(e)

                }
            }else{
                mfp('#modal-form');
            }
            var pl = $("#ProfissionalLaudadorID").val();
            $.get("iPront.asp?pl=" + pl + "&t=" + t + "&p=" + p + "&m=" + m + "&i=" + i  + "&a=" + a, function (data) {
                $("#modal-form .panel").html(data);
            }).fail(function (data){
                handleFormOpenError(t, p, m, i, a, FormID, CampoID)
                $("#modal-form").magnificPopup("close");
            });
        }
    <%
    END IF
    %>
</script>

<script src="src/imageUtil.js"></script>
<script>
<% IF req("ToArea")<>"" THEN %>
    $(".<%=req("ToArea")%>").click();
<% END IF %>

</script>



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
