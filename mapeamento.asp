<!--#include file="connect.asp"-->
<table class="table table-striped table-condensed table-hover">
    <thead>
        <tr>
            <th>PROFISSIONAL</th>
            <th>ESPECIALIDADE</th>
            <th>BAIRRO</th>
            <th>CIDADE</th>
        </tr>
    </thead>
    <tbody>
    <%
    db_execute("delete from cliniccentral.estat")

    if session("banco")="clinic105" then
        cp = 0
        set l = db.execute("select l.id, b.Nome, b.Bairro, b.Cidade, b.Estado from cliniccentral.licencas l LEFT JOIN bafim.paciente b on b.id=l.Cliente WHERE l.Status='C'")
        while not l.eof
            set ii = db.execute("select i.table_name from information_schema.`TABLES` i where i.TABLE_SCHEMA='clinic"&l("id")&"' and i.TABLE_NAME='profissionais'")
            if not ii.eof then
                set prof = db.execute("select p.NomeProfissional, p.Bairro, p.Cidade, p.Estado, e.especialidade from clinic"&l("id")&".profissionais p LEFT JOIN especialidades e on e.id=p.EspecialidadeID where trim(NomeProfissional) NOT LIKE '' AND NOT ISNULL(e.especialidade) LIMIT 60")
                while not prof.eof
                    if l("Cidade")=req("Cidade") or l("Estado")=req("Estado") or prof("Estado")=req("Estado") or prof("Cidade")=req("Cidade") then
                        aparece = 1
                    else
                        aparece = 0
                    end if
                    if aparece=1 then
                        cp = cp+1
                        if trim(prof("Bairro"))<>"" then
                            Bairro = ucase(trim(prof("Bairro")))
                        else
                            Bairro = ucase(trim(l("Bairro")))
                        end if
                        if trim(prof("Cidade"))<>"" then
                            Cidade = ucase(trim(prof("Cidade")))
                        else
                            Cidade = ucase(trim(l("Cidade")))
                        end if
                        db_execute("insert into cliniccentral.estat (Especialidade, Bairro, Cidade) values ('"&prof("Especialidade")&"', '"&rep(Bairro)&"', '"&rep(Cidade)&"')")
                    %>
                    <tr>
                        <td><%=ucase(prof("NomeProfissional")) %></td>
                        <td><%=ucase(prof("Especialidade")) %></td>
                        <td><%=Bairro %></td>
                        <td><%=Cidade %></td>
                    </tr>
                    <%
                    end if
                prof.movenext
                wend
                prof.close
                set prof = nothing
            end if
        l.movenext
        wend
        l.close
        set l=nothing
    end if
    %>
    </tbody>
</table>
<%=cp %> profissionais.

<h1>RESUMO POR ESPECIALIDADE</h1>

<table class="table table-striped table-condensed table-hover">
    <thead>
        <tr>
            <th>ESPECIALIDADE</th>
            <th>QUANTIDADE</th>
        </tr>
    </thead>
    <tbody>
        <%
        set dist = db.execute("select e.Especialidade, (select count(*) from cliniccentral.estat where Especialidade=e.Especialidade) qtd from cliniccentral.estat e group by e.Especialidade")
        while not dist.eof
            %>
            <tr>
                <td><%=dist("Especialidade") %></td>
                <td><%=dist("qtd") %></td>
            </tr>
            <%
        dist.movenext
        wend
        dist.close
        set dist=nothing
        %>
    </tbody>
</table>