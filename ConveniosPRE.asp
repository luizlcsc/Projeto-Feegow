<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="modal.asp"-->
<%
call insertRedir("Convenios", req("I"))
set reg = db.execute("select * from convenios where id="&req("I"))


%>

<%=header("Convenios", "Cadastro de Convênio", reg("sysActive"), req("I"), req("Pers"), "Follow")%>

<br />
<div class="tabbable panel">
    <div class="tab-content panel-body">
        <div id="divCadastroConvenio" class="tab-pane in active">




            <form method="post" id="frm" name="frm" action="save.asp">


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
                                <div id="divDisplayUploadFoto" style="display: <%=divDisplayUploadFoto%>">
                                    <input type="file" name="Foto" id="Foto" />
                                </div>
                                <div id="divDisplayFoto" style="display: <%= divDisplayFoto %>">
                                    <img id="avatarFoto" src="<%=arqEx(reg("Foto"), "Perfil")%>" class="img-thumbnail" width="100%" />
                                    <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position: absolute; left: 18px; bottom: 6px;"><i class="far fa-trash"></i></button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-10">
                        <div class="row">
                            <%=quickField("text", "NomeConvenio", "Nome", 4, reg("NomeConvenio"), "", "", " required")%>
                            <%=quickField("text", "RazaoSocial", "Raz&atilde;o Social", 4, reg("RazaoSocial"), "", "", "")%>
                            <%= quickField("text", "CNPJ", "CNPJ", 3, reg("CNPJ"), " input-mask-cnpj", "", "") %>
                             <div class="col-md-1">
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
                        <div class="row">
                            <%=quickField("text", "RegistroANS", "Registro na ANS", 2, reg("RegistroANS"), "", "", "")%>
                            <%'=quickField("text", "NumeroContrato", "C&oacute;digo na Operadora", 3, reg("NumeroContrato"), "", "", "")%>
                            <%= quickField("text", "RetornoConsulta", "Retorno Consulta", 2, reg("RetornoConsulta"), "", "", " placeholder='Dias'") %>
                            <%'= quickField("text", "FaturaAtual", "Fatura Atual", 2, reg("FaturaAtual"), "", "", " placeholder='N&uacute;mero'") %>

                            <%= quickField("simpleSelect", "VersaoTISS", "Versão da TISS", 2, reg("VersaoTISS"), "select * from cliniccentral.tissversao", "Versao", "") %>


                            <%'= quickField("contratado", "Contratado", "Contratado", 4, reg("Contratado"), "", "", "") %>
                            <%'= quickField("simpleSelect", "ContaRecebimento", "Conta para Recebimento", 4, reg("ContaRecebimento"), "select * from sys_financialcurrentaccounts where AccountType=2 order by AccountName", "AccountName", "") %>
                            <%= quickField("text", "NumeroGuiaAtual", "Número da Guia Atual", 3, reg("NumeroGuiaAtual"), "", "", "") %>
                            <%=quickField("empresaMultiIgnore", "Unidades", "Limitar Unidades", 3, reg("Unidades"), "", "", "")%>
                        </div>
                    </div>
                </div>
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
                </div>
                <div class="row">
                    <%= quickField("phone", "Telefone", "Telefone", 3, reg("Telefone"), "", "", "") %>
                    <%= quickField("phone", "Fax", "Fax", 3, reg("Fax"), "", "", "") %>
                    <%= quickField("email", "Email", "E-mail", 4, reg("email"), "", "", "") %>
                    <%= quickField("text", "Contato", "Pessoa de Contato", 2, reg("Contato"), "", "", "") %>
                </div>
                <hr class="short alt" />
                <div class="row">
                    <%= quickField("number", "segundoProcedimento", "% do 2&deg; Procedimento", 2, reg("segundoProcedimento"), "", "", "") %>
                    <%= quickField("number", "terceiroProcedimento", "% do 3&deg; Procedimento", 2, reg("terceiroProcedimento"), "", "", "") %>
                    <%= quickField("number", "quartoProcedimento", "% do 4&deg; Procedimento", 2, reg("quartoProcedimento"), "", "", "") %>
                </div>
                <div class="row mt15">
                    <%= quickField("simpleSelect", "unidadeCalculo", "Unidade de Cálculo", 2, reg("unidadeCalculo"), "select 'R$' id, 'R$' Unidade UNION select 'CH', 'CH'", "Unidade", " semVazio no-select2") %>
                    <%= quickField("currency", "ValorCH", "Valor do CH", 2, reg("ValorCH"), " sql-mask-4-digits " , "", "") %>
                    <%= quickField("currency", "ValorUCO", "Valor da UCO", 2, reg("ValorUCO"), " sql-mask-4-digits " , "", "") %>
                    <%= quickField("currency", "ValorFilme", "Valor do Filme", 2, reg("ValorFilme"), "", "", "") %>
                </div>
                <hr class="short alt" />
                <h4>Tabelas Padrão</h4>
                <div class="row">
                    <%= quickField("simpleSelect", "TabelaPadrao", "Procedimentos", 2, reg("TabelaPadrao"), "select * from tisstabelas order by descricao", "descricao", " no-select2 ") %>
                    <%= quickField("simpleSelect", "TabelaPadraoMateriais", "Materiais", 2, reg("TabelaPadraoMateriais"), "select * from cliniccentral.tabelasprocedimentos order by codigo", "descricao", " no-select2 semVazio ") %>
                    <%= quickField("simpleSelect", "TabelaPadraoMedicamentos", "Medicamentos", 2, reg("TabelaPadraoMedicamentos"), "select * from cliniccentral.tabelasprocedimentos order by codigo", "descricao", " no-select2 semVazio ") %>
                    <%= quickField("simpleSelect", "TabelaPadraoTaxas", "Taxas", 2, reg("TabelaPadraoTaxas"), "select * from cliniccentral.tabelasprocedimentos order by codigo", "descricao", " no-select2 semVazio ") %>
                    <%= quickField("simpleSelect", "TabelaPadraoFilmes", "Filmes", 2, reg("TabelaPadraoFilmes"), "select * from cliniccentral.tabelasprocedimentos order by codigo", "descricao", " no-select2 semVazio ") %>
                    <%= quickField("simpleSelect", "TabelaPorte", "Tabela de Portes", 2, reg("TabelaPorte"), "select * from cliniccentral.tabelasportes order by Descricao", "Descricao", " no-select2 ") %>
                </div>
                <div class="row">
                    <div class="col-md-12"><br>
                        <%call Subform("contratosconvenio", "ConvenioID", req("I"), "frm")%>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <%call Subform("ConveniosPlanos", "ConvenioID", req("I"), "frm")%>
                    </div>
                </div>
                <div class="row">
                    <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 12, reg("Obs"), "", "", "") %>
                </div>
              <button class="hidden" id="save" type="submit"></button>

            </form>
        </div>
        <div id="divWS" class="tab-pane">
            <form id="WS" name="WS" method="post" action="">
                <table class="table table-striped table-condensed">
                    <thead>
                        <tr>
                            <th width="40%">Descrição</th>
                            <th width="60%">Endereço</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td align="right">ELEGIBILIDADE - PESQUISA DE BENEFICIÁRIO</td>
                            <td><%=quickfield("text", "tissVerificaElegibilidade", "", 12, reg("tissVerificaElegibilidade"), "", "", "") %></td>
                        </tr>
                        <tr>
                            <td align="right">SOLICITAÇÃO DE PROCEDIMENTO</td>
                            <td><%=quickfield("text", "tissSolicitacaoProcedimento", "", 12, reg("tissSolicitacaoProcedimento"), "", "", "") %></td>
                        </tr>
                        <tr>
                            <td align="right">ATUALIZAÇÃO DO STATUS DA GUIA</td>
                            <td><%=quickfield("text", "tissSolicitacaoStatusAutorizacao", "", 12, reg("tissSolicitacaoStatusAutorizacao"), "", "", "") %></td>
                        </tr>
                        <tr>
                            <td align="right">ENVIO DE LOTE</td>
                            <td><%=quickfield("text", "tissLoteGuias", "", 12, reg("tissLoteGuias"), "", "", "") %></td>
                        </tr>
                        <tr>
                            <td align="right">CANCELAMENTO DE GUIA</td>
                            <td><%=quickfield("text", "tissCancelaGuia", "", 12, reg("tissCancelaGuia"), "", "", "") %></td>
                        </tr>
                        <tr>
                            <td align="right">RETORNO DE DEMONSTRATIVO</td>
                            <td><%=quickfield("text", "tissSolicitacaoDemonstrativoRetorno", "", 12, reg("tissSolicitacaoDemonstrativoRetorno"), "", "", "") %></td>
                        </tr>
                    </tbody>
                </table>
            </form>
        </div>
        <div id="divValores" class="tab-pane" style="overflow-x: scroll">
            Carregando...
        </div>
        <div id="divNumeracao" class="tab-pane">
            Carregando...
        </div>
        <div id="divRegras" class="tab-pane">
            <form id="frmRegras">
                <h4>Número da Carteira</h4>
                <div class="row">
                    <%
                        MinimoDigitos = reg("MinimoDigitos")
                        MaximoDigitos = reg("MaximoDigitos")
                        if MinimoDigitos=0 then MinimoDigitos="" end if
                        if MaximoDigitos=0 then MaximoDigitos="" end if
                    %>
                    <%=quickfield("number", "MinimoDigitos", "Mínimo de Dígitos", 2, MinimoDigitos, "", "", "") %>
                    <%=quickfield("number", "MaximoDigitos", "Máximo de Dígitos", 2, MaximoDigitos, "", "", "") %>
                    <div class="col-md-6">
                        <label>&nbsp;</label><br />
                        <label><input type="checkbox" class="ace" name="Digito11" id="Digito11" value="1"<%if reg("Digito11")=1 then response.write(" checked ") end if %> /><span class="lbl"> Utilizar verificador de dígito módulo 11</span></label>
                    </div>
                </div>
                <br />
                <h4>Outras Regras de Preenchimento de Guia</h4>
                <div class="row">
                    <div class="col-md-12">
                        <%
                        set ConfigConvenioSQL = dbc.execute("SELECT * FROM cliniccentral.config_opcoes WHERE Secao='convenio'")

                        while not ConfigConvenioSQL.eof
                            Coluna = ConfigConvenioSQL("Coluna")

                            ValorMarcado = ConfigConvenioSQL("ValorMarcado")
                            if not isnull(ValorMarcado) then
                                if isnumeric(ValorMarcado) then
                                    ValorMarcado=cint(ValorMarcado)
                                end if
                            end if
                            Valor = reg(Coluna)
                            if Valor=true then
                                Valor = 1
                            end if

                            %>
                            <div class="checkbox-custom checkbox-primary">
                                <input <%if Valor=ValorMarcado then response.write(" checked ") end if %> type="checkbox" class="ace " name="<%=Coluna%>" id="<%=Coluna%>" value="<%=ValorMarcado%>">
                                <label class="checkbox" for="<%=Coluna%>"> <%=ConfigConvenioSQL("Label")%></label>
                            </div>
                            <%
                        ConfigConvenioSQL.movenext
                        wend
                        ConfigConvenioSQL.close
                        set ConfigConvenioSQL=nothing
                        %>

                        <%= quickField("text", "CodigoFilme", "Código do filme", 2, reg("CodigoFilme"), "", "", "") %>

                    </div>
                </div>
                <br />
                <div class="row">
                    <%=quickfield("select", "MesclagemMateriais", "Despesas anexas em guias com mais de um procedimento", 6, reg("MesclagemMateriais"), "select 'Somar' id, 'Inserir os materiais de todos os procedimentos' Valor UNION ALL select 'Maior', 'Inserir somente os materiais do primeiro procedimento'", "Valor", "") %>
                </div>
                <div class="row">
                    <%=quickfield("simpleSelect", "SadtImpressao", "Tipo de impressão da SADT", 6, reg("SadtImpressao"), "select 'sadt' id, 'SP/SADT Padrão' Valor UNION ALL select 'sus', 'SUS' UNION ALL SELECT 'gto', 'Odontologia'", "Valor", " semVazio") %>
                </div>
                <div class="row">
                    <% camposObrigatorios = reg("camposObrigatorios") %>
                    <% 
                        sqlFields = "SELECT 'Plano' id, 'Plano' Campo UNION ALL " &_
                                    " ( SELECT 'Data Validade da Carteira' id, 'Data Validade da Carteira' Campo ) UNION ALL "  &_ 
                                    " ( SELECT 'Data da Autorização' id, 'Data da Autorização' Campo) UNION ALL " &_ 
                                    " (SELECT 'Senha' id, 'Senha' Campo ) UNION ALL " &_ 
                                    " (SELECT 'Validade da Senha' id, 'Validade da Senha' Campo) UNION ALL " &_ 
                                    " (SELECT 'N° da Guia na Operadora' id, 'N° da Guia na Operadora' Campo) UNION ALL " &_  
                                    " (SELECT 'N° da Guia Principal' id, 'N° da Guia Principal' Campo) UNION ALL " &_  
                                    " (SELECT 'Observacoes' id, 'Observações' Campo) UNION ALL " &_
                                    " (SELECT 'CNS' id, 'CNS' Campo) UNION ALL " &_
                                    " (SELECT 'Identificador' id, 'Identificador' Campo) UNION ALL " &_  
                                    " (SELECT 'Código na Operadora' id, 'Código na Operadora' Campo) UNION ALL " &_ 
                                    " (SELECT 'Data da Solicitação' id, 'Data da Solicitação' Campo) UNION ALL " &_  
                                    " (SELECT 'Indicação Clínica' id, 'Indicação Clínica' Campo) UNION ALL " &_  
                                    " (SELECT 'Profissional Solicitante' id, 'Profissional Solicitante' Campo) UNION ALL " &_  
                                    " (SELECT 'Nome do Contratado' id, 'Nome do Contratado' Campo) " 
            
                    %>

                    <%=quickField("multiple", "camposObrigatorios", "Campos obrigatórios", 6, camposObrigatorios, sqlFields, "Campo", "")%>
                </div>
            </form>
        </div>
    </div>
</div>
<script type="text/javascript">
    $(document).ready(function(e) {
        <%call formSave("frm, #WS, #frmRegras", "save", "")%>
        $("#save").click(function() {
            $("#frm").submit();
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

    function replaceAll(string, token, newtoken) {
        while (string.indexOf(token) != -1) {
            string = string.replace(token, newtoken);
        }
        return string;
    }
</script>

<script src="../assets/js/ace-elements.min.js"></script>
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

    function tissCompletaDados(T, I, N){
        $.post("tissCompletaDados.asp?I="+I+"&T="+T,{
            ConvenioID:"<%=req("I")%>",
            Numero:N,
            },function(data,status){
                eval(data);
            });
    }
</script>
<!--#include file="disconnect.asp"-->
