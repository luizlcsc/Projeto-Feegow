<!--#include file="connect.asp"-->
<%
ProfissionalID = req("ProfissionalID")
EspecialidadeID = replace(req("EspecialidadeID"), "|", "")
ProcedimentoID = req("ProcedimentoID")
GradeID = req("GradeID")
UnidadeID = req("UnidadeID")

Data = req("data")
if isnull(Data) or Data="" then
    DiaSemana = weekday(date())
else
    DiaSemana = weekday(Data)
end if
Hora = req("horario")
Hora = left(Hora, 2) &":"& right(Hora, 2)
AgendamentoID = req("id")

if AgendamentoID<>"" and EspecialidadeID="" then
    set ag = db.execute("select EspecialidadeID from agendamentos where id="& AgendamentoID)
    if not ag.eof then
        EspecialidadeID = ag("EspecialidadeID")
    end if
end if

if EspecialidadeID&""="" then
   set ProcedimentoSQL = db.execute("SELECT SomenteEspecialidades FROM procedimentos WHERE id="&treatvalzero(ProcedimentoID))
   if not ProcedimentoSQL.eof then
        SomenteEspecialidades = replace(ProcedimentoSQL("SomenteEspecialidades")&"" , "|", "")
        if instr(SomenteEspecialidades, ",")=0 then
            EspecialidadeID=SomenteEspecialidades
        end if
   end if
end if
if ProfissionalID<>"" and isnumeric(ProfissionalID) then
    if GradeID<>"" and GradeID<>"undefined" then
        if GradeID > 0 then
            sql = "SELECT Especialidades FROM assfixalocalxprofissional WHERE id="&GradeID
        else
            sql = "SELECT Especialidades FROM assperiodolocalxprofissional WHERE id="&GradeID*-1
        end if
    else
        sql = "select group_concat(Especialidades) as `especialidades` from assfixalocalxprofissional where DiaSemana="& DiaSemana &" and HoraDe <= '"& Hora &"' and HoraA >= '"& Hora &"' and "& mydatenull(Data) &">=ifnull(InicioVigencia, '1899-01-01') and "& mydatenull(Data) &"<=ifnull(FimVigencia, '2999-01-01') and ProfissionalID="& ProfissionalID&" AND IFNULL(Especialidades,'')<>''"
    end if
    'response.Write( sql )
    sqlFiltraEspecialidadesGrade=""
    set pgrade = db.execute( sql )

    if not pgrade.eof then
        Especialidades = replace(pgrade("especialidades")&"", "|", "")

        if Especialidades<>"" then
            sqlFiltraEspecialidadesGrade= " AND esp.EspecialidadeID IN ("&Especialidades&")"
        end if
    end if

        'sql = "select group_concat(EspecialidadeID) Especialidades from (	select EspecialidadeID from profissionais where id="& ProfissionalID &" and not isnull(EspecialidadeID)		union all 	select EspecialidadeID from profissionaisespecialidades where profissionalID="& ProfissionalID &" and not isnull(EspecialidadeID)) esp"
        'response.write( sql )
        'set espMedico = db.execute( sql )
        'Especialidades = espMedico("Especialidades")&""
    sqlEsp = "select esp.EspecialidadeID id, e.especialidade from (select EspecialidadeID from profissionais where id="& ProfissionalID &" and not isnull(EspecialidadeID) union all	select EspecialidadeID from profissionaisespecialidades where profissionalID="& ProfissionalID &" and not isnull(EspecialidadeID)) esp left join especialidades e ON e.id=esp.EspecialidadeID "&_
                "WHERE TRUE "&sqlFiltraEspecialidadesGrade
    if sqlEsp<>"" then
        response.Write("<div class='row'>")
            if session("Banco")="clinic5760" then
                obrigatoriedade = " empty required "
                removeVazio = 1
            else
                obrigatoriedade = " semVazio "
                removeVazio = 0
            end if
            call quickfield("simpleSelect", "EspecialidadeID", "Especialidade", 12, EspecialidadeID, sqlEsp, "especialidade", " onchange=""$.each($('.linha-procedimento'), function(){ parametros('ProcedimentoID'+$(this).data('id'),$(this).find('select[data-showcolumn=\'NomeProcedimento\']').val()); })""  no-select2  "& obrigatoriedade)
            if removeVazio=1 then
                'NAO SEI POR QUE NAO FUNCIONA
                %>
                <script type="text-javascript">
                    setTimeout(function(){
                        if($('#EspecialidadeID').children('option').length==2){
                            $('#EspecialidadeID').children('option:first').remove();
                        }
                    }, 2000);
                </script>
                <%
            end if
        response.Write("</div>")
    end if

elseif req("EquipamentoID")="" then
    sqlEsp = "SELECT t.EspecialidadeID id, IFNULL(e.nomeEspecialidade, e.especialidade) especialidade FROM (	SELECT EspecialidadeID from profissionais WHERE ativo='on'	UNION ALL	select pe.EspecialidadeID from profissionaisespecialidades pe LEFT JOIN profissionais p on p.id=pe.ProfissionalID WHERE p.Ativo='on') t LEFT JOIN especialidades e ON e.id=t.EspecialidadeID WHERE NOT ISNULL(especialidade) GROUP BY t.EspecialidadeID ORDER BY especialidade"

    call quickfield("simpleSelect", "EspecialidadeID", "Especialidade", 12, EspecialidadeID, sqlEsp, "especialidade", " onchange=""$.each($('.linha-procedimento'), function(){ parametros('ProcedimentoID'+$(this).data('id'),$(this).find('select[data-showcolumn=\'NomeProcedimento\']').val()); })""  empty  no-select2 ")
end if
%>