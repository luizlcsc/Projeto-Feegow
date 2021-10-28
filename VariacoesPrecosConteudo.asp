<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->

<%
if req("X")<>"" and session("Admin")=1 then
    sqlDel = "delete from varprecos where id="&req("X")
    call gravaLogs(sqlDel, "AUTO", "", "")

    db_execute(sqlDel)
end if

if req("I")="" then
%>

    <table class="table table-condensed table-hover table-bordered">
        <thead>
            <tr class="dark">
                <th width="99%">REGRAS PARA VARIAÇÃO DE PREÇO</th>
                <th width="1%"></th>
            </tr>
        </thead>
        <tbody>
        <%
        set vp = db.execute("select * from varprecos")
        while not vp.eof
            response.flush()
            NomesProfissionais = ""
            classValor = ""
            DescricaoValor = ""
            NomesProcedimentos = "<b class='text-warning'>NENHUM PROCEDIMENTO SELECIONADO</b>"
            TabelasParticulares = ""
            Especialidades = vp("Especialidades")&""
            Profissionais = vp("Profissionais")&""
            Procedimentos = vp("Procedimentos")&""
            InicioNomesProcedimentos = ""
            Tabelas = vp("Tabelas")&""
            Unidades = vp("Unidades")&""
            erroProcedimentos = 0

if 0 then
            InicioNomesGrupos=""
            if instr(Procedimentos, "GRUPO")>0 then
                if instr(Procedimentos, "|EXCEPT|")>0 then
                    InicioNomesGrupos = "<b class='text-danger'>EXCETO OS GRUPOS: </b>"
                elseif instr(Procedimentos, "|ONLY|")>0 then
                    InicioNomesGrupos = "<b class='text-success'>SOMENTE OS GRUPOS: </b>"
                end if
            end if

            if instr(Procedimentos, "|ALL|")>0 then
                NomesProcedimentos = "<b>EM QUALQUER PROCEDIMENTO</b>"
                InicioNomesProcedimentos = ""
                Procedimentos = ""
            elseif instr(Procedimentos, "|EXCEPT|")>0 then
                InicioNomesProcedimentos = "<b class='text-danger'>EXCETO OS PROCEDIMENTOS: </b>"
                Procedimentos = replace(Procedimentos, "|EXCEPT|", "")
            elseif instr(Procedimentos, "|ONLY|")>0 then
                InicioNomesProcedimentos = "<b class='text-success'>SOMENTE OS PROCEDIMENTOS: </b>"
                Procedimentos = replace(Procedimentos, "|ONLY|", "")
            else
                erroProcedimentos = 1
            end if

            if Procedimentos<>"" then
                Procedimentos = "0"& Procedimentos
                NomeGrupos=""

                'aqui trata os grupos dos procedimentos
                if instr(Procedimentos, "GRUPO_")>0 then
                    ProcedimentosSplit = split(Procedimentos, ", ")
                    ProcedimentosNovo = ""
                    for i=0 to ubound(ProcedimentosSplit)
                        ItemLocalGrupo = ProcedimentosSplit(i)

                        if instr(ItemLocalGrupo, "GRUPO_")>0 then
                            GrupoID = replace(replace(ItemLocalGrupo, "GRUPO_", ""),"|","")
                            set GrupoSQL = db.execute("SELECT NomeGrupo FROM procedimentosgrupos WHERE id="&GrupoID&" AND sysActive=1")
                            if not GrupoSQL.eof then
                                NomeGrupos = NomeGrupos & ", "& GrupoSQL("NomeGrupo")
                            end if
                        else
                            if ProcedimentosNovo<>"" then
                                ProcedimentosNovo= ProcedimentosNovo&", "
                            end if
                            ProcedimentosNovo=ProcedimentosNovo&ItemLocalGrupo
                        end if
                    next
                    Procedimentos = ProcedimentosNovo
                else

                end if

                set procs = db.execute("select NomeProcedimento from procedimentos where id in ("& replace(Procedimentos, "|", "") &") and Ativo='on' order by NomeProcedimento")
                NomesProcedimentos = ""
                while not procs.eof
                    NomesProcedimentos = NomesProcedimentos & ", "& procs("NomeProcedimento")
                procs.movenext
                wend
                procs.close
                set procs = nothing
                NomesProcedimentos = InicioNomesProcedimentos & NomesProcedimentos

                if InicioNomesGrupos<> "" then
                    NomesProcedimentos = InicioNomesGrupos & NomeGrupos
                end if
            end if
end if
            'procedimentos/grupos (novo)
            inProcedimentos = ""
            inGrupos = ""
            if instr(Procedimentos, "|ALL|")>0 then
                NomesProcedimentos = "<b>EM QUALQUER PROCEDIMENTO</b>"
                InicioNomesProcedimentos = ""
                Procedimentos = ""
            elseif instr(Procedimentos, "|EXCEPT|")>0 then
                NomesProcedimentos = ""
                InicioNomesProcedimentos = "<b class='text-danger'>EXCETO OS [rotulo]: </b>"
                Procedimentos = replace(Procedimentos, "|EXCEPT|", "")
            elseif instr(Procedimentos, "|ONLY|")>0 then
                NomesProcedimentos = ""
                InicioNomesProcedimentos = "<b class='text-success'>SOMENTE OS [rotulo]: </b>"
                Procedimentos = replace(Procedimentos, "|ONLY|", "")
            else
                erroProcedimentos = 1
            end if

            if Procedimentos<>"" then
                splProc = split( replace(Procedimentos, "|", ""), ", ")
                for i=0 to ubound(splProc)
                    if isnumeric(splProc(i)) then
                        inProcedimentos = inProcedimentos & ", "& splproc(i)
                    else
                        if instr(splproc(i), "GRUPO_")>0 then
                            inGrupos = inGrupos & ", "& replace(splproc(i), "GRUPO_", "")
                        end if
                    end if
                next
                if inProcedimentos<>"" and inGrupos="" then
                    rotuloProc = "PROCEDIMENTOS"
                elseif inGrupos<>"" and inProcedimentos="" then
                    rotuloProc = "GRUPOS"
                elseif inGrupos<>"" and inProcedimentos<>"" then
                    rotuloProc = "GRUPOS/PROCEDIMENTOS"
                end if

                if inProcedimentos<>"" then
                    set pproc = db.execute("select group_concat(NomeProcedimento order by NomeProcedimento separator ', ') Procedimentos from procedimentos where id in(0"& inProcedimentos &") and Ativo='on' order by NomeProcedimento")
                    NomesProcedimentos = pproc("Procedimentos")&"<br>"
                end if
                if inGrupos<>"" then
                    set pgru = db.execute("select group_concat(NomeGrupo separator ', ') Grupos from procedimentosgrupos where id in(0"& inGrupos &") and sysActive=1 order by NomeGrupo")
                    NomesProcedimentos = NomesProcedimentos & pgru("Grupos")&""
                end if

                InicioNomesProcedimentos = replace(InicioNomesProcedimentos, "[rotulo]", rotuloProc)
                NomesProcedimentos = InicioNomesProcedimentos & NomesProcedimentos
            end if


            if erroProcedimentos then
                NomesProcedimentos = "<b class='text-danger'><i class='far fa-exclamation-triangle'></i> VOCÊ NÃO DEFINIU SE ESTA REGRA VALE PARA TODOS OS PROCEDIMENTOS OU PARA ALGUNS. </b>"
            end if

            if profissionais<>"" then
                sqlProfs = "select NomeProfissional from profissionais where id in ("& replace(Profissionais, "|", "") &") and Ativo='on' order by trim(NomeProfissional)"
                'response.write( sqlProfs )
                set profs = db.execute( sqlProfs)
                NomesProfissionais = ""
                while not profs.eof
                    NomesProfissionais = NomesProfissionais & ", " & profs("NomeProfissional")
                profs.movenext
                wend
                profs.close
                set profs=nothing
                NomesProfissionais = "<b class='text-success'>SOMENTE OS PROFISSIONAIS: </b>"& NomesProfissionais
            else
                NomesProfissionais = "<b>QUALQUER PROFISSIONAL</b>"
            end if

            if Especialidades<>"" then
                sqlEsps = "select especialidade from especialidades where id in ("& replace(Especialidades, "|", "") &") order by trim(Especialidade)"
                'response.write( sqlEsps )
                set esps = db.execute( sqlEsps)
                NomeEspecialidades = ""
                while not esps.eof
                    NomeEspecialidades = NomeEspecialidades & ", " & esps("especialidade")
                esps.movenext
                wend
                esps.close
                set esps=nothing
                NomeEspecialidades = "<b class='text-success'>SOMENTE AS ESPECIALIDADES: </b>"& NomeEspecialidades
            else
                NomeEspecialidades = "<b>QUALQUER ESPECIALIDADE</b>"
            end if
            if tabelas<>"" then
                set tabs = db.execute("select group_concat(NomeTabela separator ', ') TabelasParticulares from tabelaparticular where id in ("& replace(Tabelas, "|", "") &") order by NomeTabela")
                TabelasParticulares = "<b class='text-success'>SOMENTE PACIENTES DAS TABELAS:</b> "& tabs("TabelasParticulares")
            else
                TabelasParticulares = "<b>EM QUALQUER TABELA PARTICULAR</b>"
            end if

            Tipo = vp("Tipo")
            TipoValor = vp("TipoValor")
            Valor = fn(vp("Valor"))

            if Tipo="F" then
                DescricaoValor = "VALOR FIXO DE "
                classValor = "primary"
            elseif Tipo="D" then
                DescricaoValor = "DESCONTO DE "
                classValor = "danger"
            elseif Tipo="A" then
                DescricaoValor = "ACRÉSCIMO DE "
                classValor="system"
            end if

            if TipoValor="V" then
                preValor = "R$ "
                sufValor = ""
            else
                preValor = ""
                sufValor = "%"
            end if
            %>
            <tr>
                <td>
                    <i class="far fa-user-md text-primary"></i> <%= NomesProfissionais %><br />
                    <i class="far fa-user-md text-primary"></i> <%= NomeEspecialidades %><br />
                    <i class="far fa-money text-primary"></i> <%= TabelasParticulares %><br />
                    <% if session("Unidades")<>"|0|" then %>
                        <b>UNIDADES:</b> <%= Unidades %><br />
                    <% end if %>
                    <i class="far fa-stethoscope text-primary"></i> <%= NomesProcedimentos %><br />
                    <div class="label label-<%= classValor %>">
                        <%= DescricaoValor & preValor & Valor & sufValor %></div>
                <td>
                    <button type="button" onclick="editVP(<%= vp("id") %>)" class="btn btn-xs btn-success"><i class="far fa-edit"></i></button>
                    <br /><br />
                    <button type="button" onclick="if(confirm('Tem certeza de que deseja excluir esta regra?'))ajxContent('VariacoesPrecosConteudo&X=<%=vp("id") %>', '', 1, 'divVarPrecos');" class="btn btn-xs btn-danger btn-block"><i class="far fa-trash"></i></button>
                </td>
            </tr>
            <%

        vp.movenext
        wend
        vp.close
        set vp = nothing
        %>
        </tbody>
    </table>
<% else %>
    <div class="panel mbn">
        <form id="frmVP">
            <div class="panel-heading">
                <span class="panel-title">Configurações da Variação de Preço</span>
            </div>
            <div class="panel-body">
                <%
                set vp = db.execute("select * from varprecos where id="& req("I"))
                %>
                <%=quickField("simpleCheckbox", "ApenasPrimeiroAtendimento", "Apenas para o primeiro atendimento", "6", vp("ApenasPrimeiroAtendimento"), "", "", "")%>
                <br>
                <table class="table table-striped table-hover table-bordered">
                    <thead>
                        <tr class="info">
                            <th>Combinação</th>
                            <th>Procedimentos</th>
                            <th>Valor</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        response.buffer

                        while not vp.eof
                            response.flush()
                            Profissionais = vp("Profissionais")
                            Especialidades = vp("Especialidades")
                            Procedimentos = vp("Procedimentos")
                            Tabelas = vp("Tabelas")
                            Unidades = vp("Unidades")
                            Tipo = vp("Tipo")
                            TipoValor = vp("TipoValor")
                            Valor = fn(vp("Valor"))
                            if instr(Procedimentos, "|ALL|")>0 then
                                FiltroProcedimento = "|ALL|"
                            elseif instr(Procedimentos, "|EXCEPT|")>0 then
                                FiltroProcedimento = "|EXCEPT|"
                            elseif instr(Procedimentos, "|ONLY|")>0 then
                                FiltroProcedimento = "|ONLY|"
                            else
                                FiltroProcedimento = ""
                            end if
                        %>
                        <tr>
                            <td width="25%">
                            <%=quickfield("multiple", "Especialidades"&vp("id"), "Especialidades", 12, Especialidades, "SELECT l.id, l.especialidade FROM ( SELECT e.id, e.especialidade FROM especialidades e INNER JOIN profissionais p ON e.id = p.EspecialidadeID WHERE p.id IS NOT NULL AND p.Ativo = 'on'  UNION ALL  SELECT e.id, e.especialidade FROM profissionaisespecialidades pe INNER JOIN especialidades e ON e.id = pe.EspecialidadeID )l WHERE l.especialidade IS NOT NULL AND l.id NOT IN (168, 178, 290) group by l.id ORDER BY l.especialidade", "especialidade", "") %>
                            <br />
                            <%=quickfield("multiple", "Profissionais"&vp("id"), "Profissionais", 12, Profissionais, "select id, NomeProfissional from profissionais where Ativo='on' and sysActive=1 ORDER BY NomeProfissional", "NomeProfissional", "") %>
                            <br />
                            <%=quickfield("multiple", "Tabelas"&vp("id"), "Tabelas", 12, Tabelas, "select id, NomeTabela from tabelaparticular where sysActive=1 ORDER BY NomeTabela", "NomeTabela", "") %>
                            <br />
                            <%=quickfield("empresaMultiIgnore", "Unidades"&vp("id"), "Unidades", 12, Unidades, "", "", "") %>
                            </td>
                            <td width="55%">
                                <%=quickfield("simpleSelect", "Procedimentos"&vp("id"), "", 12, FiltroProcedimento, "select '|ALL|' id, 'Todos' Filtro UNION ALL select '|ONLY|', 'Somente' UNION ALL select '|EXCEPT|', 'Exceto'", "Filtro", " empty no-select2 semVazio") %><br />
                                <%=quickfield("multiple", "Procedimentos"&vp("id"), "", 4, Procedimentos, "select id, NomeProcedimento, 2 Tipo from procedimentos where sysActive=1 UNION ALL select CONCAT('GRUPO_',id), CONCAT('Grupo: ', NomeGrupo), 1 Tipo FROM procedimentosgrupos WHERE sysActive=1  ORDER BY Tipo, NomeProcedimento", "NomeProcedimento", "") %>
                            </td>
                            <td width="20%" nowrap>
                                <div class="input-group">
                                    <span class="input-group-addon">
                                        <select name="Tipo<%=vp("id") %>">
                                            <option value="D"<%if Tipo="D" then response.write(" selected ") end if %>>Desconto</option>
                                            <option value="A"<%if Tipo="A" then response.write(" selected ") end if %>>Acréscimo</option>
                                            <option value="F"<%if Tipo="F" then response.write(" selected ") end if %>>Valor Fixo</option>
                                        </select>
                                    </span>
					                <%=quickField("text", "Valor"&vp("id"), "", 12, fn(vp("Valor")), " input-mask-brl text-right", "", "")%>
                                    <span class="input-group-addon">
                                        <select class="select-group" name="TipoValor<%=vp("id")%>">
                                            <option value="P"<% If TipoValor="P" Then %> selected<% End If %>>%</option>
                                            <option value="V"<% If TipoValor="V" Then %> selected<% End If %>>R$</option>
                                        </select>
                                    </span>
                                </div>
                            </td>
                        <%
                        vp.movenext
                        wend
                        vp.close
                        set vp=nothing
                        %>
                        </tr>
                    </tbody>
                </table>

                <div class="row">
                    <div class="col-md-12 mt5" style="max-height: 250px; overflow-y: scroll">
                        <%
                        LogsItensInvoiceSQL = renderLogsTable("varprecos", req("I"), 0)
                        %>
                    </div>
                </div>

            </div>
            <div class="panel-footer">
                <div class="row">
                    <div class="col-md-12">
                        <button class="btn btn-success btn-sm pull-right"><i class="far fa-save"></i> SALVAR</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
    <script type="text/javascript">
        $("#frmVP").submit(function () {
            $.post("saveVP.asp?I=<%=req("I")%>", $(this).serialize(), function (data) {
                eval(data);
            });
            return false;
        });

        <!--#include file="JQueryFunctions.asp"-->
    </script>
<% end if %>