<!--#include file="connect.asp"-->
<%
IF req("back") = "1" and session("FranqueadorOld") <> "" THEN
        session("NameUser")    = session("NameUserOld")
        session("Banco")    = session("BancoOld")
        session("User")     = session("UserOld")
        session("BancoOld") = ""
        session("UserOld")  = ""
        session("NameUserOld")  = ""
        session("Franqueador") = session("FranqueadorOld")
        response.Redirect("./?P=Home&Pers=1")
        response.end
END IF

IF req("to") <> "" and session("Franqueador") <> "" THEN
    set licencaUser     = db.execute("SELECT * FROM cliniccentral.licencasusuarios where LicencaID = "&req("to")&" AND Admin = 1 ORDER BY 1 DESC;")

    session("NameUserOld") = session("NameUser")
    session("BancoOld")    = session("Banco")
    session("UserOld")     = session("User")

    session("NameUser")    = licencaUser("Nome")
    session("Banco")       = "clinic"&req("to")
    session("User")        = licencaUser("id")
    session("FranqueadorOld") = session("Franqueador")
    session("Franqueador") = ""
    response.Redirect("./?P=Home&Pers=1")
    response.end
END IF
%>
<%
if req("NewID") <> "" and req("OldID") <> "" then
    db.execute("UPDATE sys_financialcompanyunits SET id = "&req("NewID")&" WHERE id = "&req("OldID"))
    response.end
end if

call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
%>
<script type="text/javascript">
    $(".crumb-active a").html("Cadastro de Unidade / Filial");
    $(".crumb-icon a span").attr("class", "far fa-hospital-o");
</script>


<style>
.loading-full{
    top: 0;
    left: 0;
    position: fixed;
    color: #DDDDDD;
    background: rgba(0,0,0,0.7);
    opacity: .7;
    width: 100%;
    height: 100%;
    z-index: 100000;
    align-items: center;
    justify-content: center;
    display: none;
}
</style>
<div class="loading-full">
    <div>
        <h2>Aguarde.</h2><h3> Estamos gerando uma nova licença para esta unidade.</h3>
        <div class="fa-4x text-center">
          <i class="far fa-spinner fa-spin"></i>
        </div>
    </div>
</div>

<br>

<div class="panel">
<div class="panel-body">
            <form method="post" id="frm" name="frm" action="save.asp">
                <input type="hidden" name="I" value="<%=req("I")%>" />
                <input type="hidden" name="P" value="<%=req("P")%>" />
                <div class="row">
                    <div class="col-md-10">
                    </div>
                    <div class="col-md-2">
        <% IF FALSE AND reg("sysActive")=1 and session("Franqueador") <> "" AND session("UserOld") = "" THEN %>
              <a href="sys_financialCompanyUnits.asp?to=<%=reg("id")%>" class="btn  btn-primary">
                  Logar na Licenca <i class="far fa-arrow-right"></i>
              </a>
        <% END IF %>
        <%
		if (reg("sysActive")=1 and aut(lcase(req("P"))&"A")=1) or (reg("sysActive")=0 and aut(lcase(req("P"))&"I")=1) then
		%>
                        <button class="btn  btn-primary" id="save">
                            <i class="far fa-save"></i> Salvar
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
                        <div class="col-md-2">
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
                        </div>
                        <%=quickField("text", "UnitName", "Razão Social #" & req("I"), 3, reg("UnitName"), "", "", " required")%>
                        <%=quickField("text", "NomeFantasia", "Nome Fantasia", 3, reg("NomeFantasia"), "", "", " required")%>
                        <%= quickField("text", "CNPJ", "CNPJ", 2, reg("CNPJ"), " input-mask-cnpj", "", "") %>
                        <%= quickField("text", "CNES", "CNES", 2, reg("CNES"), "", "", "") %>
                        <% IF ModoFranquia THEN %>
                            <%= quickField("simpleSelect", "RegiaoUnidade", "Região", 3, reg("RegiaoUnidade"), "SELECT * FROM unidadesregioes", "descricao", "") %>
                            <%= quickField("simpleSelect", "ResponsavelMedico", "Responsável Técnico", 3, reg("ResponsavelMedico"), "SELECT * FROM profissionais WHERE  sysActive = 1  order by 2", "NomeProfissional", "") %>
                            <%= quickField("simpleSelect", "ResponsavelOdontologico", "Responsável Odontológico", 3, reg("ResponsavelOdontologico"), "SELECT * FROM profissionais WHERE sysActive = 1  order by 2", "NomeProfissional", "") %>
                        <% END IF %>
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
<script src="../assets/js/ace-elements.min.js"></script>
<script type="text/javascript">
//js exclusivo avatar
<%
Parametros = "P="&req("P")&"&I="&req("I")&"&Col=Foto"
%>
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});


function gerarLicenca(id){

    $(".loading-full").css("display","flex");

    var formdata = new FormData();
    formdata.append("NomeContato", $("#NomeFantasia").val());
    formdata.append("Telefone", "(00) 0000-0000");
    formdata.append("Celular", "(00) 00000-0000");
    formdata.append("Email", "amorsaude"+id+"@amorsaude.com.br");
    formdata.append("senha1", "amorsaude123");
    formdata.append("senha2", "amorsaude123");
    formdata.append("ComoConheceu", "Cupom");
    formdata.append("Cupom", "AMORSAUDE");

    var requestOptions = {
      method: 'POST',
      body: formdata,
      redirect: 'follow'
    };

    fetch(domain+"/trial/start", requestOptions)
      .then(response => response.json())
      .then(result => {
          fetch(`sys_financialCompanyUnits.asp?NewID=${result.LicencaID}&OldID=${id}`)
          .then((r) => r.text())
          .then((r) => window.location.href = `?P=sys_financialcompanyunits&I=${result.LicencaID}&Pers=1`);
      })
      .catch(error => console.log('error', error));
}



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


		$("#Foto").change(function() {
			var submit_url = "FotoUpload.php?<%=Parametros%>&L=<%=replace(session("Banco"), "clinic", "")%>";
			if(!file_input.data('ace_input_files')) return false;//no files selected

			var deferred ;
			if( "FormData" in window ) {
				//for modern browsers that support FormData and uploading files via ajax
				var fd = new FormData($form.get(0));

				//if file has been drag&dropped , append it to FormData
				if(file_input.data('ace_input_method') == 'drop') {
					var files = file_input.data('ace_input_files');
					if(files && files.length > 0) {
						fd.append(file_input.attr('name'), files[0]);
						//to upload multiple files, the 'name' attribute should be something like this: myfile[]
					}
				}

				upload_in_progress = true;
				deferred = $.ajax({
					url: submit_url,
					type: $form.attr('method'),
					processData: false,
					contentType: false,
					dataType: 'json',
					data: fd,
					xhr: function() {
						var req = $.ajaxSettings.xhr();
						if (req && req.upload) {
							req.upload.addEventListener('progress', function(e) {
								if(e.lengthComputable) {
									var done = e.loaded || e.position, total = e.total || e.totalSize;
									var percent = parseInt((done/total)*100) + '%';
									//percentage of uploaded file
								}
							}, false);
						}
						return req;
					},
					beforeSend : function() {
					},
					success : function(data) {

					}
				})

			}
			else {
				//for older browsers that don't support FormData and uploading files via ajax
				//we use an iframe to upload the form(file) without leaving the page
				upload_in_progress = true;
				deferred = new $.Deferred

				var iframe_id = 'temporary-iframe-'+(new Date()).getTime()+'-'+(parseInt(Math.random()*1000));
				$form.after('<iframe id="'+iframe_id+'" name="'+iframe_id+'" frameborder="0" width="0" height="0" src="about:blank" style="position:absolute;z-index:-1;"></iframe>');
				$form.append('<input type="hidden" name="temporary-iframe-id" value="'+iframe_id+'" />');
				$form.next().data('deferrer' , deferred);//save the deferred object to the iframe
				$form.attr({'method' : 'POST', 'enctype' : 'multipart/form-data',
							'target':iframe_id, 'action':submit_url});

				$form.get(0).submit();

				//if we don't receive the response after 60 seconds, declare it as failed!
				setTimeout(function(){
					var iframe = document.getElementById(iframe_id);
					if(iframe != null) {
						iframe.src = "about:blank";
						$(iframe).remove();

						deferred.reject({'status':'fail','message':'Timeout!'});
					}
				} , 60000);
			}
			////////////////////////////
			deferred.done(function(result){
				upload_in_progress = false;

				if(result.status == 'OK') {
					if(result.resultado=="Inserido"){
						$("#avatarFoto").attr("src", result.url);
						$("#divDisplayUploadFoto").css("display", "none");
						$("#divDisplayFoto").css("display", "block");
					}
					//alert("File successfully saved. Thumbnail is: " + result.url)
				}
				else {
					alert("File not saved. " + result.message);
				}
			}).fail(function(res){
				upload_in_progress = true;
				alert("There was an error");
				//console.log(result.responseText);
			});

			deferred.promise();
			return false;

		});

		$form.on('reset', function() {
			file_input.ace_file_input('reset_input');
		});


		if(location.protocol == 'file:') alert("For uploading to server, you should access this page using a webserver.");

	});




</script>
<!--#include file="disconnect.asp"-->