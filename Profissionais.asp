<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="functions.asp"-->
<style>
.listaUnidades{
	list-style-type:none;
	margin-left:10px;
}
.listaUnidades li span{
	font-size:12px!important;
}

</style>
<%
call insertRedir(req("P"), req("I"))

sqlReg = "select * from Profissionais where id="&req("I")

set reg = db.execute(sqlReg)
RegUnidades = reg("Unidades")

if regUnidades&"" = "" then
    regUnidades = "|0|"
end if

IF req("Proximo") = "1"  THEN
    sqlProximo = "select id from Profissionais where Ativo = 'on' and id>"&req("I")
    set regNext = db.execute(sqlProximo)

    IF NOT regNext.EOF THEN
        response.Redirect("./?P=profissionais&Pers=1&I="&regNext("id"))
        response.end
    END IF

END IF


Aba = req("Aba")

if Aba="" then
	ativoCadastro = " class=""active"""
	ativoHorarios = ""
	chamaScript = ""
	tabCadastro = " in active"
	tabHorarios = ""
elseif Aba="Horarios" then
	ativoCadastro = ""
	ativoHorarios = " class=""active"""
	if versaoAgenda()=1 then
    
		chamaScript = "ajxContent('Horarios-1', "&req("I")&", 1, 'divHorarios');"
	else
		chamaScript = "ajxContent('Horarios', "&req("I")&", 1, 'divHorarios');"
	end if
	tabCadastro = ""
	tabHorarios = " in active"
end if
%>

<%=header(req("P"), "Cadastro de Profissional", reg("sysActive"), req("I"), req("Pers"), "Follow")%>

<br />

<div class="tabbable">
    <div class="tab-content">
        <div id="divCadastroProfissional" class="tab-pane<%=tabCadastro%>">


            <form method="post" id="frm" name="frm" action="save.asp">
                <input type="hidden" name="I" value="<%=req("I")%>" />
                <input type="hidden" name="P" value="<%=req("P")%>" />

                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title">
                            Dados Principais
                        </span>
                        <span class="panel-controls">
                        <%
                        if (reg("sysActive")=1 AND session("Franqueador") <> "") then
                            %>
                            <button class="btn btn-dark btn-sm" type="button" onclick="replicarRegistro(<%=reg("id")%>,'<%=req("P")%>')"><i class="far fa-copy"></i> Replicar</button>
                            <%
                        end if
                        %>
                        <%
		                if (reg("sysActive")=1 and aut("|profissionaisA|")=1) or (reg("sysActive")=0 and aut("|profissionaisI|")=1) then
		                    %>
                            <button class="btn btn-primary btn-sm" id="save"> <i class="far fa-save"></i> Salvar </button>
		                    <%
		                end if
		                %>
                        </span>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                <div class="col-md-2" id="divAvatar">
                    <div class="row">
                        <div class="col-md-12">
							<%
                            if reg("Foto")="" or isnull(reg("Foto")) then
                                divDisplayUploadFoto = "block"
                                divDisplayFoto = "none"
                            else
                                divDisplayUploadFoto = "none"
                                divDisplayFoto = "block"
                            end if
                            %>
                            <div id="divDisplayUploadFoto" style="display:<%=divDisplayUploadFoto%>">
                                <input type="file" name="Foto" id="Foto" />
                            </div>
                            <div id="divDisplayFoto" style="display:<%= divDisplayFoto %>">
                                <img id="avatarFoto" src="<%=arqEx(reg("Foto"), "Perfil")%>" class="img-thumbnail" width="100%" />
                                <button  type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="far fa-trash"></i></button>
                            </div>
                        </div>
                    </div>
                        <div class="row text-center">
                            <%=quickField("cor", "Cor", "Cor na agenda", 12, reg("Cor"), "select * from Cores", "Cor", "")%>
                        </div>

                    <br />



                    <div class="panel">
                        <div class="panel-heading">
                            <span class="panel-title">
                                <i class="far fa-hospital-o"></i> Unidades
                            </span>
                        </div>
                        <div class="panel-body p7">
                            <% 
                            QtdUnidades = ubound(split(session("Unidades"), ","))


                            IF QtdUnidades > 3 THEN %>
                                <div class="row">
                                    <div class="col-md-2">
                                        <div class="checkbox-primary checkbox-custom allU">
                                             <input id="allcheck" onchange="selecionarTodasUnidades(this.checked)" type="checkbox" >
                                            <label for="allcheck"> <small></small></label>
                                        </div>
                                    </div>
                                    <div class="col-md-9" style="margin-left: 5px; margin-top: 5px">
                                        <input type="text" class="form-control input-sm" onkeyup="filterUnidades(this.value)">
                                        <script>
                                        function filterUnidades(arg){
                                                arg = arg.toUpperCase();
                                                $("[data-name],.allU").show();
                                                $("[data-name]").each((k,item) =>{
                                                    $(item).attr("data-name",$(item).attr("data-name").toUpperCase())
                                                })

                                                if(arg){
                                                    $("[data-name]:not([data-name*='"+arg+"']),.allU").hide();
                                                }
                                        }
                                        </script>
                                    </div>
                                </div>
                                <hr style="margin: 10px 0" />
                            <% END IF

                            unidadesFuncionario = regUnidades
                            %>
                        	<div class="checkbox-primary checkbox-custom" data-name="Empresa Principal"><input type="checkbox" name="Unidades" id="Unidades0" value="|0|"<%if instr(unidadesFuncionario, "|0|")>0 then%> checked="checked"<%end if%> /><label for="Unidades0"> <small>Empresa principal</small></label></div>
						<%
						set unidades = db.execute("select id, UnitName,NomeFantasia from sys_financialcompanyunits where sysActive=1 order by NomeFantasia")
						while not unidades.eof
						    nomeUnidade = unidades("NomeFantasia")
							%>
							<div class="checkbox-custom checkbox-primary" data-name="<%=nomeUnidade%>">
                                <input type="checkbox" <% IF ModoFranquiaUnidade THEN %>onclick="return false;"<% END IF %> name="Unidades" id="Unidades<%=unidades("id")%>" value="|<%=unidades("id")%>|"<%if instr(unidadesFuncionario, "|"&unidades("id")&"|")>0 then%> checked="checked"<%end if%> /><label for="Unidades<%=unidades("id")%>"><small> <%=nomeUnidade%> </small></label></div>
							<%
						unidades.movenext
						wend
						unidades.close
						set unidades=nothing
						%>
                        </div>
                    </div>

                    <div class="panel">
                        <div class="panel-heading">
                            <span class="panel-title">Assinatura</span>
                        </div>
                        <div class="panel-body" style="padding:5px !important">
                         <iframe width="100%" height="200" id="iframeDropZone" frameborder="0" scrolling="no" src="dropzone.php?ProfissionalID=<%= req("I") %>&L=<%= replace(session("Banco"), "clinic", "") %>&Pasta=Imagens&Tipo=I&Assinatura=true"></iframe>
                            <img src="<%=arqEx(reg("Assinatura"), "Imagens")%>" class="img-thumbnail" id="assinatura-img"/>
                            <button style="    position: absolute; bottom: 20px; right:20px;" id="buttonDeleteSignature" class="btn btn-xs btn-danger pull-right" onclick="if(confirm('Tem certeza de que deseja excluir esta assinatura?')){deleteSignature(<%= req("I") %>)};"><span class="far fa-trash "></span></button>

                        </div>
                    </div>

                    <button type="button" onclick="VisualizarEnvioDasAgendas()" class="btn btn-default btn-sm btn-block"><i class="far fa-envelope"></i> Visualizar envio das agendas</button>



                </div>
                <div class="col-md-10">
                    <div class="row">
                        <%=quickField("simpleSelect", "TratamentoID", "T&iacute;tulo", 1, reg("TratamentoID"), "select * from tratamento order by Tratamento", "Tratamento", "")%>
                        <%=quickField("text", "NomeProfissional", "Nome", 4, reg("NomeProfissional"), "", "", " required")%>
                        <%=quickField("datepicker", "Nascimento", "Nascimento", 2, reg("Nascimento"), "input-mask-date", "", "")%>
                        <%=quickField("simpleSelect", "Sexo", "Sexo", 2, reg("Sexo"), "select * from Sexo where sysActive=1", "NomeSexo", "")%>
                        <%= quickField("text", "CPF", "CPF", 2, reg("CPF"), " input-mask-cpf", "", " required") %>
                        <%

                        'não permitir o usuario inativar ele mesmo
                        if session("idInTable")&"" = req("I")&"" and (session("Table")&"" = req("P")&"") then
                            hideInactive = "hidden"
                        end if
                        %>
                        <div class="col-md-1 <%=hideInactive %>">
                            <label for="Ativo">Ativo</label><br />
                                <div class="switch round">
                                    <input <% If reg("Ativo")="on" or isnull(reg("Ativo")) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo" type="checkbox" />
                                    <label for="Ativo"></label>
                                </div>
                        </div>
                    </div>
                    <div class="row">

                        <div class="col-md-3">
                            <%= selectInsert("Especialidade", "EspecialidadeID", reg("EspecialidadeID"), "especialidades", "especialidade", "", "", "")%>
                        </div>
                        <%'=quickField("simpleSelect", "EspecialidadeID", "Especialidade", 3, reg("EspecialidadeID"), "select * from especialidades order by Especialidade", "Especialidade", "")%>
                        <%= quickField("text", "RQE", "RQE", 2, reg("RQE"), "", "", "") %>
                        <%= quickField("simpleSelect", "Conselho", "Conselho", 2, reg("Conselho"), "select * from conselhosprofissionais order by codigo", "codigo", "") %>
                        <%= quickField("text", "DocumentoConselho", "Registro", 2, reg("DocumentoConselho"), "", "", "") %>
                        <%= quickField("text", "UFConselho", "UF", 2, reg("UFConselho"), "", "", " maxlength=2") %>
                        <div class="col-xs-1">
                            <label>&nbsp;</label><br />
                            <button onclick="esps('I', 0)" class="btn btn-sm btn-default" type="button"><i class='far fa-plus'></i></button>
                        </div>
                    </div>
                    <div class="row" id="esps">
                        <%server.Execute("profissionaisespecialidades.asp") %>
                    </div>
                    <hr class="short alt" />
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
                        <%= quickField("simpleSelect", "Pais", "Pa&iacute;s", 2, reg("Pais"), "select * from Paises where sysActive=1 order by NomePais", "NomePais", "") %>
                    </div>
                    <%
                    set sysConf = db.execute("select * from sys_config")

                    if sysConf("ConfigGeolocalizacaoProfissional")="S" and recursoAdicional(39)=4 then
                    %>
                        <hr class="short alt" />
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="Coordenadas">Coordenadas (latitude,longitude)</label>
                                    <input class="form-control" type="text" name="Coordenadas" id="Coordenadas" value="<%=reg("Coordenadas")%>">
                                    <small class="text-muted">
                                        <b>Ex:</b> -23.00215774882604,-43.35115106562211
                                    </small>
                                    <br>
                                    <small class="text-muted">
                                        <a target="_blank" href="https://support.google.com/maps/answer/18539?co=GENIE.Platform%3DDesktop&hl=pt&oco=0">
                                            <b>clique aqui</b>
                                        </a> 
                                        para obter ajuda de como obter as coordenadas.
                                    </small>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div id="coords-map" class="col-md-12"></div>
                        </div>
                    <%end if%>
                    <hr class="short alt" />
                        <div class="row mt-1">
                            <%= quickField("phone", "Tel1", "Telefone", 4, reg("tel1"), "", "", "") %>
                            <%= quickField("mobile", "Cel1", "Celular", 4, reg("cel1"), "", "", "") %>
                            <%= quickField("email", "Email1", "E-mail", 4, reg("email1"), "", "", "") %>
                            <%= quickField("phone", "Tel2", "&nbsp;", 4, reg("tel2"), "", "", "") %>
                            <%= quickField("mobile", "Cel2", "&nbsp;", 4, reg("cel2"), "", "", "") %>
                            <%= quickField("email", "Email2", "&nbsp;", 4, reg("email2"), "", "", "") %>
                        </div>
                        <hr class="short alt" />
                        <div class="row">
                            <%=quickfield("simpleSelect", "AnamnesePadrao", "Anamnese Padrão", 2, reg("AnamnesePadrao"), "select * from buiforms where sysActive=1 and Tipo=1 order by Nome", "Nome", "") %>
                            <%=quickfield("simpleSelect", "EvolucaoPadrao", "Evolução Padrão", 2, reg("EvolucaoPadrao"), "select * from buiforms where sysActive=1 and Tipo=2 order by Nome", "Nome", "") %>
                            <%=quickfield("simpleSelect", "GrauPadrao", "Grau Participação Padrão (TISS)", 3, reg("GrauPadrao"), "select * from cliniccentral.tissgrauparticipacao order by Codigo", "Descricao", "") %>
                            <%=quickfield("simpleSelect", "CentroCustoID", "Centro de Custo", 3, reg("CentroCustoID"), "select * from centrocusto where sysActive=1 order by NomeCentroCusto", "NomeCentroCusto", "") %>
                            <div class="col-md-2">
                                <%=selectInsert("Grupo", "GrupoID", reg("GrupoID"), "profissionaisgrupos", "NomeGrupo", "", "", "") %>
                            </div>
                        </div>
                    
                    <hr class="short alt" />
                    <div class="row">
                        <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 12, reg("Obs"), "", "", "") %>
                    </div>
                    <div class="row">
                    <br>
                        <%=quickfield("simpleSelect", "FornecedorID", "Empresa", 3, reg("FornecedorID"), "select id,NomeFornecedor from fornecedores where sysActive=1 order by NomeFornecedor", "NomeFornecedor", "") %>
                        <%= quickField("text", "NomeSocial", "Nome Social", 6, reg("NomeSocial"), "", "", "") %>
                        <%= quickfield("simpleSelect", "AbaProntuario", "Aba do Prontuário", 3, reg("AbaProntuario"), "select '' id, 'Dados Principais' Descricao UNION ALL select 'abaForms', 'Anamneses e Evoluções' UNION ALL select 'abaTimeline', 'Linha do Tempo'", "Descricao", "semVazio") %>
                    </div>
                    <br>
                    <div class="row">

                        <%if session("admin")=1 then
                        AgendaProfissionais = reg("AgendaProfissionais")
                        %>
                            <%=quickField("multiple", "AgendaProfissionais", "Acesso as agendas dos profissionais", 4, AgendaProfissionais, "select id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
                        <%end if%>

                        <%= quickfield("multiple", "SomenteConvenios", "Convênios para agendamento", 4, reg("SomenteConvenios"), "(select '|NONE|' id, 'NÃO PERMITIR CONVÊNIO' NomeConvenio) UNION ALL (select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' order by NomeConvenio)", "NomeConvenio", "") %>
                        
                        <%= quickField("number", "IdadeMinima", "Idade mínima", 2, reg("IdadeMinima"), "", "", "") %>

                        <%= quickField("number", "IdadeMaxima", "Idade máxima", 2, reg("IdadeMaxima"), "", "", "") %>
                        
                        <%'= quickField("simpleSelect", "PlanoContaID", "Plano de Contas", 3, "", "select id,Name from sys_financialexpensetype where sysActive=1 order by Name", "Name", "") %>

                    </div>
                    <div class="row">
                        <div class='col-md-5'>
                            <%=quickField("simpleCheckbox", "NaoExibirAgenda", "Não exibir o profissional na agenda", 12, reg("NaoExibirAgenda"), "", "", "")%>

                            <% IF session("admin") = 1 and recursoadicional(37) = 4 THEN %>
                                <%=quickField("simpleCheckbox", "auditor", "Este é um médico auditor", 12,reg("auditor"), "", "", "")%>
                                <%=quickField("simpleCheckbox", "farmaceutico_auditor", "Este é um farmacêutico é auditor", 12,reg("farmaceutico_auditor"), "", "", "")%>
                            <% ELSE %>
                                <input type="hidden" value="<%=reg("auditor")%>" name="auditor">
                                <input type="hidden" value="<%=reg("farmaceutico_auditor")%>" name="farmaceutico_auditor">
                            <% END IF %>
                        </div>
                    </div>
                    <br>
                    <div class="row">
                        <%= quickField("memo", "ObsAgenda", "Mensagem informativa na agenda", 6, reg("ObsAgenda"), "", "", "") %>
                        <br>
                        <div class="col-md-6">
                            <%call Subform("profissionaissubespecialidades", "ProfissionalID", req("I"), "frm")%>
                            <div id="block-programas-saude"></div>
                        </div>
                    </div>
                </div>
            </div>
                </div>
            </div>

            
            </form>




        </div>
        <div id="divHorarios" class="tab-pane<%=tabHorarios%>">
			<div class="panel">
			    <div class="panel-body">
			        <i class="far fa-circle-o-notch fa-spin"></i> Carregando...
                </div>
            </div>
        </div>
        <div id="divPermissoes" class="tab-pane">
			<div class="panel">
                <div class="panel-body">
                    <i class="far fa-circle-o-notch fa-spin"></i> Carregando...
                </div>
            </div>
        </div>
        <div id="divAcesso" class="tab-pane">
            <div class="panel">
			    <div class="panel-body">
			        <i class="far fa-circle-o-notch fa-spin"></i> Carregando...
                </div>
            </div>
        </div>
        <div id="divExtrato" class="tab-pane">
			<div class="panel">
                <div class="panel-body">
                    <i class="far fa-circle-o-notch fa-spin"></i> Carregando...
                </div>
            </div>
        </div>
        <div id="divCompartilharPront" class="tab-pane">
			<div class="panel">
                <div class="panel-body">
                    <i class="far fa-circle-o-notch fa-spin"></i> Carregando...
                </div>
            </div>
        </div>
    </div>
</div>
<!--#include file="Classes/Logs.asp"-->
<%
if session("Admin")=1 then
%>
<div class="tabbable panel">
    <div class="tab-content panel-body">
        <%=dadosCadastro("profissionais" , req("I"))%>
    </div>
</div>
<%
end if
%>
<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>

    const $coordsInput = $('#Coordenadas');

    var coords = $coordsInput.val();
    var isSelected = false;
    var tried = 0;

    if (coords) {
        const [latitude, longitude] = coords.split(',');
        pullMap({ latitude, longitude });
    }

    $coordsInput.on('keyup', function () {
        const changedCoords = $coordsInput.val();
        const coordsArray = changedCoords.split(',');

        $coordsInput.val(changedCoords.replace(' ', ''));

        if (coordsArray.length === 2) {
            const [latitude, longitude] = coordsArray;
            pullMap({ latitude, longitude });
        } else {
            $('#coords-iframe').remove();
        }
    });

    $coordsInput.on('focus', function () {
        if (tried < 2 && !isSelected) {
            getCoords()
                .then(coords => {
                    const { latitude, longitude } = coords;
                    pullMap({ latitude, longitude });
                    isSelected = true;
                })
                .catch(error => {
                    console.error(error);

                    new PNotify({
                        title: 'Erro de Geolocalização',
                        text: error,
                        type: 'danger',
                        delay: 6000
                    });

                    tried++;
                });
        }
    });
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

function pullMap(position) {
    const $coordsMap = $('#coords-map');
    const { latitude, longitude } = position;
    const googleKey = 'AIzaSyCz2FUHAQGogZ13ajRNE3UQBCfdo-igcDc';

    $('#coords-iframe').remove();

    $coordsMap.html(`
        <iframe 
            id="coords-iframe"
            src="https://www.google.com/maps/embed/v1/place?key=${googleKey}&q=${latitude},${longitude}"  
            style="border:0; height: 450; width: 100%;" 
            allowfullscreen="" 
            loading="lazy"
        >
        </iframe>
    `);
}

function getCoords() {
    return new Promise(function (resolve, reject) {
        if ('geolocation' in navigator) {
            // get current geolocation position
            navigator.geolocation.getCurrentPosition(
                // when allowed
                function (position) {
                    const { latitude, longitude } = position.coords;
                    resolve({ latitude, longitude });
                },
                // when not allowed
                function () {
                    reject('Você não permitiu o navegador acessar sua geolocalização.');
                }
            );
        } else {
            reject('Seu navegador não tem suporte para geolocalização.')
        }
    });
}

function esps(A, E){
    $.post("profissionaisespecialidades.asp?I=<%=req("I")%>&A="+A+"&E="+E, $("#frm").serialize(), function(data){
        $("#esps").html(data);
    });
}

<% if getConfig("ExibirProgramasDeSaude") = 1 and reg("id") <> "" then %>
// Chamada Ajax Programa Saúde
$(document).ready(function () {

    $("#block-programas-saude").html(`<div class="panel"><div class="panel-body"><i class="far fa-circle-o-notch fa-spin"></i> Carregando...</div></div>`);
    getUrl("health-programs/professional-view/<%=req("I") %>", {}, function(data) {
        $("#block-programas-saude").html(data);
    });

});
<% end if %>

</script>
<script src="assets/js/ace-elements.min.js"></script>
<script type="text/javascript">

<%
Parametros = "P="&req("P")&"&I="&req("I")&"&Col=Foto"
%>
function removeFoto(){
	if(confirm('Tem certeza de que deseja excluir esta imagem?')){
		$.ajax({
			type:"POST",
			url:"FotoUploadSave.asp?<%=Parametros%>&Action=Remove",
			success:function(data){
				$("#divDisplayUploadFoto").css("display", "block");
				$("#divDisplayFoto").css("display", "none");
				$("#avatarFoto").attr("src", "/uploads/<%=replace(session("Banco"), "clinic", "")%>/Perfil/");
				$("#Foto").ace_file_input('reset_input');
			}
		});
	}
}

	$(function() {
		var $form = $('#frm');
		var file_input = $form.find('input[type=file]');
		var upload_in_progress = false;

		file_input.ace_file_input({
			style : 'well',
			btn_choose : 'Sem foto',
			btn_change: null,
			droppable: true,
			thumbnail: 'large',

			before_remove: function() {
				if(upload_in_progress)
					return false;//if we are in the middle of uploading a file, don't allow resetting file input
				return true;
			},

			before_change: function(files, dropped) {
				var file = files[0];
				if(typeof file == "string") {//files is just a file name here (in browsers that don't support FileReader API)
					/*if(! (/\.(jpe?g|png|gif)$/i).test(file) ) {
						alert('Please select an image file!');
						return false;
					}*/
				}
				else {
					var type = $.trim(file.type);
					/*if( ( type.length > 0 && ! (/^image\/(jpe?g|png|gif)$/i).test(type) )
							|| ( type.length == 0 && ! (/\.(jpe?g|png|gif)$/i).test(file.name) )//for android's default browser!
						) {
							alert('Please select an image file!');
							return false;
						}

					if( file.size > 110000 ) {//~100Kb
						alert('File size should not exceed 100Kb!');
						return false;
					}*/
				}
	
				return true;
			}
		});
		
		$("#Foto").change(async function() {

		    await uploadProfilePic({
		        $elem: $("#Foto"),
		        userId: "<%=req("I")%>",
		        db: "<%= LicenseID %>",
		        table: 'profissionais',
		        content: file_input.data('ace_input_files')[0] ,
		        contentType: "form"
		    });

			if(!file_input.data('ace_input_files')) return false;//no files selected
		});
		
		$form.on('reset', function() {
			file_input.ace_file_input('reset_input');
		});


		if(location.protocol == 'file:') alert("For uploading to server, you should access this page using a webserver.");

	});
	

$(document).ready(function(){
	<%=chamaScript%>
        signature();
});

<%
if req("GT")="Permissoes" then
	%>
	$(document).ready(function(e) {
        $("#gtPermissoes").click();
    });
	<%
end if
%>
$("#ObsAgenda").ckeditor();

function selecionarTodasUnidades(cel){
 $("[name='Unidades']").prop('checked', cel)
}

function VisualizarEnvioDasAgendas() {
    openComponentsModal("ProfissionalEnvioAgenda.asp", {ProfissionalID:"<%=req("I")%>"}, "Envio das agendas", true)
}

$("#farmaceutico_auditor").change(()=>{
    document.getElementById('auditor').checked = false;
})
$("#auditor").change(()=>{
    document.getElementById('farmaceutico_auditor').checked = false;
})
</script>

<script src="src/imageUtil.js"></script>

<!--#include file="disconnect.asp"-->