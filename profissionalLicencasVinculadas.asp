<!--#include file="connect.asp"-->
<%
ProfissionalIDMae = req("I")
LicencaIDMae = replace(session("Banco"),"clinic","")

qLicencasFilhoValidaSQL =   " SELECT                                                                            "&chr(13)&_
                            " pro.id AS ProfissionalIDMae, pro.NomeProfissional, pro.CPF,                       "&chr(13)&_
                            " sysUsu.id,                                                                        "&chr(13)&_
                            " lic.id AS licencaIDFilho, lic.NomeEmpresa AS LicencaNomeFilho                     "&chr(13)&_
                            "                                                                                   "&chr(13)&_
                            " FROM profissionais AS pro                                                         "&chr(13)&_
                            " LEFT JOIN sys_users AS sysUsu ON sysUsu.idInTable                                 "&chr(13)&_
                            " LEFT JOIN cliniccentral.licencasusuarios AS licUsu ON licUsu.id=sysUsu.id         "&chr(13)&_
                            " LEFT JOIN cliniccentral.licencas AS lic ON lic.LicencaIDMae=licUsu.LicencaID      "&chr(13)&_
                            " WHERE pro.id="&ProfissionalIDMae&"                                                "&chr(13)&_
                            " AND sysUsu.idInTable="&ProfissionalIDMae&" AND sysUsu.`Table`='profissionais'     "&chr(13)&_
                            " AND licUsu.LicencaID="&LicencaIDMae
'dd(qLicencasFilhoValidaSQL)
SET LicencasFilhoValidaSQL = db.execute(qLicencasFilhoValidaSQL)
if not LicencasFilhoValidaSQL.eof then
    while not LicencasFilhoValidaSQL.eof

        LicencaVinculadaBTN = ""

        ProfissionalIDMae_cpf = LicencasFilhoValidaSQL("CPF")
        licencaIDFilho        = LicencasFilhoValidaSQL("licencaIDFilho")
        LicencaNomeFilho      = LicencasFilhoValidaSQL("LicencaNomeFilho")

        licencaDB = "clinic"&licencaIDFilho
        
        '#VERIFICA SE A BASE EXISTE NO SERVIDOR
        qValidaDataBaseSQL =   " SELECT TABLE_SCHEMA "&chr(13)&_
                            " FROM `information_schema`.`COLUMNS` "&chr(13)&_
                            " WHERE TABLE_SCHEMA='"&licencaDB&"' "&chr(13)&_
                            " LIMIT 1 "
        'response.write("<pre>"&qValidaDataBaseSQL&"</pre>")
        SET ValidaDataBaseSQL = db.execute(qValidaDataBaseSQL)
        if ValidaDataBaseSQL.eof then
            profissionalFilho_login = "Erro na conexão com esta licença."
        else
            qProfissionaisFilhoSQL =    " SELECT pro.id AS profissionalIDFilho, pro.NomeProfissional,               "&chr(13)&_
                                        " licUsu.id AS usuarioIDFilho, licUsu.Email AS usuarioEmailFilho, licUsu.Nome AS usuarioNomeFilho, "&chr(13)&_
                                        " lpv.sysActive "&chr(13)&_
                                        " FROM "&licencaDB&".profissionais AS pro          "&chr(13)&_
                                        " LEFT JOIN "&licencaDB&".sys_users AS sysUsu ON sysUsu.idInTable=pro.id "&chr(13)&_
                                        " LEFT JOIN cliniccentral.licencasusuarios AS licUsu ON licUsu.id=sysUsu.id "&chr(13)&_   
                                        " LEFT JOIN cliniccentral.licencasprofissionaisvinculados lpv ON lpv.profissionalIDFilho = pro.id "&chr(13)&_                       
                                        " WHERE CPF ='"&ProfissionalIDMae_cpf&"'    "
            checked = ""

            SET ProfissionaisFilhoSQL = db.execute(qProfissionaisFilhoSQL)
                if ProfissionaisFilhoSQL.eof then
                    profissionalFilho_login = "Profissional não possui usuário ativo" 
                else
                    ProfissionalIDFilho = ProfissionaisFilhoSQL("profissionalIDFilho")
                    usuarioEmailFilho   = ProfissionaisFilhoSQL("usuarioEmailFilho")
                    usuarioNomeFilho    = ProfissionaisFilhoSQL("usuarioNomeFilho")
                    
                    profissionalFilho_login = usuarioEmailFilho&"<br><small><i>"&usuarioNomeFilho&"</i></small>"

                    if ProfissionaisFilhoSQL("sysActive") = 1 then
                        checked = "checked='checked'"
                    end if

                    LicencaVinculadaBTN =   "<div class='switch switch-info switch-inline'>"&chr(13)&_
                                            "    <input "&checked&" name='profissionalIDFilho"&ProfissionalIDFilho&"' id='profissionalIDFilho"&ProfissionalIDFilho&"' type='checkbox' value='1' onclick='ProfissionalVinculadoLicenca(`"&ProfissionalIDFilho&"`,`"&licencaIDFilho&"`)'/>"&chr(13)&_
                                            "    <label class='mn' for='profissionalIDFilho"&ProfissionalIDFilho&"'></label>"&chr(13)&_
                                            "</div>"
                end if
            ProfissionaisFilhoSQL.close
            set ProfissionaisFilhoSQL = nothing
            
        end if

        
        

        licencasVinculadasBaseHTML =    "<tr>"&_
                                            "<td>#"&licencaIDFilho&" ("&LicencaNomeFilho&")</td>"&_
                                            "<td>"&profissionalFilho_login&"</td>"&_
                                            "<td>"&LicencaVinculadaBTN&"</td>"&_
                                        "</tr>"

        if licencasVinculadasHTML="" then
            licencasVinculadasHTML = licencasVinculadasBaseHTML
        else
            licencasVinculadasHTML = licencasVinculadasHTML&licencasVinculadasBaseHTML
        end if     

        'response.write("Licença: Mae'"&LicencaMaeID&"' Filho'"&licencaIDFilho&"' | Profissional: Mae'"&ProfissionalMaeID&"' Filho'"&ProfissionalIDFilho&"'<br>")


    LicencasFilhoValidaSQL.movenext
    wend
    LicencasFilhoValidaSQL.close
    set LicencasFilhoValidaSQL = nothing
end if

'response.write(qLicencasFilhoValidaSQL)

%>

<form method="post" id="frm" name="frm" >
    <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">
                    <i class="far fa-unlock"></i>Licenças Vinculadas
                </span>
            </div>
        <div class="panel-body">
        <div class="panel panel-default">
            <div class="row">
                <div class="col-md-12 qf">
                    <table class="table table-fixed">
                        <thead>
                            <tr class="info">
                                <th>Licenças Vinculadas</th>
                                <th>Login de acesso</th>
                                <th width="100">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%=licencasVinculadasHTML%>
                        </tbody>
                    </table>
                </div>
            </div>
                <div class="row">

                </div>
        </div>
    </div>
</form>

<script>
function ProfissionalVinculadoLicenca(profissionalIDFilho,licencaIDFilho) {
    var vinculoStatus = $('#profissionalIDFilho'+profissionalIDFilho).is(':checked');
    confirmTxt = "Todos os bloqueios futuros serão removidos";
    
    if (vinculoStatus===true){
        confirmTxt = "Serão gerados bloqueios nas demais licenças a partir de hoje."
    }

    var r = confirm(confirmTxt);
    if (r == true) {
        $.post("profissionalLicencasVinculadasSave.asp", {
            profissionalIDFilho: profissionalIDFilho,
            licencaIDFilho: licencaIDFilho,
            profissionalIDMae: <%=ProfissionalIDMae%>,
            licencaIDMae: <%=LicencaIDMae%>,
            vinculoStatus: vinculoStatus
        }, function(result){
            eval(result);
        });          
    } else {
        vinculoStatus = vinculoStatus === true ? false : true;
    }
    $('#profissionalIDFilho'+profissionalIDFilho).prop("checked", vinculoStatus);
          
}
</script>
