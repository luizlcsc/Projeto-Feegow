<%
Caminho = "https://clinic.feegow.com.br/uploads/"

if TipoCampoID=3 and ValorPadrao<>"" and not isnull(ValorPadrao) then
    EstiloImagem = "background-image: url(uploads/"&ValorPadrao&"); background-position: center center; background-repeat: no-repeat; background-size: contain;"
else
    EstiloImagem = ""
end if
%>

<li id="<%=CampoID%>" class="<%if TipoCampoID=13 then response.Write("caixaGrupo campo") else response.Write("campo") end if%>" data-row="<%=pTop%>" style="text-align:left; <%=EstiloImagem%>" data-col="<%=pLeft%>" data-sizex="<%=Colunas%>" data-sizey="<%=Linhas%>">
	<%if TipoCampoID<>3 and TipoCampoID<>12 and getConfig("LembreteFormulario")=1 then%><span class="lembrar hidden-print checkbox-custom checkbox-default"><i class="far fa-flag red"></i> <input class="postvalue lembrarme tbl" type="checkbox" data-campoid="<%=CampoID%>" id="lembrarme_<%=CampoID%>" value="<%=CampoID %>" name="lembrarme" <%if instr(LembrarmeS, "|"&CampoID&"|") then response.Write("checked") end if %> /><label for="lembrarme_<%=CampoID%>"> Lembrar-me disso</label></span><%end if%>
	<%
	  select case TipoCampoID
	  	case 1'Texto
			'response.Write("["&LadoALado&"]")
			if LadoALado="S" then
				%><table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td width="1%" class="cel_label" nowrap><label class="campoLabel"><%=RotuloCampo%></label></td><td width="99%" class="cel_input"><input tabindex="<%=Ordem%>" data-campoid="<%=CampoID%>" class="campoInput form-control" name="input_<%=CampoID%>" id="input_<%=CampoID%>" value="<%=ValorPadrao%>" type="text"></td></tr></table><%
			else
				%><label class="campoLabel"><%=RotuloCampo%></label><input tabindex="<%=Ordem%>" data-campoid="<%=CampoID%>" name="input_<%=CampoID%>" id="input_<%=CampoID%>" value="<%=ValorPadrao%>" class="campoInput form-control" type="text"><%
			end if
	  	case 16'CID-10 - usar a lógica do campo que auto-sugere
			'response.Write("["&LadoALado&"]")
			if LadoALado="S" then
				%><table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td width="1%" class="cel_label" nowrap><label class="campoLabel"><%=RotuloCampo%></label></td><td width="99%" class="cel_input"><input tabindex="<%=Ordem%>" data-campoid="<%=CampoID%>" class="campoInput form-control" name="input_<%=CampoID%>" id="input_<%=CampoID%>" value="<%=ValorPadrao%>" type="text"></td></tr></table><%
			else
				%><label class="campoLabel"><%=RotuloCampo%></label><input tabindex="<%=Ordem%>" data-campoid="<%=CampoID%>" name="input_<%=CampoID%>" id="input_<%=CampoID%>" value="<%=ValorPadrao%>" class="campoInput form-control" type="text"><%
			end if
	  	case 2'Data
			if LadoALado="S" then
				%><table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td width="1%" class="cel_label" nowrap><label class="campoLabel"><%=RotuloCampo%></label></td><td width="99%" class="cel_input"><div class="input-group"><input name="input_<%=CampoID%>" id="input_<%=CampoID%>" data-campoid="<%=CampoID%>" value="<%=ValorPadrao%>" tabindex="<%=Ordem%>" class="campoInput form-control date-picker input-mask-date" data-date-format="dd/mm/yyyy" type="text"><span class="input-group-addon"><i class="far fa-calendar bigger-110"></i></span></div></td></tr></table><%
			else
				%><label class="campoLabel"><%=RotuloCampo%></label><div class="input-group"><input tabindex="<%=Ordem%>" class="campoInput form-control date-picker input-mask-date" data-date-format="dd/mm/yyyy" name="input_<%=CampoID%>" id="input_<%=CampoID%>" data-campoid="<%=CampoID%>" value="<%=ValorPadrao%>" type="text"><span class="input-group-addon"><i class="far fa-calendar bigger-110"></i></span></div><%
			end if
	  	case 3'imagem
				%>
                <label class="campoLabel"><%=RotuloCampo%></label><br>
                <%
				if ValorPadrao<>"" and not isnull(ValorPadrao) then
					%>
                    <button onclick="return launchEditor('image<%=CampoID%>', '<%=Caminho & ValorPadrao %>');" type="button" class="btn btn-xs btn-default"><i class="far fa-edit"></i></button>
                    <%
				else
					%>
                    <div class="text-center" id="fotoFoto<%=CampoID%>">
                        <input type="file" class="fotoForm" name="Foto" data-campoid="<%=CampoID%>" id="id-input-file-<%=CampoID%>" />
				    </div>
                    <%
				end if
                    %>


<script type="text/javascript">
$("#img<%=CampoID%>").css('height', $("#fotoFoto<%=CampoID%>").closest("li").css('height') );

$(function() {
	var $form = $('#frm');
	var file_input = $form.find('#id-input-file-<%=CampoID%>');
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
				if( ( type.length > 0 && ! (/^image\/(jpe?g|png|gif)$/i).test(type) )
						|| ( type.length == 0 && ! (/\.(jpe?g|png|gif)$/i).test(file.name) )//for android's default browser!
					) {
						alert('Erro: Este tipo de arquivo não é uma imagem válida.');
						return false;
					}

				if( file.size > 3000000 ) {//~100Kb
					alert('Erro: O arquivo excede o tamanho máximo permitido (3MB).');
					return false;
				}
			}

			return true;
		}
	});
	
	
	$(this).change(function() {
		
		var submit_url = "FotoUploadForm.php?FPID="+$("#FormID").val()+"&CampoID=<%=CampoID%>";
		//alert( submit_url )
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
		}else {
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
				eval(result);
			}
		}).fail(function(res){
			upload_in_progress = true;
			alert("Erro ao postar imagem.");
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








                
                
                <%
	  	case 4'checkbox
			if Checado="S" then
				Separador = "<br /><br />"
			else
				Separador = "&nbsp;&nbsp;"
			end if
			%><label class="campoLabel"><%=RotuloCampo%></label><br /><%
				set checks = db.execute("select * from buiopcoescampos where CampoID="&CampoID)
				while not checks.eof
					%><span class="checkbox-custom"><input class="campoCheck postvalue" id="input_<%=CampoID%>_<%=checks("id") %>" data-campoid="<%=CampoID%>" name="input_<%=CampoID%>"<%if (checks("Selecionado")="S" and FormID="N") or (instr(ValorPadrao, "|"&checks("id")&"|")>0 and FormID<>"N") then%> checked<%end if%> value="|<%=checks("id")%>|" type="checkbox" /><label for="input_<%=CampoID%>_<%=checks("id") %>"><%=checks("Nome")%></label></span> <%=Separador%><%
				checks.movenext
				wend
				checks.close
				set checks = nothing
	  	case 5'radio
			if Checado="S" then
				Separador = "<br /><br />"
			else
				Separador = "&nbsp;&nbsp;"
			end if
			%><label class="campoLabel"><%=RotuloCampo%></label><br /><%
				set checks = db.execute("select * from buiopcoescampos where CampoID="&CampoID)
				while not checks.eof
					%><span class="radio-custom"><input class="campoInput postvalue" name="input_<%=CampoID%>" id="<%=CampoID%>_<%=checks("id") %>" data-campoid="<%=CampoID%>"<%if (checks("Selecionado")="S" and FormID="N") or (ValorPadrao=cstr(checks("id")) and FormID<>"N") then%> checked<%end if%> type="radio" value="<%=checks("id")%>" /><label for="<%=CampoID%>_<%=checks("id") %>"><%=checks("Nome")%></label></span> <%=Separador%><%
				checks.movenext
				wend
				checks.close
				set checks = nothing
	  	case 6'select
			if Checado="S" then
				Separador = "<br /><br />"
			else
				Separador = "&nbsp;&nbsp;"
			end if
			%><label class="campoLabel"><%=RotuloCampo%></label>
            	<br />
                <select class="campoInput form-control postvalue" name="input_<%=CampoID%>" id="input_<%=CampoID%>" data-campoid="<%=CampoID%>"><%
				set checks = db.execute("select * from buiopcoescampos where CampoID="&CampoID)
				while not checks.eof
					%><option value="<%=checks("id")%>"<% If (checks("Selecionado")="S" and FormID="N") or (ValorPadrao=cstr(checks("id")) and FormID<>"N") Then %> selected="selected"<% End If %>><%=checks("Nome")%></option><%
				checks.movenext
				wend
				checks.close
				set checks = nothing
				%></select><%
	  	case 8'textarea
			%><div style="padding-bottom:4px"><label class="campoLabel"><%=RotuloCampo%></label></div>

            <textarea class="campoInput form-control" id="input_<%=CampoID%>"<%if negadoX="S" then%> readonly <% End If %> data-campoid="<%=CampoID%>" name="input_<%=CampoID%>" tabindex="<%=Ordem%>"><%=ValorPadrao%></textarea>

            <!--div style="overflow-y:scroll" class=" memorando postvalue" onblur="alt()"></div-->
            <%
            'é exatamente a primeira opção de javascript abaixo, mas roda no fim da callnewform pra dar tempo do gridster fazer a altura. qualquer coisa, colocar timeout
            ckrender = ckrender & "$(function () {$('#input_"&CampoID&"').ckeditor({ height: $('#"&CampoID&"').innerHeight()-20, skin:'bootstrapck', enterMode: CKEDITOR.ENTER_BR, removePlugins: 'elementspath', resize_enabled: false, removePlugins: 'elementspath', toolbarCanCollapse : false }); });"

            %>
			<script type="text/javascript">
                /*
			    $(function () {
			        $('#input_<%=CampoID%>').ckeditor({
			            height: $("#<%=CampoID%>").innerHeight()-76,
			            enterMode: CKEDITOR.ENTER_BR,
			            removePlugins: "elementspath",
    			        resize_enabled: false,

    			        removePlugins: 'elementspath',
    			        toolbarCanCollapse : false,
    			        sharedSpaces: { top: 'tahighlightsTBdiv' }
			        });
			    });
                */

			    /*
                //quase funcionou
			    var id = 'input_<%=CampoID%>';
			    jQuery("#" + id).ckeditor({
			        height: $("#<%=CampoID%>").innerHeight(),
			        enterMode: CKEDITOR.ENTER_BR,
			        removePlugins: "elementspath",
			        resize_enabled: false,

			        removePlugins: 'elementspath',
			        toolbarCanCollapse: false,
			        sharedSpaces: { top: 'tahighlightsTBdiv' }
			    });
			    CKEDITOR.instances[id].on("instanceReady", function (e) {
			        jQuery("#cke_" + id + " [id$='_top']").hide();
			        this.on("focus", function () {
			            jQuery("#cke_" + id + " [id$='_top']").show();
			        });

			    });
                */

			</script>
            <%
	  	case 9'tabela
			%><label class="campoLabel"><%=RotuloCampo%></label>
    <input name="tblRem<%=CampoID %>" type="hidden" id="tblRem<%=CampoID %>" class="tbl" value="0" />
    <table class="table table-condensed table-bordered table-hover"><thead><%
			sqlTit = "select * from buitabelastitulos where CampoID="&CampoID
			set pTit = db.execute(sqlTit)
			if pTit.EOF then
				insTit = "insert into buitabelastitulos (CampoID, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20) values ("&CampoID&", 'Título 1', 'Título 2', 'Título 3', 'Título 4', 'Título 5', 'Título 6', 'Título 7', 'Título 8', 'Título 9', 'Título 10', 'Título 11', 'Título 12', 'Título 13', 'Título 14', 'Título 15', 'Título 16', 'Título 17', 'Título 18', 'Título 19', 'Título 20')"
				'response.Write(insTit)
				db_execute(insTit)
				set pTit = db.execute(sqlTit)
			end if

			contaLargura = 0
			if isnull(Largura) or Largura="" then
				Largura = 7
			end if
			while contaLargura<cint(Largura) and contaLargura<20
				contaLargura = contaLargura+1
				%><th><%=pTit("c"&contaLargura)%></th><%
			wend

			%><th class="hidden-print" width="1%"><button type="button" onClick="fRow(<%=CampoID%>, 0, 'I'); alt();" class="btn btn-xs btn-primary btn-20 postvalue"><i class="far fa-plus"></i></button></th></thead><tbody id="tb_<%=CampoID%>"><%
			if FormID="N" then
				set pMod = db.execute("select * from buitabelasmodelos where CampoID="&CampoID)
			else
				set pMod = db.execute("select * from buitabelasvalores where CampoID="&CampoID&" and FormPreenchidoID="&FormID&" order by id")
			end if

            %>
            
                <tr class="hidden" id="lmodel<%=CampoID %>">
                <%
                contaLargura = 0
				while contaLargura<cint(Largura) and contaLargura<20
					contaLargura = contaLargura+1
                    %>
                    <td><input type="text" name="<%=CampoID &"_"& contaLargura  &"_RPL" %>" id="<%=CampoID &"_"& contaLargura  &"_RPL" %>" class="campoInput tbl" /> </td>
                    <%
                wend
                %>
                    <td class="hidden-print">
                        <input type="hidden" class="tbl tblH<%=CampoID %>" name="tblH<%=CampoID %>" id="tblH<%=CampoID &"_RPL" %>" value="RPL" />
                        <button type="button" class="btn btn-xs btn-danger btn-20 postvalue" onClick="fRow(<%=CampoID%>, 'RPL' , 'X')"><i class="far fa-remove"></i></button>
				    </td>
                </tr>

            <%

			while not pMod.EOF
				%><tr id="r<%=CampoID &"_"& pMod("id") %>"><%
				contaLargura = 0
				while contaLargura<cint(Largura) and contaLargura<20
					contaLargura = contaLargura+1
					%><td><input type="text" name="<%=CampoID &"_"& contaLargura  &"_"& pMod("id") %>" id="<%=CampoID &"_"& contaLargura  &"_"& pMod("id") %>" class="campoInput tbl" value="<%=pMod("c"&contaLargura)%>" /></td><%
				wend
				%><td class="hidden-print">
                    <input type="hidden" class="tbl tblH<%=CampoID %>" name="tblH<%=CampoID %>" id="tblH<%=CampoID &"_"& pmod("id") %>" value="<%=pMod("id") %>" />
                    <button type="button" class="btn btn-xs btn-danger btn-20 postvalue" onClick="fRow(<%=CampoID%>, <%=pMod("id") %>, 'X')"><i class="far fa-remove"></i></button>
				  </td></tr><%
			pMod.movenext
			wend
			pMod.close
			set pMod = nothing
			%></tbody></table><%
		case 10
			%><h2><%=RotuloCampo%></h2><%
			if Checado="" then response.Write("<hr class='m5'>") end if
			response.Write(Texto)
		case 12
			%><iframe width="100%" id="frm<%=CampoID%>" name="frm<%=CampoID%>" src="audiometria.asp?ModeloID=<%=ModeloID%>&FormID=<%=FormID%>&PacienteID=<%=PacienteID%>&field=<%=CampoID%>" frameborder="0" scrolling="no" height="100%" style="width:100%;height:100%"></iframe><%
		case 13
			if 1=1 then
				strGrupos = strGrupos&"|"&CampoID
				%><div id="demo-<%=CampoID%>" class="gridster"><ul><%
				%><!--#include file="chamaFormsCompiladorCampoPreenchido.asp"--></ul></div>
				<%
			else
				%><iframe id="frm<%=CampoID%>" name="frm<%=CampoID%>" frameborder="0" scrolling="no" src="subGrid.asp?GrupoID=<%=CampoID%>&FormID=<%=I%>" style="width:100%;height:100%"></iframe><%
			end if
		case 14
			%><div style="position:absolute; bottom:0; right:0"><button type="button" class="btn btn-sm btn-primary hidden-print" onClick="editCurva(<%= CampoID %>, '<%= FormID %>')"><i class="far fa-edit"></i> EDITAR DADOS</button></div><iframe id="frm<%=CampoID%>" name="frm<%=CampoID%>" frameborder="0" scrolling="no" src="Curva.asp?CampoID=<%=CampoID%>&FormPID=<%=FormID%>" style="width:100%;height:100%"></iframe><%
		case 15
'			if isnumeric(ValorPadrao) then
'				set pcvp = db.execute("select * from buicamposforms where id="&ValorPadrao)
'				if not pcvp.eof then
					%>
					<script>
						$("input[name=input_<%=CampoAssociado%>]").keyup(function(){
							$("#frm<%=CampoID%>").attr("src", "CodBarras.asp?NumeroCodigo=" + $(this).val() );
						});
					</script>
					<%
'				end if
'			end if
			%>
            <iframe id="frm<%=CampoID%>" name="frm<%=CampoID%>" frameborder="0" scrolling="no" src="CodBarras.asp?NumeroCodigo=<%=ValorPadrao%>" style="width:100%;height:100%"></iframe><%
	  end select
	  %></li>