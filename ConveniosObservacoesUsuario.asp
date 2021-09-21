<!--#include file="connect.asp"-->
<%

if req("Action") = "insert" then

    Usuarios = req("Usuarios")
    ConvenioID = req("I")
    DataInicio = req("DataInicio")
    DataFim = req("DataFim")
    Planos = req("Planos")
    Obs = ref("Obs")
    Obs = replace(Obs, """", """")

    db.execute("INSERT INTO convenio_observacao_usuario (sysUser, Usuarios, ConvenioID, DataInicio, DataFim, Obs, Planos) VALUES ("&session("User")&", '"&Usuarios&"', "&ConvenioID&", "&mydatenull(DataInicio)&", "&mydatenull(DataFim)&", '"&Obs&"', '"&Planos&"')")

elseif req("Action") = "update" then

    Usuarios = req("Usuarios")
    ConvenioID = req("I")
    DataInicio = req("DataInicio")
    DataFim = req("DataFim")
    Planos = req("Planos")
    Obs = ref("Obs")
    Obs = replace(Obs, """", """")
    id = req("id")

    db.execute("UPDATE convenio_observacao_usuario SET Usuarios = '"&Usuarios&"', ConvenioID = "&ConvenioID&", DataInicio = "&mydatenull(DataInicio)&", DataFim = "&mydatenull(DataFim)&", Obs = '"&Obs&"', Planos = '"&Planos&"' WHERE id = "&id&"")

elseif req("Action") = "delete" then

    id = req("id")
    db.execute("UPDATE convenio_observacao_usuario SET sysActive = -1 WHERE id = "&id&"")

else

    sql = "SELECT id, Usuarios, DataInicio, DataFim, Obs, Planos FROM convenio_observacao_usuario WHERE sysActive = 1 AND ConvenioID = "&req("I")
    set convenioObservacaoUsuario = db.execute(sql)

%>

        <% while not convenioObservacaoUsuario.eof %>
            <tr>
                <td class="text-center">
                    <% Usuarios = convenioObservacaoUsuario("Usuarios") %>
                    <%=quickField("multiple", "Usuarios"&convenioObservacaoUsuario("id"), "", 12, Usuarios, "SELECT id, Nome FROM (SELECT su.id,prof.NomeProfissional Nome FROM profissionais prof INNER JOIN sys_users su ON su.idInTable=prof.id AND su.table='profissionais' WHERE prof.Ativo='on' AND prof.sysActive=1 UNION ALL SELECT su.id,func.NomeFuncionario Nome FROM funcionarios func INNER JOIN sys_users su ON su.idInTable=func.id AND su.table='funcionarios' WHERE func.Ativo='on' AND func.sysActive=1)t ORDER BY t.Nome;", "Nome", " required")%>
                </td>
                <td class="text-center">
                     <% Planos = convenioObservacaoUsuario("Planos") %>
                     <%=quickField("multiple", "Planos"&convenioObservacaoUsuario("id"), "", 12, Planos, "SELECT id, NomePlano FROM ConveniosPlanos WHERE NomePlano<>'' AND NomePlano IS NOT NULL and sysActive = 1 AND ConvenioID = "&req("I"), "NomePlano", " required")%>
                 </td>
                <td class="text-center">
                    <% VigenciaInicio = convenioObservacaoUsuario("DataInicio") %>
                    <%=quickField("datepicker", "VigenciaInicio"&convenioObservacaoUsuario("id"), "", 12, VigenciaInicio, "", "", "")%>
                </td>
                <td class="text-center">
                    <% VigenciaFim = convenioObservacaoUsuario("DataFim") %>
                    <%=quickField("datepicker", "VigenciaFim"&convenioObservacaoUsuario("id"), "", 12, VigenciaFim, "", "", "")%>
                </td>
                <td class="text-center">
                    <% Obs = convenioObservacaoUsuario("Obs") %>
                    <%=quickField("editor", "Obs"&convenioObservacaoUsuario("id"), "", 12, Obs, "50", "", " "&disabled&" ")%>
                </td>
                <td class="text-center">
                    <button type="button" onclick="excluir('<%=convenioObservacaoUsuario("id")%>')" class="btn btn-xs btn-danger"><i class="far fa-trash"></i></button>
                </td>
            </tr>
        <%
           convenioObservacaoUsuario.movenext
           wend
           convenioObservacaoUsuario.close
           set convenioObservacaoUsuario=nothing
        %>

        <script>jqueryHelper();</script>

<% end if
%>