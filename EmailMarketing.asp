<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<br>
<div class="panel">
<div class="panel-body">

    <div class="page-header">
        <h1>Envio de E-mail Marketing</h1>
    </div>

<div class="alert alert-warning">
    <strong>Atenção!</strong> Esta mala direta não está mais habilitada. <a target="_blank" id="redirect-to" href="#">Clique aqui</a> para utilizar a nova ferramenta.
</div>
<script >
function getComponentUrl(url){
	var tk = localStorage.getItem("tk");

	return domain + url +	"?tk="+tk
}
$(document).ready(function() {
    $("#redirect-to").attr("href", getComponentUrl('reports/r/patients-by-profile'))
});
</script>
<%
Response.End
response.Charset="utf-8"

Emails = ref("Email")

spl = split(Emails, ", ")

if ref("Enviar")="" then
%>
    
    <form method="post" action="">
    
            
            
            <div class="row">
                <div class="col-md-6">
                    <div class="row">
                        <div class="col-md-12" style="height:430px; overflow-x:hidden; overflow-y:scroll">
                            <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th width="1%"></th>
                                    <th>DESTINATÁRIOS</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                            for i=0 to ubound(spl)
                                %>
                                <tr>
                                    <td><label><input class="ace" checked type="checkbox" name="Email" value="<%=spl(i)%>"><span class="lbl"></span></label></td>
                                    <td><%=spl(i)%></td>
                                </tr>
                                <%
                            next
                            %>
                            </tbody>
                            </table>
                            
                        </div>
                        <div class="clearfix navbar-form text-center">
            ATENÇÃO: Será cobrada em sua próxima fatura a quantia de R$ 0,01 (um centavo) por cada e-mail enviado.
<hr>
                            <button class="btn btn-primary"><i class="far fa-send"></i> ENVIAR</button>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="row">
                            <%=quickField("text", "NomeRemetente", "Nome do Remetente", 12, "", "", "", " placeholder='Digite seu nome ou o nome da clínica' required")%>
                            <%=quickField("text", "EmailRemetente", "E-mail do Remetente", 12, "", "", "", " placeholder='Digite seu e-mail ou o e-mail da clínica' required")%>
                            <%=quickField("text", "Assunto", "Assunto", 12, "", "", "", " placeholder='Digite o assunto da mensagem' required")%>
                            <%=quickField("editor", "Mensagem", "Mensagem", 12, "", "300", "", "")%>
                        </div>
                    </div>
                </div>
            </div>
        <input type="hidden" name="Enviar" value="Enviar">
	</form>
<script >
    $(".crumb-active a").html("E-mail marketing");
    $(".crumb-icon a span").attr("class", "far fa-envelope");
    $(".crumb-icon a span").removeClass("hidden");
</script>
	<%
else
	Email = ref("Email")
	
	spl = split(Email, ", ")
	conta = 0
	for i=0 to ubound(spl)
		conta = conta+1
		dbc.execute("insert into cliniccentral.emailmarketing (LicencaID, UserID, Assunto, NomeRemetente, EmailRemetente, Para, Mensagem) values ("&replace(session("banco"), "clinic", "")&", "&session("User")&", '"&ref("Assunto")&"', '"&ref("NomeRemetente")&"', '"&ref("EmailRemetente")&"', '"&spl(i)&"', '"&ref("Mensagem")&"')")
	next

	if 0 then
	%>
	<h4>Ocorreu um erro ao enviar os e-mails. Tente novamente mais tarde.</h4>
	<%
	else
	%>
    <h4>E-mails enviado para fila de envio.</h4>
    <%
	end if
end if
%>
</div>
</div>