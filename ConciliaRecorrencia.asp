<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <table class="table table-condensed table-striped table-bordered">
            <thead>
                <tr>
                    <th>Cliente</th>
                    <%
                    Inicio = cdate("01/01/2018")
                    Data = Inicio
                    While Data<=date()+30
                        %>
                        <th><%= right(Data, 7) %></th>
                        <%
                        Data = dateAdd("m", 1, Data)
                    wend
                    %>
                </tr>
            </thead>
            <tbody>
                <%
                response.Buffer

                set dist = db.execute("select distinct m.AccountIDDebit, p.NomePaciente from sys_financialmovement m LEFT JOIN pacientes p ON p.id=m.AccountIDDebit where m.AccountAssociationIDDebit=3 and year(m.date)="& year(Inicio)&" order by p.NomePaciente")
                while not dist.eof
                    response.flush()
                    NomeCliente = ucase(dist("NomePaciente"))
                    %>
                    <tr>
                        <td><%= NomeCliente %></td>
                        <%
                        Data = Inicio
                        While Data<=date()+30
                            %>
                            <td>
                                <%
                                set m = db.execute("select m.Value from sys_financialmovement m where m.AccountIDDebit="& dist("AccountIDDebit") &" and month(m.Date)="& month(Data) &" and year(m.Date)="& year(Data) &" order by m.Date")
                                while not m.eof
                                    response.write( m("Value") &"<br>")
                                m.movenext
                                wend
                                m.close
                                set m=nothing
                                    %>
                            </td>
                            <%
                            Data = dateAdd("m", 1, Data)
                        wend
                        %>
                    </tr>
                    <%
                dist.movenext
                wend
                dist.close
                set dist=nothing
                %>
            </tbody>
        </table>
    </div>
</div>