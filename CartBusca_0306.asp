<!--#include file="connect.asp"-->
<table class="hidden">
<%
'1. COLETANDO GRADES QUE SE ENQUADRAM NESTA BUSCA COMO NA MÚLTIPLA COMUM

db.execute("delete from agendabuscaprofissionais WHERE sysUser="& session("User") )
db.execute("delete from agendabuscahorarios where sysUser="& session("User") )
set ac = db.execute("select * from agendacarrinho WHERE sysUser="& session("User") &" AND ISNULL(Arquivado)")
ocor = 0
while not ac.eof
    diaN = 0
    while diaN < 5
        sqlProfissionais=""

        Data = cdate(ref("Data"))+diaN
        %>
        <tr><th colspan="100">Carrinho <%= ac("id") &" - "& Data %></th></tr>
        <tr>
        <%

        Profissionais = "0"

        DiaSemana = weekday(Data)
        Mes = month(Data)
        ProcedimentoID = ac("ProcedimentoID")&""


        if ProcedimentoID<>"" then
            set proc = db.execute("select ifnull(OpcoesAgenda, 0) OpcoesAgenda, SomenteProfissionais, SomenteEspecialidades, SomenteLocais, EquipamentoPadrao from procedimentos where id="&ProcedimentoID)
            if not proc.eof then
                if proc("OpcoesAgenda")="4" then
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
                SomenteEquipamentos = proc("EquipamentoPadrao")
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
                    set profesp = db.execute("select group_concat(pro.id) Profissionais from profissionais pro LEFT JOIN profissionaisespecialidades pe on pe.ProfissionalID=pro.id where pro.EspecialidadeID IN("& replace(SomenteEspecialidades, "|", "") &")")
                    if not profesp.eof then
                        if profesp("Profissionais")&"" <> "" then
                            sqlEspecialidades = " t.ProfissionalID IN ("&profesp("Profissionais")&") "
                        end if
                    end if
                end if
        
                if sqlProfissionais<>"" and sqlEspecialidades<>"" then
                    sqlProfesp = " AND ("&sqlProfissionais&" OR "&sqlEspecialidades&") "
                elseif sqlProfissionais="" and sqlEspecialidades<>"" and sqlEspecialidades<> " " then
                    sqlProfesp = " AND "&sqlEspecialidades&" "
                elseif sqlProfissionais&""<>"" and sqlEspecialidades=""  then
                    sqlProfesp = " AND "&sqlProfissionais&" "
                end if
                sqlProfissionais = ""

                if instr(SomenteLocais, "|")=0 then
                    SomenteLocais = ""
                end if
                sqlProcedimentosGrade = " AND (Procedimentos LIKE '%|"&ProcedimentoID&"|%' OR Procedimentos is null or Procedimentos='') "
            end if
        end if



        refLocais = ""'ref("Locais") DEPOIS TROCAR PELO SELECT DE LOCAIS DA ZONA

        'if ref("Unidades")<>"" and ref("Unidades")<>"0" then
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


            'sqlUnidadesHorarios = " AND ass.LocalID IN (select concat(ll.id) from locais ll where ll.UnidadeID IN ("& UnidadesIDs &")) "

        end if

        if ac("EspecialidadeID")&""<>"" then
            leftEsp = " LEFT JOIN profissionaisespecialidades e on e.ProfissionalID=p.id "
            sqlEspecialidadesSel = " AND (p.EspecialidadeID IN ("& ac("EspecialidadeID") &") OR e.EspecialidadeID IN ("& ac("EspecialidadeID") &") ) "
            fieldEsp = " , e.EspecialidadeID EspecialidadeAd "
        end if


        if ac("ProfissionalID")&""<>"" then
            sqlProfissionais = " AND p.id IN ("& ac("ProfissionalID") &") "
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

        sql = ""

        sqlOrder = " ORDER BY NomeProfissional"
        if session("Banco") = "clinic935" then
            sqlOrder = " ORDER BY OrdemAgenda DESC"
        end if
        sql = "select t.ProfissionalID, p.EspecialidadeID, t.LocalID, IF (p.NomeSocial IS NULL OR p.NomeSocial='', p.NomeProfissional, p.NomeSocial) NomeProfissional, p.ObsAgenda, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select ProfissionalID, LocalID from assfixalocalxprofissional WHERE HoraDe !='00:00:00' AND DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&") "&sqlProcedimentosGrade&") UNION ALL select ProfissionalID, LocalID from assperiodolocalxprofissional WHERE DataDe<="& mydatenull(Data) &" and DataA>="& mydatenull(Data) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda))  "& sqlEspecialidadesSel & sqlProfissionais & sqlConvenios & sqlProfesp & sqlUnidades &" GROUP BY t.ProfissionalID"&sqlOrder


        sqlVerme = "select t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.NomeProfissional, p.ObsAgenda, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select ProfissionalID, LocalID from assfixalocalxprofissional WHERE DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&"))) t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda)) "& sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlProfesp & sqlUnidades &" GROUP BY t.ProfissionalID"

        sqlVermePer = "select t.DataDe, t.DataA, t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.SomenteConvenios "& fieldEsp &" from (select ProfissionalID, LocalID, DataDe, DataA from assperiodolocalxprofissional WHERE DataDe>="& mydatenull( DiaMes("P", Data ) )&" AND DataA<="& mydatenull( DiaMes("U", Data) ) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda)) "& sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlProfesp & sqlUnidades

        sql = replace(sql, "[DiaSemana]", DiaSemana)
        'response.Write("<br>SQL GRADES-> "& sql )
        set comGrade = db.execute( sql )


        cProf = 0
        while not comGrade.eof
            set pesp = db.execute("select esp.especialidade from especialidades esp where esp.id="& treatvalnull(comGrade("EspecialidadeID"))&" or esp.id in(select group_concat(pe.EspecialidadeID) from profissionaisespecialidades pe where ProfissionalID in ("&treatvalzero(comGrade("ProfissionalID"))&"))")
            NomeEspecialidade = ""
            while not pesp.eof
                NomeEspecialidade = NomeEspecialidade & left(pesp("especialidade")&"", 21) &"<br>"
            pesp.movenext
            wend
            pesp.close
            set pesp=nothing

            ObsAgenda = comGrade("ObsAgenda")
            if len(ObsAgenda)>0 then
                ObsAgenda = 1
            else
                ObsAgenda = 0
            end if

            ocor = ocor+1
            %>



                     <td valign="top" align="center" id="pf<%= ac("id") &"_"& diaN &"_"& comGrade("ProfissionalID") %>"><i class="far fa-circle-o-notch fa-spin"></i></td>

                    <script type="text/javascript">
                        $.post("namAgendaFiltros.asp", {
                            ProfissionalID: '<%= comGrade("ProfissionalID") %>',
                            Data: '<%= Data %>',
                            NomeProfissional: "<%= comGrade("NomeProfissional") %>",
                            Cor: '<%= comGrade("Cor") %>',
                            NomeEspecialidade: '<%= NomeEspecialidade %>',
                            sqlProcedimentosGrade: "<%= sqlProcedimentosGrade %>",
                            Locais: "<%= ref("Locais") %>",
                            ObsAgenda: "<%= ObsAgenda %>",
                            strAB: '<%= strAB %>',
                            CarrinhoID: <%= ac("id") %>,
                            diaN: <%= diaN %>,
                            ocor: <%= ocor %>, 
                            ProcedimentoID: '<%= ProcedimentoID %>'
                        }, function (data) { $('#pf<%= ac("id") &"_"& diaN &"_"& comGrade("ProfissionalID") %>').html(data) });
                    </script>


        <%
        comGrade.movenext
        wend
        comGrade.close
        set comGrade=nothing
        %>
        </tr>
        <%
        diaN = diaN+1
    wend
ac.movenext
wend
ac.close
set ac = nothing
%>
</table>
<% if ocor = 0 then %>
    <div style='text-align:center'>Nenhum horário disponível para a busca</div>
<% else %>
    <div style='text-align:center'><i class='far fa-circle-o-notch fa-spin'></i> Carregando...</div>
<% end if %>

<script type="text/javascript">
function ocor(n) {
    if (n == <%= ocor %>){
        $.get("multiplaFiltrosHorarios.asp?Data=<%= ref("Data") %>&Regiao=<%= ref("Regiao")%>", function (data) {
            $("#divBusca").html(data);
        });
    }
}
</script>