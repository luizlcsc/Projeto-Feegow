<!--#include file="connect.asp"-->
<%
session.Timeout=1000
'on error resume next
set plog = db.execute("select * from cliniccentral.logprofissionais where dados like 'I=%' order by DataHora limit 10000, 10000")
while not plog.eof
	campos = ""
	valores = ""
	dados = plog("dados")
	spl = split(dados, "&")
	sql = ""
	c=0
		for i = 0 to ubound(spl)
			spl2 = split(spl(i),"=")
			campo = spl2(0)
			valor = spl2(1)
			c=c+1
			if campo<>"" and campo<>"P" and  campo<>"searchPais" and campo<>"receituario" and campo<>"atestado" and campo<>"FormID" and campo<>"ModeloID" and instr(campo, "PacientesRelativos")=0 and instr(campo, "PacientesConvenios")=0 and instr(campo, "PacientesRetornos")=0 and instr(campo, "campo_")=0 then
				if campo="I" then
					campo="id"
				end if
				if campo="Nascimento" then
					valor = mydatenull(valor)
				elseif campo="Pais" or campo="Tabela" or campo="Sexo" or campo="EstadoCivil" or campo="CorPele" or campo="GrauInstrucao" or campo="Pais" then
					valor = treatvalnull(valor)
				else
					valor = "'"&replace(valor, "'", "''")&"'"
					valor = replace(valor, "+", " ")
				end if
				'campos = campos&", "&campo&"["&c&"]"
				'valores = valores&", "&valor&"["&c&"]"
				campos = campos&", "&campo
				valores = valores&", "&valor
			elseif campo="P" then
				tabela = valor
			end if
		next
		if instr(dados, "Usuario: 734")>0 or instr(dados, "Usuario: 736")>0 or instr(dados, "Usuario: 737")>0 or instr(dados, "Usuario: 738")>0 or instr(dados, "Usuario: 739")>0 or instr(dados, "Usuario: 740")>0 or instr(dados, "Usuario: 744")>0 or instr(dados, "Usuario: 745")>0 or instr(dados, "Usuario: 746")>0 or instr(dados, "Usuario: 747")>0 or instr(dados, "Usuario: 748")>0 or instr(dados, "Usuario: 749")>0 or instr(dados, "Usuario: 750")>0 or instr(dados, "Usuario: 751")>0 or instr(dados, "Usuario: 752")>0 or instr(dados, "Usuario: 753")>0 or instr(dados, "Usuario: 754")>0 or instr(dados, "Usuario: 756")>0 or instr(dados, "Usuario: 757")>0 or instr(dados, "Usuario: 758")>0 or instr(dados, "Usuario: 759")>0 or instr(dados, "Usuario: 760")>0 or instr(dados, "Usuario: 761")>0 or instr(dados, "Usuario: 762")>0 or instr(dados, "Usuario: 763")>0 or instr(dados, "Usuario: 764")>0 or instr(dados, "Usuario: 765")>0 or instr(dados, "Usuario: 766")>0 or instr(dados, "Usuario: 767")>0 or instr(dados, "Usuario: 768")>0 or instr(dados, "Usuario: 818")>0 or instr(dados, "Usuario: 819")>0 or instr(dados, "Usuario: 820")>0 or instr(dados, "Usuario: 821")>0 or instr(dados, "Usuario: 823")>0 or instr(dados, "Usuario: 824")>0 or instr(dados, "Usuario: 825")>0 or instr(dados, "Usuario: 826")>0 or instr(dados, "Usuario: 827")>0 or instr(dados, "Usuario: 828")>0 or instr(dados, "Usuario: 830")>0 or instr(dados, "Usuario: 832")>0 or instr(dados, "Usuario: 837")>0 or instr(dados, "Usuario: 838")>0 or instr(dados, "Usuario: 839")>0 or instr(dados, "Usuario: 840")>0 or instr(dados, "Usuario: 841")>0 or instr(dados, "Usuario: 842")>0 or instr(dados, "Usuario: 1096")>0 or instr(dados, "Usuario: 1416")>0 or instr(dados, "Usuario: 1528")>0 or instr(dados, "Usuario: 1593")>0 or instr(dados, "Usuario: 1608")>0 or instr(dados, "Usuario: 1610")>0 or instr(dados, "Usuario: 1611")>0 or instr(dados, "Usuario: 1631")>0 or instr(dados, "Usuario: 1650")>0 then
			'valores = left(valores, len(valores)-5)
			sql = "insert into clinic522.pacientes_recuperar ("&right(campos, len(campos)-2)&") values ("&right(valores, len(valores)-2)&")"
			%>
            <h1><%=tabela%></h1>
			<%=sql%>
			<hr>
			<%
			if lcase(tabela)="pacientes" then
				db.execute(sql)
			end if
		end if
plog.movenext
wend
plog.close
set plog=nothing
%>