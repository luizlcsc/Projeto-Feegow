<!--#include file="connect.asp"-->
<!--#include file="classes/arquivo.asp"-->
<%
sqllicencas = "SELECT u.licencaID, l.NomeEmpresa, l.Logo"& _
              " FROM cliniccentral.licencasusuarios AS u "&_
              " LEFT JOIN cliniccentral.licencas AS l ON l.id=u.LicencaID "&_
              " WHERE u.Email= (select email from cliniccentral.licencasusuarios where id="&session("user")&") "

set licencas = db.execute(sqllicencas)

%>

<div class="modal-header">
    <h4 class="modal-title">Seleção de Licença</h4>
</div>
<div class="modal-body">

    <div class="row">
        <div class="col-md-12">
            <p>Selecione a <strong>Licença</strong> que deseja entrar:</p>
        </div>
        <%
        if not licencas.eof then
            while not licencas.eof
                set empresa = db.execute("select nomeempresa,nomefantasia, foto from clinic"&licencas("licencaID")&".empresa where id=1")
                NomeEmpresa = licencas("NomeEmpresa")
                FotoEmpresa = "https://via.placeholder.com/200?text=Sem foto"
                
                if not empresa.eof then
                    NomeEmpresa =empresa("nomefantasia")
                    if empresa("foto")&"" <>"" then
                        FotoEmpresa = findFile( empresa("foto"), "perfil", licencas("licencaID"))
                    end if 
                end if 
                
                %>
                <div class="col-md-6 pt10">
                    <a  style="font-size: 11px" 
                        href="?P=ChangeCp&Pers=1&LicID=<%=licencas("licencaID")%>" 
                        class="btn btn-block">
                    <img src="<%=FotoEmpresa%>">
                    <p><%=NomeEmpresa%></p>
                    </a>
                </div>
                <%
            licencas.movenext
            wend
            licencas.close
            set licencas=nothing
        end if
        %>
    </div>
</div>