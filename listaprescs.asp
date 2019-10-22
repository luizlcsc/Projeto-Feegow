<!--#include file="connect.asp"-->
<%if session("Banco")="clinic105" or session("Banco")="clinic100000" then %>
<table class="table table-bordered table-condensed table-striped table-hover">
    <thead>
        <tr>
            <th>Profissional</th>
            <th>Especialidade</th>
        </tr>
     </thead>
    <tbody>
        <%
        response.Buffer

        Total = 0
        Profissionais = 0
        set cli = db.execute("select id from cliniccentral.licencas where Status='C'")
        while not cli.eof
            response.flush()
            set prof = db.execute("select p.id, p.NomeProfissional, e.especialidade, u.id sysUser from clinic"&cli("id")&".profissionais p LEFT JOIN clinic"&cli("id")&".especialidades e on e.id=p.EspecialidadeID JOIN clinic"&cli("id")&".sys_users u on (u.idInTable=p.id and u.Table='profissionais')")
           while not prof.eof
              C = 0
              set presc = db.execute("select * from clinic"&cli("id")&".pacientesprescricoes where sysUser="&prof("sysUser")&" AND Data BETWEEN '2017-01-08' AND '2017-02-08'")
              if not presc.eof then
                Profissionais = Profissionais+1
                while not presc.eof
                    c=c+1
                    %>
                    <tr>
                        <td><%=presc("Prescricao") %></td>
                        <td><%=presc("Data") %></td>
                    </tr>
                    <%
                presc.movenext
                wend
                presc.close
                set presc=nothing
                %>
                <tr class="danger">
                    <th><%=prof("NomeProfissional") %></th>
                    <th><%=prof("Especialidade") %> - <%=c %></th>
                </tr>
                <%
              end if
              Total = Total + c
            prof.movenext
            wend
            prof.close
            set prof=nothing
        cli.movenext
        wend
        cli.close
        set cli=nothing
        %>
    </tbody>
</table>
<%end if %>

Profissionais pesquisados: <%=Profissionais %>
<br />
Receitas totais: <%=Total %>