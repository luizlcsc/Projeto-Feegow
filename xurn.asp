<%
response.charset = "utf-8"    
if session("Banco")="clinic105" or session("Banco")="clinic100000" or session("Banco")="clinic5459" then %>
    <!--#include file="connect.asp"-->


    <div class="panel mt15">
        <div class="panel-body">
            <table class="table table-striped table-bordered table-hover">
                <thead>
                    <tr>
                        <th>M&Ecirc;S</th>
                        <th>LICEN&Ccedil;AS</th>
                        <th>USU&Aacute;RIOS</th>
                        <th>CHR LICEN&Ccedil;AS</th>
                        <th>CHR USU&Aacute;RIOS</th>
                    </tr>
                </thead>
                <tbody>
                <%
                db_execute("update cliniccentral.licencas l set l.DataBloqueio=(select date(ll.DataHora) from cliniccentral.licencaslogins ll where ll.LicencaID=l.id and ll.Sucesso=1 order by ll.DataHora desc limit 1) where l.`Status`='B'")

                c = 0

                TEntrantes = 0
                TEntrantesUsu = 0
                TSaintes = 0
                TSaintesUsu = 0

                Data = cdate("01/09/2014")
                while Data<date()
                    c = c + 1

                    Mes = month(Data)
                    Ano = year(Data)
                   set lativ = db.execute("select count(id) Entrantes from cliniccentral.licencas where month(DataHora)="& Mes &" and year(DataHora)="& Ano &" AND Status<>'T'")
                   set lbloq = db.execute("select count(id) Saintes from cliniccentral.licencas where month(DataBloqueio)="& Mes &" and year(DataHora)="& Ano &" AND Status='B'")
                   set lativUsu = db.execute("select count(lu.id) EntrantesUsu from cliniccentral.licencasusuarios lu LEFT JOIN cliniccentral.licencas l ON l.id=lu.LicencaID where month(lu.DataHora)="& Mes &" and year(lu.DataHora)="& Ano &" AND l.Status<>'T'")
                   set lbloqUsu = db.execute("select count(lu.id) SaintesUsu from cliniccentral.licencasusuarios lu LEFT JOIN cliniccentral.licencas l ON l.id=lu.LicencaID where month(l.DataBloqueio)="& Mes &" and year(l.DataBloqueio)="& Ano &" AND l.Status='B'")

                    TEntrantes = TEntrantes + ccur(lativ("Entrantes"))
                    TEntrantesUsu = TEntrantesUsu + ccur(lativUsu("EntrantesUsu"))
                    TSaintes = TSaintes + ccur(lbloq("Saintes"))
                    TSaintesUsu = TSaintesUsu + ccur(lbloqUsu("SaintesUsu"))
                    %>
                    <tr>
                        <td><%= ucase(left(monthname(Mes), 3)) &" / "& Ano %></td>
                        <td class="text-right"><%= lativ("Entrantes") %></td>
                        <td class="text-right"><%= lativUsu("EntrantesUsu") %></td>
                        <td class="text-right"><%= lbloq("Saintes") %></td>
                        <td class="text-right"><%= lbloqUsu("SaintesUsu") %></td>
                    </tr>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend

                    %>

                </tbody>
                <tfoot>
                    <tr>
                        <th><%= c %> meses</th>
                        <th class="text-right"><%= TEntrantes %></th>
                        <th class="text-right"><%= TEntrantesUsu %></th>
                        <th class="text-right"><%= TSaintes %></th>
                        <th class="text-right"><%= TSaintesUsu %></th>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
<%
end if
    
    
%>