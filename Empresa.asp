<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Empresa Principal");
    $(".crumb-icon a span").attr("class", "fa fa-hospital-o");
</script>
<%
sql = "select * from empresa where id=1"
set reg = db.execute(sql)
if reg.eof then
	set licenca = dbc.execute("select * from licencas where id="&replace(session("banco"), "clinic", ""))
	if not licenca.eof then
		db_execute("insert into Empresa (id, NomeEmpresa, Tel1, Cel1, sysActive) values (1, '"&rep(licenca("NomeEmpresa"))&"', '"&rep(licenca("Telefone"))&"', '"&rep(licenca("Celular"))&"', 1)")
		set reg = db.execute(sql)
	end if
else
	db_execute("update empresa set sysActive=1")
end if

%>

<br />
<div class="panel">
    <div class="panel-body">
        <form method="post" id="frmEmpresa" name="frmEmpresa" action="save.asp">
            <input type="hidden" name="I" value="1" />
            <input type="hidden" name="P" value="empresa" />
            <%
		if aut("sys_financialcompanyunitsA")=1 then
            %>
            <script type="text/javascript">
                $("#rbtns").html('<button type="button" onclick="$(\'#save\').click()" class="btn btn-sm btn-primary"><i class="fa fa-save"></i><span class="menu-text"> Salvar</span></button>');
            </script>
            <button class="btn btn-primary hidden" id="save">
                <i class="fa fa-save"></i>Salvar
            </button>
            <%
		end if
            %>
            <div class="row">
                <%=quickField("text", "NomeEmpresa", "Razão Social", 4, reg("NomeEmpresa"), "", "", " required")%>
                <%=quickField("text", "NomeFantasia", "Nome Fantasia", 3, reg("NomeFantasia"), "", "", " required")%>
                <%= quickField("text", "CNPJ", "CNPJ", 3, reg("CNPJ"), " input-mask-cnpj", "", "") %>
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
            <div class="row">
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
        </form>
    </div>
</div>

<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frmEmpresa", "save", "")%>
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