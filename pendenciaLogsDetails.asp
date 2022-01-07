<!--#include file="connect.asp"-->
<%
usuarioID = req("usuarioID")
pendenciaID = req("pendenciaID")

where = ""

If usuarioID <> 0  Then
    where = "where pe.sysUser = " & usuarioID
End if  

If pendenciaID <> 0  Then
    where = "where pe.PendenciaID = " &pendenciaID
End if  

sqlPendencia = " SELECT pe.pendenciaID,                                                                                                                                                        "&chr(13)&_
" pe.sysUser usuarioid,                                                                                                                                                                           "&chr(13)&_
" DATE_FORMAT(pe.DHUp,'%d/%m/%Y') Data,                                                                                                                                                           "&chr(13)&_
" DATE_FORMAT(pe.DHUp,'%H:%i') Hora,                                                                                                                                                              "&chr(13)&_
" lu.nome usuario,                                                                                                                                                                                "&chr(13)&_
" retorna_nome_unidade(pe.UnidadeID) Unidade,                                                                                                                                                     "&chr(13)&_
" ps.NomeStatus,                                                                                                                                                                                  "&chr(13)&_
" pa.NomePaciente,                                                                                                                                                                                "&chr(13)&_
" (SELECT GROUP_CONCAT(pr.NomeProcedimento) FROM pendencia_procedimentos pp                                                                                                                       "&chr(13)&_
" JOIN agendacarrinho ac ON ac.id = pp.BuscaID                                                                                                                                                    "&chr(13)&_
" JOIN procedimentos pr ON pr.id = ac.ProcedimentoID                                                                                                                                              "&chr(13)&_
" WHERE pp.pendenciaID = pe.id  ) Procedimento ,                                                                                                                                                  "&chr(13)&_
" pe.Zonas, CASE pe.Requisicao WHEN 'C' THEN 'Central' WHEN 'P' THEN 'Particular' WHEN 'S' THEN 'SUS' END Requisicao, CASE pe.Contato WHEN 'P' THEN 'Paciente' WHEN 'O' THEN 'Outro' END Contato, "&chr(13)&_
" pe.ObsRequisicao,                                                                                                                                                                               "&chr(13)&_
" pe.ObsContato,                                                                                                                                                                                  "&chr(13)&_
" pe.ObsExclusao,                                                                                                                                                                                 "&chr(13)&_
" me.Motivo,                                                                                                                                                                                      "&chr(13)&_
" pe.sysActive                                                                                                                                                                                    "&chr(13)&_
" FROM pendencia_logs pe                                                                                                                                                                              "&chr(13)&_
" JOIN pendenciasstatus ps ON ps.id = pe.StatusID                                                                                                                                                 "&chr(13)&_
" JOIN cliniccentral.licencasusuarios lu ON lu.id = pe.sysUser                                                                                                                                    "&chr(13)&_
" LEFT JOIN motivoexclusao me ON me.Id = pe.MotivoExclusaoID                                                                                                                                      "&chr(13)&_
" LEFT JOIN pacientes pa ON pa.id = pe.PacienteID                                                                                                                                                 "&chr(13)&_
where                                                                                                                                                                                       &chr(13)&_
" ORDER BY pe.DHUp DESC                                                                                                                                                                           "

If usuarioID <> 0 Then
    where = "where pd.sysUser = " & usuarioID
End if  
If pendenciaID <> 0  Then
    where = "where pd.PendenciaID = " & pendenciaID
End if  

sqlDatas =  " SELECT pd.PendenciaID,                          "&chr(13)&_
" pd.sysUser,                                                 "&chr(13)&_
" pd.sysActive,                                               "&chr(13)&_
" DATE_FORMAT(pd.DHUp,'%d/%m/%Y') Data,                       "&chr(13)&_
" DATE_FORMAT(pd.DHUp,'%H:%i') Hora,                          "&chr(13)&_
" lu.nome usuario,                                            "&chr(13)&_
" pa.NomePaciente,                                            "&chr(13)&_
" DATE_FORMAT(Data, '%d/%m/%Y') DATA,                         "&chr(13)&_
" TurnoManha,                                                 "&chr(13)&_
" TurnoTarde,                                                 "&chr(13)&_
" Observacao                                                  "&chr(13)&_
" FROM pendencia_data_log pd                                      "&chr(13)&_
" JOIN cliniccentral.licencasusuarios lu ON lu.id = pd.sysUser"&chr(13)&_
" LEFT JOIN pendencias pe ON pe.id = pd.PendenciaID           "&chr(13)&_
" LEFT JOIN pacientes pa ON pa.id = pe.PacienteID             "&chr(13)&_
where  &" ORDER BY pd.DHUp DESC                               "&chr(13)&_
"                                                             "

If usuarioID <> 0 Then
    where = "where pp.sysUser = " & usuarioID
End if  
If pendenciaID <> 0  Then
    where = "where pp.PendenciaID = " & pendenciaID
End if  

sqlProcedimentos = " SELECT pp.PendenciaID,                        "&chr(13)&_
" pp.sysUser,                                                      "&chr(13)&_
" pp.sysActive,                                                    "&chr(13)&_
" DATE_FORMAT(pp.DHUp,'%d/%m/%Y') Data,                            "&chr(13)&_
" DATE_FORMAT(pp.DHUp,'%H:%i') Hora,                               "&chr(13)&_
" lu.nome usuario,                                                 "&chr(13)&_
" pa.NomePaciente,                                                 "&chr(13)&_
" pr.NomeProcedimento                                              "&chr(13)&_
" FROM pendencia_procedimentos_log pp                                  "&chr(13)&_
" LEFT JOIN agendacarrinho ac ON ac.id = pp.buscaid                "&chr(13)&_
" LEFT JOIN procedimentos pr ON pr.id = ac.procedimentoid          "&chr(13)&_
" LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id = pp.sysUser"&chr(13)&_
" LEFT JOIN pendencias pe ON pe.id = pp.PendenciaID                "&chr(13)&_
" LEFT JOIN pacientes pa ON pa.id = pe.PacienteID                  "&chr(13)&_
where  &" ORDER BY pp.DHUp DESC                                    "

If usuarioID <> 0 Then
    where = "where pce.sysUser = " & usuarioID
End if  
If pendenciaID <> 0  Then
    where = "where pp.PendenciaID = " & pendenciaID
End if  

sqlContatos = " SELECT pp.PendenciaID,                                            "&chr(13)&_
" pce.sysUser,                                                                    "&chr(13)&_
" pce.sysActive,                                                                  "&chr(13)&_
" DATE_FORMAT(pce.DHUp,'%d/%m/%Y') DataRegistro,                                  "&chr(13)&_
" DATE_FORMAT(pce.DHUp,'%H:%i') HoraRegistro,                                     "&chr(13)&_
" lu.nome usuario,                                                                "&chr(13)&_
" pce.Data dataSelecionada,                                                       "&chr(13)&_
" DATE_FORMAT(pce.Hora,'%H:%i') horaSelecionada,                                  "&chr(13)&_
" pce.TurnoManha,                                                                 "&chr(13)&_
" pce.TurnoTarde,                                                                 "&chr(13)&_
" pce.Observacoes,                                                                "&chr(13)&_
" pce.Contato, pce.valor,                                                         "&chr(13)&_
" pes.NomeStatus, pr.NomeProcedimento, pe.id PacienteID,                          "&chr(13)&_
" COALESCE(pro.NomeSocial, pro.NomeProfissional) NomeProfissional                 "&chr(13)&_
" FROM pendencia_contatos_executantes_log pce                                         "&chr(13)&_
" LEFT JOIN cliniccentral.pendencia_executante_status pes ON pes.id = pce.StatusID"&chr(13)&_
" LEFT JOIN pendencia_procedimentos pp ON pp.id = pce.PendenciaProcedimentoID     "&chr(13)&_
" LEFT JOIN pendencias pe ON pe.id = pp.PendenciaID                               "&chr(13)&_
" LEFT JOIN agendacarrinho ac ON ac.id = pp.BuscaID                               "&chr(13)&_
" LEFT JOIN procedimentos pr ON pr.id = ac.ProcedimentoID                         "&chr(13)&_
" LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id = pce.sysUser              "&chr(13)&_
" LEFT JOIN profissionais pro ON pro.id = pce.ExecutanteID                        "&chr(13)&_
where  &" ORDER BY pce.DHUp DESC                                                  "

%>

<div class="panel">
    <div class="panel-body">
        <div class="bs-component">
            <div class="panel">
                <div class="panel-heading">
                    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab">
                        <li class="active">
                            <a data-toggle="tab" href="#Pendencia" id="tabPendencia">
                                Pendência 
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Data" id="tabData">
                                Datas
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Procedimento" id="tabProcedimento">
                                Procedimentos
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Contato" id="tabContato">
                                Contatos
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="panel-body">
                    <div class="tab-content pn br-n">
                        <div id="Pendencia" class="tab-pane active widget-box transparent">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data registro</th>
                                        <th>Hora registro</th>
                                        <th>Usuário</th>
                                        <th>Paciente</th>
                                        <th>Zonas</th>
                                        <th>Requisição</th>
                                        <th>Observação da requisição</th>
                                        <th>Contato</th>
                                        <th>Observação do contato</th>
                                        <th>Status</th>
                                        <th>Ativo</th>
                                        <th>Observação da exclusão</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% 
                                    Set p = db.execute(sqlPendencia)
                                    while not p.eof 
                                %>
                                    <% If p("sysActive") = 1 Then %>
                                        <tr>
                                    <% Else %>
                                        <tr class="danger">
                                    <% End if %>
                                        <td><%= p("pendenciaid") %></td>
                                        <td><%= p("Data") %></td>
                                        <td><%= p("Hora") %></td>
                                        <td><%= p("usuario") %></td>
                                        <td><%= p("NomePaciente") %></td>
                                        <td><%= p("Zonas") %></td>
                                        <td><%= p("Requisicao") %></td>
                                        <td><%= p("ObsRequisicao") %></td>
                                        <td><%= p("Contato") %></td>
                                        <td><%= p("ObsRequisicao") %></td>
                                        <td><%= p("NomeStatus") %></td>
                                        <% If p("sysActive") = 1 Then %>
                                            <td>Ativo</td>
                                        <% Else %>
                                            <td>Inativo</td>
                                        <% End if %>
                                        <td><%= p("ObsExclusao") %></td>
                                    </tr>
                                <% 
                                    p.movenext
                                    Wend
                                    p.Close
                                    Set p = Nothing 
                                %>    
                                </tbody>
                            </table>
                        </div>
                        <div id="Data" class="tab-pane">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data registro</th>
                                        <th>Hora registro</th>
                                        <th>Usuário</th>
                                        <th>Paciente</th>
                                        <th>Data selecionada</th>
                                        <th>Turno manhã</th>
                                        <th>Turno tarde</th>
                                        <th>Observação</th>
                                        <th>Ativo</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% 
                                    Set p = db.execute(sqlDatas)
                                    while not p.eof 
                                %>
                                    <% If p("sysActive") = 1 Then %>
                                        <tr>
                                    <% Else %>
                                        <tr class="danger">
                                    <% End if %>
                                        <td><%= p("pendenciaid") %></td>
                                        <td><%= p("Data") %></td>
                                        <td><%= p("Hora") %></td>
                                        <td><%= p("usuario") %></td>
                                        <td><%= p("NomePaciente") %></td>
                                        <td> 99/99/9999 </td>

                                        <% If p("TurnoManha") = "M" Then %>
                                            <td>Manhã</td>
                                            <td></td>
                                        <% Else %>
                                            <td></td>
                                            <td>Tarde</td>
                                            
                                        <% End if %>
                                        <td><%= p("Observacao") %></td>
                                        <% If p("sysActive") = 1 Then %>
                                            <td>Ativo</td>
                                        <% Else %>
                                            <td>Inativo</td>
                                        <% End if %>
                                    </tr>
                                <% 
                                    p.movenext
                                    Wend
                                    p.Close
                                    Set p = Nothing 
                                %> 
                                </tbody>
                            </table>
                        </div>
                        <div id="Procedimento" class="tab-pane">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data registro</th>
                                        <th>Hora registro</th>
                                        <th>Usuário</th>
                                        <th>Paciente</th>
                                        <th>Procedimento</th>
                                        <th>Ativo</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% 
                                    Set p = db.execute(sqlProcedimentos)
                                    while not p.eof 
                                %>
                                    <% If p("sysActive") = 1 Then %>
                                        <tr>
                                    <% Else %>
                                        <tr class="danger">
                                    <% End if %>
                                        <td><%= p("pendenciaid") %></td>
                                        <td><%= p("Data") %></td>
                                        <td><%= p("Hora") %></td>
                                        <td><%= p("usuario") %></td>
                                        <td><%= p("NomePaciente") %></td>
                                        <td><%= p("NomeProcedimento") %></td>
                                        <% If p("sysActive") = 1 Then %>
                                            <td>Ativo</td>
                                        <% Else %>
                                            <td>Inativo</td>
                                        <% End if %>
                                    </tr>
                                <% 
                                    p.movenext
                                    Wend
                                    p.Close
                                    Set p = Nothing 
                                %> 
                                </tbody>
                            </table>
                        </div>
                        <div id="Contato" class="tab-pane">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data registro</th>
                                        <th>Hora registro</th>
                                        <th>Usuário</th>
                                        <th>Paciente</th>
                                        <th>Procedimento</th>
                                        <th>Data selecionada</th>
                                        <th>Hora selecionada</th>
                                        <th>Valor</th>
                                        <th>Profissional</th>
                                        <th>Observação</th>
                                        <th>Contato</th>
                                        <th>Status</th>
                                        <th>Ativo</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% Set p = db.execute(sqlContatos) 
                                If p.eof Then %>
                                        <tr class="danger">
                                            <td colspan="100%">NENHUM DADO ENCONTRADO</td>
                                        </tr>
                                <% end if %>
                                <% 
                                    while not p.eof 
                                %>
                                    <% If p("sysActive") = 1 Then %>
                                        <tr>
                                    <% Else %>
                                        <tr class="danger">
                                    <% End if %>
                                    
                                        <td><%= p("pendenciaid") %></td>
                                        <td><%= p("DataRegistro") %></td>
                                        <td><%= p("HoraRegistro") %></td>
                                        <td><%= p("usuario") %></td>
                                        <td><%= p("PacienteID") %></td>
                                        <td><%= p("NomeProcedimento") %></td>
                                        <td><%= p("dataSelecionada") %></td>
                                        <td><%= p("horaSelecionada") %></td>
                                        <td><%= FormatCurrency(p("valor"),2) %></td>
                                        <td><%= p("NomeProfissional") %></td>
                                        <td><%= p("Observacoes") %></td>
                                        <td><%= p("Contato") %></td>
                                        <td><%= p("NomeStatus") %></td>
                                        <% If p("sysActive") = 1 Then %>
                                            <td>Ativo</td>
                                        <% Else %>
                                            <td>Inativo</td>
                                        <% End if %>
                                    </tr>
                                <% 
                                    p.movenext
                                    Wend
                                    p.Close
                                    Set p = Nothing 
                                %>     
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>