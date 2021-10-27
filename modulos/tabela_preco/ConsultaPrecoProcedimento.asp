<!--#include file="../../connect.asp"-->
<%

GrupoID = ref("bGrupoID")
Unidades = ref("Unidades")
Submit = ref("Submit")
%>

<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>

<form method="post" id="frmFiltroConsulta" action="" class="hidden-print">
<input type='hidden' name='submit' value='S'>

<div class="panel mt20">
    <div class="panel-heading">
        <span class="panel-title"><i class="far fa-info-circle"></i> Filtros</span>
        <span class="panel-controls">
                <button class="btn btn-info btn-sm" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i></button>
                <button type="button" class="btn btn-sm btn-success" title="Gerar Excel" onclick="downloadExcel()"><i class="far fa-table"></i></button>
                <button class="btn btn-primary"><i class="far fa-search"></i> Consultar</button>
        </span>
    </div>
    <div class="panel-body">
            <div class="row">
                 <div id="divComboGrupoProcedimento">
                    <%= quickfield("simpleSelect", "bGrupoID", "Grupo", 3, GrupoID, "select id, NomeGrupo from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", " ") %>
                </div>
                <div id="divComboProcedimento">
                    <%= quickfield("simpleSelect", "bProcedimentoID", "Procedimento", 3, "", "select id, NomeProcedimento from procedimentos p where GrupoID="&treatvalzero(GrupoID)&" AND sysActive=1 and Ativo='on' order by NomeProcedimento", "NomeProcedimento", "") %>
                </div>
                <% IF ModoFranquiaUnidade THEN %>
                    <input type="hidden" name="Unidades" value="|<%=session("UnidadeID") %>|" id="CompanyUnitID" />
                <% ELSE %>
                    <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, Unidades, "", "", "")%>
                <% END IF %>

            </div>


        <div class="row mt10">

            <div class="col-md-12">

                <table class="table table-hover table-bordered">

                    <tr class="">
                        <th>Procedimento</th>
                        <th width="40px"></th>
                    </tr>
                    <tbody id="procedimentosSelecionados">
                        <%
                        procedimentos = replace(ref("procedimentoSelecionado"),"|","")

                        if procedimentos<>"" then

                            set ProcedimentoSQL = db_execute("SELECT id,NomeProcedimento FROM procedimentos WHERE id in ("&procedimentos&")")

                            while not ProcedimentoSQL.eof
                                ProcedimentoID = ProcedimentoSQL("id")
                                NomeProcedimento = ProcedimentoSQL("NomeProcedimento")
                            %>
                            <tr class='linha-procedimento' data-id='<%=ProcedimentoID%>'>
                                    <td><%=NomeProcedimento%></td>
                                    <td><input type='hidden' name='procedimentoSelecionado' value='<%=ProcedimentoID%>'>
                                        <buttton onclick="removeLinhaProcedimento('<%=ProcedimentoID%>')" type="button" class="btn btn-sm btn-danger" ><i class="far fa-remove"></i></buttton>
                                    </td>
                            </tr>
                            <%
                            ProcedimentoSQL.movenext
                            wend
                            ProcedimentoSQL.close
                            set ProcedimentoSQL=nothing
                        end if
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</form>


<div class="panel mt20">
    <div class="panel-body">

        <div class="row">

            <div class="col-md-12">

                <%
                if procedimentos<>"" then
                    procedimentos=replace(procedimentos,"|","")


                    if Unidades<>"" then
                        sqlUnidades = " AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('"&Unidades&"',''),'-999')),TRUE) "
                    end if


                    set TabelasDistintasSQL = db_execute("SELECT  "&_
                                                          " group_concat(distinct p.id) ids "&_
                                                          " from "&_
                                                          " procedimentostabelas p "&_
                                                          " JOIN procedimentostabelasvalores pv ON pv.TabelaID=p.id "&_
                                                          " WHERE "&_
                                                          "  sysActive = 1 "&_
                                                          " and now() between Inicio and Fim "&_
                                                          " "&sqlUnidades&" "&_
                                                          " AND pv.ProcedimentoID IN ("&procedimentos&") AND pv.Valor>0 "&_
                                                          " ORDER BY p.Unidades, p.Tipo, NomeTabela")

                    tabelaIds = TabelasDistintasSQL("ids")
                    if tabelaIds&"" = "" then
                        %>
                        Nenhuma tabela configurada para o(s) procedimento(s) selecionado(s).
                        <%
                    else

                        set TabelasSQL = db_execute("SELECT p.id, p.NomeTabela "&_
                                                      " from "&_
                                                      " procedimentostabelas p "&_
                                                      " WHERE id in ("&tabelaIds&") "&_
                                                      " ORDER BY p.Unidades, p.Tipo, NomeTabela")

                    %>
                        <div class="table-responsive">
                        <table width="100%" class="table table-hover table-bordered" id="table-precos" _excel-name="Consulta de valores">

                        <tr class="primary">
                            <th>Procedimento</th>
                            <%
                            while not TabelasSQL.eof
                                %>
                                <th><%=TabelasSQL("NomeTabela")%></th>
                                <%
                            TabelasSQL.movenext
                            wend
                            TabelasSQL.close
                            set TabelasSQL=nothing
                            %>
                            <th>Custo médio</th>
                            <th>Venda média</th>
                        </tr>

                        <%

                        Unidades = replace(session("Unidades"),"|","")

                        procedimentos = replace(ref("procedimentoSelecionado"),"|","")

                        tabelasSplt = split(tabelaIds,",")

                        if procedimentos<>"" then

                            set ProcedimentoSQL = db_execute("SELECT id,NomeProcedimento FROM procedimentos WHERE id in ("&procedimentos&")")

                            while not ProcedimentoSQL.eof
                                ProcedimentoID = ProcedimentoSQL("id")
                                NomeProcedimento = ProcedimentoSQL("NomeProcedimento")


                                SomaCusto = 0
                                QuantidadeCusto = 0
                                SomaVenda = 0
                                QuantidadeVenda = 0
                            %>
                            <tr class='linha-procedimento' data-id='<%=ProcedimentoID%>'>
                                    <td><%=NomeProcedimento%></td>
                                    <%
                                    set ValoresSQL = db_execute("SELECT  "&_
                                                                "pv.Valor, p.Tipo, p.id "&_
                                                                "FROM procedimentos proc "&_
                                                                "LEFT JOIN procedimentostabelas p ON p.id IN ("&tabelaIds&") "&_
                                                                "LEFT JOIN procedimentostabelasvalores pv ON pv.ProcedimentoID=proc.id AND pv.TabelaID=p.id "&_
                                                                "WHERE proc.id="&ProcedimentoID&" "&_
                                                                "GROUP BY p.id "&_
                                                                "ORDER BY p.Unidades, p.Tipo, NomeTabela")

                                    while not ValoresSQL.eof

                                        ValorTabela = ValoresSQL("Valor")

                                        if isnumeric(ValorTabela) then
                                            Valor=fn(ValorTabela)

                                        classCol = ""
                                        if ValoresSQL("Tipo")="V" then
                                            classCol = "text-success"

                                            SomaVenda = SomaVenda + ValorTabela
                                            QuantidadeVenda = QuantidadeVenda + 1
                                        else
                                            classCol = "text-danger"

                                            SomaCusto = SomaCusto + ValorTabela
                                            QuantidadeCusto = QuantidadeCusto + 1
                                        end if

                                        %>
                                        <td class="<%=classCol%> text-right"><a target="_blank" class="<%=classCol%>" href="?P=ProcedimentosTabelas2&I=<%=ValoresSQL("id")%>&ProcedimentoID=<%=ProcedimentoID%>&Busca=<%=NomeProcedimento%>&Pers=1"><%=Valor%></a></td>
                                        <%

                                        else
                                            %>
                                            <td class="text-right">-</td>
                                            <%
                                        end if
                                    ValoresSQL.movenext
                                    wend
                                    ValoresSQL.close
                                    set ValoresSQL=nothing

                                    CustoMedio = 0
                                    if SomaCusto > 0 then
                                        CustoMedio = SomaCusto/QuantidadeCusto
                                    end if
                                    VendaMedia = 0
                                    if SomaVenda > 0 then
                                        VendaMedia = SomaVenda/QuantidadeVenda
                                    end if
                                    %>
                                    <th class="danger"><%= fn(CustoMedio) %></th>
                                    <th class="success"><%= fn(VendaMedia) %></th>
                            </tr>
                            <%
                            ProcedimentoSQL.movenext
                            wend
                            ProcedimentoSQL.close
                            set ProcedimentoSQL=nothing
                        end if


                        %>

                    </table>
                    </div>
                    <%
                    end if
                else
                    if Submit="S" then
                        %>
                        Selecione um procedimento.
                        <%
                    end if
                end if
                %>

            </div>

        </div>

    </div>
</div>

<script>
    $(".crumb-active a").html("Consulta de preço do procedimento");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("valores nas tabelas");
    $(".crumb-icon a span").attr("class", "far fa-check");

$("#bGrupoID").change(function(el){
   $.get("ajax/RenderSelectProcedimento.asp", {GrupoID: $(this).val()}, function (data){
       $("#divComboProcedimento").html(data);
   });
});

$("#frmFiltroConsulta").on("change", "#bProcedimentoID", function(){
    var procedimentoId = $(this).val();
    if(!procedimentoId){
        return;
    }
    var nome = $(this).find("option:selected").text();

    $("#procedimentosSelecionados").append(`<tr class='linha-procedimento' data-id='${procedimentoId}'>
            <td>${nome}</td>
            <td><input type='hidden' name='procedimentoSelecionado' value='${procedimentoId}'}>
                <buttton onclick="removeLinhaProcedimento('${procedimentoId}')" type="button" class="btn btn-sm btn-danger" ><i class="far fa-remove"></i></buttton>
            </td>
    </tr>`);

    $(this).val("").change();
});

function removeLinhaProcedimento(procedimentoId){
    $(`.linha-procedimento[data-id=${procedimentoId}]`).remove();
}

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


function downloadExcel(){
    $("#htmlTable").val($("#table-precos").html());
    $("#formExcel").attr("action", domain+"reports/download-excel?title=Consulta de valores&tk=" + localStorage.getItem("tk")).submit();
}

</script>