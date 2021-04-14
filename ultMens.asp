<!--#include file="connect.asp"-->

<% 
response.charset="utf-8"
on error resume next
    
if session("Banco")="clinic5459" then
    %>
    <div class="panel">
        <div class="panel-body">
            <table class="table table-striped table-bordered table-hover">
                <thead>
                    <tr>
                        <th>Licença</th>
                        <th>Profs</th>
                        <th>Funcs</th>
                        <th>Nome</th>
                        <th>Últ. Fat.</th>
                        <th>Cupom</th>
                    </tr>
                </thead>
                <tbody>
                <%
                c = 0
                response.Buffer


                set lics = db.execute("select l.NomeContato, l.NomeEmpresa, l.Cliente, l.Cupom, l.id LicencaID, l.Servidor from cliniccentral.licencas l where l.Status='C'")
                while not lics.eof
                    Servidor = lics("Servidor")
                    'if Servidor="localhost" then Servido="192.168.193.43" else Servidor="192.168.193."&Servidor end if
                    ConnStringServ = "Driver={MySQL ODBC 8.0 ANSI Driver};Server="& Servidor &";Database=cliniccentral;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
                    Set dbServ = Server.CreateObject("ADODB.Connection")
                    dbServ.Open ConnStringServ



                    nota = 0
                    max = 5
                    c = c+1
                    opinioes = 0
                    response.Flush()

                    set pessoas = dbServ.execute("select (select count(id) from clinic"& lics("LicencaID") &".profissionais where Ativo='on') profs, (select count(id) from clinic"& lics("LicencaID") &".funcionarios where ativo='on') funcs")
                    %>
                    <tr>
                        <td onclick="pgn(<%= lics("LicencaID") %>)"><%= lics("LicencaID") %> - <%= lics("Cliente") %></td>
                        <td><%= pessoas("Profs") %></td>
                        <td><%= pessoas("Funcs") %></td>
                        <td style="text-transform:capitalize" id="l<%= lics("LicencaID") %>"><%= lcase(ucase(lics("NomeEmpresa") &"<br>"& lics("NomeContato"))) %></td>
                        <td>
                        <%
                        sql = "select Date, Value from clinic5459.sys_financialmovement m where m.AccountIDDebit="& lics("Cliente") &" and CD='C' and Date BETWEEN "& mydatenull(date()-31) &" AND "& mydatenull(date()) &""
                        'response.write( sql )
                        set vcaVal = db.execute( sql )
                        while not vcaVal.eof
                            %>
                            <%= vcaVal("Date") %> - <%= vcaVal("Value") %>
                            <%
                        vcaVal.movenext
                        wend
                        vcaVal.close
                        set vcaVal = nothing
                        %>
                        </td>
                        <td><%= lics("Cupom") %></td>
                    </tr>
                    <%
                    topinioes = topinioes + opinioes
                lics.movenext
                wend
                lics.close
                set lics = nothing
                %>
                </tbody>
                <tfoot>
                    <tr>
                        <th><%= c %> licenças </th>
                        <th></th>
                        <th></th>
                        <th><%= topinioes %> votos</th>
                    </tr>
                </tfoot>
            </table>

        </div>
    </div>
    <%
end if
%>

<script type="text/javascript">
    function pgn(L) {
        $.get("PointsPegaNome.asp?L=" + L, function (data) {
            $("#l" + L).html() + "<br>" +  $("#l" + L).html(data);
        });
}
</script>