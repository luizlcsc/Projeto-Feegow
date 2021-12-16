<!--#include file="connect.asp"-->

<%
sqlData = ""
sqlUnidades = ""
sqlProfissionais = ""

Unidades = ref("Unidades")
DataDe = ref("DataDe")
DataAte = ref("DataAte")
ProfissionalID = ref("ProfissionalID")
StatusAgenda = ref("Status")

if ProfissionalID<>"" and ProfissionalID<>"0" then
    sqlProfissionais = " AND (SELECT prof.id FROM profissionaiscirurgia pc INNER JOIN profissionais prof ON prof.id=pc.ProfissionalID WHERE pc.GuiaID=ac.id AND pc.GrauParticipacaoID=100 LIMIT 1) = "&ProfissionalID
end if

if DataDe<>"" then
    sqlData = " AND ac.DataEmissao BETWEEN "&mydatenull(DataDe)&" AND "&mydatenull(DataAte)
end if

if Unidades<>"" then
    sqlUnidades = " AND ac.UnidadeID IN ("&replace(Unidades, "|", "")&")"
end if

if StatusAgenda<>"" then
    StatusAgenda = " AND s.id IN("&replace(StatusAgenda, "|", "")&")"
else
    StatusAgenda = " AND s.id IN(1,2,4,6,7,8) "
end if

cancelarId = req("x")
if cancelarId&"" <> "" then
    db.execute("update agendacirurgica set StatusID=3 where id="& cancelarId)
end if

Faturar = req("Faturar")
if Faturar<>"" then
    Tipo = req("Tipo")
    if Tipo="Invoice" then
        db.execute("insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, FormaID, ContaRectoID, sysDate, CaixaID) select PacienteID, '3', Valor, '1', 'BRL', UnidadeID, '1', 'm', 'C', '1', '"& session("User") &"', '0', '0', curdate(), "& treatvalnull(session("CaixaID")) &" from agendacirurgica where id="& Faturar)
        set pinv = db.execute("select id from sys_financialinvoices where sysUser="& session("User") &" order by id desc limit 1")
        Tabela = "invoice"
        IDFaturamento = pinv("id")
        db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, ItemID, ValorUnitario, Executado, DataExecucao, HoraExecucao, GrupoID, AgendamentoID, sysUser, ProfissionalID, Associacao) select '"& IDFaturamento &"', 'S', pc.Quantidade, pc.ProcedimentoID, pc.ValorUnitario, '', pc.Data, pc.HoraInicio, 0, 0, '"& session("User") &"', pc.ProfissionalID, '5' from procedimentoscirurgia pc WHERE pc.GuiaID="& Faturar)
        set mat = db.execute("select * from cirurgiaanexos where GuiaID="& Faturar)
        while not mat.eof
            db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, ItemID, ValorUnitario, sysUser, Executado) values ("& IDFaturamento &", 'M', "& treatvalzero(mat("Quantidade")) &", "& treatvalzero(mat("ProdutoID")) &", "& treatvalzero(mat("ValorUnitario")) &", "& session("User") &", 'U')")
        mat.movenext
        wend
        mat.close
        set mat = nothing
        db.execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, CaixaID, UnidadeID) select '0', '0', '3', ac.PacienteID, (select sum(Quantidade*(ValorUnitario+Acrescimo-Desconto)) from itensinvoice where InvoiceID="& IDFaturamento &"), curdate(), 'C', 'Bill', 'BRL', '1', '"& IDFaturamento &"', '1', '"&session("User")&"', "& treatvalnull(session("CaixaID")) &", ac.UnidadeID from agendacirurgica ac WHERE id="& Faturar)
    elseif Tipo="Honorarios" then
        db.execute("insert into tissguiahonorarios (PacienteID, CNS, ConvenioID, PlanoID, RegistroANS, Senha, NumeroCarteira, AtendimentoRN, Contratado,CodigoNaOperadora, CodigoCNES, ContratadoLocalCodigoNaOperadora, ContratadoLocalNome, ContratadoLocalCNES, Procedimentos, sysUser, sysActive, UnidadeID, DataEmissao) select PacienteID, CNS, ConvenioID, PlanoID, RegistroANS, Senha, NumeroCarteira, AtendimentoRN, Contratado,CodigoNaOperadora, CodigoCNES, ContratadoLocalCodigoNaOperadora, ContratadoLocalNome, ContratadoLocalCNES, Procedimentos, sysUser, sysActive, UnidadeID, curdate() from agendacirurgica WHERE id="& Faturar)
        set phon = db.execute("select id from tissguiahonorarios where sysUser="& session("User") &" order by id desc limit 1")
        IDFaturamento = phon("id")
        db.execute("insert into tissprocedimentoshonorarios (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser) select "& IDFaturamento &", ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, "& session("User") &" from procedimentoscirurgia where GuiaID="& Faturar)
        db.execute("insert into tissprofissionaishonorarios (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) select "& IDFaturamento &", Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, "& session("User") &" from profissionaiscirurgia WHERE GuiaID="& Faturar)
        Tabela = "tissguiahonorarios"
    elseif Tipo="SADT" then
        db.execute("insert into tissguiasadt (PacienteID, CNS, ConvenioID, PlanoID, RegistroANS, Senha, NumeroCarteira, AtendimentoRN, Contratado,CodigoNaOperadora, CodigoCNES, Procedimentos, sysUser, sysActive, UnidadeID) select PacienteID, CNS, ConvenioID, PlanoID, RegistroANS, Senha, NumeroCarteira, AtendimentoRN, Contratado,CodigoNaOperadora, CodigoCNES, Procedimentos, sysUser, sysActive, UnidadeID from agendacirurgica WHERE id="& Faturar)
        set phon = db.execute("select id from tissguiasadt where sysUser="& session("User") &" order by id desc limit 1")
        IDFaturamento = phon("id")
        db.execute("insert into tissprocedimentossadt (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser) select "& IDFaturamento &", ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, "& session("User") &" from procedimentoscirurgia where GuiaID="& Faturar)
        db.execute("insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) select "& IDFaturamento &", Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, "& session("User") &" from profissionaiscirurgia WHERE GuiaID="& Faturar)
        db.execute("insert into tissguiaanexa (GuiaID, CD, Data, TabelaProdutoID, ProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao, ProcGSID) select '"& IDFaturamento &"', CD, Data, TabelaProdutoID, ProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao, ProcGSID from cirurgiaanexos where GuiaID="& Faturar )
        Tabela = "tissguiasadt"
    end if
    db.execute("update agendacirurgica set StatusID=4, Tabela='"& Tabela &"', IDFaturamento="& IDFaturamento &" where id="& Faturar)
    response.Redirect("./?P=lAgendaCirurgica&Pers=1")
end if
%>
        <table class="table table-striped table-hover">
            <thead>
                <tr class="info">
                    <th>Status</th>
                    <th>Lote</th>
                    <th>Data</th>
                    <th>Hora</th>
                    <th>Paciente</th>
                    <th>Telefone</th>
                    <th>Local</th>
                    <th>Convênio</th>
                    <th>Cirurgião</th>
                    <th width="1%"></th>
                    <th width="1%"></th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
            <%
            sqlCirurgia = "SELECT COALESCE(tl.Lote,'Sem Lote') AS loteID, s.NomeStatus, ac.IDFaturamento AS Lote, ac.StatusID, ac.rdValorPlano, ac.IDFaturamento, ac.Tabela, ac.id, ac.DataEmissao, ac.Hora, pac.NomePaciente, c.NomeConvenio, ac.ContratadoLocalNome, if(ac.rdValorPlano='V', 'Particular', c.NomeConvenio) NomeConvenio, ac.PacienteID, pac.Cel1 "&_
                                      " ,(SELECT NomeProfissional FROM profissionaiscirurgia pc INNER JOIN profissionais prof ON prof.id=pc.ProfissionalID WHERE pc.GuiaID=ac.id AND pc.GrauParticipacaoID=100 LIMIT 1) Cirurgiao "&_
                                      "FROM agendacirurgica ac LeFT JOIN agendacirurgicastatus s ON s.id=ac.StatusID "&_
                                      "LEFT JOIN tissguiahonorarios tgh ON ac.IDFaturamento = tgh.id "&_
                                      "LEFT JOIN tissguiasadt tgs ON ac.IDFaturamento = tgs.id "&_
                                      "LEFT JOIN pacientes pac ON pac.id=ac.PacienteID "&_
                                      "LEFT JOIN convenios c ON c.id=ac.ConvenioID "&_
                                      "LEFT JOIN tisslotes tl ON tl.id=if(ac.Tabela='tissguiahonorarios',tgh.LoteID,if(ac.Tabela='tissguiasadt',tgs.LoteID,0)) "&_
                                      "WHERE ac.sysActive=1 "&sqlProfissionais&" "&sqlData&" "&sqlUnidades&" "&StatusAgenda&" ORDER BY ac.DataEmissao desc, Hora desc"
            set ac = db.execute(sqlCirurgia)
            while not ac.eof
                %>
                <tr>
                    <td><%= ac("NomeStatus") %></td>
                    <td><%= ac("LoteID")&"" %></td>
                    <td><%= ac("DataEmissao") %></td>
                    <td><%= replace(ft(ac("Hora")), "00:00", "") %></td>
                    <td><a href="?P=Pacientes&Pers=1&I=<%=ac("PacienteID")%>" target="_blank"><%= ac("NomePaciente") %></a></td>
                    <td><%= ac("Cel1") %></td>
                    <td><%= ac("ContratadoLocalNome") %></td>
                    <td><%= ac("NomeConvenio") %></td>
                    <td><%= ac("Cirurgiao") %></td>
                    <td width="1%" nowrap>
                        <a class="btn btn-xs btn-primary" href="./?P=AgendaCirurgica&I=<%= ac("id") %>&Pers=1"><i class="far fa-edit"></i></a>
                    </td>
                    <td width="1%">
                        <%
                            if ac("rdValorPlano")="V" then 
                                if not isnull(ac("IDFaturamento")) then
                                %>
                                <a href="./?P=invoice&Pers=1&I=<%= ac("IDfaturamento") %>" target="_blank" class="btn btn-xs btn-success btn-block"><i class="far fa-money"></i></a>
                                <% else %>
                                <a class="btn btn-xs btn-system btn-block" href="javascript:void(0)" onclick="if(confirm('Confirma o faturamento particular desta cirurgia?'))location.href='./?P=lAgendaCirurgica&Faturar=<%= ac("id") %>&Tipo=Invoice&Pers=1';"><i class="far fa-money"></i></a>
                                <% end if
                            else
                                if isnull(ac("IDFaturamento")) then
                                %>
                                <div class="btn-group">
                                    <button class="btn btn-xs btn-system dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="far fa-credit-card"></i>  <i class="far fa-angle-down icon-on-right"></i></button>
                                    <ul class="dropdown-menu dropdown-danger pull-right">
                                        <li><a href="javascript:void(0)" onclick="if(confirm('Confirma o faturamento desta cirurgia em Guia de Honorários?'))location.href='./?P=lAgendaCirurgica&Faturar=<%= ac("id") %>&Tipo=Honorarios&Pers=1';">Guia de Honorários</a></li>
                                        <li><a href="javascript:void(0)" onclick="if(confirm('Confirma o faturamento desta cirurgia em Guia de SP/SADT?'))location.href='./?P=lAgendaCirurgica&Faturar=<%= ac("id") %>&Tipo=SADT&Pers=1';">Guia de SP/SADT</a></li>
                                    </ul>
                                </div>
                                <%
                                else
                                    %>
                                    <a href="./?P=<%= ac("Tabela") %>&Pers=1&I=<%= ac("IDFaturamento") %>" class="btn btn-xs btn-success btn-block"><i class="far fa-credit-card"></i></a>
                                    <%
                                end if
                            end if
                        %>
                    </td>
                    <td width="1%">
                        <a class="btn btn-xs btn-danger" href="javascript:void()" onclick="if(confirm('Tem certeza de que deseja excluir esta cirurgia?'))location.href='./?P=lAgendaCirurgica&X=<%= ac("id") %>&Pers=1'"><i class="far fa-remove"></i></a>
                    </td>
                </tr>
                <%
            ac.movenext
            wend
            ac.close
            set ac=nothing
            %>                
            </tbody>
        </table>
