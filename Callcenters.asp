<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <table class="table table-striped table-hover table-bordered">
            <thead>
                <tr>
                    <th>TIPO</th>
                    <th>CLIENTE</th>
                    <th>NOME</th>
                    <th>EMAIL</th>
                    <th>DATA DE CADASTRO</th>
                    <th>DIAS</th>
                    <th>VALOR</th>
                    <th>ATIVO</th>
                </tr>
            </thead>
            <tbody>
            <%
            Part = req("Part")
            set l = db.execute("select l.Servidor, lu.id UsuarioID, lu.LicencaID, lu.Tipo, l.NomeContato Cliente, lu.Nome, lu.Email, l.DataHora `Data_de_Cadastro`, DATEDIFF(NOW(), l.DataHora) Dias, if(DATEDIFF(NOW(), l.DataHora)>=30 and lu.Admin=1, 25, 0) Valor  from cliniccentral.licencas l LEFT JOIN cliniccentral.licencasusuarios lu on lu.licencaid=l.id WHERE l.Cupom IN('"& req("Partner") &"') AND l.Cupom<>'' AND `Status`='C' ORDER BY l.NomeContato")
            while not l.eof
                ConnStringCli = "Driver={MySQL ODBC 8.0 ANSI Driver};Server="& l("Servidor") &";Database=clinic"& l("LicencaID") &";uid=root;pwd=pipoca453;"
                Set dbCli = Server.CreateObject("ADODB.Connection")
                dbCli.Open ConnStringCli
                set vca = dbCli.execute("select i.table_name from information_schema.tables i WHERE i.table_schema='clinic"& l("LicencaID") &"' AND i.table_name='"& l("Tipo") &"'")
                if not vca.eof then
                    set profun= dbCli.execute("select t.ativo from clinic"& l("LicencaID") &"."& l("Tipo") &" t LEFT JOIN clinic"& l("LicencaID") &".sys_users u ON u.idInTable=t.id WHERE u.id="& l("UsuarioID"))
                    if not profun.eof then
                        if profun("Ativo")="on" then
                            %>
                            <tr>
                                <td><%= l("Tipo") %></td>
                                <td><%= l("Cliente") %></td>
                                <td><%= l("Nome") %></td>
                                <td><%= l("Email") %></td>
                                <td><%= l("Data_de_Cadastro") %></td>
                                <td><%= l("Dias") %></td>
                                <td><%= l("Valor") %></td>
                                <td><%= profun("Ativo") %></td>
                            </tr>
                            <%
                        end if
                    end if
                end if
            l.movenext
            wend
            l.close
            set l=nothing
            %>
            </tbody>
        </table>
    </div>
</div>
