<!--#include file="connect.asp"-->
<!--#include file="functionOcupacao.asp"-->
<%
lDe = cdate(ref("Data"))
lAte = lDe + 7
rfLocais = "|UNIDADE_ID"& ref("Unidade") &"|"
'rfLocais = ref("Unidade")
if rfLocais="" then
    rfLocais = "-"
end if
'response.write(De&", "&Ate&", "&refEspecialidade&", """", """", """", "& rfLocais)    
call ocupacao(lDe, lAte, ref("Especialidades"), "", "", "", rfLocais,session("User"),"",false)    
%>


<table class="table table-condensed table-bordered table-hover">
    <thead>
        <tr>
            <th>Profissional</th>
            <th>Especialidade</th>
            <th>Unidade</th>
            <%
            dataN = lDe
            while dataN<lAte
                %>
                <th><%= ucase(left(weekdayname(weekday(dataN)),3)) %></th>
                <%
                dataN = dataN+1
            wend
            %>
        </tr>
    </thead>
    <tbody>
        <%
        set prof = db.execute("select distinct ro.ProfissionalID, ro.EspecialidadeID, ro.UnidadeID, prof.NomeProfissional, esp.especialidade, u.NomeFantasia FROM rel_ocupacao ro LEFT JOIN profissionais prof ON prof.id=ro.ProfissionalID LEFT JOIN especialidades esp ON ro.EspecialidadeID=esp.id LEFT JOIN sys_financialcompanyunits u ON u.id=ro.UnidadeID WHERE ro.sysUser="& session("User") &" ORDER BY prof.NomeProfissional")
        while not prof.eof
            nomUn = getNomeLocalUnidade(prof("UnidadeID"))&""
            %>
            <tr>
                <td><%= prof("NomeProfissional") %></td>
                <td><%= prof("Especialidade") %></td>
                <td><%= prof("NomeFantasia") %></td>
                <%
                dataN = lDe
                while dataN<lAte
                    set conta = db.execute("select "&_
					"(select count(ro.id) from rel_ocupacao ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.Situacao IN('A') AND ro.sysUser="& session("User") &" AND ro.ProfissionalID="& prof("ProfissionalID") &" AND ro.UnidadeID="& treatvalnull(prof("UnidadeID")) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID)) A, "&_
					"(select count(ro.id) from rel_ocupacao ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.Situacao IN('B') AND ro.sysUser="& session("User") &" AND ro.ProfissionalID="& prof("ProfissionalID") &" AND ro.UnidadeID="& treatvalnull(prof("UnidadeID")) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &" AND ro.StaID NOT IN(11,15) AND NOT ISNULL(ro.StaID)) AB, "&_
					"(select count(ro.id) from rel_ocupacao ro WHERE ro.Data="& mydatenull(DataN) &" AND ro.Situacao='V' AND ro.sysUser="& session("User") &" AND ro.ProfissionalID="& prof("ProfissionalID") &" AND ro.UnidadeID="& treatvalnull(prof("UnidadeID")) &" AND ro.EspecialidadeID="& treatvalnull(prof("EspecialidadeID")) &") V")
                    Agendados = ccur(conta("A"))
					AgeBloq = ccur(conta("AB"))
                    Vazios = ccur(conta("V"))

                    perc = 0
                    classe = ""
                    if Vazios+Agendados+AgeBloq=0 then
                        classe = "dark"
                    elseif (Vazios+Agendados+AgeBloq)>0 and (Agendados+AgeBloq)<=(Vazios+Agendados+AgeBloq) then
                        perc = (Agendados+AgeBloq) / (Vazios+Agendados+AgeBloq)
                        if perc=0 then
                            classe = "white"
                        elseif perc>0 and perc<=0.25 then
                            classe = "info"
                        elseif perc>0.25 and perc<=0.5 then
                            classe = "system"
                        elseif perc>0.5 and perc<=0.75 then
                            classe = "alert"
                        elseif perc>0.75 and perc<1 then
                            classe = "warning"
                        elseif perc>=1 then
                            classe = "danger"
                        end if

                    end if
                    %>
                    <td>
                        <a class="btn btn-sm btn-block btn-<%= classe %>" href="./?P=agendamultipla&Pers=1&Data=<%= dataN %>&Profissionais=|<%= prof("ProfissionalID") %>|&Locais=|UNIDADE_ID<%= prof("UnidadeID") %>|&Especialidades=|<%= prof("EspecialidadeID") %>|" target="_blank">
                            <%= Agendados+AgeBloq &"/"& Vazios+Agendados %> <%'= perc %>
                        </a>
                    </td>
                    <%
                    dataN = dataN+1
                wend
                %>
            </tr>
            <%
        prof.movenext
        wend
        prof.close
        set prof = nothing
        %>
    </tbody>
</table>
