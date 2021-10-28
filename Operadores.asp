<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<script >
$(".crumb-active a").html("Operadores");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Ativos");
    $(".crumb-icon a span").attr("class", "far fa-table");
</script>
<div class="panel mt15">
     <div class="panel-heading">
        <span class="panel-title">
            <i class="far fa-user-alt"></i> Operadores ativos
        </span>
        <span class="panel-controls">
            <button class="btn btn-sm btn-success" onclick="javascript:location.href='?P=Operador&I=N&Pers=1'"><i class="far fa-plus"></i> INSERIR</button>
        </span>
    </div>
    <div class="panel-body">
        <div class="row">
            <table class="table table-striped table-hover">
                <thead>
                    <th>Nome</th>
                    <th>E-mail</th>
                    <th>Status</th>
                    <th></th>
                </thead>
                <tbody>
                    <%
                    if req("X")<>"" and isnumeric(req("X")) then
                        dbc.execute("update cliniccentral.licencasusuariosmulti SET Ativo='' where Cupom='"&session("Partner")&"' AND id="&req("X")&" AND Admin=0")
                        response.Redirect("./?P=Operadores&Pers=1")
                    end if

                    set ops = dbc.execute("select * from cliniccentral.licencasusuariosmulti where Cupom='"&session("Partner")&"' ORDER BY Nome")
                    while not ops.eof
                        link = "./?P=Operador&Pers=1&I="&ops("id")
                        %>
                        <tr>
                            <td><a href="<%=link%>"><%=ops("Nome")%></a></td>
                            <td><%=ops("Email")%></td>
                            <td>
                                <%
                                if ops("Ativo")<>"on" then
                                    %>
                                    <span class="label label-danger">Inativo</span>
                                    <%
                                else
                                    %>
                                    <span class="label label-success">Ativo</span>
                                    <%
                                end if
                                %>
                            </td>
                            <td nowrap width="1%">
                                <a class="btn btn-xs btn-success" href="<%=link%>"><i class="far fa-edit"></i></a>
                                <%
                                if ops("Admin")=0 then
                                %>
                                    <a class="btn btn-xs btn-danger" href="javascript:if(confirm('Tem certeza de que deseja excluir este operador?'))location.href='./?P=Operadores&Pers=1&X=<%=ops("id")%>'"><i class="far fa-remove"></i></a>
                                <%
                                end if
                                %>
                            </td>
                        </tr>
                        <%
                    ops.movenext
                    wend
                    ops.close
                    set ops=nothing
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>