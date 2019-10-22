<!--#include file="connect.asp"-->
<%
call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("select * from pacotes where id="&request.QueryString("I"))
%>

<br>
<div class="panel">
<div class="panel-body">


            <form method="post" id="frm" name="frm" action="save.asp">
	<%=header(req("P"), "Cadastro de Pacote", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
                <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
                <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />

                <div class="row">
                    <%=quickField("text", "NomePacote", "Nome do Pacote", 6, reg("NomePacote"), "", "", " required")%>
                    <br>
                    <%=quickField("simpleCheckbox", "ExibirValorRecibo", "Não exibir valor no recibo", 4, reg("ExibirValorRecibo"), "", "", " required")%>

                    <div class="col-md-offset-1 col-md-1">
                        <label>
                            Ativo
                            <br />
                            <div class="switch round">
                                <input type="checkbox" <% If reg("Ativo")="on" Then %> checked="checked"<%end if%> name="Ativo" id="Ativo">
                                <label for="Ativo">Label</label>
                            </div>

                        </label>
                    </div>
                </div>
                <br>
                <div class="row">
                    <div class="col-md-offset-2 col-md-8">
                        <%call Subform("pacotesitens", "PacoteID", request.QueryString("I"), "frm")%>
                    </div>
                </div>
            </form>
            </div>
            </div>
<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});
</script>

<script src="../assets/js/ace-elements.min.js"></script>
<script type="text/javascript">
//js exclusivo avatar
<%
Parametros = "P="&request.QueryString("P")&"&I="&request.QueryString("I")&"&Col=Foto"
%>

function tissCompletaDados(T, I, N){
	$.post("tissCompletaDados.asp?I="+I+"&T="+T,{
		   ConvenioID:"<%=request.QueryString("I")%>",
		   Numero:N,
		   },function(data,status){
	  eval(data);
	});
}
</script>
<!--#include file="disconnect.asp"-->