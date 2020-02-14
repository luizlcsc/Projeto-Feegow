<!--#include file="../connect.asp"-->
<%
ProcedimentoID=req("ProcedimentoID")

set ProcedimentoSQL= db.execute("SELECT GrupoID, Valor, SomenteEspecialidades, SomenteProfissionais, OpcoesAgenda FROM procedimentos WHERE id="&ProcedimentoID)

GrupoID = ProcedimentoSQL("GrupoID")
procValor = ProcedimentoSQL("Valor")
OpcoesAgenda = ProcedimentoSQL("OpcoesAgenda")
SomenteEspecialidades = ProcedimentoSQL("SomenteEspecialidades")
if not isnull(SomenteEspecialidades) then
    SomenteEspecialidades = replace(SomenteEspecialidades, "|", "")
end if
SomenteProfissionais = ProcedimentoSQL("SomenteProfissionais")
if not isnull(SomenteProfissionais) then
    SomenteProfissionais = replace(SomenteProfissionais, "|", "")
end if
ProfissionaisPadrao="-"
EspecialidadesPadrao="-"

if not isnull(OpcoesAgenda) then
    if OpcoesAgenda=4 then

        if SomenteEspecialidades&""<>"" then
            set EspecialidadesPadraoSQL = db.execute("SELECT group_concat(especialidade SEPARATOR ' , <br> ') Especialidades FROM especialidades WHERE id in ("&SomenteEspecialidades&")")
            if not EspecialidadesPadraoSQL.eof then
                EspecialidadesPadrao = EspecialidadesPadraoSQL("Especialidades")
            end if
        end if

        if SomenteProfissionais&""<>"" then
            set ProfissionaisPadraoSQL = db.execute("SELECT group_concat(NomeProfissional SEPARATOR ' , <br> ') Profissionais FROM profissionais WHERE id in ("&SomenteProfissionais&")")
            if not ProfissionaisPadraoSQL.eof then
                ProfissionaisPadrao = ProfissionaisPadraoSQL("Profissionais")
            end if
        end if
    else
        EspecialidadesPadrao="Todas"
        ProfissionaisPadrao="Todos"
    end if
end if

%>
<div class="row">
    <div class="col-md-12">
        <table class="table table-striped">
            <thead>
                <tr class="success">
                    <th>Unidade</th>
                    <th>Tabela</th>
                    <th>Valor Base - Procedimento</th>
                    <th>Diferença - Tabela</th>
                    <th>Valor Tabela</th>
                    <th>Diferença - Variação</th>
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

        set UnidadesSQL = db.execute("SELECT id, NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t ORDER BY t.NomeFantasia " )

        while not UnidadesSQL.eof
            NomeFantasia=UnidadesSQL("NomeFantasia")
            UnidadeID=UnidadesSQL("id")

            %>

            <tbody>
                <%
                set TabelasSQL = db.execute("SELECT * FROM tabelaparticular WHERE sysActive=1 AND Ativo='on' AND (Unidades LIKE '%|"&UnidadeID&"|%' OR Unidades='' OR Unidades IS NULL)")

                while not TabelasSQL.eof
                    TabelaID=TabelasSQL("id")


                    NomeTabela=TabelasSQL("NomeTabela")

                    set ProcedimentosSQL= db.execute("SELECT id,NomeProcedimento, Valor, GrupoID FROM procedimentos WHERE sysActive=1 AND Ativo='on' AND id="&ProcedimentoID)

                    while not ProcedimentosSQL.eof
                        ProcedimentoID=ProcedimentosSQL("id")
                        GrupoID=ProcedimentosSQL("GrupoID")
                        NomeProcedimento=ProcedimentosSQL("NomeProcedimento")
                        ValorProcedimento=ProcedimentosSQL("Valor")
                        ValorBase=ValorProcedimento
                        Valor=0
                        VariacaoID=0

                        sqlProcedimentoTabela = "SELECT pt.id, ptv.Valor, Profissionais, TabelasParticulares, Especialidades FROM procedimentostabelasvalores ptv INNER JOIN procedimentostabelas pt ON pt.id=ptv.TabelaID WHERE ProcedimentoID="&ProcedimentoID&" AND "&_
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
                                        pmValor = ValorBase - pmDescAcre
                                    else
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
                                <strong><%=NomeTabela%></strong>
                            </td>
                            <td>
                                <%=fn(ValorProcedimento)%>
                            </td>
                            <td>
                                <%= getDiferencaCor(ValorBase - ValorProcedimento) %>
                            </td>
                            <td>
                                <%=fn(ValorBase)%>

                            </td>
                            <td>
                                <%= getDiferencaCor(ValorVariacao - ValorBase) %>
                                <%
                                if (pmTipo="D" or pmTipo="A") and pmTipoValor="P" then
                                    %>
                                    (<%=pmValorPerc%>%)
                                    <%
                                end if
                                %>
                            </td>
                            <td>
                                <strong><%=fn(ValorVariacao)%></strong>
                                <%
                                if VariacaoID>0 then
                                %>
                                (<a href="./?P=VariacoesPrecos&I=<%=VariacaoID%>&Pers=1"><%=VariacaoID%></a>)
                                <%
                                end if
                                %>
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
        </table>
    </div>
</div>
<script >
    function EditaVariacao(TipoVariacao, ID) {
        if(TipoVariacao==="Valor padrão"){
            closeComponentsModal();
        }else if(TipoVariacao === "Variação"){
            location.href= ".?P=VariacoesPrecos&I="+ID+"&Pers=1";
        }else if(TipoVariacao === "Tabela de preço"){
            location.href= ".?P=ProcedimentosTabelas&I="+ID+"&Pers=1";
        }
    }
</script>