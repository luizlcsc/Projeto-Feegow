<!--#include file="connect.asp"-->
<%
RegraID=req("RegraID")
UnidadeID=session("UnidadeID")

set RegraSQL = db.execute("SELECT group_concat(Regra)regras FROM regraspermissoes WHERE id in ("&RegraID&")")

RegraIDArray = split(RegraID, ",")
For i = 0 to Ubound(RegraIDArray)
    RegraIDArray(i) = " su.Permissoes LIKE '%["&Trim(RegraIDArray(i))&"]%'  "
Next

RegraLike = Join(RegraIDArray, " or ")
if not RegraSQL.eof then
    sqlRegra = "SELECT su.id, und.NomeFantasia, su.UnidadeID FROM sys_users su "&_
                    " INNER JOIN (SELECT 'profissionais' Tipo, id, Ativo, NomeProfissional Nome FROM profissionais WHERE sysActive=1 UNION ALL SELECT 'funcionarios' Tipo,id, Ativo, NomeFuncionario Nome FROM funcionarios WHERE sysActive=1)tab ON tab.Tipo= su.Table AND tab.id = su.idInTable "&_
                    " LEFT JOIN (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)und ON und.id= su.UnidadeID "&_
                    " WHERE tab.Ativo='on' and ("&RegraLike&") ORDER BY tab.Nome"
    set UsuariosComRegraSQL = db.execute(sqlRegra)

    %>
    <div class="row">
        <div class="col-md-7">
            <h5>Selecione um usuário com perfil de <br><i><%=RegraSQL("regras")%></i>.</h5>
            <%
            while not UsuariosComRegraSQL.eof
                UserID=UsuariosComRegraSQL("id")

                Cor="#000"
                if UsuariosComRegraSQL("UnidadeID")=session("UnidadeID") then
                    Cor="#3588BF"
                end if
                %>
                <input type="radio" id="User<%=UserID%>" name="RegraUsuario" value="<%=UserID%>">
                <label for="User<%=UserID%>" style="color: <%=Cor%>;"><%=nameInTable(UserId)%> (<%=UsuariosComRegraSQL("NomeFantasia")%>)</label> <br>
                <%
            UsuariosComRegraSQL.movenext
            wend
            UsuariosComRegraSQL.close
            set UsuariosComRegraSQL=nothing
            %>
        </div>
        <div class="col-md-5">
            <label for="SenhaAdministrador">Senha do usuário</label>
            <input type="password" class="form-control" id="SenhaAdministrador" autocomplete="off">
        </div>
    </div>
    <%
end if
%>