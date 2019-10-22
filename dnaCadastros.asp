<%
ON ERROR RESUME NEXT

function myDateTime(Val)
	if isDate(Val) and Val<>"" then
		myDateTime = "'"&year(Val)&"-"&month(Val)&"-"&day(Val)&" "&hour(val)&":"&minute(val)&":"&second(val)&"'"
		if year(val)<1960 then
			myDateTime = "NULL"
		end if
	else
		myDateTime = "NULL"
	end if
end function

function rep(Val)
	if isnull(Val) then
		rep=""
	else
		rep = replace(trim(Val&" "), "'", "''")
	end if
end function


ConnString43 = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=192.168.193.43;Database=cliniccentral;uid=root;pwd=pipoca453;"
Set db43 = Server.CreateObject("ADODB.Connection")
db43.Open ConnString43

response.charset = "utf-8"
%>

<table border="1" width="100%">
    <tr>
        <td>Status</td>
        <td>Empresa</td>
        <td>Data</td>
        <td>Mes</td>
        <td>Ano</td>
        <td>Unidades</td>
        <td>Profissionais Ativos</td>
        <td>Profissionais Inativos</td>
        <td>Profissionais Externos</td>
        <td>Funcionários Ativos</td>
        <td>Funcionários Inativos</td>
        <td>Pacientes</td>
        <td>Agendamentos</td>
    </tr>
<%
response.buffer

c = 0

set l = db43.execute("select * from licencas")
while not l.eof
    response.Flush()
    ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server="& l("Servidor") &";Database=cliniccentral;uid=root;pwd=pipoca453;"
    Set db = Server.CreateObject("ADODB.Connection")
    db.Open ConnString

    sqlvcaBanco = "select i.table_name from information_schema.tables i where i.table_schema='clinic"& l("id") &"' and i.table_name='profissionais'"
    sqlProfissionaisAtivos = "select count(id) from clinic"& l("id") &".profissionais where ativo='on'"
    sqlProfissionaisInativos = "select count(id) from clinic"& l("id") &".profissionais where ativo=''"
    sqlProfissionaisExternos = "select count(id) from clinic"& l("id") &".profissionalexterno where sysActive=1"
    sqlFuncionariosAtivos = "select count(id) from clinic"& l("id") &".funcionarios where ativo='on'"
    sqlFuncionariosInativos = "select count(id) from clinic"& l("id") &".funcionarios where ativo=''"
    sqlPacientes = "select count(id) from clinic"& l("id") &".pacientes where sysActive=1"
    sqlAgendamentos = "select count(id) from clinic"& l("id") &".agendamentos"
    sqlUnidades = "select count(id) from clinic"& l("id") &".sys_financialcompanyunits where sysActive=1"
    sql = " select ("& sqlProfissionaisAtivos &") ProfissionaisAtivos, ("& sqlProfissionaisInativos &") ProfissionaisInativos, ("& sqlProfissionaisExternos &") ProfissionaisExternos, ("& sqlFuncionariosAtivos &") FuncionariosAtivos, ("& sqlFuncionariosInativos &") FuncionariosInativos, ("& sqlPacientes &") Pacientes, ("& sqlAgendamentos &") Agendamentos, (ifnull(("& sqlUnidades &"), 0)+1) Unidades"
    set vcaBanco = db.Execute( sqlvcaBanco )
    if not vcaBanco.eof then
        set q = db.execute( sql )
        if not q.eof then
            db43.execute("replace into estatisticas (id, Status, Empresa, DataHora, ProfissionaisAtivos, ProfissionaisInativos, ProfissionaisExternos, FuncionariosAtivos, FuncionariosInativos, Pacientes, Agendamentos, Unidades) values ('"& l("id") &"', '"& l("Status") &"', '"& rep(l("NomeContato") &" - "& l("NomeEmpresa")) &"', "& mydatetime(l("DataHora")) &", "& q("ProfissionaisAtivos") &", "& q("ProfissionaisInativos") &", "& q("ProfissionaisExternos") &", "& q("FuncionariosAtivos") &", "& q("FuncionariosInativos") &", "& q("Pacientes") &", "& q("Agendamentos") &", "& q("Unidades") &")")
            %>
            <tr>
                <td><%= l("Status") %></td>
                <td><%= l("NomeContato") &" - "& l("NomeEmpresa") %></td>
                <td><%= l("DataHora") %></td>
                <td><%= month(l("DataHora")) %></td>
                <td><%= year(l("DataHora")) %></td>
                <td><%= q("Unidades") %></td>
                <td><%= q("ProfissionaisAtivos") %></td>
                <td><%= q("ProfissionaisInativos") %></td>
                <td><%= q("ProfissionaisExternos") %></td>
                <td><%= q("FuncionariosAtivos") %></td>
                <td><%= q("FuncionariosInativos") %></td>
                <td><%= q("Pacientes") %></td>
                <td><%= q("Agendamentos") %></td>
            </tr>
            <%
        end if
    end if
l.movenext
wend
l.close
set l = nothing
%>
</table>
