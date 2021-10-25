<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
{
<%

function existeGrade(ProfissionalID, UnidadeID, DiaSemana, Hora, Data)
    existeGrade = false
    if UnidadeID<>"" then
        sqlUnidade = " AND loc.UnidadeID='"&UnidadeID&"'"
    end if

    sqlGrade = "SELECT id GradeID, Especialidades, Procedimentos, LocalID FROM (SELECT ass.id, Especialidades, Procedimentos, LocalID FROM assfixalocalxprofissional ass LEFT JOIN locais loc ON loc.id=ass.LocalID WHERE ProfissionalID="&treatvalzero(ProfissionalID)&sqlUnidade&" AND DiaSemana="&DiaSemana&" AND "&mytime(Hora)&" BETWEEN HoraDe AND HoraA AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&")) UNION ALL SELECT ex.id*-1 id, Especialidades, Procedimentos, LocalID FROM assperiodolocalxprofissional ex LEFT JOIN locais loc ON loc.id=ex.LocalID WHERE ProfissionalID="&ProfissionalID&sqlUnidade&" AND DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&")t"
    'response.write sqlGrade
    set Grade = db.execute(sqlGrade)
    if Grade.eof then
        existeGrade = true
    end if
end function


    exibir=ref("exibir")
    TermoBuscado=ref("q")
    if exibir<>"" then
        exibir = replace(exibir,"|","'")
        sqlExibir = " AND id IN ("&exibir&")"
    end if
    page = ref("page")
    if page="" then
        page=0
    else
        page = ccur(page)-1
    end if
    PermissaoParaAdd = aut("|"&lcase(ref("t"))&"I|")
    set conta = db.execute("select count(id) total from "&ref("t")&" where "&ref("c")&" like '"&trim(ref("q"))&"%'")
%>
  "total_count": <%=ccur(conta("total")) %>,
<%
recursoPermissaoUnimed = recursoAdicional(12)

if aut(lcase(ref("resource"))&"A")=1 then
    if lcase(ref("t"))="pacientes" then
        if left(ref("q"),1) = "#" and isnumeric(replace(ref("q"),"#","")) then
            sql = "select id, NomePaciente, Nascimento from pacientes where id="&replace(ref("q"),"#","")
        else

            ProfissionalID = ref("ProfissionalID")
            if ProfissionalID<>"" and isnumeric(ProfissionalID) and ProfissionalID<>"0" and session("SepararPacientes") then
                sqlProfissionalPaciente = " AND (Profissionais LIKE '%|"&ProfissionalID&"|%' OR Profissionais IS NULL)"
            end if

            sqlNascimento = ""
            if ref("nascimento")<>"" then
                sqlNascimento = " AND Nascimento="&mydatenull(ref("nascimento"))
            end if

            if PorteClinica <= 3 then
                'sqlNomeDaMae = " id IN ( (select PacienteID from pacientesrelativos where ((TRIM(Nome) like '%"&ref("q")&"%' ) and sysActive=1 and parentesco = 2 ) ) )"
                sqlTelefone = " OR replace(replace(replace(replace(Tel1,'(',''),')',''),'-',''),' ', '') like '%"&ref("q")&"%' or replace(replace(replace(replace(Tel2,'(',''),')',''),'-',''),' ', '') like '%"&ref("q")&"%' or replace(replace(replace(replace(Cel1,'(',''),')',''),'-',''),' ', '') like '%"&ref("q")&"%' or replace(replace(replace(replace(Cel2,'(',''),')',''),'-',''),' ', '') like '%"&ref("q")&"%' "
            else
                sqlTelefone = " OR Cel1='"&ref("q")&"' OR Tel1='"&ref("q")&"' "
            end if
            
            if not isnumeric(TermoBuscado) then
                sqlTelefone=""
            end if

            if isnumeric(ref("q")) and ref("q")<>"" then
                sql = "select id, NomePaciente, Nascimento from pacientes where (id = '"&ref("q")&"' or replace(replace(CPF,'.',''),'-','') like replace(replace('"&ref("q")&"%','.',''),'-','') and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" " & sqlTelefone &" order by NomePaciente limit "& page*30 &", 30"
                if PorteClinica > 3 then
                    sql = replace(sql,"replace(replace(CPF,'.',''),'-','') like replace(replace('"&ref("q")&"%','.',''),'-','')","CPF = '"&ref("q")&"'")
                end if
            elseif isdate(ref("q")) and ref("q")<>"" then
                DataNasc = mydatenull(ref("q"))
                sql = "select id, NomePaciente, Nascimento from pacientes where Nascimento="& DataNasc &" and sysActive=1 "&sqlProfissionalPaciente&" order by NomePaciente limit "& page*30 &", 30"
            else
                if recursoPermissaoUnimed=4 and (session("Banco")="clinic6224" or session("Banco")="clinic6581" or session("Banco")="clinic6501") and len(ref("q")) > 3 then
                    sql = "select id, NomePaciente, Nascimento from pacientes where (((NomePaciente) like '%"&ref("q")&"%' ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" UNION ALL SELECT 1000000000+pp.id, concat(pp.NomePaciente, ' (Base Unimed)'), pp.Nascimento FROM clinic5803.pacientes pp LEFT JOIN pacientes p ON p.idImportado = pp.id WHERE p.idImportado is null and ((trim(pp.NomePaciente) like '%"&ref("q")&"%' ) and pp.sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" order by (case when NomePaciente like '"&ref("q")&"%' then 1 else 2 end) , NomePaciente limit "& page*30 &", 30 "
                else
                    'sql = "select id, IF( ( " & sqlNomeDaMae & ") , CONCAT('<b>Mae: ',NomePaciente,'</b>'), NomePaciente) NomePaciente, Nascimento from pacientes where ((TRIM(NomePaciente) like '%"&ref("q")&"%' ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" OR  "&sqlNomeDaMae&" order by (case when NomePaciente like '"&ref("q")&"%' then 1 else 2 end) , NomePaciente limit "& page*30 &", 30"
                    sqlparentesco = "NomePaciente, "

                    if PorteClinica > 3 then
                        sqlNomeDaMae=""
                    end if
                    sqlNascimento = ""

                    'if getConfig("ExibirParentescoPacienteAgendar")=1 then
                    '    sqlparentesco = "IF( ( " & sqlNomeDaMae & ") , CONCAT('<b>Mae: ',NomePaciente,'</b>'), NomePaciente) NomePaciente,"
                    'end if

                    sql = "select id,"&sqlparentesco&"  Nascimento from pacientes where (((NomePaciente) like '%"&ref("q")&"%' ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" or ((false "&sqlNomeDaMae&" " &sqlTelefone&") and sysActive=1) limit "& page*30 &", 30"
                end if
                'sql = "select id, NomePaciente, Nascimento from pacientes where (((NomePaciente) like '"&ref("q")&"%' ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" order by (case when NomePaciente like '"&ref("q")&"%' then 1 else 2 end) , NomePaciente limit "& page*30 &", 30"
                sqlAlternativo = "select id, NomePaciente, Nascimento from pacientes where ((SOUNDEX(LEFT(NomePaciente, LENGTH('"&ref("q")&"'))) = SOUNDEX('"&ref("q")&"') ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" order by (case when NomePaciente like '"&ref("q")&"%' then 1 else 2 end) , NomePaciente limit "& page*30 &", 30"
            end if
        end if
	    'campoSuperior???
	    ResourceID = 1
	    initialOrder = "NomePaciente"
	    tableName = "pacientes"
	    Pers = 1
	    mainFormColumn = ""
    else
        if instr(ref("oti"), "agenda") then
            ProfissionalID = ref("ProfissionalID")
            EquipamentoID = ref("EquipamentoID")&""

            if EquipamentoID<>"" and EquipamentoID<>"0" and (ProfissionalID="" or ProfissionalID="0") then
                ProfissionalID = "-"&EquipamentoID
            end if

            if ProfissionalID<>"" and isnumeric(ProfissionalID) and ProfissionalID<>"0" then
                set prof = db.execute("select EspecialidadeID from profissionais where not isnull(EspecialidadeID) and EspecialidadeID<>0 and id="& ProfissionalID)
                if not prof.eof then
                    EspecialidadeID = prof("EspecialidadeID")

                    sqlEspecialidades = " (SomenteEspecialidades like '%|"& EspecialidadeID &"|%' or SomenteEspecialidades IS NULL)"

                    set EspecialidadesSQL = db.execute("SELECT EspecialidadeID FROM profissionaisespecialidades WHERE ProfissionalID="&ProfissionalID)
                    while not EspecialidadesSQL.eof

                        sqlEspecialidades =  sqlEspecialidades & " or SomenteEspecialidades like '%|"& EspecialidadesSQL("EspecialidadeID") &"|%'"

                    EspecialidadesSQL.movenext
                    wend
                    EspecialidadesSQL.close
                    set EspecialidadesSQL=nothing

                    sqlEsp = " (opcoesagenda in (4,5) AND ("&sqlEspecialidades&")) "
                    'SomenteProcedimentos = prof("SomenteProcedimentos")&""
                else

                'entra aqui quando pela agenda de equipamentos
                    sqlEsp = " false "
                end if
                sqlProf = " (opcoesagenda IN (4,5) and SomenteProfissionais like '%|"& ProfissionalID &"|%') "

                if SomenteProcedimentos<>"" then
                    sqlProfProc = " and ('"&SomenteProcedimentos&"' LIKE CONCAT('%|',id,'|%')) "
                end if
            end if

            if ref("cs")<>"" then
                sqlConv = " AND ((SomenteConvenios LIKE '%|"&ref("cs")&"|%' or SomenteConvenios ='' OR SomenteConvenios is null) AND SomenteConvenios NOT LIKE '%|NONE|%' or SomenteConvenios is null) "
            end if

            if sqlProf = "" then sqlProf = " true "
            if sqlEsp = "" then sqlEsp = " true "

            sqlProfEsp = " or (OpcoesAgenda=4 AND ("&sqlProf&" or "&sqlEsp&"))"

            sqlProfEsp = sqlProfEsp&" or (OpcoesAgenda=5 AND (("&sqlProf&" OR SomenteProfissionais='') AND ("&sqlEsp&" OR SomenteEspecialidades='')))"

            sqlLimitProcedimentos = ""
            if getConfig("BloqueioProcedimentoUnidadeProfissional")=1 then
                set procUnidades = db.execute("select count(id) total from procedimento_profissional_unidade ppu where ppu.id_profissional = " & ProfissionalID)
                if not procUnidades.eof then
                    if ccur(procUnidades("total")) > 0 then
                        set procedimentosPermitidos = db.execute("SELECT GROUP_CONCAT(id_procedimento) procs FROM procedimento_profissional_unidade WHERE id_unidade = "&session("UnidadeID")&" AND id_profissional = " & ProfissionalID)
                        if not procedimentosPermitidos.eof then
                            if procedimentosPermitidos("procs")&"" <> "" then
                                sqlLimitProcedimentos = " AND id IN (" & procedimentosPermitidos("procs") & ") "
                            end if
                        end if
                    end if
                end if

            end if
            sqlSomenteProcedimento=""



            sql = "SELECT * FROM ("&_
            "select id, NomeProcedimento, coalesce(opcoesagenda,0) opcoesagenda from procedimentos where sysActive=1 and (NomeProcedimento like '%"&ref("q")&"%' or Codigo like '%"&ref("q")&"%') AND NomeProcedimento IS NOT NULL "&sqlConv&" and Ativo='on' "&sqlSomenteProcedimento&" and (isnull(opcoesagenda) or opcoesagenda=0 or opcoesagenda=1 " &sqlProfProc& sqlProfEsp &") " & sqlLimitProcedimentos & sqlExibir &" "&_
            ") t UNION ALL ("&_
            "select id, concat(NomeProcedimento, ' (sinônimo)'), coalesce(opcoesagenda,0) opcoesagenda from procedimentos where sysActive=1 and (NomeProcedimento not like '%"&ref("q")&"%' and Sinonimo like '%"&ref("q")&"%') AND NomeProcedimento IS NOT NULL "&sqlConv&" and Ativo='on' "&sqlSomenteProcedimento&" and (isnull(opcoesagenda) or opcoesagenda=0 or opcoesagenda=1 " &sqlProfProc& sqlProfEsp &") " & sqlLimitProcedimentos & sqlExibir&" ) order by if(OpcoesAgenda = 0, 1 , 0) desc, NomeProcedimento"

            IF ModoFranquiaUnidade THEN
                sql = "select id, NomeProcedimento, coalesce(opcoesagenda,0) opcoesagenda from procedimentos where id in (SELECT idOrigem FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID")&") AND sysActive=1 and (NomeProcedimento like '%"&ref("q")&"%' or Codigo like '%"&ref("q")&"%') AND NomeProcedimento IS NOT NULL "&sqlConv&" and Ativo='on' "&sqlSomenteProcedimento&" and (isnull(opcoesagenda) or opcoesagenda=0 or opcoesagenda=1 " &sqlProfProc& sqlProfEsp &") " & sqlLimitProcedimentos &" order by if(OpcoesAgenda = 0, 1 , 0) desc, NomeProcedimento"
            END IF
            initialOrder = "NomeProcedimento"
        elseif ref("t")="cliniccentral.cid10" then
            PermissaoParaAdd = 0
            Typed=ref("q")
            sql = "select id, concat(codigo, ' - ', descricao) as "&ref("c")&" from cliniccentral.cid10 where codigo like '%"&Typed&"%' or descricao like '%"&Typed&"%' order by codigo limit 10"
            initialOrder = "codigo"
        elseif ref("t")="cliniccentral.principioativo" then
            PermissaoParaAdd = 0
            Typed=ref("q")
            sql = "select * from cliniccentral.principioativo where Principio like '%"&Typed&"%' order by Principio limit 10"
            initialOrder = "Principio"
        elseif ref("t")="procedimentos" then
            Typed=ref("q")

            if instr(ref("oti"), "guia-tiss")>0 and (session("Banco")="clinic6178" or session("Banco")="clinic100000") and ref("cs")<>"" then
                sql = "select proc.id, proc.NomeProcedimento from procedimentos proc LEFT JOIN tissprocedimentosvalores tpv ON tpv.ProcedimentoID=proc.id where (tpv.ConvenioID="&ref("cs")&") AND proc.sysActive=1 and (proc.NomeProcedimento like '%"&ref("q")&"%' or proc.Codigo like '%"&ref("q")&"%') and proc.Ativo='on' GROUP BY proc.id order by proc.OpcoesAgenda desc, proc.NomeProcedimento"
            else
                sql = "select id, NomeProcedimento from ((select id, NomeProcedimento from procedimentos where sysActive=1 and (NomeProcedimento like '%"&ref("q")&"%' or Codigo like '%"&ref("q")&"%'  or Sinonimo like '%"&ref("q")&"%') and Ativo='on' order by OpcoesAgenda desc, NomeProcedimento) UNION ALL (SELECT (-1*CAST(id as SIGNED))id, CONCAT(NomePacote, ' (Pacote)') NomeProcedimento FROM pacotes WHERE sysActive=1 AND NomePacote like '%"&ref("q")&"%'))t LIMIT 20"
            end if

            initialOrder = "NomeProcedimento"
        elseif ref("t")="sys_financialexpensetype" then
            PermissaoParaAdd = 0

            set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName like '"&ref("t")&"'")
            Typed= ref("q")

            sql = "SELECT id, CONCAT(IFNULL(Pai2,''), IFNULL(Pai1,''), Name) Name FROM ( "&_
                " "&_
                "select et.id,  "&_
                " "&_
                "(CONCAT(SUBSTR(( SELECT (SELECT etp2.NAME from sys_financialExpenseType etp2 WHERE etp2.id=etp1.Category) from sys_financialExpenseType etp1 WHERE etp1.id=et.Category )  ,1,4),'.', ' > ')) Pai2, "&_
                " "&_
                "(CONCAT(SUBSTR((SELECT etp.NAME from sys_financialExpenseType etp WHERE etp.id=et.Category)  ,1,4),'.', ' > ')) Pai1, "&_
                " "&_
                "et.NAME  "&_
                " "&_
                "from sys_financialExpenseType et  "&_
                "WHERE TRUE  "&_
                "AND (SELECT ifnull(limitarcontaspagar,'') FROM sys_users WHERE sys_users.id = [USERID]) NOT LIKE CONCAT('%|',et.id,'|%')  "&_
                "AND (SELECT count(id) FROM sys_financialExpenseType WHERE et.id=Category)=0  and sysActive=1 order by et.NAME "&_
                " "&_
                ")t "&_
                "WHERE CONCAT(IFNULL(Pai2,''), IFNULL(Pai1,''), Name) LIKE '%[TYPED]%'"

            sql = replace(sql, "[TYPED]", Typed)
            sql = replace(sql, "[USERID]", session("user"))
            sql = replace(sql, "[campoSuperior]", ref("cs"))
            othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
            ResourceID = dadosResource("id")
            initialOrder = dadosResource("initialOrder")
            tableName = dadosResource("tableName")
            Pers = dadosResource("Pers")
            mainFormColumn = dadosResource("mainFormColumn")
        
        elseif ref("t")="locais" then
            set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName = '"&ref("t")&"'")

            Typed= ref("q")

            sql = "select l.id, concat(l.NomeLocal, IFNULL(concat(' - ', COALESCE(NULLIF(e.Sigla,''),NULLIF(fcu.Sigla,''), NULLIF(e.NomeFantasia,''),NULLIF(fcu.NomeFantasia,'')) ),'')) NomeLocal "&_
        	    "from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) "&_
                "LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID "&_
                "WHERE l.sysActive=1 AND l.NomeLocal LIKE '%[TYPED]%' "&_
                "order by l.NomeLocal "

            othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
            ResourceID = dadosResource("id")
            initialOrder = dadosResource("initialOrder")
            tableName = dadosResource("tableName")
            Pers = dadosResource("Pers")
            mainFormColumn = dadosResource("mainFormColumn")

        elseif ref("t")="sys_financialincometype" then
            PermissaoParaAdd = 0
            set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName like '"&ref("t")&"'")
            Typed= ref("q")

            sql = "SELECT id, CONCAT(IFNULL(Pai2,''), IFNULL(Pai1,''), Name) Name FROM ( "&_
                " "&_
                "select et.id,  "&_
                " "&_
                "(CONCAT(SUBSTR(( SELECT (SELECT etp2.NAME from sys_financialIncomeType etp2 WHERE etp2.id=etp1.Category) from sys_financialIncomeType etp1 WHERE etp1.id=et.Category )  ,1,4),'.', ' > ')) Pai2, "&_
                " "&_
                "(CONCAT(SUBSTR((SELECT etp.NAME from sys_financialIncomeType etp WHERE etp.id=et.Category)  ,1,4),'.', ' > ')) Pai1, "&_
                " "&_
                "et.NAME  "&_
                " "&_
                "from sys_financialIncomeType et  "&_
                "WHERE TRUE  "&_
                "AND (SELECT count(id) FROM sys_financialIncomeType WHERE et.id=Category)=0  and sysActive=1 order by et.NAME "&_
                " "&_
                ")t "&_
                "WHERE CONCAT(IFNULL(Pai2,''), IFNULL(Pai1,''), Name) LIKE '%[TYPED]%'"

            othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
            ResourceID = dadosResource("id")
            initialOrder = dadosResource("initialOrder")
            tableName = dadosResource("tableName")
            Pers = dadosResource("Pers")
            mainFormColumn = dadosResource("mainFormColumn")
            
        elseif ref("t")="locaisexternos" then
            Typed= ref("q")
	        sql = "select * from "&ref("t")&" where "&ref("c")&" like '%"&Typed&"%'"
            initialOrder = ref("c")
            ResourceID = 1
            initialOrder = "NomePaciente"
            tableName = ref("t")
            Pers = 1
            mainFormColumn = ""

        else
    	    set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName = '"&ref("t")&"'")
    	    Typed= ref("q")
	        sql = dadosResource("sqlSelectQuickSearch")&""
	        othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
	        ResourceID = dadosResource("id")
	        initialOrder = dadosResource("initialOrder")
	        tableName = dadosResource("tableName")
	        Pers = dadosResource("Pers")
	        mainFormColumn = dadosResource("mainFormColumn")

            if instr(sql, "limit")=0 then
                sql = sql & " LIMIT 100"
            end if

        end if
        sql = replace(sql, "[campoSuperior]", ref("cs"))
        sql = replace(sql, "[UNIDADES]", session("Unidades"))
        sql = replace(sql, "[TYPED]", Typed)

        if sqlExibir<>"" and (ProfissionalID = ""  and ProfissionalID = "0") then
            sql = replace(sql, " order ",sqlExibir&" order ")
        end if
    end if
    if aut("|"&lcase(ref("resource"))&"I|") then
        %>
        "ins": "./?P=<%=tableName%>&Pers=<%=Pers%>",
        <%
    else
        %>
        "ins": false,
        <%
    end if
else
    %>
    "ins": false,
    <%
end if


%>
  "items": [
    <%
    set q = db.execute(sql)

    if q.eof and sqlAlternativo<>"" then
        IF PorteClinica <= 3 then
            set q = db.execute(sqlAlternativo)
        END IF
    end if
    c = 0


    if instr(ref("oti"),"empty") then

        if c>0 then
            response.write(",")
        end if
        %>
        {
          "id": " ",
          "full_name": "Selecione"
        },
        <%
    end if

    response.Buffer
    while not q.eof
        response.Flush()

        if c>0 then
            response.write(",")
        end if
        c=c+1

        Nascimento = ""

        if lcase(ref("t"))="pacientes" then
            if q("Nascimento") <> "" then
                Nascimento = """birth"": "&""""&q("Nascimento")& ""","
            end if
        end if


    %>
    {
      "id": <%=q("id") %>,<%=Nascimento%>
      "full_name": "<%=fix_string_chars_full(q(ref("c"))) %>"
    }
    <%
    q.movenext
    wend
    q.close
    set q=nothing

    if (c < 3 or ref("t")="pacientes") and ref("q") <> "" then
        if c>0 then
            response.write(",")
        end if
        %>
        {
          "id": -1,
          "permission":<%=PermissaoParaAdd%>,
          "full_name": "<%= fix_string_chars_full(ref("q")) %>",
          "buscado": "<%=ref("q") %>"
        }
        <%
    end if


    %>
  ]
}
