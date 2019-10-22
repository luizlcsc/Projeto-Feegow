<!--#include file="connect.asp"--><%
response.charset="utf-8"
if req("FP")="" then
    set vca = db.execute("select * from cliniccentral.biometria")
    if vca.eof then
        %>Você não abriu a janela de cadastro de biometria no sistema.<%
    else
        response.write(vca("UsuarioID"))
    '    db.execute("delete from cliniccentral.biometria")
    end if
else
    set vca = db.execute("select * from cliniccentral.licencasusuarios where id="&req("FP"))
    if not vca.eof then
        response.Redirect("./../?P=Login&FP="&req("FP"))
    end if
end if
%>