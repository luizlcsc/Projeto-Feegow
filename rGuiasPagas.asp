<!--#include file="connect.asp"-->
<style type="text/css">
    th, td {
        font-size:8pt;
    }
</style>
<%
DataDe = req("DataDe")
DataAte = req("DataAte")

Profissionais = req("ProfissionalID")
Convenios = req("ConvenioID")
%>

<h1 class="text-center">Guias Pagas</h1>
<h3 class="text-center"><%= DataDe %> a <%= DataAte %></h3>

<%
response.Buffer
splProf = split(Profissionais, ", ")
SubProcedimentosPP = 0
SubGuiaPP = 0
SubPagoPP = 0
cPP = 0
for i=0 to ubound(splProf)
    SubProcedimentosP = 0
    SubPagoP = 0
    SubGuiaP = 0
    cP = 0
    ProfissionalID = splProf(i)
    set nprof = db.execute("select * from profissionais where id="& ProfissionalID)
    %>
    <h2><%= nprof("NomeProfissional") %></h2>
    <table class="table table-condensed table-bordered table-hover">
    <%
    splConv = split(Convenios, ", ")
    for ic=0 to ubound(splConv)
        lClasse = ProfissionalID &"_"& ConvenioID
        ConvenioID = splConv(ic)
        set nconv = db.execute("select * from convenios where id="& ConvenioID)

        sql = "select m.Date DataPagto, parc.InvoiceID, g.GuiaID, g.TipoGuia, nroNFe from sys_financialmovement m LEFT JOIN sys_financialdiscountpayments p ON p.MovementID=m.id LEFT JOIN sys_financialmovement parc ON parc.id=p.InstallmentID LEFT JOIN tissguiasinvoice g ON g.InvoiceID=parc.InvoiceID LEFT JOIN sys_financialinvoices i ON i.id=g.InvoiceID WHERE m.AccountAssociationIDCredit=6 and m.AccountIDCredit="& ConvenioID &" and m.CD='D' and m.Type='Pay' and m.`Date` BETWEEN "& mydatenull(DataDe) &" AND "& mydatenull(DataAte)

        'response.write( sql )
        set guias = db.execute(sql)
        %>
            <tr class="<%= lClasse %>">
                <th colspan="10">
                    <h4 class="m5"><%= nconv("NomeConvenio") %></h4>
                </th>
            </tr>
            <tr class="<%= lClasse %>">
                <th width="10%" nowrap>N&deg; da Guia</th>
                <th width="10%" nowrap>Tipo de Guia</th>
                <th width="10%" nowrap>Pagamento</th>
                <th width="10%" nowrap>Execução</th>
                <th width="20%" nowrap>Paciente</th>
                <th width="20%" nowrap>Procedimento</th>
                <th width="10%" nowrap>Valor</th>
                <th width="10%" nowrap>Valor Guia</th>
                <th width="10%" nowrap>Valor Pago</th>
                <th width="10%" nowrap>NF-e</th>
            </tr>
            <%
            c = 0
            SubProcedimentos = 0
            SubGuia = 0
            SubPago = 0

            if req("ProcedimentoID")<>"" then
                Procedimentos = replace(req("ProcedimentoID"), "|", "")
                sqlProcedimentoConsulta = " AND gc.ProcedimentoID IN("& Procedimentos &") "
                sqlProcedimentoSADT = " AND gps.ProcedimentoID IN("& Procedimentos &") "
            end if
            while not guias.eof
                response.flush()
                nroNFe=guias("nroNFe")
                if guias("GuiaID")<>"" and not isnull(guias("GuiaID")) then
                    if guias("TipoGuia")="guiaconsulta" then
                        set g = db.execute("select gc.NGuiaPrestador, gc.DataAtendimento Data, gc.ValorProcedimento TotalProcedimentos, gc.ValorProcedimento TotalGuia, ifnull(gc.ValorPago, 0) ValorPago, p.NomePaciente, proc.NomeProcedimento from tissguiaconsulta gc LEFT JOIN pacientes p ON p.id=gc.PacienteID LEFT JOIN procedimentos proc ON proc.id=gc.ProcedimentoID where gc.id="& guias("GuiaID")&" and gc.ProfissionalID="& ProfissionalID & sqlProcedimentoConsulta&" ORDER BY gc.DataAtendimento ")
                        TipoGuia = "Consulta"
                    elseif guias("TipoGuia")="guiasadt" then
                        set g = db.execute("select gs.NGuiaPrestador, gps.Data, gps.ValorTotal TotalProcedimentos, gs.TotalGeral TotalGuia, ifnull(gs.ValorPago, 0) ValorPago, p.NomePaciente, proc.NomeProcedimento from tissguiasadt gs LEFT JOIN tissprocedimentossadt gps ON gps.GuiaID=gs.id LEFT JOIN pacientes p ON p.id=gs.PacienteID LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID where gps.ProfissionalID="&ProfissionalID&" AND gs.id="& guias("GuiaID") & sqlProcedimentoSADT &" GROUP BY GuiaID ORDER BY gps.Data")
                        TipoGuia = "SP/SADT"
                    else
                        set g = db.execute("select gs.NGuiaPrestador, gps.Data, gps.ValorTotal TotalProcedimentos, gs.TotalGeral TotalGuia, ifnull(gs.ValorPago, 0) ValorPago, p.NomePaciente, proc.NomeProcedimento from tissguiasadt gs LEFT JOIN tissprocedimentoshonorarios gps ON gps.GuiaID=gs.id LEFT JOIN pacientes p ON p.id=gs.PacienteID LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID where gps.ProfissionalID="&ProfissionalID&" AND gs.id="& guias("GuiaID") & sqlProcedimentoSADT &" GROUP BY GuiaID ORDER BY gps.Data")
                        TipoGuia = "SP/SADT"
                    end if

                    if not g.eof then
                        c = c+1
                        SubProcedimentos = SubProcedimentos + g("TotalProcedimentos")
                        SubGuia = SubGuia + g("TotalGuia")
                        SubPago = SubPago + g("ValorPago")
                        %>
                        <tr class="<%= lClasse %>">
                            <td class="text-right"><%= zeroEsq(g("NGuiaPrestador"), 8) %></td>
                            <td><%= TipoGuia %></td>
                            <td class="text-right"><%= guias("DataPagto") %></td>
                            <td class="text-right"><%= g("Data") %></td>
                            <td><%= g("NomePaciente") %></td>
                            <td>
                                <%
                                if guias("TipoGuia")="guiaconsulta" then
                                    response.write g("NomeProcedimento")
                                    ValorProcedimentos = g("TotalProcedimentos")
                                elseif guias("TipoGuia")="guiasadt" then
                                    ValorProcedimentos = 0
                                    set psa = db.execute("select p.NomeProcedimento, gs.ValorTotal from tissprocedimentossadt gs left join procedimentos p on p.id=gs.ProcedimentoID where gs.ProfissionalID="& ProfissionalID &" and gs.GuiaID="& guias("GuiaID"))
                                    while not psa.eof
                                        ValorProcedimentos = fn(psa("ValorTotal")) + ValorProcedimentos
                                        %>
                                        <%= psa("NomeProcedimento") %><br />
                                        <%
                                    psa.movenext
                                    wend
                                    psa.close
                                    set psa=nothing
                                end if
                                %>
                            </td>
                            <td class="text-right"><%= fn(ValorProcedimentos) %></td>
                            <td class="text-right"><%= fn(g("TotalGuia")) %></td>
                            <td class="text-right"><%= fn(g("ValorPago")) %></td>
                            <td class="text-right"><%= nroNFe %></td>
                        </tr>
                        <%
                    end if
                end if
            guias.movenext
            wend
            guias.close
            set guias=nothing
            %>
            <tr class="<%= lClasse %>">
                <th colspan="6">
                    <%=c %> guia<%if c>1 then response.write("s") end if %>.
                </th>
                <th class="text-right"><%= fn(SubProcedimentos) %></th>
                <th class="text-right"><%= fn(SubGuia) %></th>
                <th class="text-right"><%= fn(SubPago) %></th>
            </tr>
        <%
            if c=0 then
                %>
                <script type="text/javascript">
                    $(".<%= lClasse %>").css("display", "none");
                </script>
                <%
            end if

            cP = cP+c
            SubProcedimentosP = SubProcedimentosP+SubProcedimentos
            SubGuiaP = SubGuiaP+SubGuia
            SubPagoP = SubPagoP+SubPago
        next
        %>
        <tr>
            <th colspan="6">
                <%=cP %> guia<%if cP>1 then response.write("s") end if %> deste profissional.
            </th>
            <th class="text-right"><%= fn(SubProcedimentosP) %></th>
            <th class="text-right"><%= fn(SubGuiaP) %></th>
            <th class="text-right"><%= fn(SubPagoP) %></th>
        </tr>
    </table>
    <%
    SubGuiaPP = SubGuiaPP + SubGuiaP
    SubPagoPP = SubPagoPP + SubPagoP
    SubProcedimentosPP = SubProcedimentosPP + SubProcedimentosP
    cPP = cPP + cP
next
%>
<br>
<h2>Total</h2>
<table class=" table-condensed table-bordered table-hover" style="width: 100%;">
    <tbody>
    <tr>
        <th colspan="6">
            <%=cPP %> guia<%if cPP>1 then response.write("s") end if %> no total.
        </th>
        <th class="text-right"><%= fn(SubProcedimentosPP) %></th>
        <th class="text-right"><%= fn(SubGuiaPP) %></th>
        <th class="text-right"><%= fn(SubPagoPP) %></th>
    </tr>
    </tbody>
</table>