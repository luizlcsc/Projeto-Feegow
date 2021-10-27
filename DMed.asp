<!--#include file="connect.asp"-->
<%
De = ref("De")
Ate = ref("Ate")
Profissionais = ref("Profissionais")
ApenasImpresso = ref("ApenasImpresso")
ConsiderarValorTotal = ref("ConsiderarValorTotal")

if ApenasImpresso="S" then
    sqlAI = " AND NOT ISNULL(rec.ImpressoEm) "
end if

response.Buffer
%>

<form method="post" action="">
    <div class="panel mt20">
        <div class="panel-body">
            <h1>DMED</h1>
            <hr class="short alt" />
            <div class="row">
                <%= quickfield("datepicker", "De", "De", 2, De, "", "", " required ") %>
                <%= quickfield("datepicker", "Ate", "Até", 2, Ate, "", "", " required ") %>
                <%= quickfield("multiple", "Profissionais", "Profissionais", 3, Profissionais, "select id, NomeProfissional from profissionais where sysActive=1 and Ativo='on' Order by NomeProfissional", "NomeProfissional", " required ") %>
                <div class="col-md-2 pt25">
                    <input type="checkbox" name="ApenasImpresso" value="S" <% if ApenasImpresso="S" then response.write(" checked ") end if %> />
                    Somente impressos
                </div>
                <div class="col-md-1 pt25">
                    <button class="btn btn-primary btn-block">Buscar</button>
                </div>
                <div class="col-md-2 pt25">
                        <button type="button" class="btn btn-success" title="Gerar Excel" onclick="downloadExcel()"><i class="far fa-table"></i></button>
                        <button type="button" class="btn btn-warning" title="Gerar Zip " onclick="downloadPDF()"><i class="far fa-archive"></i></button>
                </div>
                
            </div>
        </div>
    </div>
</form>

<%
if Profissionais<>"" then
    %>
    <div class="panel">
        <div class="panel-body" id="content-relatorio">
            <%
            set prof = db.execute("select id, NomeProfissional from profissionais where id IN ("& replace(Profissionais, "|", "") &") order by NomeProfissional")
            while not prof.eof
                response.Flush()

                sqlRecibos = "select ii.DataExecucao, ii.InvoiceID, p.id PacienteID,p.NomePaciente, p.CPF, sum(ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorTotal from rateiorateios rr "&_
                                             " left join itensinvoice ii ON ii.id=rr.ItemInvoiceID "&_
                                             " left join sys_financialinvoices i on i.id=ii.InvoiceID "&_
                                             " left join pacientes p on p.id=i.AccountID "&_
                                             " where ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND rr.ContaCredito=concat('5_', "& prof("id") &") AND ii.Executado='S' "&_
                                             " GROUP BY ii.InvoiceID ORDER BY ii.DataExecucao  "

                set ii = db.execute(sqlRecibos)
                if not ii.eof then
                %>

                <div class="div-dmed-profissional" data-id="<%= prof("id") %>">
                <div data-id="<%= prof("id") %>" class="nomeGrupo group1-report">
                <h1><%= prof("NomeProfissional") %></h1>
                </div>
                
                <div data-id="<%= prof("id") %>" data-filename="<%= prof("NomeProfissional") %>" class="group1-report" >
                <table _excel-name="<%= left(prof("NomeProfissional"), 30) %>" class="table table-bordered table-condensed table-hover">
                    <thead>
                        <tr>
                            <th>Data</th>
                            <th>Recibo gerado</th>
                            <th>Impresso em</th>
                            <th>Paciente</th>
                            <th>CPF Paciente</th>
                            <th>Responsável</th>
                            <th>CPF/CNPJ Resp.</th>
                            <th>Total</th>
                            <th>Repasse</th>
                            <th>Recibo</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        c = 0
                        tValorTotal = 0
                        tTotalRepasse = 0
                        while not ii.eof
                            sqlContaCredito = "rec.ContaCredito=concat('5_', "& prof("id") &") AND "

                            if cdate(Ate)<=cdate("2019-07-31") then
                                sqlContaCredito = ""
                            end if

                            set rec = db.execute("select (Valor) TotalRecibo, ImpressoEm FROM recibos rec WHERE "&sqlContaCredito&" rec.InvoiceID="& ii("InvoiceID") & sqlAI &" ORDER BY rec.id desc limit 1")
                            'SÓ EXIBE QUEM TEM RECIBO
                            ReciboGerado=False
                            ImpressoEm=""
                            TotalRecibo=0

                            if not rec.eof then
                                TotalRecibo=rec("TotalRecibo")
                                ImpressoEm=rec("ImpressoEm")
                                ReciboGerado=true
                            end if

                            if (ApenasImpresso="S" and ReciboGerado) or ApenasImpresso<>"S" then

                                PacienteID = ii("PacienteID")
                                set rr = db.execute("select rr.Valor, sum(rr.Valor) TotalRepasse from rateiorateios rr "&_ 
                                " left join itensinvoice ii ON ii.id=rr.ItemInvoiceID "&_
                                " WHERE rr.ContaCredito=concat('5_', "& prof("id") &") AND ii.InvoiceID="& ii("invoiceID") &" AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" GROUP BY ii.InvoiceID")
                                tValorTotal = tValorTotal+ii("ValorTotal")
                                tTotalRepasse = tTotalRepasse+rr("TotalRepasse")
                                c = c+1
                                if fn(TotalRecibo)<>fn(rr("TotalRepasse")) then
                                    'classe = "danger"
                                else
                                    classe = ""
                                end if
                                ResponsavelFinanceiro=""
                                CPFRespFin=""

                                set ResponsavelSQL = db.execute("SELECT Nome, CPFParente FROM pacientesrelativos WHERE sysActive=1 AND Dependente='S' AND PacienteID="&PacienteID)
                                if not ResponsavelSQL.eof then
                                    ResponsavelFinanceiro=ResponsavelSQL("Nome")
                                    CPFRespFin=ResponsavelSQL("CPFParente")
                                end if

                                %>
                                <tr class="<%= classe %>">
                                    <td><a href="./?P=Invoice&Pers=1&CD=C&I=<%= ii("InvoiceID") %>" target="_blank"><%= ii("DataExecucao") %></a></td>
                                    <td><% if ReciboGerado then %>Sim<% else %>Não<% end if %></td>
                                    <td><%= ImpressoEm %></td>
                                    <td><%= ii("NomePaciente") %></td>
                                    <td><%= ii("CPF") %></td>
                                    <td><%= ResponsavelFinanceiro %></td>
                                    <td><%= CPFRespFin %></td>
                                    <td class="text-right"><%= fn(ii("ValorTotal")) %></td>
                                    <td class="text-right"><%= fn(rr("TotalRepasse"))  %></td>
                                    <td class="text-right"><%= fn(rr("TotalRepasse"))  %></td>
                                </tr>
                                <%
                            end if

                        ii.movenext
                        wend
                        ii.close
                        set ii = nothing
                            if c=0 then
                                %>
                                <script >
                                    $(".div-dmed-profissional[data-id=<%=prof("id")%>]").remove();
                                </script>
                                <%
                            end if
                            %>
                    </tbody>
                    <tfoot>
                        <td colspan="5"><%= c %></td>
                        <td class="text-right"><%= fn(tValorTotal) %></td>
                        <td class="text-right"><%= fn(tTotalRepasse) %></td>
                        <td class="text-right"><%= fn(tTotalRepasse) %></td>
                    </tfoot>
                </table>
                </div>
                </div>
                <%
                end if
            prof.movenext
            wend
            prof.close
            set prof = nothing
                %>
        </div>
    </div>
    <%
end if
%>

<form id="formExcel" method="POST">
            <input type="hidden" name="html" id="htmlTable">
        </form>

<script>

function downloadExcel(){
    $("#htmlTable").val($("#content-relatorio").html());
    $("#formExcel").attr("action", domain+"reports/download-excel?title=Dmed&tk=" + localStorage.getItem("tk")).submit();
}

function downloadPDF(){
    $("#htmlTable").val($("#content-relatorio").html());
    $("#formExcel").attr("action", domain+"reports/download-excel?zip=zip&title=Dmed&tk=" + localStorage.getItem("tk")).submit();
}
</script>