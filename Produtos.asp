<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%

call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("select * from "&request.QueryString("P")&" where id="&request.QueryString("I"))

if reg("Foto")="" or isnull(reg("Foto")) then
	divDisplayUploadFoto = "block"
	divDisplayFoto = "none"
else
	divDisplayUploadFoto = "none"
	divDisplayFoto = "block"
end if

if reg("sysActive")=0 then
	disabled = " disabled=""disabled"""
end if

if 0 then
    set oldLanctos = db.execute("select id, QuantidadeTotal, EntSai from estoquelancamentos where isnull(PosicaoE) and ProdutoID="& req("I") &" order by id")
    while not oldLanctos.eof
        posicaoAnte = ""
        QuantidadeTotal = oldLanctos("QuantidadeTotal")
        EntSai = oldLanctos("EntSai")
        set lanc = db.execute("select distinct Validade, Lote from estoquelancamentos where ProdutoID="&req("I")&" and id<"& oldLanctos("id"))
        while not lanc.eof
            Quantidade = quantidadeEstoqueIMPORT(req("I"), lanc("Lote"), lanc("Validade"), oldLanctos("id"))
            if Quantidade>0 then
                if isnull(lanc("Validade")) then
                    sqlValidade = ""
                else
                    sqlValidade = " and Validade="& mydatenull(lanc("Validade"))
                end if
                set vcaPosicao = db.execute("select id, Quantidade from estoqueposicao where importado=1 and ProdutoID="&req("I")&" and TipoUnidade='U' and Lote like '"&lanc("Lote")&"'"& sqlValidade)
                if EntSai="E" then
                    QuantidadeFinal = Quantidade + QuantidadeTotal
                else
                    QuantidadeFinal = Quantidade - QuantidadeTotal
                end if
                if vcaPosicao.eof then
                    db_execute("insert into estoqueposicao (ProdutoID, Quantidade, TipoUnidade, LocalizacaoID, Lote, Validade, ValorPosicao, importado) values ("&req("I")&", "&treatvalnull( QuantidadeFinal )&", 'U', 0, '"&lanc("Lote")&"', "&mydatenull(lanc("Validade"))&", 0, 1)")
                    set pultPos = db.execute("select id from estoqueposicao order by id desc limit 1")
                    PosicaoID = pultPos("id")
                else
                    PosicaoID = vcaPosicao("id")
                    db_execute("update estoqueposicao set Quantidade="&treatvalnull( QuantidadeFinal )&" where id="& PosicaoID)
                end if
                posicaoAnte = posicaoAnte & PosicaoID &"="& treatval(Quantidade) &"|0, "
            end if
        lanc.movenext
        wend
        lanc.close
        set lanc = nothing
        if posicaoAnte<>"" then
            posicaoAnte = left(posicaoAnte, len(posicaoAnte)-2)
            db_execute("update estoquelancamentos set posicaoAnte='"&posicaoAnte&"' where id="& oldLanctos("id"))
        end if
    oldLanctos.movenext
    wend
    oldLanctos.close
    set oldLanctos=nothing
    'falta atualizar posicaoE e posicaoS nos lancamentos old
end if

%>

<br />
<div class="tabbable panel">
    <div class="tab-content panel-body">
        <div id="divCadastroProduto" class="tab-pane in active">




            <form method="post" id="frm" name="frm" action="save.asp">
                <iframe align="middle" class="hidden" id="CodBarras" name="CodBarras" src="about:blank" width="100%" height="110"></iframe>
                
                <%=header(req("P"), "Produto", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
                <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
                <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />
                <div class="row">
                    <div class="col-md-2">
                        <div class="row">
                            <div class="col-md-12" id="divAvatar">
                                <div id="divDisplayUploadFoto" style="display: <%=divDisplayUploadFoto%>">
                                    <input type="file" name="Foto" id="Foto" />
                                </div>
                                <div id="divDisplayFoto" style="display: <%= divDisplayFoto %>">
                                    <img id="avatarFoto" src="<%=arqEx(reg("Foto"), "Perfil")%>" class="img-thumbnail" width="100%" />
                                    <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position: absolute; left: 18px; bottom: 6px;"><i class="fa fa-trash"></i></button>
                                </div>
                            </div>
                        </div>
                        <br />
                        <div class="row">
                            <%=quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 12, reg("Obs"), "", "", "")%>
                        </div>
                    </div>
                    <div class="col-md-10">
                        <div class="row">
                            <%=quickField("text", "NomeProduto", "Nome do Produto <code>#"& reg("id") &"</code>", 4, reg("NomeProduto"), "", "", " required")%>
                            <%=quickField("text", "Codigo", "C&oacute;digo", 2, reg("Codigo"), "", "", "")%>
                            <div class="col-md-3">
                                <%= selectInsert("Categoria", "CategoriaID", reg("CategoriaID"), "produtoscategorias", "NomeCategoria", "", "", "") %>
                            </div>
                            <div class="col-md-3">
                                <%= selectInsert("Fabricante", "FabricanteID", reg("FabricanteID"), "produtosfabricantes", "NomeFabricante", "", "", "") %>
                            </div>
                        </div>
                        <br />
                        <div class="row">
                            <%=quickField("text", "ApresentacaoNome", "Apresenta&ccedil;&atilde;o", 2, reg("ApresentacaoNome"), "", "", " placeholder=""Ex.: caixa, garrafa..."" required")%>
                            <%
						ApresentacaoQuantidade = reg("ApresentacaoQuantidade")
						if not isnull(ApresentacaoQuantidade) and not ApresentacaoQuantidade="" and isnumeric(ApresentacaoQuantidade) then
							ApresentacaoQuantidade = formatnumber(ApresentacaoQuantidade,2)
						end if
                            %>
                            <%=quickField("text", "ApresentacaoQuantidade", "Contendo", 2, ApresentacaoQuantidade, " input-mask-brl text-right", "", " placeholder=""1,00"" required")%>
                            <%=quickField("simpleSelect", "ApresentacaoUnidade", "Unidade", 2, reg("ApresentacaoUnidade"), "select * from cliniccentral.tissunidademedida order by Descricao", "Descricao", " required empty")%>
                            <div class="col-md-3">
                                <%= selectInsert("Localiza&ccedil;&atilde;o Padrão", "LocalizacaoID", reg("LocalizacaoID"), "produtoslocalizacoes", "NomeLocalizacao", "", "", "") %>
                            </div>
                            <%=quickField("simpleSelect", "CD", "CD", 3, reg("CD"), "select * from cliniccentral.tisscd order by Descricao", "Descricao", "")%>
                        </div>
                        <br />

                        <div class="row">
                            <%=quickField("text", "EstoqueMinimo", "Estoque M&iacute;nimo", 2, fn(reg("EstoqueMinimo")), " input-mask-brl text-right", "", "")%>
                            <%=quickfield("simpleSelect", "EstoqueMinimoTipo", "&nbsp;", 2, reg("EstoqueMinimoTipo"), "select 'U' id, 'Unidade' Descricao UNION ALL select 'C', 'Conjunto'", "Descricao", "no-select2 semVazio") %>



                                    <%=quickField("currency", "PrecoCompra", "Pre&ccedil;o Médio de Compra", 2, reg("PrecoCompra"), "", "", "")%>
                                    <div class="col-md-2">
                                        <br />
                                        <div class="radio-custom radio-system">
                                            <input type="radio" name="TipoCompra" value="C" id="TipoCompraC" <% If reg("TipoCompra")="C" Then %> checked="checked" <% End If %> /><label id="lblApresentacaoNomeC" for="TipoCompraC"> por conjunto</label></div>
                                        
                                        <div class="radio-custom radio-system">
                                            <input type="radio" name="TipoCompra" value="U" id="TipoCompraU" <% If reg("TipoCompra")="U" Then %> checked="checked" <% End If %> /><label id="lblApresentacaoUnidadeC" for="TipoCompraU"> por unidade</label></div>
                                    </div>
                                    <%=quickField("currency", "PrecoVenda", "Pre&ccedil;o Médio de Venda", 2, reg("PrecoVenda"), "", "", "")%>
                                    <div class="col-md-2">
                                        <br />
                                        <div class="radio-custom radio-alert">
                                            <input type="radio" name="TipoVenda" id="TipoVendaC" value="C" <% If reg("TipoVenda")="C" Then %> checked="checked" <% End If %> /><label id="lblApresentacaoNomeV" for="TipoVendaC"> por conjunto</label></div>
                                        
                                        <div class="radio-custom radio-alert">
                                            <input type="radio" name="TipoVenda" id="TipoVendaU" value="U" <% If reg("TipoVenda")="U" Then %> checked="checked" <% End If %> /><label id="lblApresentacaoUnidadeV" for="TipoVendaU"> por unidade</label></div>
                                    </div>




                        </div>
                        <br>
                        <%if aut("|produtosI|")=1 OR aut("|produtosA|")=1 then%>
                            <div class="row">
                                <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="PermitirSaida" id="PermitirSaida" value="S" class="ace" <% If reg("PermitirSaida")="S" Then %> checked="checked" <% End If %> />
                                <label for="PermitirSaida">Permitir saída do produto pelo cadastro</label></div>
                            </div>
                        <%end if%>
                    </div>
                </div>
                <hr class="short alt" />

				<%
				set uii = db.execute("select el.Valor, el.TipoUnidade UC from estoquelancamentos el WHERE el.ProdutoID="& req("I") &" ORDER BY el.sysDate desc LIMIT 1")
				if not uii.eof then
					if uii("UC")="C" then
						descUC = "conjunto"
					else
						descUC = "unidade"
					end if
					%>
					<div class="alert alert-info">
						Última compra: R$ <%= fn(uii("Valor")) %>/<%= descUC %>

						<% if aut("contasapagar")=1 and false then %>
							<a target="_blank" href="./?P=Invoice&Pers=1&T=D&I=<%= uii("InvoiceID") %>" class="btn btn-xs btn-default"><i class="fa fa-eye"></i></a>
						<% end if %>
					</div>
					<%
				end if

				%>

               <div class="row">
                    <div class="col-md-12">
                        <div class="row">
                                    <div class="col-md-12" id="ProdutosPosicao">

                                        <%server.Execute("EstoquePosicao.asp")%>
                                    </div>
                        </div>

                    </div>
                </div>
            </form>
        </div>
        <div id="divLancamentos" class="tab-pane">
            Carregando...
        </div>
    </div>
</div>
<script type="text/javascript">

    function printEtiqueta(ProdutoID) {
        $.post("printEtiqueta.asp?ProdutoID="+ ProdutoID, $(".eti").serialize(), function (data) {
            $("#modal-table").modal("show");
            $(".modal-content").html(data);
        });
    }



    $(document).ready(function(e) {
        <%call formSave("frm", "save", "$('.btnLancto').removeAttr('disabled');")%>

        <%
        if req("BaixarPosicao")<>"" then
        %>
setTimeout(function() {
    lancar('<%=req("I")%>', 'S', '', '', '<%=req("BaixarPosicao")%>', '', '', );
}, 700);
        <%
        end if
        %>
        });


    function lancar(P, T, L, V, PosicaoID){
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.ajax({
            type:"POST",
            url:"EstoqueLancamento.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&PosicaoID="+PosicaoID,
            success: function(data){
                setTimeout(function(){
                    $("#modal").html(data);
                }, 500);
            }
        });
    }
    function dividir(P, T, L, V, PosicaoID){
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.ajax({
            type:"POST",
            url:"EstoqueDist.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&PosicaoID="+PosicaoID,
            success: function(data){
                setTimeout(function(){
                    $("#modal").html(data);
                }, 500);
            }
        });
    }


    function atualizaLanctos(){
        $.ajax({
            type:"GET",
            url:"EstoquePosicao.asp?I=<%=request.QueryString("I")%>",
            success: function(data){
                $("#ProdutosPosicao").html(data);
            }
    });
    }



   $("#Codigo").on("keyup", function(){
        $("#CodBarras").removeClass("hidden");
        $("#CodBarras").attr("src", "CodBarras.asp?NumeroCodigo="+ $(this).val() );
    });















</script>

<script type="text/javascript">


function lbl(){
    if($("#ApresentacaoNome").val()==""){
        var ApresentacaoNome = "Conjunto";
    }else{
        var ApresentacaoNome = $("#ApresentacaoNome").val()+" (A)";
    }
    $("#lblApresentacaoNomeC, #lblApresentacaoNomeV").html("por "+ ApresentacaoNome);
    $("#EstoqueMinimoTipo option[value=C]").html(ApresentacaoNome);
    if($("#ApresentacaoUnidade").val()=="" || $("#ApresentacaoUnidade").val()=="0"){
        var ApresentacaoUnidade = "Unidade";
    }else{
        var ApresentacaoUnidade = $("#ApresentacaoUnidade option:selected").text().substring(5, 16)+" (U)";
    }
    $("#lblApresentacaoUnidadeC, #lblApresentacaoUnidadeV").html("por "+ ApresentacaoUnidade);
    $("#EstoqueMinimoTipo option[value=U]").html(ApresentacaoUnidade);
}

$("#ApresentacaoNome, #ApresentacaoUnidade").on("keyup change", function(){
    lbl();
});

lbl();

    //js exclusivo avatar
<%
    Parametros = "P="&request.QueryString("P")&"&I="&request.QueryString("I")&"&Col=Foto&L="& replace(session("Banco"), "clinic", "")

    %>
    function removeFoto(){
        if(confirm('Tem certeza de que deseja excluir esta imagem?')){
            $.ajax({
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
		
		
        $("#Foto").change(function() {
            var submit_url = "FotoUpload.php?<%=Parametros%>";
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
                $form.after('<iframe id="'+iframe_id+'" name="'+iframe_id+'" frameborder="0" width="0" height="0" src="about:blank" style="position:absolute; z-index:-1;"></iframe>');
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
