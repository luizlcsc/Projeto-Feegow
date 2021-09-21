<!--#include file="connect.asp"-->
<%
Data=req("Data")
ProfissionalID=req("ProfissionalID")
UnidadeID=req("UnidadeID")
DiaSemana=weekday(Data)
Hora=req("Hora")

if UnidadeID<>"" then
    sqlUnidade = " AND loc.UnidadeID='"&UnidadeID&"'"
end if

sqlGrade = "SELECT id GradeID, Especialidades, Procedimentos, LocalID FROM (SELECT ass.id, Especialidades, Procedimentos, LocalID FROM assfixalocalxprofissional ass LEFT JOIN locais loc ON loc.id=ass.LocalID WHERE ProfissionalID="&treatvalzero(ProfissionalID)&" "& sqlUnidade&" AND DiaSemana="&DiaSemana&" AND "&mytime(Hora)&" BETWEEN HoraDe AND HoraA AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&")) UNION ALL SELECT ex.id*-1 id, Especialidades, Procedimentos, LocalID FROM assperiodolocalxprofissional ex LEFT JOIN locais loc ON loc.id=ex.LocalID WHERE ProfissionalID="&treatvalzero(ProfissionalID)&sqlUnidade&" AND DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&")t"

set GradeSQL = db.execute(sqlGrade)
if GradeSQL.eof then
    sqlGrade = "SELECT id GradeID, Especialidades, Procedimentos, LocalID FROM (SELECT ass.id, Especialidades, Procedimentos, LocalID FROM assfixalocalxprofissional ass LEFT JOIN locais loc ON loc.id=ass.LocalID WHERE ProfissionalID="&ProfissionalID&sqlUnidade&" AND DiaSemana="&DiaSemana&" AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&")) UNION ALL SELECT ex.id*-1 id, Especialidades, Procedimentos, LocalID FROM assperiodolocalxprofissional ex LEFT JOIN locais loc ON loc.id=ex.LocalID WHERE ProfissionalID="&ProfissionalID&sqlUnidade&" AND DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&")t ORDER BY 3 DESC"
    set GradeSQL = db.execute(sqlGrade)
end if


if not GradeSQL.eof then
    Especialidades = replace(GradeSQL("Especialidades")&"","|","")
    Procedimentos = GradeSQL("Procedimentos")
    LocalID=GradeSQL("LocalID")
    GradeID=GradeSQL("GradeID")

    if GradeID&"" <> "" then
        %>
        $("#GradeID").val("<%=GradeID%>");
        <%
    end if

    if Procedimentos<> "" then
        %>
        $("#ProcedimentoID").attr("data-exibir", '<%=Procedimentos%>');
        <%
    else
        %>
        $("#ProcedimentoID").attr("data-exibir", '');
        <%
    end if

    if not isnull(LocalID) then
        if ccur(LocalID)>0 then


            set LocalSQL = db.execute("SELECT NomeLocal FROM locais WHERE id="&LocalID)
            if not LocalSQL.eof then


    %>
    if($("#LocalID").val()=="0"){
        $("#LocalID").html("<option checked value='<%=LocalID%>' ><%=LocalSQL("NomeLocal")%></option>").select2();
    }
    <%
            end if
        end if
    end if

    if Especialidades&""<>"" then
        set EspecialidadesSQL = db.execute("SELECT id, especialidade FROM especialidades WHERE id IN ("&Especialidades&")")

        Opcoes = ""
        while not EspecialidadesSQL.eof
            Opcoes = Opcoes&"<option value='"&EspecialidadesSQL("id")&"'>"&EspecialidadesSQL("especialidade")&"</option>"
        EspecialidadesSQL.movenext
        wend
        EspecialidadesSQL.close
        set EspecialidadesSQL=nothing

        %>
        var EspecialidadeSelecionada = $("#EspecialidadeID").val();

        $("#EspecialidadeID").val("").html("<%=Opcoes%>").val(EspecialidadeSelecionada);
        <%

    end if
else

end if

%>