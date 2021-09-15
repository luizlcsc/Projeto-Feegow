<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
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
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))

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
		chamaScript = "ajxContent('Horarios-1', "&req("I")*(-1)&", 1, 'divHorarios');"
	else
		chamaScript = "ajxContent('Horarios', "&req("I")*(-1)&", 1, 'divHorarios');"
	end if
	tabCadastro = ""
	tabHorarios = " in active"
end if
%>


<br />
<div class="panel">
    <div class="panel-body">
        <div class="tabbable">
            <div class="tab-content">
                <div id="divCadastroEquipamento" class="tab-pane<%=tabCadastro%>">




                    <form method="post" id="frm" name="frm" action="save.asp">
<%=header(req("P"), "Cadastro de Equipamento", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
                        <input type="hidden" name="I" value="<%=req("I")%>" />
                        <input type="hidden" name="P" value="<%=req("P")%>" />
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
                                        <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="far fa-trash"></i></button>
                                    </div>
                                </div>
                            </div>


                        </div>
                        <div class="col-md-10">
                            <div class="row">
                                <%=quickField("text", "NomeEquipamento", "Nome do Equipamento", 4, reg("NomeEquipamento"), "", "", " required")%>
                                <%=quickField("empresa", "UnidadeID", "Unidade", 3, reg("UnidadeID"), "", "", "")%>
                                <%=quickField("text", "Pacs_id", "Identificação no PACS", 2, reg("Pacs_id"), "", "", " ")%>
                                <div class="col-md-1 col-md-offset-2">
                                    <label>
                                        Ativo
                                        <br />
                                        <div class="switch round">
                                            <input type="checkbox" <% If reg("Ativo")="on" or isnull(reg("Ativo")) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo">
                                            <label for="Ativo">Label</label>
                                        </div>

                                    </label>
                                </div>
                            </div>
                                <hr class="short alt" />
                                <div class="row">
                                    <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 6, reg("Obs"), "", "", "") %>
                                </div>
                            </div>
                        </div>

                    </form>
                </div>
                <div id="divHorarios" class="tab-pane<%=tabHorarios%>">
			        Carregando...
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});


</script>

<script src="assets/js/ace-elements.min.js"></script>
<script type="text/javascript">
//js exclusivo avatar
<%
Parametros = "P="&req("P")&"&I="&req("I")&"&Col=Foto&L="& replace(session("Banco"), "clinic", "")
%>
function removeFoto(){
	if(confirm('Tem certeza de que deseja excluir esta imagem?')){
		$.ajax({
			type:"POST",
			url:"FotoUploadSave.asp?<%=Parametros%>&Action=Remove",
			success:function(data){
				$("#divDisplayUploadFoto").css("display", "block");
				$("#divDisplayFoto").css("display", "none");
				$("#avatarFoto").attr("src", "uploads/");
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
        		        table: 'equipamentos',
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
</script>

<!--#include file="disconnect.asp"-->