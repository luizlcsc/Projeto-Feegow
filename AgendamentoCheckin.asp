<!--#include file="connect.asp"-->
<%
set omit = db.execute("select * from omissaocampos")
while not omit.eof
	tipo = omit("Tipo")
	grupo = omit("Grupo")
	if Tipo="P" and lcase(session("Table"))="profissionais" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
		omitir = omitir&lcase(omit("Omitir"))
	elseif Tipo="F" and lcase(session("Table"))="funcionarios" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
		omitir = omitir&lcase(omit("Omitir"))
	elseif Tipo="E" and lcase(session("Table"))="profissionais" then
		set prof = db.execute("select EspecialidadeID from profissionais where id="&session("idInTable"))
		if not prof.eof then
			if instr(grupo, "|"&prof("EspecialidadeID")&"|")>0 then
				omitir = omitir&lcase(omit("Omitir"))
			end if
		end if
	end if
    if omit("Tipo")="C" then
        omitir = omitir & lcase(omit("Omitir")) & "|tel1|, |cel1|, |email1|, |tabela|"
    end if
omit.movenext
wend
omit.close
set omit = nothing

set CamposNaAgendaSQL = db.execute("SELECT Exibir, group_concat(Obrigar) Obrigar FROM obrigacampos WHERE Recurso='Agendamento' OR Recurso='Paciente'")
if not CamposNaAgendaSQL.eof then
    ExibirCamposAgenda = CamposNaAgendaSQL("Exibir")&""
    camposObrigatorioPaciente= CamposNaAgendaSQL("Obrigar")&""
end if


AgendamentoID = req("id")
set reg = db.execute("select p.*, a.TabelaParticularID from agendamentos a LEFT JOIN pacientes p ON a.PacienteID=p.id WHERE a.id="& AgendamentoID)

if not reg.eof then
    TabelaParticularID = reg("TabelaParticularID")&""

    if TabelaParticularID="" then
        TabelaParticularID = reg("Tabela")
    end if
end if

%>
    <div class="panel-heading">
        Dados do Paciente
    </div>

    <div class="panel-body">
        <div class="row">
            <div class="col-md-4"><%=selectList("Nome &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small class=""label label-xs label-light hidden"" id=""resumoConvenios""></small>", "NomePaciente", reg("NomePaciente"), "pacientes", "NomePaciente", "location.href=""?P=Pacientes&Pers=1&I=""+$(this).val()", " required", "")%></div>
            <%=quickField("datepicker", "Nascimento", "Nascimento", 3, reg("Nascimento"), "input-mask-date", "", "")%>
            <%= quickField("text", "CPF", "CPF", 3, reg("CPF"), " input-mask-cpf", "", "") %>

            <%=quickField("simpleSelect", "Sexo", "Sexo", 2, reg("Sexo"), "select * from Sexo where sysActive=1", "NomeSexo", " empty")%>
        </div>
        <div class="row">
            <div class="col-md-8">
                <div class="row">
                    <%= quickField("text", "Cep", "Cep", 3, reg("cep"), "input-mask-cep", "", "") %>
                    <%= quickField("text", "Endereco", "Endere&ccedil;o", 5, reg("endereco"), "", "", "") %>
                    <%= quickField("text", "Numero", "N&uacute;mero", 2, reg("numero"), "", "", "") %>
                    <%= quickField("text", "Complemento", "Compl.", 2, reg("complemento"), "", "", "") %>
                </div>
                <div class="row">
                    <%= quickField("text", "Bairro", "Bairro", 4, reg("bairro"), "", "", "") %>
                    <%= quickField("text", "Cidade", "Cidade", 4, reg("cidade"), "", "", "") %>
                    <%= quickField("text", "Estado", "Estado", 2, reg("estado"), "", "", "") %>
                    <div class="col-md-2<%if instr(Omitir, "|pais|") then%> hidden<%end if%>">
	                    <%= selectInsert("Pa&iacute;s", "Pais", reg("Pais"), "paises", "NomePais", "", "", "") %>
                    </div>
                </div>
                <div class="row">
					<%= quickField("phone", "Tel1", "Telefone", 4, reg("tel1"), "", "", "") %>
                    <%= quickField("mobile", "Cel1", "Celular", 4, reg("cel1"), "", "", "") %>
                    <%= quickField("email", "Email1", "E-mail", 4, reg("email1"), "", "", "") %>
                    <%= quickField("phone", "Tel2", "Telefone 2", 4, reg("tel2"), "", "", "") %>
                    <%= quickField("mobile", "Cel2", "Celular 2", 4, reg("cel2"), "", "", "") %>
                    <%= quickField("email", "Email2", "E-mail 2", 4, reg("email2"), "", "", "") %>
                </div><br />
                <div class="row">
                    <%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 6, reg("Observacoes"), "", "", "") %>
                    <div class="col-md-6">
                        <div class="checkbox-custom checkbox-warning"><input data-rel="tooltip" title="" data-original-title="Marque para acionar lembrete" type="checkbox" class="tooltip-danger" name="lembrarPendencias" id="lembrarPendencias" value="S"<%if reg("lembrarPendencias")="S" then%> checked="checked"<%end if%> /><label for="lembrarPendencias"> Avisos e Pend&ecirc;ncias</label> <i class="far fa-flag red pull-right"></i></div>
                        <textarea class="form-control" name="Pendencias" id="Pendencias"><%=reg("Pendencias")%></textarea>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="row">
                    <%= quickField("text", "Profissao", "Profiss&atilde;o", 6, reg("profissao"), "", "", " style='max-height:37px'") %>
                    <%= quickField("simpleSelect", "GrauInstrucao", "Escolaridade", 6, reg("grauinstrucao"), "select * from GrauInstrucao where sysActive=1 order by GrauInstrucao", "GrauInstrucao", "") %>
                    <%= quickField("text", "Documento", "RG", 6, reg("Documento"), "", "", "") %>
                    <%= quickField("text", "Naturalidade", "Naturalidade", 6, reg("Naturalidade"), "", "", "") %>
					<%= quickField("simpleSelect", "EstadoCivil", "Estado Civil", 6, reg("estadocivil"), "select * from EstadoCivil where sysActive=1 order by EstadoCivil", "EstadoCivil", "") %>
                    <%= quickField("simpleSelect", "Origem", "Origem", 6, reg("Origem"), "select * from Origens where sysActive=1 order by Origem", "Origem", " empty") %>
                    <%= quickField("text", "IndicadoPor", "Indica&ccedil;&atilde;o", 6, reg("IndicadoPor"), "", "", "") %>
                    <%= quickField("text", "Religiao", "Religi&atilde;o", 6, reg("Religiao"), "", "", "") %>
                    <%= quickField("text", "CNS", "CNS", 6, reg("CNS"), "", "", "") %>
                    <%=quickField("simpleSelect", "CorPele", "Cor da Pele", 6, reg("CorPele"), "select * from CorPele where sysActive=1", "NomeCorPele", "")%>
                    <%
					set tab = db.execute("select * from TabelaParticular where sysActive=1")
					if tab.EOF then
						%><input type="hidden" name="Tabela" value="0" id="Tabela" /><%
					else
						response.Write(quickField("simpleSelect", "ageTabela", "Tabela", 6, TabelaParticularID, "select * from TabelaParticular where sysActive=1 and Ativo='on' and (Unidades like '' or Unidades = "&session("UnidadeID")&" or Unidades like '%|"& session("UnidadeID") &"|%') order by NomeTabela", "NomeTabela", " onchange=""$.each($('.linha-procedimento'), function(){ parametros('ProcedimentoID'+$(this).data('id'),$(this).find('[id^=ProcedimentoID]').val()); })""  "))
					end if
					%>
                </div>
            </div>
        </div>
    </div>
<%
'on error resume next

if reg("lembrarPendencias")="S" then
%>
<script type="text/javascript">
$( document ).ready(function() {
	new PNotify({
			title: 'AVISOS E PEND&Ecirc;NCIAS',
			text: $("#Pendencias").val(),
			sticky: true,
			type: 'warning',
            delay: 5000
		});

});
</script>
<%
end if

camposPedir = "Tel1, Cel1, Email1"
if ExibirCamposAgenda<> "" then
    camposPedir= camposPedir&","&ExibirCamposAgenda
end if


camposPedir = replace(camposPedir, "|", "")
camposPedir= replace(camposPedir, " ", "")

camposObrigatorioPaciente = replace(camposObrigatorioPaciente, "|", "")
camposObrigatorioPaciente= replace(camposObrigatorioPaciente, " ", "")

    %>
<script >
var camposProtegerArr = "<%=camposPedir%>".split(",");
var camposObrigatoriosArr =  "<%=camposObrigatorioPaciente%>".split(",");

for(let i=0;i<camposProtegerArr.length;i++){
    let campoProteger = camposProtegerArr[i];
    let $campo = $("#"+campoProteger);

    if($campo){
        $("#age"+campoProteger).change(function() {
            var newVal = $(this).val();
            $campo.val(newVal).change();
        });

        if($campo.hasClass("select2-single")){
            $campo.select2({disabled:'readonly', attr: 'Preencha este campo acima.'});
        }else{
            $campo.attr("readonly", "true").attr("title", "Preencha este campo acima.");
        }
    }
}

for(let i=0;i<camposObrigatoriosArr.length;i++){
    let $campo = $("#"+camposObrigatoriosArr[i]);
    if($campo){
        $campo.attr("required",true);
    }
}

</script>
    <%


if not isnull(reg("Nascimento")) and isdate(reg("Nascimento")) then
    if month(reg("Nascimento"))=month(date()) and day(reg("Nascimento"))=day(date()) and idade(reg("Nascimento"))<> "Nascido hoje" then
        txt = "Hoje o paciente completa "&idade(reg("Nascimento"))&"."
        %>
<script type="text/javascript">
$( document ).ready(function() {
new PNotify({
	    icon: 'far fa-birthday-cake',
	    title: 'ANIVERS&Aacute;RIO DO PACIENTE',
	    text: '<%=txt%>',
	    type: 'info',
        delay: 5000
	});
    return false;
});

</script>
    <%
    end if
end if
%>


<script type="text/javascript">
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