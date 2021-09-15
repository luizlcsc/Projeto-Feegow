<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Datas com grade diferenciada</span>
        <span class="panel-controls"><button type="button" onclick="ajxContent('Horarios-1&T=Profissionais', <%=ProfissionalID%>, 1, 'divHorarios');" class="btn btn-sm btn-system"><i class="far fa-calendar"></i> VOLTAR PARA GRADE ATUAL</button></span>
    </div>
    <div class="panel-body">
        <table class="table table-condensed table-striped">
            <thead>
                <tr>
                    <th>A partir de</th>
                    <th>Grade</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
        <%
        ProfissionalID = req("I")
        set pass = db.execute("select * from (	select distinct InicioVigencia from assfixalocalxprofissional where ProfissionalID="& ProfissionalID &"	UNION ALL	select distinct date_add(FimVigencia, interval 1 day) from assfixalocalxprofissional where ProfissionalID="& ProfissionalID &"	) t group by InicioVigencia order by InicioVigencia")
            while not pass.eof
                InicioVigencia = pass("InicioVigencia")
                IniVig = pass("InicioVigencia")
                if isnull(InicioVigencia) then
                    InicioVigencia = "Sempre"
                    IniVig = cdate("01/01/1900")
                end if
                %>
                <tr>
                    <td><%= InicioVigencia %></td>
                    <td>
                        <%
                        dia = 0
                        while dia<7
                            dia = dia+1
                            sql = "select * from assfixalocalxprofissional where ProfissionalID="& ProfissionalID &" and "
                            'set pgrade = db.execute( sql )

                        wend

                        if cstr(Inivig&"")="01/01/1900" then
                            Inivig = ""
                        end if
                        %>
                    </td>
                    <td><button type="button" onclick="ajxContent('Horarios-1&T=Profissionais&ViewDate=<%= IniVig %>', <%=ProfissionalID%>, 1, 'divHorarios');" class="btn btn-xs btn-alert"><i class="far fa-calendar"></i> GRADE COMPLETA</button></td>
                </tr>
                <%
            pass.movenext
            wend
            pass.close
            set pass=nothing
            %>
            </tbody>
        </table>
    </div>
</div>