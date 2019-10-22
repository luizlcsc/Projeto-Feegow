<%
if request.ServerVariables("HTTPS")="off" then
	if request.ServerVariables("REMOTE_ADDR")="::1" OR request.ServerVariables("REMOTE_ADDR")="127.0.0.1" OR request.QueryString("Partner")<>"" OR SESSION("Partner")<>"" then
'		response.Redirect( "https://localhost/feegowclinic/?P="&request.QueryString("P") )
	else
'		response.Redirect( "https://clinic.feegow.com.br/?P="&request.QueryString("P") )
	end if
end if

if session("User")="" and request.QueryString("P")<>"Login" and request.QueryString("P")<>"Trial" and request.QueryString("P")<>"Confirmacao" then
	response.Redirect("./?P=Login")
end if

if request.QueryString("P")<>"Login" and request.QueryString("P")<>"Trial" and request.QueryString("P")<>"Confirmacao" then
	if request.QueryString("P")<>"Home" and session("Bloqueado")<>"" then
		response.Redirect("./?P=Home&Pers=1")
	end if
%>
<!--#include file="connect.asp"-->
<!DOCTYPE html>
<html lang="en">
	<head>
		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<meta charset="utf-8" />
		<title>Feegow Software :: <%=session("NameUser")%></title>

		<meta name="description" content="" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		<!-- basic styles -->

		<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		<!--link rel="stylesheet" href="assets/css/animate.css" />-->

		<!--[if IE 7]>
		  <link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" />
		<![endif]-->

		<!-- page specific plugin styles -->
		<link rel="stylesheet" href="assets/css/jquery-ui-1.10.3.custom.min.css" />
		<link rel="stylesheet" href="assets/css/chosen.css" />
		<link rel="stylesheet" href="assets/css/datepicker.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-timepicker.css" />
		<link rel="stylesheet" href="assets/css/daterangepicker.css" />
		<link rel="stylesheet" href="assets/css/colorpicker.css" />
		<link rel="stylesheet" href="assets/css/jquery.gritter.css" />
		<link rel="stylesheet" href="assets/css/select2.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-editable.css" />
        <!-- fonts -->

		<link rel="stylesheet" href="assets/css/ace-fonts.css" />

		<!-- ace styles -->

		<link rel="stylesheet" href="assets/css/ace.css" />
		<link rel="stylesheet" href="assets/css/ace-rtl.min.css" />
		<link rel="stylesheet" href="assets/css/ace-skins.min.css" />

		<!--[if lte IE 8]>
		  <link rel="stylesheet" href="assets/css/ace-ie.min.css" />
		<![endif]-->

		<!-- inline styles related to this page -->
		<style>
			.spinner-preview {
				width:100px;
				height:100px;
				text-align:center;
				margin-top:60px;
			}
			
			.dropdown-preview {
				margin:0 5px;
				display:inline-block;
			}
			.dropdown-preview  > .dropdown-menu {
				display: block;
				position: static;
				margin-bottom: 5px;
			}
			.editavel {
				border:2px #f3f3f3 dashed;
			}
			.fc-widget-content:hover {
				background-color:#FFC;
			}
			.fc-widget-content {
				cursor:pointer;
			}
			.select-insert li {
				margin:0;
				padding:0;
			}
			.select-insert li {
				cursor:pointer;
				list-style-type:none;
				margin:0;
				padding:3px;
				font-size:14px;
				color:#000;
				background-color:#FFF;
			}
			.select-insert li:hover {
				background-color:#999;
			}
			.min-tabs {
				min-height:500px;
			}
			.vertical-text {
				transform: rotate(90deg);
				transform-origin: left top 0;
			}
			.ace-settings-container{
				top:145px!important;
			}
			.ace-settings-box{
				width:500px;
				border:#f00 2px solid!important;
				height:400px;
			}
			.xx{
			/*	padding:0 30px;*/
			}
            body{
                overflow-x:hidden;
            }
			</style>
            <!-- ace settings handler -->

		<script src="assets/js/ace-extra.min.js"></script>
        <!-- colocado por feegow para calendario funcionar -->
    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
    <script type="text/javascript" src="assets/js/jquery.validate.min.js"></script>
	<%if lcase(req("P"))="pacientes" then%>
	<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
	<script src="ckeditors/adapters/jquery.js"></script>
	<%else%>
	<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
	<script src="ckeditornew/adapters/jquery.js"></script>
	<%end if%>
	<script type="text/javascript" src="assets/js/qtip/jquery.qtip.js"></script>
		<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->

		<!--[if lt IE 9]>
		<script src="assets/js/html5shiv.js"></script>
		<script src="assets/js/respond.min.js"></script>
		<![endif]-->
	</head>
	<body class="animsition">
    <div id="disc" class="alert alert-danger text-center hidden" style="position:absolute; z-index:9999; width:100%"></div>
    
        <div id="modalCaixa" class="modal fade" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content" id="modalCaixaContent">
                Carregando...
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div>
		<input type="hidden" id="spinners"/>
		<!--#include file="top.asp"-->
		<div class="<%if lcase(req("P"))<>"novoquadro" and lcase(req("P"))<>"funil" and lcase(req("P"))<>"quadrodisponibilidade" and lcase(req("P"))<>"agenda-s" then%> container<%if session("Partner")<>"" then response.write("-fluid") end if%> xx<%end if%>" id="main-container">
			<script type="text/javascript">
//				document.getElementById('spinners').value='';
	//			try{ace.settings.check('main-container' , 'fixed')}catch(e){}
			</script>

			<div class="main-container-inner">
				<div class="main-content">

						<div class="row">
                            <%
	                        if session("Partner")<>"" then
                                larguraConteudo = 10
		                        %>
                                <div class="col-xs-2"><!--#include file="divPartner.asp"--></div>
                                <%
                            else
                                larguraConteudo = 12
	                        end if
	                        %>

							<div class="col-xs-<%=larguraConteudo %>">
								<!-- PAGE CONTENT BEGINS -->
								<%
								if request.QueryString("P")="" then
									response.Redirect("?P=Home&Pers=1")
								end if
								if request.QueryString("Pers")="1" then
								  FileName = request.QueryString("P")&".asp"
								else
								  FileName = "DefaultContent.asp"
								end if
								set fs=nothing
								server.Execute(FileName)
								%>
								<!-- PAGE CONTENT ENDS -->
							</div><!-- /.col -->
						</div><!-- /.row -->
					</div><!-- /.page-content -->
				</div><!-- /.main-content -->
				<div class="ace-settings-container hidden-print" id="ace-settings-container" style="position:fixed">
					<div id="ace-settings-btn" style="background-color:#fff; border:1px solid #598EA4; cursor:pointer; padding:3px; border-radius:10px 0 0 10px; border-right:none">
						<img src="assets/img/help.png" width="24">
					</div>
					<div class="ace-settings-box" id="ace-settings-box" style="margin-left:25px">
						<div>
                            <div>
                            <table class="table table-striped" border="0">
                                    <tbody>
                                    <tr><td colspan="3"><h4 class="no-margin blue">Telef&ocirc;nico <small> &raquo; seg. a sex. das 9h &agrave;s 18h</small></h4></td></tr>
                                    <tr>
                                      <td valign="top"><span class="textotel"><strong>SP</strong> 11 3136.0479<br>
                            
                            <strong>RJ</strong> 21 2018.0123 <br>
                            <strong>PR</strong> 41 2626.1434 </span><br><br></td>
                                      <td class="textotel" valign="top"> 
                            <strong>RS</strong> 51 2626.3019<br>
                            <strong>BA</strong> 71 2626.0047</td>
                                      <td valign="top" class="textotel"><strong>MG</strong> 31 2626.8010 <br>
                                        <strong>DF</strong> 61 2626.1004<br></td>
                                      </tr>
                                    <tr><td colspan="3"><h4 class="no-margin blue">Chat online <small> &raquo; seg. a sex. das 9h &agrave;s 18h</small></h4></td></tr>
                                    <tr>
                                    	<td colspan="3">
                                        Clique no bot&atilde;o abaixo, e na parte inferior da tela ser&aacute; exibida a caixa para iniciar a conversa com nossos atendentes.
                                        <a href="./?P=AtivaChat&Pers=1" class="btn btn-default btn-block btn-xs">Acessar Chat</a>
                                        </td>
                                    </tr>
                                    <tr><td colspan="3"><h4 class="no-margin blue">Manual e Downloads</h4></td></tr>
                                    <tr>
                                    	<td class="text-center"><a href="http://www.feegowclinic.com.br/wiki/index.php?title=P%C3%A1gina_principal" target="_blank">
                                        	<img width="64" src="assets/img/manual.png" border="0"><br>
                                        	Manual do Sistema</a>
                                        </td>
                                        <td class="text-center">
                                        	<a href="http://www.teamviewer.com" target="_blank">
                                            <img width="64" src="assets/img/Team_Viewer.png" border="0"><br>
                                        	Acesso Remoto</a>
                                        </td>
                                        <td class="text-center">
                                        	<a href="mailto:contato@feegowclinic.com.br">
                                            <img width="64" src="assets/img/email.png" border="0"><br>
                                        	contato@feegowclinic.com.br</a>
                                        </td>
                                    </tr>
                            </tbody></table>
                            </div>
                        </div>
					</div>
				</div><!-- /#ace-settings-container -->
			</div><!-- /.main-container-inner -->

			<a href="#" id="btn-scroll-up" class="btn-scroll-up btn btn-sm btn-inverse hidden-print">
				<i class="fa fa-double-angle-up icon-only bigger-110"></i>
			</a>
		</div>

<%
if device()<>"" then
	%>
	<div id="divDevice" style="position:fixed; height:20px; background-color:#11932C; display:none; font-weight:bold; color:#fff; top:0; z-index:1000000; left:0; width:100%">
    	
    </div>
	<%
end if

if session("OtherCurrencies")="phone" then
    %>
    <div id="calls" style="position:fixed; right:10px; bottom:10px; width:350px; border-radius:10px; background-color:#fff; border:1px solid #ccc; display:none; box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);"></div>
    <script type="text/javascript">
        function recontatar(I){
            $.get("constante.asp?Recontatar="+I, function(data){
                eval(data);
            })
        }
    </script>

    <%
end if
%>

<%if session("ChatSuporte")="S" then%>
<script src="https://feegow.tomticket.com/chat/balaofixo/EP10758/"></script>
<%end if%>


        <!-- /.main-container -->
		<!-- basic scripts -->
		<!--[if !IE]> -->
<%
response.Write("		<script type=""text/javascript"">")
response.Write("			window.jQuery || document.write(""<script src='assets/js/jquery-2.0.3.min.js'>""+""<""+""/script>"");")
response.Write("		</script>")
%>
		<!-- <![endif]-->

		<!--[if IE]>
<%
response.Write("<script type=""text/javascript"">")
response.Write(" window.jQuery || document.write(""<script src='assets/js/jquery-1.10.2.min.js'>""+""<""+""/script>"");")
response.Write("</script>")
%>
<![endif]-->

<%
response.Write("		<script type=""text/javascript"">")
response.Write("			if(""ontouchend"" in document) document.write(""<script src='assets/js/jquery.mobile.custom.min.js'>""+""<""+""/script>"");")
response.Write("		</script>")
%>
		<script src="assets/js/bootstrap.min.js"></script>
		<script src="assets/js/typeahead-bs2.min.js"></script>
		<script src="assets/js/jquery.maskMoney.js" type="text/javascript"></script>

		<!-- page specific plugin scripts -->
		<script src="assets/js/jquery-ui-1.10.3.custom.min.js"></script>
		<script src="assets/js/jquery.ui.touch-punch.min.js"></script>
		<script src="assets/js/jquery.gritter.min.js"></script>
        <script src="assets/js/jquery.slimscroll.min.js"></script>
		<script src="assets/js/jquery.hotkeys.min.js"></script>
		<script src="assets/js/bootstrap-wysiwyg.min.js"></script>
  		<script src="assets/js/select2.min.js"></script>
        <script src="assets/js/jquery.easy-pie-chart.min.js"></script>
		<script src="assets/js/jquery.sparkline.min.js"></script>
		<script src="assets/js/flot/jquery.flot.min.js"></script>
		<script src="assets/js/flot/jquery.flot.pie.min.js"></script>
		<script src="assets/js/flot/jquery.flot.resize.min.js"></script>
			<!-- table scripts -->
		<script src="assets/js/jquery.dataTables.min.js"></script>
		<script src="assets/js/bootbox.min.js"></script>
		<script src="assets/js/jquery.dataTables.bootstrap.js"></script>


		<!--[if lte IE 8]>
		  <script src="assets/js/excanvas.min.js"></script>
		<![endif]-->

		<script src="assets/js/chosen.jquery.min.js"></script>
		<script src="assets/js/fuelux/fuelux.spinner.min.js"></script>
		<script src="assets/js/date-time/bootstrap-datepicker.min.js"></script>
		<script src="assets/js/date-time/bootstrap-timepicker.min.js"></script>
		<script src="assets/js/date-time/moment.min.js"></script>
		<script src="assets/js/date-time/daterangepicker.min.js"></script>
		<script src="assets/js/bootstrap-colorpicker.min.js"></script>
		<script src="assets/js/jquery.knob.min.js"></script>
		<script src="assets/js/jquery.autosize.min.js"></script>
		<script src="assets/js/jquery.inputlimiter.1.3.1.min.js"></script>
		<script src="assets/js/jquery.maskedinput.min.js"></script>
		<script src="assets/js/bootstrap-tag.min.js"></script>
		<script src="assets/js/x-editable/bootstrap-editable.min.js"></script>
		<script src="assets/js/x-editable/ace-editable.min.js"></script>
        <script type="text/javascript" src="assets/js/bootstrap-datetimepicker.min.js"></script> 
        <script type="text/javascript" src="assets/js/bootstrap-datetimepicker.pt-BR.js"></script> 

		<!-- ace scripts -->

		<script src="assets/js/ace-elements.min.js"></script>
		<script src="assets/js/ace.min.js"></script>

		<!-- inline scripts related to this page -->
			<!-- collapse -->
		<script type="text/javascript">
			jQuery(function($) {
			
				$('#Cor').ace_colorpicker({pull_right:true}).on('change', function(){
					var color_class = $(this).find('option:selected').data('class');
					var new_class = 'widget-header';
					if(color_class != 'default')  new_class += ' header-color-'+color_class;
					$(this).closest('.widget-header').attr('class', new_class);
				});
			
			
				// scrollables
				$('.slim-scroll').each(function () {
					var $this = $(this);
					$this.slimScroll({
						height: $this.data('height') || 100,
						railVisible:true
					});
				});
			
				/**$('.widget-box').on('ace.widget.settings' , function(e) {
					e.preventDefault();
				});*/
				  
				  
			
				// Portlets (boxes)
			    $('.widget-container-span').sortable({
			        connectWith: '.widget-container-span',
					items:'> .widget-box',
					opacity:0.8,
					revert:true,
					forceHelperSize:true,
					placeholder: 'widget-placeholder',
					forcePlaceholderSize:true,
					tolerance:'pointer'
			    });
			
			});
		</script>			<!-- other inline scripts -->

	<script type="text/javascript">
	<!--#include file="jQueryFunctions.asp"-->

function Idade(Nascimento){
	$.ajax({
		type: "POST",
		url: "Idade.asp?Nascimento="+Nascimento,
		success: function( data )
		{
			$("#Idade").html(data);
		}
	});
}

function itemSubform(tbn, act, reg, cln, idc, frm){
	$.ajax({
		type: "POST",
		url: "callSubform.asp?tbn="+tbn+"&act="+act+"&reg="+reg+"&cln="+cln+"&idc="+idc+"&frm="+frm,
		data: $('#'+frm).serialize(),
		success: function( data )
		{
			$("#div"+tbn).html(data);
		}
	});
}

function ajxContent(P, I, Pers, Div){
	$.ajax({
		type: "POST",
		url: "ajxContent.asp?P="+P+"&I="+I+"&Pers="+Pers+"&q=<%=TirarAcento(req("q"))%>&Div="+Div,
		success: function( data )
		{
			//alert(data);
			$("#"+Div).html(data);
		}
	});
}
<%
if session("Atendimentos")<>"" then
	splAtendimentos = split(session("Atendimentos"), "|")
	contaAtendimentos = 0
	for z=0 to ubound(splAtendimentos)
		if splAtendimentos(z)<>"" and isnumeric(splAtendimentos(z)) then
			set atendimento = db.execute("select * from atendimentos where id="&splAtendimentos(z))
			if not atendimento.EOF then
				PacienteID = atendimento("PacienteID")
				set pac = db.execute("select NomePaciente from pacientes where id="&PacienteID)
				if not pac.eof then
					contaAtendimentos = contaAtendimentos+1
					strAtendimentos = strAtendimentos&"<a id=""agePac"&PacienteID&""" class=""btn btn-warning btn-xs btn-block"" href=""?P=Pacientes&Pers=1&I="&PacienteID&""">"&pac("NomePaciente")&"</a>"
				end if
			end if
		end if
	next
	
	if contaAtendimentos=1 and lcase(request.QueryString("P"))="pacientes" and request.QueryString("I")<>cstr(PacienteID) then
		Exibe = "S"
	elseif contaAtendimentos=1 and lcase(request.QueryString("P"))<>"pacientes" then
		Exibe = "S"
	elseif contaAtendimentos>1 then
		Exibe = "S"
	else
		Exibe = "N"
	end if

	if Exibe="S" then
	%>
	$.gritter.add({
			title: 'Atendimento<%if contaAtendimentos>1 then%>s<%end if%> em curso',
			text: '<%=strAtendimentos%>',
			image: 'assets/img/Doctor.png',
			sticky: true,
			time: '',
			class_name: 'gritter-success'
		});
	<%
	end if
end if
%>

function constante(){
	$.ajax({
		type:"POST",
		url:"constante.asp",
		success:function(data){
			eval(data);
		}
	});
}

function callSta(callID, StaID){
	$.get("callSta.asp?callID="+callID+"&StaID="+StaID, function(data){ eval(data) });
}

<%
if request.ServerVariables("REMOTE_ADDR")<>"::1" then
    if session("OtherCurrencies")="phone" then
	    %>
	    setTimeout(function(){constante()}, 1500);
	    setInterval(function(){constante()}, 7000);
	    <%
    else
	    %>
	    setTimeout(function(){constante()}, 3000);
	    setInterval(function(){constante()}, 18000);
	    <%
    End If
end if
%>


function callTalk(D, P, Da, Div){
	$.ajax({
		type:"POST",
		url:"pageCallTalk.asp?D="+D+"&P="+P+"&Da="+Da,
		success:function(data){
			$("#"+Div).html(data);
			//$("#"+Div).animate({ scrollTop: 90000 }, "slow");
			$("#"+Div).slimScroll({ scrollTo: '900000' });
		}
	});
}
function callWindow(I){
	$.ajax({
		type:"POST",
		url:"callJanelaChat.asp?ChatID="+I,
		success:function(data){
			$("#chat_"+I).html(data);
			$("#chat_"+I).css("display", "block");
			$("#body_"+I).slimScroll({ scrollTo: '900000' });
			openChat(I);
		}
	});
}
function closeChat(I){
	$("#chat_"+I).css("display", "none");
	$.ajax({
	   type:"POST",
	   url:"chatSessions.asp?T=C&I="+I,
	   success:function(data){
		   }
	});
}
function openChat(I){
	$("#chat_"+I).css("display", "block");
	$("#body_"+I).slimScroll({ scrollTo: '900000' });
	$.ajax({
	   type:"POST",
	   url:"chatSessions.asp?T=O&I="+I,
	   success:function(data){
		   }
	});
}
function chatUsers(){
	$.ajax({
		type:"POST",
		url:"chatNotificacoes.asp",
		success:function(data){
			$("#notifchat").html(data);
		}
	});
}

function notifTarefas(){
	$.ajax({
		type:"POST",
		url:"notifTarefas.asp",
		success:function(data){
			$("#divNotiftarefas").html(data);
		}
	});
}

$(document).ready(function(){
	$(".chat").submit(function(){
		$.ajax({
			type:"POST",
			url:"saveChat.asp",
			data:$(this).serialize(),
			success:function(data){
				$(".cx-mensagem").val('');
				eval(data);
			}
		});
		return false;
	});
});

function Caixa(){
	$.post("Caixa.asp", '', function(data, status){ $("#modalCaixa").modal("show"); $("#modalCaixaContent").html(data); });
}
function btb(T, ppt, Contato) {
    if(ppt==1){
        bootbox.prompt("Digite o telefone com DDD ou E-mail", function(result) {
            if (result === null) {
                //Example.show("Prompt dismissed");
            } else {
                ajxContent('GenerateCall&Contato='+Contato+'&Numero='+result, T, 1, 'calls');
            }
        });
    }else if(ppt==0){
        ajxContent('GenerateCall&Contato='+Contato+'&Numero=', T, 1, 'calls');
    }else{
        ajxContent('GenerateCall&Contato='+Contato+'&Numero='+ppt, T, 1, 'calls');
    }

}

$('[data-rel=tooltip]').tooltip();
</script>

<div style="position:fixed; width:100%; z-index:200000; bottom:0; height:25px; background-color:#903; color:#FFF; padding:3px; display:none" id="legend">
	<marquee id="legendText"></marquee>
</div>
<iframe width="250" id="speak" name="speak" height="195" scrolling="no" style="position:fixed; bottom:0; left:0; display:none" frameborder="0" src="about:blank"></iframe>

<div style="position:fixed; bottom:0; right:0; z-index:200000">
<%
splChatWindows = split(session("UsersChat"), "|")
for i=0 to ubound(splChatWindows)
	if splChatWindows(i)<>"A" and splChatWindows(i)<>"" then
		if instr(splChatWindows(i), "A") then
			chatID = replace(splChatWindows(i), "A", "")
			De = session("User")
			Para = chatID
			scrollBaixo = scrollBaixo&"$(""#body_"&chatID&""").slimScroll({ scrollTo: '900000' });"
			%>
			<div class="widget-box pull-right" id="chat_<%=chatID%>" style="height:350px; width:260px; margin:0 7px 0 7px;">
			<!--#include file="janelaChat.asp"-->
            </div>
			<%
		else
			De = session("User")
			Para = chatID
			chatID = splChatWindows(i)
			%>
			<div class="widget-box pull-right" id="chat_<%=chatID%>" style="height:350px; width:260px; margin:0 7px 0 7px; display:none;"></div>
            <%
		end if
	end if
next
%>			
</div>
			<script language="javascript">
			$(document).ready(function(){
			<%=scrollBaixo%>
			});
			</script>
            <!--#include file="speech.asp"-->
        </body>
</html>
<% Elseif request.QueryString("P")="Trial" then%>
	<!--#include file="Trial.asp"-->
<% Elseif request.QueryString("P")="Confirmacao" then%>
	<%=server.Execute("Confirmacao.asp")%>
<% Else %>
	<!--#include file="Login.asp"-->
<% End If %>