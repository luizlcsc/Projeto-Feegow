<!--#include file="connect.asp"-->
<%
ConvenioID = req("ConvenioID")
PlanoID = req("PlanoID")

if ref("gPacienteID")<>"" then
	set paccon = db.execute("select * from pacientes where id like '"&ref("gPacienteID")&"' and ConvenioID1 like '"&ConvenioID&"'")
	if not paccon.eof then
		if not isnull(paccon("PlanoID1")) AND paccon("PlanoID1") <> "0" then
			PlanoID = paccon("PlanoID1")
		end if
	end if
end if
%>
<!--#include file="tissplanosguia.asp"-->