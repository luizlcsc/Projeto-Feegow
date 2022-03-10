<%
'server.ScriptTimeout = 200
d = req("debug")
if d="1" then
    d=True
else
    d=False
end if

User = session("User")

function debugMessage(msg)
    if d then
        dd(msg)
    end if
end function

'ATENÇÃO: ESTA FUNÇÃO NÃO BUSCA SEM ESPECIALIDADE!!!
function ocupacao(De, Ate, refEspecialidade, reffiltroProcedimentoID, rfProfissionais, rfConvenio, rfLocais, ConsiderarEspecialidadeReal)
    De = cdate(De)
    Ate = cdate(Ate)


    set AgendamentosNaoPagosSQL = db_execute("SELECT GROUP_CONCAT(id) agendamentosNaoPagos FROM agendamentos WHERE FormaPagto = 9 AND DATE_ADD(sysDate, INTERVAL 15 MINUTE) < now()  and sysActive = 1 AND CanalID=1 AND StaID=1;")

    if not AgendamentosNaoPagosSQL.eof then
        agendamentosNaoPagos = AgendamentosNaoPagosSQL("agendamentosNaoPagos")&""

        if agendamentosNaoPagos<>"" then
            db.execute("UPDATE agendamentos SET sysActive = -1 WHERE FormaPagto = 9 AND id in ("&agendamentosNaoPagos&");")
        end if
    end if

    db.execute("delete from agenda_horarios where sysUser="& treatvalzero(session("User")))
    response.Buffer
    profissionais=rfProfissionais

    sqlLimitarProfissionais =""

    if User&"" = "" then
        if lcase(session("table"))="funcionarios" then
             set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
             if not FuncProf.EOF then
             profissionaisExibicao=FuncProf("Profissionais")
                if not isnull(profissionaisExibicao) and profissionaisExibicao<>"" then
                    profissionaisExibicao = replace(profissionaisExibicao, "|", "")
                    sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
                end if
             end if

        elseif lcase(session("table"))="profissionais" then
             set FuncProf = db.execute("SELECT AgendaProfissionais FROM profissionais WHERE id="&session("idInTable"))
             if not FuncProf.EOF then
             profissionaisExibicao=FuncProf("AgendaProfissionais")
                if not isnull(profissionaisExibicao) and profissionaisExibicao<>"" then
                    profissionaisExibicao = replace(profissionaisExibicao, "|", "")
                    sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
                end if
             end if
        end if
    end if


    if refEspecialidade="" and rfProfissionais<>"" then
        sqlEsp2 = "SELECT group_concat(EspecialidadeID SEPARATOR ', ')EspecialidadeID FROM ( "&_
                   "SELECT EspecialidadeID FROM profissionais WHERE id IN ("&rfProfissionais&") "&_
                   "UNION ALL "&_
                   "SELECT EspecialidadeID FROM profissionaisespecialidades WHERE ProfissionalID IN ("&rfProfissionais&") "&_
                   ") t"

        set ProfissionalSQL = db.execute(sqlEsp2)
        if not ProfissionalSQL.eof then
            refEspecialidade=ProfissionalSQL("EspecialidadeID")&""
        end if
    else
        Profissionais = "0"
    end if


    ProcedimentoID = reffiltroProcedimentoID

    if ProcedimentoID<>"" then
        sqlProcFiltro = "select ifnull(OpcoesAgenda, 0) OpcoesAgenda, SomenteProfissionais, SomenteEquipamentos, SomenteEspecialidades, SomenteLocais, EquipamentoPadrao from procedimentos where id="&ProcedimentoID


        set proc = db.execute(sqlProcFiltro)
        if not proc.eof then

            OpcoesAgenda=proc("OpcoesAgenda")

            if OpcoesAgenda="4" or OpcoesAgenda="5" then
                SomenteProfissionais = proc("SomenteProfissionais")&""
                SomenteProfissionais = replace(SomenteProfissionais, ",", "")
                SomenteProfissionais = replace(SomenteProfissionais, " ", "")

                SomenteEspecialidades = proc("SomenteEspecialidades")&""
                SomenteEspecialidades = replace(SomenteEspecialidades, "|", "")
                SomenteEspecialidades = replace(SomenteEspecialidades, " ", "")

                splSomProf = split(SomenteProfissionais, "|")
                SomenteProfissionais = ""
                for i=0 to ubound(splSomProf)
                    if isnumeric(splSomProf(i)) and splSomProf(i)<>"" then
                        SomenteProfissionais = SomenteProfissionais & "," & splSomProf(i)
                    end if
                next
                
                if refEspecialidade="" and SomenteEspecialidades<>"" then
                    refEspecialidade=SomenteEspecialidades
                end if
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

            if SomenteEspecialidades&"" <> "" then
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
        if SomenteEspecialidades="" then
            SomenteEspecialidades = ProcedimentoSomenteEspecialidades
        else
            SomenteEspecialidades = SomenteEspecialidades&", "&ProcedimentoSomenteEspecialidades
        end if
    end if


    splrfesp = split(refEspecialidade, ", ")

    for k=0 to ubound(splrfesp)
            EspecialidadeID = replace(splrfesp(k), "|","")
            rfEspecialidade = EspecialidadeID
            if ConsiderarEspecialidadeReal and SomenteEspecialidades="" then
                ZerarEspecialidadeAoFinalDoLoop = True ' :(
                SomenteEspecialidades = "|"&EspecialidadeID&"|"
            end if

            Data = De

                while Data<=Ate
                    refLocais = rfLocais
                    DiaSemana = weekday(Data)
                    Mes = month(Data)
                    '-> procedimento filtrado selecionado


                    if SomenteEspecialidades<>""  then
                        spltEspecialidades = split(SomenteEspecialidades, ", ")

                        sqlGradeEspecialidade = " AND (Especialidades is null or Especialidades='' "

                        for i=0 to ubound(spltEspecialidades)
                            EspecialidadeIDLoop=spltEspecialidades(i)

                            sqlGradeEspecialidade =  sqlGradeEspecialidade&" OR Especialidades LIKE '%"&EspecialidadeIDLoop&"%'"
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

                    if rfProfissionais<>"" and rfProfissionais&""<>"0" then
                        sqlProfissionais = " AND p.id IN ("& replace(rfProfissionais, "|", "") &") "
                    else

                    've se deve seprar por paciente
                         sqlProfissionais =""
                        if lcase(session("table"))="funcionarios" then
                             set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
                             if not FuncProf.EOF then
                                profissionaisExibicao=FuncProf("Profissionais")
                                if not isnull(profissionaisExibicao) and profissionaisExibicao<>"" then
                                    profissionaisExibicao = replace(profissionaisExibicao, "|", "")
                                    if profissionaisExibicao<>"" and profissionaisExibicao&""<>"0" then
                                        sqlProfissionais = " AND p.id IN ("&profissionaisExibicao&")"
                                    end if
                                end if
                             end if
                        elseif lcase(session("table"))="profissionais" then
                             set FuncProf = db.execute("SELECT AgendaProfissionais FROM profissionais WHERE id="&session("idInTable"))
                             if not FuncProf.EOF then
                                profissionaisExibicao=FuncProf("AgendaProfissionais")
                                if not isnull(profissionaisExibicao) and profissionaisExibicao<>"" then
                                    profissionaisExibicao = replace(profissionaisExibicao, "|", "")
                                    if profissionaisExibicao<>"" and profissionaisExibicao&""<>"0" then
                                        sqlProfissionais = " AND p.id IN ("&profissionaisExibicao&")"
                                    end if
                                end if
                             end if
                        end if

                    end if

                    if rfProfissionais<>"" then
                        rfProfissionais=replace(rfProfissionais,"||","|,|")
                    end if

                    if rfConvenio<>"" then
                        splConv = split(rfConvenio, ", ")
                        for i=0 to ubound(splConv)
                            loopConvenios = loopConvenios & " OR p.SomenteConvenios LIKE '%|"& splConv(i) &"|%'"'
                        next
                        sqlConvenios = sqlConvenios&" AND (ISNULL(p.SomenteConvenios) OR p.SomenteConvenios LIKE '' "& loopConvenios &") "
                        sqlConvenios = sqlConvenios&" AND (ISNULL(t.Convenios) OR t.Convenios LIKE '' OR t.Convenios LIKE '%"&rfConvenio&"%') "
                    end if
                    sql = ""

                    sqlOrder = " ORDER BY NomeProfissional"
                    if session("Banco") = "clinic935" then
                        sqlOrder = " ORDER BY OrdemAgenda DESC"
                    end if
                    sql = "select t.ProfissionalID, p.EspecialidadeID, t.LocalID, IF (p.NomeSocial IS NULL OR p.NomeSocial='', p.NomeProfissional, p.NomeSocial) NomeProfissional, p.ObsAgenda, p.Cor, Especialidades,  p.SomenteConvenios "& fieldEsp &" from (select Especialidades, ProfissionalID, LocalID, Convenios from assfixalocalxprofissional WHERE HoraDe !='00:00:00' AND DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&") "&sqlProcedimentosGrade&sqlEspecialidadesGrade&") UNION ALL select Especialidades, ProfissionalID, LocalID, '' Convenios from assperiodolocalxprofissional WHERE DataDe<="& mydatenull(Data) &" and DataA>="& mydatenull(Data) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda))  "& sqlEspecialidadesSel & sqlProfissionais & sqlConvenios & sqlProfesp & sqlGradeEspecialidade& sqlUnidades &" GROUP BY t.ProfissionalID"&sqlOrder
                    sqlVerme = "select t.FrequenciaSemanas, t.InicioVigencia, t.FimVigencia, t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.NomeProfissional, p.ObsAgenda, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select Especialidades, FrequenciaSemanas, InicioVigencia, FimVigencia, ProfissionalID, LocalID, Convenios from assfixalocalxprofissional WHERE DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR (DATE_FORMAT(InicioVigencia ,'%Y-%m-01') <= "&mydatenull(Data)&")) AND (FimVigencia IS NULL OR (DATE_FORMAT(FimVigencia ,'%Y-%m-30') >= "&mydatenull(Data)&" )))) t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda)) "& sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlGradeEspecialidade &sqlProfesp & sqlUnidades &" "

                    sqlVermePer = "select t.DataDe, t.DataA, t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.SomenteConvenios "& fieldEsp &" from (select ProfissionalID, LocalID, DataDe, DataA, '' Convenios from assperiodolocalxprofissional WHERE DataDe>="& mydatenull( DiaMes("P", Data ) )&" AND DataA<="& mydatenull( DiaMes("U", Data) ) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda)) "& sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlProfesp & sqlUnidades

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


                        'if (session("Banco")="clinic5760" or session("Banco")="clinic6118" or session("Banco")="clinic5968" or session("Banco")="clinic105" or session("Banco")="clinic6259" or session("Banco")="clinic6629") and instr(rfLocais, "UNIDADE_ID")>0 then
                        if instr(rfLocais, "UNIDADE_ID")>0 then
                            UnidadesIN = replace(replace(rfLocais, "UNIDADE_ID", ""), "|", "")
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
                            if SomenteEspecialidades="" then
                                SomenteEspecialidades = ProcedimentoSomenteEspecialidades
                            else
                                SomenteEspecialidades = SomenteEspecialidades&", "&ProcedimentoSomenteEspecialidades
                            end if
                        end if
                        if SomenteEspecialidades="" AND refEspecialidade<>"" and instr(refEspecialidade, ",")=0 then
                            SomenteEspecialidades = refEspecialidade
                        end if

                        Hora = cdate("00:00")
                        '!!!X
                        set Horarios = db.execute("select ass.intervalo, ass.LocalID, ass.Procedimentos, ass.id, ass.HoraDe, ass.HoraA, ass.ProfissionalID, l.UnidadeID, '0' TipoGrade, '0' GradePadrao, '' Procedimentos, Especialidades, '' Horarios, ass.Compartilhar Compartilhada from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" "&sqlUnidadesHorarios & sqlProcedimentosGrade& sqlGradeEspecialidade &" order by HoraDe")
                        if Horarios.EOF then
                            set Horarios = db.execute("select ass.Especialidades, ass.intervalo, ass.FrequenciaSemanas, ass.InicioVigencia, ass.LocalID, ass.Procedimentos, ass.id, ass.HoraDe, ass.HoraA, ass.ProfissionalID, ass.TipoGrade, l.UnidadeID, '1' GradePadrao, Horarios, ass.Compartilhada from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) "&sqlUnidadesHorarios & sqlProcedimentosGrade& sqlGradeEspecialidade &" order by ass.HoraDe")
                        end if
                        sqlInsertV = ""
                        EspecialidadesGrade=""
						txtGradeOriginal = ""
                        if not Horarios.eof then
                            while not Horarios.EOF
                                LocalID = Horarios("LocalID")
                                Compartilhada = Horarios("Compartilhada")
                                if Compartilhada="S" then
                                    ExibeAgendamentoOnline=1
                                else
                                    ExibeAgendamentoOnline=0
                                end if
                                UnidadeID = Horarios("UnidadeID")
                                Procedimentos = Horarios("Procedimentos")&""
                                EspecialidadesGrade = Horarios("Especialidades")&""


                                if UnidadeID&"" <> "" then
                                    sqlUnidadesBloqueio = sqlUnidadesBloqueio&" OR c.Unidades LIKE '%|"&UnidadeID&"|%'"
                                end if

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
                                        if Horarios("GradePadrao")&""="0" then
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
		                                    horarioAFix = (formatdatetime(Horarios("HoraA"), 4))
                                            ultimoValorMinuto = Mid(horarioAFix,Len(horarioAFix)-0,1)

			                                HoraA = cdate(Horarios("HoraA"))
                                            if ultimoValorMinuto <> "9" then
                                                HoraA = cdate(dateAdd("n", 1, Horarios("HoraA")))
                                            end if
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
											txtGradeOriginal = txtGradeOriginal &"|"& ft(Hora) &"|"
                                            HoraID = formatdatetime(Hora, 4)
                                            HoraID = replace(HoraID, ":", "")
                                            'HORARIO VAZIO

                                            sqlInsertV = sqlInsertV & ", ("& treatvalzero(session("User")) &", "& mydatenull(Data) &", "& mytime(Hora) &", 'V', "& treatvalzero(ProfissionalID) &", "& EspecialidadeID &", "& treatvalzero(LocalID) &", "& treatvalzero(UnidadeID) &", "& Horarios("TipoGrade") &", "& treatvalnull(GradeID) &", 1, "&ExibeAgendamentoOnline&")"

                                            Hora = dateadd("n", Intervalo, Hora)
                                        wend
                                    else
                                        txtHorarios = Horarios("Horarios")&""
                                        if instr(txtHorarios, ",") then
                                            splHorarios = split(txtHorarios, ",")
                                            for ih=0 to ubound(splHorarios)
                                                HoraPers = trim(splHorarios(ih))
                                                if isdate(HoraPers) then
													txtGradeOriginal = txtGradeOriginal &"|"& ft(HoraPers) &"|"
				                                    HLivres = HLivres+1
                                                    HoraID = horaToID(HoraPers)

                                                sqlInsertV = sqlInsertV & ", ("& treatvalzero(session("User")) &", "& mydatenull(Data) &", "& mytime(HoraPers) &", 'V', "& treatvalzero(ProfissionalID) &", "& EspecialidadeID &", "& treatvalzero(LocalID) &", "& treatvalzero(UnidadeID) &", "& Horarios("TipoGrade") &", "& treatvalnull(GradeID) &", 1, "&ExibeAgendamentoOnline&")"
                                                end if
                                            next
                                        end if
                                    end if
                                end if
                            Horarios.movenext
                            wend
                            Horarios.close
                            set Horarios=nothing

							'response.write( "1. "& txtGradeOriginal &"<br>")

                            if sqlInsertV<>"" then
                                sqlInsertV = right(sqlInsertV, len(sqlInsertV)-1)
                                sqlI ="insert into agenda_horarios (sysUser, Data, Hora, Situacao, ProfissionalID, EspecialidadeID, LocalID, UnidadeID, TipoGrade, GradeID, GradeOriginal,ExibeAgendamentoOnline) VALUES "& sqlInsertV
                                db.execute(sqlI)
                            end if

                            IF 1 THEN
                            whereEspecialidadesAgendamentos=""

                            if ConsiderarEspecialidadeReal then
                                whereEspecialidadesAgendamentos = " AND a.EspecialidadeID="&EspecialidadeID
                            end if

                            set comps=db.execute("select a.EspecialidadeID, a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.Encaixe, a.Tempo from agendamentos a " & joinLocaisUnidades &_
                            "where a.ProfissionalID="&ProfissionalID&" and a.Data="&mydatenull(Data) & whereLocaisUnidades &whereEspecialidadesAgendamentos &" and a.sysActive=1 order by Hora")
                            while not comps.EOF
                                HoraComp = HoraToID(comps("Hora"))
                                EspecialidadeIDAgendada = comps("EspecialidadeID")
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
	                                if Tempo>1 then
	                                    Tempo=Tempo-1
	                                end if

		                            HoraFinal = dateadd("n", Tempo, Horario)
		                            HoraFinal = formatdatetime( HoraFinal, 4 )
		                            'HoraFinal = HoraToID(HoraFinal)
		                            if HoraFinal<=HoraComp then
			                            HoraFinal = Horario
		                            end if

	                            else
		                            HoraFinal = Horario
	                            end if
	                            '<-hora final


                                LiberaInsert=False
                                if EspecialidadesGrade <> "" then
                                   ' response.write(EspecialidadesGrade)
                                   ' response.write("//")
                                   ' response.write(EspecialidadeIDAgendada)
                                   ' response.write("---------")
                                    if instr(EspecialidadesGrade, "|"&EspecialidadeIDAgendada&"|")>0 then

                                        LiberaInsert = True
                                    end if
                                else
                                    LiberaInsert=True
                                end if

                                StaID = comps("StaID")
                                if StaID<>11 and StaID<>22 and LiberaInsert then
                                    sqlDel = "DELETE FROM agenda_horarios WHERE sysUser="& treatvalzero(session("User")) &" AND Situacao='V' AND Data="& mydatenull(Data) &" AND ProfissionalID="& treatvalnull(ProfissionalID) &" AND Hora BETWEEN "& mytime(Horario) &" AND "& mytime(HoraFinal)
                                    'response.write( sqlDel &"<br>")
                                    db.execute( sqlDel )
                                end if

								if instr(txtGradeOriginal, "|"& ft(Horario) &"|")>0 AND StaID<>11 AND StaID<>22 then
									GradeOriginal = 1
									txtGradeOriginal = replace(txtGradeOriginal, "|"& ft(Horario) &"|", "")
								else
									GradeOriginal = "NULL"
								end if


                                sqlGradeExcecao = "select id, Compartilhar from assperiodolocalxprofissional where  '"&horario&"' BETWEEN HoraDe  AND HoraA  AND  " & mydatenull(Data) & " BETWEEN DataDe AND DataA  AND ProfissionalID=" &treatvalnull(ProfissionalID) & " ORDER BY 1  "
                                set GradeExcecaoSQL = db.execute(sqlGradeExcecao)

                                sqlGradeId=""
                                ExibeAgendamentoOnline=1

                                if not GradeExcecaoSQL.eof then
                                    sqlGradeId = ", GradeID="&treatvalnull(GradeExcecaoSQL("id")*-1)
                                    if GradeExcecaoSQL("Compartilhar")="S" then
                                        ExibeAgendamentoOnline=1
                                    else
                                        ExibeAgendamentoOnline=0
                                    end if
                                else
                                    sqlGradePadrao0 = "select id, Compartilhada from assfixalocalxprofissional where DiaSemana = " & DiaSemana & " AND HoraDe <= " & mytime(horario) & " AND HoraA >= "  &  mytime(horario) &  " AND ( (InicioVigencia <= " &mydatenull(Data)& " OR InicioVigencia IS NULL) AND (FimVigencia >= " &mydatenull(Data)& " OR FimVigencia  IS NULL) )  AND ProfissionalID=" &treatvalzero(ProfissionalID)& " ORDER BY 1 "
                                    set GradePadraoSQL = db.execute(sqlGradePadrao0)

                                    if not GradePadraoSQL.eof then
                                        sqlGradeId = ", GradeID="&treatvalnull(GradePadraoSQL("id"))
                                        if GradePadraoSQL("Compartilhada")="S" then
                                            ExibeAgendamentoOnline=1
                                        else
                                            ExibeAgendamentoOnline=0
                                        end if
                                    end if
                                end if



                            if LiberaInsert then
                                db.execute("INSERT INTO agenda_horarios SET AgendamentoID="&treatvalzero(comps("id"))&", sysUser="& treatvalzero(session("User")) &", Data="& mydatenull(Data) &", Hora="& mytime(Horario) &", StaID="& StaID &", Situacao='A', ProfissionalID="& treatvalzero(ProfissionalID) &", EspecialidadeID="& EspecialidadeID &", LocalID="& treatvalzero(LocalID) &", UnidadeID="& treatvalzero(UnidadeID) &", ExibeAgendamentoOnline="&treatvalzero(ExibeAgendamentoOnline)&",Encaixe="& treatvalnull(comps("Encaixe")) &", GradeOriginal="& GradeOriginal & sqlGradeId)
                            '                            set vcaPL = db.execute("select id from agenda_horarios where sysUser="& treatvalzero(session("User")) &" AND Data="& mydatenull(Data) &" AND Situacao='V' AND ProfissionalID="& treatvalnull(ProfissionalID) &" AND LocalID="& treatvalnull(LocalID))
                            '                            if vcaPL.eof then
                            '                                set vcaPL = db.execute("select id from agenda_horarios where sysUser="& treatvalzero(session("User")) &" AND Data="& mydatenull(Data) &" AND Situacao='V' AND ProfissionalID="& treatvalnull(ProfissionalID))
                            '                            end if
                            '                            while not vcaPL.eof
                            '                                if ft(vcaPL("Hora"))=ft(comps("Hora")) and ( StaID<>11 and StaID<>22) ) then
                            '                                    db.execute("update agenda_horarios SET StaID="& StaID &", Situacao='A' WHERE")
                            '                                end if
                            '                            vcaPL.movenext
                            '                            wend
                            '                            vcaPL.close
                            '                            set vcaPL = nothing
                                else
                                    db.execute("UPDATE agenda_horarios SET Situacao='A',Encaixe="&treatvalnull(comps("Encaixe"))&",AgendamentoID="&treatvalzero(comps("id"))&" where sysUser="& treatvalzero(session("User")) &" AND Data="& mydatenull(Data) &" AND Hora="& mytime(Horario) &" AND Situacao='V' AND ProfissionalID="& treatvalzero(ProfissionalID) &" and EspecialidadeID="& EspecialidadeID)
                                end if
                            comps.movenext
                            wend
                            comps.close
                            set comps = nothing
                        END IF

    if ProfissionalID&""="" then
        ProfissionalID="0"
    else
        ProfissionalID= replace(ProfissionalID, ",00", "")
    end if
    bloqueioSql = "select c.HoraDe, c.HoraA, c.Profissionais, c.id from compromissos c where (c.ProfissionalID='"& ProfissionalID &"' or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"& ProfissionalID&"%|'))) AND (c.Unidades LIKE '%|"&UnidadeID&"|%' or c.Unidades='' or c.Unidades is null) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"
   ' response.Write( bloqueioSql )
    set bloq = db.execute(bloqueioSql)

    while not bloq.EOF

        HoraDe = bloq("HoraDe")
        HoraA = bloq("HoraA")
        BloqueioID = bloq("id")

        sqlUP = "UPDATE agenda_horarios SET BloqueioID="&treatvalzero(BloqueioID)&", Situacao='B', GradeOriginal=if(GradeOriginal=1, 2, NULL) WHERE sysUser="& treatvalzero(session("User")) &" AND Data="& mydatenull(Data) &" AND ProfissionalID="& treatvalnull(ProfissionalID) &" AND Hora BETWEEN "& mytime(HoraDe) &" AND "& mytime(HoraA) &" AND Situacao IN('V', 'A')"

        'response.write( sqlUP &" -> "& bloq("Profissionais") &"<br>")
        sqlProfissionalBloq = "ProfissionalID="& treatvalnull(ProfissionalID)
        ProfissionaisBloq = bloq("Profissionais")&""
        if ProfissionaisBloq<>"" then
            ProfissionaisBloq = replace(ProfissionaisBloq, "|", "")
            sqlProfissionalBloq = sqlProfissionalBloq & " OR ProfissionalID IN("& ProfissionaisBloq &") "
        end if

        sqlUP = "UPDATE agenda_horarios SET BloqueioID="&treatvalzero(BloqueioID)&",Situacao='B', GradeOriginal=if(GradeOriginal=1, 2, NULL) WHERE sysUser="& treatvalzero(session("User")) &" AND Data="& mydatenull(Data) &" AND ("& sqlProfissionalBloq &") AND Hora BETWEEN "& mytime(HoraDe) &" AND "& mytime(HoraA) &" AND Situacao IN('V', 'A')"
        db.execute( sqlUP )

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
                    if ZerarEspecialidadeAoFinalDoLoop then
                        SomenteEspecialidades=""
                    end if
                wend
            next

'                            response.Write( "2. "& txtGradeOriginal )
end function
%>