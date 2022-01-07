<!--#include file="Classes/Restricao.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
ObrigarFormaRecebimentoCheckin=getConfig("ObrigarFormaRecebimentoCheckin")

function linhaPagtoCheckin(strTipoGuia, rdValorPlano, ClasseLinha, IDMovementBill)


    %>
    <tr class="<%=ClasseLinha%>">
        <td class="default" colspan="10" style="border-top:none">

            <%
            if rdValorPlano="V" then
                Rotulo = "RECEBER"

                recebimentoFunc = "onclick='lanctoCheckin("""&Bloco &""", """&IDMovementBill&""")'"
                
                
                if ObrigarFormaRecebimentoCheckin = "1" then
                    recebimentoFunc = " onclick='lanctoCheckinNovoUpdate("""&Bloco&""")' "
                end if

                if aut("|contasareceberI|")=0 and session("CaixaID")="" and aut("|aberturacaixinhaI|") then
                    recebimentoFunc="data-toggle='tooltip' title='Você precisar abrir o caixinha'"

                    styleDisabled = "style='cursor: not-allowed; opacity:0.65'"
                end if                
                %>
                    <button type="button" class="ckpagar btn btn-xs btn-warning" <%=styleDisabled%> <%=recebimentoFunc%> ><i class="far fa-arrow-circle-up"></i> <%= Rotulo %></button>
                <% 
            else
                spl = split(strTipoGuia, ", ")
                for i=0 to ubound(spl)
                    TipoGuia = spl(i)

                    Rotulo = "Guia "&TipoGuia

                    if TipoGuia<>"Simplificada" then
                        Rotulo = "Guia de "&TipoGuia
                    end if

                    %>
                    <button type="button" onclick="GeraGuia('<%=TipoGuia%>')" class="btn btn-xs btn-warning"><i class="far fa-arrow-circle-up"></i> <%= ucase(Rotulo) %></button>
                    <%
                next
            end if
            %> </td>
    </tr>
    <%
end function

if req("validaParticular") <> "" then
    response.write(recordToJSON(db.execute("SELECT *, SomenteConvenios like '%|NOTPARTICULAR|%' as NaoParticular FROM procedimentos WHERE id ="&req("validaParticular")&" ")))
    response.end
end if

if req("Checkin")="1" then
    staPagto = "danger"
    %>
<input id="AccountID" type="hidden" name="AccountID" value="<%= "3_"& PacienteID %>" />
<div id="divLanctoCheckin"><!--#include file="invoiceEstilo.asp"--></div>
    <div id="checkinProcedimentosBaixar">
    <% server.execute("checkinProcedimentosBaixar.asp") %>
</div>

    <script type="text/javascript">

        var temRegraCadastradaProUsuario = false;
        var temAutorizacaoAberta         = false;
        var valorTotalSelecionado        = 0;
        var idsRegrasSuperiores          = '';

        $('[data-toggle="tooltip"]').tooltip();

        function abrirPagar(MovementID) {
            $("#dadosAgendamento").append("<input class=\"parcela\" type=\"hidden\" name=\"Parcela\" value=\"|"+MovementID+"|\" />");

            $("#pagar").fadeIn();

            $( "#pagar" ).draggable();

            $("#pagar").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
            $.post("Pagar.asp?T=C", {
                Parcela: '|'+MovementID+'|'
                }, function (data) {
                    $("#pagar").html(data);
                });

        }

        function onKeyUpDesconto(){
            let acrescimo = parseFloat($('#acrescimoForma').val().replace('.', '').replace(',', '.'));
            if (isNaN(acrescimo)) {
                acrescimo = 0;
            }
            let desconto  = parseFloat($('#descontoForma').val().replace('.', '').replace(',', '.'));
            if (isNaN(desconto)) {
                desconto = 0;
            }

            let total   = valorTotalSelecionado + acrescimo - desconto;
            let totalBr = round(total, 2).toLocaleString(undefined, { minimumFractionDigits: 2 })

            $('#valorTotalSomaItems, #totalvalue').val(totalBr);
        }

        async function lanctoCheckin(Bloco, IDMovementBill) {
            let validacao = await checkParticularTableFields()

            if(!validacao){
                return false
            }

            if(IDMovementBill!==""){abrirPagar(IDMovementBill); return;}
            var valorTotal = 0;
            valor = ""
            procedimento = ""
            AgendamentoID = ""
            ProfissionalID =  $("#valuesearchindicacaoId").val();

            $(".linha-procedimento").each(function(index){
                var valor1 = $(this).find(".valorprocedimento").val();
                var procedimento1 = $(this).find("#ProcedimentoID").val();
                var AgendamentoID1 = $(this).find("input[name='LanctoCheckin']").val();

                if(typeof AgendamentoID1 !== "undefined"){
                    valor += valor1 + "|";
                    procedimento += procedimento1 + "|";
                    AgendamentoID += AgendamentoID1 + "|";
                }


                /*$.post('checkinLanctoUpdate.asp', {
                    valor : valor,
                    procedimento : procedimento,
                    AgendamentoID : AgendamentoID
                }, function(data){
                   //alert(data)
                });*/
            });
            $.post("saveAgenda.asp?PreSalvarCheckin=1", $("#formAgenda").serialize(), function(data) {
                                if(data.indexOf("Erro") !== -1){
                                    eval(data);
                                    return;
                                }


            $.post('checkinLanctoUpdate.asp', {
                    valor : valor,
                    procedimento : procedimento,
                    AgendamentoID : AgendamentoID,
                    ProfissionalID: ProfissionalID
                }, function(val1){

                    $.post("checkinLancto.asp", $(".Bloco" + Bloco).serialize(), function (v) { $('#divLanctoCheckin').html(v) });

                });
            });
        }

        function getProcedimentosCheckin() {
            const procedimentos = [];
            $(".linha-procedimento").each(function(){
                const valor         = $(this).find(".valorprocedimento").val();
                const procedimento  = $(this).find("input[id^=ProcedimentoID]").val();
                const agendamentoID = $(this).find("input[name='LanctoCheckin']");

                if(typeof agendamentoID !== "undefined" && agendamentoID.is(':checked')){
                    procedimentos.push({
                        procedimentoId: procedimento,
                        agendamentoId: agendamentoID,
                        valor: parseFloat(valor.replace('.', '').replace(',', '.'))
                    });
                }
            });
            return procedimentos;
        }

        function lanctoCheckinNovoUpdate(Bloco) {
            let ModoFranquia = '<%=ModoFranquia%>' ;

            if(ModoFranquia){
                let retorno = checkParticularTableFields()
                if(!retorno){
                    return false
                }
            }
            

            var valorTotal = 0;
            valor = "";
            procedimento = "";
            AgendamentoID = "";
            ProfissionalID =  $("#valuesearchindicacaoId").val();

            $(".linha-procedimento").each(function(index){
                var valor1 = $(this).find(".valorprocedimento").val();
                var procedimento1 = $(this).find("#ProcedimentoID").val();
                var AgendamentoID1 = $(this).find("input[name='LanctoCheckin']").val();

                if(typeof AgendamentoID1 !== "undefined"){
                    valor += valor1 + "|";
                    procedimento += procedimento1 + "|";
                    AgendamentoID += AgendamentoID1 + "|";
                }
            });

            
            $.post('itensFatura.asp?tipoTela=checkin&InvoiceID=0', {
                    valor : valor,
                    procedimento : procedimento,
                    AgendamentoID : AgendamentoID,
                    ProfissionalID : ProfissionalID
                }
                , function(data) {
                    $('#modal-table').modal('show');
                    $("#modal").html(data);

            });
        }

        function verificaMaximoDescontoCheckin() {
            return new Promise(function(resolve, reject) {
                const procedimentos = getProcedimentosCheckin();

                let procedimentosParam = '';
                procedimentos.map(function(procedimento) {
                    if (procedimentosParam.length > 0) {
                        procedimentosParam += '|';
                    }
                    procedimentosParam += procedimento.procedimentoId + '_' + procedimento.valor
                });

                let valorTotalModificado = parseFloat($('#valorTotalSomaItems').val().replace('.', '').replace(',', '.'));

                if (valorTotalModificado < 0) {
                    showMessageDialog("Desconto inválido.");
                    $('#desconfoForma').focus();
                    reject('Desconto inválido');
                    return;
                }

                let percDesc = null;
                if (valorTotalModificado < valorTotalSelecionado) {
                    percDesc = 1 - (valorTotalModificado / valorTotalSelecionado);
                    percDesc = (Math.round(percDesc * 100000000) / 100000000) * 100; //arredondado em 6 decimais
                }

                $.when($.get('VerificaMaximoDescontoCheckin.asp', {
                    Procedimentos: procedimentosParam,
                    PercDesconto: percDesc
                })).then(resolve, reject);
            });
        }

        function validaMaximoDescontoCheckin() {
            return new Promise(function(resolve, reject)  {
                verificaMaximoDescontoCheckin().then(function(verificacao) {
                    if (verificacao.valido) {
                        resolve();
                    } else if (verificacao.temRegraSuperior) {
                        $.when($.get('ModalMaximoDesconto.asp', {RegraID: verificacao.regrasSuperiores}))
                            .then(function(modalContent) {
                                idsRegrasSuperiores = verificacao.regrasSuperiores;
                                showBoxAutorizacaoDesconto(modalContent);
                                reject('Autorização Necessária');
                            }, reject);
                    } else {
                        showMessageDialog("Desconto inválido.");
                        $('#desconfoForma').focus();
                        reject('Desconto inválido');
                    }
                }, reject);
            });
        }

        function validaAutorizacaoDesconto() {
            return new Promise(function(resolve, reject) {

                const boxAutorizacao = $('#box-autorizacao-desconto');

                const usuario    = boxAutorizacao.find('input[name=RegraUsuario]:checked').val();
                const inputSenha = boxAutorizacao.find("#SenhaAdministrador");
                const senha      = inputSenha.val();

                if (!usuario) {
                    alert('Selecione um usuário');
                    reject('Nenhum usuário selecionado.');
                    return;
                }
                if (!senha || senha.trim() === '') {
                    alert('Digite a senha.');
                    reject('Senha não informada');
                    return;
                }

                $.when($.post('SenhaDeAdministradorValida.asp', {U: usuario, S: senha})).then(function(res) {
                    res = parseInt(res, 10);
                    if (res === 1) {
                        resolve();
                    } else {
                         new PNotify({
                            title: 'ERRO',
                            text: 'Senha inválida.',
                            type: 'danger',
                            delay: 3000
                        });
                        reject('Senha inválida');
                    }
                }, reject);

            });
        }

        function aguardarAutorizacaoDesconto(Bloco) {
            submitCheckinLancto(Bloco, true).then(function() {

                //verifica se response veio com as variáveis MOVEMENT_ID e DESCONTOS_PENDENTES
                if (DESCONTOS_PENDENTES && MOVEMENT_ID) {
                    const modalPagto     = $('#modalFormaPagamento');
                    const boxAutorizacao = $('#box-autorizacao-desconto');

                    boxAutorizacao.find('.panel-body').html('<i class="far fa-spinner fa-spin orange bigger-125"></i> ' +
                        'Aguarde a autorização do desconto...');

                    $('#btn-aguardar-autorizacao, #salvar-mudancas').hide();

                    let intervalVerifica = setInterval(function() {
                        $.get('VerificaDescontoPendenteCheckin.asp?descontos=' + DESCONTOS_PENDENTES, function(res) {
                            if (res === '1') {
                                clearInterval(intervalVerifica);

                                // fecha o modal de recebimento
                                showMessageDialog('Desconto aprovado.', 'success');
                                modalPagto.modal('hide');

                                // abre a modal de pagamento
                                const divPagar = $('#pagar');
                                divPagar.fadeIn();
                                divPagar.draggable();
                                divPagar.html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
                                $.post("Pagar.asp?T=C", {
                                    Parcela: '|' + MOVEMENT_ID + '|'
                                }, function (data) {
                                    divPagar.html(data);
                                });

                            } else if (res === '2') {
                                clearInterval(intervalVerifica);
                                showMessageDialog('O desconto não foi aprovado.');
                                hideBoxAutorizacaoDesconto();
                            }
                        });
                    }, 15000); // a cada 15 seg

                    modalPagto.on('hidden.bs.modal', function() {
                        clearInterval(intervalVerifica);
                    });

                } else {
                    showMessageDialog('Erro ao processa a sua solicitação');
                    hideBoxAutorizacaoDesconto();
                }
            }, function() {
                showMessageDialog('Erro ao processa a sua solicitação');
                hideBoxAutorizacaoDesconto();
            });
        }

        function clearValue() {
            document.getElementById('acrescimoForma').value = '0,00';
            document.getElementById('descontoForma').value = '0,00';
            document.getElementById('totalvalue').value = '0,00';
        }

        function saveLanctoNovo(Bloco){
            const modalPagto   = $('#modalFormaPagamento');
            const modalButtons = modalPagto.find('button, .close');
            modalButtons.prop('disabled', 'disabled');

            if (!temRegraCadastradaProUsuario) {
                submitCheckinLancto(Bloco).then(function() {
                    modalPagto.modal('hide');
                    clearValue();
                }).finally(function() {
                    modalButtons.prop('disabled', '');
                });
                return;
            }

            // Validações do desconto
            if (temAutorizacaoAberta) {
                validaAutorizacaoDesconto().then(function() {
                     submitCheckinLancto(Bloco).then(function() {
                         modalPagto.modal('hide');
                         clearValue();
                     }).finally(function() {
                       modalButtons.prop('disabled', '');
                     });
                }, function(rejectReason) {
                    // console.log(rejectReason);
                }).finally(function() {
                    modalButtons.prop('disabled', '');
                });
            } else {
                validaMaximoDescontoCheckin().then(function() {
                    submitCheckinLancto(Bloco).then(function() {
                        modalPagto.modal('hide');
                        clearValue();
                    }).finally(function() {
                      modalButtons.prop('disabled', '');
                    });
                }, function(rejectReason) {
                    // console.log(rejectReason);
                }).finally(function() {
                    modalButtons.prop('disabled', '');
                });
            }
        }

        function submitCheckinLancto(Bloco, notificaDesconto) {
            return new Promise(function(resolve, reject) {

                let keyItemFormaPagamentoSelecionado = document.getElementById('FormaID').selectedIndex;
                let elementOptionsSelecionado = document.getElementById("FormaID").options[keyItemFormaPagamentoSelecionado];
                let splitFormRecto = elementOptionsSelecionado.value.split('_');
                let sysFormasrectoId = splitFormRecto[0];
                let ContaRectoID = splitFormRecto[1];

                if(typeof sysFormasrectoId === "undefined"){
                    sysFormasrectoId = 0;
                }
                if(typeof ContaRectoID === "undefined"){
                    ContaRectoID = 0;
                }
                let valorTotalSomaItems = document.getElementById('valorTotalSomaItems').value;
                let dados = $(".Bloco" + Bloco).serialize() + "&valorTotalSomadoModificado="+valorTotalSomaItems
                    + "&FormaID="+sysFormasrectoId+"&ContaRectoID="+ContaRectoID;
                    
                if (notificaDesconto) {
                    dados += '&NotificaDesconto=1&IdsRegrasSuperiores=' + idsRegrasSuperiores;
                }

                $.when($.post("checkinLancto.asp", dados)).then(function(lanctoResponse) {
                    $('#divLanctoCheckin').html(lanctoResponse);
                    resolve();
                }, reject);
            });
        }

        function showBoxAutorizacaoDesconto(modalContent) {
            const modalPagto     = $('#modalFormaPagamento');
            const boxAutorizacao = $('#box-autorizacao-desconto');
            const btnAguardar    = $('#btn-aguardar-autorizacao');

            temAutorizacaoAberta = true;

            modalPagto.find('#salvar-mudancas').html('Confirmar');
            modalPagto.find('#FormaID').prop('disabled', 'disabled');
            modalPagto.find('#acrescimoForma').prop('disabled', 'disabled');
            modalPagto.find('#descontoForma').prop('disabled', 'disabled');

            boxAutorizacao.find('.panel-body').html(modalContent);
            boxAutorizacao.find('input,select').on('keypress', function(ev) {
                if (ev.keyCode === 13) {
                    ev.preventDefault();
                }
            });
            boxAutorizacao.show();
            btnAguardar.show();
            modalPagto.on('hidden.bs.modal', hideBoxAutorizacaoDesconto);
        }

        function hideBoxAutorizacaoDesconto() {
            const modalPagto     = $('#modalFormaPagamento');
            const boxAutorizacao = $('#box-autorizacao-desconto');
            const btnAguardar    = $('#btn-aguardar-autorizacao');

            boxAutorizacao.find('.panel-body').html('')
            boxAutorizacao.hide();
            btnAguardar.hide();

            temAutorizacaoAberta = false;
            idsRegrasSuperiores  = '';

            modalPagto.find('#salvar-mudancas').html('Salvar mudanças').show();
            modalPagto.find('#FormaID').prop('disabled', '')
            if (temRegraCadastradaProUsuario) {
                modalPagto.find('#acrescimoForma').prop('disabled', '');
                modalPagto.find('#descontoForma').prop('disabled', '');
            }
        }

        function normalizeMoney(valor){
            let check = valor.slice(valor.length - 3)
            if(check[0] == '.' || check[1] == '.'){
                valor = valor.replace(',','v')
                valor = valor.replace('.',',')
                valor = valor.replace('v','.')
            }
            return valor
        }

    </script>

    <%
else
    %>
    <div class="row pt20">
        <div class="col-md-12" <% if device()<>"" then %> style="overflow-x: scroll" <% end if %>>
            <table class="table table-condensed">
                <thead>
                    <tr class="info">
                        <th width="25%">Procedimento</th>
                        <th width="10%" nowrap>Tempo (min)</th>
                        <th width="10%">Forma</th>
                        <th width="15%">Valor / Convênio</th>
                        <th width="15%">Local</th>
                        <th width="15%">Equipamento</th>
                        <th width="1%">
                            <button type="button" id="addProcedimentos" onclick="adicionarProcedimentos()" class="btn btn-xs btn-success"><i class="far fa-plus"></i></button>
                        </th>
                        <script>
                        function adicionarProcedimentos(count=false,callback=false) {
                            if(callback && typeof callback == 'function'){
                                procs('I', 0, <%=LocalID%>, '<%=Convenios%>', '<%=GradeApenasProcedimentos%>', '<%=GradeApenasConvenios%>', '<%=EquipamentoID%>',count, (retorno)=>{
                                    callback(retorno)
                                });
                            }else{
                                procs('I', 0, <%=LocalID%>, '<%=Convenios%>', '<%=GradeApenasProcedimentos%>', '<%=GradeApenasConvenios%>', '<%=EquipamentoID%>',count)
                            }
                        }
</script>
                    </tr>
                </thead>
                <tbody id="bprocs">
                    <tr class="linha-procedimento" data-id="">
                        <td><%= selectInsert("", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""validaProcedimento(this.id, this.value);parametros(this.id, this.value); atualizarTempoProcedimentoProfissional(this)"" data-agenda="""" data-exibir="""&GradeApenasProcedimentos&"""", oti, "ConvenioID") %>
                        <% if not isnull(PacienteID) and false then %>
                            <br>
                            <button class="btn btn-warning btn-xs" type="button" onclick="openComponentsModal('procedimentosListagem.asp?ProcedimentoId=<%=ProcedimentoID%>&PacientedId=<%=PacienteID%>', true, 'Restrições', true, '')"><i class="far fa-caret-square-o-left"></i></button>
                            <button class="btn btn-success btn-xs" type="button" onclick="openComponentsModal('procedimentosModalPreparo.asp?ProcedimentoId=<%=ProcedimentoID%>&PacientedId=<%=PacienteID%>', true, 'Preparo', true, '')"><i class="far fa-lock"></i></button>
                        <% end if %>
                        </td>
                        
                        <td>
                            <%
                    TempoChange = ""
                    if aut("|agendaalteracaoprecadastroA|")=0 then
                        TempoChange=" readonly"
                    end if
                            %>
                            <%=quickField("number", "Tempo", "", 2, Tempo, "", "", " placeholder='Em minutos'"&TempoChange)%>
                        </td>
                        <td>
                            <%
                            if PermiteParticular then
                            %>
                            <div class="radio-custom radio-primary">
                                <input type="radio" onchange="parametros('ProcedimentoID', $('#ProcedimentoID').val());" name="rdValorPlano" id="rdValorPlanoV" required value="V" <% If rdValorPlano="V" Then %> checked="checked" <% End If %> class="ace valplan" onclick="valplan('', 'V')" style="z-index: -1" /><label for="rdValorPlanoV" class="radio"> Particular</label>
                            </div>
                            <%
                            end if
                    if Convenios<>"Nenhum" and (GradeApenasConvenios<> "|P|" or isnull(GradeApenasConvenios)) then
                            %>
                            <div class="radio-custom radio-primary">
                                <input type="radio" name="rdValorPlano" id="rdValorPlanoP" required value="P" <% If rdValorPlano="P" Then %> checked="checked" <% End If %> class="ace valplan" onclick="valplan('', 'P')" style="z-index: -1" /><label for="rdValorPlanoP" class="radio"> Conv&ecirc;nio</label>
                            </div>
                            <%end if %>
                        </td>
                        <td>
                            <div class="col-md-12" id="divValor" <% If rdValorPlano<>"V" Then %> style="display: none" <% End If %>>
                                <div class="row">
                                    <div class="col-md-12">
                                        <%
                                if aut("|valordoprocedimentoA|")=0 and aut("|valordoprocedimentoV|")=1 then
                                        %>
                                        <input type="hidden" id="Valor" name="Valor" class="valorprocedimento" value="<%=Valor%>">
                                        R$ <span id="ValorText"><%=Valor%></span>
                                        <script>
                                        $("#Valor").change(function() {
                                            $("#ValorText").html($(this).val());
                                        });
                                        </script>
                                        <% elseif aut("areceberpacienteV")=1 and aut("|valordoprocedimentoV|")=1 then
                                        %>
                                        <%=quickField("text", "Valor", "", 5, Valor, " text-right input-mask-brl valorprocedimento", "", "")%>
                                        <%
                                else
                                        %>
                                        <input type="hidden" id="Valor" name="Valor" value="<%=Valor%>" class="valorprocedimento" >
                                        <%
                                end if
                                        %>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-12" id="divConvenio" <% If rdValorPlano<>"P" Then %> style="display: none" <% End If %>>
                                <%

                        if not isnull(ConvenioID) and ConvenioID<>"" then
                            ObsConvenios = ""
                            set ConvenioSQL = db.execute("SELECT Obs FROM convenios WHERE id="&treatvalzero(ConvenioID)&"")
                            if not ConvenioSQL.eof then

                                 planosOptions = getPlanosOptions(ConvenioID, PlanoID)
                                 if planosOptions<>"" then
                                    %>
<script >
$(document).ready(function() {
  $("#divConvenio").after("<%=planosOptions%>");

    $("#PlanoID").select2();
})
</script>
                                    <%
                                end if

                                ObsConvenio = ConvenioSQL("Obs")

                                if ObsConvenio&""<>"" then
                                %>
                                <button title="Observações do convênio" id="ObsConvenios" style="z-index: 99; position: absolute; left: -16px" class="btn btn-system btn-xs" type="button" onclick="ObsConvenio(<%=ConvenioID%>)"><i class="far fa-align-justify"></i></button>
                                <%
                                end if
                            end if
                        end if

                        if Convenios="Todos" then

                                %>
                                <%=selectInsert("", "ConvenioID", ConvenioID, "convenios", "NomeConvenio", " data-exibir="""&GradeApenasConvenios&""" onchange=""parametros(this.id, this.value+'_'+$('#ProcedimentoID').val());""", "", "")%>
                                <%
                        else
                            if (len(Convenios)>2 or (isnumeric(Convenios) and not isnull(Convenios))) and instr(Convenios&" ", "Nenhum")=0 then
                                %>
                                <%=quickfield("simpleSelect", "ConvenioID", "", 12, ConvenioID, "select id, NomeConvenio from convenios where ativo='on' AND sysActive=1 and id in("&Convenios&") order by NomeConvenio", "NomeConvenio", " data-exibir="""&GradeApenasConvenios&""" onchange=""parametros(this.id, this.value);""") %>
                                <%
                            end if
                        end if
                                %>
                            </div>

                        </td>
                        <td><%
                    if aut("localagendaA")=0 then
                        call quickfield("simpleSelect", "LocalIDx", "", 2, LocalID, "select * from locais where sysActive=1", "NomeLocal", " disabled ")
                        response.write("<input type='hidden' name='LocalID' id='LocalID' value='"& LocalID &"'>")
                    else
                        if session("Banco")="clinic5760" and ProfissionalID<>"" and isnumeric(ProfissionalID) then
                            set lPro = db.execute("select Unidades from profissionais where id="& ProfissionalID)
                            if not lPro.eof then
                                unidadesP = replace(lPro("Unidades")&"", "|", "")
                                if unidadesP<>"" then
                                    sqlUnidadesP = " AND l.UnidadeID IN("& unidadesP &") "
                                end if
                            end if
                            call quickfield("simpleSelect", "LocalID", "", 5, LocalID, "select l.id, l.NomeLocal from locais l where sysActive=1 "& sqlUnidadesP &" order by NomeLocal", "NomeLocal", "")
                        else
                            call selectInsert("", "LocalID", LocalID, "locais", "NomeLocal", "", "", "")
                        end if
                    end if
                        %>
                        </td>
                        <td>
                            <%if req("Tipo")="Quadro" or req("EquipamentoID")="" or req("EquipamentoID")="undefined" or req("EquipamentoID")="0" then%>
                            <%=quickfield("select", "EquipamentoID", "", 2, EquipamentoID, "select * from equipamentos where ativo='on' and sysActive=1", "NomeEquipamento", "") %>
                            <%else
                                set equipSQL = db.execute("select NomeEquipamento from equipamentos where sysActive=1 and id="&EquipamentoID)
                                if not equipSQL.eof then
                                    NomeEquipamento = "<span>"&equipSQL("NomeEquipamento")&"</span>"
                                end if
                             %>
                            <input type="hidden" name="EquipamentoID" id="EquipamentoID" value="<%=EquipamentoID%>" />
                            <%=NomeEquipamento%>
                            <%end if %>
                        </td>
                        <td>
                            <div class="btn-group mt5">
                                <button type="button" class="btn btn-info btn-xs dropdown-toggle" data-toggle="dropdown" title="Gerar recibo" aria-expanded="false"><i class="far fa-print bigger-110"></i></button>
                                <ul class="dropdown-menu dropdown-info pull-right">
                                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Protocolo')"><i class="far fa-plus"></i> Protocolo de laudo </a></li>
                                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Impresso')"><i class="far fa-plus"></i> Impresso </a></li>
                                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Etiqueta')"><i class="far fa-plus"></i> Etiqueta </a></li>
                                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Preparos')"><i class="far fa-plus"></i> Preparos </a></li>
                                </ul>
                            </div>
                        </td>
                    </tr>
                    <%

                    'verifica se tem restricao
                    'set restricaoObj = new Restricao

                    'set RestricoesSQL = restricaoObj.getRestricoes(ProfissionalID, ProcedimentoID)

                    'while not RestricoesSQL.eof
                        %>
                        <!--<tr>
                            <td colspan="6"><%'restricaoObj.renderRestricao(RestricoesSQL("Descricao"), RestricoesSQL("Tipo"), RestricoesSQL("id"), RestricoesSQL("Restringir"), RestricoesSQL("Inicio"), RestricoesSQL("Fim"), RestricoesSQL("TextoSIM"), RestricoesSQL("TextoNAO"))%></td>
                        </tr>-->
                        <%
                    'RestricoesSQL.movenext
                    'wend
                    'RestricoesSQL.close
                    'set RestricoesSQL=nothing


            nProcedimentos = 0
            set ageprocs = db.execute("select * from agendamentosprocedimentos where AgendamentoID="& ConsultaID)
            contador = 1
            while not ageprocs.eof
                call linhaAgenda("-"&contador, ageprocs("TipoCompromissoID"), ageprocs("Tempo"), ageprocs("rdValorPlano"), ageprocs("ValorPlano"), ageprocs("PlanoID"),ageprocs("ValorPlano"), Convenios, ageprocs("EquipamentoID"), ageprocs("LocalID"), GradeApenasProcedimentos, GradeApenasConvenios, PermiteParticular)
                contador = contador + 1
  
            ageprocs.movenext
            wend
            ageprocs.close
            nProcedimentos = contador
            set ageprocs=nothing
                    %>
                </tbody>
            </table>
            <input type="hidden" id="nProcedimentos" value="<%= nProcedimentos %>" />
            <div id="totalProcedimentos">
            <% if aut("valordoprocedimentoV")= 1 then %>
                <p class="text-right">
                    Valor total: <b>R$  <span id="valortotal"></span></b>
                </p>
            <% end if %>
            </div>
        </div>
    </div>
<%
end if
%>

<!-- Modal -->
<div class="modal fade" id="modalFormaPagamento" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" data-backdrop="static" data-keyboard="false" aria-hidden="true">
  <div class="modal-dialog " role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Forma de recebimento
            <button type="button" class="close" data-dismiss="modal" onclick='clearValue()' aria-label="Fechar">
                <span aria-hidden="true">&times;</span>
            </button>
        </h5>
      </div>
      <div class="modal-body">
            <div id="forma-carregar" class="row">x</div>
            <div class="row">
                <div class="col-md-4 qf" id="qfnumero">
                    <br>
                    <label>Acrescimo</label>
                    <br>
                    <input type="text" class="form-control input-mask-brl text-right" name="acrescimoForma" id="acrescimoForma" value="" disabled="" onkeyup="onKeyUpDesconto()">
                 </div>
                <div class="col-md-4 qf" id="qfnumero">
                     <br>
                    <label>Desconto</label>
                    <br>
                    <input type="text" class="form-control input-mask-brl text-right" name="descontoForma"  id="descontoForma" value="" disabled=""  onkeyup="onKeyUpDesconto()">
                 </div>
                <div class="col-md-4 qf" id="qfnumero">
                    <br>
                    <label>Total</label>
                    <br>
                    <input type="text" class="form-control input-mask-brl text-right" name="totalvalue"  id="totalvalue" value="" disabled="">
                    <input type="hidden" class="form-control input-mask-brl text-right" name="invoicenew"  id="invoicenew" value="" disabled="">
                </div>
                <input id="valorTotalSomaItems" name="valorTotalSomaItems" type="hidden" value="">
            </div>
            <div id="box-autorizacao-desconto" class="row" style="display: none">
                <div class="col-xs-12" style="margin-top: 25px">
                    <div class="panel panel-warning">
                      <div class="panel-heading">Desconto máximo ultrapassado</div>
                      <div class="panel-body"></div>
                    </div>
                </div>
            </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" onclick='clearValue(); ' data-dismiss="modal">Fechar</button>
        <button id="btn-aguardar-autorizacao" type="button" class="btn btn-secondary" onclick="aguardarAutorizacaoDesconto(<%=Bloco%>)" style="display: none">Aguardar Autorização</button>
        <button type="button" id="salvar-mudancas" onclick='saveLanctoNovo(<%=Bloco%>);' class="btn btn-primary">Salvar mudanças</button>
      </div>
    </div>
  </div>
</div>



<script type="text/javascript">
$("#ageTabela").change(function() {
     checkParticularTableFields();
});

fazerCalculoItens = (valorItem, porcentagem) => {
    return (valorItem * porcentagem) / 100;
}

recalcularValorPagamento = (valorPagamento, acrescimo, desconto) => {      
    return (valorPagamento + acrescimo) - desconto;
}

gerarAcrescimoDesconto = (valorPagamento, acrescimo, tipo) => {
    if(acrescimo){
        acrescimo = parseFloat(acrescimo.replace(/[^0-9,]*/g, '').replace(',', '.'));
    }else{
        acrescimo = 0;
    }
    if(tipo == 'P') {
        return (valorPagamento * acrescimo) / 100;       
    }

    if(tipo == 'V') {  
        quantidadesProcedimentos = 0; 
        document.querySelector('#divAgendamentoCheckin').querySelectorAll('input').forEach(element => {	
            if(!(element.className.search('valorprocedimento') > -1)) {
                return;
            } 

            quantidadesProcedimentos++;
        });

        return acrescimo / quantidadesProcedimentos;
    }
}

function round(value, decimals) {
    return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

$("#ageMatricula1").change(function(){
    checkParticularTableFields();
});


$("#ageCPF").change(function(){
    checkParticularTableFields();
});

    async function  checkParticularTableFields (){

                <% if not isAmorSaude() and getConfig("ValidarCartaoClubFlex") <> 1 then %>
                return true;
                <% end if %>

                if(!$("#ageTabela").val()){
                    return true;
                }

                let particularTable = await endpointFindValidationRules($("#ageTabela").val());

                if(!particularTable){
                    return true;
                }

                if(particularTable.TipoValidacao !== 1)
                {
                    return true;
                }

                if(!$("#ageMatricula1").val()){
                    showMessageDialog("Preencha a campo matrícula","error");
                    return false;
                }

                <% if isAmorSaude() then %>
                    let returnEndpoint = await endpointGetMatricula($("#ageMatricula1").val());
                <% else %>
                    let passCpf = $("#ageCPF").val().replace(/\./g,"").replace("-","");
                    if(!passCpf){
                        showMessageDialog("Preencha a campo CPF","error");
                        return false;
                    }
                    let returnEndpoint = await endpointGetMatricula(passCpf + '|' + $("#ageMatricula1").val());
                <% end if %>

                let dataFromFeegow = returnEndpoint.data.dados;

                if(!returnEndpoint || !returnEndpoint.data){
                     showMessageDialog("Não foi possível validar a matrícula","error");
                     return false;
                }

                if(returnEndpoint.data.elegivel && dataFromFeegow.length > 0)
                {
                    let encontrado = false;
                    let cpfError = false;
                    let status = true;

                    $.each(dataFromFeegow,function(index,obj){
                        let cpf = obj.cpf
                        let choosenCpf = $("#ageCPF").val().replace(/\./g,"").replace("-","");
                        if(choosenCpf){
                            cpfError = true;
                            if(choosenCpf == cpf){
                                encontrado = true;
                                cpfError = false;
                            }
                        }else{
                            let arrayName = obj.nomeFiliado.trim().split(" ");
                            let choosenName = $("#select2-PacienteID-container").text();
                            if(!choosenName){
                                choosenName = $("#select2-PacienteID2-container").text();
                            }
                            let arrayChoosenName = choosenName.split(" ");

                            if(arrayChoosenName[0].toLowerCase() == arrayName[0].toLowerCase())
                            {
                                // validar isso com produto
                                if(obj.statusFiliado !== "Ativo" && obj.statusFiliado !== "OK"){
                                    showMessageDialog("Matrícula em Status: "+obj.statusFiliado,"error");
                                    status = false
                                    return false
                                }
                                encontrado = true;
                            }
                        }

                    });

                    // validar isso com produto - return caso não esteja ativo
                    if(!status){
                        return false
                    }


                    if(encontrado){
                        showMessageDialog("Matricula válida","success");
                        return true;
                    }

                    if(cpfError){
                        showMessageDialog("Esta matricula não pertence a esse cpf","error");
                        return;
                    }

                    showMessageDialog("Matricula não pertence a este paciente","error");
                    return;

                }else if(returnEndpoint.data && returnEndpoint.data.dados != undefined && returnEndpoint.data.dados[0] && returnEndpoint.data.dados[0].tipoSituacaoFinanceira === "Inadimplente"){
                    showMessageDialog("Matrícula não autorizado","error");
                    return;
                }

                showMessageDialog("Matrícula inválida","error");
                return false;
    };


const endpointGetMatricula = async (matricula) => {

    <% if isAmorSaude() then %>
        const ans = '140188';
        const by  = 'cpf';
    <% else %>
        const ans = 'DNA';
        const by  = 'cartao';
    <% end if %>

    let url = `${domain}/autorizador/elegivel/${ans}/${by}/${matricula}`;
    return $.ajax({
        type: 'GET',
        url: url,
        async: false,
        dataType: 'json',
        done: function(results) {

        },
        fail: function( jqXHR, textStatus, errorThrown ) {
            console.log( 'Could not get posts, server response: ' + textStatus + ': ' + errorThrown );
        }
    }).responseJSON;
};

const endpointFindValidationRules = async (idTable) => {
    let url = domain+"medical-report-integration/verify-validation-type";
    const response = await $.ajax({
        type: 'POST',
        url: url,
        //async: false,
        dataType: 'json',
        data:{"particularTableId":idTable},
        done: function(results) {

        },
        error: function( jqXHR, textStatus, errorThrown ) {
            showMessageDialog("Não foi possível validar a matrícula.");
        }
    });

    return response;
};

atualizarValores = (acrescimoTotal, descontoTotal, valorTotalSomadoFormaPagamento) => {
    document.getElementById('acrescimoForma').value = round(acrescimoTotal, 2).toLocaleString("pt-BR", { minimumFractionDigits: 2 }); 
    document.getElementById('descontoForma').value = round(descontoTotal, 2).toLocaleString("pt-BR", { minimumFractionDigits: 2 }); 
    document.getElementById('valorTotalSomaItems').value = round(valorTotalSomadoFormaPagamento, 2).toLocaleString("pt-BR", { minimumFractionDigits: 2 }); 
    document.getElementById('totalvalue').value = document.getElementById('valorTotalSomaItems').value;
}

fillResponseGetFormaPagamento = responseJson => {
    if(responseJson[0] != '' && responseJson[0] != undefined){       
        return responseJson[0];
    }
    
    return responseJson;
}

function getFormaPagamento() {    
    var valorTotalSomadoFormaPagamento = 0;
    var acrescimoTotal = 0;
    var descontoTotal = 0;
    
    let keyItemFormaPagamentoSelecionado = document.getElementById('FormaID').selectedIndex;
    let elementOptionsSelecionado = document.getElementById("FormaID").options[keyItemFormaPagamentoSelecionado];    
    let sysFormasrectoId = elementOptionsSelecionado.dataset.frid;

    let response = null;
    const header = { method: 'GET', cache: 'default' }; 

    let acrescimo = undefined;
    let desconto = undefined;
   
    fetch(`getFormaPagamento.asp?sysFormasrectoId=${sysFormasrectoId}`, header)
        .then(promiseResponse => {
            promiseResponse.json().then(responseJson => {
                const procedimentos = getProcedimentosCheckin();
                procedimentos.map(pro => {

                    responseFormaPagamento = fillResponseGetFormaPagamento(responseJson);

                    acrescimo = gerarAcrescimoDesconto(pro.valor, responseFormaPagamento.acrescimo, responseFormaPagamento.tipoAcrescimo);
                    desconto = gerarAcrescimoDesconto(pro.valor, responseFormaPagamento.desconto, responseFormaPagamento.tipoDesconto);

                    acrescimo = (acrescimo != undefined) ? acrescimo : 0;
                    desconto = (desconto != undefined) ? desconto : 0;
                                        
                    valorTotalSomadoFormaPagamento += ((pro.valor + acrescimo) - desconto);

                    acrescimoTotal += acrescimo;
                    descontoTotal += desconto;
                });

                if (isNaN(valorTotalSomadoFormaPagamento)) {
                    valorTotalSomadoFormaPagamento = 0;
                }

                atualizarValores(acrescimoTotal, descontoTotal, valorTotalSomadoFormaPagamento);
            
                document.getElementById("salvar-mudancas").disabled = true;
                $("#acrescimoForma, #descontoForma").prop('disabled', 'disabled');

                if (elementOptionsSelecionado.value != "") {
                    document.getElementById("salvar-mudancas").disabled = false;
                    if (temRegraCadastradaProUsuario) {
                        $("#acrescimoForma, #descontoForma").prop('disabled', '');
                    }
                }
            });
        });   
}

function geraParcelas(){
    var invoice = '<%= req("I") %>';

    if(invoice == '') {
        invoice = '<%= ItemInvoiceID %>'
    }        

    $.post("invoiceParcelas.asp?I="+invoice+"&T=C&Recalc=N&chamaParcelas=N", $("#formItens").serialize(), function(data, status){ $("#invoiceParcelas").html(data) });	
}

function formaRectoCheckin(FormaIDSelecionado = null, ItemInvoiceID = null) {    
    if(FormaIDSelecionado == null) {       
	    FormaIDSelecionado = ($("#FormaID option:selected").val());
    }

    if(ItemInvoiceID == null) {

        if(typeof invoiceId !== "undefined"){
            ItemInvoiceID = invoiceId;
        }else{
            ItemInvoiceID = '<%=ItemInvoiceID %>';
        }
    }

    $.post("invoiceSelectPagto.asp?I="+ItemInvoiceID+"&T=C&FormaID="+ $("#FormaID option:selected").attr("value")+"&chamaParcelas=N", "FormaID="+FormaIDSelecionado, function(data, status) { 
        $("#forma-carregar").html(data);

        document.getElementById("FormaID").addEventListener("change", _ => {
            getFormaPagamento();
        }, false); 

        getFormaPagamento();
    });
}

function allRepasses(){
	$("input[name^=Executado]").each(function(index, element) {
        if( $(this).prop('checked')==true ){
			id = $(this).attr('id');
			id = id.replace('Executado', '');
			calcRepasse(id);
		}
    });
}

// Esconder a div de consulta e mostrar a guia de agendamento
function showOriginalCheckinTab() {
    if (document.getElementById("dadosGuiaConsulta")) {
        $("#dadosGuiaConsulta").remove();
    }

    if ($(".abaAgendamento.active")[0].id === "liAgendamento" && document.getElementById("dadosAgendamento")) {
        $("#dadosAgendamento").addClass("active");
    }
}

atualizarTempoProcedimentoProfissional = (self) => {    
    let header = { method: 'GET',
                   cache: 'default' };

    let profissionalId = '<%=ProfissionalID%>';
    let procedimentoId = (new jQuery.fn.init(self)).select2('val');
    fetch(`AgendaParametros.asp?idProcedimento=${procedimentoId}&idProfissional=${profissionalId}&ProcedimentoTempoProfissional=true`, header)
		.then(promiseResponse => {
			    promiseResponse.json().then((ResponseJson) => {
                    if(ResponseJson.tempo != ''){
                        setTimeout(() => {
                           if(ResponseJson.tempo != undefined) {
	                            self.parentElement.nextElementSibling.querySelectorAll("input")[0].value = ResponseJson.tempo;
	                        }
	                    }, 50);        
                    }   
                })
            }
        );
};

function verificaRestricao($ipt, restringir, min, max, textoSim, textoNao) {
    var $btnSalvar = $("#btnSalvarAgenda"),
        $parent = $($($ipt).parents("div")[0]),
        valorPreenchido = $($ipt).val(),
        habilitaSalvar = true;

    min = parseFloat(min);
    max = parseFloat(max);

    if(restringir==="F"){
        valorPreenchido = parseFloat(valorPreenchido);

        if(valorPreenchido < min || valorPreenchido > max){
            habilitaSalvar = false;
        }
    }else if(restringir==="D"){
        valorPreenchido = parseFloat(valorPreenchido);

        if(valorPreenchido >= min && valorPreenchido <= max){
            habilitaSalvar = false;
        }
    }else if(restringir==="S"){
        if(valorPreenchido === "S"){
            habilitaSalvar = false;
        }
    }else if(restringir==="N"){
        if(valorPreenchido === "N"){
            habilitaSalvar = false;
        }
    }

    $(".aviso-restricao").remove();

    var mostraAviso = function(data){
        $parent.after(data)
    };

    var getSpanColor = function(color, content) {
        return "<span class='aviso-restricao' style='color: "+color+"'>"+content+"</span>";
    };

    if(valorPreenchido === "S" || valorPreenchido === "N"){
        if(valorPreenchido === "S" && textoSim){
            mostraAviso(getSpanColor("red",textoSim));
        }
        if(valorPreenchido === "N" && textoNao){
            mostraAviso(getSpanColor("red",textoNao));
        }
    }

    $btnSalvar.attr("disabled", !habilitaSalvar)
}

function validaProcedimento(id,value){

    $("#rdValorPlanoV").removeAttr("disabled");
    $("#rdValorPlanoV").parent().removeClass("radio-disabled");

    $.ajax('agendamentoProcedimentos.asp?validaParticular='+value, {
        success: function(res) {
            let json = JSON.parse(res);
            if(!json){
                return;
            }
            if(!(json.length > 0)){
                return;
            }

            json = json[0];

            $("#EquipamentoID").val(json.EquipamentoPadrao).change();
            $("#EquipamentoID").select2();
            
            if(json.NaoParticular == "1"){
                $("#rdValorPlanoV").parent().addClass("radio-disabled");
                $("#rdValorPlanoV").attr("disabled","disabled");
            }
        }
    });
    // console.log(id,value);
}

function GeraGuia(TipoGuia) {

    if (TipoGuia=='Simplificada')
    {
        var url  = 'tissguiaSimplificada.asp?P=tissguia'+TipoGuia+'&I=N&Pers=1&Lancto=<%=ConsultaID%>|agendamento';
    }
    else if(TipoGuia == "SADT")
    {
        var url  = 'tissguiasadt.asp?P=tissguiasadt&I=N&Pers=1&ApenasProcedimentosNaoFaturados=S&Lancto=<%=ConsultaID%>|agendamento';
    }else{
        var url  = 'tissguiaconsulta.asp?P=tissguia'+TipoGuia+'&I=N&Pers=1&Lancto=<%=ConsultaID%>|agendamento';
    }

    $.ajax(url, {
        success: function(res) {
            if (res) {
                $("#divHistorico").html("");
                $("#tabContentCheckin").append("<div id='dadosGuiaConsulta'></div>");
                var divAgendamento = $("#dadosGuiaConsulta");
                divAgendamento.html(res);
                $("#dadosAgendamento").removeClass("active");
            }
        }
    });

}
$(document).ready(function(){
    //formaRecto(<%=FormaIDSelecionado %>);
    allRepasses();
    
    $('.abaAgendamento').on('click',  function() {
        $("#dadosGuiaConsulta").remove();
        if ($(this)[0].id === "liAgendamento") {
            $("#dadosAgendamento").addClass("active");
        }
    })

});
</script>