<!--#include file="connectCentral.asp"-->
<%
response.charset="utf-8"

c = 0
set licsBCK = dbc.execute("select id, ultimoRefresh, ultimoBackup from licencas where not isnull(ultimoRefresh) and ((ultimoBackup<ultimoRefresh and ultimoBackup<   DATE_ADD(NOW(), INTERVAL -15 MINUTE)   ) or isnull(ultimoBackup)) and `Status`='C' LIMIT 10")
if not licsBCK.eof then
    dim fs, f
    set fs=Server.CreateObject("Scripting.FileSystemObject")
end if
while not licsBCK.eof
    c = c+1
    response.Write(licsBCK("id") &" - "& licsBCK("ultimoRefresh") &" - "& licsBCK("ultimoBackup") &"<br>")
    if fs.FolderExists("F:\backup\clinic"& licsBCK("id"))=0 then
      set f = fs.CreateFolder("F:\backup\clinic"& licsBCK("id"))
    end if

    fs.CopyFile "C:\ProgramData\MySQL\MySQL Server 5.6\Data\clinic"& licsBCK("id") &"\*", "F:\backup\clinic"& licsBCK("id") &"\"

    dbc.execute("update licencas set ultimoBackup=NOW() where id="& licsBCK("id"))
licsBCK.movenext
wend
licsBCK.close
set lics = nothing

if c>0 then
    set f=nothing
    set fs=nothing
end if

%>
Concluído - <%= c %> clínica(s).