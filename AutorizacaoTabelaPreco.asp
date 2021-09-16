<!--#include file="connect.asp"-->
<%


%>



<div class="panel mt20">
    <div class="panel-body">
        
        <div class="row">

            <div class="col-md-12">

                <table class="table table-hover table-bordered">

                    <tr class="primary">
                        <th>#</th>
                        <th>Unidade</th>
                        <th>Tabela</th>
                        <th>Usuário</th>
                        <th>Data & Hora</th>
                        <th>Motivo</th>
                        <th>Procedimento</th>
                        <th>Valor anterior</th>
                        <th>Valor proposto</th>
                        <th>Variação</th>
                        <th>Ação</th>
                    </tr>

                    <%

                    Status = "PENDENTE"
                    Unidades = replace(session("Unidades"),"|","")

                    sqlSolicitacoes = "SELECT t.id TabelaID, u.NomeFantasia, t.NomeTabela, lu.Nome, s.*, count(sp.id) procedimentos  " &_
                                                              " FROM solicitacao_tabela_preco s " &_
                                                              " INNER JOIN solicitacao_tabela_preco_procedimentos sp ON sp.SolicitacaoID=s.id " &_
                                                              " INNER JOIN procedimentostabelas t ON t.id=s.TabelaPrecoID " &_
                                                              " LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id = s.sysUser " &_
                                                              " LEFT JOIN vw_unidades u ON u.id=s.UnidadeID " &_
                                                              " WHERE Status='"&Status & "' "&franquiaUnidade("AND (s.UnidadeID IN ("&Unidades&") "&sqlUnidadeFranquia&")")&"  GROUP BY s.id HAVING procedimentos > 0"
                    set SolicitacaoTabelaSQL = db_execute(sqlSolicitacoes)

                    while not SolicitacaoTabelaSQL.eof

                        SolicitacaoID = SolicitacaoTabelaSQL("id")

                        %>
                        <tr class="dark">
                            <td><i>#<%=SolicitacaoID%></i></td>
                            <td><%=SolicitacaoTabelaSQL("NomeFantasia")%></td>
                            <td><%=SolicitacaoTabelaSQL("NomeTabela")%></td>
                            <td><%=SolicitacaoTabelaSQL("Nome")%></td>
                            <td><%=SolicitacaoTabelaSQL("sysDate")%></td>
                            <td><%=SolicitacaoTabelaSQL("Descricao")%></td>
                            <td><%=SolicitacaoTabelaSQL("procedimentos")%></td>
                            <td colspan="3"></td>
                            <td>
                                <%
                                if aut("|aprovacaotabelaprecoI|")=1 then
                                %>
                                <button onclick="feedbackSolicitacao('APROVAR', '<%=SolicitacaoID%>')" title="Aprovar solicitação" type="button" class="btn btn-xs btn-success">
                                    <i class="fa fa-check"></i>
                                </button>
                                <button onclick="feedbackSolicitacao('REJEITAR', '<%=SolicitacaoID%>')" title="Rejeitar solicitação" type="button" class="btn btn-xs btn-danger">
                                    <i class="fa fa-times"></i>
                                </button>
                                <%
                                end if
                                %>
                            </td>
                        </tr>
                        <%

                        set ProcedimentosSQL = db_execute("SELECT tpp.*, proc.NomeProcedimento FROM solicitacao_tabela_preco_procedimentos tpp "&_
                                                            " INNER JOIN procedimentos proc ON proc.id=tpp.ProcedimentoID "&_
                                                            "WHERE tpp.SolicitacaoID="&SolicitacaoTabelaSQL("id"))
                        
                        if not ProcedimentosSQL.eof then                                                            
                            while not ProcedimentosSQL.eof

                                valorAnterior = ProcedimentosSQL("ValorAnterior")
                                valorProposto = ProcedimentosSQL("ValorProposto")

                                Diferenca = valorProposto - valorAnterior

                                if Diferenca < 0 then
                                    classDiff = " text-danger "
                                    operacaoDiff = ""
                                else
                                    classDiff = " text-success "
                                    operacaoDiff = "+"
                                end if
                                %>
                                <tr>
                                    <td colspan="6"></td>
                                    <td><code><%=ProcedimentosSQL("NomeProcedimento")%></code></td>
                                    <td class="text-right"><%=fn(valorAnterior)%></td>
                                    <td class="text-right"><%=fn(valorProposto)%></td>
                                    <td class="text-right"><strong class="<%=classDiff%>"><%=operacaoDiff%> <%=fn(Diferenca)%></strong></td>
                                    <td></td>
                                </tr>
                                <%
                            ProcedimentosSQL.movenext
                            wend
                            ProcedimentosSQL.close
                            set ProcedimentosSQL=nothing
                        end if

                    SolicitacaoTabelaSQL.movenext
                    wend
                    SolicitacaoTabelaSQL.close
                    set SolicitacaoTabelaSQL=nothing


                    %>

                </table>

            </div>

        </div>

    </div>
</div>

<script>
    $(".crumb-active a").html("Solicitação de preço de tabela");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("ver solicitações");
    $(".crumb-icon a span").attr("class", "fa fa-check");

function feedbackSolicitacao(feedback, solicitacao_id){
    $.post("modulos/tabela_preco/FeedbackSolicitacao.asp", {
        feedback: feedback,
        solicitacao_id: solicitacao_id
    }, function(data){
        if(feedback == "APROVAR"){
            showMessageDialog("Solicitação aprovada com sucesso.","success")            
        }else{
            showMessageDialog("Solicitação rejeitar.","danger")
        }
    });
}

</script>