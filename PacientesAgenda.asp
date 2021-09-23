<%
set reg = db.execute("select * from Pacientes where id="&req("I"))
%>
<input type="hidden" name="DadosAlterados" id="DadosAlterados" value="" />
<form method="post" id="frm" name="frm" action="save.asp">
	<input type="hidden" name="I" value="<%=req("I")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />
    <div class="row">
        <div class="col-md-8">
           <a href="./?P=Pacientes&I=<%=req("I")%>&Pers=1" class="btn"><i class="far fa-external-link"></i> Ir para ficha completa</a>
        </div>
        <div class="col-md-2">
			<%
			if getConfig("AlterarNumeroProntuario") = 1 then
			'if session("banco")="clinic1612" or session("banco")="clinic5868" or session("banco")="clinic105" or session("banco")="clinic3859" or session("banco")="clinic5491" then
				Prontuario = reg("idImportado")
				if isnull(Prontuario) then
					set pultPront = db.execute("select idImportado Prontuario from pacientes where not isnull(idImportado) order by idImportado desc limit 1")
					if pultPront.eof then
						Prontuario = 1
					else
						Prontuario = pultPront("Prontuario")+1
					end if
				end if
				%>
	            <input type="text" name="Prontuario" id="Prontuario" class="form-control text-right" value="<%=Prontuario%>" />
			<% Else %>
    	        <input type="text" class="form-control text-right" value="<%=reg("id")%>" disabled="disabled" />
			<% End If%>
        </div>
        <div class="col-md-2">
        <%
		if (reg("sysActive")=1 and aut("pacientesA")=1) or (reg("sysActive")=0 and aut("pacientesI")=1) then
		%>
            <button class="btn btn-block btn-primary" id="save">
                <i class="far fa-save"></i> Salvar
            </button>
        <%
		end if
		%>
        </div>
    </div>
    <hr />
<%
if reg("Foto")="" or isnull(reg("Foto")) then
	divDisplayUploadFoto = "block"
	divDisplayFoto = "none"
else
	divDisplayUploadFoto = "none"
	divDisplayFoto = "block"
end if
%>
<div class="clearfix form-actions no-margin">
	<div class="col-md-2" id="divAvatar">
            <div id="camera" class="camera"></div>  
            <div id="divDisplayUploadFoto" style="display:<%=divDisplayUploadFoto%>">
                <input type="file" name="Foto" id="Foto" />
                <button type="button" id="clicar" class="btn btn-block btn-xs btn-info"><i class="far fa-camera"></i></button>
            </div>
            <div id="divDisplayFoto" style="display:<%= divDisplayFoto %>">
	            <img id="avatarFoto" src="uploads/<%=reg("Foto")%>" class="img-thumbnail" width="100%" />
                <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="far fa-trash"></i></button>
            </div>
            <div class="row"><div class="col-xs-6">
	            <button type="button" class="btn btn-xs btn-success btn-block" style="display:none" id="take-photo"><i class="far fa-check"></i></button>
            </div><div class="col-xs-6">
	            <button type="button" style="display:none" id="cancelar" onclick="return cancelar();" class="btn btn-block btn-xs btn-danger"><i class="far fa-remove"></i></button>
            </div></div>
    </div>
    <div class="col-md-10">
        <div class="row">
            <%=quickField("text", "NomePaciente", "Nome", 6, reg("NomePaciente"), "", "", " required")%>
            <%=quickField("datepicker", "Nascimento", "Nascimento", 2, reg("Nascimento"), "input-mask-date", "", "")%>
            <div class="col-md-4"><label>&nbsp;</label><br />
            	<span class="btn btn-default btn-sm default-cursor btn-block blue" id="Idade" style="cursor:default"><%=Idade(reg("Nascimento"))%></span>
            </div>
        </div>
        <div class="row">
            <%=quickField("simpleSelect", "Sexo", "Sexo", 4, reg("Sexo"), "select * from Sexo where sysActive=1", "NomeSexo", "")%>
            <%=quickField("simpleSelect", "CorPele", "Cor da Pele", 4, reg("CorPele"), "select * from CorPele where sysActive=1", "NomeCorPele", "")%>
			<%= quickField("text", "Altura", "Altura", 2, reg("Altura"), " input-mask-brl text-right", "", "") %>
            <%= quickField("text", "Peso", "Peso", 2, reg("Peso"), "input-mask-brl text-right", "", "") %>
        </div>
        <div class="row">
			<%= quickField("phone", "Tel1", "Telefone", 3, reg("tel1"), "", "", "") %>
            <%= quickField("phone", "Tel2", "&nbsp;", 3, reg("tel2"), "", "", "") %>
            <%= quickField("mobile", "Cel1", "Celular", 3, reg("cel1"), "", "", "") %>
            <%= quickField("mobile", "Cel2", "&nbsp;", 3, reg("cel2"), "", "", "") %>
        </div>
	</div>
</div>
        	<div class="row">
            	<div class="col-md-12">
                    <div class="row">
                        <%= quickField("text", "Cep", "Cep", 2, reg("cep"), "input-mask-cep", "", "") %>
                        <%= quickField("text", "Endereco", "Endere&ccedil;o", 4, reg("endereco"), "", "", "") %>
                        <%= quickField("text", "Numero", "N&uacute;mero", 1, reg("numero"), "", "", "") %>
                        <%= quickField("text", "Complemento", "Compl.", 2, reg("complemento"), "", "", "") %>
                        <%= quickField("email", "Email1", "E-mail", 3, reg("email1"), "", "", "") %>
                    </div>
                    <div class="row">
                        <%= quickField("text", "Bairro", "Bairro", 3, reg("bairro"), "", "", "") %>
                        <%= quickField("text", "Cidade", "Cidade", 3, reg("cidade"), "", "", "") %>
                        <%= quickField("text", "Estado", "Estado", 1, reg("estado"), "", "", "") %>
                        <div class="col-md-2">
	                        <%= selectInsert("Pa&iacute;s", "Pais", reg("Pais"), "paises", "NomePais", "", "", "") %>
                        </div>
                        <%= quickField("email", "Email2", "&nbsp;", 3, reg("email2"), "", "", "") %>
                    </div>
                    <hr />
                    <div class="row">
                        <div class="col-sm-3">
                            <%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, reg("Observacoes"), "", "", " rows='3'") %>
                            <%= quickField("memo", "Pendencias", "Pend&ecirc;ncias", 12, reg("Pendencias"), "", "", "") %>
                        </div>
                        <div class="col-sm-3">
                            <%= quickField("text", "Profissao", "Profiss&atilde;o", 12, reg("profissao"), "", "", "") %>
                            <%= quickField("simpleSelect", "GrauInstrucao", "Escolaridade", 12, reg("grauinstrucao"), "select * from GrauInstrucao where sysActive=1 order by GrauInstrucao", "GrauInstrucao", "") %>
                            <%= quickField("text", "Documento", "RG", 12, reg("Documento"), "", "", "") %>
                            <%= quickField("text", "CPF", "CPF", 12, reg("CPF"), " input-mask-cpf", "", "") %>
                        </div>
                        <div class="col-sm-3">
                            <%= quickField("text", "Naturalidade", "Naturalidade", 12, reg("Naturalidade"), "", "", "") %>
                            <%= quickField("simpleSelect", "EstadoCivil", "Estado Civil", 12, reg("estadocivil"), "select * from EstadoCivil where sysActive=1 order by EstadoCivil", "EstadoCivil", "") %>
                            <%= quickField("simpleSelect", "Origem", "Origem", 12, reg("Origem"), "select * from Origens where sysActive=1 order by Origem", "Origem", "") %>
                            <%= quickField("text", "IndicadoPor", "Indica&ccedil;&atilde;o", 12, reg("IndicadoPor"), "", "", "") %>
                        </div>
                        <div class="col-sm-3">
                            <%= quickField("text", "Religiao", "Religi&atilde;o", 12, reg("Religiao"), "", "", "") %>
                            <%= quickField("text", "CNS", "CNS", 12, reg("CNS"), "", "", "") %>
                            <%
                            set tab = db.execute("select * from TabelaParticular where sysActive=1")
                            if tab.EOF then
                                %><input type="hidden" name="Tabela" value="0" id="Tabela" /><%
                            else
                                response.Write(quickField("simpleSelect", "Tabela", "Tabela", 12, reg("Tabela"), "select * from TabelaParticular where sysActive=1", "NomeTabela", ""))
                            end if
                            %>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
            		<!--#include file="PacientesConvenio.asp"-->
                </div>
            </div>
            <div class="row">
            	<div class="col-md-6">
					<%call Subform("PacientesRetornos", "PacienteID", req("I"),"frm")%>
                </div>
            	<div class="col-md-6">
					<%call Subform("PacientesRelativos", "PacienteID", req("I"), "frm")%>
                </div>
            </div>
            <hr>
                    <%
		if (reg("sysActive")=1 and aut("pacientesA")=1) or (reg("sysActive")=0 and aut("pacientesI")=1) then
		%>
        <div class="row">
          <div class="col-md-2 pull-right">
            <button class="btn btn-block btn-primary">
                <i class="far fa-save"></i> Salvar
            </button>
          </div>
        </div>
        <%
		end if
		%>

</form>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
</script>

<%


if not isnull(reg("Validade1")) then
    if reg("Validade1")<date() then
        %>
<script language="javascript">
$( document ).ready(function() {
$.gritter.add({
	    title: 'CORRIJA OS PROBLEMAS',
	    text: 'A data da carteirinha do conv&ecirc;nio est&aacute; vencida.',
	    image: 'assets/img/atFim.png',
	    sticky: true,
	    time: '',
	    class_name: 'gritter-error'
	});
    return false;
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
</script>
    <%
    end if
end if


if not isnull(reg("Nascimento")) and isdate(reg("Nascimento")) then

    if day(reg("Nascimento"))=day(date()) and month(reg("Nascimento"))=month(date()) then
        txt = "O paciente completa "&idade(reg("Nascimento"))&" este mês."
        if day(reg("Nascimento"))=day(date()) then
            txt = "Hoje o paciente completa "&idade(reg("Nascimento"))&"."
        end if
        %>
<script language="javascript">
$( document ).ready(function() {
$.gritter.add({
        icon: 'far fa-birthday-cake',
	    title: 'ANIVERS&Aacute;RIO DO PACIENTE',
	    text: '<%=txt%>',
	    image: 'assets/img/birthday.gif',
	    sticky: true,
	    time: '',
	    class_name: 'gritter-warning'
	});
    return false;
});
</script>
    <%
    end if
end if
%>
