<!--#include file="connect.asp"-->
<%
acao = request.form("acao")
id = request.form("id")
EspecialidadeID = request.form("EspecialidadeID")
GrupoID = request.form("GrupoID")
ProcedimentoID = request.form("ProcedimentoID")
ProfissionalID = request.form("ProfissionalID")
complementaQuery = ""
if acao = "carregaComboProcedimento" then
    sqlGrupoID = ""
    if GrupoID&"" <> "" and GrupoID&"" <> "0" then 
        sqlGrupoID = " AND p.GrupoID="&treatvalzero(GrupoID)
    end if
    sqlProfissional = ""
    if ProfissionalID <> "" and ProfissionalID <> "0" then
        sqlProfissional = " AND  p.id IN ( SELECT id_procedimento FROM procedimento_profissional_unidade WHERE id_profissional = "&ProfissionalID&" ) "
    end if
    sql = " SELECT id, "&_
          " NomeProcedimento "&_
          " FROM procedimentos p "&_
          " WHERE p.GrupoID not in (select id from procedimentosgrupos pg where pg.sysActive = 1 and (pg.NomeGrupo like '%Laboratório%')) "&_
          " AND sysActive=1 "&_
          " AND Ativo='on' " & sqlGrupoID & sqlProfissional &_ 
          " order by NomeProcedimento "
    response.write(quickfield("simpleSelect", "bProcedimentoID", "Procedimento", "", ProcedimentoID, sql, "NomeProcedimento", "style=""width:100%""  onchange=""agfilParametros();recarregaCombo('carregaComboExecutor','',$(this).val(),$('#bProfissionalID').val());recarregaCombo('carregaComplemento','',$(this).val()); recarregaCombo('carregaComboSubEspecializacao','',$(this).val())"" "))
    response.write("<script>$('.select2-single').select2();</script>")
elseif acao = "carregaComboExecutorAll" then
        sql = "SELECT DISTINCT p.id, IF(ISNULL(NomeSocial) OR NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional "&_ 
              " FROM procedimento_profissional_unidade ppu "&_ 
              " JOIN profissionais p ON p.id = ppu.id_profissional "&_ 
              " WHERE p.ativo = 'on' "&_ 
              " AND p.sysActive = 1 "&_ 
              " ORDER BY IF(ISNULL(NomeSocial) OR NomeSocial='', TRIM(NomeProfissional), TRIM(NomeSocial)) "
        response.write(quickfield("simpleSelect", "bProfissionalID", "Executor", "", "", sql, "NomeProfissional", " onchange=""agfilParametros();recarregaCombo('carregaComboProcedimento','',$('#bProcedimentoID').val(),$(this).val());""") )
        response.write("<div class='text-right'> <a href='#' onclick='profissionais()'> <i class='fa fa-external-link'></i> Agendamentos</a> </div>")
        response.write("<script>$('.select2-single').select2();</script>")
elseif acao = "carregaComboExecutor" then
    if ProcedimentoID <> "" and ProcedimentoID <> "0" then
        
        sql = "SELECT DISTINCT p.id, IF(ISNULL(NomeSocial) OR NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional "&_ 
              " FROM procedimento_profissional_unidade ppu "&_ 
              " JOIN profissionais p ON p.id = ppu.id_profissional "&_ 
              " WHERE id_procedimento = "&ProcedimentoID&_ 
              " AND p.ativo = 'on' "&_ 
              " AND p.sysActive = 1"
    else
        sql = "SELECT DISTINCT p.id, IF(ISNULL(NomeSocial) OR NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional "&_ 
              " FROM procedimento_profissional_unidade ppu "&_ 
              " JOIN profissionais p ON p.id = ppu.id_profissional "&_ 
              " WHERE p.ativo = 'on' "&_ 
              " AND p.sysActive = 1"
    end if
    sql = sql &" ORDER BY IF(ISNULL(NomeSocial) OR NomeSocial='', TRIM(NomeProfissional), TRIM(NomeSocial))"
    response.write(quickfield("simpleSelect", "bProfissionalID", "Executor", "", ProfissionalID, sql , "NomeProfissional", " onchange=""agfilParametros();recarregaCombo('carregaComboProcedimento','',$('#bProcedimentoID').val(),$(this).val())"" "))
    response.write("<div class='text-right'> <a href='#' onclick='profissionais()'> <i class='fa fa-external-link'></i> Agendamentos</a> </div>")
    response.write("<script>$('.select2-single').select2();</script>")
elseif acao = "carregaComplemento" then
    where = ""
    if ProcedimentoID <> "" then
        where = " where pcomp.ProcedimentoID = "&ProcedimentoID
    end if 
    sql = "select comp.id, comp.NomeComplemento from complementos comp "&_
          " where id in ( "&_
          " select ComplementoID from procedimentoscomplementos pcomp"&_
          " "&where&")"
    Response.write(quickfield("simpleSelect", "bComplementoID", "Complemento", 4, "", sql, "NomeComplemento", " empty "))
    Response.write("<script>$('.select2-single').select2();</script>")
elseif acao = "carregaComboSubEspecializacao" then
    sql = " SELECT DISTINCT sub.id, subespecialidade "&_
          " FROM subespecialidades sub "&_
          " JOIN profissionaissubespecialidades psub ON psub.SubespecialidadeID = sub.id "&_
          " JOIN procedimento_profissional_unidade ppu ON ppu.id_profissional = psub.ProfissionalID "&_
          " JOIN profissionais p ON p.id = ppu.id_profissional "&_
          " WHERE p.Ativo = 'on' AND sub.sysActive=1"&_
          " AND ppu.id_procedimento = "&ProcedimentoID&_
          " ORDER BY 2 "
    Response.write(quickfield("simpleSelect", "bSubespecialidadeID", "Sub Especialidade", 4, "", sql, "Subespecialidade", " empty "))
    Response.write("<script>$('.select2-single').select2();</script>")
end if
%>