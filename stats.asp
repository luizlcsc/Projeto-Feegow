<!--#include file="connect.asp"-->
<table class="table table-condensed table-bordered">
    <tbody>
    <%
    if session("Banco")="clinic105" or session("Banco")="clinic100000" then


        select case req("Tipo")

            case ""
                response.write("Selecione o tipo")
    
            case "UsuariosPorEspecialidade"

                set lu = db.execute("select distinct lu.Esp1, esp.especialidade, (select count(id) from cliniccentral.licencasusuarios where Esp1=lu.Esp1) qtd from cliniccentral.licencasusuarios lu left join cliniccentral.especialidade esp on esp.id=lu.esp1 order by especialidade")
                while not lu.eof
                    %>
                    <tr>
                        <td><%= lu("especialidade") %></td>
                        <td><%= lu("qtd") %></td>
                    </tr>
                    <%
                lu.movenext
                wend
                lu.close
                set lu=nothing

            case "ClientesPorLocalizacao"

                set uf = db.execute("select distinct estado from bafim.paciente order by estado")
                while not uf.eof
                    %>
                    <tr>
                        <td><b><%= ucase(uf("Estado")) %></b></td>
                        <td></td>
                    </tr>
                    <%
                    set cid = db.execute("select distinct p.Cidade, (select count(id) from bafim.paciente where Cidade=p.Cidade) qtd from bafim.paciente p where p.Estado='"& uf("Estado") &"' order by p.Cidade")
                    while not cid.eof
                        %>
                        <tr>
                            <td><%= ucase(cid("Cidade")) %></td>
                            <td><%= cid("qtd") %></td>
                        </tr>
                        <%
                    cid.movenext
                    wend
                    cid.close
                    set cid=nothing
                uf.movenext
                wend
                uf.close
                set uf=nothing

            case "UsuariosPorPeriodo"

                set per = db.execute("select distinct month(DataHora) Mes, year(DataHora) Ano from cliniccentral.licencasusuarios order by DataHora")
                while not per.eof
                    set conta = db.execute("select count(id) Total from cliniccentral.licencasusuarios where month(DataHora)="& per("Mes") &" and year(DataHora)="& per("Ano"))
                    %>
                    <tr>
                        <td><%= per("Mes") &"/"& per("Ano") %></td>
                        <td><%= conta("Total") %></td>
                    </tr>
                    <%
                per.movenext
                wend
                per.close
                set per=nothing

            case "UsuariosAcumuladosPorPeriodo"

                Total = 0
                set per = db.execute("select distinct month(DataHora) Mes, year(DataHora) Ano from cliniccentral.licencasusuarios order by DataHora")
                while not per.eof
                    set conta = db.execute("select count(id) Total from cliniccentral.licencasusuarios where month(DataHora)="& per("Mes") &" and year(DataHora)="& per("Ano"))
                    Total = Total + ccur(conta("Total"))
                    %>
                    <tr>
                        <td><%= per("Mes") &"/"& per("Ano") %></td>
                        <td><%= Total %></td>
                    </tr>
                    <%
                per.movenext
                wend
                per.close
                set per=nothing

        end select

    end if
    %>
    </tbody>
</table>