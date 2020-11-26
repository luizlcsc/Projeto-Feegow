<!--#include file="connect.asp"-->
    <%
    if req("Impressao")="" then
    %>
    <div class="panel-heading">
        <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        <h4 class="modal-title"><i class="fa fa-history"></i> Histórico de Ações</h4>
    </div>
    <div class="panel-body">
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
                            <%if req("I")="" then %>
                            <th width="1"></th>
                            <th>Registro</th>
                            <th>Operação</th>
                            <%end if %>
                            <th>ID</th>
                            <th>Registro</th>
                            <th>Data</th>
                            <th>Usuário</th>
                            <th>Obs.</th>
                            <th>Campo</th>
                            <th>Valor Anterior</th>
                            <th>Valor Alterado</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        c=0
                        if req("I")<>"" then
                            colspan = 4
                            'aqui eh direto da pagina do registro
                            set plog = db.execute("select * from log where lower(recurso)=lower('"&req("R")&"') and I="&req("I")&" order by DataHora desc limit 3000")
                        else
                            colspan = 6
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
                                set sr = db.execute("select initialOrder, Pers from cliniccentral.sys_resources where tableName='"& ref("Recurso") &"'")
                                if not sr.eof then
                                    initialOrder = sr("initialOrder")
                                    Pers = sr("Pers")
                                    if isnull(initialOrder) then
                                        initialOrder="id"
                                    end if
                                    set reg = db.execute("select "& initialOrder &" from `"& ref("recurso") &"` where id="& treatvalzero(plog("I")))
                                    if not reg.eof then
                                        NomeRegistro = plog("I") &": "& reg(""&sr("initialOrder")&"")
                                    end if
                                end if
                            end if

                            if Operacao="X" then
                                    %>
<tr>
<%if req("I")="" then %>
    <td class="p5 mn">
        <a disabled href="./?P=logRedir&LI=<%=plog("id") %>&Pers=1" class="btn btn-xs btn-primary"><i class="fa fa-external-link"></i></a>
    </td>
    <td>
        <%= NomeRegistro %>
    </td>
    <td>
        <%= Op %>
    </td>
<%
end if

    valorAntigo = " - "
    if ref("recurso") = "sys_financialinvoices" then
        valorAntigo = accountName(splValAnt(2), splValAnt(1))
        valorAntigo = valorAntigo & " - R$ " & formatnumber(splValAnt(3),2)
    elseif ref("recurso") = "sys_financialmovement" then
        valorAntigo = accountName(splValAnt(2), splValAnt(3))
        valorAntigo = valorAntigo & " - R$ " & formatnumber(splValAnt(7),2)
        
        set payment = db.execute("select PaymentMethod from cliniccentral.sys_financialpaymentmethod where id="& splValAnt(4) &" ")
        if not payment.eof then
            valorAntigo = valorAntigo & "<br>Forma de pagamento: " & payment("PaymentMethod")
        end if

        valorAntigo = valorAntigo & "<br>Data do pagamento: " & splValAnt(8)
    end if

%>
    <th><code>#<%=plog("I") %></code></th>
    <th><small><%=plog("PaiID") %></small></th>
    <th><%=plog("DataHora") %></th>
    <th><%=nameInTable(plog("sysUser")) %></th>
    <th><%=plog("Obs") %></th>
    <td>-</td>
    <td><%=valorAntigo%></td>
    <td><%=plog("valorAtual")%></td>
</tr>
                                    <%
                                c=c+1
                            else
                                for i=0 to ubound(splCol)

                                c=c+1
                                    if splValAnt(i)<>splValAtu(i) or plog("ValorAnterior")=""  then
                                    %>
                                    <tr>
                                        <%if UltimaData = plog("DataHora") then %>
                                            <td colspan="<%=colspan %>"></td>
                                        <%else %>
                                            <%if req("I")="" then

                                                %>
                                            <td class="p5 mn">
                                                <%
                                                externalLinkDisabled = ""

                                                if isnull(Pers) then
                                                    externalLinkDisabled=" disabled "
                                                end if
                                                %>
                                                <a <%=externalLinkDisabled%> href="./?P=logRedir&LI=<%=plog("id") %>&Pers=1" class="btn btn-xs btn-primary"><i class="fa fa-external-link"></i></a>
                                            </td>
                                            <td>
                                                <%= NomeRegistro %>
                                            </td>
                                            <td>
                                                <%= Op %>
                                            </td>
                                            <%end if %>
                                            <th><code>#<%=plog("I") %></code></th>
                                            <th><small><%=plog("PaiID") %></small></th>
                                            <th>

                                                <%=plog("DataHora") %></th>
                                            <th><%=nameInTable(plog("sysUser")) %></th>
                                            <th><%=plog("Obs") %></th>
                                        <%end if %>
                                        <td><%=splCol(i) %></td>
                                        <td><%=splValAnt(i) %></td>
                                        <td><%=splValAtu(i) %></td>
                                    </tr>
                                    <%
                                    UltimaData = plog("DataHora")

                                    end if
                                next
                                end if

                             plog.movenext

                            wend
                            plog.close
                            set plog=nothing

                        if c=0 then
                        %>
                        <tr>
                            <td colspan="8">Nenhuma ação registrada.</td>
                            <td></td>
                            <td></td>
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