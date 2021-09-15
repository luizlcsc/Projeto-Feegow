<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Configuração de E-mail e SMS");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("confirmação automática de agendamentos");
    $(".crumb-icon a span").attr("class", "far fa-<%=dIcone(lcase("configconfirmacoes"))%>");
    <%
    'if aut("lancamentosI")=1 then
    %>
    $("#rbtns").html('<button type="button" onClick="salvarConfig();" class="btn btn-sm btn-primary">&nbsp;&nbsp;<i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>');
    <%
    'end if
    %>
</script>

<script src="assets/js/date-time/bootstrap-timepicker.min.js"></script>
<%
sql = "select * from sys_smsemail"
set reg = db.execute(sql)
if reg.eof then
	txtPadrao = "[NomePaciente], não se esqueça de sua consulta com [NomeProfissional] às [HoraAgendamento] do dia [DataAgendamento]."
	db_execute("insert into sys_smsemail (AtivoEmail, TextoEmail, ConfirmarPorEmail, TempoAntesEmail, AtivoSMS, TextoSMS, ConfirmarPorSMS, TempoAntesSMS, HAntesEmail, HAntesSMS) values ('on', '"&txtPadrao&"', 'S', '02:00:00', 'on', '"&txtPadrao&"', 'S', '02:00:00', 24, 24)")
	set reg = db.execute(sql)
end if

if ref("E")="E" then
	db_execute("update sys_smsemail set AtivoEmail='"&ref("AtivoEmail")&"', TextoEmail='"&ref("TextoEmail")&"', ConfirmarPorEmail='"&ref("ConfirmarPorEmail")&"', TempoAntesEmail='"&ref("TempoAntesEmail")&"', AtivoSMS='"&ref("AtivoSMS")&"', TextoSMS='"&ref("TextoSMS")&"', ConfirmarPorSMS='"&ref("ConfirmarPorSMS")&"', TempoAntesSMS='"&ref("TempoAntesSMS")&"', HAntesEmail="&treatvalzero(ref("HAntesEmail"))&", HAntesSMS="&treatvalzero(ref("HAntesSMS"))&", LinkRemarcacao='"&ref("LinkRemarcacao")&"'")
else
%>
<br />
<form method="post" id="frm" name="frm" action="ConfigConfirmacoes.asp">
    <input type="hidden" name="E" value="E">
<div class="row">
    <div class="col-md-6">
        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">Confirma&ccedil;&atilde;o via e-mail
                </span>
                <span class="panel-controls">
                    <div title="Ativar / Desativar" class='mn'>
                        <div class='switch switch-info switch-inline'>
                            <input<% If reg("AtivoEmail")="on" Then %> checked="checked" <%end if%> name="AtivoEmail" id="AtivoEmail" type="checkbox" />
                            <label class="mn" for="AtivoEmail"></label>
                        </div>
                    </div>
                </span>
            </div>
            <div class="panel-body">
                <div class="row">
                    <%=quickField("editor", "TextoEmail", "Texto do e-mail", 12, reg("TextoEmail"), 200, "", "")%><hr>
                </div>
                <hr class="short alt" />
                <div class="row">
                    <%=quickField("number", "HAntesEmail", "Quantas horas antes do agendamento o e-mail deve ser enviado?", 12, reg("HAntesEmail"), "", "", "")%>
                    <div class="col-md-12 mt20">
                        <div class="checkbox-custom checkbox-primary">
                            <input type="checkbox" name="ConfirmarPorEmail" id="ConfirmarPorEmail" value="S" <% If reg("ConfirmarPorEmail")="S" Then %> checked <% End If %>><label for="ConfirmarPorEmail"> Enviar link de confirma&ccedil;&atilde;o</label></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">
                    Confirma&ccedil;&atilde;o via SMS &raquo; <small><span class="badge badge-pink">R$ 0,08</span> por SMS enviado</small>
                </span>
                <span class="panel-controls">
                    <div title="Ativar / Desativar" class='mn'>
                        <div class='switch switch-info switch-inline'>
                            <input <% If reg("AtivoSMS")="on" Then %> checked="checked" <%end if%> name="AtivoSMS" id="AtivoSMS" type="checkbox" />
                            <label class="mn" for="AtivoSMS"></label>
                        </div>
                    </div>
                </span>
            </div>
            <div class="panel-body">
                <div class="row">
                    <%=quickField("memo", "TextoSMS", "Texto do SMS (m&aacute;x. 155 caracteres)", 12, reg("TextoSMS"), " limited", "", " rows='6' maxlength='140'")%>
                </div>
                <hr class="short alt">
                <div class="row">
                    <%=quickField("number", "HAntesSMS", "Quantas horas antes do agendamento a mensagem deve ser enviada?", 12, reg("HAntesSMS"), "", "", "")%>
                    
                    <div class="col-md-12 mt20">
                        <div class="checkbox-custom checkbox-primary">
                            <input type="checkbox" class="ace" name="ConfirmarPorSMS" id="ConfirmarPorSMS" value="S" <% If reg("ConfirmarPorSMS")="S" Then %> checked<% End If %>><label for="ConfirmarPorSMS"> Enviar link de confirma&ccedil;&atilde;o</label></div>
                    </div>
                    <div class="col-md-12 mt20">
                        <div class="checkbox-custom checkbox-primary">
                            <input type="checkbox" class="ace" name="LinkRemarcacao" id="LinkRemarcacao" value="S" <% If reg("LinkRemarcacao")="S" Then %> checked<% End If %>><label for="LinkRemarcacao"> Enviar link de remarcação em cancelamento</label></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</form>
<script type="text/javascript">
function salvarConfig(){
	$.ajax({
		   type:"POST",
		   url:"ConfigConfirmacoes.asp",
		   data:$("#frm").serialize(),
		   success:function(data){
		       new PNotify({
		           title: 'Salvo com sucesso',
		           text:'',
		           type:'success',
                   delay:500
		       });
		   }
	});
}

<!--#include file="jQueryFunctions.asp"-->
</script>
<%end if%>
<!--#include file="disconnect.asp"-->