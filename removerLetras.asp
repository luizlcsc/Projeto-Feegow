<%
Private Function RmChr(byVal string, byVal remove)
	Dim i, j, tmp, strOutput
	strOutput = ""
	for j = 1 to len(string)
		tmp = Mid(string, j, 1)
		for i = 1 to len(remove)
			tmp = replace( tmp, Mid(remove, i, 1), "")
			if len(tmp) = 0 then exit for
		next
		strOutput = strOutput & tmp
	next
	RmChr = strOutput
End Function


Dim Input, Disallowed

 ' String para limpar
Input =	"sjsvnw)68&Y469$T_W$(*T+}D|3567808SDK49SO" & _
		"DJ0570570Gosdnp SNDFG_S(*GH-S570570GN*4 jwt jtj+W$T )"

 ' Permitir espaços, sublinhados e qualquer inteiro ou letra do alfabeto. 
'Remover qualquer outra coisa ...
Disallowed = "[]+=)(*&^%$#@!|\/?><,{}:;.-~`'" & chr(34) & vbCrLf & vbTab
Response.Write RmChr(Input, Disallowed) & "<BR>"

 ' remover espaços, tabulações, linefeed carriagereturns ...
Disallowed = " " & vbTab & vbCrLf
Response.Write RmChr(Input, Disallowed) & "<BR>"

 ' remove numeros...
Disallowed = "0123456789"
Response.Write RmChr(Input, Disallowed) & "<BR>"

 ' remove lower case...
Disallowed = lcase("abcdefghijklmnopqrstuvwxyz")
Response.Write RmChr(Input, Disallowed) & "<BR>"

 ' remove upper case ...
Disallowed = ucase("abcdefghijklmnopqrstuvwxyz")
Response.Write RmChr(Input, Disallowed) & "<BR>"


str = request.QueryString("Telefone")

Private Function telefone(str, numero, fixoOuCelular)
	DDD = 21
	Dim i, j, tmp, strOutput, remove
	strOutput = ""
	remove =  ucase("abcdefghijklmnopqrstuvwxyz")&lcase("abcdefghijklmnopqrstuvwxyz")&"\| *-+.<>/?,}]{[´`_='!@#$%¨&*()§"
	for j = 1 to len(str)
		tmp = Mid(str, j, 1)
		for i = 1 to len(remove)
			tmp = replace( tmp, Mid(remove, i, 1), "")
			if len(tmp) = 0 then exit for
		next
		strOutput = strOutput & tmp
	next
	telefone = strOutput
	
	if left(telefone, 1)="0" then
		telefone = right(telefone, len(telefone)-1)
	end if
	if len(telefone)=8 or len(telefone)=9then
		telefone = DDD&telefone
	end if
	if len(telefone)=16 then
		telefone = DDD&left(
	end if
End Function

%><br>
<br>
<br>
<br>
<%=telefone(str)%>
