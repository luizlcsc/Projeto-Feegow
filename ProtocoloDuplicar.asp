<!--#include file="connect.asp"-->
<%
ProtocoloID = req("I")
set getProtocolo = db.execute("SELECT * FROM protocolos WHERE id="&ProtocoloID)
set getKits = db.execute("SELECT * FROM protocoloskits WHERE ProtocoloID="&ProtocoloID&" ORDER BY id ")
set getMedicamentos = db.execute("SELECT * FROM protocolosmedicamentos WHERE ProtocoloID="&ProtocoloID&" ORDER BY id ")

set ultimoProtocolo = db.execute("SELECT id FROM protocolos ORDER BY id DESC LIMIT 1")
if not ultimoProtocolo.eof then
    idProtocoloNovo = ultimoProtocolo("id")+1
end if

if not getProtocolo.eof then
    db.execute("INSERT INTO protocolos (id, NomeProtocolo, GrupoID, Procedimentos, Referencia, NCiclos, AUC, Marcacao, MaxDias, Periodicidade, Duracao, Ativo, sysActive, sysUser) "&_
                "VALUES ("&idProtocoloNovo&", '"&getProtocolo("NomeProtocolo")&" - Cópia"&"', "&treatvalzero(getProtocolo("GrupoID"))&", '"&getProtocolo("Procedimentos")&"', '"&getProtocolo("Referencia")&"', "&treatvalzero(getProtocolo("NCiclos"))&", "&treatvalzero(getProtocolo("AUC"))&", "&treatvalzero(getProtocolo("Marcacao"))&", "&treatvalzero(getProtocolo("MaxDias"))&", "&treatvalzero(getProtocolo("Periodicidade"))&", "&treatvalzero(getProtocolo("Duracao"))&", 'on', 1, "&session("User")&" )")
end if

while not getKits.eof
    db.execute("INSERT INTO protocoloskits (ProtocoloID, KitID, sysActive, sysUser ) "&_
                "VALUES ("&idProtocoloNovo&" , "&treatvalzero(getKits("KitID"))&", 1, "&session("User")&" ) ")
getKits.movenext
wend
getKits.close
set getKits=nothing


while not getMedicamentos.eof
    db.execute("INSERT INTO protocolosmedicamentos (ProtocoloID, Medicamento, Dose, Dias, Ciclos, Obs, DiluenteID, QtdDiluente, ReconstituinteID, QtdReconstituinte, sysActive, sysUser ) "&_
                   "VALUES ("&idProtocoloNovo&" , "&treatvalzero(getMedicamentos("Medicamento"))&", "&treatvalzero(getMedicamentos("Dose"))&", '"&getMedicamentos("Dias")&"', '"&getMedicamentos("Ciclos")&"', '"&getMedicamentos("Obs")&"', "&treatvalzero(getMedicamentos("DiluenteID"))&", "&treatvalzero(getMedicamentos("QtdDiluente"))&", "&treatvalzero(getMedicamentos("ReconstituinteID"))&", "&treatvalzero(getMedicamentos("QtdReconstituinte"))&", 1, "&session("User")&" ) ")
getMedicamentos.movenext
wend
getMedicamentos.close
set getMedicamentos=nothing

%>

new PNotify({
    title: 'Sucesso!',
    text: 'Protocolo Copiado',
    type: 'alert',
    delay:1000
});