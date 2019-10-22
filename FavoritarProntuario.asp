<!--#include file="connect.asp"-->
<%

idMedicamento = ref("id")
favorito = ref("favorito")
tipo = ref("tipo")
idUser = session("User")

if favorito = 1 then
    set sqlFavoritar = db.execute("insert into prontuariosfavoritos (TipoID, Tipo, sysUser, sysDate) values(" & idMedicamento & ", '" & tipo & "', " & idUser & ", now())")
    response.write("Prontuário adicionado aos favoritos")
else
    set sqlFavoritar = db.execute("delete from prontuariosfavoritos where TipoID = " & idMedicamento & " and Tipo = '" & tipo & "' and  sysUser = " & idUser)
    response.write("Prontuário retirado dos favoritos")
end if
%>