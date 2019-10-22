<!--#include file="connect.asp"-->
<%
nova = "|522|909|84|90|100|107|207|214|408|450|811|105|1124|1169|274|1224|1165|935|856|1289|1294|600|1208|1352|1444|672|1297|1399|1459|"

'response.Write( datediff("n", "00:00:00", formatdatetime("00:30:00", 3)) )

set lic = db.execute("select l.*, c.Resultado, u.Email from cliniccentral.licencas l left join cliniccentral.conversaoagenda c on c.LicencaID=l.id left join cliniccentral.licencasusuarios u on u.LicencaID=l.id and Admin=1 where isnull(Excluido) and l.id not in(1283, 1284, 1285, 1286, 1287, 1288)")
while not lic.eof
	if isnull(lic("Resultado")) then
		if instr(nova, "|"&lic("id")&"|")>0 then
			Resultado = "S"
			Quantidade = 0
		else
			set vcaInt = db.execute("select * from information_schema.`COLUMNS` c where c.TABLE_SCHEMA='clinic"&lic("id")&"' and c.TABLE_NAME='assfixalocalxprofissional' and c.COLUMN_NAME='Intervalo'")
			if vcaInt.eof then
				db_execute("alter table clinic"&lic("id")&".assfixalocalxprofissional add column `Intervalo` INT(11) NULL DEFAULT NULL after `LocalID`")
			end if
			response.Write( lic("id") )
			set conf = db.execute("select count(*) Quantidade from clinic"&lic("id")&".assfixalocalxprofissional")
			Quantidade = ccur(conf("Quantidade"))
			if Quantidade=0 then
				'inicia  a conversao
				set h = db.execute("select * from clinic"&lic("id")&".horarios where Atende='S' and Dia<8")
				while not h.eof
					ProfissionalID = h("ProfissionalID")
					HoraDe = h("HoraDe")
					Intervalo = datediff("n", "00:00:00", formatdatetime(h("Intervalos"), 3))
					LocalID = 0
					Dia = h("Dia")
					if h("Pausa")="" then
						HoraFinal = h("HoraAs")
					else
						HoraFinal = h("PausaDe")
						
						HoraDe2 = h("PausaAs")
						HoraFinal2 = h("HoraAs")
						db_execute("insert into clinic"&lic("id")&".assfixalocalxprofissional (DiaSemana, HoraDe, HoraA, ProfissionalID, LocalID, Intervalo) values ("&Dia&", "&mytime(HoraDe2)&", "&mytime(HoraFinal2)&", "&ProfissionalID&", "&LocalID&", "&Intervalo&")")
					end if
					db_execute("insert into clinic"&lic("id")&".assfixalocalxprofissional (DiaSemana, HoraDe, HoraA, ProfissionalID, LocalID, Intervalo) values ("&Dia&", "&mytime(HoraDe)&", "&mytime(HoraFinal)&", "&ProfissionalID&", "&LocalID&", "&Intervalo&")")
				h.movenext
				wend
				h.close
				set h=nothing
		
				Resultado = "C"
			else
				Resultado = "P"
			end if
		end if
		db_execute("insert into cliniccentral.conversaoagenda (LicencaID, QtdQuadro, Resultado, Email) values ("&lic("id")&", "&Quantidade&", '"&Resultado&"', '"&lic("Email")&"')")
	end if
lic.movenext
wend
lic.close
set lic=nothing
%>
FEITO