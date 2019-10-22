<!--#include file="connect.asp"-->
<style type="text/css">
    td, th {
        font-size: 7pt;
        padding:3px!important;
    }
</style>

<h2 class="text-center">Taxa de Ocupação</h2>

<%
'server.ScriptTimeout = 200

db.execute("delete from rel_ocupacao where sysUser="& session("User"))
response.Buffer

if ref("De")="" then
    De=date()
else
    De=cdate(ref("De"))
end if
if ref("Ate")="" then
    Ate=date()+7
else
    Ate=cdate(ref("Ate"))
end if

sqlLimitarProfissionais =""
if lcase(session("table"))="funcionarios" then
     set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
     if not FuncProf.EOF then
     profissionais=FuncProf("Profissionais")
        if not isnull(profissionais) and profissionais<>"" then
            profissionaisExibicao = replace(profissionais, "|", "")
            sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
        end if
     end if
elseif lcase(session("table"))="profissionais" then
     set FuncProf = db.execute("SELECT AgendaProfissionais FROM profissionais WHERE id="&session("idInTable"))
     if not FuncProf.EOF then
     profissionais=FuncProf("AgendaProfissionais")
        if not isnull(profissionais) and profissionais<>"" then
            profissionaisExibicao = replace(profissionais, "|", "")
            sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
        end if
     end if
end if

if session("Banco")="clinic5760" or session("Banco")="clinic6118" or session("Banco")="clinic5968" or session("Banco")="clinic6259" then
    'sUnidadeID = "|"& session("UnidadeID") &"|"
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1)"
else
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia)NomeLocal FROM empresa WHERE id=1) UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits WHERE sysActive=1) UNION ALL (SELECT concat('G', id) id, concat('Grupo: ', NomeGrupo) NomeLocal from locaisgrupos where sysActive=1 order by NomeGrupo) UNION ALL (select l.id, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where l.sysActive=1 order by l.NomeLocal)"
end if

if ref("De")="" then
%>

        <form target="_blank" id="frmFiltros" method="post" action="PrintStatement.asp?R=OcupacaoMultipla">
            <div class="row">
                <%'=quickField("select", "filtroProcedimentoID", "Procedimento", 2, "", "select '' id, '-' NomeProcedimento UNION ALL select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' and OpcoesAgenda!=3 order by NomeProcedimento", "NomeProcedimento", " empty ") %>
                <%'=quickField("multiple", "Profissionais", "Profissionais", 2, ref("Profissionais"), "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais WHERE (NaoExibirAgenda != 'S' OR NaoExibirAgenda is null OR NaoExibirAgenda='') AND sysActive=1 and Ativo='on' "&sqlLimitarProfissionais&" ORDER BY NomeProfissional)t ORDER BY Ordem, NomeProfissional", "NomeProfissional", " empty ") %>
                <%=quickField("multiple", "Especialidade", "Especialidades", 2, ref("Especialidade"), "SELECT t.EspecialidadeID id, IFNULL(e.nomeEspecialidade, e.especialidade) especialidade FROM (	SELECT EspecialidadeID from profissionais WHERE ativo='on'	UNION ALL	select pe.EspecialidadeID from profissionaisespecialidades pe LEFT JOIN profissionais p on p.id=pe.ProfissionalID WHERE p.Ativo='on') t LEFT JOIN especialidades e ON e.id=t.EspecialidadeID WHERE NOT ISNULL(especialidade) AND e.sysActive=1 GROUP BY t.EspecialidadeID ORDER BY especialidade", "especialidade", " empty required ") %>
                <%'=quickField("multiple", "Convenio", "Convênios", 2, "", "select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' order by NomeConvenio", "NomeConvenio", " empty ") %>
                <%'=quickField("empresaMultiIgnore", "Unidades", "Unidades", 2, "", "", "", "") %>
                <%=quickField("multiple", "Locais", "Locais", 2, ref("Locais"), sqlAM, "NomeLocal", " empty ") %>
                <%'=quickField("multiple", "Equipamentos", "Equipamentos", 2, "", "SELECT id, NomeEquipamento FROM equipamentos WHERE sysActive=1 and Ativo='on' ORDER BY NomeEquipamento", "NomeEquipamento", " empty ") %>
                <%=quickField("datepicker", "De", "De", 2, De, "", "", "") %>
                <%=quickField("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
                <div class="col-md-2">
                    <button class="btn mt25 btn-primary">Gerar</button>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 text-center">
                    <button id="buscar" class="btn btn-primary hidden mt10 btn-block" onclick="$(this).addClass('hidden')"><i class="fa fa-search"></i> BUSCAR</button>
                </div>
            </div>
        </form>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->
</script>

<%
else
    'CONTEÚDO DA AGENDAMULTIPLACONTEUDO
    Profissionais = "0"
    De = cdate(ref("De"))
    Ate = cdate(ref("Ate"))
    'Especialidades = ref("Especialidade") quando voltar ao normal por busca como na agenda
    splrfesp = split(ref("Especialidade"), ", ")
    ProcedimentoID = ref("filtroProcedimentoID")
    'rfEspecialidade = ref("Especialidade")
    rfProfissionais = ref("Profissionais")
    rfConvenio = ref("Convenio")
    rfLocais = ref("Locais")

    for k=0 to ubound(splrfesp)
        Especialidades = splrfesp(k)
        rfEspecialidade = Especialidades
                Data = De
                while Data<=Ate
                    refLocais = rfLocais
                    DiaSemana = weekday(Data)
                    Mes = month(Data)
                    '-> procedimento filtrado selecionado
                    if ProcedimentoID<>"" then
                        sqlProcFiltro = "select ifnull(OpcoesAgenda, 0) OpcoesAgenda, SomenteProfissionais, SomenteEquipamentos, SomenteEspecialidades, SomenteLocais, EquipamentoPadrao from procedimentos where id="&ProcedimentoID

                        set proc = db.execute(sqlProcFiltro)
                        if not proc.eof then
                            OpcoesAgenda=proc("OpcoesAgenda")
                            if OpcoesAgenda="4" or OpcoesAgenda="5" then
                                SomenteProfissionais = proc("SomenteProfissionais")&""
                                SomenteProfissionais = replace(SomenteProfissionais, ",", "")
                                SomenteProfissionais = replace(SomenteProfissionais, " ", "")
                                splSomProf = split(SomenteProfissionais, "|")
                                SomenteProfissionais = ""
                                for i=0 to ubound(splSomProf)
                                    if isnumeric(splSomProf(i)) and splSomProf(i)<>"" then
                                        SomenteProfissionais = SomenteProfissionais & "," & splSomProf(i)
                                    end if
                                next
                                SomenteEspecialidades = proc("SomenteEspecialidades")&""
                            end if
                            EquipamentoPadrao = proc("EquipamentoPadrao")

                            SomenteEquipamentos = proc("SomenteEquipamentos")

                            if EquipamentoPadrao&""<>"" then
                                EquipamentoPadrao="|"&EquipamentoPadrao&"|"

                                if SomenteEquipamentos&""="" then
                                    SomenteEquipamentos=EquipamentoPadrao
                                else
                                    SomenteEquipamentos=SomenteEquipamentos&","&EquipamentoPadrao
                                end if
                            end if

                            SomenteLocais = proc("SomenteLocais")&""
                            if instr(SomenteProfissionais, ",")>0 then
                                'Profissionais = replace(SomenteProfissionais, "||", ",")
                                'Profissionais = replace(Profissionais, ", , ", ", ")
                                'Profissionais = replace(Profissionais, "|", "")
                                Profissionais = SomenteProfissionais

                                if left(Profissionais, 1)="," then
                                    Profissionais = right(Profissionais, len(Profissionais)-1)
                                end if


                                if Profissionais&""<>"" then
                                    sqlProfissionais = " t.ProfissionalID IN("& Profissionais &") "
                                end if
                            end if
                            if instr(SomenteEspecialidades, "|")>0 then
                                set GroupConcat = db.execute("SET SESSION group_concat_max_len = 1000000;")
                                set profesp = db.execute("select group_concat(pro.id) Profissionais from profissionais pro LEFT JOIN profissionaisespecialidades pe on pe.ProfissionalID=pro.id where pro.EspecialidadeID IN("& replace(SomenteEspecialidades, "|", "") &") or pe.EspecialidadeID IN("& replace(SomenteEspecialidades, "|", "") &")")

                                sqlEspecialidades = ""
                                if not profesp.eof then
                                    ProfissionaisEspecialidade = profesp("Profissionais")
                                    if trim(ProfissionaisEspecialidade&"") <> "" then
                                        sqlEspecialidades = " t.ProfissionalID IN ("&ProfissionaisEspecialidade&") "
                                    end if
                                end if
                            end if
        
                            if sqlProfissionais<>"" and sqlEspecialidades<>"" then
                                if OpcoesAgenda="4" then
                                    sqlProfesp = " AND ("&sqlProfissionais&" OR "&sqlEspecialidades&") "
                                else
                                    sqlProfesp = " AND ("&sqlProfissionais&" AND "&sqlEspecialidades&") "
                                end if
                            elseif sqlProfissionais="" and sqlEspecialidades<>"" then
                                sqlProfesp = " AND "&sqlEspecialidades&" "
                            elseif sqlProfissionais<>"" and sqlEspecialidades="" then
                                sqlProfesp = " AND "&sqlProfissionais&" "
                            end if

                            sqlProfissionais = ""

                            if instr(SomenteLocais, "|")=0 then
                                SomenteLocais = ""
                            end if

                            sqlProcedimentosGrade = " AND (Procedimentos LIKE '%|"&ProcedimentoID&"|%' OR Procedimentos is null or Procedimentos='') "
                        end if
                    end if

                    if ProcedimentoID<>"" then
                        set EspecialidadesPermitidasNoProcedimentoSQL = db.execute("SELECT SomenteEspecialidades FROM procedimentos WHERE id="&treatvalzero(ProcedimentoID))
                        if not EspecialidadesPermitidasNoProcedimentoSQL.eof then
                            ProcedimentoSomenteEspecialidades = EspecialidadesPermitidasNoProcedimentoSQL("SomenteEspecialidades")
                        end if
                        sqlProcedimentosGrade = " AND (Procedimentos LIKE '%|"&ProcedimentoID&"|%' OR Procedimentos is null or Procedimentos='') "
                    end if

                    if ProcedimentoSomenteEspecialidades<>"" then
                        if Especialidades="" then
                            Especialidades = ProcedimentoSomenteEspecialidades
                        else
                            Especialidades = Especialidades&", "&ProcedimentoSomenteEspecialidades
                        end if
                    end if

                    if Especialidades<>""  then
                        spltEspecialidades = split(Especialidades, ", ")

                        sqlGradeEspecialidade = " AND (Especialidades is null or Especialidades='' "

                        for i=0 to ubound(spltEspecialidades)
                            EspecialidadeID=spltEspecialidades(i)

                            sqlGradeEspecialidade =  sqlGradeEspecialidade&" OR Especialidades LIKE '%"&EspecialidadeID&"%'"
                        next
                        sqlGradeEspecialidade=sqlGradeEspecialidade&")"
                    end if
                    '<- procedimento filtrado selecionado
                    if instr(refLocais, "UNIDADE_ID")>0 then
                        UnidadesIDs=""
                        spltLocais = split(refLocais, ",")
                        refLocais=""
                        for i=0 to ubound(spltLocais)
                            if instr(spltLocais(i),"UNIDADE_ID") > 0 then
                                if i>0 then
                                    UnidadesIDs = UnidadesIDs&","
                                end if
                                UnidadesIDs= UnidadesIDs& replace(replace(spltLocais(i),"UNIDADE_ID",""),"|","")
                            else
                                if i>0 then
                                    refLocais = refLocais&","
                                end if
                                refLocais = refLocais&spltLocais(i)
                            end if
                        next
                        sqlUnidades = " AND t.LocalID IN (select concat(l.id) from locais l where l.UnidadeID IN ("& UnidadesIDs &")) "
                    end if
                    if rfEspecialidade<>"" then
                        leftEsp = " LEFT JOIN profissionaisespecialidades e on e.ProfissionalID=p.id "
                        sqlEspecialidadesSel = " AND (p.EspecialidadeID IN ("& replace(rfEspecialidade, "|", "") &") OR e.EspecialidadeID IN ("& replace(rfEspecialidade, "|", "") &") ) "
                        fieldEsp = " , e.EspecialidadeID EspecialidadeAd "
                    end if

                    if rfProfissionais<>"" then
                        sqlProfissionais = " AND p.id IN ("& replace(rfProfissionais, "|", "") &") "
                    else
                    've se deve seprar por paciente
                         sqlProfissionais =""
                        if lcase(session("table"))="funcionarios" then
                             set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
                             if not FuncProf.EOF then
                                profissionais=FuncProf("Profissionais")
                                if not isnull(profissionais) and profissionais<>"" then
                                    profissionaisExibicao = replace(profissionais, "|", "")
                                    if profissionaisExibicao<>"" then
                                        sqlProfissionais = " AND p.id IN ("&profissionaisExibicao&")"
                                    end if
                                end if
                             end if
                        elseif lcase(session("table"))="profissionais" then
                             set FuncProf = db.execute("SELECT AgendaProfissionais FROM profissionais WHERE id="&session("idInTable"))
                             if not FuncProf.EOF then
                                profissionais=FuncProf("AgendaProfissionais")
                                if not isnull(profissionais) and profissionais<>"" then
                                    profissionaisExibicao = replace(profissionais, "|", "")
                                    if profissionaisExibicao<>"" then
                                        sqlProfissionais = " AND p.id IN ("&profissionaisExibicao&")"
                                    end if
                                end if
                             end if
                        end if
                    end if

                    if rfConvenio<>"" then
                        splConv = split(rfConvenio, ", ")
                        for i=0 to ubound(splConv)
                            loopConvenios = loopConvenios & " OR p.SomenteConvenios LIKE '%|"& splConv(i) &"|%'"'
                        next
                        sqlConvenios = " AND (ISNULL(p.SomenteConvenios) OR p.SomenteConvenios LIKE '' "& loopConvenios &") "
                    end if
                    sql = ""

                    sqlOrder = " ORDER BY NomeProfissional"
                    if session("Banco") = "clinic935" then
                        sqlOrder = " ORDER BY OrdemAgenda DESC"
                    end if
                    sql = "select t.ProfissionalID, p.EspecialidadeID, t.LocalID, IF (p.NomeSocial IS NULL OR p.NomeSocial='', p.NomeProfissional, p.NomeSocial) NomeProfissional, p.ObsAgenda, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select Especialidades, ProfissionalID, LocalID from assfixalocalxprofissional WHERE HoraDe !='00:00:00' AND DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&") "&sqlProcedimentosGrade&sqlEspecialidadesGrade&") UNION ALL select '', ProfissionalID, LocalID from assperiodolocalxprofissional WHERE DataDe<="& mydatenull(Data) &" and DataA>="& mydatenull(Data) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda))  "& sqlEspecialidadesSel & sqlProfissionais & sqlConvenios & sqlProfesp & sqlGradeEspecialidade& sqlUnidades &" GROUP BY t.ProfissionalID"&sqlOrder


                    sqlVerme = "select t.FrequenciaSemanas, t.InicioVigencia, t.FimVigencia, t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.NomeProfissional, p.ObsAgenda, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select Especialidades, FrequenciaSemanas, InicioVigencia, FimVigencia, ProfissionalID, LocalID from assfixalocalxprofissional WHERE DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR (DATE_FORMAT(InicioVigencia ,'%Y-%m-01') <= "&mydatenull(Data)&")) AND (FimVigencia IS NULL OR (DATE_FORMAT(FimVigencia ,'%Y-%m-30') >= "&mydatenull(Data)&" )))) t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda)) "& sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlGradeEspecialidade &sqlProfesp & sqlUnidades &" "

                    sqlVermePer = "select t.DataDe, t.DataA, t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.SomenteConvenios "& fieldEsp &" from (select ProfissionalID, LocalID, DataDe, DataA from assperiodolocalxprofissional WHERE DataDe>="& mydatenull( DiaMes("P", Data ) )&" AND DataA<="& mydatenull( DiaMes("U", Data) ) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda)) "& sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlProfesp & sqlUnidades

                    sql = replace(sql, "[DiaSemana]", DiaSemana)

                    '-> BUSCANDO SE TEM GRADE
                    set comGrade = db.execute( sql )
                    if comGrade.eof then
                        %>
                        <%
                    end if
                    cProf = 0
                    while not comGrade.eof
                        response.Flush()
                        '-> namAGENDA
                        ProfissionalID = comGrade("ProfissionalID")
                        if (session("Banco")="clinic5760" or session("Banco")="clinic6118" or session("Banco")="clinic5968" or session("Banco")="clinic105" or session("Banco")="clinic6259") and instr(ref("Locais"), "UNIDADE_ID")>0 then
                            UnidadesIN = replace(replace(ref("Locais"), "UNIDADE_ID", ""), "|", "'")
                            sqlUnidadesHorarios = " AND l.UnidadeID IN("& UnidadesIN &") "
                            joinLocaisUnidades = " LEFT JOIN locais l ON l.id=a.LocalID "
                            whereLocaisUnidades = " AND l.UnidadeID IN("& UnidadesIN &") "
                        end if

                        if ProcedimentoID<>"" then
                            set EspecialidadesPermitidasNoProcedimentoSQL = db.execute("SELECT SomenteEspecialidades FROM procedimentos WHERE id="&treatvalzero(ProcedimentoID))
                            if not EspecialidadesPermitidasNoProcedimentoSQL.eof then
                                ProcedimentoSomenteEspecialidades = EspecialidadesPermitidasNoProcedimentoSQL("SomenteEspecialidades")
                            end if
                            sqlProcedimentosGrade = " AND (Procedimentos LIKE '%|"&ProcedimentoID&"|%' OR Procedimentos is null or Procedimentos='') "
                        end if

                        if ProcedimentoSomenteEspecialidades<>"" then
                            if Especialidades="" then
                                Especialidades = ProcedimentoSomenteEspecialidades
                            else
                                Especialidades = Especialidades&", "&ProcedimentoSomenteEspecialidades
                            end if
                        end if

                        if Especialidades<>""  then
                            spltEspecialidades = split(Especialidades, ", ")

                            sqlGradeEspecialidade = " AND (ass.Especialidades is null or ass.Especialidades='' "

                            for i=0 to ubound(spltEspecialidades)
                                EspecialidadeID=spltEspecialidades(i)

                                sqlGradeEspecialidade =  sqlGradeEspecialidade&" OR ass.Especialidades LIKE '%"&EspecialidadeID&"%'"
                            next
                            sqlGradeEspecialidade=sqlGradeEspecialidade&")"
                        end if

                        Hora = cdate("00:00")
                        set Horarios = db.execute("select ass.*, l.UnidadeID, '0' TipoGrade, '0' GradePadrao, '' Procedimentos from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" "&sqlUnidadesHorarios & sqlProcedimentosGrade& sqlGradeEspecialidade &" order by HoraDe")
                        if Horarios.EOF then
                            set Horarios = db.execute("select ass.*, l.UnidadeID, '1' GradePadrao from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) "&sqlUnidadesHorarios & sqlProcedimentosGrade& sqlGradeEspecialidade &" order by ass.HoraDe")
                        end if
                        sqlInsertV = ""
                        if not Horarios.eof then
                            while not Horarios.EOF
                                LocalID = Horarios("LocalID")
                                UnidadeID = Horarios("UnidadeID")
                                Procedimentos = Horarios("Procedimentos")&""


                                MostraGrade=True

                                if Horarios("GradePadrao")=1 then
                                    FrequenciaSemanas = Horarios("FrequenciaSemanas")
                                    InicioVigencia = Horarios("InicioVigencia")

                                    if FrequenciaSemanas>1 then
                                        NumeroDeSemanaPassado = datediff("w",InicioVigencia,Data)
                                        RestoDivisaoNumeroSemana = NumeroDeSemanaPassado mod FrequenciaSemanas

                                        if RestoDivisaoNumeroSemana>0 then
                                            MostraGrade=False
                                        end if
                                    end if
                                end if


                                if MostraGrade then
                                    cProf = cProf+1
                                    'TITULO DA GRADE
                                    'response.write("<br> -> P: "& ProfissionalID &" ("& comGrade("NomeProfissional") &") L: "& LocalID &" U: "& UnidadeID &"</br>")
                                    if Horarios("TipoGrade")=0 then
                                        GradeID=Horarios("id")
                                        if Horarios("GradePadrao")="0" then
                                            GradeID=GradeID*-1
                                        end if
                                        Intervalo = Horarios("Intervalo")
                                        LocalID = Horarios("LocalID")
                                        if isnull(Intervalo) or Intervalo=0 then
                                            Intervalo = 30
                                        end if
                                        HoraDe = cdate(Horarios("HoraDe"))
		                                if isnull(Horarios("HoraA")) then
			                                HoraA = HoraDe
		                                else
			                                HoraA = cdate(Horarios("HoraA"))
		                                end if
                                        ProfissionalID = Horarios("ProfissionalID")
                                        if isnull(ProfissionalID) then
                                            ProfissionalID = 0
                                        end if
		                                if instr(Profissionais, "|"&ProfissionalID&"|")=0 and ProfissionalID<>0 then
			                                Profissionais = Profissionais&"|"&ProfissionalID&"|"
		                                end if

                                        Bloqueia = ""
                                        if Procedimentos<>"" and session("RemSol")<>"" then
                                            set procRem = db.execute("select TipoCompromissoID from agendamentos where id="& session("RemSol"))
                                            if not procRem.eof then
                                                if instr(Procedimentos, "|"& procRem("TipoCompromissoID") &"|")=0 then
                                                    Bloqueia = "S"
                                                end if
                                            end if
                                        end if

                                        Hora = HoraDe
                                        while Hora<=HoraA
                                            HoraID = formatdatetime(Hora, 4)
                                            HoraID = replace(HoraID, ":", "")
                                            'HORARIO VAZIO
                                            'response.Write("<button class='btn btn-xs btn-primary'>V: "& ft(Hora) &" P: "& ProfissionalID &" L: "& LocalID &" G: "& GradeID &"</button>")
                                            'db.execute("insert into rel_ocupacao set sysUser="& session("User") &", Data="& mydatenull(Data) &", Hora="& mytime(Hora) &", Situacao='V', ProfissionalID="& treatvalzero(ProfissionalID) &", EspecialidadeID="& replace(Especialidades, "|", "") &", LocalID="& treatvalzero(LocalID) &", UnidadeID="& treatvalzero(UnidadeID))
                                            sqlInsertV = sqlInsertV & ", ("& session("User") &", "& mydatenull(Data) &", "& mytime(Hora) &", 'V', "& treatvalzero(ProfissionalID) &", "& replace(Especialidades, "|", "") &", "& treatvalzero(LocalID) &", "& treatvalzero(UnidadeID) &")"
                                            Hora = dateadd("n", Intervalo, Hora)
                                        wend
                                    else
                                        txtHorarios = Horarios("Horarios")&""
                                        if instr(txtHorarios, ",") then
                                            splHorarios = split(txtHorarios, ",")
                                            for ih=0 to ubound(splHorarios)
                                                HoraPers = trim(splHorarios(ih))
                                                if isdate(HoraPers) then
				                                    HLivres = HLivres+1
                                                    HoraID = horaToID(HoraPers)
                                                    'db.execute("insert into rel_ocupacao set sysUser="& session("User") &", Data="& mydatenull(Data) &", Hora="& mytime(HoraPers) &", Situacao='V', ProfissionalID="& treatvalzero(ProfissionalID) &", EspecialidadeID="& replace(Especialidades, "|", "") &", LocalID="& treatvalzero(LocalID) &", UnidadeID="& treatvalzero(UnidadeID))
                                                sqlInsertV = sqlInsertV & ", ("& session("User") &", "& mydatenull(Data) &", "& mytime(HoraPers) &", 'V', "& treatvalzero(ProfissionalID) &", "& replace(Especialidades, "|", "") &", "& treatvalzero(LocalID) &", "& treatvalzero(UnidadeID) &")"
                                                end if
                                            next
                                        end if
                                    end if
                                end if
                            Horarios.movenext
                            wend
                            Horarios.close
                            set Horarios=nothing

                            if sqlInsertV<>"" then
                                sqlInsertV = right(sqlInsertV, len(sqlInsertV)-1)
                                db.execute("insert into rel_ocupacao (sysUser, Data, Hora, Situacao, ProfissionalID, EspecialidadeID, LocalID, UnidadeID) VALUES "& sqlInsertV)
                            end if

                            IF 1 THEN
                            set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.Encaixe, a.Tempo from agendamentos a " & joinLocaisUnidades &_
                            "where a.ProfissionalID="&ProfissionalID&" and a.Data="&mydatenull(Data) & whereLocaisUnidades &"order by Hora")
                            while not comps.EOF
                                HoraComp = HoraToID(comps("Hora"))
                                compsHora = comps("Hora")
                                LocalID = comps("LocalID")
	                            if not isnull(compsHora) then
		                            compsHora = formatdatetime(compsHora, 4)
	                            end if

                                Tempo = 0
                                ValorProcedimentosAnexos = 0

                                'soma o tempo dos procedimentos anexos
                                if VariosProcedimentos<>"" and instr(VariosProcedimentos, ",") then
                                    set ProcedimentosAnexosTempoSQL = db.execute("SELECT sum(Tempo)Tempo, sum(IF(rdValorPlano='V',ValorPlano,0))Valor FROM agendamentosprocedimentos WHERE Tempo IS NOT NULL AND AgendamentoID="&comps("id"))
                                    if not ProcedimentosAnexosTempoSQL.eof then
                                        if not isnull(ProcedimentosAnexosTempoSQL("Tempo")) then
                                            Tempo = Tempo + ccur(ProcedimentosAnexosTempoSQL("Tempo"))
                                        end if
                                        if not isnull(ProcedimentosAnexosTempoSQL("Valor")) then
                                            ValorProcedimentosAnexos = ValorProcedimentosAnexos + ccur(ProcedimentosAnexosTempoSQL("Valor"))
                                        end if
                                    end if
                                end if

	                            '->hora final
	                            if not isnull(comps("Tempo")) and comps("Tempo")<>"" and isnumeric(comps("Tempo")) then
		                            Tempo = Tempo + ccur(comps("Tempo"))
	                            else
		                            Tempo = 0
	                            end if
	                            Horario = comps("Hora")
	                            if isdate(Horario) and Horario<>"" then
		                            HoraFinal = dateadd("n", Tempo, Horario)
		                            HoraFinal = formatdatetime( HoraFinal, 4 )
		                            HoraFinal = HoraToID(HoraFinal)
		                            if HoraFinal<=HoraComp then
			                            HoraFinal = Horario
		                            end if
	                            else
		                            HoraFinal = Horario
	                            end if
	                            '<-hora final
                            
                                StaID = comps("StaID")
                                if StaID<>11 and StaID<>22 then
                                    db.execute("DELETE FROM rel_ocupacao WHERE sysUser="& session("User") &" AND Situacao='V' AND Data="& mydatenull(Data) &" AND ProfissionalID="& treatvalnull(ProfissionalID) &" AND Hora BETWEEN "& mytime(Horario) &" AND "& mytime(HoraFinal))
                                end if
                                db.execute("INSERT INTO rel_ocupacao SET sysUser="& session("User") &", Data="& mydatenull(Data) &", Hora="& mytime(Horario) &", StaID="& StaID &", Situacao='A', ProfissionalID="& treatvalzero(ProfissionalID) &", EspecialidadeID="& replace(Especialidades, "|", "") &", LocalID="& treatvalzero(LocalID) &", UnidadeID="& treatvalzero(UnidadeID))
                            '                            set vcaPL = db.execute("select id from rel_ocupacao where sysUser="& session("User") &" AND Data="& mydatenull(Data) &" AND Situacao='V' AND ProfissionalID="& treatvalnull(ProfissionalID) &" AND LocalID="& treatvalnull(LocalID))
                            '                            if vcaPL.eof then
                            '                                set vcaPL = db.execute("select id from rel_ocupacao where sysUser="& session("User") &" AND Data="& mydatenull(Data) &" AND Situacao='V' AND ProfissionalID="& treatvalnull(ProfissionalID))
                            '                            end if
                            '                            while not vcaPL.eof
                            '                                if ft(vcaPL("Hora"))=ft(comps("Hora")) and ( StaID<>11 and StaID<>22) ) then
                            '                                    db.execute("update rel_ocupacao SET StaID="& StaID &", Situacao='A' WHERE")
                            '                                end if
                            '                            vcaPL.movenext
                            '                            wend
                            '                            vcaPL.close
                            '                            set vcaPL = nothing

                            comps.movenext
                            wend
                            comps.close
                            set comps = nothing
                            END IF

    bloqueioSql = "select c.HoraDe, c.HoraA from compromissos c where (c.ProfissionalID="& treatvalnull(ProfissionalID) &" or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"& treatvalnull(ProfissionalID)&"%|'))) AND (c.Unidades LIKE '%|"&UnidadeID&"|%' or c.Unidades='' or c.Unidades is null) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"
    'response.Write( bloqueioSql )
    set bloq = db.execute(bloqueioSql)

    while not bloq.EOF

    HoraDe = bloq("HoraDe")
    HoraA = bloq("HoraA")
        db.execute("UPDATE rel_ocupacao SET Situacao='B' WHERE sysUser="& session("User") &" AND Data="& mydatenull(Data) &" AND ProfissionalID="& treatvalnull(ProfissionalID) &" AND Hora BETWEEN "& mytime(HoraDe) &" AND "& mytime(HoraA) &" AND Situacao='V'")
    HBloqueados = HBloqueados + 1

    bloq.movenext
    wend
    bloq.close
    set bloq=nothing

     end if 


                    '<- namAGENDA
                    comGrade.movenext
                    wend
                    comGrade.close
                    set comGrade=nothing


                


                    Data = Data+1
                wend
            next
        end if
        %>


        <%
        'set u = db.execute("select distinct UnidadeID FROM rel_ocupacao WHERE sysUser="& session("User"))
        'while not u.eof
        splU = split(ref("Locais"), ", ")
        for j=0 to Ubound(splU)
            UnidadeID = replace(replace(splU(j), "UNIDADE_ID", ""), "|", "")
		    if UnidadeID="0" then
			    set un = db.execute("select NomeFantasia from empresa")
		    else
			    set un = db.execute("select NomeFantasia from sys_financialcompanyunits where id="& UnidadeID )
		    end if
		    if un.EOF then
			    NomeUnidade = ""
		    else
			    NomeUnidade = un("NomeFantasia")
		    end if


            %>
            <h1><%= NomeUnidade %></h1>
            <table class="table table-hover table-bordered table-condensed" _excel-name="<%= NomeUnidade %>">
                <thead>
                    <tr class="info">
                        <th></th>
                        <%
                        De = cdate(ref("De"))
                        Ate = cdate(ref("Ate"))
                        Data = De
                        while Data<=Ate
                            %>
                            <th class="text-center" colspan="5"><%= Data %></th>
                            <%
                            Data = Data+1
                        wend
                        %>
                        <th class="text-center success" colspan="5">TOTAL</th>
                    </tr>
                    <tr class="info">
                        <th></th>
                        <%
                        De = cdate(ref("De"))
                        Ate = cdate(ref("Ate"))
                        Data = De
                        while Data<=Ate
                            %>
                            <th>TOT</th>
                            <th>LIV</th>
                            <th>BLQ</th>
                            <th>AGE</th>
                            <th>OCU</th>
                            <%
                            Data = Data+1
                        wend
                        %>
                        <th class="success">TOT. </th>
                        <th class="success">TOT. LIV</th>
                        <th class="success">TOT. BLQ</th>
                        <th class="success">TOT. AGE</th>
                        <th class="success">TOT. OCU</th>
                    </tr>
                </thead>
            <%
            'set distEsp = db.execute("SELECT DISTINCT esp.Especialidade, ro.EspecialidadeID FROM rel_ocupacao ro LEFT JOIN especialidades esp ON esp.id=ro.EspecialidadeID ORDER BY esp.Especialidade")
            set distEsp = db.execute("SELECT id EspecialidadeID, Especialidade FROM especialidades WHERE id IN("& replace(ref("Especialidade"), "|", "") &") ORDER BY Especialidade")
            while not distEsp.eof
                %>
                <tr>
                    <th><%= distEsp("Especialidade") %></th>
                    <%
                    De = cdate(ref("De"))
                    Ate = cdate(ref("Ate"))
                    Data = De
                    VTotal = 0
                    ATotal = 0
                    BTotal = 0
                    TTotal = 0

                    while Data<=Ate
                        sqlConta = "select (select count(id) from rel_ocupacao where EspecialidadeID="& distEsp("EspecialidadeID") &" AND sysUser="& session("User") &" AND UnidadeID="& UnidadeID &" AND Data="& mydatenull(Data) &" AND Situacao='V') V, "&_
                        "(select count(id) from rel_ocupacao where EspecialidadeID="& distEsp("EspecialidadeID") &" AND UnidadeID="& UnidadeID &" AND sysUser="& session("User") &" AND Data="& mydatenull(Data) &" AND Situacao='A') A, "&_
                        "(select count(id) from rel_ocupacao where EspecialidadeID="& distEsp("EspecialidadeID") &" AND UnidadeID="& UnidadeID &" AND sysUser="& session("User") &" AND Data="& mydatenull(Data) &" AND Situacao='B') B"
                        'response.write( sqlConta &"<br>")
                        set conta = db.execute( sqlConta )
                        V = ccur(conta("V"))
                        A = ccur(conta("A"))
                        B = ccur(conta("B"))
                        T = V+A+B

                        VTotal = VTotal + V
                        ATotal = ATotal + A
                        BTotal = BTotal + B
                        TTotal = TTotal + T

                        TotalUtil = T-B
                        if TotalUtil>0 then
                            O = A/TotalUtil
                        else
                            O = 0
                        end if
                        %>
                        <td><%= T %></td>
                        <td><%= V %></td>
                        <td><%= B %></td>
                        <td><%= A %></td>
                        <td><%= formatnumber(O * 100, 0) %>%</td>
                        <%
                        Data = Data+1
                    wend
                    %>
                    <td><%= TTotal %></td>
                    <td><%= VTotal%></td>
                    <td><%= BTotal %></td>
                    <td><%= ATotal  %></td>
                    <td><%= "" %></td>
                </tr>
                <%
            distEsp.movenext
            wend
            distEsp.close
            set distEsp = nothing
            %>

            </table>
            <%
        next
        'u.movenext
        'wend
        'u.close
        'set u = nothing
        %>
