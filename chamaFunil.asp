<!--#include file="connect.asp"-->
<table cellpadding="7"  width="95%" align="center" border="0">
<tr>
<%
splEtapa = split(ref("Etapa"), ", ")
c = 0
for i=0 to ubound(splEtapa)
    c = c+1
next
if c>0 then
    larg = cint(100/c)
end if

set fun = db.execute("select * from chamadasconstatus order by Ordem")
while not fun.eof
    if instr(ref("Etapa"), "|"&fun("id")&"|") then
    %>
    <td width="<%=larg %>%" class="widget-box">
        <div class="widget-box">
            <div class="widget-header">
                <h5><%=ucase(fun("NomeStatus")) %></h5>
            </div>
        </div>
        <div style="height:450px; overflow-y:scroll" class="widget-body">
            <table width="100%" class="table table-hover table-bordered">
                <tbody>
                <%
                    if instr(ref("Origem"), "|ALL|")=0 and ref("Origem")<>"" then
                        sqlOrigem = " AND p.Origem="&replace(ref("Origem"), "|", "")
                    end if
                    if ref("Responsavel")<>"" then
                        sqlResp = " AND p.sysUser in("&replace(ref("Responsavel"), "|", "")&") "
                    end if
                    if ref("DataDe")<>"" then
                        sqlDataDe = " AND date(p.sysDate)>="&mydatenull(ref("DataDe"))&" "
                    end if
                    if ref("DataAte")<>"" then
                        sqlDataAte = " AND date(p.sysDate)<="&mydatenull(ref("DataAte"))&" "
                    end if
                    if ref("De")<>"" and ref("De")<>"0,00" then
                        sqlDe = " AND p.ValorInteresses>="&treatvalzero(ref("De"))&" "
                    end if
                    if ref("Ate")<>"" and ref("Ate")<>"0,00" then
                        sqlAte = " AND p.ValorInteresses<="&treatvalzero(ref("Ate"))&" "
                    end if
                    if ref("FollowUp")="Nenhum" then
                        sqlFup = " and isnull(r.Data)"
                    elseif ref("FollowUp")="Vencidos" then
                        sqlFup = " and (r.Data<date(now()) or (r.Data=date(now()) and r.Hora<time(now())) )"
                    elseif ref("FollowUp")="Futuros" then
                        sqlFup = " and (r.Data>date(now()) or (r.Data=date(now()) and r.Hora>time(now())) )"
                    else
                        sqlFup = ""
                    end if
                    set pac = db.execute("select p.id, p.NomePaciente, p.Tel1, p.Tel2, p.Cel1, p.Cel2, p.Interesses, p.ValorInteresses, r.Data, r.Hora from pacientes p LEFT JOIN chamadasrecontatar r on replace(r.Contato, '3_', '')=p.id where p.ConstatusID="&fun("id") & sqlOrigem & sqlResp & sqlDataDe & sqlDataAte & sqlDe & sqlAte & sqlFup &" GROUP BY p.id ORDER BY p.sysDate desc LIMIT 300")
                    while not pac.eof
                        %>
                        <tr>
                            <td style="padding:10px">
                                <b><a target="_blank" href="./?P=Pacientes&Pers=1&I=<%=pac("id") %>"><%=pac("NomePaciente") %></a></b>
                                <br />
                                <%=callAction(pac("Tel1"), 2, "3_"&pac("id")) %>
                                <%=callAction(pac("Tel2"), 2, "3_"&pac("id")) %>
                                <%=callAction(pac("Cel1"), 2, "3_"&pac("id")) %>
                                <%=callAction(pac("Cel2"), 2, "3_"&pac("id")) %>
                                <br />
                                <small>
                                <%
                                if not isnull(pac("Interesses")) and pac("Interesses")<>"" then
                                    set procs = db.execute("select group_concat(NomeProcedimento) NomesProcedimentos from procedimentos where id in("&replace(pac("Interesses")&"", "|", "")&")")
                                    if not procs.eof then
                                        response.Write( procs("NomesProcedimentos") )
                                    end if
                                end if

                                strFup = pac("Data") &" - "& ft(pac("Hora"))
                                if not isnull(pac("Data")) and isdate(pac("Data")) then
                                    if pac("Data")<date() or (pac("Data")=date() and pac("Hora")<time()) then
                                        strFup = "<span class='label label-sm arrowed label-danger'>" & strFup & "</span>"
                                    end if
                                end if
                                %>
                                <br />
                                R$ <%=fn(pac("ValorInteresses")) %> &nbsp; &nbsp; &nbsp; Follow Up: <%=strFup %></small>
                            </td>
                        </tr>
                        <%
                    pac.movenext
                    wend
                    pac.close
                    set pac=nothing
                %>
                </tbody>
            </table>
        </div>
    </td>
    <%
    end if
fun.movenext
wend
fun.close
set fun=nothing
%>
</tr>
</table>