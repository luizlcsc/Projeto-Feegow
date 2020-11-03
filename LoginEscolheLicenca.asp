<!--#include file="connect.asp"-->
<!--#include file="classes/arquivo.asp"-->
<!--#include file="classes/Connection.asp"-->
<%
sqllicencas = "SELECT l.id LicencaID, l.NomeEmpresa, l.Logo,l.Servidor "& _
              " FROM cliniccentral.licencas AS l "&_
              " WHERE l.id IN ("&replace(session("Licencas"),"|","")&") "

set licencas = db.execute(sqllicencas)


IF session("UnidadeID") >= "0" THEN
    UnidadeID = session("UnidadeID")
END IF

%>

<div class="modal-header">
    <h4 class="modal-title">Seleção de Licença</h4>
</div>
<div class="modal-body">

    <div class="row">
        <div class="col-md-12">
            <p>Selecione a <strong>Licença</strong> que deseja acessar:</p>
        </div>
        <%
        if not licencas.eof then
            while not licencas.eof
                set connLicense = newConnection("clinic"&licencas("licencaID"), licencas("Servidor"))

                NomeEmpresa = licencas("NomeEmpresa")
                'FotoEmpresa = "https://via.placeholder.com/200?text=Sem foto"
                FotoEmpresa = "https://cdn.feegow.com/feegowclinic-v7/images/hospital-icon.png"

                set FotoSQL = connLicense.execute("SELECT Logo FROM sys_config WHERE id=1 and Logo Like 'http%'")
                if not FotoSQL.eof then
                    FotoEmpresa = FotoSQL("Logo")
                end if
                
                %>
                <div class="col-md-6 pt10">
                    <a  style="font-size: 11px" 
                        href="?P=ChangeCp&Pers=1&LicID=<%=licencas("licencaID")%>" 
                        class="btn btn-block">
                    <img style="height: 60px; width: auto" src="<%=FotoEmpresa%>">
                    <p class="mt10"><%=NomeEmpresa%></p>
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