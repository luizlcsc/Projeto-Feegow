<!--#include file="connect.asp"-->
<%
call insertRedir(request.QueryString("P"), request.QueryString("I"))

sql = "select * from sys_smsemail WHERE id="&req("I")
set reg = db.execute(sql)
if reg.eof then
    txtPadrao = "[NomePaciente], não se esqueça de sua consulta com [NomeProfissional] às [HoraAgendamento] do dia [DataAgendamento]."
    db_execute("insert into sys_smsemail (AtivoEmail, TextoEmail, ConfirmarPorEmail, TempoAntesEmail, AtivoSMS, TextoSMS, ConfirmarPorSMS, TempoAntesSMS, HAntesEmail, HAntesSMS) values ('on', '"&txtPadrao&"', 'S', '02:00:00', 'on', '"&txtPadrao&"', 'S', '02:00:00', 24, 24)")
    set reg = db.execute(sql)
end if

%>
<%=header(req("P"), "Configuração de E-mail e SMS", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
<%

if ref("E")="E" then
    db_execute("update sys_smsemail set InviteEmail='"&ref("InviteEmail")&"' , AtivoEmail='"&ref("AtivoEmail")&"', TextoEmail='"&ref("TextoEmail")&"', ConfirmarPorEmail='"&ref("ConfirmarPorEmail")&"', TempoAntesEmail='"&ref("TempoAntesEmail")&"', AtivoSMS='"&ref("AtivoSMS")&"', TextoSMS='"&ref("TextoSMS")&"', ConfirmarPorSMS='"&ref("ConfirmarPorSMS")&"', TempoAntesSMS='"&ref("TempoAntesSMS")&"', HAntesEmail="&treatvalzero(ref("HAntesEmail"))&", HAntesSMS="&treatvalzero(ref("HAntesSMS"))&", LinkRemarcacao='"&ref("LinkRemarcacao")&"'")
else
%>
<br />

<form method="post" id="frm" name="frm" action="save.asp">
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />
<div class="row">

    <div class="col-md-12">
        <div class="panel">
            <div class="panel-body">
                <%=quickField("text", "Descricao", "Descrição do modelo", 4, reg("Descricao"), 200, "", "")%>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-6">
        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">Enviar e-mail
                </span>
                <span class="panel-controls">
                    <div title="Ativar / Desativar" class='mn'>
                        <div class='switch switch-info switch-inline'>
                            <input<% If reg("AtivoEmail")="on" Then %> checked="checked" <%end if%> name="AtivoEmail" id="AtivoEmail" type="checkbox" value="on"/>
                            <label class="mn" for="AtivoEmail"></label>
                        </div>
                    </div>
                </span>
            </div>
            <div class="panel-body">
                <div class="row">
                    <%=quickField("text", "TituloEmail", "Titulo do e-mail", 6, reg("TituloEmail"), "", "", "")%>
                    <%=quickField("simpleCheckbox", "InviteEmail", "Enviar invite por e-mail", 4, reg("InviteEmail"), "", "", "")%>

                    <%=quickField("editor", "TextoEmail", "Texto do e-mail", 12, reg("TextoEmail"), 200, "", "")%>
                </div>
                <hr class="short alt" />
                <div class="row">
                    <div class="col-md-6 mt20">
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
                    Enviar SMS &raquo; <small><span class="badge badge-pink">R$ 0,12</span> por SMS enviado</small>
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
                    <%=quickField("memo", "TextoSMS", "Texto do SMS (m&aacute;x. 155 caracteres)", 12, reg("TextoSMS"), " limited", "", " rows='8' maxlength='140'")%>
                </div>
                <hr class="short alt">
                <div class="row">
                    <div class="col-md-12 mt20">
                        <div class="checkbox-custom checkbox-primary">
                            <input type="checkbox" class="ace" name="ConfirmarPorSMS" id="ConfirmarPorSMS" value="S" <% If reg("ConfirmarPorSMS")="S" Then %> checked<% End If %>><label for="ConfirmarPorSMS"> Enviar link de confirma&ccedil;&atilde;o</label></div>
                    </div>
                    <div class="col-md-12 mt20 hidden">
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
$(document).ready(function(e) {
    <%call formSave("frm", "save", "")%>

    $("#Salvar").click(function() {
      $("#frm").submit();
    })
});

<!--#include file="jQueryFunctions.asp"-->
</script>
<%end if%>
<!--#include file="disconnect.asp"-->
