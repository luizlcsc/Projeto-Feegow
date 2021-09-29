<!--#include file="connect.asp"-->
<!--#include file="Classes/Restricao.asp"-->

<%
acao = ref("acao")&""

if acao = "" then

    acao = req("acao")

end if

if acao = "abrirModalRestricaoPreparo" then

    ProcedimentoID = ref("ProcedimentoID")
    ProfissionalID = ref("ProfissionalID")
    PropostaID = ref("PropostaID")

    if ProfissionalID <> "" then
        where = " SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalID&" AND "
    else
        where = " "
    end if

    sqlRestricao = " SELECT count(*) totalRestricoes "&_
                    "   FROM procedimentosrestricaofrase prf "&_
                    "   JOIN sys_restricoes r ON r.id = prf.RestricaoID "&_
                    "  WHERE ProcedimentoID = "&ProcedimentoID&" "&_
                    "    AND (ExcecaoID IN ((SELECT id FROM procedimentosrestricoesexcecao WHERE "&where&" ProcedimentoID = "&ProcedimentoID&")) OR ExcecaoID = 0) "
        
    sqlPreparo = "SELECT count(*) totalPreparos "&_
                "      FROM procedimentospreparofrase "&_
                "      JOIN sys_preparos ON sys_preparos.id = procedimentospreparofrase.PreparoID"&_
                " LEFT JOIN procedimentospreparosexcecao ON procedimentospreparosexcecao.id = procedimentospreparofrase.ExcecaoID"&_
                " WHERE procedimentospreparofrase.ProcedimentoID ="&ProcedimentoID&_
                "    AND (ExcecaoID IN ((SELECT id FROM procedimentospreparosexcecao WHERE "&where&" ProcedimentoID = "&ProcedimentoID&")) OR ExcecaoID = 0) "

    totalRestricoes = db.execute(sqlRestricao)
    totalPreparos = db.execute(sqlPreparo)

    if ccur(totalRestricoes("totalRestricoes")) > 0 then
%>
        enviar(<%=totalPreparos("totalPreparos")%>);
<%
    elseif ccur(totalPreparos("totalPreparos")) > 0 then
%>
        openComponentsModal('procedimentosModalPreparo.asp?ProcedimentoId=' + ProcedimentoID+ '&PacientedId=' + PacienteID+'&agendamentoID=' + agendamentoID + '&requester=AgendaMultipla&ProfissionalID=' + ProfissionalID, true, 'Preparo', true, '')
<%
    else
        if CriarPendencia = "sim" then
%>
            var pendencias = [];
            var $pendenciasSelecionadas = $("input[name='BuscaSelecionada']");

            $.each($pendenciasSelecionadas, function() {
                pendencias.push($(this).val())
            });
            $(".modalpendencias").modal("hide");
            AbrirPendencias(0, pendencias);
<%
        elseif CriarPendencia <> "sim" then
%>
            abrirAgenda2();
<%
        end if
    end if

elseif acao = "VerificaDuplicidade" then

    PacienteID = ref("PacienteID")&""

    totalDuplicidade = 0

    if PacienteID <> "" then
        VerificaDuplicidade = db.execute("SELECT COUNT(id) total FROM pendencias WHERE PacienteID = "&PacienteID&" AND StatusID NOT IN (5,6) AND sysActive != -1 AND MotivoExclusaoID IS NULL")
        totalDuplicidade = VerificaDuplicidade("total")
    end if

    response.write(totalDuplicidade)

elseif acao = "carregaZona" then

    concatAND = replace(ref("zonaValor"),"''","'")

    zonasSQL = "SELECT DISTINCT Regiao id, Regiao FROM sys_financialcompanyunits WHERE sysActive=1 "&concatAND&" AND Regiao IS NOT NULL AND Regiao!=''"

    set zonas = db.execute(zonasSQL)

    response.write("<select class='class-zona' id='Regiao' name='Regiao'>")

    while not zonas.EOF

        response.write("<option value='"&zonas("id")&"'>"&zonas("Regiao")&"</option>")

        zonas.movenext
    wend

    zonas.close
    set zonas = nothing

    response.write("</select><script>$('.class-zona').select2();</script>")

elseif acao = "carregaTimeline" then

    PendenciaID = req("PendenciaID")

    sqlTimeLine = "SELECT pes.NomeStatus, "&_ 
                  " CONCAT(DATE_FORMAT(t.DataInicio,'%d/%m/%Y'),' ',DATE_FORMAT(t.DataInicio,'%H:%i')) DataInicio, "&_ 
                  " CONCAT(DATE_FORMAT(t.DataFim,'%d/%m/%Y'),' ',DATE_FORMAT(t.DataFim,'%H:%i')) DataFim, "&_ 
                  " SUBSTRING_INDEX(TIMEDIFF(COALESCE(t.DataFim,CURRENT_TIMESTAMP()), t.DataInicio),':',2) Tempo, "&_
                  " lu.Nome "&_
                  " FROM pendencia_timeline t "&_ 
                  " JOIN pendenciasstatus pes ON pes.id = t.StatusID "&_
                  " JOIN cliniccentral.licencasusuarios lu ON lu.id = t.sysUser"&_
                  " WHERE t.PendenciaID = "&PendenciaID

    set timeLine = db.execute(sqlTimeLine)
%>
    <table class="table">
        <thead>
            <tr class="primary">
                <th>
                    Status
                </th>
                <th>
                    Data início
                </th>
                <th>
                    Data fim
                </th>
                <th>
                    Tempo
                </th>
                <th>
                    Usuário
                </th>
            </tr>
        </thead>
        <tbody>
<%
    while not timeLine.eof
%>
        <tr>
            <td>
                <%=timeLine("NomeStatus")%>
            </td>
            <td>
                <%=timeLine("DataInicio")%>
            </td>
            <td>
                <%=timeLine("DataFim")%>
            </td>
            <td>
                <%=timeLine("Tempo")%>
            </td>
            <td>
                <%=timeLine("Nome")%>
            </td>
        </tr>
<%
        timeline.movenext
    wend
%>
        </tbody>
    </table>
    <br>
<%
    timeLine.close
    set timeLine = nothing


    sqlTotais = " SELECT pes.NomeStatus, SUBSTRING_INDEX(TIME(SUM(TIMEDIFF(COALESCE(t.DataFim,CURRENT_TIMESTAMP()), t.DataInicio))),':',2) Tempo "&_
                " FROM pendencia_timeline t "&_
                " JOIN cliniccentral.pendencia_executante_status pes ON pes.id = t.StatusID "&_
                " WHERE t.PendenciaID = "&PendenciaID&_
                " GROUP BY pes.NomeStatus"
   
    set totais = db.execute(sqlTotais)
%>
    <table class="table">
        <thead>
            <tr class="primary">
                <th colspan="100%">
                    Totais 
                </th>
            </tr>
            <tr class="primary">
                <th>
                    Status
                </th>
                <th>
                    Tempo total
                </th>
            </tr>
<%
    while not totais.eof
%>
            <tr>
                <td>
                    <%=totais("NomeStatus")%>
                </td>
                <td>
                    <%=totais("Tempo")%>
                </td>
            </tr>
<%
        totais.movenext    
    wend
    totais.close
    set totais = nothing
%>
        </tbody>
    </table>
<%

elseif acao = "VerificaPendencia" then
    PendenciaID = ref("PendenciaID")&""
    totalErros = 0
    
    qPendenciaSQL = "SELECT * FROM pendencia_procedimentos WHERE sysActive = 1 and pendenciaid = " &PendenciaID
    set PendenciaSQL = db.execute(qPendenciaSQL)
 
    while not PendenciaSQL.eof      
        set sql = db.execute("SELECT * FROM pendencia_contatos_executantes WHERE pendenciaprocedimentoid = "&PendenciaSQL("id")& " ORDER BY sysdate DESC LIMIT 1")

        if sql.eof then
            totalErros = totalErros + 1
        elseif sql("StatusID") <> 6 then
            totalErros = totalErros + 1
        end if

        PendenciaSQL.movenext
    wend
    
    PendenciaSQL.close
    set PendenciaSQL = nothing
    response.write(totalErros)

elseif acao = "VerificaSessao" then

    function difHoras(dthora)
        dts = Split(dtHora, " ")
        hora = dts(1)

        min = DateDiff("n", dthora, now )
        
        if min > 60 then
            horas = int( (min / 60) )
            
            restomin = min mod 60
            if horas <= 9 then horas = "0"&horas end if
            if restomin <= 9 then restomin = "0"&restomin end if
            difHoras = horas & ":" & restomin
        else
            if min <= 9 then min = "0"&min end if
            difHoras = "00:" & min
        end if
    end function

    MinutosPendencia = getConfig("MinutosPendencia")

    if MinutosPendencia > 0 then
        ResMinutosPendencia = MinutosPendencia
    else
        ResMinutosPendencia = 0
    end if

    PacienteID = ref("PacienteID")
    UnidadeID = ref("UnidadeID")
    GrupoID = ref("GrupoID")
    StatusID = ref("StatusID")
    OrdernarPor = ref("OrdernarPor")
    OrdernarTipo = ref("OrdernarTipo")

    countSqlGrupo = "0"
    countSqlStatus = "0"

    if GrupoID > "0" then
        countSqlGrupo = "(SELECT count(pp.id)Qtd FROM pendencia_procedimentos pp inner join agendacarrinho ac on ac.id = pp.BuscaID WHERE ProcedimentoID IN (SELECT id FROM procedimentos WHERE GrupoID = " & GrupoID & ") AND PendenciaID = pend.id)"
    end if 
    
    if StatusID > "0" then
        countSqlStatus = "(SELECT count(pp.id)Qtd FROM pendencia_procedimentos pp inner join pendencia_contatos_executantes ppe on ppe.PendenciaProcedimentoID = pp.id WHERE ppe.StatusID = " & StatusID & " AND PendenciaID = pend.id)"
    end if 

    if countSqlGrupo = "0" and countSqlStatus = "0" then 
        countSql = "1"
    else 
        countSql = countSqlGrupo&" + "&countSqlStatus
    end if

    sqlPendencias = " SELECT DISTINCT pend.id, pend.sysDate, pend.Datas,  pac.NomePaciente, "&_
                        " pend.Zonas, "&_
                        " DATE_FORMAT(pend.sysDate,'%d/%m/%Y') AS `Data`, "&_
                        " DATE_FORMAT(pend.sysDate,'%H:%i') AS `Hora`, "&_
                        " SUBSTRING_INDEX(TIMEDIFF(CURRENT_TIMESTAMP(), t.DataInicio),':',2) AS Tempo, "&_
                        " '1' AS temProcedimento, " &_
                        " ps.NomeStatus, "&_
                        " pend.StatusID, "&_
                        " (SELECT count(id)Qtd FROM pendencia_procedimentos WHERE PendenciaID = pend.id AND sysActive = 1) AS Qtd, "&_
                        " t.DataInicio datacontato, "&_ 
                        " TIMEDIFF(CURRENT_TIMESTAMP(), t.DataInicio) AS TempoOrdenacao, "&_
                        " CASE WHEN pend.StatusID = 5 THEN (SELECT SUBSTRING_INDEX(TIMEDIFF(COALESCE(t.DataFim, CURRENT_TIMESTAMP()), t.DataInicio),':',2) "&_
                        " FROM pendencia_timeline t "&_
                        " WHERE t.Ativo = 1 AND t.PendenciaID = pend.id) ELSE NULL END TempoPaciente "&_
                    " FROM pendencias pend "&_
                    " LEFT JOIN pendencia_timeline t ON t.PendenciaID = pend.id AND t.Ativo = 1 "&_ 
                    " LEFT JOIN pacientes pac ON pac.id= pend.PacienteID "&_ 
                    " LEFT JOIN pendenciasstatus ps ON ps.id = pend.StatusID "&_
                    " LEFT JOIN pendencia_procedimentos pp ON pp.PendenciaID = pend.id AND pp.sysActive = 1"&_
                    " LEFT JOIN agendacarrinho ac ON ac.id = pp.BuscaID "&_ 
                    " LEFT JOIN procedimentos p ON p.id = ac.ProcedimentoID "&_
                    " WHERE pend.sysActive=1 "&_ 
                    " AND pend.StatusID NOT IN (0,6) "

    if PacienteID <> "" and PacienteID > "0" then
        sqlPendencias = sqlPendencias & " AND pac.ID = " & PacienteID
    end if
    
    if UnidadeID <> "" then
        sqlPendencias = sqlPendencias & " AND pend.UnidadeID = " & UnidadeID
    end if

    if GrupoID > "0" then
        sqlPendencias = sqlPendencias & " AND p.GrupoID = " & GrupoID
    end if

    if StatusID > "0" then
        sqlPendencias = sqlPendencias & " AND pend.StatusID = " & StatusID
    end if
    
    if OrdernarPor <> "" then

        if OrdernarPor = "TempoPaciente" and OrdernarTipo = "ASC" then
            sqlPendencias = sqlPendencias & " ORDER BY COALESCE(" & OrdernarPor & ",999999999999999) "
        else 
            sqlPendencias = sqlPendencias & " ORDER BY " & OrdernarPor
        end if
        
    else 
        sqlPendencias = sqlPendencias & " ORDER BY pend.sysDate "
    end if

    if OrdernarTipo <> "" then
        sqlPendencias = sqlPendencias & " " & OrdernarTipo
    end if

    set PendenciasSQL = db.execute(sqlPendencias)

    if PendenciasSQL.eof then
%>
        <tr>
            <td colspan="100%" style="text-align:center">
                Nenhuma pendência cadastrada
            </td>
        </tr>
<%

    else 
        while not PendenciasSQL.eof

            if PendenciasSQL("temProcedimento") > "0" then 
                    set verificaSessao = db.execute(" SELECT Nome, "&_ 
                                                " UsuarioID "&_ 
                                                " FROM pendencia_sessao ps "&_ 
                                                " JOIN cliniccentral.licencasusuarios lu ON lu.id = ps.UsuarioID "&_ 
                                                " WHERE ps.PendenciaID = "&PendenciasSQL("id"))
                
                bloquear = false
                UsuarioBloqueio = ""

                if not verificaSessao.eof then
                    if (verificaSessao("UsuarioID") <> session("User")) then
                        UsuarioBloqueio = verificaSessao("Nome")
                        bloquear = true
                    end if
                end if

                set StatusAtual = db.execute("SELECT pes.NomeStatus, t.StatusID, "&_ 
                                        " CONCAT(DATE_FORMAT(t.DataInicio,'%d/%m/%Y'),' ',DATE_FORMAT(t.DataInicio,'%H:%i')) DataInicio, "&_ 
                                        " CONCAT(DATE_FORMAT(t.DataFim,'%d/%m/%Y'),' ',DATE_FORMAT(t.DataFim,'%H:%i')) DataFim, "&_ 
                                        " CASE WHEN TIMESTAMPDIFF(MINUTE,DataInicio,NOW()) > "&ResMinutosPendencia&" THEN 'atraso' END Minutos"&_
                                        " FROM pendencia_timeline t "&_ 
                                        " JOIN pendenciasstatus pes ON pes.id = t.StatusID "&_
                                        " WHERE t.StatusID <> 5 AND t.PendenciaID = "&PendenciasSQL("id")&_
                                        " ORDER BY t.id DESC LIMIT 1")

                set TempoTotalPendencia = db.execute("SELECT SUBSTRING_INDEX(TIMEDIFF(NOW(), sysDate),':',2) Tempo FROM pendencias WHERE id = "&PendenciasSQL("id"))

                set StatusPaciente = db.execute("SELECT pes.NomeStatus, t.StatusID, "&_ 
                                        " CONCAT(DATE_FORMAT(t.DataInicio,'%d/%m/%Y'),' ',DATE_FORMAT(t.DataInicio,'%H:%i')) DataInicio, "&_ 
                                        " CONCAT(DATE_FORMAT(t.DataFim,'%d/%m/%Y'),' ',DATE_FORMAT(t.DataFim,'%H:%i')) DataFim, "&_ 
                                        " SUBSTRING_INDEX(TIMEDIFF(COALESCE(t.DataFim,CURRENT_TIMESTAMP()), t.DataInicio),':',2) Tempo, "&_
                                        " CASE WHEN TIMESTAMPDIFF(MINUTE,DataInicio,NOW()) > "&ResMinutosPendencia&" THEN 'atraso' END Minutos"&_
                                        " FROM pendencia_timeline t "&_ 
                                        " JOIN pendenciasstatus pes ON pes.id = t.StatusID "&_
                                        " WHERE t.Ativo = 1 AND t.PendenciaID = "&PendenciasSQL("id"))

                atraso = false
                
                StatusAtualDataInicio = ""
                
                if not StatusAtual.eof then

                    StatusAtualDataInicio = StatusAtual("DataInicio")
                    if StatusAtual("Minutos")&"" = "atraso" then
                        atraso = true
                    end if
                end if

                %>
                <tr id="tr<%=PendenciasSQL("id") %>" <% if bloquear then 
                                                            response.write("class='warning'") 
                                                        elseif atraso then 
                                                            response.write("class='danger'") 
                                                        end if %> >

                    <td><%=PendenciasSQL("NomePaciente")%></td>
                    <td><% if PendenciasSQL("Zonas") <>"" then  response.write(replace(PendenciasSQL("Zonas"), "|","")) end if%></td>
                    <td class="item" style="cursor:pointer;" data-value="<%=PendenciasSQL("id") %>"><%=PendenciasSQL("Qtd")%></td>
                    <td><%=PendenciasSQL("Data")%></td>
                    <td><%=PendenciasSQL("Hora")%></td>
                    <td data-value="<%=PendenciasSQL("id") %>"><% 

                        if StatusAtualDataInicio <> "" and StatusAtualDataInicio <> "0000-00-00 00:00:00"  then 
                            response.write(TempoTotalPendencia("Tempo"))
                        else 
                            response.write(" - ")
                        end if %></td>
                    <td><%=PendenciasSQL("NomeStatus") %></td>
                    <td><% if not StatusPaciente.eof then 
                                if StatusPaciente("StatusID") = 5 then 
                                    response.write(StatusPaciente("Tempo"))
                                end if 
                        end if
                    %>
                    </td>
                    <td nowrap>
                        <% if not bloquear then %>
                        <button onclick="GerenciarPendencia('<%=PendenciasSQL("id")%>')" type="button" class="btn btn-xs btn-warning"><i class="fa fa-cog"></i></button>
                        <button onclick="ExcluirPendencia('<%=PendenciasSQL("id")%>')" type="button" class="btn btn-xs btn-danger"><i class="fa fa-trash"></i></button>
                        <% else response.write("Pendência com "&UsuarioBloqueio) end if %>
                    </td>
                </tr>
    <%
            end if
        PendenciasSQL.movenext
        wend
    end if
    PendenciasSQL.close
    set PendenciasSQL = nothing
%>
<script>

    $(".item").on('click', function() {
        var value = $(this).attr("data-value")
        openComponentsModal("buscarProcedimentos.asp", {
                    A : 'PEND',
                   PendenciaID: value
               }, "Procedimentos", true, "");
    })

    $(".timeline").on('click', function() {
        var value = $(this).attr("data-value")
        openComponentsModal("pendenciasUtilities.asp", {
                    acao : 'carregaTimeline',
                   PendenciaID: value
               }, "Timeline", true, "");
    })
</script>
<%
elseif acao = "carregaProcedimentoExecutante" then

    ProcedimentoID=ref("ProcedimentoID")
    EspecialidadeID=ref("EspecialidadeID")
    PendenciaProcedimentoID=ref("PendenciaProcedimentoID")
    PacienteID =ref("PacienteID")

    function corrigeValoresPorVirgula(valores)
        corrigeValoresPorVirgula = replace(valores, ", ,", ", ")
    end function
    
    orderByField = ""

    set ZonaSQL = db.execute("SELECT Zonas "&_
                             "  FROM pendencias p "&_
                             "  JOIN pendencia_procedimentos pp ON pp.PendenciaID = p.id "&_
                             " WHERE pp.id = "&PendenciaProcedimentoID)
    
    if not ZonaSQL.eof then

        if ZonaSQL("Zonas") <> "" then
            zonas = split(ZonaSQL("Zonas"),",")
            for i=UBound(zonas) to 0 step-1
                
                fields = fields&("'"&trim(zonas(i))&"'")

                if i > 0 then
                    fields=fields&", "
                end if 
            next

            orderByField = " ORDER BY FIELD(sf.Regiao,"&fields&") DESC, sf.Regiao, NomeProfissional ASC "
        end if
    end if

    sql = "SELECT GROUP_CONCAT(DISTINCT p.id) SomenteProfissionais "&_ 
            " FROM procedimento_profissional_unidade ppu "&_ 
            " JOIN profissionais p ON p.id = ppu.id_profissional "&_ 
            " WHERE id_procedimento = "&ProcedimentoID&_ 
            " AND p.ativo = 'on' "&_ 
            " AND p.sysActive = 1"
            
    set ProcedimentoSQL = db.execute(sql)

    TemProfissional=False

    if not ProcedimentoSQL.eof then

        SomenteProfissionais = ProcedimentoSQL("SomenteProfissionais")

        if SomenteProfissionais <> "" then

            dim restricaoObj
            set restricaoObj = new Restricao

            

            SomenteProfissionais= replace(SomenteProfissionais, "|","")
            SomenteProfissionais= replace(SomenteProfissionais, ", ,",",")

            if SomenteProfissionais&"" <> "" then
                SomenteProfissionais=corrigeValoresPorVirgula(SomenteProfissionais)

                set ProfissionalSQL = db.execute("SELECT p.id, "&_ 
                                                "       COALESCE(NomeSocial, NomeProfissional) NomeProfissional, "&_ 
                                                "       p.Cidade, "&_
                                                "       sf.Regiao "&_
                                                "  FROM profissionais p "&_
                                                " JOIN procedimento_profissional_unidade pu ON pu.id_profissional = p.id "&_
                                                " JOIN sys_financialcompanyunits sf ON pu.id_unidade = sf.id "&_
                                                " WHERE p.id in ("&SomenteProfissionais&") "&_
                                                "   AND p.sysActive = 1 "&_
                                                "   AND p.ativo = 'on' "&_
                                                " GROUP BY p.id "&_
                                                orderByField)

                while not ProfissionalSQL.eof

                    TemProfissional=True
                    Status=""
                    ClasseStatus=""
                    StatusID=null
                    ExecutanteID=ProfissionalSQL("id")
                    set resultadoRestricao = restricaoObj.verificaRestricao(ProfissionalSQL("id"), ProcedimentoID, PacienteID, "", "")

                    set ContatosSQL = db.execute("SELECT count(id) as Qtd, MAX(id) as id FROM pendencia_contatos_executantes WHERE PendenciaProcedimentoID="&PendenciaProcedimentoID&" AND ExecutanteID="&ExecutanteID&" AND sysActive = 1")
                    QtdContatos = ContatosSQL("Qtd")

                    ValorTabela = calcValorProcedimento(ProcedimentoID, 0, "", ExecutanteID, EspecialidadeID, 0, "")

                    if ContatosSQL("id") <> "" then
                        set StatusSQL = db.execute("SELECT ce.StatusID, es.NomeStatus, es.Classe FROM cliniccentral.pendencia_executante_status es LEFT JOIN pendencia_contatos_executantes ce ON ce.StatusID=es.id WHERE PendenciaProcedimentoID="&PendenciaProcedimentoID&" AND ExecutanteID="&ExecutanteID&" AND ce.id='"&ContatosSQL("id")&"'")

                        if not StatusSQL.eof then
                            Status   = StatusSQL("NomeStatus")
                            StatusID = StatusSQL("StatusID")
                        end if
                    end if

                    ClasseStatus = resultadoRestricao.item("classe")

                    NomeProcedimento=""

                    set ProcedimentoPendenciaSQL = db.execute("SELECT proc.NomeProcedimento FROM pendencia_procedimentos pp INNER JOIN agendacarrinho ab ON ab.id=pp.BuscaID INNER JOIN procedimentos proc ON proc.id=ab.ProcedimentoID WHERE pp.id="&PendenciaProcedimentoID)
                    if not ProcedimentoPendenciaSQL.eof then
                        NomeProcedimento=ProcedimentoPendenciaSQL("NomeProcedimento")
                    end if

%>
            <tr class="<%=ClasseStatus%>">
                <td><%=ProfissionalSQL("NomeProfissional")%></td>
                <td><%=ProfissionalSQL("Cidade")%></td>
                <td><%=ProfissionalSQL("Regiao")%></td>
                <td><%=Status%></td>
                <td style="text-align:right"><%=fn(ValorTabela)%></td>
                <td style="text-align:center"><%=QtdContatos%></td>
                <td style="text-align:left; white-space: nowrap">
                    <button title="Observações" data-toggle="tooltip" onclick='obs(<%=ProfissionalSQL("id")%>);' type='button' class='btn btn-xs btn-primary'><i class='fa fa-info-circle'></i></button>
<%
                    if ccur(restricaoObj.possuiPreparo(ProcedimentoID)) > 0 then
%>
                    <button title="Preparos" data-toggle="tooltip" class="btn btn-system btn-xs" type="button" onclick="openComponentsModal('procedimentosModalPreparo.asp?ProcedimentoId=<%=ProcedimentoID%>&PacientedId=<%=PacienteID%>&ProfissionalID=<%=ProfissionalSQL("id")%>', true, 'Preparo', true, '')"><i class="fa fa-list-alt"></i></button>
<%
                    end if

                    if ccur(restricaoObj.possuiRestricao(ProcedimentoID)) > 0 then
%>
                        <button title="Restrições" data-toggle="tooltip" class="btn btn-dark btn-xs" type="button" onclick="abrirModalRestricao(<%=ProfissionalSQL("id")%>,<%=ProcedimentoID%>,<%=PacienteID%>)""><i class="fa fa-exclamation-circle"></i></button>
<%
                    end if

                    if resultadoRestricao.item("semExcecao") <> "S" then
%>
                        <button title="Contato" data-toggle="tooltip" class="btn btn-success btn-xs" type="button" onclick="RealizarContato('<%=PendenciaProcedimentoID%>', '<%=ExecutanteID%>', '<%=PacienteID %>')"><i class="fa fa-phone"></i></button>
<%
                    end if

                    if QtdContatos<>"0" then
                        if StatusID = 6 then
%>
                            <button title="Excluir" data-toggle="tooltip" class="btn btn-danger btn-xs" type="button" onclick="ExcluirExecutante2('<%=ContatosSQL("id")%>')"><i class="fa fa-times"></i></button>
                        <% end if %>
                        <button title="Visualizar contatos" data-toggle="tooltip" class="btn btn-default btn-xs" type="button" onclick="VisualizarContatos('<%=PendenciaProcedimentoID%>', '<%=ExecutanteID%>')"><i class="fa fa-history"></i></button>
                    <% end if %>
                </td>
            </tr>
                    <%
                ProfissionalSQL.movenext
                wend
                ProfissionalSQL.close
                set ProfissionalSQL=nothing

            end if

        end if

    end if
    if not TemProfissional then
        set ProcedimentoSQL = db.execute("SELECT NomeProcedimento FROM procedimentos WHERE id="&ProcedimentoID)
%>
    <tr>
        <td colspan="100%" class="text-center">Nenhum profissional configurado para executar este procedimento. <a target="_blank" href="?P=Procedimentos&Pers=1&I=<%=ProcedimentoID%>"><%=ProcedimentoSQL("NomeProcedimento")%></a></td>
    </tr>
<%
    end if

elseif acao = "verificaRestricao" then
    
    procedimentoID = ref("procedimentoID")
    parRestricaoID = ref("restricaoID")
    resposta = ref("resposta")

    dim restricaoObj2
    set restricaoObj2 = new Restricao

    splProcedimento = split(procedimentoID, ",")

    erro = "N"

    for i=0 to UBound(splProcedimento)

        sql = "SELECT SUBSTRING_INDEX(Conta,'_',-1) profissionalID "&_
            " FROM procedimentosrestricaofrase prf "&_
            " INNER JOIN procedimentosrestricoesexcecao pr ON prf.ExcecaoID=pr.id "&_
            " INNER JOIN sys_restricoes sr ON sr.id=prf.RestricaoID "&_
            " WHERE prf.ProcedimentoID="&splProcedimento(i)&_
            " AND sr.id = "&ref("restricaoID")
           
        set resProfissional = db.execute(sql)

        while not resProfissional.eof
            set resultadoRestricao = restricaoObj2.verificaRestricao(resProfissional("profissionalID"), splProcedimento(i), "", ref("restricaoID"), resposta)
            if resultadoRestricao.item("resultado") = "S" then
                erro = "S"
            end if
            resProfissional.movenext
        wend
        
        resProfissional.close
        set resProfissional = nothing
       
    next
    response.write(erro)

end if
%>