<!--#include file="connect.asp"-->
<%
'cada via tem 484
campo = req("campo")
ModeloID = req("ModeloID")
FormID = req("FormID")
PacienteID = req("PacienteID")
tipo_audio = ref("tipo_audioT")
set modelo = db.execute("select * from buiforms where id="&ModeloID)
if not modelo.EOF then
	if modelo("Tipo")=4 or modelo("Tipo")=3 then
		FTipo = "L"
	else
		FTipo = "AE"
	end if
end if

function audVal(valor)
	if not isnumeric(valor) then
		audVal = "-999"
	else
		if len(valor)=1 then
			audVal = "000"&valor
		elseif len(valor)=2 then
			audVal = "00"&valor
		elseif len(valor)=3 then
			audVal = "0"&valor
		else
			audVal = valor
		end if
	end if
end function
str = "0125,0250,0500,0750,1000,1500,2000,3000,4000,6000,8000"

viazeradaA = "aad0125-999ead0125-999aad0250-999ead0250-999aad0500-999ead0500-999aad0750-999ead0750-999aad1000-999ead1000-999aad1500-999ead1500-999aad2000-999ead2000-999aad3000-999ead3000-999aad4000-999ead4000-999aad6000-999ead6000-999aad8000-999ead8000-999aai0125-999eai0125-999aai0250-999eai0250-999aai0500-999eai0500-999aai0750-999eai0750-999aai1000-999eai1000-999aai1500-999eai1500-999aai2000-999eai2000-999aai3000-999eai3000-999aai4000-999eai4000-999aai6000-999eai6000-999aai8000-999eai8000-999"
viazeradaO = "aod0125-999eod0125-999aod0250-999eod0250-999aod0500-999eod0500-999aod0750-999eod0750-999aod1000-999eod1000-999aod1500-999eod1500-999aod2000-999eod2000-999aod3000-999eod3000-999aod4000-999eod4000-999aod6000-999eod6000-999aod8000-999eod8000-999aoi0125-999eoi0125-999aoi0250-999eoi0250-999aoi0500-999eoi0500-999aoi0750-999eoi0750-999aoi1000-999eoi1000-999aoi1500-999eoi1500-999aoi2000-999eoi2000-999aoi3000-999eoi3000-999aoi4000-999eoi4000-999aoi6000-999eoi6000-999aoi8000-999eoi8000-999"



'vai ter q ir ver se tem o registro, se nao tiver cria com aquele valor completo padrao
'se ja tiver, ve qual o tipo q ta vindo
'se for a, a metade q pertence ao o e deixa gravada no bd
'e a metade do a monta conforme a logica
tipo_audio = ref("tipo_audio")
spl = split(str, ",")
for i=0 to ubound(spl)
	linha = linha&"a"&tipo_audio&"d"&spl(i)&audVal(ref("ad_"&spl(i)))
	linha = linha&"e"&tipo_audio&"d"&spl(i)&audVal(ref("ed_"&spl(i)))
next
for i=0 to ubound(spl)
	linha = linha&"a"&tipo_audio&"i"&spl(i)&audVal(ref("ai_"&spl(i)))
	linha = linha&"e"&tipo_audio&"i"&spl(i)&audVal(ref("ei_"&spl(i)))
next




if FormID="N" then
	db_execute("insert into buiFormsPreenchidos (ModeloID, PacienteID, sysUser) values ("&ModeloID&", "&PacienteID&", "&session("User")&")")
	set pult = db.execute("select * from buiFormsPreenchidos where ModeloID="&ModeloID&" and PacienteID="&PacienteID&" order by id desc LIMIT 1")
	if lembrarme="S" then
		'sqlIns = "insert into `_"&ref("ModeloID")&"` (id, PacienteID, sysUser) values ("&pult("id")&", "&ref("PacienteID")&", "&session("User")&")"
	else
		if tipo_audio = "a" then
			sqlIns = "insert into `_"&ModeloID&"` (id, `"&campo&"`, PacienteID, sysUser) values ("&pult("id")&", '"&linha&viazeradaO&"', "&PacienteID&", "&session("User")&")"
		else
			sqlIns = "insert into `_"&ModeloID&"` (id, `"&campo&"`, PacienteID, sysUser) values ("&pult("id")&", '"&viazeradaA&linha&"', "&PacienteID&", "&session("User")&")"
		end if
	end if
'	response.Write(sqlIns)
	db_execute(sqlIns)
	FormID = pult("id")
	session("FP"&FTipo) = pult("id")
	%>
	{
	    "FormID": "<%=FormID%>",
	    "run": "window.parent.document.getElementById('FormID').value = <%=FormID%>;"
	}
    <%
	call FormValPadImg(ModeloID, FormID)
else
	FormID = session("FP"&FTipo)
	set pValor = db.execute("select * from `_"&ModeloID&"` where id="&FormID)
	if not pValor.EOF then
		if tipo_audio = "a" then
			valor = linha&right(pValor(""&campo&""), 484)
		else
			valor = left(pValor(""&campo&""), 484)&linha
		end if
	end if
	if lembrarme="" then
		sqlUp = "update `_"&ModeloID&"` set `"&campo&"`='"&valor&"' where id="&FormID
		db_execute(sqlUp)
	end if
	%>
    {}
	<%
end if




'response.Write(valor)
%>