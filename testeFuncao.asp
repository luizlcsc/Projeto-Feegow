<%
function tipoForm(T)
	select case T
	case "A"
		tipoForm="Anamnese"
	case "E"
		tipoForm="Evolu&ccedil;&atilde;o"
	case "L"
		tipoForm="Laudo"
	end select
end function

function tratoForm(palavra)
	tratoForm=lcase(replace(replace(palavra," ","_"),"'",""))
	tratoForm=replace(tratoForm,"�","c")
	tratoForm=replace(tratoForm,"�","a")
	tratoForm=replace(tratoForm,"�","e")
	tratoForm=replace(tratoForm,"�","i")
	tratoForm=replace(tratoForm,"�","o")
	tratoForm=replace(tratoForm,"�","u")
	tratoForm=replace(tratoForm,"�","a")
	tratoForm=replace(tratoForm,"�","e")
	tratoForm=replace(tratoForm,"�","i")
	tratoForm=replace(tratoForm,"�","o")
	tratoForm=replace(tratoForm,"�","u")
	tratoForm=replace(tratoForm,"�","a")
	tratoForm=replace(tratoForm,"�","e")
	tratoForm=replace(tratoForm,"�","i")
	tratoForm=replace(tratoForm,"�","o")
	tratoForm=replace(tratoForm,"�","u")
	tratoForm=replace(tratoForm,"�","a")
	tratoForm=replace(tratoForm,"�","e")
	tratoForm=replace(tratoForm,"�","i")
	tratoForm=replace(tratoForm,"�","o")
	tratoForm=replace(tratoForm,"�","u")
	tratoForm=replace(tratoForm,"~","")
	tratoForm=replace(tratoForm,"`","")
	tratoForm=replace(tratoForm,"'","")
	tratoForm=replace(tratoForm,"!","")
	tratoForm=replace(tratoForm,"@","")
	tratoForm=replace(tratoForm,"#","")
	tratoForm=replace(tratoForm,"$","")
	tratoForm=replace(tratoForm,"%","")
	tratoForm=replace(tratoForm,"^","")
	tratoForm=replace(tratoForm,"&","")
	tratoForm=replace(tratoForm,"*","")
	tratoForm=replace(tratoForm,"(","")
	tratoForm=replace(tratoForm,")","")
	tratoForm=replace(tratoForm,"-","")
	tratoForm=replace(tratoForm,"=","")
	tratoForm=replace(tratoForm,"+","")
	tratoForm=replace(tratoForm,"{","")
	tratoForm=replace(tratoForm,"[","")
	tratoForm=replace(tratoForm,"}","")
	tratoForm=replace(tratoForm,"]","")
	tratoForm=replace(tratoForm,"\","")
	tratoForm=replace(tratoForm,"|","")
	tratoForm=replace(tratoForm,"""","")
	tratoForm=replace(tratoForm,"'","")
	tratoForm=replace(tratoForm,",","")
	tratoForm=replace(tratoForm,":","")
	tratoForm=replace(tratoForm,";","")
	tratoForm=replace(tratoForm,".","")
	tratoForm=replace(tratoForm,"<","")
	tratoForm=replace(tratoForm,">","")
	tratoForm=replace(tratoForm,"?","")
	tratoForm=replace(tratoForm,"/","")
end function

function validaCampo(campo)
	set ca = lojadb.execute("select * from camposobrigatorios where campo = '"&campo&"'")
	if not ca.eof then
		if ca("obrigatorio") = "S" then
			response.write "req"
		end if
	end if
end function

function msgCampo()
	set ca = lojadb.execute("select * from camposobrigatorios")
	'var msg = {'nome':'Nome obrigat�rio', 'tel':'Telefone obrigat�rio'}
	vet = "var msg = {"
	while not ca.eof
		vet = vet & "'" & ca("campo") & "':'" & ca("msg") & "'"
		ca.movenext
		if not ca.eof then
			vet = vet & ", "
		else
			vet = vet & "}"
		end if
	wend
	response.write vet
	'return vet
end function

function nomeUsuario(ID)
	set vnomeusuario=lojadb.execute("select * from usuarios where id = '"&ID&"'")
	if vnomeusuario.eof then
		nomeUsuario="-"
	else
		nomeUsuario=vnomeusuario("usuario")
	end if
end function

function diasAbr(diaAbr)
	if diaAbr=1 then diasAbr="Domingos" end if
	if diaAbr=2 then diasAbr="Segundas" end if
	if diaAbr=3 then diasAbr="Ter&ccedil;as" end if
	if diaAbr=4 then diasAbr="Quartas" end if
	if diaAbr=5 then diasAbr="Quintas" end if
	if diaAbr=6 then diasAbr="Sextas" end if
	if diaAbr=7 then diasAbr="S&aacute;bados" end if
end function

function horaPequena(recebeHora)
	horas=hour(recebeHora)
	if horas<10 then horas="0"&horas end if
	minutos=minute(recebeHora)
	if minutos<10 then minutos="0"&minutos end if
	horaPequena=horas&":"&minutos
end function
function FunForn(NomeForn)
				if not NomeForn="" then
				set veseFornExi=lojadb.execute("select * from Ship where trim(Nome) like '"&trim(NomeForn)&"' and  Ativo='S'")
					if not veseFornExi.EOF then
					FunForn=veseFornExi("id")
					else
					lojadb_execute("insert Into Ship (Nome, Usuario, Tipo, Ativo) Values ('"&trim(NomeForn)&"', '"&session("usuario")&"', 'Fornecedor', 'S')")
					set pUltID=lojadb.execute("select id,Nome from Ship where Nome like '"&trim(NomeForn)&"' order by id desc")
					FunForn=pUltID("id")
					lojadb_execute("insert Into ContasCentral (Tabela, ContaID, Nome) Values ('Ship', "&Fornecedor&", '"&trim(NomeForn)&"')")
					end if
				else
				FunForn=0
				end if
end function

function SepDat(DataJunta)
                if isnumeric(DataJunta) and len(DataJunta)=8 then
					DataSeparada=right(DataJunta,2)&"/"&mid(DataJunta,5,2)&"/"&left(DataJunta,4)
					DataSeparadaEn=mid(DataJunta,5,2)&"/"&right(DataJunta,2)&"/"&left(DataJunta,4)
					SepDat=DataSeparada
					if isdate(SepDat) then
						SepDat = cdate(SepDat)
					else
						SepDat = NULL
					end if
				end if
end function

function SepDatEn(DataJunta)
                if isnumeric(DataJunta) and len(DataJunta)=8 then
				DataSeparada=right(DataJunta,2)&"/"&mid(DataJunta,5,2)&"/"&left(DataJunta,4)
				DataSeparadaEn=mid(DataJunta,5,2)&"/"&right(DataJunta,2)&"/"&left(DataJunta,4)
				SepDatEn=DataSeparadaEn
				end if
end function

function DatDate(DataJunta)
                if isnumeric(DataJunta) and len(DataJunta)=8 then
				DataSeparada=right(DataJunta,2)&"/"&mid(DataJunta,5,2)&"/"&left(DataJunta,4)
				DataSeparadaEn=mid(DataJunta,5,2)&"/"&right(DataJunta,2)&"/"&left(DataJunta,4)
					if day("01/02/2000")=1 then
					DatDate=DataSeparada
					else
					DatDate=DataSeparadaEn
					end if
				end if
end function

function JunDat(DataSeparada)
				if isdate(DataSeparada) then
				varDt = DataSeparada
				ValFunDat = split(varDt,"/")
				c=1
					for r = 0 to uBound(ValFunDat) 
						if c=1 then rfDia=ccur(ValFunDat(r)) end if
						if c=2 then rfMes=ccur(ValFunDat(r)) end if
					c=c+1
					rfAno=year(DataSeparada)
					next
					if rfDia<10 then rfDia="0"&rfDia end if
					if rfMes<10 then rfMes="0"&rfMes end if
				JunDat="'"&rfAno&rfMes&rfDia&"'"
				else
				JunDat="null"
				end if
end function
function JunDatSp(DataSeparada)
				if isdate(DataSeparada) then
				varDt = DataSeparada
				ValFunDat = split(varDt,"/")
				c=1
					for r = 0 to uBound(ValFunDat) 
						if c=1 then rfDia=ccur(ValFunDat(r)) end if
						if c=2 then rfMes=ccur(ValFunDat(r)) end if
					c=c+1
					rfAno=year(DataSeparada)
					next
					if rfDia<10 then rfDia="0"&rfDia end if
					if rfMes<10 then rfMes="0"&rfMes end if
				JunDatSp=rfAno&rfMes&rfDia
				else
				JunDatSp=""
				end if
end function

function ExiVal(ValExiAtu)
				if isnull(ValExiAtu) then
				ValExiAtu="0"
				end if
				if ccur("1,00")=100 then
				ExiVal=replace(ValExiAtu,",","@")
				ExiVal=replace(Exival,".",",")
				ExiVal=replace(Exival,"@",".")
				else
				ExiVal=ValExiAtu
				end if
end function

function GraVal(ValExiAtual)
	GraVal=replace(ValExiAtual,".","")
	GraVal=replace(GraVal,",",".")
end function

function GraValANTIGO(ValExiAtual)
				set Provinha=lojadb.execute("select * from Provinha")
				if Provinha.eof then
				lojadb_execute("insert into Provinha (Provinha) values ('1,00')")
				else
				lojadb_execute("update Provinha set Provinha='1,00'")
				end if
				set Provinha=lojadb.execute("select * from Provinha")

				if ccur(Provinha("Provinha"))=100 then
				GraVal=replace(ValExiAtual,".","@")
				GraVal=replace(GraVal,",",".")
				GraVal=replace(GraVal,"@",",")
				else
				GraVal=ValExiAtual
				end if
end function
function nomeDiaSemana(diaSemanaAtual)
	if weekday(diaSemanaAtual)=1 then
	nomeDiaSemana="Domingo"
	elseif weekday(diaSemanaAtual)=2 then
	nomeDiaSemana="Segunda-feira"
	elseif weekday(diaSemanaAtual)=3 then
	nomeDiaSemana="Ter&ccedil;a-feira"
	elseif weekday(diaSemanaAtual)=4 then
	nomeDiaSemana="Quarta-feira"
	elseif weekday(diaSemanaAtual)=5 then
	nomeDiaSemana="Quinta-feira"
	elseif weekday(diaSemanaAtual)=6 then
	nomeDiaSemana="Sexta-feira"
	elseif weekday(diaSemanaAtual)=7 then
	nomeDiaSemana="S&aacute;bado"
	end if
end function
function nomeMes(mesUsado)
	if mesUsado=1 then
	nomeMes="Janeiro"
	elseif mesUsado=2 then
	nomeMes="Fevereiro"
	elseif mesUsado=3 then
	nomeMes="Mar&Ccedil;o"
	elseif mesUsado=4 then
	nomeMes="Abril"
	elseif mesUsado=5 then
	nomeMes="Maio"
	elseif mesUsado=6 then
	nomeMes="Junho"
	elseif mesUsado=7 then
	nomeMes="Julho"
	elseif mesUsado=8 then
	nomeMes="Agosto"
	elseif mesUsado=9 then
	nomeMes="Setembro"
	elseif mesUsado=10 then
	nomeMes="Outubro"
	elseif mesUsado=11 then
	nomeMes="Novembro"
	elseif mesUsado=12 then
	nomeMes="Dezembro"
	end if
end function

hoje=jundatsp(day(date())&"/"&month(date())&"/"&year(date()))
%>