<!--#include file="connect.asp"-->
<%
on error resume next

set lic = db.execute("select l.* from cliniccentral.licencas l where isnull(Excluido) and l.id not in(1283, 1284, 1285, 1286, 1287, 1288)")
while not lic.eof
	set vca = db.execute("select i.TABLE_NAME from information_schema.`TABLES` i where i.TABLE_SCHEMA='clinic"&lic("id")&"' and i.TABLE_NAME='agendaocupacoes'")
	if vca.eof then
		Tem = "N"
		db_execute("create TABLE `clinic"&lic("id")&"`.`agendaocupacoes` (	`id` INT(11) NOT NULL AUTO_INCREMENT,	`Data` DATE NULL DEFAULT NULL,	`ProfissionalID` INT(11) NULL DEFAULT NULL,	`HLivres` INT(11) NULL DEFAULT NULL,	`HAgendados` INT(11) NULL DEFAULT NULL,	`HBloqueados` INT(11) NULL DEFAULT NULL,	PRIMARY KEY (`id`)) COLLATE='utf8_general_ci' ENGINE=MyISAM")
	else
		Tem = ""
	end if
	%><%=lic("id") &" -&gt; "& Tem %><br><%
lic.movenext
wend
lic.close
set lic=nothing
%>