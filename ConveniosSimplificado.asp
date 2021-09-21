<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="modal.asp"-->
<% function formSaveSimplificado(FormID, btnSaveID, AcaoSeguinte)
	%>
    $("#<%=FormID%>").submit(function() {
		$("#<%=btnSaveID%>").html('salvando');
		$("#<%=btnSaveID%>").attr('disabled', 'disabled');
        $.post("ConveniosSimplificadoSave.asp", $("#<%=FormID%>").serialize())
        .done(function(data) {
          $("#<%=btnSaveID%>").html('<i class="fa fa-save"></i> Salvar');
		  $("#<%=btnSaveID%>").removeAttr('disabled');
          eval(data);

		  if(data.toLowerCase().indexOf("erro") <= 0){
            <%=AcaoSeguinte%>
          }
        });
        return false;
    })
	<%
end function


AlteraTipo = req("AlteraTipo")
if AlteraTipo<>"" then
    registroAns = ""
    if AlteraTipo="simplificado" then
        registroAns="simplificado"
    end if

    db_execute("UPDATE convenios SET RegistroANS='"&registroAns &"' WHERE id="&req("I"))

    if AlteraTipo="simplificado" then
        response.redirect("?P=ConveniosSimplificado&I="&req("I")&"&Pers=1")
    end if

end if
%>

<script>
<% if request.QueryString("I") <> "N" then %>
    function addRow() {
        $("#newQtd").val(parseInt($("#newQtd").val())+1);
        let num = $("#newQtd").val();
        let linha = `<tr>
                        <td class="text-center">
                            <select class="form-control multisel tag-input-style" multiple name="NewUsuarios${num}" id="NewUsuarios${num}">
                                <%
                                    set sqlUsuarios = db.execute("SELECT id, Nome FROM (SELECT su.id,prof.NomeProfissional Nome FROM profissionais prof INNER JOIN sys_users su ON su.idInTable=prof.id AND su.table='profissionais' WHERE prof.Ativo='on' AND prof.sysActive=1 UNION ALL SELECT su.id,func.NomeFuncionario Nome FROM funcionarios func INNER JOIN sys_users su ON su.idInTable=func.id AND su.table='funcionarios' WHERE func.Ativo='on' AND func.sysActive=1)t ORDER BY t.Nome;")
                                    while not sqlUsuarios.EOF
                                        response.write("<option value='"&sqlUsuarios("id")&"'>"&sqlUsuarios("Nome"))
                                        sqlUsuarios.movenext
                                    wend
                                    sqlUsuarios.close
                                    set sqlUsuarios = nothing
                                %>
                            </select>
                        </td>
                        <td class="text-center">
                            <select class="form-control multisel tag-input-style" multiple name="NewPlanos${num}" id="NewPlanos${num}">
                                <%
                                    set sqlPlanos = db.execute("SELECT id, NomePlano FROM ConveniosPlanos WHERE sysActive = 1 AND ConvenioID = "&request.QueryString("I"))
                                    while not sqlPlanos.EOF
                                        response.write("<option value='"&sqlPlanos("id")&"'>"&sqlPlanos("NomePlano"))
                                        sqlPlanos.movenext
                                    wend
                                    sqlPlanos.close
                                    set sqlPlanos = nothing
                                %>
                            </select>
                        </td>
                        <td class="text-center">
                            <div class="input-group">
                                <input id="NewVigenciaInicio${num}" autocomplete="off" class="form-control input-mask-date date-picker" type="text" value="" name="NewVigenciaInicio${num}" data-date-format="dd/mm/yyyy" />
                                <span class="input-group-addon">
                                <i class="fa fa-calendar bigger-110"></i>
                                </span>
                            </div>
                        </td>
                        <td class="text-center">
                            <div class="input-group">
                                <input id="NewVigenciaFim${num}" autocomplete="off" class="form-control input-mask-date date-picker" type="text" value="" name="NewVigenciaFim${num}" data-date-format="dd/mm/yyyy" />
                                <span class="input-group-addon">
                                <i class="fa fa-calendar bigger-110"></i>
                                </span>
                            </div>
                        </td>
                        <td class="text-center">
                            <textarea class="form-control" id="NewObs${num}" name="NewObs${num}"></textarea>
                        </td>
                        <td class="text-center">
                        </td>
                    </tr>`;

        $('#conveniosObs tr:last').after(linha);
        jqueryHelper();
    }

    function jqueryHelper() {
        $('.multisel').multiselect({
            includeSelectAllOption: true,
            enableFiltering: true,
            numberDisplayed: 1,
        });

        $('.date-picker').datepicker({autoclose:true}).next().on(ace.click_event, function(){
            $(this).prev().focus();
        });

        $('.input-mask-date').mask('99/99/9999');

        CKEDITOR.config.shiftEnterMode= CKEDITOR.ENTER_P;
        CKEDITOR.config.enterMode= CKEDITOR.ENTER_BR;
        CKEDITOR.config.height = 50;
        $("#NewObs"+$("#newQtd").val()).ckeditor();
    }

    $(document).ready(function(){
        jqueryHelper();
    });

<% end if %>

    function save() {
        $("input[name^=NewVigenciaInicio]").each(function () {
             let codigo = $(this).attr("name");
             codigo = codigo.replace("NewVigenciaInicio", "");

             let UsuariosAux = $("#NewUsuarios"+codigo).val();
             let PlanosAux = $("#NewPlanos"+codigo).val();
             let VigenciaInicio = $("#NewVigenciaInicio"+codigo).val();
             let VigenciaFim = $("#NewVigenciaFim"+codigo).val();

             let Obs = $("#NewObs"+codigo).val();
             let Usuarios = "";
             let Planos = "";
             if(UsuariosAux !== null && Obs !== "") {
                  UsuariosAux.forEach(function (element, index){
                      if (index === UsuariosAux.length - 1){
                          Usuarios += "|" + element.replace(/\|/g,'') + "|";
                      } else {
                          Usuarios += "|" + element.replace(/\|/g,'') + "|,";
                      }
                  });

                  if(PlanosAux !== null) {
                     PlanosAux.forEach(function (element, index){
                         if (index === PlanosAux.length - 1){
                             Planos += "|" + element.replace(/\|/g,'') + "|";
                         } else {
                             Planos += "|" + element.replace(/\|/g,'') + "|,";
                         }
                    });
                  }

                  $.post("ConveniosObservacoesUsuario.asp?Action=insert&I=<%=request.QueryString("I")%>&Usuarios="+Usuarios+"&DataInicio="+VigenciaInicio+"&DataFim="+VigenciaFim+"&Planos="+Planos, {
                      Obs: Obs
                  }, function(data){
                       eval(data);
                  });
             }
        });

        $("input[name^=VigenciaInicio]").each(function () {
             let codigo = $(this).attr("name");
             codigo = codigo.replace("VigenciaInicio", "");

             let UsuariosAux = $("#Usuarios"+codigo).val();
             let PlanosAux = $("#Planos"+codigo).val();
             let VigenciaInicio = $("#VigenciaInicio"+codigo).val();
             let VigenciaFim = $("#VigenciaFim"+codigo).val();

             let Obs = $("#Obs"+codigo).val();
             let Usuarios = "";
             let Planos = "";
             if(UsuariosAux !== null && Obs !== "") {
                  UsuariosAux.forEach(function (element, index){
                      if (index === UsuariosAux.length - 1){
                          Usuarios += "|" + element.replace(/\|/g,'') + "|";
                      } else {
                          Usuarios += "|" + element.replace(/\|/g,'') + "|,";
                      }
                  });

                  if(PlanosAux !== null) {
                      PlanosAux.forEach(function (element, index){
                          if (index === PlanosAux.length - 1){
                              Planos += "|" + element.replace(/\|/g,'') + "|";
                          } else {
                              Planos += "|" + element.replace(/\|/g,'') + "|,";
                          }
                      });
                  }

                  $.post("ConveniosObservacoesUsuario.asp?Action=update&I=<%=request.QueryString("I")%>&Usuarios="+Usuarios+"&DataInicio="+VigenciaInicio+"&DataFim="+VigenciaFim+"&id="+codigo+"&Planos="+Planos, {
                      Obs: Obs
                  }, function(data){
                       eval(data);
                       abrirModalObs();
                  });
             }
        });

        new PNotify({
            title: 'SUCESSO!',
            text: 'Observação salva com sucesso.',
            type: 'success',
            delay: 1000
        });
    }

    function excluir(id) {
        $.get("ConveniosObservacoesUsuario.asp?Action=delete&id="+id, function(data) {
        });

        abrirModalObs();

        new PNotify({
            title: 'SUCESSO!',
            text: 'Observação excluída com sucesso.',
            type: 'success',
            delay: 1000
        });
    }

    function abrirModalObs() {
        $.get("ConveniosObservacoesUsuario.asp?Action=getAll&I=<%=request.QueryString("I")%>", function(data) {
            $('#conveniosObs').children('tbody').html(data);
        });
    }
</script>

<%
call insertRedir("Convenios", request.QueryString("I"))
set reg = db.execute("select * from convenios where id="&request.QueryString("I"))
LimitarEscalonamento = reg("LimitarEscalonamento")&""


function coalesce(valor1,valor2)

	IF NOT ISNULL(valor1) THEN
	    coalesce = (valor1)
	    Exit Function
	END IF

	IF NOT ISNULL(valor2) THEN
    	coalesce = (valor2)
    	Exit Function
    END IF

end function


%>

<%=header("Convenios", "Cadastro de Convênio Simplificado: "&reg("NomeConvenio"), reg("sysActive"), req("I"), req("Pers"), "Follow")%>

<br />
<div class="tabbable panel">
    <div class="tab-content panel-body">
        <div id="divCadastroConvenio" class="tab-pane in active">
            <form method="post" id="frm" name="frm" action="ConveniosSimplificadoSave.asp">
                <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
                <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />
                <input type="hidden" name="registroans" value="simplificado" />

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
                                    <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position: absolute; left: 18px; bottom: 6px;"><i class="fa fa-trash"></i></button>
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
                            <%= quickField("number", "RetornoConsulta", "Retorno Consulta", 2, reg("RetornoConsulta"), "", "", " placeholder='Dias'") %>
                            <%= quickField("number", "DiasRecebimento", "Dias para Recebimento", 2, reg("DiasRecebimento"), "", "", " placeholder='Dias'") %>
                            <%= quickField("text", "NumeroGuiaAtual", "Nº da Guia Atual",2 , reg("NumeroGuiaAtual"), "", "", "") %>
                            <%=quickField("empresaMultiIgnore", "Unidades", "Limitar Unidades", 2, reg("Unidades"), "", "", "")%>
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
                <div class="row">
                    <%= quickField("editor", "Obs", "Observações "&"&nbsp;&nbsp;<button type=""button"" onclick=""abrirModalObs()"" class=""btn btn-xs btn-success"" data-toggle=""modal"" data-target=""#modalConveniosObs""><i class=""fa fa-plus""></i></button>", 12, reg("Obs"), "50", "", "")%>
                </div>

                <div class="row">
                    <div class="col-md-12" style="text-align: right; margin-bottom: 20px">
                        <button type="button" class="btn btn-sm btn-warning" onclick="window.location.replace('?P=Convenios&AlteraTipo=normal&I=<%=request.QueryString("I")%>&Pers=1');"  style="margin: 2px; ">
                            <i class="far fa-exclamation-circle"></i> Ver convênio completo
                        </button>
                    </div>
                </div>

              <button class="hidden" id="save" type="button"></button>

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
          <div id="divValoresPlanos" class="tab-pane">
                    Carregando...
                </div>
        <div id="divValoresImpostos" class="tab-pane">
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
                    <%= quickField("simpleSelect", "TipoAtendimentoID", "Tipo de Atendimento Padrão", 6, reg("TipoAtendimentoID"), "select * from tisstipoatendimento order by descricao", "descricao", "  ") %>
                </div>
            </form>
        </div>
    </div>
</div>
<script type="text/javascript">
    $(document).ready(function(e) {
        <%call formSaveSimplificado("frm, #WS, #frmRegras", "save", "")%>
        $("#save").click(function() {
            $("#frm").submit();
        });
    });

    $("#Cep").keyup(function(){
        getEndereco();
    });
    var resultadoCEP
    function getEndereco() {
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
                }

                return true;
            }
        });


				$("#Foto").change(async function() {

        		    await uploadProfilePic({
        		        $elem: $("#Foto"),
        		        userId: "<%=req("I")%>",
        		        db: "<%= LicenseID %>",
        		        table: 'convenios',
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

    function tissCompletaDados(T, I, N){
        $.post("tissCompletaDados.asp?I="+I+"&T="+T,{
            ConvenioID:"<%=request.QueryString("I")%>",
            Numero:N,
            },function(data,status){
                eval(data);
            });
    }

    function placeholder(){
        $("[name^='ValorPlanoCH']").attr("placeholder",$("#ValorCH").val())
        $("[name^='ValorPlanoFilme']").attr("placeholder",$("#ValorFilme").val())
        $("[name^='ValorPlanoUCO']").attr("placeholder",$("#ValorUCO").val())
    }

    $("#ValorCH,#ValorFilme,#ValorUCO").on("change",()=>placeholder());

    $("#TabelaPorte").on("change",(arg) => {
       $("[name^='TabelaPlanoPorte']").val($(arg.target).val()).trigger("change")
    });

    placeholder();

</script>
<div class="modal fade" id="modalConveniosObs" tabindex="-1" role="dialog" aria-labelledby="modalConveniosObsLabel" aria-hidden="true">
  <div class="modal-dialog" style="width: 90%" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalConveniosObsLabel">Observações por Usuário</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <%
          sql = "SELECT id, Usuarios, DataInicio, DataFim, Obs FROM convenio_observacao_usuario WHERE ConvenioID = "&req("I")
          set convenioObservacaoUsuario = db.execute(sql)
      %>
      <div class="modal-body" style="display: flow-root;">
            <input id="newQtd" name="newQtd" type="hidden" value="0" />
            <table class="table table-striped table-hover table-bordered table-condensed" id="conveniosObs">
                <thead>
                  <tr>
                    <th style="width: 20%" class="text-center">Usuários</th>
                    <th style="width: 10%" class="text-center">Planos</th>
                    <th style="width: 10%" class="text-center">Início da Vigência</th>
                    <th style="width: 10%" class="text-center">Fim da Vigência</th>
                    <th class="text-center">Observações</th>
                    <th style="width: 5%" class="text-center"><button type="button" class="btn btn-xs btn-success mn" onclick="addRow();"><i class="fa fa-plus"></i></button></th>
                  </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
        <button type="button" onclick="save()" class="btn btn-primary">Salvar</button>
      </div>
    </div>
  </div>
</div>

<!--#include file="disconnect.asp"-->