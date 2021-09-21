<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
'response.Write( dataGoogle("10/03/2012", "15:00") )

set pro = db.execute("select * from profissionais where id="&req("I"))
%>
<form method="post" id="frmIntegracao" name="frmIntegracao" action="">
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">
            <i class="far fa-calendar"></i> Integração da Agenda de <%=Nome%> com o Google Calendar
        </span>
        <span class="panel-controls">
            <button id="btnSalvarIntegracao" type="submit" class="btn btn-sm btn-primary"> <i class="far fa-key"></i> Salvar </button>
        </span>
    </div>
    <div id="login-box" class="panel-body">
        <div class="widget-body">
            <div class="admin-form">

                <div class="space-6"></div>
				<label><input type="checkbox" name="Integrar" id="Integrar" value="S" class="ace"<% If pro("GoogleCalendar")<>"" Then %> checked<% End If %>> <span class="lbl"> Integrar esta agenda ao Google Calendar.</span></label>
                <input type="hidden" name="E" value="E">
                    <fieldset id="divGC" <%if pro("GoogleCalendar")="" then%> class="hidden"<%end if%>><br><br>

                            E-mail da conta Google<br>
                            <label class="field prepend-icon">
                                <input type="email" class="form-control" name="GoogleCalendar" id="GoogleCalendar" required placeholder="E-mail do Google Calendar" value="<%= pro("GoogleCalendar") %>" autofocus />
                                <label for="GoogleCalendar" class="field-icon">
                                    <i class="far fa-user"></i>
                                </label>
                            </label>
                        <div class="space"></div>

                        <div class="clearfix">
                        </div>

                        <div class="space-4"></div>
                    </fieldset>

            </div><!-- /widget-main -->

            <div class="clearfix form-actions">
                <div class="col-xs-12">
                     <span id="msg"><%=msg%></span>
                </div>
            </div>
        </div><!-- /widget-body -->
    </div><!-- /login-box -->
</div>
</form>
<script language="javascript">
$("#Integrar").click(function(){
	if($(this).prop("checked")==true){
		$("#divGC").removeClass("hidden");
	}else{
		$("#divGC").addClass("hidden");
	}
});

$("#frmIntegracao").submit(function(){
    $("#btnSalvarIntegracao").attr("disabled", true);
	$.ajax({
		type:"POST",
		url:"saveIntegracaoAgenda.asp?ProfissionalID=<%=req("I")%>",
		data:$(this).serialize(),
		success:function(data){
			eval(data);
			$("#btnSalvarIntegracao").attr("disabled", false);
		}
	});
	return false;
});
</script>