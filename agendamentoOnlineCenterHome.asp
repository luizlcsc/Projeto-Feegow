<!--#include file="connect.asp"-->
            <div class="row">
                <%
                Filtros = getConfAO("filtros")&""
                if instr(Filtros, "|Especialidade|")>0 then
                        response.write( quickfield("simpleSelect", "Especialidade", "Especialidade", 3, req("Especialidade"), "select id, Especialidade FROM especialidades where sysActive=1 ORDER by Especialidade", "Especialidade", ""))
                end if
                if instr(Filtros, "|Procedimento|")>0 then
                        response.write( quickfield("simpleSelect", "Procedimento", "Procedimento", 3, req("Procedimento"), "select id, NomeProcedimento FROM procedimentos where sysActive=1 AND Ativo='on' ORDER by NomeProcedimento", "NomeProcedimento", ""))
                end if
                if instr(Filtros, "|Convenio|")>0 then
                        response.write( quickfield("simpleSelect", "Convenio", "Convênio", 3, req("Convenio"), "select id, NomeConvenio FROM convenios where sysActive=1 AND Ativo='on' ORDER by NomeConvenio", "NomeConvenio", ""))
                end if
                if instr(Filtros, "|Unidade|")>0 then
                        response.write( quickfield("simpleSelect", "Unidade", "Unidade", 3, req("Unidade"), "select '0' id, NomeFantasia Nome from empresa UNION ALL select id, NomeFantasia FROM sys_financialcompanyunits where sysActive=1 ORDER BY Nome", "Nome", ""))
                end if

                %>
            </div>
            <div class="row mt-5">
                <div class="col-12 text-center">
                    <%
                    'botoes das abas
                    set abas = db.execute("select * from aoabas order by id")
                    while not abas.eof
                        Rotulo = abas("Rotulo")&""
                        Tabela = abas("Tabela")
                        Icone = abas("Icone")
                        if Tabela="Tipo" AND Rotulo="" then
                            set v = db.execute("select TipoProcedimento FROM tiposprocedimentos WHERE id="& abas("ItemID"))
                            if not v.eof then
                                Rotulo = v("TipoProcedimento")
                            end if
                        elseif Tabela="Grupo" AND Rotulo="" then
                            set v = db.execute("select NomeGrupo FROM procedimentosgrupos WHERE id="& abas("ItemID"))
                            if not v.eof then
                                Rotulo = v("NomeGrupo")
                            end if
                        end if
                        %>
                        <button type="button" class="btn btn-primary btn-lg py-4 btn-aba">
                            <i class="fs20 fas fa-<%= Icone %>" onclick="qualidometro(5)"></i>
                            <br>
                            <%= Rotulo %>
                        </button>
                        <%
                    abas.movenext
                    wend
                    abas.close
                    set abas = nothing
                    %>
                </div>
            </div>
            <div class="row mt-3">
                    <%

                    'conteudo das abas
                    set abas = db.execute("select * from aoabas order by id")
                    while not abas.eof
                        %>
                        <div class="col-md-10 offset-1">
                            <%
                            Tabela = abas("Tabela")
                            Agrupamento = abas("Agrupamento")
                            if Agrupamento="Especialidades" then
                                sqlEsp = "select e.id, e.Especialidade NomeItem from especialidades e "
                            end if

                            set itens = db.execute( sqlEsp )
                            while not itens.eof
                                %>
                                <div class="btn btn-block"><%= itens("NomeItem") %></div>
                                <%
                            itens.movenext
                            wend
                            itens.close
                            set itens = nothing
                            %>
                        </div>
                        <%
                    abas.movenext
                    wend
                    abas.close
                    set abas = nothing



                    %>
            </div>