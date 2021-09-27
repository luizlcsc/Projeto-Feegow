<!--#include file="connect.asp"-->
<%

pag = req("pag")
txt = replace(req("txt"), " ", "%")

if pag = "sys_preparos" then 
    set preparos = db.execute("select p.id as idpreparo, pt.Tipo TipoPreparo, pc.Combinacao, Descricao from sys_preparos p left join cliniccentral.preparostipo pt ON pt.id = p.Tipo  left join cliniccentral.preparoscombinacao pc ON pc.id = p.CombinacaoID " &_
                " where sysActive=1 and (Descricao like '%"& txt &"%' or pc.Combinacao like '%"& txt &"%')")
    if not preparos.eof then
    %>

    <table class="table table-striped table-bordered table-condensed">
        <thead>
            <tr class="primary">
                <th>Preparo</th>
                <th>Tipo</th>
                <th>Descrição</th>
                <th width="1%"></th>
            </tr>
        </thead>
        <tbody>
            <%
            while not preparos.eof
                %>
                <tr>
                    <td><%=preparos("Combinacao")%></td>
                    <td><%=preparos("TipoPreparo")%></td>
                    <td>
                    <a href="./?P=sys_preparos&I=<%=preparos("idpreparo")%>&Pers=0">
                    <%= preparos("Descricao") %></a></td>
                </tr>
                <%
            preparos.movenext
            wend
            preparos.close
            set preparos = nothing
            %>
        </tbody>
    </table>
    <%
    else
        %>
        Nenhum preparo  ativo com o termo '<%= txt %>'.
        <%
    end if
elseif pag = "sys_restricoes" then 
    set restricao = db.execute("select p.id as idrestricao, pt.Tipo TipoPreparo, Descricao, MostrarPorPadrao from sys_restricoes p left join cliniccentral.preparostipo pt ON pt.id = p.Tipo  " &_
                " where sysActive=1 and (Descricao like '%"& txt &"%')")
    if not restricao.eof then
    %>

    <table class="table table-striped table-bordered table-condensed">
        <thead>
            <tr class="primary">
                <th>Mostrar por padrão</th>
                <th>Tipo</th>
                <th>Descrição</th>
                <th width="1%"></th>
            </tr>
        </thead>
        <tbody>
            <%
            while not restricao.eof
                %>
                <tr>
                    <td><%=restricao("MostrarPorPadrao")%></td>
                    <td><%=restricao("TipoPreparo")%></td>
                    <td>
                    <a href="./?P=sys_restricoes&I=<%=restricao("idrestricao")%>&Pers=1">
                    <%= restricao("Descricao") %></a></td>
                </tr>
                <%
            restricao.movenext
            wend
            restricao.close
            set restricao = nothing
            %>
        </tbody>
    </table>
    <%
    else
        %>
        Nenhuma restrição ativa com o termo '<%= txt %>'.
        <%
    end if
end if
%>