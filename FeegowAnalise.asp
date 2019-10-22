<!--#include file="connect.asp"-->

<%
if left(req("P"), 6)="Feegow" and session("Banco")<>"clinic5459" then
    response.Redirect("./?P=Home&Pers=1")
end if


response.Buffer

if req("Calc")="1" then
    set l = db.execute("select * from cliniccentral.licencas l where l.Status<>'T'")
    while not l.eof

        response.flush()

        DataPriMens = ""
        ValPriMens = ""
        DataUltMens = ""
        ValUltMens = ""

       ' if l("Cupom")="LIVENT" or l("Cupom")="PRST" then
        '    DataPriMens = l("DataHora")
         '   ValPriMens = 27
         '   DataUltMens = date()
         '   ValUltMens = 27
        'else
            set priMens = db.execute("select Date, Value from sys_financialmovement where AccountIDDebit="& l("Cliente") &" and AccountAssociationIDDebit=3 order by Date limit 2")
            while not priMens.eof
                DataPriMens = priMens("Date")
                ValPriMens = priMens("Value")
            priMens.movenext
            wend
            priMens.close
            set priMens = nothing

            set ultMens = db.execute("select Date, Value from sys_financialmovement where AccountIDDebit="& l("Cliente") &" and AccountAssociationIDDebit=3 and Date<="& mydatenull(date()+10) &" order by Date desc limit 1")
            if not ultMens.eof then
                DataUltMens = ultMens("Date")
                ValUltMens = ultMens("Value")
            end if
        'end if

        sql = "replace into cliniccentral.feegowanalise (LicencaID, Cliente, Status, DataPriMens, DataUltMens, ValPriMens, ValUltMens, SatisfacaoMedia, Cidade, Estado, ProfAtivos, FuncAtivos) VALUES ("&_
        l("id") &", "& l("Cliente") &", '"& l("Status") &"', "& mydatenull(DataPriMens) &", "& mydatenull(DataUltMens) &", "& treatvalnull(ValPriMens) &", "& treatvalnull(ValUltMens) &", "& treatvalnull(SatisfacaoMedia) &", NULL, NULL, "& treatvalzero(ProfAtivos) &", "& treatvalzero(FuncAtivos) &")"
        response.write( sql &"<br>")
        db.execute( sql )

    l.movenext
    wend
    l.close
    set l = nothing
end if

%>

<div class="panel">
    <div class="panel-body">
        <table class="table table-condensed table-hover">
            <thead>
                    <%

                    GranDiferenca = 0
                    granQTD = 0
                    granPerdaCli = 0
                    granPerdaVal = 0
                    granPriMens = 0
                    granUltMens = 0
                    granTicketMedio = 0
                    granMaiorTicket = 0

                    set dist = db.execute("select distinct month(DataPriMens) Mes, year(DataPriMens) Ano from cliniccentral.feegowanalise where not isnull(DataPrimens) order by DataPriMens")
                    while not dist.eof
                    %>
                     <tr>
                       <th><%= monthName(dist("Mes")) &"/"& dist("Ano") %></th>
                       <td nowrap>
                           <table class="table table-condensed table-hover">
                               <tr>
                                   <th nowrap>Cliente</th>
                                   <th width="1%" nowrap>Prim. Mens.</th>
                                   <th width="1%" nowrap>Últ. Mens.</th>
                                   <th width="1%" class="hidden" nowarp>Últ. Fat</th>
                               </tr>
                           <%
                            PerdaVal = 0
                            PerdaCli = 0
                            TicketMedio = 0
                            Qtd = 0
                            MaiorTicket = 0
                            totPriMens = 0
                            totUltMens = 0
                            Diferenca = 0
                               
                            
                            set cli = db.execute("select fa.*, cli.NomePaciente from cliniccentral.feegowanalise fa LEFT JOIN pacientes cli ON cli.id=fa.Cliente where month(DataPriMens)="& dist("Mes") &" and year(DataPriMens)="& dist("Ano") &" order by fa.ValUltMens")
                            while not cli.eof
                                totPriMens = totPriMens + cli("valPriMens")
                                totUltMens = totUltMens + cli("valUltMens")
                                Qtd = Qtd + 1
                                if cli("valUltMens")>=cli("valPriMens") then
                                   classe = "system"
                                else
                                   classe = "info"
                                end if
                                if cli("DataUltMens")<date()-240 then
                                   classe = "danger"
                                    PerdaVal = PerdaVal + cli("ValUltMens")
                                    PerdaCli = PerdaCli + 1
                                end if

                               TicketMedio = TicketMedio + cli("ValUltMens")

                               if cli("valUltMens")>MaiorTicket then
                                    MaiorTicket = cli("valUltMens")
                               end if

                               Diferenca = cli("valUltMens")-cli("valPriMens") + Diferenca

                                %>
                                <tr class="<%= classe %>">
                                    <td><%= ucase(cli("NomePaciente")) %></td>
                                    <td class="text-right"><%= fn(cli("ValPriMens")) %></td>
                                    <td class="text-right"><%= fn(cli("ValUltMens")) %></td>
                                    <td class="text-right hidden"><%= cli("DataUltMens") %></td>
                                </tr>
                                <%
                            cli.movenext
                            wend
                            cli.close
                            set cli = nothing

                            TicketMedio = TicketMedio / qtd

                            granQTD = granQTD + qtd
                            GranDiferenca = GranDiferenca+Diferenca
                            granPerdaCli = granPerdaCli + PerdaCli
                            granPerdaVal = granPerdaVal + PerdaVal
                            granPriMens = granPriMens + totPriMens
                            granUltMens = granUltMens + totUltMens
                            %>
                            <tr>
                                <td>
                                    <div class="btn btn-default"><%= qtd &" adesões" %></div>
                                    <div class="btn btn-default"><%= PerdaCli &" perdas (R$ "& fn(PerdaVal) &")" %></div>
                                    <div class="btn btn-default"><%= "Tkt médio: R$ "& fn(TicketMedio) %></div>
                                    <div class="btn btn-default"><%= "Maior tkt: R$ "& fn(MaiorTicket) %></div>
                                </td>
                                <td class="text-right"><%= fn(totPriMens) %></td>
                                <td class="text-right"><%= fn(totUltMens) %></td>
                                <td class="text-right"><%= fn(Diferenca) %></td>
                            </tr>
                            </table>
                       </td>
                    </tr>
                    <%
                    dist.movenext
                    wend
                    dist.close
                    set dist = nothing
                    %>
            </thead>
        </table>

        <div class="btn btn-default"><%= granQTD & " adesões totais" %></div>
        <div class="btn btn-default"><%= granPerdaCli &" perdas totais (R$ "& fn(granPerdaVal) &")" %></div>
        <div class="btn btn-default"><%= "Tkt médio: R$ "& fn(granTicketMedio) %></div>
        <div class="btn btn-default"><%= "Maior tkt: R$ "& fn(granMaiorTicket) %></div>
        <div class="btn btn-default"><%= "Total fechado: R$ "& fn(granPriMens) %></div>
        <div class="btn btn-default"><%= "Total fechado + incrementado: R$ "& fn(granUltMens) %></div>
    </div>
</div>