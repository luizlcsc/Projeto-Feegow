<!--#include file="connect.asp"-->
<%
Unidades=Request.QueryString("Unidades")
%>
<br>
<div class="panel">
    <div class="panel-body">
        <form id="form-conferencia">
            <div class="row">
                <input type="hidden" name="P" value="ConferenciaValorProcedimento">
                <input type="hidden" name="Pers" value="1">
                <%=quickfield("empresa", "UnidadeID", "Unidades", 2, Unidades, "", "", "")%>
                <%=quickField("simpleSelect", "GrupoID", "Grupo", 2, Request.QueryString("GrupoID"), "select * from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", "  required ")%>
                <%=quickField("simpleSelect", "TabelaID", "Tabela", 2, Request.QueryString("TabelaID"), "select * from tabelaparticular where sysActive=1 order by NomeTabela", "NomeTabela", " required  ")%>
                <div class="col-md-3">
                <br><button class="btn btn-primary">
                    Consultar valores
                </button>
                </div>
            </div>
        </form>
        <table class="table table-striped mt20 table-bordered table-striped">
            <thead>
                <tr class="primary">
                    <th>Unidade</th>
                    <th>Tabela</th>
                    <th>Procedimento</th>
                    <th>Valor Base (procedimento)</th>
                    <th>Valor Tabela</th>
                    <th>Variação de preço</th>
                    <th>Valor final</th>
                </tr>
            </thead>
        <%

        function getDiferencaCor(valor)
            if valor > 0 then
                Cor="green"
            elseif Valor<0 then
                Cor="red"
            else
                Cor="#000"
            end if

            getDiferencaCor = "<span style='color:"&Cor&"'>"&fn(valor)&"</span>"
        end function

        GrupoID=Request.QueryString("GrupoID")
        TabelaID=Request.QueryString("TabelaID")

        if GrupoID<>"" then

            if Unidades="" then
                Unidades="0"
            end if

            Unidades=replace(Unidades,"|","")

            set UnidadesSQL = db.execute("SELECT id, NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE id in ("&Unidades&") ORDER BY t.NomeFantasia" )

            while not UnidadesSQL.eof
                NomeFantasia=UnidadesSQL("NomeFantasia")
                UnidadeID=UnidadesSQL("id")

                %>

                <tbody>
                    <%
                    sqlTabela=""
                    if TabelaID<>"0" and TabelaID<>"" then
                        sqlTabela=" AND id="&TabelaID
                    end if
                    set TabelasSQL = db.execute("SELECT * FROM tabelaparticular WHERE sysActive=1 AND Ativo='on' AND (Unidades LIKE '%|"&UnidadeID&"|%' OR Unidades='' OR Unidades IS NULL)"&sqlTabela)

                    while not TabelasSQL.eof
                        TabelaID=TabelasSQL("id")
                        NomeTabela=TabelasSQL("NomeTabela")

                        set ProcedimentosSQL= db.execute("SELECT id,NomeProcedimento, Valor, GrupoID FROM procedimentos WHERE sysActive=1 AND Ativo='on' AND GrupoID="&treatvalzero(GrupoID))

                        while not ProcedimentosSQL.eof
                            ProcedimentoID=ProcedimentosSQL("id")
                            GrupoID=ProcedimentosSQL("GrupoID")
                            NomeProcedimento=ProcedimentosSQL("NomeProcedimento")
                            ValorProcedimento=ProcedimentosSQL("Valor")
                            ValorBase=ValorProcedimento
                            TabelaDePrecoID=""
                            DescricaoTabelaDePreco=""
                            Valor=0
                            VariacaoID=0

                            sqlProcedimentoTabela = "SELECT pt.NomeTabela, pt.id, ptv.Valor, Profissionais, TabelasParticulares, Especialidades FROM procedimentostabelasvalores ptv INNER JOIN procedimentostabelas pt ON pt.id=ptv.TabelaID WHERE ProcedimentoID="&ProcedimentoID&" AND "&_
                            "(Especialidades='' OR Especialidades IS NULL OR Especialidades LIKE '%|"&ref("EspecialidadeID")&"|%' ) AND "&_
                            "(Profissionais='' OR Profissionais IS NULL OR Profissionais LIKE '%|"&ref("ProfissionalID")&"|%' ) AND "&_
                            "(TabelasParticulares='' OR TabelasParticulares IS NULL OR TabelasParticulares LIKE '%|"&TabelaID&"|%' ) AND "&_
                            "(Unidades='' OR Unidades IS NULL OR Unidades LIKE '%|"&UnidadeID&"|%' ) AND "&_
                            "pt.Fim>="&mydatenull(date())&" AND pt.Inicio<="&mydatenull(date())&" AND pt.sysActive=1 AND pt.Tipo='V' "

                            ultimoPonto=0

                            set ProcedimentoVigenciaSQL = db.execute(sqlProcedimentoTabela)

                            while not ProcedimentoVigenciaSQL.eof
                                estePonto=0


                                if instr(ProcedimentoVigenciaSQL("TabelasParticulares"), "|"&TabelaID&"|")>0 then
                                    estePonto = estePonto + 1
                                end if


                                if estePonto>=ultimoPonto then
                                    ValorBase = ProcedimentoVigenciaSQL("Valor")
                                    TabelaDePrecoID = ProcedimentoVigenciaSQL("id")
                                    DescricaoTabelaDePreco = ProcedimentoVigenciaSQL("NomeTabela")
                                end if

                                ultimoPonto=estePonto

                            ProcedimentoVigenciaSQL.movenext
                            wend
                            ProcedimentoVigenciaSQL.close
                            set ProcedimentoVigenciaSQL=nothing


                                sqlVarPreco = "select * from("&_
                                   "select (if(instr(Procedimentos, '|"&ProcedimentoID&"|'), 0, 1)) PrioridadeProc, t.* from (select * from varprecos WHERE "&_
                                   "((Procedimentos='' OR Procedimentos IS NULL)  "&_
                                   "OR (Procedimentos LIKE '%|"&ProcedimentoID&"|%' AND Procedimentos LIKE '%|ONLY|%') "&_
                                   "OR (Procedimentos NOT LIKE '%|"&ProcedimentoID&"|%' AND Procedimentos LIKE '%|EXCEPT|%') "&_
                                   "OR (Procedimentos LIKE '%|GRUPO_"&GrupoID&"|%' AND Procedimentos LIKE '%|ONLY|%') "&_
                                   "OR (Procedimentos NOT LIKE '%|GRUPO_"&GrupoID&"|%' AND Procedimentos LIKE '%|EXCEPT|%') "&_
                                   "OR (Procedimentos LIKE '%|ALL|%') "&_
                                   ") AND "&_
                                   "(Profissionais='' OR Profissionais IS NULL OR Profissionais LIKE '%|"&ProfissionalID&"|%' ) AND "&_
                                   "(Especialidades='' OR Especialidades IS NULL OR Especialidades LIKE '%|"&EspecialidadeID&"|%' ) AND "&_
                                   "(Tabelas='' OR Tabelas IS NULL OR Tabelas LIKE '%|"&TabelaID&"|%' ) AND "&_
                                   "(Unidades='' OR Unidades='0' OR Unidades IS NULL OR Unidades LIKE '%|"&UnidadeID&"|%' ) ORDER BY Ordem"&_
                               ") t ) t2 order by PrioridadeProc desc"

                                set vcaTab = db.execute(sqlVarPreco)

                                pmValorPerc=0

                                sinalVariacao=""

                                if not vcaTab.eof then
                                    while not vcaTab.eof
                                        'response.Write("//"& sqlVarPreco )
                                        pmTipo = vcaTab("Tipo")
                                        pmValor = vcaTab("Valor")
                                        pmValorPerc = vcaTab("Valor")
                                        pmTipoValor = vcaTab("TipoValor")
                                        VariacaoID=vcaTab("id")
                                    vcaTab.movenext
                                    wend
                                    vcaTab.close
                                    set vcaTab=nothing

                                    pmFator=0

                                    if pmTipo="F" then
                                        Valor = pmValor
                                    elseif pmTipo="D" or pmTipo="A" then
                                        if pmTipoValor="V" then
                                            pmDescAcre = pmValor
                                        else
                                            pmFator = pmValor/100
                                            pmDescAcre = pmFator * ValorBase
                                        end if
                                        if pmTipo="D" then
                                            sinalVariacao="-"
                                            pmValor = ValorBase - pmDescAcre
                                        else
                                            sinalVariacao="+"
                                            pmValor = ValorBase + pmDescAcre
                                        end if
                                        Valor = pmValor
                                    end if
                                end if

                                if Valor=0 then
                                    ValorVariacao = ValorBase
                                else
                                    ValorVariacao= Valor
                                end if
                        %>
                            <tr>
                                <td>
                                    <%=NomeFantasia%>
                                </td>
                                <td>
                                    <%=NomeTabela%>
                                </td>
                                <td>
                                    <%=NomeProcedimento%>
                                </td>
                                <td class="text-right">
                                    <%=fn(ValorProcedimento)%>
                                </td>
                                <td class="text-right">
                                    <%=fn(ValorBase)%><% if DescricaoTabelaDePreco<>"" then %> (<a target="_blank" href="?P=TabelasPreco&Pers=1I=<%=TabelaDePrecoID%>"><%=DescricaoTabelaDePreco%></a>)<% end if %>
                                </td>
                                <td class="text-right">
                                    <%
                                    if (pmTipo="D" or pmTipo="A") and pmTipoValor="P" then
                                        %>
                                        <%=sinalVariacao&pmValorPerc%>%
                                        <%
                                    end if
                                    if VariacaoID>0 then
                                    %>
                                    (<a target="_blank" href="./?P=VariacoesPrecos&I=<%=VariacaoID%>&Pers=1"><%=VariacaoID%></a>)
                                    <%
                                    end if
                                    %>
                                </td>
                                <td class="text-right">
                                    <strong><%=fn(ValorVariacao)%></strong>
                                </td>
                            </tr>
                        <%

                        response.Flush()
                        ProcedimentosSQL.movenext
                        wend
                        ProcedimentosSQL.close
                        set ProcedimentosSQL=nothing


                    TabelasSQL.movenext
                    wend
                    TabelasSQL.close
                    set TabelasSQL=nothing
                    %>
                <%


            UnidadesSQL.movenext
            wend
            UnidadesSQL.close
            set UnidadesSQL=nothing
            %>
                </tbody>
                <%
                end if
                %>
        </table>
    </div>
</div>

<script >
<!--#include file="JQueryFunctions.asp"-->

</script>