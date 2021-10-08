<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
ProfissionalID = req("ProfissionalID")
Unidades = session("Unidades")

Operacao= req("Operacao")

if Operacao="Remover" then
    sqlDel = "delete from assPeriodoLocalXProfissional where id = '"&ref("GradeID")&"'"
    call gravaLogs(sqlDel, "AUTO", "", "ProfissionalID")
    db_execute(sqlDel)
    %>
    closeComponentsModal();
    showMessageDialog("Grade de exceção removida com sucesso.", "warning");
    ajxContent('Horarios-1&T=Profissionais', <%=ProfissionalID%>, 1, 'divHorarios');
    <%
    Response.end
elseif Operacao="Salvar" then

    DataDe=ref("DataDe")
    	DataA=ref("DataA")
    	HoraDe=ref("HoraDe")
    	HoraA=ref("HoraA")
    	LocalID=ref("LocalID")
    	Procedimentos=ref("Procedimentos")&""
    	Especialidades=ref("Especialidades")&""
    	Convenios=ref("Convenios")&""

    	Intervalo = ref("Intervalo")
    	Compartilhar = ref("Compartilhada")
        if ref("ProfissionalID")<>"" and ref("ProfissionalID")<>"0" then
            ProfissionalID = ref("ProfissionalID")
        end if

    	if not isdate(DataDe) or not isdate(DataA) or not isdate(HoraDe) or not isdate(HoraA) then
    		erro="Preencha as datas e horários com valores válidos."
    	else
    		if cdate(HoraDe)>=cdate(HoraA) then
    			erro="O horário inicial deve ser menor que o horário final."
    		end if
    		if cdate(DataDe)>cdate(DataA) then
    			erro="A data inicial deve ser menor ou igual &agrave; data final."
    		end if
    	end if
    	if erro="" then
            sqlInsert = "insert into assPeriodoLocalXProfissional (DataDe,DataA,HoraDe,HoraA,ProfissionalID,LocalID, Intervalo, Compartilhar, Procedimentos, Especialidades,Convenios) values ("&mydatenull(DataDe)&","&mydatenull(DataA)&",'"&HoraDe&"','"&HoraA&"', "&treatvalzero(ProfissionalID)&", "&treatvalzero(LocalID)&", '"&Intervalo&"','"&Compartilhar&"', '"&Procedimentos&"', '"&Especialidades&"','"&Convenios&"')"
            db_execute(sqlInsert)

            call gravaLogs(sqlInsert, "AUTO", "", "ProfissionalID")
            %>

            closeComponentsModal();
            showMessageDialog("Grade de exceção criada com sucesso.", "success");
            ajxContent('Horarios-1&T=Profissionais', <%=ProfissionalID%>, 1, 'divHorarios');
            <%

        else
            %>
            showMessageDialog("<%=erro%>");
            <%
        end if

    Response.end
else
%>
<div class="row">

    <%=quickfield("datepicker", "DataDe", "De", 3, date(), "", "", "") %>
    <%=quickfield("datepicker", "DataA", "Até", 3, date(), "", "", "") %>
    <%=quickfield("timepicker", "HoraDe", "Das", 3, "08:00", "", "", "") %>
    <%=quickfield("timepicker", "HoraA", "Às", 3, "18:00", "", "", "") %>
    <div class="col-md-6">
        <label>Intervalo (min)</label><br />
        <input type="number" name="Intervalo" class="form-control" size="5" maxlength="5" value="15" min="1" />
    </div>
    <input type="hidden" name="ProfissionalID" id="ProfissionalID" value="<%=ProfissionalID %>" />

    <%
    response.write(quickField("simpleSelect", "LocalID", "Local", 6, LocalID, "select l.*, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where COALESCE(cliniccentral.overlap(CONCAT('|',l.UnidadeID,'|'),COALESCE(NULLIF('"&Unidades&"',''),'-999')),TRUE) AND  l.sysActive=1 "&sqlUnidades&" order by l.NomeLocal", "NomeLocal", "required"))
    %>

    <%=quickField("multiple", "Procedimentos", "Procedimentos", 3, Procedimentos, "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' "&franquia("AND CASE WHEN procedimentos.OpcoesAgenda IN (4,5) THEN COALESCE(NULLIF(SomenteProfissionais,'') LIKE '%|"&req("ProfissionalID")&"|%',TRUE) ELSE TRUE END")&" order by OpcoesAgenda desc, NomeProcedimento", "NomeProcedimento", "")%>

    <%=quickField("multiple", "Especialidades", "Especialidades", 4, Especialidades, "select id, especialidade from especialidades where sysActive=1 and id in (SELECT EspecialidadeID FROM profissionais WHERE profissionais.id = "&req("ProfissionalID")&" UNION SELECT EspecialidadeID FROM profissionaisespecialidades WHERE profissionaisespecialidades.ProfissionalID = "&req("ProfissionalID")&") order by especialidade", "especialidade", "")%>
    <%
    sqlConvenios = "select 'P' id, ' PARTICULAR' NomeConvenio UNION ALL select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' AND COALESCE((SELECT CASE WHEN SomenteConvenios LIKE '%|NONE|%' THEN FALSE ELSE NULLIF(SomenteConvenios,'') END FROM profissionais  WHERE id = "&treatvalzero(ProfissionalID)&") LIKE CONCAT('%|',id,'|%'),TRUE) "&franquia("AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('"&Unidades&"',''),'-999')),TRUE)")&" order by NomeConvenio"
    %>
    <%=quickField("multiple", "Convenios", "Convênios", 4, Convenios, sqlConvenios, "NomeConvenio", "")%>

    <div class="col-md-6">
        <input type="checkbox" class="ace" name="Compartilhada" id="Compartilhada" value="S" style="margin-left:5px" checked="">
        <label for="Compartilhada">Compartilhar esta grade para agendamentos externos</label>
    </div>

</div>
<script>
    <!--#include file="jQueryFunctions.asp"-->
</script>
<%
end if
%>
<!--#include file="disconnect.asp"-->
