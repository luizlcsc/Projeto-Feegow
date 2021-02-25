<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="Classes/ConnectionReadOnly.asp"-->
{
<%
set dbread = newReadOnlyConnection()

function existeGrade(ProfissionalID, UnidadeID, DiaSemana, Hora, Data)
    existeGrade = false
    if UnidadeID<>"" then
        sqlUnidade = " AND loc.UnidadeID='"&UnidadeID&"'"
    end if

    sqlGrade = "SELECT id GradeID, Especialidades, Procedimentos, LocalID FROM (SELECT ass.id, Especialidades, Procedimentos, LocalID FROM assfixalocalxprofissional ass LEFT JOIN locais loc ON loc.id=ass.LocalID WHERE ProfissionalID="&treatvalzero(ProfissionalID)&sqlUnidade&" AND DiaSemana="&DiaSemana&" AND "&mytime(Hora)&" BETWEEN HoraDe AND HoraA AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&")) UNION ALL SELECT ex.id*-1 id, Especialidades, Procedimentos, LocalID FROM assperiodolocalxprofissional ex LEFT JOIN locais loc ON loc.id=ex.LocalID WHERE ProfissionalID="&ProfissionalID&sqlUnidade&" AND DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&")t"
    'response.write sqlGrade
    set Grade = dbread.execute(sqlGrade)
    if Grade.eof then
        existeGrade = true
    end if
end function


exibir=ref("exibir")
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
TermoBuscado = trim(ref("q"))
NomeTabela = lcase(ref("t"))
PermissaoParaAdd = aut("|"&NomeTabela&"I|")
PermiteBuscar = True

if NomeTabela="pacientes" then
    PermiteBuscar = False

    if len(TermoBuscado) > 4 then
        PermiteBuscar = True
    end if
end if

Qtd="0"

if PermiteBuscar then
    set conta = dbread.execute("select count(id) total from `"&NomeTabela&"` where `"&ref("c")&"` like '"&TermoBuscado&"%'")
    Qtd=ccur(conta("total"))
end if
%>
  "total_count": <%=Qtd %>,
<%
recursoPermissaoUnimed = recursoAdicional(12)

if aut(lcase(ref("resource"))&"A")=1 then
    if lcase(ref("t"))="pacientes" then
        if len(TermoBuscado)<1 then
            %>
            message: "Digite..." }
            <%
            Response.End
        end if

        ProfissionalID = ref("ProfissionalID")
        if ProfissionalID<>"" and isnumeric(ProfissionalID) and ProfissionalID<>"0" and session("SepararPacientes") then
            sqlProfissionalPaciente = " AND (Profissionais LIKE '%|"&ProfissionalID&"|%' OR Profissionais IS NULL)"
        end if

        sqlNascimento = ""
        if ref("nascimento")<>"" then
            sqlNascimento = " AND Nascimento="&mydatenull(ref("nascimento"))
        end if

        IF ModoFranquia=false THEN
            sqlNomeDaMae = " OR id IN ( (select PacienteID from pacientesrelativos where ((TRIM(Nome) like '%"&TermoBuscado&"%' ) and sysActive=1 and parentesco = 2 ) ) )"
            sqlTelefone = " OR replace(replace(replace(replace(Tel1,'(',''),')',''),'-',''),' ', '') like '%"&TermoBuscado&"%' or replace(replace(replace(replace(Tel2,'(',''),')',''),'-',''),' ', '') like '%"&ref("q")&"%' or replace(replace(replace(replace(Cel1,'(',''),')',''),'-',''),' ', '') like '%"&ref("q")&"%' or replace(replace(replace(replace(Cel2,'(',''),')',''),'-',''),' ', '') like '%"&ref("q")&"%' "
        END IF
        
        if not isnumeric(TermoBuscado) then
            sqlTelefone=""
        end if

        if isnumeric(ref("q")) and ref("q")<>"" then
            sql = "select id, NomePaciente, Nascimento, CPF from pacientes where (id = '%"&ref("q")&"' or replace(replace(CPF,'.',''),'-','') like replace(replace('"&ref("q")&"%','.',''),'-','') and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" " & sqlTelefone &" order by NomePaciente limit "& page*30 &", 30"
            if ModoFranquia=true then
                sql = replace(sql,"replace(replace(CPF,'.',''),'-','') like replace(replace('"&ref("q")&"%','.',''),'-','')","CPF like '"&ref("q")&"%'")
            end if
        elseif isdate(ref("q")) and ref("q")<>"" then
            DataNasc = mydatenull(ref("q"))
            sql = "select id, NomePaciente, Nascimento, CPF from pacientes where Nascimento="& DataNasc &" and sysActive=1 "&sqlProfissionalPaciente&" order by NomePaciente limit "& page*30 &", 30"
        else
            if recursoPermissaoUnimed=4 and (session("Banco")="clinic6224" or session("Banco")="clinic6581" or session("Banco")="clinic6501") and len(ref("q")) > 3 then
                sql = "select id, NomePaciente, Nascimento, CPF from pacientes where ((trim(NomePaciente) like '%"&ref("q")&"%' ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" UNION ALL SELECT 1000000000+pp.id, concat(pp.NomePaciente, ' (Base Unimed)'), pp.Nascimento FROM clinic5803.pacientes pp LEFT JOIN pacientes p ON p.idImportado = pp.id WHERE p.idImportado is null and ((trim(pp.NomePaciente) like '%"&ref("q")&"%' ) and pp.sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" order by (case when NomePaciente like '"&ref("q")&"%' then 1 else 2 end) , NomePaciente limit "& page*30 &", 30 "
            else
                sqlparentesco = "NomePaciente, "
                if getConfig("ExibirParentescoPacienteAgendar")="1" then
                    sqlparentesco = "IF( ( " & sqlNomeDaMae & ") , CONCAT('<b>Mae: ',NomePaciente,'</b>'), NomePaciente) NomePaciente,"
                end if

                if ModoFranquia then
                    sqlNomeDaMae=""
                end if

                sql = "select id,"&sqlparentesco&"  Nascimento, CPF from pacientes where ((NomePaciente like '"&TermoBuscado&"%' ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" "&sqlNomeDaMae&" " &sqlTelefone&" limit "& page*30 &", 30"
            end if
    	    'sql = "select id, NomePaciente, Nascimento from pacientes where ((TRIM(NomePaciente) like '%"&ref("q")&"%' ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" order by (case when NomePaciente like '"&ref("q")&"%' then 1 else 2 end) , NomePaciente limit "& page*30 &", 30"
    	    sqlAlternativo = "select id, NomePaciente, Nascimento, CPF from pacientes where ((SOUNDEX(LEFT(NomePaciente, LENGTH('"&ref("q")&"'))) = SOUNDEX('"&ref("q")&"') ) and sysActive=1 "&sqlProfissionalPaciente&") "&sqlNascimento&" order by (case when NomePaciente like '"&ref("q")&"%' then 1 else 2 end) , NomePaciente limit "& page*30 &", 30"
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
                set prof = dbread.execute("select EspecialidadeID from profissionais where not isnull(EspecialidadeID) and EspecialidadeID<>0 and id="& ProfissionalID)
                if not prof.eof then
                    EspecialidadeID = prof("EspecialidadeID")

                    sqlEspecialidades = " (SomenteEspecialidades like '%|"& EspecialidadeID &"|%' or SomenteEspecialidades IS NULL)"

                    set EspecialidadesSQL = dbread.execute("SELECT EspecialidadeID FROM profissionaisespecialidades WHERE ProfissionalID="&ProfissionalID)
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
                set procUnidades = dbread.execute("select count(id) total from procedimento_profissional_unidade ppu where ppu.id_profissional = " & ProfissionalID)
                if not procUnidades.eof then
                    if ccur(procUnidades("total")) > 0 then
                        set procedimentosPermitidos = dbread.execute("SELECT GROUP_CONCAT(id_procedimento) procs FROM procedimento_profissional_unidade WHERE id_unidade = "&session("UnidadeID")&" AND id_profissional = " & ProfissionalID)
                        if not procedimentosPermitidos.eof then
                            if procedimentosPermitidos("procs")&"" <> "" then
                                sqlLimitProcedimentos = " AND id IN (" & procedimentosPermitidos("procs") & ") "
                            end if
                        end if
                    end if
                end if

            end if
            sqlSomenteProcedimento=""

            sql = "select id, NomeProcedimento from procedimentos where sysActive=1 and (NomeProcedimento like '%"&ref("q")&"%' or Codigo like '%"&ref("q")&"%' or Sinonimo like '%"&ref("q")&"%') AND NomeProcedimento IS NOT NULL "&sqlConv&" and Ativo='on' "&sqlSomenteProcedimento&" and (isnull(opcoesagenda) or opcoesagenda=0 or opcoesagenda=1 " &sqlProfProc& sqlProfEsp &") " & sqlLimitProcedimentos &" order by OpcoesAgenda desc, NomeProcedimento"
            IF ModoFranquiaUnidade THEN
                sql = "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' "&franquiaUnidade("AND CASE WHEN procedimentos.OpcoesAgenda IN (4,3) THEN COALESCE(NULLIF(SomenteProfissionais,'') LIKE '%|"&ProfissionalID&"|%',FALSE) OR COALESCE(cliniccentral.overlap(SomenteEspecialidades,'"&ProfissionalEspecialidade&"'),FALSE) END")&" order by OpcoesAgenda desc, NomeProcedimento"
                
                '  tirar profissional especialidades
                ' sql = "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' "&franquiaUnidade("AND CASE WHEN procedimentos.OpcoesAgenda IN (4,3) THEN COALESCE(NULLIF(SomenteProfissionais,'') LIKE '%|"&ProfissionalID&"|%',FALSE) OR COALESCE(cliniccentral.overlap(SomenteEspecialidades,'"&ProfissionalEspecialidade&"'),FALSE) ELSE TRUE END")&" order by OpcoesAgenda desc, NomeProcedimento"
                'sql = "select id, NomeProcedimento from procedimentos where id in (SELECT idOrigem FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID")&") AND sysActive=1 and (NomeProcedimento like '%"&ref("q")&"%' or Codigo like '%"&ref("q")&"%' or Sinonimo like '%"&ref("q")&"%') AND NomeProcedimento IS NOT NULL "&sqlConv&" and Ativo='on' "&sqlSomenteProcedimento&" and (isnull(opcoesagenda) or opcoesagenda=0 or opcoesagenda=1 " &sqlProfProc& sqlProfEsp &") " & sqlLimitProcedimentos &" order by OpcoesAgenda desc, NomeProcedimento"
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
                sql = "select id, NomeProcedimento from ((select id, NomeProcedimento from procedimentos where "&franquiaUnidade("id in (SELECT idOrigem FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID")&") AND")&" sysActive=1 and (NomeProcedimento like '%"&ref("q")&"%' or Codigo like '%"&ref("q")&"%' or Sinonimo like '%"&ref("q")&"%') and Ativo='on' order by OpcoesAgenda desc, NomeProcedimento) UNION ALL (SELECT (-1*CAST(id as SIGNED))id, CONCAT(NomePacote, ' (Pacote)') NomeProcedimento FROM pacotes WHERE sysActive=1 AND NomePacote like '%"&ref("q")&"%'))t LIMIT 20"
            end if

            initialOrder = "NomeProcedimento"
        elseif ref("t")="sys_financialexpensetype" then
            PermissaoParaAdd = 0

            set dadosResource = dbread.execute("select * from cliniccentral.sys_resources where tableName like '"&ref("t")&"'")
            Typed= ref("q")

            sql = "SELECT id, CONCAT(coalesce(concat(posicao,' - '),''),IFNULL(Pai2,''), IFNULL(Pai1,''), Name) Name FROM ( "&_
                " "&_
                "select et.id,  "&_
                " "&_
                "(CONCAT(SUBSTR(( SELECT (SELECT etp2.NAME from sys_financialExpenseType etp2 WHERE etp2.id=etp1.Category) from sys_financialExpenseType etp1 WHERE etp1.id=et.Category )  ,1,4),'.', ' > ')) Pai2, "&_
                " "&_
                "(CONCAT(SUBSTR((SELECT etp.NAME from sys_financialExpenseType etp WHERE etp.id=et.Category)  ,1,4),'.', ' > ')) Pai1, "&_
                " "&_
                "et.NAME  "&_
                " "&_
                ", et.Posicao  "&_
                "from sys_financialExpenseType et  "&_
                "WHERE TRUE  "&_
                "AND (SELECT ifnull(limitarcontaspagar,'') FROM sys_users WHERE sys_users.id = [USERID]) NOT LIKE CONCAT('%|',et.id,'|%')  "&_
                "AND (SELECT count(id) FROM sys_financialExpenseType WHERE et.id=Category)=0  and sysActive=1 order by et.NAME "&_
                " "&_
                ")t "&_
                "WHERE CONCAT(coalesce(concat(posicao,' - '),''),IFNULL(Pai2,''), IFNULL(Pai1,''), Name) LIKE '%[TYPED]%'"

            sql = replace(sql, "[TYPED]", Typed)
            sql = replace(sql, "[USERID]", session("user"))
            sql = replace(sql, "[campoSuperior]", ref("cs"))
            othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
            ResourceID = dadosResource("id")
            initialOrder = dadosResource("initialOrder")
            tableName = dadosResource("tableName")
            Pers = dadosResource("Pers")
            mainFormColumn = dadosResource("mainFormColumn")
        elseif ref("t")="sys_financialincometype" then
            PermissaoParaAdd = 0
            set dadosResource = dbread.execute("select * from cliniccentral.sys_resources where tableName like '"&ref("t")&"'")
            Typed= ref("q")

            sql = "SELECT id, CONCAT(coalesce(concat(posicao,' - '),''),IFNULL(Pai2,''), IFNULL(Pai1,''), Name) Name FROM ( "&_
                " "&_
                "select et.id,  "&_
                " "&_
                "(CONCAT(SUBSTR(( SELECT (SELECT etp2.NAME from sys_financialIncomeType etp2 WHERE etp2.id=etp1.Category) from sys_financialIncomeType etp1 WHERE etp1.id=et.Category )  ,1,4),'.', ' > ')) Pai2, "&_
                " "&_
                "(CONCAT(SUBSTR((SELECT etp.NAME from sys_financialIncomeType etp WHERE etp.id=et.Category)  ,1,4),'.', ' > ')) Pai1, "&_
                " "&_
                "et.NAME  "&_
                " "&_
                ", et.Posicao  "&_
                "from sys_financialIncomeType et  "&_
                "WHERE TRUE  "&_
                "AND (SELECT count(id) FROM sys_financialIncomeType WHERE et.id=Category)=0  and sysActive=1 order by et.NAME "&_
                " "&_
                ")t "&_
                "WHERE CONCAT(coalesce(concat(posicao,' '),''),IFNULL(Pai2,''), IFNULL(Pai1,''), Name) LIKE '%[TYPED]%'"

            othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
            ResourceID = dadosResource("id")
            initialOrder = dadosResource("initialOrder")
            tableName = dadosResource("tableName")
            Pers = dadosResource("Pers")
            mainFormColumn = dadosResource("mainFormColumn")
        else
    	    set dadosResource = dbread.execute("select * from cliniccentral.sys_resources where tableName = '"&ref("t")&"'")
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

        if sqlExibir<>"" then
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
    set q = dbread.execute(sql)

    if q.eof and sqlAlternativo<>"" then
        IF not ModoFranquia then
            set q = dbread.execute(sqlAlternativo)
        END IF
    end if

    'set q = dbread.execute("select id, "&ref("c")&" from "&ref("t")&" where TRIM("&ref("c")&") like '"&trim(ref("q"))&"%' order by TRIM("&ref("c")&") limit "& page*30 &", 30")
    contador = 0


    if instr(ref("oti"),"empty") then

        if contador>0 then
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

        if contador>0 then
            response.write(",")
        end if
        contador=contador+1

        Nascimento = ""
        CPF = ""
        if lcase(ref("t"))="locais" then
            NomeUnidadeLocal = ""
            set LocalUnidadeSQL = dbread.execute("select l.id, CONCAT(IF(l.UnidadeID=0,concat(' - ', e.Sigla),concat(' - ', fcu.Sigla)))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where l.sysActive=1 AND l.id="&q("id")&" order by l.NomeLocal ")
            if not LocalUnidadeSQL.eof then
                NomeUnidadeLocal = LocalUnidadeSQL("NomeLocal")
            end if
        end if

        if lcase(ref("t"))="pacientes" then
            if q("Nascimento") <> "" then
                Nascimento = """birth"": "&""""&q("Nascimento")& ""","
            end if

             IF getConfig("CPFBuscaPaciente") =1 THEN
                if q("CPF") <> "" then
                     CPF = """Cpf"": "&""""&q("CPF")& ""","
                end if
             END IF

    

        end if


    %>
    {
      "id": <%=q("id") %>,<%=Nascimento%><%=CPF%>
      "full_name": "<%=fix_string_chars_full(q(ref("c"))) %><%=NomeUnidadeLocal%>"
    }
    <%
    q.movenext
    wend
    q.close
    set q=nothing

    if (contador < 3 or ref("t")="pacientes") and ref("q") <> "" then
        if contador>0 then
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
