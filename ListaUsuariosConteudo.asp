<!--#include file="connect.asp"-->

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
            Cupom = ref("Cupom")&""
            Empresa = ref("Empresa")&""
            Tipo = ref("Tipo")&""
            Nome = ref("Nome")&""

            sqlEmpresa=""
            if Empresa<>"" then
                ListaEmpresas = replace(Empresa, "|", "")
                sqlEmpresa = " AND l.id in ("&ListaEmpresas&") "
            end if

            sqlTipo=""
            if Tipo<>"" then
                sqlTipo = " AND lu.tipo like '"&Tipo&"' "
            end if

            sqlNome=""
            if Nome<>"" then
                sqlNome = " AND lu.Nome like '%"&Nome&"%' "
            end if


            Quantidade = 0
            QuantSA = 0
            QuantCA = 0
            set usu = db.execute("select l.id LicencaID, lu.Nome, lu.Tipo, lu.Email, l.NomeEmpresa from cliniccentral.licencasusuarios lu left join cliniccentral.licencas l on l.id=lu.licencaid where l.cupom like '"&Cupom&"' "&sqlEmpresa&" "&sqlTipo&" "&sqlNome&" order by l.NomeEmpresa asc, lu.Nome asc")
            while not usu.EOF
                Quantidade = Quantidade + 1
                if usu("Email")&""="" then
                    Email = "<b><i>Sem acesso</i></b>"
                    cor = "danger"
                    QuantSA = QuantSA + 1
                else
                    Email = usu("Email")
                    cor = "success"
                    QuantCA = QuantCA + 1
                end if
                %>

                <tbody>
                <tr class="<%=cor%>">
                    <td><%=usu("LicencaID")%></td>
                    <td><%=usu("Nome")%></td>
                    <td><%=lcase(usu("Tipo"))%></td>
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
