<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
Save = req("Save")


VersaoDe = session("PastaAplicacaoRedirect")
VersaoPara = req("Versao")



if Save&""="1" then
     MotivoID = ref("MotivoID")
     Comentario = ref("Comentario")

    dbc.execute("INSERT INTO `cliniccentral`.`licenca_versao` (`LicencaID`, `VersaoDe`, `VersaoPara`, `Comentarios`, `sysUser`, `MotivoID`) VALUES ("&LicenseID&", '"&VersaoDe&"', '"&VersaoPara&"', '"&Comentario&"', '"&session("User")&"', '"&MotivoID&"'); ")

    response.write("OK")
    Response.End
end if

%>
<div class="row">
    <div class="col-md-12">
        <p>Para que possamos melhorar, por favor compartilhe conosco o motivo da troca da versão.</p>
    </div>

    <%= quickField("simpleSelect", "MotivoID", "Qual motivo da troca?", 6, "", "select * from cliniccentral.motivo_troca_versao where 1 order by Motivo", "Motivo", " required ") %>

    <%=quickfield("memo", "Comentario", "O que ocorreu?", 12, "", "", "", " required ")%>

</div>
