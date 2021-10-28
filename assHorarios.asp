<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->

<%

function getNomeEspecialidades(stringIDs)
	newStringIds = replace(stringIDs&"","|","")
	getNomeEspecialidades =""

	if newStringIds <> "" then
		set esp = db.execute("select group_concat(especialidade separator ', ' ) as esp from especialidades where id in("&newStringIds&")")
		if not esp.eof then
			getNomeEspecialidades = esp("esp")
		end if 
	end if 
end function

function getNomeProcedimentos(stringIDs)
	newStringIds = replace(stringIDs&"","|","")
	getNomeProcedimentos =""

	if newStringIds <> "" then
		set procs = db.execute("select group_concat( nomeprocedimento separator ', ' ) procs from procedimentos where id in("&newStringIds&")")
		if not procs.eof then
			getNomeProcedimentos = procs("procs")
		end if 
	end if 
end function

function getNomeConvenios(stringIDs)
	newStringIds = replace(stringIDs&"","|","")
	getNomeConvenios =""

	if instr(newStringIds,"N")>0 then

		if newStringIds <> "" then
			set convs = db.execute("select group_concat( nomeconvenio separator ', ' ) convs from convenios where id in("&newStringIds&")")
			if not convs.eof then
				getNomeConvenios = convs("convs")
			end if 
		end if 
		
	end if
end function


if req("X")<>"" then
    sqlDel = "delete from assPeriodoLocalXProfissional where id = '"&req("X")&"'"
    call gravaLogs(sqlDel, "AUTO", "", "ProfissionalID")
	db_execute(sqlDel)
end if
%>
<!DOCTYPE html>
<html>
	<head>
		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<meta charset="utf-8" />
		<title>Feegow Software :: <%=session("NameUser")%></title>

		<meta name="description" content="" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		<!-- basic styles -->

		<!--link rel="stylesheet" href="assets/css/animate.css" />-->

		<!--[if IE 7]>
		  <link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" />
		<![endif]-->

		<!-- page specific plugin styles -->
  <link rel="stylesheet" type="text/css" href="assets/fonts/icomoon/icomoon.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/magnific/magnific-popup.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/footable/css/footable.core.min.css">
  <link rel='stylesheet' type='text/css' href='assets/css/css.css'>
  <link rel="stylesheet" type="text/css" href="vendor/plugins/fullcalendar/fullcalendar.min.css">
  <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/theme.css">
  <link rel="stylesheet" type="text/css" href="assets/admin-tools/admin-forms/css/admin-forms.css">
  <link rel="shortcut icon" href="assets/img/feegowclinic.ico" type="image/x-icon" />
  <link href="vendor/plugins/select2/css/core.css" rel="stylesheet" type="text/css"> 
  <link href="vendor/plugins/select2/select2-bootstrap.css" rel="stylesheet" type="text/css"> 
  <link rel="stylesheet" href="assets/css/old.css" />
  <link rel="stylesheet" type="text/css" href="vendor/plugins/ladda/ladda.min.css">
        <!-- fonts -->


		<!-- ace styles -->

		<!--[if lte IE 8]>
		  <link rel="stylesheet" href="assets/css/ace-ie.min.css" />
		<![endif]-->

		<!-- inline styles related to this page -->
		<style type="text/css">
            body{
                background-color:#fff!important;
            }
			</style>
            <!-- ace settings handler -->

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!--[if lt IE 9]>
  <script src="assets/js/html5shiv.js"></script>
  <script src="assets/js/respond.min.js"></script>
<![endif]-->
  <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
  <script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
  <script src="vendor/plugins/select2/select2.min.js"></script> 
  <script src="vendor/plugins/select2/select2.full.min.js"></script> 
  <script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
  <script src="ckeditors/adapters/jquery.js"></script>
  <script src="vendor/plugins/footable/js/footable.all.min.js"></script>
	</head>

<body>
    			<div class="">
				<div class="">


<%

DataDe=date()
DataA=date()
HoraDe="08:00"
HoraA="17:00"
Intervalo = 30
if req("LocalID")<>"" then
	LocalID = ccur(req("LocalID"))
	sqlWhere = " and LocalID="&LocalID
end if
if req("ProfissionalID")<>"" then
	ProfissionalID = ccur(req("ProfissionalID"))
	sqlWhere = " and ProfissionalID="&ProfissionalID
else
    ProfissionalID=0
end if
if ref("h")="h" then
	DataDe=ref("DataDe")
	DataA=ref("DataA")
	HoraDe=ref("HoraDe")
	HoraA=ref("HoraA")
	LocalID=ref("LocalID")
	Procedimentos=ref("Procedimentos")&""
	Especialidades=ref("Especialidades")&""
	Convenios=ref("Convenios")&""

	Intervalo = ref("Intervalo")
	Compartilhar = ref("Compartilhada")
    if ref("ProfissionalID")<>"" and ref("ProfissionalID")<>"0" then
        ProfissionalID = ref("ProfissionalID")
    end if

	if not isdate(DataDe) or not isdate(DataA) or not isdate(HoraDe) or not isdate(HoraA) then
		erro="Preencha as datas e horários com valores válidos."
	else
		if cdate(HoraDe)>=cdate(HoraA) then
			erro="O horário inicial deve ser menor que o horário final."
		end if
		if cdate(DataDe)>cdate(DataA) then
			erro="A data inicial deve ser menor ou igual &agrave; data final."
		end if
	end if
	if erro="" then

	    sqlInsert = "insert into assPeriodoLocalXProfissional (DataDe,DataA,HoraDe,HoraA,ProfissionalID,LocalID, Intervalo, Compartilhar, Procedimentos, Especialidades,Convenios) values ("&mydatenull(DataDe)&","&mydatenull(DataA)&",'"&HoraDe&"','"&HoraA&"', "&treatvalzero(ProfissionalID)&", "&treatvalzero(LocalID)&", '"&Intervalo&"','"&Compartilhar&"', '"&Procedimentos&"', '"&Especialidades&"','"&Convenios&"')"
		db_execute(sqlInsert)

	    call gravaLogs(sqlInsert, "AUTO", "", "ProfissionalID")

	end if
end if
%>
                    
<center><font color="#FF0000"><strong><%=erro%></strong></font></center>

    



<table width="868" align="center" class="table table-striped table-bordered table-hover table-condensed">
<tbody>

<%
set pass=db.execute("select h.*, l.NomeLocal, l.UnidadeID, p.NomeProfissional from assPeriodoLocalXProfissional h left join profissionais p on p.id=h.ProfissionalID left join locais l on l.id=h.LocalID where not isnull(h.DataDe) and not isnull(h.DataA) and not isnull(h.HoraDe) and not isnull(h.HoraA) "& sqlWhere &" order by h.DataDe desc, h.DataA desc")
while not pass.EOF
%>
<tr>
	<td class="text-center"><%=pass("DataDe")%></td>
    <td class="text-center"><%=pass("DataA")%></td>
    <td class="text-center"><%=formatdatetime(pass("HoraDe"),4)%></td>
    <td class="text-center"><%=formatdatetime(pass("HoraA"),4)%></td>
    <td class="text-center"><%=pass("Intervalo")%></td>
    <td><%=pass("NomeProfissional")%></td>
    <td><%=pass("NomeLocal")%> <%=getNomeLocalUnidade(pass("UnidadeID"))%></td>
    <td class="text-center"><%=getNomeProcedimentos(pass("Procedimentos"))%></td>
    <td class="text-center"><%=getNomeEspecialidades(pass("Especialidades"))%></td>
    <td class="text-center"><%=getNomeConvenios(pass("Convenios"))%></td>
    <td class="text-center"><%=pass("Compartilhar")%></td>
	<td width="1%">
	    <%
	    if aut("|horariosX|") then
	    %>
	    <button type="button" value="Excluir" onClick="location.href='?X=<%=pass("id")%>&ProfissionalID=<%=req("ProfissionalID")%>&LocalID=<%=req("LocalID")%>';" style="font-size:10px" class="btn btn-sm btn-danger"><i class="far fa-remove"></i> </button>
	    <%
	    end if
	    %>
    </td>
</tr>
<%
pass.moveNext
wend
pass.close
set pass=nothing
%>
</tbody>
</table>

</div>
                    </div>
    

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
		url: "ajxContent.asp?P="+P+"&I="+I+"&Pers="+Pers+"&q=<%=req("q")%>&Div="+Div,
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
	
	if contaAtendimentos=1 and lcase(req("P"))="pacientes" and req("I")<>cstr(PacienteID) then
		Exibe = "S"
	elseif contaAtendimentos=1 and lcase(req("P"))<>"pacientes" then
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
function btb(T) {
    bootbox.prompt("Digite o telefone com DDD ou E-mail", function(result) {
        if (result === null) {
            //Example.show("Prompt dismissed");
        } else {
            ajxContent('GenerateCall&Numero='+result, T, 1, 'calls');
        }
    });
}
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

    </body>
    </html>