<!--#include file="connect.asp"-->
    <%
function getPermissionDescription(perm)

    perm=trim(replace(perm,"|",""))

    tipoPerm = right(perm, 1)
    perm=left(perm, len(perm)-1)

    set PermissoesAdicionadasSQL = db.execute("SELECT Acao, Categoria FROM cliniccentral.sys_permissoes WHERE nome in ('"&perm&"')")

    if not PermissoesAdicionadasSQL.eof then
        if tipoPerm="A" then
            tipoPerm="Alterar"
        elseif tipoPerm="I" then
            tipoPerm="Inserir"
        elseif tipoPerm="X" then
            tipoPerm="Excluir"
        elseif tipoPerm="V" then
            tipoPerm="Visualizar"
        end if

        perm = PermissoesAdicionadasSQL("Acao")&" ( "&tipoPerm&" )"

        getPermissionDescription=perm
    end if
end function
    if req("Impressao")="" then
    %>
    <div class="panel-heading">
        <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        <h4 class="modal-title"><i class="far fa-history"></i> Histórico de Ações</h4>
    </div>
    <div class="panel-body" style="overflow-x: scroll">
        <%
        else
        %>
        <h2>Histórico de ações</h2><br>
        <%
        end if
        %>
        <div class="row">
            <div class="col-md-12">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th>Data</th>
                            <th>Usuário</th>
                            <th>Obs.</th>
                            <th>Permissões removidas</th>
                            <th>Permissões adicionadas</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        c=0
                        if req("I")<>"" then
                            colspan = 2
                            'aqui eh direto da pagina do registro
                            set plog = db.execute("select * from log where lower(recurso)=lower('"&req("R")&"') and I="&req("I")&" order by DataHora desc limit 3000")
                        else
                            colspan = 5
                            'aqui eh direto da central de logs
                            if ref("Usuario")<>"" then
                                sqlUser = " and sysUser="&ref("Usuario")
                            end if
                            sql = "select * from log where lower(recurso)=lower('"&ref("Recurso")&"') "& sqlUser &" AND Date(DataHora) BETWEEN "& mydatenull(ref("De")) &" AND "& mydatenull(ref("Ate")) &" order by DataHora desc limit 3000"

                            set plog = db.execute(sql)
                        end if
                        while not plog.eof
                            colunas = plog("colunas")
                            valorAnterior = plog("ValorAnterior")
                            valorAtual = plog("ValorAtual")
                            splCol = split(colunas&"", "|")
                            splValAnt = split(valorAnterior&"", "|^")
                            splValAtu = split(valorAtual&"", "|^")

                            Operacao = plog("Operacao")
                            Op = "Inserção"

                            if Operacao="E" then
                                Op = "Edição"
                            end if

                            if Operacao="X" then
                                Op = "Exclusão"
                            end if

                            if req("I")="" then
                                set sr = db.execute("select initialOrder from cliniccentral.sys_resources where tableName='"& ref("Recurso") &"'")
                                if not sr.eof then
                                    initialOrder = sr("initialOrder")
                                    if isnull(initialOrder) then
                                        initialOrder="id"
                                    end if
                                    set reg = db.execute("select "& initialOrder &" from `"& ref("recurso") &"` where id="& treatvalzero(plog("I")))
                                    if not reg.eof then
                                        NomeRegistro = plog("I") &": "& reg(""&sr("initialOrder")&"")
                                    end if
                                end if
                            end if


                                for i=0 to ubound(splCol)

                                c=c+1
                                    if splValAnt(i)<>splValAtu(i) or plog("ValorAnterior")=""  then


                                    anterior = splValAnt(i)
                                    atual = splValAtu(i)

                                    permissoesAdicionadas = ""
                                    permissoesRemovidas = ""

                                    spltAtual = split(atual, ",")
                                    spltAnterior = split(anterior, ",")

                                    for f=0 to ubound(spltAtual)
                                        permissao = spltAtual(f)

                                        if instr(anterior, permissao)=0 then
                                            permissoesAdicionadas = permissoesAdicionadas&"<span class='label label-success'>"&getPermissionDescription(permissao)&"</span> <br>"

                                        end if
                                    next


                                    for j=0 to ubound(spltAnterior)
                                        permissao = spltAnterior(j)

                                        if instr(atual, permissao)=0 then
                                            permissoesRemovidas = permissoesRemovidas &"<span class='label label-danger'>"&getPermissionDescription(permissao)&"</span> <br>"

                                        end if
                                    next

                                    %>
                                    <tr>
                                        <%if UltimaData = plog("DataHora") then %>
                                            <td colspan="<%=colspan %>"></td>
                                        <%else %>
                                            <th><%=plog("DataHora") %></th>
                                            <th><%=nameInTable(plog("sysUser")) %></th>
                                        <%end if %>
                                        <td><%=plog("Obs") %></td>
                                        <td><%=permissoesRemovidas %></td>
                                        <td><%=permissoesAdicionadas %></td>
                                    </tr>
                                    <%
                                    UltimaData = plog("DataHora")

                                    end if
                                next

                             plog.movenext

                            wend
                            plog.close
                            set plog=nothing

                        if c=0 then
                        %>
                        <tr>
                            <td colspan="5">Nenhuma ação registrada.</td>
                        </tr>
                        <%
                        end if
                        %>
                    </tbody>
                </table>
            </div>
        </div>
        <%
        if req("Impressao")="" then
        %>
        </div>
        <%
        end if
        %>