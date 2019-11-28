<!--#include file="Classes/Restricao.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
function linhaPagtoCheckin(strTipoGuia, rdValorPlano, ClasseLinha, IDMovementBill)


    %>
    <tr class="<%=ClasseLinha%>">
        <td class="default" colspan="10" style="border-top:none">

            <%
            if rdValorPlano="V" then
                Rotulo = "RECEBER"

                recebimentoFunc = "onclick='lanctoCheckin("""&Bloco &""", """&IDMovementBill&""")'"
                recebimentoFuncCaixinha=""

                if aut("|contasareceberI|")=0 and session("CaixaID")="" and aut("|aberturacaixinhaI|") then
                    recebimentoFunc="data-toggle='tooltip' title='Você precisar abrir o caixinha'"
                    recebimentoFuncCaixinha="data-toggle='tooltip' title='Você precisar abrir o caixinha'"
                    styleDisabled = "style='cursor: not-allowed; opacity:0.65'"
                end if                
                
                if getConfig("ObrigarFormaRecebimentoCheckin") = "1" then %>
                    <button type="button" class="ckpagar btn btn-xs btn-warning" <%=styleDisabled%> <%=recebimentoFuncCaixinha%> data-toggle="modal" onclick='lanctoCheckinNovoUpdate(<%=Bloco%>)'>
                        <i class="fa fa-arrow-circle-up"></i> <%= Rotulo %>
                    </button>                    
                <% else %>
                    <button type="button" class="ckpagar btn btn-xs btn-warning" <%=styleDisabled%> <%=recebimentoFunc%> ><i class="fa fa-arrow-circle-up"></i> <%= Rotulo %></button>
                <% end if %>
                <!-- Botão para acionar modal -->
               
                
                <%
            else
                spl = split(strTipoGuia, ", ")
                for i=0 to ubound(spl)
                    TipoGuia = spl(i)
                    Rotulo = "Guia de "& TipoGuia
                    %>
                    <button type="button" id="btnAgGuia<%=TipoGuia%>" onclick="GeraGuia('<%=TipoGuia%>')" class="btn btn-xs btn-warning"><i class="fa fa-arrow-circle-up"></i> <%= ucase(Rotulo) %></button>
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
    <table class="table table-condensed table-hover">
    <%
    sql = "SELECT t.*, if(isnull(proc.TipoGuia) or proc.TipoGuia='', 'Consulta, SADT', proc.TipoGuia) TipoGuia, IF(rdValorPlano='V', 'Particular', conv.NomeConvenio) NomeConvenio, tpv.Valor ValorConvenio, proc.id as ProcedimentoID, proc.Valor valorProcedimentoOriginal FROM ("&_
    "SELECT '' id, a.rdValorPlano, a.ValorPlano, a.TipoCompromissoID, a.Tempo, a.LocalID, a.EquipamentoID,a.PlanoID from agendamentos a where id="& ConsultaID &_
    " UNION ALL "&_
    " SELECT ap.id, ap.rdValorPlano, ap.ValorPlano, ap.TipoCompromissoID, ap.Tempo, ap.LocalID, ap.EquipamentoID,ap.PlanoID FROM agendamentosprocedimentos ap "&_
    " WHERE AgendamentoID="& ConsultaID &_
    ") t "&_
    " LEFT JOIN procedimentos proc ON proc.id=t.TipoCompromissoID "&_
    " LEFT JOIN tissprocedimentosvalores tpv ON tpv.ProcedimentoId = t.TipoCompromissoID AND (tpv.ConvenioID=t.ValorPlano AND t.rdValorPlano='P')  "&_
    " LEFT JOIN convenios conv ON (conv.id=t.ValorPlano AND t.rdValorPlano='P') "&_
    " ORDER BY t.rdValorPlano DESC, t.ValorPlano, proc.TipoGuia"

    'response.write(sql)
    set agp = db.execute( sql )
    'UrdValorPlano = agp("rdValorPlano")
    blocoPend = 0
    blocoPendParcial = 0
    Bloco = 0
    ValorConvenio = ""
    while not agp.eof

        procedimentos = ""

        if agp("rdValorPlano")="V" then
            PermitirFaturamentoContaZerada = getConfig("PermitirFaturamentoContaZerada")

            if PermitirFaturamentoContaZerada="0" and agp("ValorPlano")=0 then
                staPagto = "success"
            else
            ItemInvoiceID = "null"  
            FormaIDSelecionado = ""
            TipoCompromissoIDSe = agp("TipoCompromissoID")
                sqlQuitacao = "select mov.id MovementID, i.FormaID, ii.InvoiceID as InvoiceID, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorItem, ifnull((select sum(Valor) from itensdescontados where ItemID=ii.id), 0) TotalQuitado from itensinvoice ii "&_
                                              " INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                                              " INNER JOIN sys_financialmovement mov ON mov.InvoiceID=i.id "&_
                                              " WHERE i.AccountID="& PacienteID &" and AssociationAccountID=3 "&_
                                              " AND ii.ItemID="& TipoCompromissoIDSe &" "&_
                                              " AND (ISNULL(DataExecucao) OR DataExecucao=CURDATE()) "&_
                                              " AND (ISNULL(ProfissionalID) or ProfissionalID=0 OR ProfissionalID="& treatvalnull(ProfissionalID) &") and ii.Executado!='C' order by 2"
                set vcaIIPaga = db.execute(sqlQuitacao)
                if not vcaIIPaga.eof then
                    ItemInvoiceID = vcaIIPaga("InvoiceID")    
                    FormaIDSelecionado = vcaIIPaga("FormaID")       
                    if round(agp("ValorPlano"),2)<=round(vcaIIPaga("TotalQuitado"),2) then
                        staPagto = "success"

                    else
                        if round(vcaIIPaga("TotalQuitado"),2) > 1 then
                            staPagto = "warning"
                            MovementID=vcaIIPaga("MovementID")

                        else
                            staPagto = "danger"
                        end if
                    end if
                else
                    staPagto = "danger"
                end if

            end if
            
        else
            staPagto = "danger"'verifica as guias antes de dar DANGER
        end if

      '  response.write(FormaIDSelecionado)

        if UTipoGuia<>"" and UTipoGuia<>agp("TipoGuia") and blocoPend=1 then
            call linhaPagtoCheckin( UTipoGuia, UrdValorPlano, "danger", "" )
        end if
        if UrdValorPlano<>agp("rdValorPlano") or (UrdValorPlano="P" and UValorPlano<>agp("ValorPlano")) then
            Bloco = Bloco + 1

            %>
            <tr class="info" data-position="<%=Bloco%>" data-tipo="<%=UTipoGuia%>">
                <th width="1%"></th>
                <th width="30%"><%= agp("NomeConvenio") %></th>
                <th width="5%">Tempo</th>
                <th colspan="2" width="30%">Forma</th>
                <th width="20%">Local</th>
                <th width="20%">Equipamento</th>
                <th></th>
            </tr>
            <%
            blocoPend = 0
        end if
                'response.write( agp("TipoGuia") &" { "& UTipoGuia &" } [ "& UrdValorPlano &" ]<br>")
        %>

        <%idagp = agp("id")%>
        <input type="hidden" class="linha-procedimento-id" value="<%=agp("ProcedimentoID")%>"> 
        <input type="hidden" class="linha-procedimento-id-daPro" name="daPro" data-idPro="<%=idagp%>" value="<%=agp("valorProcedimentoOriginal")%>">
        <%= linhaAgenda(idagp, agp("TipoCompromissoID"), agp("Tempo"), agp("rdValorPlano"), agp("ValorPlano"), agp("PlanoID"), agp("ValorPlano"), Convenios, agp("EquipamentoID"), agp("LocalID"), GradeApenasProcedimentos, GradeApenasConvenios) %>


        <%
        UrdValorPlano = agp("rdValorPlano")
        UValorPlano = agp("ValorPlano")
        ValorConvenio = agp("ValorConvenio")
        UTipoGuia = agp("TipoGuia")
        if staPagto="danger" then
            blocoPend = 1
        end if
        if staPagto="warning" then
            blocoPendParcial = 1
        end if
    agp.movenext
    wend
    agp.close
    set agp = nothing

    if blocoPend=1 then
        if UrdValorPlano = "V" or (UrdValorPlano = "P" and ValorConvenio&"" <> "") then
            call linhaPagtoCheckin( UTipoGuia, UrdValorPlano , "danger", "" )
        end if
    elseif blocoPendParcial=1 then
        if UrdValorPlano = "V" or (UrdValorPlano = "P" and ValorConvenio&"" <> "") then
            call linhaPagtoCheckin( UTipoGuia, UrdValorPlano , "warning", MovementID )
        end if
    else
        %>
<script >
$("#btnSalvarAgenda").attr("disabled", false).removeClass("disabled")
</script>
        <%
    end if
    %>
    </table>

    <script type="text/javascript">
        $('[data-toggle="tooltip"]').tooltip();

        function abrirPagar(MovementID) {
            $("#dadosAgendamento").append("<input class=\"parcela\" type=\"hidden\" name=\"Parcela\" value=\"|"+MovementID+"|\" />");

            $("#pagar").fadeIn();

            $( "#pagar" ).draggable();

            $("#pagar").html("Carregando...");
            $.post("Pagar.asp?T=C", {
                Parcela: '|'+MovementID+'|'
                }, function (data) {
                    $("#pagar").html(data);
                });

        }

        function lanctoCheckin(Bloco, IDMovementBill) {
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


        function lanctoCheckinNovoUpdate(Bloco) {

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

            $.post('checkinLanctoUpdate.asp', {
                    valor : valor,
                    procedimento : procedimento,
                    AgendamentoID : AgendamentoID,
                    ProfissionalID : ProfissionalID
                }, function(val1) {
                    formaRectoCheckin(null, null);
                    $.post("saveAgenda.asp?PreSalvarCheckin=1", $("#formAgenda").serialize(), function(data) {

                    if(data.indexOf("Erro") !== -1) {
                        eval(data);
                        return;
                    } else {
                        $('#modalFormaPagamento').modal('show');
                    }
               });
            });
        }

        function clearValue() {
            document.getElementById('acrescimoForma').value = '0,00';
            document.getElementById('descontoForma').value = '0,00';
            document.getElementById('totalvalue').value = '0,00';
        }

        function saveLanctoNovo(Bloco){
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

            valorTotalSomaItems = document.getElementById('valorTotalSomaItems').value;
            var bloco = $(".Bloco" + Bloco).serialize()+"&valorTotalSomadoModificado="+valorTotalSomaItems+"&FormaID="+sysFormasrectoId+"&ContaRectoID="+ContaRectoID;

            $.post("checkinLancto.asp", bloco, function (v) { 
                $('#divLanctoCheckin').html(v);
                clearValue();
            });            
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
                            <button type="button" id="addProcedimentos" onclick="adicionarProcedimentos()" class="btn btn-xs btn-success"><i class="fa fa-plus"></i></button>
                        </th>
                        <script>
                        function adicionarProcedimentos() {
                           procs('I', 0, <%=LocalID%>, '<%=Convenios%>', '<%=GradeApenasProcedimentos%>', '<%=GradeApenasConvenios%>', '<%=EquipamentoID%>');
                        }
</script>
                    </tr>
                </thead>
                <tbody id="bprocs">
                    <tr class="linha-procedimento" data-id="">
                        <td><%= selectInsert("", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""validaProcedimento(this.id, this.value);parametros(this.id, this.value); atualizarTempoProcedimentoProfissional(this)"" data-agenda="""" data-exibir="""&GradeApenasProcedimentos&"""", oti, "ConvenioID") %>
                        <% if not isnull(PacienteID) and false then %>
                            <br>
                            <button class="btn btn-warning btn-xs" type="button" onclick="openComponentsModal('procedimentosListagem.asp?ProcedimentoId=<%=ProcedimentoID%>&PacientedId=<%=PacienteID%>', true, 'Restrições', true, '')"><i class="fa fa-caret-square-o-left"></i></button>
                            <button class="btn btn-success btn-xs" type="button" onclick="openComponentsModal('procedimentosModalPreparo.asp?ProcedimentoId=<%=ProcedimentoID%>&PacientedId=<%=PacienteID%>', true, 'Preparo', true, '')"><i class="fa fa-lock"></i></button>
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
                            <div class="radio-custom radio-primary">
                                <input type="radio" name="rdValorPlano" id="rdValorPlanoV" required value="V" <% If rdValorPlano="V" Then %> checked="checked" <% End If %> class="ace valplan" onclick="valplan('', 'V')" style="z-index: -1" /><label for="rdValorPlanoV" class="radio"> Particular</label>
                            </div>
                            <%
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
                            set ConvenioSQL = db.execute("SELECT Obs FROM convenios WHERE id="&ConvenioID&"")
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
                                <button title="Observações do convênio" id="ObsConvenios" style="z-index: 99; position: absolute; left: -16px" class="btn btn-system btn-xs" type="button" onclick="openModal('<%=replace(replace(ObsConvenio,chr(10),"<br>"),chr(13),"<br>")%>', 'Observações do convênio', true, false, 'md')"><i class="fa fa-align-justify"></i></button>
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
                                <%=quickfield("simpleSelect", "ConvenioID", "Conv&ecirc;nio", 12, ConvenioID, "select id, NomeConvenio from convenios where ativo='on' and id in("&Convenios&") order by NomeConvenio", "NomeConvenio", " data-exibir="""&GradeApenasConvenios&""" onchange=""parametros(this.id, this.value);""") %>
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
                                <button type="button" class="btn btn-info btn-xs dropdown-toggle" data-toggle="dropdown" title="Gerar recibo" aria-expanded="false"><i class="fa fa-print bigger-110"></i></button>
                                <ul class="dropdown-menu dropdown-info pull-right">
                                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Protocolo')"><i class="fa fa-plus"></i> Protocolo de laudo </a></li>
                                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Impresso')"><i class="fa fa-plus"></i> Impresso </a></li>
                                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Etiqueta')"><i class="fa fa-plus"></i> Etiqueta </a></li>
                                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Preparos')"><i class="fa fa-plus"></i> Preparos </a></li>
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
            while not ageprocs.eof
                call linhaAgenda(ageprocs("id"), ageprocs("TipoCompromissoID"), ageprocs("Tempo"), ageprocs("rdValorPlano"), ageprocs("ValorPlano"), ageprocs("PlanoID"),ageprocs("ValorPlano"), Convenios, ageprocs("EquipamentoID"), ageprocs("LocalID"), GradeApenasProcedimentos, GradeApenasConvenios)
            ageprocs.movenext
            wend
            ageprocs.close
            set ageprocs=nothing
                    %>
                </tbody>
            </table>
            <input type="hidden" id="nProcedimentos" value="<%= nProcedimentos %>" />
            <div id="totalProcedimentos">
                <p class="text-right">
                    Valor total: <b>R$  <span id="valortotal"></span></b>
                </p>
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
        <h5 class="modal-title" id="exampleModalLabel">Forma de recebimento</h5>
        <button type="button" class="close" data-dismiss="modal" onclick='clearValue()' aria-label="Fechar">
            <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body" style="display: flow-root;">            
                <div id="forma-carregar">x</div>
                <div class="col-md-4 qf" id="qfnumero">  
                <br> 
                <label>Acrescimo</label>
                <br>              
                <input type="text" class="form-control input-mask-brl text-right" name="acrescimoForma" id="acrescimoForma" value="" disabled="">
                 </div>
                <div class="col-md-4 qf" id="qfnumero">
                 <br>    
                <label>Desconto</label>
                <br>
                <input type="text" class="form-control input-mask-brl text-right" name="descontoForma"  id="descontoForma" value="" disabled="">
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
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" onclick='clearValue(); ' data-dismiss="modal">Fechar</button>
        <button type="button" id="salvar-mudancas" data-dismiss="modal" onclick='saveLanctoNovo(<%=Bloco%>);' class="btn btn-primary">Salvar mudanças</button>
      </div>
    </div>
  </div>
</div>















<script type="text/javascript">
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


atualizarValores = (acrescimoTotal, descontoTotal, valorTotalSomadoFormaPagamento) => {
    document.getElementById('acrescimoForma').value = round(acrescimoTotal, 2).toLocaleString(undefined, { minimumFractionDigits: 2 }); 
    document.getElementById('descontoForma').value = round(descontoTotal, 2).toLocaleString(undefined, { minimumFractionDigits: 2 }); 
    document.getElementById('valorTotalSomaItems').value = round(valorTotalSomadoFormaPagamento, 2).toLocaleString(undefined, { minimumFractionDigits: 2 }); 
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
                document.querySelector('#divAgendamentoCheckin').querySelectorAll('input').forEach((element, key) => {	
                    if(!(element.className.search('valorprocedimento') > -1)) {
                        return;
                    }

                    let valorPagamentoFormatado = parseFloat(element.dataset.valor.replace(/[^0-9,]*/g, '').replace(',', '.'));

                    responseFormaPagamento = fillResponseGetFormaPagamento(responseJson);                   

                    acrescimo = gerarAcrescimoDesconto(valorPagamentoFormatado, responseFormaPagamento.acrescimo, responseFormaPagamento.tipoAcrescimo);
                    desconto = gerarAcrescimoDesconto(valorPagamentoFormatado, responseFormaPagamento.desconto, responseFormaPagamento.tipoDesconto);

                  //  console.log('loop')

                    //console.log(acrescimo);
                   // console.log(desconto);

                    acrescimo = (acrescimo != undefined) ? acrescimo : 0;
                    desconto = (desconto != undefined) ? desconto : 0;
                                        
                    valorTotalSomadoFormaPagamento += ((valorPagamentoFormatado + acrescimo) - desconto);

                    acrescimoTotal += acrescimo;
                    descontoTotal += desconto;
                });

                if (isNaN(valorTotalSomadoFormaPagamento)) {
                    valorTotalSomadoFormaPagamento = 0;
                }

                atualizarValores(acrescimoTotal, descontoTotal, valorTotalSomadoFormaPagamento);
            
                document.getElementById("salvar-mudancas").disabled = false;
                if(elementOptionsSelecionado.value == "") {
                    document.getElementById("salvar-mudancas").disabled = true;
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
	                    }, 200);        
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

            if(json.NaoParticular == "1"){
                $("#rdValorPlanoV").parent().addClass("radio-disabled");
                $("#rdValorPlanoV").attr("disabled","disabled");
            }
        }
    });
    console.log(id,value);
}

function GeraGuia(TipoGuia) {
    $.ajax('tissguiaconsulta.asp?P=tissguia'+TipoGuia+'&I=N&Pers=1&Lancto=<%=ConsultaID%>|agendamento', {
        success: function(res) {
            if (res) {
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
    
    $(document).on('click', '.abaAgendamento', function() {
        $("#dadosGuiaConsulta").remove();
        if ($(this)[0].id === "liAgendamento") {
            $("#dadosAgendamento").addClass("active");
        }
    })
    
    $(document).on('click', "#btnAgGuiaSADT", function() {
        $.ajax('tissguiasadt.asp?P=tissguiasadt&I=N&Pers=1&Lancto=<%=ConsultaID%>|agendamento', {
            success: function(res) {
                if (res) {
                    $("#tabContentCheckin").append("<div id='dadosGuiaConsulta'></div>");
                    var divAgendamento = $("#dadosGuiaConsulta");
                    divAgendamento.html(res);
                    $("#dadosAgendamento").removeClass("active");
                }
            }
        });
    });
});
</script>