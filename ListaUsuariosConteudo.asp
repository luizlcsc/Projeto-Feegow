<!--#include file="connect.asp"-->
<!--#include file="Classes/Connection.asp"-->
<div class="row">
    <div class="col-md-12">
        <table id="datatableUsuarios" class="table table-striped table-bordered table-hover">
            <thead>
                <tr class="primary">
                    <th>Licença</th>
                    <th>Nome</th>
                    <th>Tipo</th>
                    <th>E-mail</th>
                    <th>Empresa</th>
                </tr>
            </thead>
            <%
            Cupom   = ref("Cupom")&""
            Empresa = ref("Empresa")&""
            Tipo    = ref("Tipo")&""
            Nome    = ref("Nome")&""
            
            qUsuariosConteudoWhere = ""

            if Cupom<>"" then
                qUsuariosConteudoWhere = qUsuariosConteudoWhere&" AND Cupom LIKE '%"&Cupom&"%' "
            end if
            if Empresa<>"" then
                qUsuariosConteudoWhere = qUsuariosConteudoWhere&" AND l.id in ("&replace(Empresa, "|", "")&") "
            end if
            if Tipo<>"" then
                qUsuariosConteudoWhere = qUsuariosConteudoWhere&" AND lu.tipo like '"&Tipo&"' "
            end if
            if Nome<>"" then
                qUsuariosConteudoWhere = qUsuariosConteudoWhere&" AND lu.Nome like '%"&Nome&"%' "
            end if

            Quantidade = 0
            QuantSA = 0
            QuantCA = 0
            lastServerID = 0

            if Cupom = "" then
                Cupom = "UNIMEDLONDRINA"
            end if

            sqlUsuariosConteudo = " SELECT l.id LicencaID, lu.Nome, lu.Tipo, lu.Email, l.NomeEmpresa, lu.Ativo, l.Servidor, lu.id, l.ServidorID"&chr(13)&_
                                    " FROM cliniccentral.licencasusuarios lu                                                "&chr(13)&_
                                    " LEFT JOIN cliniccentral.licencas l ON l.id=lu.licencaid                               "&chr(13)&_
                                    " WHERE TRUE "&qUsuariosConteudoWhere&"                                                 "&chr(13)&_
                                    " ORDER BY l.ServidorID ASC, l.NomeEmpresa ASC, lu.Nome ASC                             "&chr(13)&_
                                    "                                                                                       "
            'response.write("<pre>"&sqlUsuariosConteudo&"</pre>")
            set usu = db.execute(sqlUsuariosConteudo)

            while not usu.EOF
                Quantidade = Quantidade + 1
                license_user = usu("LicencaID")
                type_user = lcase(usu("Tipo"))
                id_user = usu("id")
                server_user = usu("Servidor")
                server_id_user = usu("ServidorID")
                usuario_ativo = usu("Ativo")
                usuario_email = usu("Email")&""

                If usuario_email="" or usuario_ativo=0 then
                    inactive_user = true
                else
                    inactive_user = false
                End if

                'Criar nova conexao quando for de outro servidor
                If lastServerID <> server_id_user Then
                    set dbProvider = newConnection("clinic"&license_user, server_user)
                    lastServerID = lastServerID + 1
                End if

                sqlVerifyActiveUser = "SELECT p.Ativo FROM profissionais p WHERE p.id="&id_user  
                set AtivoSQL = dbProvider.execute(sqlVerifyActiveUser)
                if not AtivoSQL.eof then
                    if AtivoSQL("Ativo")<>"on" then
                        inactive_user = false
                    end if
                end if

                If inactive_user Then
                    Email = "<b><i>Sem acesso</i></b>"
                    cor = "danger"
                    QuantSA = QuantSA + 1
                Else
                    Email = usu("Email")
                    cor = "success"
                    QuantCA = QuantCA + 1
                End if
                %>

                <tbody>
                <tr class="<%=cor%>">
                    <td><%=usu("LicencaID")%></td>
                    <td><%=usu("Nome")%></td>
                    <td><%=type_user%></td>
                    <td><%=Email%></td>
                    <td><%=usu("NomeEmpresa")%></td>
                </tr>
                </tbody>
            <%
            usu.movenext
            wend
            usu.close
            set usu = nothing
            %>
        </table>
        <div class="mt5">
            <div class="col-md-12 text-success">
                Com acesso: <%=QuantCA%>
            </div>
            <div class="col-md-12 text-danger">
                Sem acesso: <%=QuantSA%>
            </div>
            <div class="col-md-12 text-dark">
                <b>Total: <%=Quantidade%></b>
            </div>
        </div>
    </div>
</div>
