<%
function ocupacao(De, Ate, refEspecialidade, reffiltroProcedimentoID, idsProfissionais, rfConvenio, rfLocais, refEspecializacaoID, CarrinhoID, Apagar, sessaoAgenda)

    De = cdate(De)
    Ate = cdate(Ate)
    parCarrinhoID = ""
    ProcedimentoID = reffiltroProcedimentoID
    rfEspecialidade = refEspecialidade
    Data = De

    if CarrinhoID&"" <> "" then
       parCarrinhoID = CarrinhoID
    end if

    if Apagar <> "nao" then
        db.execute("delete from agenda_horarios where sysUser="& treatvalzero(session("User"))&" AND sessaoAgenda='"&sessaoAgenda&"'" )
        response.Buffer
    end if
        
    if ProcedimentoID<>"" then
        sqlProcFiltro = "SELECT * FROM (SELECT ifnull(OpcoesAgenda, 0) OpcoesAgenda, CONCAT('|',GROUP_CONCAT(DISTINCT ppu.id_profissional SEPARATOR '|,|'),'|') SomenteProfissionais, SomenteEquipamentos, SomenteEspecialidades, SomenteLocais, EquipamentoPadrao from procedimentos pro JOIN procedimento_profissional_unidade ppu ON ppu.id_procedimento = pro.id where ppu.id_unidade IS NOT NULL AND pro.id="&ProcedimentoID&") t WHERE t.SomenteProfissionais IS NOT NULL"
        'response.write("<pre>DETALHES DO PROCEDIMENTO - "&sqlProcFiltro&"</pre>")
        set proc = db.execute(sqlProcFiltro)

        if not proc.eof then

            set GroupConcat = db.execute("SET SESSION group_concat_max_len = 1000000;")

            profespSQL = " SELECT GROUP_CONCAT(DISTINCT pro.id) Profissionais "&_
                            " FROM procedimento_profissional_unidade ppu "&_
                            " JOIN profissionais pro ON pro.id = ppu.id_profissional"&_
                            " JOIN procedimentos p ON p.id = ppu.id_procedimento"&_
                            " LEFT JOIN profissionaissubespecialidades psub ON psub.ProfissionalID = pro.id"&_
                            " WHERE ppu.id_unidade IS NOT NULL AND ppu.id_procedimento = "&ProcedimentoID  
            'response.write("<pre>DETALHES DO PROFISSIONAL - "&profespSQL&"</pre>")

            if refEspecializacaoID<>"" then
                profespSQL = profespSQL&" AND psub.subespecialidadeid = "&refEspecializacaoID
            end if

            if idsProfissionais<>"" then
                profespSQL = profespSQL&" AND ppu.id_profissional = "&idsProfissionais
            end if

            set profesp = db.execute(profespSQL)
            
            'response.write("<pre>PROFISSIONAIS PELA ESPECIALIDADE - "&profespSQL&"</pre>")
            
            sqlProfesp = ""

            if not profesp.eof then
                ProfissionaisEspecialidade = profesp("Profissionais")

                if trim(ProfissionaisEspecialidade&"") <> "" then
                    sqlProfesp = " AND ProfissionalID IN ("&ProfissionaisEspecialidade&") "
                end if
            end if

            sqlProfissionais = ""

            if instr(SomenteLocais, "|")=0 then
                SomenteLocais = ""
            end if
        end if
    end if

    while Data<=Ate

        refLocais = rfLocais
        DiaSemana = weekday(Data)
        Mes = month(Data)
        sqlProfissionais = ""
     
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
            'response.write("<pre>UNIDADES - "&sqlUnidades&"</pre>")
        end if

        if idsProfissionais<>"" and idsProfissionais&""<>"0" then
            sqlProfissionais = " AND p.id IN ("& replace(idsProfissionais, "|", "") &") "
            'response.write("<pre>"&sqlProfissionais&"</pre>")
        else
            sqlProfissionais =""

            if lcase(session("table"))="funcionarios" then
                    set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
                    if not FuncProf.EOF then
                        profissionais=FuncProf("Profissionais")
                        if not isnull(profissionais) and profissionais<>"" then
                            profissionaisExibicao = replace(profissionais, "|", "")
                            if profissionaisExibicao<>"" and profissionaisExibicao&""<>"0" then
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
                        if profissionaisExibicao<>"" and profissionaisExibicao&""<>"0" then
                            sqlProfissionais = " AND p.id IN ("&profissionaisExibicao&")"
                        end if
                    end if
                end if
            end if
        end if
'response.write("<pre> a "&sqlProfissionais&"</pre>")
        if idsProfissionais<>"" then
            idsProfissionais=replace(idsProfissionais,"||","|,|")
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

        'sqlProfissionais = ""

        sql = "SELECT concat(t.ProfissionalID,' ') as ProfissionalID, "&_
                "       p.EspecialidadeID, "&_
                "       t.LocalID, "&_ 
                "       IF (p.NomeSocial IS NULL OR p.NomeSocial='', p.NomeProfissional, p.NomeSocial) NomeProfissional, "&_ 
                "       p.ObsAgenda, "&_ 
                "       p.Cor, "&_ 
                "       Especialidades, "&_ 
                "       p.SomenteConvenios "&_ 
                "  FROM (SELECT Especialidades, "&_ 
                "               ProfissionalID, "&_ 
                "               LocalID, "&_ 
                "               Convenios "&_ 
                "          FROM assfixalocalxprofissional ass "&_
                "          JOIN procedimento_profissional_unidade ppu ON ppu.id_profissional = ass.ProfissionalID "&_
                "         WHERE (HoraDe !='00:00:00' OR HoraDe IS NULL AND GradeEncaixe = 'S')  "&_
                "           AND DiaSemana="&DiaSemana&" "&_ 
                "           AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&") AND ppu.id_procedimento = "&ProcedimentoID&sqlProfesp&") "&_ 
                "     UNION ALL "&_
                "        SELECT Especialidades, "&_
                "               ProfissionalID, "&_ 
                "               LocalID, "&_ 
                "               '' Convenios "&_
                "          FROM assperiodolocalxprofissional "&_ 
                "         WHERE DataDe<="& mydatenull(Data) &_ 
                "           AND DataA>="& mydatenull(Data) &sqlProfesp&") t "&_
                "     LEFT JOIN profissionais p ON p.id=t.ProfissionalID "&_ 
                "         WHERE p.Ativo='on'"&_ 
                "           AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda))  "&_ 
                                sqlConvenios &_ 
                                sqlUnidades &_ 
                                sqlProfissionais &_
                "      GROUP BY t.ProfissionalID"&_
                                sqlOrder
        response.write("<pre>"&sql&"</pre>")
        set comGrade = db.execute(sql)

        cProf = 0

        while  not comGrade.eof
            response.Flush()
            idsProfissionais= idsProfissionais&""

            ProfissionalID = comGrade("ProfissionalID")&""

            if instr(rfLocais, "UNIDADE_ID")>0 then
                UnidadesIN = replace(replace(rfLocais, "UNIDADE_ID", ""), "|", "")
                sqlUnidadesHorarios = " AND l.UnidadeID IN("& UnidadesIN &") "
                joinLocaisUnidades = " LEFT JOIN locais l ON l.id=a.LocalID "
                whereLocaisUnidades = " AND l.UnidadeID IN("& UnidadesIN &") "
            end if

            Hora = cdate("00:00")

            sqlHorariosExcecao = "SELECT distinct ass.intervalo, "&_
                                        "       ass.LocalID, "&_
                                        "       ass.Procedimentos, "&_
                                        "       ass.id, "&_
                                        "       ass.HoraDe, "&_
                                        "       ass.HoraA, "&_ 
                                        "       ass.ProfissionalID, "&_ 
                                        "       l.UnidadeID, "&_ 
                                        "       '0' TipoGrade, "&_ 
                                        "       '0' GradePadrao, "&_ 
                                        "       '' Procedimentos, "&_ 
                                        "       Especialidades, "&_ 
                                        "       '' Horarios "&_ 
                                        "  FROM assperiodolocalxprofissional ass "&_ 
                                        "  JOIN procedimento_profissional_unidade ppu ON ppu.id_profissional = ass.ProfissionalID"&_
                                    " LEFT JOIN locais l on l.id=ass.LocalID "&_ 
                                        " WHERE ass.ProfissionalID="&ProfissionalID&" "&_ 
                                        "   AND DataDe<="&mydatenull(Data)&" "&_ 
                                        "   AND DataA>="&mydatenull(Data)&_ 
                                        "      "&sqlUnidadesHorarios &_ 
                                        "   AND ppu.id_procedimento = "&ProcedimentoID&_ 
                                    " ORDER BY HoraDe"

            set Horarios = db.execute(sqlHorariosExcecao)
            if Horarios.EOF then

                sqlHorarios = "SELECT distinct ass.Especialidades, "&_ 
                                            "       ass.intervalo, "&_ 
                                            "       ass.FrequenciaSemanas, "&_ 
                                            "       ass.InicioVigencia, "&_ 
                                            "       ass.LocalID, "&_ 
                                            "       ass.Procedimentos, "&_ 
                                            "       ass.id, "&_ 
                                            "       HoraDe, "&_ 
                                            "       HoraA, "&_ 
                                            "       ass.ProfissionalID, "&_ 
                                            "       ass.TipoGrade, "&_
                                            "       ass.GradeEncaixe, "&_
                                            "       l.UnidadeID, "&_ 
                                            "       '1' GradePadrao, "&_ 
                                            "       Horarios "&_ 
                                            "  FROM assfixalocalxprofissional ass "&_ 
                                            "  JOIN procedimento_profissional_unidade ppu ON ppu.id_profissional = ass.ProfissionalID"&_
                                       "  LEFT JOIN locais l on l.id=ass.LocalID "&_ 
                                            " WHERE ass.ProfissionalID="&ProfissionalID&" "&_ 
                                            "   AND ass.DiaSemana="&DiaSemana&" "&_ 
                                            "   AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) "&_ 
                                                    sqlUnidadesHorarios &_ 
                                            "   AND ppu.id_procedimento = "&ProcedimentoID&_ 
                                        " ORDER BY ass.HoraDe"
'response.write("<pre>HORÁRIOS - "&sqlHorarios&"</pre>")
                set Horarios = db.execute(sqlHorarios)
            end if

            sqlInsertV = ""
            EspecialidadesGrade=""
            txtGradeOriginal = ""

            if not Horarios.eof then

                while not Horarios.EOF

                    LocalID = Horarios("LocalID")
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
                        
                        if Horarios("TipoGrade")=0 and not isnull(Horarios("HoraDe")) then
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
                                sqlInsertV = sqlInsertV & ", ("& treatvalzero(session("User")) &", "& mydatenull(Data) &", "& mytime(Hora) &", 'V', "& treatvalzero(ProfissionalID) &", NULL, "& treatvalzero(LocalID) &", "& treatvalzero(UnidadeID) &", "& Horarios("TipoGrade") &", "& Horarios("id") &", 0, 1 , "&parCarrinhoID&", '"&sessaoAgenda&"')"
                                Hora = dateadd("n", Intervalo, Hora)
                            wend

                        elseif Horarios("GradeEncaixe")="S" then

                            sqlInsertV = sqlInsertV & ", ("& treatvalzero(session("User")) &", "& mydatenull(Data) &", NULL, 'V', "& treatvalzero(ProfissionalID) &", NULL, "& treatvalzero(LocalID) &", "& treatvalzero(UnidadeID) &", "& Horarios("TipoGrade") &", "& Horarios("id") &", 1, 1 , "&parCarrinhoID&", '"&sessaoAgenda&"')"

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
                                        sqlInsertV = sqlInsertV & ", ("& treatvalzero(session("User")) &", "& mydatenull(Data) &", "& mytime(HoraPers) &", 'V', "& treatvalzero(ProfissionalID) &", NULL, "& treatvalzero(LocalID) &", "& treatvalzero(UnidadeID) &", "& Horarios("TipoGrade") &", "& Horarios("id") &", 0, 1, "&parCarrinhoID&", '"&sessaoAgenda&"')"
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
                    sqlI ="insert into agenda_horarios (sysUser, Data, Hora, Situacao, ProfissionalID, EspecialidadeID, LocalID, UnidadeID, TipoGrade, GradeID, Encaixe, GradeOriginal, CarrinhoID, sessaoAgenda) VALUES "& sqlInsertV
                    'response.write("<pre>"&sqlI&"</pre>")
                    db.execute(sqlI)
                end if

                if 1 then
                'response.write("<pre>COMPS - select a.EspecialidadeID, a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.Encaixe, a.Tempo from agendamentos a " & joinLocaisUnidades &_
                    '   "where a.ProfissionalID="&ProfissionalID&" and a.Data="&mydatenull(Data) & whereLocaisUnidades &"order by Hora</pre>")
                    set comps=db.execute("select a.EspecialidadeID, a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.Encaixe, a.Tempo from agendamentos a " & joinLocaisUnidades &_
                    "where a.ProfissionalID="&ProfissionalID&" and a.Data="&mydatenull(Data) & whereLocaisUnidades &"order by Hora")
                
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

                        if not isnull(comps("Tempo")) and comps("Tempo")<>"" and isnumeric(comps("Tempo")) then
                            Tempo = Tempo + ccur(comps("Tempo"))
                        else
                            Tempo = 0
                        end if

                        Horario = comps("Hora")

                        if isdate(Horario) and Horario<>"" then
                            HoraFinal = dateadd("n", Tempo, Horario)
                            HoraFinal = formatdatetime( HoraFinal, 4 )

                            if HoraFinal<=HoraComp then
                                HoraFinal = Horario
                            end if
                        else
                            HoraFinal = Horario
                        end if

                        LiberaInsert=False

                        if EspecialidadesGrade <> "" then
                            if instr(EspecialidadesGrade, "|"&EspecialidadeIDAgendada&"|")>0 then
                                LiberaInsert = True
                            end if
                        else
                            LiberaInsert=True
                        end if

                        StaID = comps("StaID")

                        if StaID<>11 and StaID<>22 and LiberaInsert then
                            sqlDel = "DELETE FROM agenda_horarios WHERE sysUser="& treatvalzero(session("User")) &" AND sessaoAgenda='"&sessaoAgenda&"' AND Situacao='V' AND Data="& mydatenull(Data) &" AND ProfissionalID="& treatvalnull(ProfissionalID) &" AND Hora BETWEEN "& mytime(Horario) &" AND "& mytime(HoraFinal)
                            db.execute( sqlDel )
                        end if

                        if instr(txtGradeOriginal, "|"& ft(Horario) &"|")>0 AND StaID<>11 AND StaID<>22 then
                            GradeOriginal = 1
                            txtGradeOriginal = replace(txtGradeOriginal, "|"& ft(Horario) &"|", "")
                        else
                            GradeOriginal = "NULL"
                        end if

                        sqlGradeExcecao = "select id from assperiodolocalxprofissional where  '"&horario&"' BETWEEN HoraDe  AND HoraA  AND  " & mydatenull(Data) & " BETWEEN DataDe AND DataA  AND ProfissionalID=" &treatvalnull(ProfissionalID) & " ORDER BY 1  "
                        ' response.write("<pre>GRADE EXCECAO -"&sqlGradeExcecao&"</pre>")
                        set GradeExcecaoSQL = db.execute(sqlGradeExcecao)

                        sqlGradeId=""

                        if not GradeExcecaoSQL.eof then
                            sqlGradeId = ", GradeID="&GradeExcecaoSQL("id")*-1
                        else
                            sqlGradePadrao0 = "select id from assfixalocalxprofissional where DiaSemana = " & DiaSemana & " AND HoraDe <= " & mytime(horario) & " AND HoraA >= "  &  mytime(horario) &  " AND ( (InicioVigencia <= " &mydatenull(Data)& " OR InicioVigencia IS NULL) AND (FimVigencia >= " &mydatenull(Data)& " OR FimVigencia  IS NULL) )  AND ProfissionalID=" &treatvalzero(ProfissionalID)& " ORDER BY 1 "
                            ' response.write("<pre>GRADE PADRÃO -"&sqlGradePadrao0&"</pre>")
                            set GradePadraoSQL = db.execute(sqlGradePadrao0)

                            if not GradePadraoSQL.eof then
                                sqlGradeId = ", GradeID="&GradePadraoSQL("id")
                            end if
                        end if

                        if LiberaInsert then
                            db.execute("INSERT INTO agenda_horarios SET AgendamentoID="&treatvalzero(comps("id"))&", sysUser="& treatvalzero(session("User")) &", sessaoAgenda = '"&sessaoAgenda&"', Data="& mydatenull(Data) &", Hora="& mytime(Horario) &", StaID="& StaID &", Situacao='A', ProfissionalID="& treatvalzero(ProfissionalID) &", EspecialidadeID=NULL, LocalID="& treatvalzero(LocalID) &", UnidadeID="& treatvalzero(UnidadeID) &", Encaixe="& treatvalnull(comps("Encaixe")) &", GradeOriginal="& GradeOriginal & sqlGradeId)
                        end if
                        comps.movenext
                    wend
                    comps.close
                    set comps = nothing
                end if

                if ProfissionalID&""="" then
                    ProfissionalID="0"
                else
                    ProfissionalID= replace(ProfissionalID, ",00", "")
                end if

                bloqueioSql = "select c.HoraDe, c.HoraA, c.Profissionais, c.id from compromissos c where (c.ProfissionalID='"& ProfissionalID &"' or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"& ProfissionalID&"%|'))) AND (c.Unidades LIKE '%|"&UnidadeID&"|%' or c.Unidades='' or c.Unidades is null) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"
            'response.write("<pre>BLOQUEIO - "&bloqueioSql&"</pre>")
                set bloq = db.execute(bloqueioSql)

                while not bloq.EOF

                    HoraDe = bloq("HoraDe")
                    HoraA = bloq("HoraA")
                    BloqueioID = bloq("id")

                    sqlUP = "UPDATE agenda_horarios SET BloqueioID="&treatvalzero(BloqueioID)&", Situacao='B', GradeOriginal=if(GradeOriginal=1, 2, NULL) WHERE sysUser="& treatvalzero(session("User")) &" AND sessaoAgenda='"&sessaoAgenda&"' AND Data="& mydatenull(Data) &" AND ProfissionalID="& treatvalnull(ProfissionalID) &" AND Hora BETWEEN "& mytime(HoraDe) &" AND "& mytime(HoraA) &" AND Situacao IN('V', 'A')"

                    sqlProfissionalBloq = "ProfissionalID="& treatvalnull(ProfissionalID)
                    ProfissionaisBloq = bloq("Profissionais")&""

                    if ProfissionaisBloq<>"" then
                        ProfissionaisBloq = replace(ProfissionaisBloq, "|", "")
                        sqlProfissionalBloq = sqlProfissionalBloq & " OR ProfissionalID IN("& ProfissionaisBloq &") "
                    end if

                    sqlUP = "UPDATE agenda_horarios SET BloqueioID="&treatvalzero(BloqueioID)&",Situacao='B', GradeOriginal=if(GradeOriginal=1, 2, NULL) WHERE sysUser="& treatvalzero(session("User")) &" AND sessaoAgenda='"&sessaoAgenda&"' AND Data="& mydatenull(Data) &" AND ("& sqlProfissionalBloq &") AND Hora BETWEEN "& mytime(HoraDe) &" AND "& mytime(HoraA) &" AND Situacao IN('V', 'A')"
                    db.execute( sqlUP )

                    HBloqueados = HBloqueados + 1

                    bloq.movenext
                wend

                bloq.close
                set bloq=nothing

            end if
            comGrade.movenext
        wend

        comGrade.close
        set comGrade=nothing

        Data = Data+1
    wend
end function
%>