<!--#include file="connect.asp"-->

<% 
response.charset="utf-8"
    
if session("Banco")="clinic105" then
    %>
    <div class="panel">
        <div class="panel-body">
            <table class="table table-striped table-bordered table-hover">
                <thead>
                    <tr>
                        <th colspan="2">LICENÇA</th>
                        <th>Profs</th>
                        <th>Funcs</th>
                        <%
                        dim cores(5), qtdnota(5)

                        set pq = db.execute("select * from cliniccentral.qualidometrostatus")
                        while not pq.eof
                            cores(pq("id")) = pq("Cor")
                            qtdnota(pq("id")) = 0
                            %>
                            <th style="background-color:#<%= pq("Cor") %>; color:#fff"> <i class="imoon imoon-<%= pq("Icone") %>"></i> <%= pq("Status") %></th>
                            <%
                        pq.movenext
                        wend
                        pq.close
                        set pq=nothing
                            %>
                        <th>ID</th>
                    </tr>
                </thead>
                <tbody>
                <%
                c = 0
                topinioes = 0
                response.Buffer

                Servidores = array(43, 45)
                for i=0 to ubound(Servidores)

                    Servidor = Servidores(i)

                    ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=192.168.193."& Servidor &";Database=clinic105;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
                    Set dbServ = Server.CreateObject("ADODB.Connection")
                    dbServ.Open ConnString


                    'set ajustaQuali = dbServ.Execute("select NotaNova, UsuarioID from cliniccentral.pesquisa_satisfacao where isnull(Nota)")
                    'while not ajustaQuali.eof
                    '    dbServ.execute("update cliniccentral.licencasusuarios set Qualidometro="& ajustaQuali("NotaNova") &" where id="& ajustaQuali("UsuarioID"))
                    'ajustaQuali.movenext
                    'wend
                    'ajustaQuali.close
                    'set ajustaQuali=nothing


                    set lics = dbServ.execute("select pu.LicencaID, l.NomeContato, l.NomeEmpresa, l.Cliente, l.Cupom from cliniccentral.pesquisa_satisfacao pu LEFT JOIN cliniccentral.licencas l ON l.id=pu.LicencaID where isnull(pu.Nota) group by pu.LicencaID")
                    while not lics.eof
                        nota = 0
                        max = 5
                        c = c+1
                        opinioes = 0
                        response.Flush()

                        set pessoas = dbServ.execute("select (select count(id) from clinic"& lics("LicencaID") &".profissionais where Ativo='on') profs, (select count(id) from clinic"& lics("LicencaID") &".funcionarios where ativo='on') funcs")
                        %>
                        <tr>
                            <td onclick="pgn(<%= lics("LicencaID") %>)"><%= lics("LicencaID") %> <br /> <%= lics("Cupom") %> </td>
                            <td><%= pessoas("Profs") %></td>
                            <td><%= pessoas("Funcs") %></td>
                            <td style="text-transform:capitalize" id="l<%= lics("LicencaID") %>"><%= lcase(ucase(lics("NomeEmpresa") &"<br>"& lics("NomeContato"))) %></td>
                            <%
                            while nota<max
                                nota = nota+1
                                %>
                                <td style="text-transform:capitalize; color:#<%= cores(nota) %>">
                                    <%
                                    set usus = dbServ.Execute("select Nome, tipo, Admin from cliniccentral.licencasusuarios where Qualidometro="& nota &" and LicencaID="& lics("LicencaID"))
                                    while not usus.eof
                                        qtdnota(nota) = qtdnota(nota)+1
                                        opinioes = opinioes+1

                                        if usus("Admin")=1 then
                                            exclamacao = "<span class='far fa-exclamation-circle'></span>"
                                        else
                                            exclamacao = ""
                                        end if
                                        %>
                                        <%= exclamacao &" "& lcase(left(usus("Nome"), 15) &" ("& left(usus("tipo"), 4) &")") %><br />
                                        <%
                                    usus.movenext
                                    wend
                                    usus.close
                                    set usus=nothing
                                    %>
                                </td>
                                <%
                            wend
                            %>
                            <td>
                            <%
                            set vcaVal = db.execute("select Date, Value from clinic5459.sys_financialmovement m where m.AccountIDDebit="& lics("Cliente") &" and CD='C' and Date BETWEEN "& mydatenull(date()-31) &" AND "& mydatenull(date()) &"")
                            while not vcaVal.eof
                                if req("V")="1" then
                                    %>
                                    <%= replace(vcaVal("Date"), "/", "") %> - R$ <%= vcaVal("Value") %>
                                    
                                    <%
                                end if
                            vcaVal.movenext
                            wend
                            vcaVal.close
                            set vcaVal = nothing
                            %>
                            </td>
                        </tr>
                        <%
                        topinioes = topinioes + opinioes
                    lics.movenext
                    wend
                    lics.close
                    set lics = nothing
                next
                %>
                </tbody>
                <tfoot>
                    <tr>
                        <th><%= c %> licenças </th>
                        <th></th>
                        <th></th>
                        <th><%= topinioes %> votos</th>
                        <%
                        set pq = db.execute("select * from cliniccentral.qualidometrostatus")
                        while not pq.eof
                            %>
                            <th style="background-color:#<%= pq("Cor") %>; color:#fff"> <%= pq("Status") %>: <%= qtdnota(pq("id")) %>  </th>
                            <%
                        pq.movenext
                        wend
                        pq.close
                        set pq=nothing
                        %>
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