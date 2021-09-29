<!--#include file="connect.asp"-->
<!--#include file="Classes/Restricao.asp"-->
<%
PacienteID = req("PacienteID")
ProcedimentoID = req("ProcedimentoID")
ProfissionalID = req("ProfissionalID")&""

if ProfissionalID <> "" then
    where = " SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalID&" AND "
else
    where = " "
end if

dim restricaoObj
set restricaoObj = new Restricao

set resultadoRestricao = restricaoObj.verificaRestricao(ProfissionalID, ProcedimentoID, PacienteID, "", "")

sql = " SELECT distinct RestricaoID, r.Descricao, Tipo, (SELECT prf2.ExcecaoID "&_
    "                                                    FROM procedimentosrestricaofrase prf2 "&_
    "                                                   WHERE prf2.RestricaoID = prf.RestricaoID "&_
    "                                                     AND ProcedimentoID IN ("&ProcedimentoID&") AND (ExcecaoID IN ((SELECT id FROM procedimentosrestricoesexcecao WHERE "&where&" ProcedimentoID IN ("&ProcedimentoID&"))) OR ExcecaoID = 0)  ORDER BY 1 "&_
    "                                              DESC LIMIT 1) ExcecaoID, RestricaoSemExcecao "&_
    "   FROM procedimentosrestricaofrase prf "&_
    "   JOIN sys_restricoes r ON r.id = prf.RestricaoID "&_
    "  WHERE ProcedimentoID IN ("&ProcedimentoID&") "&_
    "    AND (ExcecaoID IN ((SELECT id FROM procedimentosrestricoesexcecao WHERE "&where&" ProcedimentoID IN ("&ProcedimentoID&"))) OR ExcecaoID = 0) "&limitarCheckin&_
    " ORDER BY 4,2 "

set procedimentosExcecaoPadrao = db.execute(sql) 

if procedimentosExcecaoPadrao.eof then

%>
<div class="alert alert-default">
    Nenhuma restrição configurada para este procedimento e profissional.
</div>
<%
end if

%>
        <table class="table table-bordered" bgcolor="#fff">
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
                    <tr class="primary">
                        <th width="30%">
                            <%="Restrições "&titulo%>
                        </th>
                        <th width="30%">
                            Resposta
                        </th>
                        <th>
                            Observação
                        </th>
                        <th width="1%">

                        </th>
                    </tr>
                </thead>
<%
                end if
                
                ExcecaoIDAnterior = procedimentosExcecaoPadrao("ExcecaoID")
                exibeCabecalho = false
                
                sqlResposta = "SELECT RespostaMarcada, Resposta, Observacao FROM restricoes_respostas WHERE PacienteID = "&PacienteID&" AND RestricaoID = "&procedimentosExcecaoPadrao("RestricaoID") 

                set respostas = db.execute(sqlResposta)

                sqlValorRestricao =  " SELECT Horas, Dias, Inicio, Fim, Restringir, MostrarPorPadrao, CaixaSIM, CaixaNAO, TextoSIM, TextoNAO, DadoFicha, ExibeDadoFicha, AlteraDadoFicha, Texto, RestricaoSemExcecao "&_ 
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
                <tr>
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
                            <div class="col-md-12 qf">
                                <div class="checkbox-custom checkbox-primary">
                                    <input type="checkbox" 
                                    class="ace" <%if RespostaMarcada="T" then response.write("checked") end if %> disabled/> 
                                    <label class="checkbox" for="restricao_check_texto_<%=procedimentosExcecaoPadrao("restricaoId")%>"> </label>
                                </div>
                            </div>
<%
                        'INTERVALO
                        elseif procedimentosExcecaoPadrao("Tipo") = 2 then

                            dadoFicha = ""

                            if valorRestricao("ExibeDadoFicha") = "S" then
                                set campo = db.execute("SELECT columnName FROM cliniccentral.sys_resourcesfields WHERE id = "&valorRestricao("DadoFicha"))
                                set resDadoFicha = db.execute("SELECT "&campo("columnName")&" campo FROM pacientes WHERE id = "&PacienteID)
                                
                                dadoFicha = resDadoFicha("campo")
                            else 
                                dadoFicha = RespostaMarcada
                            end if
%>
                            <div class="col-md-12 qf">
                                <%=RespostaMarcada%>
                            </div>
<%                     
                        'SIM/NÃO
                        elseif procedimentosExcecaoPadrao("Tipo") = 3 then
%>
                            <div class="col-md-6 qf" id="qfrestringir_<%=procedimentosExcecaoPadrao("restricaoId")%>">
                                <div class="radio-custom radio-primary">
                                    <input 
                                    type="radio" 
                                    class="ace prePar" 
                                    class="ace" 
                                    name="<%="restricao_check_"&procedimentosExcecaoPadrao("restricaoId") %>" 
                                    id="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId")&"_S" %>" 
                                    value="S" 
                                    <% if RespostaMarcada ="S" then response.write("checked") end if %> disabled/> 
                                    <label class="radio" for="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId")&"_S" %>"> <% response.write("Sim") %></label>
                                </div>
                            </div>
                            <div class="col-md-6 qf" id="qfrestringir_<%=procedimentosExcecaoPadrao("restricaoId")%>">
                                <div class="radio-custom radio-primary">
                                    <input 
                                    type="radio" 
                                    class="ace prePar"
                                    class="ace" 
                                    name="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId") %>" 
                                    id="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId")&"_N" %>" 
                                    value="N" <% if RespostaMarcada ="N" then response.write("checked") end if %> disabled/> 
                                    <label class="radio" for="<%= "restricao_check_"&procedimentosExcecaoPadrao("restricaoId")&"_N" %>"> <% response.write("Não") %></label>
                                </div>
                            </div>
<%
                        end if
%>
                    </td>
                    <td>
                        <%=Observacao%>
                    </td>
                    <td>
                        <%
                        if cssClass = "danger" then
                        %>
                            <button type="button" class="btn btn-danger btn-xs"><li class="fa fa-remove"></li></button>
                        <%
                        else
                        %>
                            <button type="button" class="btn btn-success btn-xs"><li class="fa fa-check"></li></button>
                        <%
                        end if
                        %>
                    </td>
                 </tr>
                </tbody>
<%
                procedimentosExcecaoPadrao.movenext
            wend
            
            procedimentosExcecaoPadrao.close
            set procedimentosExcecaoPadrao = nothing
%>
        </table>

        <% ' resultadoRestricao.item("mensagem")%>
