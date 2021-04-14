<!--#include file="connect.asp"-->
<h1><%= req("Data") %></h1>
<%
'on error resume next

if session("Banco")<>"clinic5459" then response.end() end if

response.buffer
Data = req("Data")

c = 0
cl = 0

set l = db.execute("select * from cliniccentral.licencas where Status='C'")

while not l.eof
    ConnStringCli = "Driver={MySQL ODBC 8.0 ANSI Driver};Server="& l("Servidor") &";Database=cliniccentral;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
    Set dbCli = Server.CreateObject("ADODB.Connection")
    dbCli.Open ConnStringCli

    set vca = dbCli.execute("SELECT i.column_name FROM information_schema.columns i WHERE i.TABLE_SCHEMA='clinic"& l("id") &"' AND i.TABLE_NAME='procedimentos' AND i.COLUMN_NAME='ProcedimentoTelemedicina' LIMIT 1")

    if not vca.eof then
        sql = "select a.*, prof.NomeProfissional, proc.NomeProcedimento, pac.NomePaciente, pac.Tel1, pac.Tel2, pac.Cel1, pac.Cel2, pac.Email1, pac.Email2, pac.Nascimento from clinic"& l("id")&".agendamentos a left join clinic"& l("id")&".procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN clinic"& l("id")&".profissionais prof ON prof.id=a.ProfissionalID LEFT JOIN clinic"& l("id")&".pacientes pac ON pac.id=a.PacienteID where Data="& mydatenull(Data) &" AND proc.ProcedimentoTelemedicina='S' ORDER BY a.Hora"
        set a = dbCli.execute(sql)
        if not a.eof then
            cl = cl+1
        %>
        <div class="panel">
            <div class="panel-body">
                <h2><%= l("id") &" :: "& l("NomeEmpresa") &" :: "& l("NomeContato") %></h2>
                <table class="table">
                    <thead>
                        <tr>
                            <th width="1%"></th>
                            <th>Hora</th>
                            <th>Profissional</th>
                            <th>Paciente</th>
                            <th>Procedimento</th>
                            <th>Telefones</th>
                            <th>E-mails</th>
                            <th>Resultado</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    while not a.eof
                        response.flush()

                        c = c+1
                        %>
                        <tr>
                            <td><%= "<img src='assets/img/"& a("StaID") &".png' width='16'>" %></td>
                            <td><%= ft(a("Hora")) %></td>
                            <td><%= a("NomeProfissional") %></td>
                            <td><%= a("NomePaciente") %></td>
                            <td><%= a("NomeProcedimento") %></td>
                            <td><%= a("Tel1") &"&nbsp; &nbsp; &nbsp; "&a("Tel2") &"&&nbsp; &nbsp; &nbsp; "&a("Cel1") &"&&nbsp; &nbsp; &nbsp; "&a("Cel2") %></td>
                            <td><%= a("Email1") &"&nbsp; &nbsp; &nbsp; "&a("Email2") %></td>
                            <td><%= quickfield("memo", "", "", 12, "", "", "", "") %></td>
                        </tr>
                        <%
                    a.movenext
                    wend
                    a.close
                    set a=nothing
                    %>
                    </tbody>
                </table>
            </div>
        </div>
        <%
        end if
    end if
l.movenext
wend
l.close
set l=nothing

dbCli.close
set dbCli=nothing
%>
<%= cl &" licenças com "& c &" agendamentos." %>