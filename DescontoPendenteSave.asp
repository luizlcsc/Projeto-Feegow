<!--#include file="connect.asp"-->
<%
ID = req("I")
OP = req("OP")

resultado = ""
if ID <> "" and OP <> "" then
    set rsDescontoPendenteUpdate = db.execute("select * from descontos_pendentes WHERE id = "&ID& " and Status = 0")
    if not rsDescontoPendenteUpdate.eof then 
        
        SysUser = Session("user")
        'Salvar na tabela sys_dinancialinvoice
        sqlUpdateDescontoPendente = "update descontos_pendentes set Status = " & OP & ", SysUserAutorizado = " & SysUser &_
            ", DataHoraAutorizado = now() WHERE id = " & ID

        db.execute(sqlUpdateDescontoPendente)
        Desconto = treatVal(rsDescontoPendenteUpdate("Desconto"))
        if OP = 1 then
            if rsDescontoPendenteUpdate("ItensInvoiceID") > 0 then 
                'Atualizar a tabela invoices retirando o valor do desconto

                'Atualizar a tabela de itens invoice com o valor do desconto
                sqlUpdateItemInvoice = "update itensinvoice set Desconto = " & Desconto & " WHERE id = " & rsDescontoPendenteUpdate("ItensInvoiceID")
                db.execute(sqlUpdateItemInvoice)

                set rsInvoice = db.execute("select InvoiceID, Value, ItemID, DataExecucao, ProfissionalID, HoraExecucao from itensinvoice ii inner join sys_financialinvoices sfi on sfi.id = ii.InvoiceID WHERE ii.id = "&rsDescontoPendenteUpdate("ItensInvoiceID"))
                if not rsInvoice.eof then
                    
                    totalParcelas = 1
                    set countP = db.execute("select count(*) total from sys_financialmovement WHERE InvoiceID = "&rsInvoice("InvoiceID")&"  ")
                    totalParcelas = countP("total")

                    set rsMovement = db.execute("select id, Value from sys_financialmovement WHERE InvoiceID = "&rsInvoice("InvoiceID")&"  ")
                    
                    totalDescontoParcelado = ccur(rsDescontoPendenteUpdate("Desconto")) / ccur(totalParcelas)

                    while not rsMovement.eof 'and totalDesconto > 0 
                        'if totalDesconto > rsMovement("Value") then
                        '    total = treatVal(0)
                        '    totalDesconto = totalDesconto - rsMovement("Value")
                        'else
                        '    total = treatVal(rsMovement("Value") - totalDesconto)
                        '    totalDesconto = 0
                        'end if
                        
                        total = treatVal(rsMovement("Value") - totalDescontoParcelado)
                        sqlUpdateMovement = "update sys_financialmovement set Value = " & total & " WHERE id = " & rsMovement("id")
                        db.execute(sqlUpdateMovement)
                        rsMovement.movenext
                    wend

                    'Atualizar o sys_financialinvoices
                    totalInvoice = treatVal(rsInvoice("Value") - rsDescontoPendenteUpdate("Desconto"))

                    sqlUpdateInvoice = "update sys_financialinvoices set Value = " & totalInvoice & " WHERE id = " & rsInvoice("InvoiceID")
                    db.execute(sqlUpdateInvoice)

                    Hora = rsInvoice("HoraExecucao")

                    if rsInvoice("HoraExecucao")&"" <> "" then
                        Hora = formatdatetime(Hora,4)
                    end if

                    'atualizar nas tabelas de agendamento e agendamentoprocedimento o valor
                    'procurar no agendamento por 
                    sqlAgendamento = "select * from agendamentos where ProfissionalID = " & rsInvoice("ProfissionalID") & " AND Data = " & mydatenull(rsInvoice("DataExecucao")) & " AND ValorPlano = " & treatValZero(rsInvoice("Value")) & " " &_
                        " AND TipoCompromissoID = " & rsInvoice("ItemID") & " AND Hora = '" & Hora & "' "
                        
                    set rsAgendamento = db.execute(sqlAgendamento)
                    if not rsAgendamento.eof then
                        sqlUpdateAgendamento = "update agendamentos set ValorPlano = " & totalInvoice & " WHERE id = " & rsAgendamento("id")
                        db.execute(sqlUpdateAgendamento)
                    end if

                    sqlAgendamentoProcedimento = "select *, ap.id as idagendaprocesso from agendamentos a inner join agendamentosprocedimentos ap ON ap.AgendamentoID = a.id where ProfissionalID = " & rsInvoice("ProfissionalID") & " AND Data = " & mydatenull(rsInvoice("DataExecucao")) &  " AND ap.ValorPlano = " & treatValZero(rsInvoice("Value")) & " " &_
                        " AND ap.TipoCompromissoID = " & rsInvoice("ItemID") & " AND Hora = '" & Hora & "'"
                    
                    set rsAgendamentoProcedimento = db.execute(sqlAgendamentoProcedimento)
                    if not rsAgendamentoProcedimento.eof then
                        sqlUpdateAgendamentoProcedimento = "update agendamentosprocedimentos set ValorPlano = " & totalInvoice & " WHERE id = " & rsAgendamentoProcedimento("idagendaprocesso")
                        db.execute(sqlUpdateAgendamentoProcedimento)
                    end if

                end if

            else
                'Se o ID for negativo vamos atualizar a tabela de propostas
                sqlBuscarUltimoItem = "select i.id as iditem, TipoDesconto, ValorUnitario, Valor, p.id as idproposta from itensproposta i inner join propostas p on p.id = i.PropostaID where CONCAT('-', i.id) = " & rsDescontoPendenteUpdate("ItensInvoiceID") 
                set sqlBuscarUltimoItemProposta = db.execute(sqlBuscarUltimoItem)
                if not sqlBuscarUltimoItemProposta.eof then
                    TipoDesconto = sqlBuscarUltimoItemProposta("TipoDesconto")
                    ValorDoDesconto = rsDescontoPendenteUpdate("Desconto")
                    if TipoDesconto = "P" then
                        ValorDoDesconto = (rsDescontoPendenteUpdate("Desconto") * 100) / sqlBuscarUltimoItemProposta("ValorUnitario")
                    end if
                    sqlPropostaUpdate = "update itensproposta set Desconto = " & treatValZero(ValorDoDesconto) & " WHERE id = " & sqlBuscarUltimoItemProposta("iditem")
                    db.execute(sqlPropostaUpdate)

                    NovoValor = sqlBuscarUltimoItemProposta("Valor") - ValorDoDesconto
                    sqlPropostaUpdate2 = "update propostas set Valor = " & treatValZero(NovoValor) & " WHERE id = " & sqlBuscarUltimoItemProposta("idproposta")
                    db.execute(sqlPropostaUpdate2)
                end if

            end if
        end if

    db.execute("delete from exibicao_conteudo WHERE SysUser = "&session("User")&" AND conteudo = 'desconto_pendente' AND  Data = curdate()")
%>
<script>
        $(function(){
        showMessageDialog("Desconto autorizado com sucesso", "success")
        });
        </script>
<%
    rsDescontoPendenteUpdate.movenext
    else
    %>
        <script>
        $(function(){
        showMessageDialog("Desconto já autorizado", "danger")
        });
        </script>
    <%
    end if
    rsDescontoPendenteUpdate.close
end if
%>