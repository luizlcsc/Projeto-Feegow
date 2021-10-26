<style>
.listaUnidades{
	list-style-type:none;
	margin-left:10px;
}
.listaUnidades li span{
	font-size:12px!important;
}
</style>
<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
Profissionais = reg("Profissionais")
regUnidades = reg("unidades")

if regUnidades&"" = "" then
    regUnidades = "|0|"
end if
%>
	<%=header(req("P"), "Cadastro de Funcionário", reg("sysActive"), req("I"), req("Pers"), "Follow")%>

<br />
<div class="tabbable">
    <div class="tab-content">
        <div id="divCadastroFuncionario" class="tab-pane in active panel">
            <form method="post" id="frm" name="frm" action="save.asp">
                <div class="panel-heading">
                    <span class="panel-title">
                        Dados Principais
                    </span>
                    <span class="panel-controls">
                        <%
		                if (reg("sysActive")=1 and aut(lcase(req("P"))&"A")=1) or (reg("sysActive")=0 and aut(lcase(req("P"))&"I")=1) then
		                    %>
                            <button class="btn btn-primary btn-sm" id="save"> <i class="far fa-save"></i> Salvar </button>
		                    <%
		                end if
		                %>
                    </span>
                </div>
                <div class="panel-body">
                    <input type="hidden" name="I" value="<%=req("I")%>" />
                    <input type="hidden" name="P" value="<%=req("P")%>" />
                    <div class="row">
                        <div class="col-md-10">
                        </div>
                        <div class="col-md-2">
                        </div>
                    </div>

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
                                    <img id="avatarFoto" src="<%= arqEx(reg("Foto"), "Perfil") %>" class="img-thumbnail" width="100%" />
                                    <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="far fa-trash"></i></button>
                                </div>
                            </div>
                        </div>
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
                    </div>
                    <div class="col-md-10">
                        <div class="row">
                            <%=quickField("text", "NomeFuncionario", "Nome", 5, reg("NomeFuncionario"), "", "", " required")%>
                            <%=quickField("simpleSelect", "Sexo", "Sexo", 2, reg("Sexo"), "select * from Sexo where sysActive=1", "NomeSexo", "")%>
                            <%=quickField("datepicker", "Nascimento", "Nascimento", 3, reg("Nascimento"), "input-mask-date", "", "")%>
                           	<%
							'não permitir o usuario inativar ele mesmo
                            if session("idInTable")&"" = req("I")&"" and (session("Table")&"" = req("P")&"") then
								hideInactive = "hidden"
							end if
							%>
						    <div class="col-md-2 <%=hideInactive %>">
                                <label for="Ativo">Ativo</label><br />
                                    <div class="switch round">
                                        <input <% If reg("Ativo")="on" or isnull(reg("Ativo")) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo" type="checkbox" />
                                    	<label for="Ativo"></label>
                                    </div>
                            </div>
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
                            <%= quickField("text", "Estado", "Estado", 2, reg("estado"), "", "", "") %>
                            <%= quickField("simpleSelect", "Pais", "Pa&iacute;s", 2, reg("Pais"), "select * from Paises where sysActive=1 order by NomePais", "NomePais", "") %>
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
                            <%= quickField("text", "CPF", "CPF", 3, reg("CPF"), " input-mask-cpf", "", " required") %>
                            <%= quickField("text", "RG", "RG", 3, reg("RG"), "", "", "") %>
                                <%=quickfield("simpleSelect", "CentroCustoID", "Centro de Custo", 3, reg("CentroCustoID"), "select * from centrocusto where sysActive=1 order by NomeCentroCusto", "NomeCentroCusto", "") %>
                            <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 3, reg("Obs"), "", "", "") %>
                        </div>
                        <%if session("admin")=1 then%>
                            <hr class="short alt" />
                            <div class="row col-md-12">
                                <%=quickField("multiple", "Profissionais", "Acesso as agendas dos profissionais", 4, Profissionais, "select id, if(not isnull(NomeSocial) and NomeSocial<>'', NomeSocial, NomeProfissional) NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
                            </div>
                        <%end if%>
                        </div>
                    </div>
                </div>
            </form>
        </div>


        <div id="divPermissoes" class="tab-pane">
			<!--#include file="unavailable.asp"-->
        </div>
        <div id="divAcesso" class="tab-pane">
			<!--#include file="unavailable.asp"-->
        </div>
		<div class="tab-pane" id="divCadastroCargo">
            Carregando...
        </div>
        <div class="tab-pane" id="divCadastroDepartamento">
            Carregando...
        </div>
        <div class="tab-pane" id="divCadastroFuncoes">
            Carregando...
        </div>
        <div class="tab-pane" id="divCadastroAgenciaintegradora">
            Carregando...
        </div>
    </div>
</div>
<!--#include file="Classes/Logs.asp"-->
<%
if session("Admin")=1 then
%>
<div class="tabbable panel">
    <div class="tab-content panel-body">
        <%=dadosCadastro("funcionarios" , req("I"))%>
    </div>
</div>
<%
end if
%>
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
<script src="../assets/js/ace-elements.min.js"></script>
<script type="text/javascript">
//js exclusivo avatar
<%
Parametros = "P="&req("P")&"&I="&req("I")&"&Col=Foto"
%>

function removeFoto(){
	if(confirm('Tem certeza de que deseja excluir esta imagem?'))
	{
		$.ajax(
		    {
			    type:"POST",
			    url:"FotoUploadSave.asp?<%=Parametros%>&Action=Remove",
			        success:function(data){
				        $("#divDisplayUploadFoto").css("display", "block");
                        $("#divDisplayFoto").css("display", "none");
                        $("#avatarFoto").attr("src", "/uploads/");
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
        		        table: 'funcionarios',
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
<%
if req("GT")="Permissoes" then
	%>
	$(document).ready(function(e) {
        $("#gtPermissoes").click();
    });
	<%
end if
%>

function selecionarTodasUnidades(cel){
 $("[name='Unidades']").prop('checked', cel)
}

</script>

<!--#include file="disconnect.asp"-->