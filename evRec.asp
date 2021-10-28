<!--#include file="connect.asp"-->
<div class="panel pt20">
    <div class="panel-body">
        <table class="table table-condensed table-hover table-striped">
        <thead>
            <tr class="info">
                <th>Cliente</th>
                <th>Entrada</th>
                <th>Valor Inicial</th>
                <th>Valor Final</th>
                <th>Incremento</th>
                <th>Permanência</th>
                <th>Total</th>
            </tr>
        </thead>
        <%
        server.scripttimeout = 2000
        response.buffer
        c = 0
        totalGeral = 0
        Ano = req("Ano")
        tValorInicial = 0
        tValorFinal = 0
        tPermanencia = 0
        if Ano<>"" then
            sqlAno = " and year(p.sysDate)="& Ano &" "
        end if
        set dist = db.execute("select p.id, p.NomePaciente, p.sysDate from pacientes p where not isnull(p.sysDate) "& sqlAno &" order by p.sysDate")
        while not dist.eof
            DataEntrada = dist("sysDate")
            set fat = db.execute("select m.Date, m.Value from sys_financialmovement m where AccountAssociationIDDebit=3 and AccountIDDebit="& dist("id") &" and m.Value>0 and Type='Bill' order by m.Date")
            if not fat.eof then
                response.flush()
                c = c+1
                %>
                <tr>
                    <td><%= ucase(dist("NomePaciente")) %></td>
                    <td><%= formatdatetime(dist("sysDate"),2) %></td>
                    <td>
                        <%
                        totalCliente = 0
                        numeroParcela = 0
                        valorInicial = 0
                        valorFinal = 0
                        while not fat.eof
                            DataFatura = fat("Date")
                            numeroParcela = numeroParcela+1
                            if numeroParcela<4 then
                                valorInicial = fat("Value")
                            end if
                            valorFinal = fat("Value")

                            totalCliente = totalCliente + fat("Value")
                            totalGeral = totalGeral + fat("Value")

                            db.execute("insert into temp_evrec set MesEntrada="& month(DataEntrada) &", AnoEntrada="& year(DataEntrada) &", MesFatura="& month(DataFatura) &", AnoFatura="& year(DataFatura) &", ValorFatura="& treatvalzero(fat("Value")))
                            if 0 then
                            %>
                            <code>
                                <%= fat("Date")&" "& fn(fat("Value")) %>
                            </code>
                            <%
                            end if
                        fat.movenext
                        wend
                        fat.close
                        set fat = nothing


                        tValorInicial = tValorInicial + valorInicial
                        tValorFinal = tValorFinal + valorFinal
                        tPermanencia = tPermanencia + numeroParcela

                        Crescimento = ((valorFinal-valorInicial)/valorInicial)*100
                        if Crescimento>0 then
                            Crescimento = "<span class='label label-success'><i class='far fa-arrow-up'></i> "& fn(Crescimento) &"%</span>"
                        elseif Crescimento<0 then
                            Crescimento = "<span class='label label-danger'><i class='far fa-arrow-down'></i> "& fn(Crescimento) &"%</span>"
                        else
                            Crescimento = ""
                        end if

                        response.write( fn(valorInicial) )
                        %>
                    </td>
                    <td><%= fn(valorFinal) %></td>
                    <td><%= Crescimento %></td>
                    <td><%= numeroParcela %></td>
                    <td><%= fn(totalCliente) %></td>
                </tr>
                <%
            end if
        dist.movenext
        wend
        dist.close
        set dist=nothing
        %>
        <tfoot>
            <tr>
                <th colspan="2"><%= c %></th>
                <th><%= fn( tValorInicial ) %></th>
                <th><%= fn( tValorFinal ) %></th>
                <th><%= fn( ((tvalorFinal-tvalorInicial)/tvalorInicial)*100 ) %>%</th>
                <th><%= cint( tPermanencia/c ) %></th>
                <th><%= fn( totalGeral ) %></th>
            </tr>
        </tfoot>
        </table>
    </div>
</div>