<!--#include file="connect.asp"-->
<%
call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("select * from "&request.QueryString("P")&" where id="&request.QueryString("I"))
%>
<script type="text/javascript">
    $(".crumb-active a").html("Cadastro de Unidade / Filial");
    $(".crumb-icon a span").attr("class", "fa fa-hospital-o");
</script>


<br>

<div class="panel">
<div class="panel-body">
            <form method="post" id="frm" name="frm" action="save.asp">
                <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
                <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />
                <div class="row">
                    <div class="col-md-10">
                    </div>
                    <div class="col-md-2">
        <%
		if (reg("sysActive")=1 and aut(lcase(request.QueryString("P"))&"A")=1) or (reg("sysActive")=0 and aut(lcase(request.QueryString("P"))&"I")=1) then
		%>
                        <button class="btn btn-block btn-primary" id="save">
                            <i class="fa fa-save"></i> Salvar
                        </button>
		<%
		end if
		%>
                    </div>
                </div>
                <hr />
            <div class="row">
                <div class="col-md-12">
                    <div class="row">
                        <%=quickField("text", "UnitName", "Razão Social #" & req("I"), 4, reg("UnitName"), "", "", " required")%>
                        <%=quickField("text", "NomeFantasia", "Nome Fantasia", 4, reg("NomeFantasia"), "", "", " required")%>
                        <%= quickField("text", "CNPJ", "CNPJ", 2, reg("CNPJ"), " input-mask-cnpj", "", "") %>
                        <%= quickField("text", "CNES", "CNES", 2, reg("CNES"), "", "", "") %>
                    </div>
                    <div class="row">
                    </div>
                    <hr />
                    <div class="row">
                        <%= quickField("text", "Cep", "Cep", 3, reg("cep"), "input-mask-cep", "", "") %>
                        <%= quickField("text", "Endereco", "Endere&ccedil;o", 5, reg("endereco"), "", "", "") %>
                        <%= quickField("text", "Numero", "N&uacute;mero", 2, reg("numero"), "", "", "") %>
                        <%= quickField("text", "Complemento", "Compl.", 2, reg("complemento"), "", "", "") %>
                    </div>
                    <div class="row">
                        <%= quickField("text", "Bairro", "Bairro", 4, reg("bairro"), "", "", "") %>
                        <%= quickField("text", "Cidade", "Cidade", 4, reg("cidade"), "", "", "") %>
                        <%= quickField("text", "Regiao", "Região / Zona", 2, reg("Regiao"), "", "", "") %>
                        <%= quickField("text", "Estado", "Estado", 2, reg("estado"), "", "", " maxlength=2 ") %>
                    </div>
                    <div class="row">
                        <%= quickField("phone", "Tel1", "Telefone", 4, reg("tel1"), "", "", "") %>
                        <%= quickField("mobile", "Cel1", "Celular", 4, reg("cel1"), "", "", "") %>
                        <%= quickField("email", "Email1", "E-mail", 4, reg("email1"), "", "", "") %>
                        <%= quickField("phone", "Tel2", "&nbsp;", 4, reg("tel2"), "", "", "") %>
                        <%= quickField("mobile", "Cel2", "&nbsp;", 4, reg("cel2"), "", "", "") %>
                        <%= quickField("email", "Email2", "&nbsp;", 4, reg("email2"), "", "", "") %>
                    </div>
                    <div class="row ">
                        <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 4, reg("Obs"), "", "", "") %>
                        <%= quickField("text", "Sigla", "Sigla", 2, reg("Sigla"), "", "", "") %>
                        <%= quickField("simpleSelect", "FusoHorario", "Fuso Horário", 3, reg("FusoHorario"), "SELECT * FROM cliniccentral.fuso_horarios", "Local", "") %>
                        <br>
                        <%=quickField("simpleCheckbox", "HorarioVerao", "Aplicar Horário de Verão", "3", reg("HorarioVerao"), "", "", "")%>
                    </div>
                    <div class="row">
                        <%= quickField("text", "Coordenadas", "Link das Coordenadas", 4, reg("Coordenadas"), "", "", "") %>
                        <%= quickField("text", "DDDAuto", "DDD automático", 2, reg("DDDAuto"), "", "", " maxlength='2'") %>
                        <div class="col-md-6">
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" class="ace 1" name="ExibirAgendamentoOnline" id="ExibirAgendamentoOnline" value="1" <% if reg("ExibirAgendamentoOnline")=1 then %>checked<%end if%>>
                                <label class="checkbox" for="ExibirAgendamentoOnline"> Exibir no agendamento online</label>
                            </div>
                        </div>
                    </div>
                    </div>
                </div>
            </form>
            </div>
            </div>
<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
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
				$("#Numero").focus();
			}else{
				$("#Endereco").focus();
			}
		});				
	}			
}


</script>
<!--#include file="disconnect.asp"-->