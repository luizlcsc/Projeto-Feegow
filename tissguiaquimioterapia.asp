<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<%posModalPagar="fixed" %>
<!--#include file="invoiceEstilo.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Anexo de Solicitação de Quimioterapia");
    $(".crumb-icon a span").attr("class", "far fa-credit-card");
</script>
<style>
.select2-container{
    width: 100%!important;
}
</style>
<%
call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))

MinimoDigitos = 0
MaximoDigitos = 100

NGuiaPrincipal = reg("NGuiaReferenciada")
CNS = reg("CNS")
RegistroANS = reg("RegistroANS")
NGuiaPrestador = reg("NGuiaPrestador")
Senha = reg("Senha")
DataAutorizacao = reg("DataAutorizacao")
NGuiaOperadora = reg("NGuiaOperadora")
NumeroCarteira = reg("NumeroCarteira")
DataValidadeSenha = reg("DataValidadeSenha")
NumeroCarteira = reg("NumeroCarteira")
ValidadeCarteira = reg("ValidadeCarteira")
PacienteID = reg("PacienteID")
Peso = reg("Peso")
Altura = reg("Altura")
IdadePaciente = reg("Idade")
if IdadePaciente = 0 then
    IdadePaciente = ""
end if
SuperficieCorporal = reg("SuperficieCorporal")
Sexo = reg("Sexo")
if Sexo = "Masculino" then
    Sexo = 1
elseif Sexo = "Feminino" then
    Sexo = 2
elseif Sexo = "Indefinido" then
    Sexo = 3
end if
ConvenioID = reg("ConvenioID")
PlanoID = reg("PlanoID")
if PlanoID&"" = "" then
    PlanoID = 0
end if
ProfissionalSolicitanteID = reg("ProfissionalSolicitanteID")
Telefone = reg("Telefone")
Email = reg("Email")
DataDiagnostico = reg("DataDiagnostico")
Cid1 = reg("Cid1")
Cid2 = reg("Cid2")
Cid3 = reg("Cid3")
Cid4 = reg("Cid4")
Estadiamento = reg("Estadiamento")
TipoQuimioterapia = reg("TipoQuimioterapia")
Finalidade = reg("Finalidade")
ECOG = reg("ECOG")
PlanoTerapeutico = reg("PlanoTerapeutico")
DiagnosticoCitoHistopatologico = reg("DiagnosticoCitoHistopatologico")
InfoRelevante = reg("InfoRelevante")
Cirurgia = reg("Cirurgia")
DataRealizacao = reg("DataRealizacao")
AreaIrradiada = reg("AreaIrradiada")
DataAplicacao = reg("DataAplicacao")
Observacoes = reg("Observacoes")
NumeroCicloPrevisto = reg("NumeroCicloPrevisto")
CicloAtual = reg("CicloAtual")
IntervaloEntreCiclos = reg("IntervaloEntreCiclos")
DataSolicitacao = reg("DataSolicitacao")

UnidadeID = reg("UnidadeID")
if UnidadeID&"" = "" then
    UnidadeID = session("UnidadeID")
end if
RepetirNumeroOperadora = 0
if ConvenioID<> "" then
    set conv = db.execute("select c.* from convenios c where c.id="&ConvenioID)
    if not conv.eof then
        if conv("RepetirNumeroOperadora")=1 then
            %>
            <script >
            $(document).ready(function(){
                $("#NGuiaOperadora").keyup(function(){
                    $('#NGuiaPrestador').val( $(this).val() );

                });
            })
            </script>
            <%
        end if
    end if
end if

%>
<form id="GuiaQuimioterapia" action="" method="post">
    <div class="row">
        <div class="col-md-10">
        </div>
        <%=quickField("empresa", "UnidadeID", "Unidade", 2, UnidadeID, "", "", "")%>
    </div>
    <br />
    <div class="admin-form theme-primary">
        <div class="panel heading-border panel-primary">
            <div class="panel-body">
                <input type="hidden" name="tipo" value="GuiaQuimioterapia" />
                <input type="hidden" name="GuiaID" value="<%=req("I")%>" />
                <div class="section-divider mt40 mb20">
                    <span> Dados do Beneficiário </span>
                </div>
                <div class="row">
                    <div class="col-md-3"><%= selectInsert("Paciente  <button onclick=""if($('#gPacienteID').val()==''){alert('Selecione um Paciente')}else{window.open('./?P=Pacientes&Pers=1&I='+$('#gPacienteID').val())}"" class='btn btn-xs btn-default' type='button'><i class='far fa-external-link'></i></button>", "gPacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""tissCompletaDados(1, this.value);""", " required", "") %></div>
                    <%= quickField("simpleSelect", "gConvenioID", "Conv&ecirc;nio", 2, ConvenioID, "select * from Convenios where sysActive=1 and ativo='on' order by NomeConvenio", "NomeConvenio", " empty="""" required=""required""") %>
                    <div class="col-md-2" id="tissplanosguia"><!--#include file="tissplanosguia.asp"--></div>
                    <script> 
                        $('#gPacienteID').prop('required', true);
                        $('#PlanoID option[value="<%=PlanoID%>"]').attr('selected','selected');
                    </script>
                    <%
                        pattern = ""
                        if MaximoDigitos&"" <> "" then
                            pattern= "'.{"&MinimoDigitos&","&MaximoDigitos&"}'"
                        end if
                    %>
                    <div class="col-md-2">
                        <%= quickField("text", "NumeroCarteira", "N&deg; da Carteira", 12, NumeroCarteira, " lt", "", " required""  autocomplete='matricula' required "&pattern&" title=""O padrão da matrícula deste convênio está configurado para 10 caracteres""") %>
                        <div class="form-group has-error" id="NumeroCarteiraContent" style="display: none;position: absolute;top: 65px;z-index: 9999;">
                            <input id="NumeroCarteiraValidacao" class=" form-control input-sm" placeholder="Digite novamente  o  n&deg; da carteira...">
                        </div>
                    </div>
                    <%= quickField("datepicker", "ValidadeCarteira", "Data Validade da Carteira", 2, ValidadeCarteira, " input-mask-date ", "", "") %>
                    <%= quickField("text", "RegistroANS", "Reg. ANS", 1, RegistroANS, "", "", " required minlength='1' maxlength='6'") %>
                </div>
                <br />
                <div class="row mb20">
                    <%= quickField("datepicker", "DataAutorizacao", "Data da Autoriza&ccedil;&atilde;o", 2, DataAutorizacao, "", "", "") %>
                    <%= quickField("text", "Senha", "Senha", 1, Senha, "", "", "") %>
                    <%= quickField("datepicker", "DataValidadeSenha", "Validade da Senha", 2, DataValidadeSenha, "", "", "") %>
                    <%= quickField("text", "NGuiaPrestador", "N&deg; da Guia no Prestador", 2, NGuiaPrestador, "", "", " autocomplete='nro-prestador' required") %>
                    <%
                    if RepetirNumeroOperadora=1 then
                        fcnRepetirNumeroOperadora = " onkeyup=""$('#NGuiaPrestador').val( $(this).val() )"" "
                    end if
                    %>
                    <%= quickField("text", "NGuiaOperadora", "N&deg; da Guia na Operadora", 2, NGuiaOperadora, "", "", fcnRepetirNumeroOperadora) %>
                    <%= quickField("text", "NGuiaReferenciada", "N&deg; da Guia Principal", 2, NGuiaPrincipal, "", "", " required ") %>
                    <%= quickField("text", "CNS", "CNS", 1, CNS, "", "", "") %>
                </div>
                <div class="row">
                    <%= quickField("text", "Peso", "Peso(Kg)", 3, Peso, "", "", " required") %>
                    <%= quickField("text", "Altura", "Altura(Cm)", 3, Altura, "", "", " required") %>
                    <%= quickField("text", "SuperficieCorporal", "Superficie Corporal", 2, SuperficieCorporal, "", "", " required") %>
                    <%= quickField("number", "Idade", "Idade", 2, IdadePaciente, "", "", " required") %>
                    <%=quickField("simpleSelect", "Sexo", "Sexo", 2, Sexo, "select * from Sexo where sysActive=1", "NomeSexo", "required")%>
                </div>
                <div class="section-divider mt40 mb20">
                    <span> Dados do Profissional Solicitante </span>
                </div>
                <div class="row">
                    <%= quickField("simpleSelect", "ProfissionalID", "Profissional Solicitante", 4, ProfissionalSolicitanteID, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", " onchange=""tissCompletaDados('ProfissionalSolicitante', this.value);"" required") %>
                    <%= quickField("datepicker", "DataSolicitacao", "Data da Solicitação", 2, DataSolicitacao, "", "", "required") %>
                    <%= quickField("mobile", "Cel1", "Telefone", 3, Telefone, "", "", " required") %>
                    <%= quickField("text", "Email", " E-mail", 3, Email, "", "", "") %>
                </div>
                <div class="section-divider mt40 mb20">
                    <span> Diagnóstico Oncológico </span>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="row mb20">
                            <div class="col-md-3">
                                <%= quickField("datepicker", "DataDiagnostico", " Data do Diagnóstico", 12, DataDiagnostico, "", "", "") %>
                            </div>
                            <div class="col-md-9">
                                <div class="col-md-3">
                                    <%= selectInsert("CID 10 Principal", "Cid1", Cid1, "cliniccentral.cid10", "codigo", "", "", "") %>
                                </div>
                                <div class="col-md-3">
                                    <%= selectInsert("CID 10 (2)", "Cid2", Cid2, "cliniccentral.cid10", "codigo", "", "", "") %>
                                </div>
                                <div class="col-md-3">
                                    <%= selectInsert("CID 10 (3)", "Cid3", Cid3, "cliniccentral.cid10", "codigo", "", "", "") %>
                                </div>
                                <div class="col-md-3">
                                    <%= selectInsert("CID 10 (4)", "Cid4", Cid4, "cliniccentral.cid10", "codigo", "", "", "") %>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <%= quickField("text", "Estadiamento", "Estadiamento", 3, Estadiamento, "", "", " required minlength='1' maxlength='1'") %>
                            <%= quickField("text", "TipoQuimioterapia", "Tipo de Quimioterapia", 3, TipoQuimioterapia, "", "", " required minlength='1' maxlength='1'") %>
                            <%= quickField("text", "Finalidade", "Finalidade", 2, Finalidade, "", "", " required minlength='1' maxlength='1'") %>
                            <%= quickField("text", "ECOG", "ECOG", 4, ECOG, "", "", " required minlength='1' maxlength='1'") %>
                        </div>
                        <div class="row mt20">
                            <%=quickfield("memo", "DiagnosticoCitoHistopatologico", " Diagnostico Cito/Histopatógico", 12, DiagnosticoCitoHistopatologico, "", "", "rows='4' minlength='0' maxlength='1000'")%>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="row">
                            <%=quickfield("memo", "PlanoTerapeutico", "Plano Terapêutico", 12, PlanoTerapeutico, "", "", "rows='5' required minlength='0' maxlength='1000'")%>
                        </div>
                        <div class="row mt10">
                            <%=quickfield("memo", "InfoRelevante", " Informações Relevantes", 12, InfoRelevante, "", "", "rows='4' minlength='0' maxlength='1000'")%>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="section-divider mt40 mb20">
                        <span> Medicamentos e drogas solicitadas </span>
                    </div>
                    <div class="row">
                        <div class="col-md-12" id="tissmedicamentosquimioterapia">
                            <%server.Execute("tissmedicamentosquimioterapia.asp")%>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="section-divider mt40 mb20">
                        <span> Tratamentos Anteriores </span>
                    </div>
                    <%= quickField("text", "Cirurgia", " Cirurgia", 3, Cirurgia, "", "", "") %>
                    <%= quickField("datepicker", "DataRealizacao", " Data da Realização", 3, DataRealizacao, "", "", "") %>
                    <%= quickField("text", "AreaIrradiada", " Área irradiada", 3, AreaIrradiada, "", "", "") %>
                    <%= quickField("datepicker", "DataAplicacao", " Data da Aplicação", 3, DataAplicacao, "", "", "") %>
                </div>
                <div class="row">
                    <div class="section-divider mt40 mb20">
                        <span> Informações Adicionais </span>
                    </div>
                    <div class="col-md-12 mb20">
                        <div class="row">
                            <%=quickField("number", "NumeroCicloPrevisto", "Número de Ciclos Previstos", 3, NumeroCicloPrevisto, "", "", " required min='0' max='99' ")%>
                            <%=quickField("number", "CicloAtual", "Ciclos Atual", 2, CicloAtual, "", "", " required min='0' max='99' ")%>
                            <%=quickField("number", "IntervaloEntreCiclos", "Intervalo entre Ciclos(em dias)", 3, IntervaloEntreCiclos, "", "", " required min='0' max='999' ")%>
                            <%= quickField("memo", "Observacoes", " Observação / Justificativa", 4, Observacoes, "", "", "minlength='0' maxlength='500'") %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="clearfix form-actions no-margin">
            <button class="btn btn-primary btn-md"><i class="far fa-save"></i> Salvar</button>
            <button type="button" class="btn btn-md btn-default pull-right" onclick="guiaTISS('GuiaQuimioterapia', 0)"><i class="far fa-file"></i> Imprimir Guia em Branco</button>
        </div>
    </div>
</form>

<% if AutorizadorTiss then %>
<script type="text/javascript" src="js/autorizador-tiss.js"></script>
<% end if %>
<script type="text/javascript">
$(document).ready(function() {
    $('#PacienteID,#ProfissionalID option[value=0]').attr('value', '');
    let ProfissionalSolicitanteID = '<%=ProfissionalSolicitanteID%>';
    if(ProfissionalSolicitanteID == ''){
        $('#ProfissionalSolicitanteID').val('');
        $('#ProfissionalSolicitanteID option[value=""]').attr('selected','selected');
    }
});
<% if AutorizadorTiss then %>
if(typeof AutorizadorTiss === "function"){
    var Autorizador = new AutorizadorTiss();
    Autorizador.userId = "<%=session("User")%>";
    Autorizador.guideId = "<%=req("I")%>";
    Autorizador.sadt = true;
}

$(document).ready(function() {
    Autorizador.bloqueiaBotoes(3);    
   
});
<% end if %>


function autorizadorGuiaQuimioterapia(){
	$.ajax({
        type:"POST",
		url:"saveGuiaQuimioterapia.asp?Tipo=Quimioterapia&I=<%=request.QueryString("I")%>",
		data:$("#GuiaQuimioterapia").serialize(),
		success:function(data){
            Autorizador.autorizaInternacoes();
		},
		error:function(data){
            alert("Preencher todos os campos obrigatórios")
        }
    });
    return false;
}


function tissCompletaDados(T, I){
	$.ajax({
		type:"POST",
		url:"tissCompletaDados.asp?I="+I+"&T="+T,
		data:$("#GuiaQuimioterapia").serialize(),
		success:function(data){
			eval(data);
		}
	});
}
    $("#gConvenioID, #UnidadeID").change(function(){
        tissCompletaDados("Convenio", $("#gConvenioID").val());
    });

    $("#Contratado, #UnidadeID").change(function(){
        tissCompletaDados("Contratado", $(this).val());
    });

    $("#ContratadoSolicitanteID").change(function(){
        tissCompletaDados("ContratadoSolicitante", $(this).val());
    });


$("#GuiaQuimioterapia").submit(function(){
	$.ajax({
		type:"POST",
		url:"saveGuiaQuimioterapia.asp?Tipo=Quimioterapia&I=<%=request.QueryString("I")%>",
		data:$("#GuiaQuimioterapia").serialize(),
		success:function(data){
			eval(data);
		}
	});
	return false;
});

function itemQuimioterapia(T, I, II, A){
    $("[id^="+T+"]").html('');
    if(A!='Cancela'){
        $("#"+T+II).removeClass('hidden');
	    $.ajax({
	        type:"POST",
	        url:"modalQuimioterapia.asp?T="+T+"&I="+I+"&II="+II,
	        data:$("#GuiaQuimioterapia").serialize(),
	        success:function(data){
                $("#"+T+II).fadeIn();
                $("#"+T+II).html(data);
	            $("#Fator").trigger("keyup")
	        }
	    });
	}
}

function atualizaTabela(D, U){
	$.ajax({
	   type:"GET",
	   url:U,
	   success:function(data){
		   $("#"+D).html(data);
	   }
   });
}

function tc(T){
	if(T=="I"){
		$("#spanContratadoE").css("display", "none");
		$("#spanContratadoI").css("display", "block");
	}else{
		$("#spanContratadoE").css("display", "block");
		$("#spanContratadoI").css("display", "none");
	}
}
function tps(T){
	if(T=="I"){
		$("#spanProfissionalSolicitanteE").css("display", "none");
		$("#spanProfissionalSolicitanteI").css("display", "block");
	}else{
		$("#spanProfissionalSolicitanteE").css("display", "block");
		$("#spanProfissionalSolicitanteI").css("display", "none");
	}
}

<%if trocaConvenioID<>"" then%>
    $("#gConvenioID").val("<%=trocaConvenioID%>");
tissCompletaDados("Convenio", $("#gConvenioID").val());
<%end if%>

$('#IdentificadorBeneficiario').keydown(function(e) {
    if(e.which == 10 || e.which == 13){
        return false;
    }
});

function addContrato(ModeloID, InvoiceID, ContaID){
    if($("#gPacienteID").val()==""){
        alert("Selecione um paciente.");
        $("#gPacienteID").focus();
    }else{
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.post("addContrato.asp?Tipo=Quimioterapia&ModeloID="+ModeloID+"&InvoiceID="+InvoiceID+"&ContaID=3_"+$("#gPacienteID").val(), "", function(data){
            $("#modal").html(data);
        });
    }
}
function AutorizarGuiaTisss()
{
    $("#btnSalvar").click();
    setTimeout(() => {
        isSolicitar = true;
    }, 50);
}
function tissplanosguia(ConvenioID){

    let PlanoID = "<%=PlanoID%>";

	$.ajax({
		type:"POST",
		url:"chamaTissplanosguia.asp?PlanoID=<%=PlanoID %>&ConvenioID="+ConvenioID,
		data:$("#GuiaSADT").serialize(),
		success: function(data){
			$("#tissplanosguia").html(data);
    		$("[name='PlanoID']").val(PlanoID);
		}
	});
}
<%
if drCD<>"" then
    response.write(drCD)
end if
    %>

<!--#include file="JQueryFunctions.asp"-->
</script>