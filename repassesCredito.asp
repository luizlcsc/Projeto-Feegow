<!--#include file="connect.asp"-->
<%
I = ccur(req("I"))
MovementID = I

set mov = db.execute("select * from sys_financialmovement where id="& MovementID)
%>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Repasses Lançados como Crédito</span>
    </div>
    <div class="panel-body">
        <h5>Dados do Crédito</h5>

        <table class="table table-condensed table-bordered">
            <thead>
                <tr>
                    <th>Data</th>
                    <th>Creditado</th>
                    <th>Lançado por</th>
                    <th>Valor</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><%= mov("Date") %></td>
                    <td><%= accountName(mov("accountAssociationIDDebit"), mov("accountIDDebit")) %></td>
                    <td><%= nameIntable(mov("sysUser")) %></td>
                    <td class="text-right"><%= fn(mov("Value")) %></td>
                </tr>
            </tbody>
        </table>

        <h5>Atendimentos Agrupados</h5>

        <table class="table table-condensed table-bordered">
            <thead>
                <tr>
                    <th>Data Exec.</th>
                    <th>Paciente</th>
                    <th>Descrição</th>
                    <th>Função</th>
                    <th>Forma</th>
                    <th>Valor Serv.</th>
                    <th>Repasse</th>
                </tr>
            </thead>
            <tbody>
            <%
                set rr = db.execute("select rr.* from rateiorateios rr where rr.CreditoID="& I)
                while not rr.eof
                    if not isnull(rr("ItemInvoiceID")) then
                        DataExecucao = ""
                        Descricao = ""
                        Pagador = ""
                        FormaRecto = ""
                        Valor = 0
                        ValorRepasse = 0
                        set ii = db.execute("select 'Particular' FormaRecto, ii.DataExecucao, proc.NomeProcedimento, pac.NomePaciente, (ii.Quantidade * (ii.ValorUnitario + ii.Acrescimo - ii.Desconto)) ValorProcedimento from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN pacientes pac ON pac.id=i.AccountID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.id="& rr("ItemInvoiceID"))
                    elseif not isnull(rr("ItemGuiaID")) then
                        set ii = db.execute("select gps.Data DataExecucao, proc.NomeProcedimento, pac.NomePaciente, gps.ValorTotal ValorProcedimento, conv.NomeConvenio FormaRecto FROM tissprocedimentossadt gps LEFT JOIN tissguiasadt gs ON gs.id=gps.GuiaID LEFT JOIN pacientes pac ON pac.id=gs.PacienteID LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID LEFT JOIN convenios conv ON conv.id=gs.ConvenioID WHERE gps.id="& rr("ItemGuiaID"))
                    elseif not isnull(rr("GuiaConsultaID")) then
                        set ii = db.execute("select gc.DataAtendimento DataExecucao, proc.NomeProcedimento, pac.NomePaciente, gc.ValorProcedimento, conv.NomeConvenio FormaRecto FROM tissguiaconsulta gc LEFT JOIN pacientes pac ON pac.id=gc.PacienteID LEFT JOIN procedimentos proc ON proc.id=gc.ProcedimentoID LEFT JOIN convenios conv ON conv.id=gc.ConvenioID WHERE gc.id="& rr("GuiaConsultaID"))
                    elseif not isnull(rr("ItemHonorarioID")) then
                        set ii = db.execute("select gps.Data DataExecucao, proc.NomeProcedimento, pac.NomePaciente, gps.ValorTotal ValorProcedimento, conv.NomeConvenio FormaRecto FROM tissprocedimentoshonorarios gps LEFT JOIN tissguiahonorarios gs ON gs.id=gps.GuiaID LEFT JOIN pacientes pac ON pac.id=gs.PacienteID LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID LEFT JOIN convenios conv ON conv.id=gs.ConvenioID WHERE gps.id="& rr("ItemGuiaID"))
                    end if

                    if not ii.eof then
                        DataExecucao = ii("DataExecucao")
                        Descricao = ii("NomeProcedimento")
                        Pagador = ii("NomePaciente")
                        FormaRecto = ii("FormaRecto")
                        Valor = ii("ValorProcedimento")
                        ValorRepasse = fn(calculaRepasse(rr("id"), rr("Sobre"), ii("ValorProcedimento"), rr("Valor"), rr("TipoValor")))
                    end if
                    ContaRepasses = ContaRepasses+1
                    %>
                    <tr>
                        <td><%= DataExecucao %></td>
                        <td><%= Pagador %></td>
                        <td><%= Descricao %></td>
                        <td><%= rr("Funcao") %></td>
                        <td><%= FormaRecto %></td>
                        <td class="text-right"><%= fn(Valor) %></td>
                        <td class="text-right"><%= ValorRepasse %></td>
                        <td>
                            <% if isnull(rr("ItemContaAPagar")) then %>
                                <button onclick="x(<%= rr("id") %>)" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button>
                            <% end if %>
                        </td>
                    </tr>
                    <%
                rr.movenext
                wend
                rr.close
                set rr = nothing
            %>
            </tbody>
        </table>

    </div>
</div>
