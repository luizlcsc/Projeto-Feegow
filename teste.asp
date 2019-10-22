<!--#include file="connect.asp"-->

<script type="text/javascript">
    function ok(ItemInvoiceID, TabelaCorretaID) {
        $.get("Corrige.asp?ItemInvoiceID=" + ItemInvoiceID + "&TabelaCorretaID=" + TabelaCorretaID, function (data) { eval(data) });
    }
</script>

<div class="panel">
    <div class="panel-body">
        <table class="table table-condensed table-hover table-bordered">
            <thead>
                <tr>
                    <th>Invoice</th>
                    <th>Data</th>
                    <th>Paciente</th>
                    <th>Profissional</th>
                    <th>Especialidade</th>
                    <th>Procedimento</th>
                    <th>Unidade</th>
                    <th>Valor</th>
                    <th>Calc</th>
                    <th>Tb Inv</th>
                    <th>Tb Age</th>
                    <th>Tb Pac</th>
                </tr>
            </thead>
            <tbody>
                <%
                Inicio = "20/05/2019"

                certos = 0
                errados = 0

                set inv = db.execute("select ii.id ItemInvoiceID, i.id, i.sysDate, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, i.CompanyUnitID, (ii.Quantidade * ii.ValorUnitario) Valor, ii.Quantidade, i.TabelaID, pac.NomePaciente, pac.Tabela, i.TabelaID, t.NomeTabela, prof.NomeProfissional, esp.Especialidade, ii.ItemID ProcedimentoID, ii.ProfissionalID, ii.EspecialidadeID, proc.GrupoID FROM sys_financialinvoices i LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID LEFT JOIN tabelaparticular t ON t.id=i.TabelaID LEFT JOIN profissionais prof ON prof.id=ii.ProfissionalID LEFT JOIN especialidades esp ON esp.id=ii.EspecialidadeID WHERE i.sysDate>"& mydatenull(Inicio) &" AND ii.Tipo='S' AND i.CD='C' AND i.AssociationAccountID=3 AND ii.Executado='S' AND i.Corrigido=0 LIMIT 4000")
                while not inv.eof
                    tbInv = inv("TabelaID")&""
                    tbAge = ""
                    tbPac = inv("Tabela")&""
                    set age = db.execute("select a.TabelaParticularID from agendamentos a WHERE a.Data="& mydatenull(inv("sysDate")) &" AND a.TipoCompromissoID="& inv("ProcedimentoID") &" AND a.PacienteID="& inv("AccountID") &" AND a.ProfissionalID="& inv("ProfissionalID"))
                    while not age.eof
                        if tbAge<>"" then
                            tbAge = tbAge &"<br>"
                        end if
                        tbAge = tbAge & age("TabelaParticularID") 
                    age.movenext
                    wend
                    age.close
                    set age = nothing

                    if tbInv=tbPac and (tbInv=tbAge or tbAge="") then
                        classe = ""
                        certos = certos + 1
                    else
                        classe = "danger"
                        errados = errados + 1
                    end if

                    if classe="danger" then
                    %>
                    <tr class="<%= classe %>">
                        <td><a href="./?P=Invoice&Pers=1&T=C&I=<%= inv("id") %>" target="_blank"><%= inv("id") %></a></td>
                        <td><%= inv("sysDate") %></td>
                        <td><a href="./?P=Paciente&Pers=1&I=<%= inv("AccountID") %>" target="_blank"><%= inv("NomePaciente") %></a></td>
                        <td><%= inv("NomeProfissional") %></td>
                        <td><%= inv("Especialidade") %></td>
                        <td><%= inv("NomeProcedimento") %></td>
                        <td><%= inv("CompanyUnitID") %></td>
                        <td class="text-right"><%= fn(inv("Valor")) %></td>
                        <td nowrap><%
                            'set tabs = db.execute("select group_concat(pt.TabelasParticulares) TabelasParticulares FROM procedimentostabelasvalores ptv LEFT JOIN procedimentostabelas pt ON pt.id=ptv.TabelaID WHERE pt.Tipo='V' AND ptv.Valor="& treatvalzero(inv("Valor")) &" AND ptv.ProcedimentoID="& inv("ProcedimentoID") &" ")
                            'while not tabs.eof
                             
                            '    response.write ( tabs("TabelasParticulares") &"<br />")
                                
                            'tabs.movenext
                            'wend
                            'tabs.close
                            'set tabs = nothing

                            %>



                            <input type="hidden" class="input<%= inv("ItemInvoiceID") %>" name="Quantidade<%= inv("ItemInvoiceID") %>" value="<%= inv("Quantidade") %>" />
                            <input type="hidden" class="input<%= inv("ItemInvoiceID") %>" name="ItemID<%= inv("ItemInvoiceID") %>" value="<%= inv("ProcedimentoID") %>" />
                            <input type="hidden" class="input<%= inv("ItemInvoiceID") %>" name="ProfissionalID<%= inv("ItemInvoiceID") %>" value="<%= "5_"& inv("ProfissionalID") %>" />
                            <input type="hidden" class="input<%= inv("ItemInvoiceID") %>" name="EspecialidadeID<%= inv("ItemInvoiceID") %>" value="<%= inv("EspecialidadeID") %>" />
                            <input type="hidden" class="input<%= inv("ItemInvoiceID") %>" name="Tipo<%= inv("ItemInvoiceID") %>" value="S" />
                            <input type="hidden" class="input<%= inv("ItemInvoiceID") %>" name="Executado<%= inv("ItemInvoiceID") %>" value="S" />

                            <div id="sub<%= inv("ItemInvoiceID") %>">
                            </div>
                        </td>
                        <td nowrap>
                            <%= inv("TabelaID") %>
                            <br />
                            <button type="button" onclick="par(<%= inv("ItemInvoiceID") %>, <%= inv("CompanyUnitID") %>, '<%= inv("sysDate") %>', <%= tbInv %>, <%= inv("ProcedimentoID") %>)" class="btn btn-xs btn-default">Calcular Inv</button>
                            <button type="button" class="btn btn-xs btn-success" onclick="ok(<%= inv("ItemInvoiceID") %>, <%= tbInv %>)">Inv</button>
                        </td>
                        <td nowrap>
                            
                            <%= tbAge %>
                            <br />
                            <%
                            if tbAge<>"" and isnumeric(tbAge) and tbAge<>"0" then %>
                                <button type="button" onclick="par(<%= inv("ItemInvoiceID") %>, <%= inv("CompanyUnitID") %>, '<%= inv("sysDate") %>', <%= tbAge %>, <%= inv("ProcedimentoID") %>)" class="btn btn-xs btn-default">Calcular Age</button>
                                <button type="button" class="btn btn-xs btn-success" onclick="ok(<%= inv("ItemInvoiceID") %>, <%= tbAge %>)">Age</button>
                                <br />
                            <% end if %>


                        </td>
                        <td nowrap>
                            <%= tbPac %>
                            <br />
                            <%
                            set tbPacAt = db.execute("select id from tabelaparticular where Ativo='on' and sysActive=1 and id="& tbPac)
                            if not tbPacAt.eof then
                                %>
                            
                                <button type="button" onclick="par(<%= inv("ItemInvoiceID") %>, <%= inv("CompanyUnitID") %>, '<%= inv("sysDate") %>', <%= tbPac %>, <%= inv("ProcedimentoID") %>)" class="btn btn-xs btn-default">Calcular Pac</button>
                                <button type="button" class="btn btn-xs btn-success" onclick="ok(<%= inv("ItemInvoiceID") %>, <%= tbPac %>)">Pac</button>
                                <br />

                            <%
                            end if
                            %>
                        </td>
                    </tr>

                <script type="text/javascript">
                    function par(divID, CompanyUnitID, sysDate, invTabelaID, ProcedimentoID, Executado, ProfissionalID, EspecialidadeID, DataExecucao) {
                        $("#sub" + divID).html("");
                        $.post("invoiceParametros.asp?ElementoID="+ divID +"&id="+ ProcedimentoID, 
                                $(".input"+divID).serialize() +"&CompanyUnitID="+ CompanyUnitID +"&Data="+ sysDate +"&sysDate="+ sysDate +"&invTabelaID="+ invTabelaID,
                                function(data){ eval(data) }
                        );
                    }
                </script>

                    <%
                    end if
                inv.movenext
                wend
                inv.close
                set inv=nothing
                    %>
            </tbody>

            Certos = <%= Certos %>
            <br />
            Errados = <%= Errados %>
        </table>
    </div>
</div>
<%

%>