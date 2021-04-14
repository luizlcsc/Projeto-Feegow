<!--#include file="connect.asp"-->
<%

    server.ScriptTimeout = 500
    q = request.form("Q")
%>
<div class="panel">
    <div class="panel-body">
        <div class="row">
            <form method="post" class="col-md-12">
                <%= quickfield("memo", "Q", "Query", 11, q, "", "", "") %>
                <div class="col-md-1">
                    <button type="submit" class="btn btn-primary mt20 btn-block">Ok</button>
                </div>
            </form>
        </div>

        <hr class="short alt" />

        <div class="row">
            <table class="table table-condensed table-striped table-bordered col-md-12">
                <thead>
                    <tr>
                        <th>Licença</th>
                        <th>Valor</th>
                    </tr>
                </thead>
                <tbody>
                <%
                t = 0

                'on error resume next

                if q<>"" then
                    response.Buffer
                    ConnStringC = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
                    Set dbC = Server.CreateObject("ADODB.Connection")
                    dbC.Open ConnStringC
                    set l = dbC.execute("select id, Servidor from cliniccentral.licencas where Servidor like '%amazonaws%' and id not in(446, 449, 475, 485, 499, 528, 542, 565, 605, 1449, 6539, 6540, 6548) and Status='C'")
                    while not l.eof
                        LicencaID = l("id")
                        strServidor = l("Servidor")

                        ConnStringL = "Driver={MySQL ODBC 8.0 ANSI Driver};Server="& strServidor &";Database=clinic"& l("id") &";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
                        Set dbL = Server.CreateObject("ADODB.Connection")
                        dbL.Open ConnStringL

                        set cons = dbL.Execute( q )
                        while not cons.eof
                            response.Flush()

                            t = t+ccur(cons("Res"))
                            %>
                            <tr>
                                <td><%= l("id") %></td>
                                <td>
                                    <%= cons("Res") %>
                                </td>
                            </tr>
                            <%
                        cons.movenext
                        wend
                        cons.close
                        set cons = nothing
                    l.movenext
                    wend
                    l.close
                    set l = nothing
                end if
                %>
                </tbody>
                <tfoot>
                    <tr>
                        <td></td>
                        <td><%= t %></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
</div>
