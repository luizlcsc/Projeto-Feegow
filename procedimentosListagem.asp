<!--#include file="connect.asp"-->
<%
ProcedimentoID  = req("ProcedimentoId")
ProfissionalID = req("ProfissionalID")&""
PacientedIdq    = req("PacientedId")
ExcecaoID       = req("ExcecaoID")
Checkin         = req("Checkin")
Requester       = req("requester")
CriarPendencia  = req("criarPendencia")
totalPreparo    = req("totalPreparo")
limitarCheckin  = ""

if Checkin <> "" then
    limitarCheckin = " AND ExibirCheckin = 'S' "
end if

if ProfissionalID <> "" then
    where = " SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalID&" AND "
else
    where = " "
end if

sql = " SELECT distinct RestricaoID, r.Descricao, Tipo, (SELECT prf2.ExcecaoID "&_
    "                                                    FROM procedimentosrestricaofrase prf2 "&_
    "                                                   WHERE prf2.RestricaoID = prf.RestricaoID "&_
    "                                                     AND ProcedimentoID IN ("&ProcedimentoID&") AND (ExcecaoID IN ((SELECT id FROM procedimentosrestricoesexcecao WHERE "&where&" ProcedimentoID IN ("&ProcedimentoID&"))) OR ExcecaoID = 0)  ORDER BY 1 "&_
    "                                              DESC LIMIT 1) ExcecaoID, RestricaoSemExcecao  "&_
    "   FROM procedimentosrestricaofrase prf "&_
    "   JOIN sys_restricoes r ON r.id = prf.RestricaoID "&_
    "  WHERE ProcedimentoID IN ("&ProcedimentoID&") "&_
    "    AND (ExcecaoID IN ((SELECT id FROM procedimentosrestricoesexcecao WHERE "&where&" ProcedimentoID IN ("&ProcedimentoID&"))) OR ExcecaoID = 0) "&limitarCheckin&_
    " ORDER BY 4,2 "


set procedimentosExcecaoPadrao = db.execute(sql)

if procedimentosExcecaoPadrao.eof = true then  
%>
    <!-- div class="col-md-12" style="margin: 10px 0 0 0;">            
    <div class="alert alert-warning" role="alert">
        Não existem restrições para esse procedimento
    </div -->
<%
if CriarPendencia = "Sim" then
    totalPreparo = 0
end if

    if totalPreparo > 0 then

    else 

        if Requester <> "MultiplaPorFiltro" and CriarPendencia <> "Sim" then
%>
            <button type="button" class="btn btn-primary" id="avancar" onclick="avancar()">Avançar</button>

            <script>
                function avancar(){
                    abrirAgenda2();
                    $('.modalpendencias').modal('hide')
                }
            </script>
<% 
        elseif CriarPendencia = "Sim" then

%>
            <!-- button type="button" class="btn btn-primary" id="avancarPendencia" onclick="avancar()">Avançar</button -->
            <script>
                    var pendencias = [];
                    var $pendenciasSelecionadas = $("input[name='BuscaSelecionada2']:checked");
                    $.each($pendenciasSelecionadas, function() {
                        pendencias.push($(this).val())
                    });
                    $(".modalpendencias").modal("hide");

                    AbrirPendencias(0, pendencias)

            </script>
<%
        end if 
    end if
%>
    <!--/div-->
<% 
else
%>
<style>
    #tblRestricoes{
        border-collapse: collapse;
        width: 100%;
    }

    #tblRestricoes td, #tblRestricoes th {
        border: 0.5px solid #FDF0D4;
        padding: 8px;
    }

     #tblRestricoes tr:hover {background-color: #FEF5E2;}

    #tblRestricoes th {
        padding-top: 12px;
        padding-bottom: 12px;
        text-align: left;
        background-color: #F5B125;
        color: white;
    }
</style>
<div class="row">
    <div class="col-md-12">
    <form id="procedimentos_restricoes_form" name="procedimentos_restricoes_form">
        <input type="hidden" id="irParaPendencia" value="<%=CriarPendencia%>">
        <input type="hidden" id="totalPreparo" value="<%=totalPreparo%>">
        <input type="hidden" id="requester" value="<%=Requester%>">
        <table id="tblRestricoes" style="background-color:white">
<%
            exibeCabecalho = true
            ExcecaoIDAnterior = 0

            while not procedimentosExcecaoPadrao.eof

                if ccur(procedimentosExcecaoPadrao("ExcecaoID")) = 0 and exibeCabecalho then
                    titulo = "padrão"
                    
                elseif ccur(procedimentosExcecaoPadrao("ExcecaoID")) > 0 then

                    if ccur(ExcecaoIDAnterior) = 0 then
                            exibeCabecalho = true
                            titulo = "do profissional"
                    end if
                end if

                if exibeCabecalho then
%>
                <thead>
                    <tr class="dark">
                        <th width="30%">
                            <%="Restrições "&titulo%>
                        </th>
                        <th>
                            Valor
                        </th>
                        <th width="1%">

                        </th>
                    </tr>
                </thead>
<%
                end if
                
                ExcecaoIDAnterior = procedimentosExcecaoPadrao("ExcecaoID")
                exibeCabecalho = false 
                
                sqlResposta = "SELECT RespostaMarcada, Resposta, Observacao FROM restricoes_respostas WHERE PacienteID = "&PacientedIdq&" AND RestricaoID = "&procedimentosExcecaoPadrao("RestricaoID") 

                set respostas = db.execute(sqlResposta)

                sqlValorRestricao =  " SELECT Horas, Dias, Inicio, Fim, Restringir, MostrarPorPadrao, CaixaSIM, CaixaNAO, TextoSIM, TextoNAO, DadoFicha, ExibeDadoFicha, AlteraDadoFicha, RestricaoSemExcecao "&_ 
                                        " FROM procedimentosrestricaofrase prf "&_ 
                                        " JOIN sys_restricoes r ON r.id = prf.RestricaoID "&_ 
                                        " WHERE RestricaoID = "&procedimentosExcecaoPadrao("RestricaoID")&_
                                        " AND ProcedimentoID IN ("&ProcedimentoID&")"&_
                                        " AND ExcecaoID = "&procedimentosExcecaoPadrao("ExcecaoID")
                                        
                set valorRestricao = db.execute(sqlValorRestricao)

                if not respostas.eof then

                    valor = ""
                    cssClass = ""
                    Resposta = respostas("Resposta")
                    RespostaMarcada = respostas("RespostaMarcada")
                    Observacao = respostas("Resposta")

                    if not valorRestricao.eof then

                        if procedimentosExcecaoPadrao("tipo") = 2 then

                            if valorRestricao("Restringir") = "D" and respostas("RespostaMarcada") >= valorRestricao("Inicio") and respostas("RespostaMarcada") <= valorRestricao("Fim") then
                                valorMotivo = "dentro"
                                cssClass = "danger"
                            elseif valorRestricao("Restringir") = "F" and (respostas("RespostaMarcada") <= valorRestricao("Inicio") or respostas("RespostaMarcada") >= valorRestricao("Fim")) then
                                valorMotivo = "fora"
                                cssClass = "danger"
                            end if 

                            if cssClass <> "" then
                                valor = " (restrito "&valorMotivo&" da faixa "&valorRestricao("Inicio")&" - "&valorRestricao("Fim")&")"
                            end if

                        elseif procedimentosExcecaoPadrao("tipo") = 3 then

                            if valorRestricao("Restringir") = "S" and respostas("RespostaMarcada") = "S" then
                                cssClass = "danger"
                            elseif valorRestricao("Restringir") = "N" and respostas("RespostaMarcada") = "N" then
                                cssClass = "danger"
                            end if

                        end if
%>
                        <script>
                            $("#tr<%=procedimentosExcecaoPadrao("RestricaoID")%>").addClass("<%=cssClass%>");
                        </script>
<%
                    end if
                else
                    Resposta = ""
                    RespostaMarcada = ""
                    Observacao = ""

                end if
%>
                <tbody>
                <tr class="warning">
                    <td>  
                        <% response.write(procedimentosExcecaoPadrao("Descricao"))
                        if procedimentosExcecaoPadrao("RestricaoSemExcecao") = "S" then response.write(" (SEM EXCEÇÃO)") end if %>
<% 
                        if procedimentosExcecaoPadrao("Tipo") = 2 and ccur(procedimentosExcecaoPadrao("ExcecaoID")) = 0 then 
                            if valorRestricao("Restringir") = "D" then
%>                         
                                <strong><%=" ("&valorRestricao("Inicio")&" ≤ x ≥ "&valorRestricao("Fim")&")" %></strong>
<%
                            elseif valorRestricao("Restringir") = "F" then
%>                         
                                <strong><%=" ("&valorRestricao("Inicio")&" ≥ x ≤ "&valorRestricao("Fim")&")" %></strong>
<%
                            end if
                        end if 
%>    
                    </td>
                    <td>
<%
                        'TEXTO
                        if procedimentosExcecaoPadrao("Tipo") = 1 then
%>
                                <div class="checkbox-custom checkbox-primary">
                                    <input 
                                    type="checkbox" 
                                    class="ace" 
                                    name="restricao_check_texto" 
                                    id="restricao_check_texto_<%=procedimentosExcecaoPadrao("restricaoId")%>"
                                    data-restricao_sem_excecao = "<%=procedimentosExcecaoPadrao("RestricaoSemExcecao")%>" 
                                    data-check_padrao="<%=procedimentosExcecaoPadrao("ExcecaoID")%>"
                                    data-id_restricao="<%=procedimentosExcecaoPadrao("restricaoId")%>"
                                    value="T" <%if RespostaMarcada="T" then response.write("checked") end if %> /> 
                                    <label class="checkbox" for="restricao_check_texto_<%=procedimentosExcecaoPadrao("restricaoId")%>"> </label>
                                </div>
<%
                        'INTERVALO
                        elseif procedimentosExcecaoPadrao("Tipo") = 2 then

                            dadoFicha = ""

                            if valorRestricao("ExibeDadoFicha") = "S" then
                                set campo = db.execute("SELECT columnName FROM cliniccentral.sys_resourcesfields WHERE id = "&valorRestricao("DadoFicha"))

                                if campo("columnName") = "Nascimento" then
                                    campoFormatado = "COALESCE(TIMESTAMPDIFF(YEAR, Nascimento, CURDATE()),'')"
                                else 
                                    campoFormatado = campo("columnName")
                                end if

                                set resDadoFicha = db.execute("SELECT "&campoFormatado&" campo FROM pacientes WHERE id = "&PacientedIdq)
                                
                                dadoFicha = resDadoFicha("campo")
                            else 
                                dadoFicha = RespostaMarcada
                            end if
%>
                            <div class="col-md-2 qf">
                           <input
                            type="text" 
                            style="width: 10px; margin: 0px 5px 0px 0px;"
                            onkeyup="checkRegrasRestricao(this); clearObsCasoRestricaoNaoForValido(this)"
                            onclick="checkRegrasRestricao(this); clearObsCasoRestricaoNaoForValido(this)"
                            onkeypress="return event.charCode == 46 || (event.charCode >= 48 && event.charCode <= 57)"
                            data-restricao_sem_excecao = "<%=procedimentosExcecaoPadrao("RestricaoSemExcecao")%>"
                            data-excecao_inicio="<%=valorRestricao("Inicio")%>"
                            data-excecao_fim="<%=valorRestricao("Fim")%>"
                            data-restricao_sem_excecao = "<%=procedimentosExcecaoPadrao("RestricaoSemExcecao")%>"
                            data-check_padrao="<%=procedimentosExcecaoPadrao("ExcecaoID")%>"
                            data-id_restricao="<%=procedimentosExcecaoPadrao("restricaoId")%>"
                            data-tipo_restricao="<%=valorRestricao("Restringir")%>"
                            data-sem_excecao="<%=valorRestricao("RestricaoSemExcecao")%>"
                            class="form-control"
                            name="restricao_inicio_fim"
                            data-dispara="true"
                            id="restricao_inicio_fim_<%=procedimentosExcecaoPadrao("restricaoId")%>"
                            value="<%=dadoFicha%>"
                            <%if ccur(procedimentosExcecaoPadrao("ExcecaoID")) = 0 then %>
                            required
                            <% end if %>
                          >                                    
                            </div>
                            <div class="col-md-10 qf">
                            <input 
                                type="text" 
                                class="form-control" 
                                name="restricao_inicio_fim_obs"
                                style="display:none width: calc(85% - 10px);"
                                data-restricao_sem_excecao = "<%=procedimentosExcecaoPadrao("RestricaoSemExcecao")%>"                                            
                                data-check_padrao="<%=procedimentosExcecaoPadrao("ExcecaoID")%>"
                                data-id_restricao="<%=procedimentosExcecaoPadrao("restricaoId")%>"
                                placeholder="Digite sua observação" 
                                id="restricao_inicio_fim_obs_<%=procedimentosExcecaoPadrao("restricaoId")%>" 
                                value="<%=Observacao%>"
                            >
                            </div>
<%                     
                        'SIM/NÃO
                        elseif procedimentosExcecaoPadrao("Tipo") = 3 then
%>
                            <div class="col-md-3 qf" id="qfrestringir_<%=procedimentosExcecaoPadrao("restricaoId")%>">
                                <div class="radio-custom radio-primary">
                                    <input 
                                    type="radio" 
                                    class="ace prePar" 
                                    onclick="checkRegrasRestricao(this); clearObsCasoRestricaoNaoForValido(this); exibeTextoSimNao(<%=procedimentosExcecaoPadrao("restricaoId")%>,'<%=valorRestricao("TextoSIM")%>')"
                                    class="ace"
                                    data-restricao_sem_excecao = "<%=procedimentosExcecaoPadrao("RestricaoSemExcecao")%>" 
                                    data-check_padrao="<%=procedimentosExcecaoPadrao("ExcecaoID")%>"
                                    data-id_restricao="<%=procedimentosExcecaoPadrao("restricaoId")%>" 
                                    data-tipo_restricao="<%=valorRestricao("Restringir")%>"
                                    data-sem_excecao="<%=valorRestricao("RestricaoSemExcecao")%>"
                                    data-dispara="true"
                                    name="<%="restricao_check_"&procedimentosExcecaoPadrao("restricaoId") %>" 
                                    id="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId")&"_S" %>" 
                                    value="S" 
                                    <% if RespostaMarcada ="S" then response.write("checked") end if %> /> 
                                    <label class="radio" for="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId")&"_S" %>"> <% response.write("Sim") %></label>
                                </div>
                            </div>
                            <div class="col-md-3 qf" id="qfrestringir_<%=procedimentosExcecaoPadrao("restricaoId")%>">
                                <div class="radio-custom radio-primary">
                                    <input 
                                    type="radio" 
                                    class="ace prePar"
                                    onclick="checkRegrasRestricao(this); clearObsCasoRestricaoNaoForValido(this); exibeTextoSimNao(<%=procedimentosExcecaoPadrao("restricaoId")%>,'<%=valorRestricao("TextoNAO")%>')"
                                    class="ace"
                                    data-restricao_sem_excecao = "<%=procedimentosExcecaoPadrao("RestricaoSemExcecao")%>" 
                                    data-check_padrao="<%=procedimentosExcecaoPadrao("ExcecaoID")%>"
                                    data-id_restricao="<%=procedimentosExcecaoPadrao("restricaoId")%>"
                                    data-tipo_restricao="<%=valorRestricao("Restringir")%>"
                                    data-sem_excecao="<%=valorRestricao("RestricaoSemExcecao")%>"
                                    data-dispara="true"
                                    name="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId") %>" 
                                    id="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId")&"_N" %>" 
                                    value="N" <% if RespostaMarcada ="N" then response.write("checked") end if %> /> 
                                    <label class="radio" for="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId")&"_N" %>"> <% response.write("Não") %></label>
                                </div>
                            </div>
                            <div class="col-md-6 qf">
                            <input 
                                type="text" 
                                class="form-control" 
                                name="restricao_check_obs"
                                style="display:none width: calc(85% - 10px);"
                                data-restricao_sem_excecao = "<%=procedimentosExcecaoPadrao("RestricaoSemExcecao")%>"                                            
                                data-check_padrao="<%=procedimentosExcecaoPadrao("ExcecaoID")%>"
                                data-id_restricao="<%=procedimentosExcecaoPadrao("restricaoId")%>"
                                placeholder="Digite sua observação" 
                                id="restricao_check_obs_<%=procedimentosExcecaoPadrao("restricaoId")%>" 
                                value="<%=Observacao%>"
                            >
                            </div>
<%
                        end if
%>
                    </td>
                    <td style="text-align:center" id="tdRestricao_<%=procedimentosExcecaoPadrao("restricaoId")%>">

                    </td>
                </tr>
<%
if procedimentosExcecaoPadrao("Tipo") = 3 then
%>
    <script>
<%
    if RespostaMarcada ="N" then
        if valorRestricao("TextoNAO") <> "" then
%>
            $("#textoTd"+<%=procedimentosExcecaoPadrao("restricaoId")%>).text("<%=valorRestricao("TextoNAO")%>");
            $("#hideTr"+<%=procedimentosExcecaoPadrao("restricaoId")%>).show();
<%
        else 
%>
        $("#hideTr"+<%=procedimentosExcecaoPadrao("restricaoId")%>).hide();
<%
        end if
    elseif RespostaMarcada ="S" then
        if valorRestricao("TextoSIM") <> "" then
%>
            $("#textoTd"+<%=procedimentosExcecaoPadrao("restricaoId")%>).text("<%=valorRestricao("TextoSIM")%>");
            $("#hideTr"+<%=procedimentosExcecaoPadrao("restricaoId")%>).show();
<%
        else 
%>
            $("#hideTr"+<%=procedimentosExcecaoPadrao("restricaoId")%>).hide();
<%
        end if
    else 
%>
        $("#hideTr"+<%=procedimentosExcecaoPadrao("restricaoId")%>).hide();
<%
    end if 
%>
    </script>
                <tr id="hideTr<%=procedimentosExcecaoPadrao("restricaoId")%>" style="background-color: #F7D6D0">
                    <td colspan="100" id="textoTd<%=procedimentosExcecaoPadrao("restricaoId")%>" style="text-align:center; font-weight: bold">

                    </td>
                </tr>
<%
end if
%>
                </tbody>
<%
                procedimentosExcecaoPadrao.movenext
            wend
            
            procedimentosExcecaoPadrao.close
            set procedimentosExcecaoPadrao = nothing
%>
        </table>
    </form>
    </div>
    <div id="divBtnSalvar" class="col-md-12 text-right" style="margin: 10px 0 0 0;">            
        <button type="button" class="btn btn-success" onclick="persistProcedimentosRestricoes()">Salvar</button>        
    </div>
    </div>

<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
$('head').append('<style type="text/css">.modal .modal-body {max-height: ' + ($('body').height() * .8) + 'px;overflow-y: auto;}.modal-open .modal{overflow-y: hidden !important;}</style>');
    function exibeTextoSimNao(id, texto){
        if (texto != "") {
            $("#textoTd"+id).text(texto);
            $("#hideTr"+id).show();
        } else {
            $("#hideTr"+id).hide();
        }
    }

    $(document).ready(function(){
        $(document).on('show.bs.modal', '.modal', function (event) {
            var zIndex = 1040 + (10 * $('.modal:visible').length);
            $(this).css('z-index', zIndex);
            setTimeout(function() {
                $('.modal-backdrop').not('.modal-stack').css('z-index', zIndex - 1).addClass('modal-stack');
            }, 0);
        });
    })

    checkRegrasRestricao = (self) => {    
        const ForaDoIntervalo = 'F';
        const DentroDoIntervalo = 'D';
        const RestringirSim = 'S'
        const RestringirNao = 'N'
        let idRestricao = self.dataset.id_restricao;

        if(self.value.includes(",")){
            self.value = self.value.replace(",", ".");
        }
        
        if(self.dataset.excecao_inicio != undefined) {
            self.dataset.excecao_inicio = self.dataset.excecao_inicio.replace(",", ".")
        }
        if (self.dataset.excecao_fim != undefined) {
            self.dataset.excecao_fim = self.dataset.excecao_fim.replace(",", ".")   
        }

        let restricaoExcexao = self.dataset.restricao_sem_excecao
        let checkPadrao = self.dataset.check_padrao
        let reqPendencia = "<%=criarPendencia%>"
        if(!isNaN(self.value)){
            self.valor = parseFloat(self.value);
        }        
        let valor = self.value;
        let excecaoInicio = parseFloat(self.dataset.excecao_inicio);
        let excecaoFim = parseFloat(self.dataset.excecao_fim);
        let tipoRestricao = self.dataset.tipo_restricao;  
        let RestricaoSemExcecao = self.dataset.sem_excecao; 

        resetAll = _ => {
            let restricaoInicioFim = document.forms["procedimentos_restricoes_form"].elements[`restricao_inicio_fim_obs_${idRestricao}`];
            let restricaoInicioFimInput = document.forms["procedimentos_restricoes_form"].elements[`restricao_numero_${idRestricao}`];
            let restricaoCheckObs = document.forms["procedimentos_restricoes_form"].elements[`restricao_check_obs_${idRestricao}`];

            if(restricaoInicioFim != null) {
                restricaoInicioFim.style.display = 'none';
                restricaoInicioFim.removeAttribute("required");
                $(`#tdRestricao_${idRestricao}`).html(`<button type="button" class="btn btn-success btn-xs"><li class="fa fa-check"></li></button>`);
            }

            if(restricaoInicioFimInput != null) {
                restricaoInicioFimInput.style.display = 'none';
                restricaoInicioFimInput.removeAttribute("required");
                $(`#tdRestricao_${idRestricao}`).html(`<button type="button" class="btn btn-success btn-xs"><li class="fa fa-check"></li></button>`);    
            }
            
            if(restricaoCheckObs != null) {
                restricaoCheckObs.style.display = 'none';
                restricaoCheckObs.removeAttribute("required");
                $(`#tdRestricao_${idRestricao}`).html(`<button type="button" class="btn btn-success btn-xs"><li class="fa fa-check"></li></button>`);    
            }
        }

        checkRestricaoInicioFimForaLimite = _ => {
            if(((valor < excecaoInicio) || (valor > excecaoFim)) && tipoRestricao == ForaDoIntervalo) {
                let restricaoInicioFimInput = document.forms["procedimentos_restricoes_form"].elements[`restricao_inicio_fim_obs_${idRestricao}`];
                restricaoInicioFimInput.style.display = "block";    
                restricaoInicioFimInput.setAttribute("required", "");             
                $(`#tdRestricao_${idRestricao}`).html(`<button type="button" class="btn btn-danger btn-xs"><li class="fa fa-remove"></li></button>`);
                if(restricaoExcexao == "S") {
                    $(".btn-success").prop( "disabled", true );
                }
            } else {
                $(".btn-success").prop( "disabled", false );
            }
        }

        checkRestricaoInicioFimDentroLimite = _ => {        
            if((valor >= excecaoInicio && valor <= excecaoFim) && tipoRestricao == DentroDoIntervalo) {
                let restricaoInicioFimInput = document.forms["procedimentos_restricoes_form"].elements[`restricao_inicio_fim_obs_${idRestricao}`];
                restricaoInicioFimInput.style.display = "block";
                restricaoInicioFimInput.setAttribute("required", "");        
                $("#tdRestricao_"+idRestricao).html(`<button type="button" class="btn btn-danger btn-xs"><li class="fa fa-remove"></li></button>`);
                if(restricaoExcexao == "S") {
                    $(".btn-success").prop( "disabled", true );
                }
            } else {
                $(".btn-success").prop( "disabled", false );
            }
        }

        checkRestricaoCheckBoxSim = _ => {      
            let restricaoCheckObs = document.forms["procedimentos_restricoes_form"].elements[`restricao_check_obs_${idRestricao}`];
            let valorSelecionado = $(`#restricao_check_${idRestricao}_S`).val();
            if($(`#restricao_check_${idRestricao}_S`).is(":checked") && tipoRestricao == valorSelecionado) {  
                    
                restricaoCheckObs.style.display = "block";
                restricaoCheckObs.setAttribute("required", "");         

                $("#tdRestricao_"+idRestricao).html(`<button type="button" class="btn btn-danger btn-xs"><li class="fa fa-remove"></li></button>`);
                
                if(restricaoExcexao == "S") {
                    $(".btn-success").prop( "disabled", true );
                }
            } else if ($(`#restricao_check_${idRestricao}_S`).is(":checked") && tipoRestricao != valorSelecionado) {
                restricaoCheckObs.style.display = 'none';
                restricaoCheckObs.removeAttribute("required");
                $("#tdRestricao_"+idRestricao).html(`<button type="button" class="btn btn-success btn-xs"><li class="fa fa-check"></li></button>`);
                $(".btn-success").prop( "disabled", false );
            }
        }

        checkRestricaoCheckBoxNao = _ => {
            let restricaoCheckObs = document.forms["procedimentos_restricoes_form"].elements[`restricao_check_obs_${idRestricao}`];
            let valorSelecionado = $(`#restricao_check_${idRestricao}_N`).val();
            if($(`#restricao_check_${idRestricao}_N`).is(":checked") && tipoRestricao == valorSelecionado) {
                restricaoCheckObs.style.display = "block";
                restricaoCheckObs.setAttribute("required", "");
                $("#tdRestricao_"+idRestricao).html(`<button type="button" class="btn btn-danger btn-xs"><li class="fa fa-remove"></li></button>`);
                if(restricaoExcexao == "S") {
                    $(".btn-success").prop( "disabled", true );
                }
            } else if ($(`#restricao_check_${idRestricao}_N`).is(":checked") && tipoRestricao != valorSelecionado) {
                restricaoCheckObs.style.display = 'none';
                restricaoCheckObs.removeAttribute("required");
                $("#tdRestricao_"+idRestricao).html(`<button type="button" class="btn btn-success btn-xs"><li class="fa fa-check"></li></button>`);
                $(".btn-success").prop( "disabled", false );
            }
        }

        resetAll();
        if (checkPadrao == 0 || reqPendencia != "Sim") {
            checkRestricaoInicioFimForaLimite();
            checkRestricaoInicioFimDentroLimite();
            checkRestricaoCheckBoxSim();
            checkRestricaoCheckBoxNao();
        } else {
            let validation = true;
            
            if(self.type === "radio" && $("#"+self.id).is(':checked') === false || $("#"+self.id).val() === ""){
                validation = false; 
            }                                
            
            if(validation){
                $.post("pendenciasUtilities.asp",{acao:'verificaRestricao',procedimentoID:'<%response.write(ProcedimentoID)%>',restricaoID:idRestricao,resposta:valor},function(data){
                    if(data == "S"){
                        $(`#tdRestricao_${idRestricao}`).html(`<button type="button" class="btn btn-danger btn-xs"><li class="fa fa-remove"></li></button>`);

                        if(self.type === "radio"){
                            let restricaoCheckObs = document.forms["procedimentos_restricoes_form"].elements[`restricao_check_obs_${idRestricao}`];
                            restricaoCheckObs.style.display = "block";
                        }else {
                            let restricaoNumero = document.forms["procedimentos_restricoes_form"].elements[`restricao_inicio_fim_obs_${idRestricao}`];
                            restricaoNumero.style.display = "block";
                        }   
                    } else {
                        $("#tdRestricao_"+idRestricao).html(`<button type="button" class="btn btn-success btn-xs"><li class="fa fa-check"></li></button>`);
                    } 
                })
            }
        }
    }

    clearObsCasoRestricaoNaoForValido = (self) => {    
        let idRestricao = self.dataset.id_restricao;
        let restricaoNumero = document.forms["procedimentos_restricoes_form"].elements[`restricao_inicio_fim_obs_${idRestricao}`];
        let restricaoCheckObs = document.forms["procedimentos_restricoes_form"].elements[`restricao_check_obs_${idRestricao}`];
        
        if(restricaoNumero != null && restricaoNumero.style.display == 'none') {
            restricaoNumero.value = '';
        }

        if(restricaoCheckObs != null && restricaoCheckObs.style.display == 'none') {
            restricaoCheckObs.value = '';
        }
    }

    persistProcedimentosRestricoes = () => {

        forml = document.querySelector('#procedimentos_restricoes_form');

        checkRequired = () => {
            valido = true;
            [...document.querySelector('#procedimentos_restricoes_form')].forEach((input)=> {	
                if(input.required && input.value == '') {                        
                    valido = false;
                }
            });
            
            var totCheckbox = $(':radio[name^="restricao_check_"]').length;
            var totCheckSelected = $(':radio[name^="restricao_check_"]:checked').length;
            var tt = (totCheckbox/2) 

            if( tt != totCheckSelected ) {
                console.log("minha validacao")
                valido = false;
            }

            return valido             
        }

        if(!checkRequired()) {  
            new PNotify({
                title: 'Preencha os campos do formulário',
                text: '',
                type: 'danger',
                delay: 1500
            });      
            return;
        }
        
        novoItem = {};
        Object.values(forml).forEach((item) => {
            if(item.name == '') {
                return;
            }
            
            if(item.type == 'radio') {
                nome = "restricao_check"
            } else {
                nome = item.name
            }

            novoItem[nome] = [];
        }); 

        Object.values(forml).forEach((item) => {
            if(item.name == '') {
                return;
            }

            if(item.type == 'radio') {
                if (item.checked) {
                    novoItem["restricao_check"].push(`${item.dataset.id_restricao}||${item.value}`);	
                }
                return;	
            }

            if(item.type == 'checkbox') {
                if (item.checked) {
                    novoItem["restricao_check_texto"].push(`${item.dataset.id_restricao}||${item.value}`);	
                }
                return;	
            }
            
            if (!item.name.includes("_obs")) {
                itemValue = item.value.replace(",",".")
            } else {
                itemValue = item.value
            }

            novoItem[item.name].push(`${item.dataset.id_restricao}||${itemValue}`);
        });

        let formData = new FormData();
        for (const key of Object.keys(novoItem)) {
            formData.append(key, novoItem[key]);
        } 

        var str = "";
        for (var key in novoItem) {
            if (str != "") {
                str += "&";
            }
            str += key + "=" + encodeURIComponent(novoItem[key]);
        }

        fetch(`persistProcedimentosRestricoes.asp?PacienteId=<%= PacientedIdq %>`, {
                method: 'POST',
                body: str,            
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                }
        })
        .then(response => { 
            if(response.status == 200){
                    $("#btnSalvarAgenda").removeClass("disabled");
                    new PNotify({
                        title: 'Restrições cadastradas',
                        text: '',
                        type: 'success',
                        delay: 1500
                }); 
                return;
            }
            new PNotify({
                    title: 'Ocorreu um erro!',
                    text: '',
                    type: 'danger',
                    delay: 1500
                });
        });

        if($("#totalPreparo").val() > 0) {

            if($("#requester").val() == "ModalPreparo") {
                $(".modalpendencias").modal("hide");
            } else {
                abrirModalPreparo();
            }
          
        } else {
            if($("#irParaPendencia").val() == "Sim") {

                $("#irParaPendencia").val("Nao");
                closeComponentsModal();

                var pendencias = [];
                var $pendenciasSelecionadas = $("input[name='BuscaSelecionada']");

                $.each($pendenciasSelecionadas, function() {
                    pendencias.push($(this).val());
                });

                requestProcedimentoRestricoes();
            } else if ($("#irParaPendencia").val() == "Nao") {
                if($("#requester").val() == "ModalPreparo") {
                    $(".modalpendencias").modal("hide");
                } else {
                    requestProcedimentoRestricoes();
                }
            } else {
                $(".modalpendencias").modal("hide");
                abrirAgenda2()   
            }
        }
    }

    [...document.querySelector('#procedimentos_restricoes_form')].find((input, key)=> {
        if(input.dataset.dispara) {
            checkRegrasRestricao(input);	
        }
    });

    function requestProcedimentoRestricoes() {
        var pacienteid = <%response.write(PacientedIdq)%>
        var procedimentoid = "<%response.write(ProcedimentoID)%>"
        $.post("ProcedimentoListagemRestricoes.asp?PacientedId="+pacienteid+"&ProcedimentoID="+procedimentoid, function(data){
            $(".modalpendencias").modal("hide");
            $(".modalpendenciasbody2").html(data);
            $(".modalpendencias2").modal("show");
        });
    }
</script>
<%
end if
%>
