<%
function CalculaCPF(NumeroCPF)

Dim RecebeCPF, Numero(11), soma, resultado1, resultado2

RecebeCPF = NumeroCPF

'Retirar todos os caracteres que nao sejam 0-9

s="" 
for x=1 to len(RecebeCPF)
ch=mid(RecebeCPF,x,1)
if asc(ch)>=48 and asc(ch)<=57 then
s=s & ch
end if
next
RecebeCPF = s

if len(RecebeCPF) <> 11 then
	CalculaCPF = false
	'response.write("<h1>&Eacute; obrigat&oacute;rio o CPF com 11 d&iacute;gitos</h1>")
elseif RecebeCPF = "00000000000" then
	CalculaCPF = false
	'response.write("<h1>CPF Inválido</h1>")
else

Numero(1) = Cint(Mid(RecebeCPF,1,1))
Numero(2) = Cint(Mid(RecebeCPF,2,1))
Numero(3) = Cint(Mid(RecebeCPF,3,1))
Numero(4) = Cint(Mid(RecebeCPF,4,1))
Numero(5) = Cint(Mid(RecebeCPF,5,1))
Numero(6) = CInt(Mid(RecebeCPF,6,1))
Numero(7) = Cint(Mid(RecebeCPF,7,1))
Numero(8) = Cint(Mid(RecebeCPF,8,1))
Numero(9) = Cint(Mid(RecebeCPF,9,1))
Numero(10) = Cint(Mid(RecebeCPF,10,1))
Numero(11) = Cint(Mid(RecebeCPF,11,1))


soma = 10 * Numero(1) + 9 * Numero(2) + 8 * Numero(3) + 7 * Numero(4) + 6 * Numero(5) + 5 * Numero(6) + 4 * Numero(7) + 3 * Numero(8) + 2 * Numero(9)

soma = soma -(11 * (int(soma / 11)))

if soma = 0 or soma = 1 then
resultado1 = 0
else
resultado1 = 11 - soma
end if

if resultado1 = Numero(10) then

soma = Numero(1) * 11 + Numero(2) * 10 + Numero(3) * 9 + Numero(4) * 8 + Numero(5) * 7 + Numero(6) * 6 + Numero(7) * 5 + Numero(8) * 4 + Numero(9) * 3 + Numero(10) * 2

soma = soma -(11 * (int(soma / 11)))

if soma = 0 or soma = 1 then
resultado2 = 0
else
resultado2 = 11 - soma
end if

if resultado2 = Numero(11) then
	CalculaCPF = true
	'response.write("<h1>CPF Válido</h1>") 
else
	CalculaCPF = false
	'response.write("<h1>CPF Inválido</h1>")
end if
else
	CalculaCPF = false
	'response.write("<h1>CPF Inválido</h1>")
end if
end if

end function


'|///////////////////////////////////////////////////////////|
'| |
'| Funcao para calcular CNPJ |
'| |
'|///////////////////////////////////////////////////////////|

function CalculaCNPJ()

Dim RecebeCNPJ, Numero(14), soma, resultado1, resultado2

RecebeCNPJ = Request("CampoNumero")

s="" 
for x=1 to len(RecebeCNPJ)
ch=mid(RecebeCNPJ,x,1)
if asc(ch)>=48 and asc(ch)<=57 then
s=s & ch
end if
next
RecebeCNPJ = s

if len(RecebeCNPJ) <> 14 then
response.write("<h1>&Eacute; obrigat&oacute;rio o CNPJ com 14 d&iacute;gitos</h1>")
elseif RecebeCNPJ = "00000000000000" then
response.write("<h1>CNPJ Inv&aacute;lido</h1>")
else

Numero(1) = Cint(Mid(RecebeCNPJ,1,1))
Numero(2) = Cint(Mid(RecebeCNPJ,2,1))
Numero(3) = Cint(Mid(RecebeCNPJ,3,1))
Numero(4) = Cint(Mid(RecebeCNPJ,4,1))
Numero(5) = Cint(Mid(RecebeCNPJ,5,1))
Numero(6) = CInt(Mid(RecebeCNPJ,6,1))
Numero(7) = Cint(Mid(RecebeCNPJ,7,1))
Numero(8) = Cint(Mid(RecebeCNPJ,8,1))
Numero(9) = Cint(Mid(RecebeCNPJ,9,1))
Numero(10) = Cint(Mid(RecebeCNPJ,10,1))
Numero(11) = Cint(Mid(RecebeCNPJ,11,1))
Numero(12) = Cint(Mid(RecebeCNPJ,12,1))
Numero(13) = Cint(Mid(RecebeCNPJ,13,1))
Numero(14) = Cint(Mid(RecebeCNPJ,14,1))

soma = Numero(1) * 5 + Numero(2) * 4 + Numero(3) * 3 + Numero(4) * 2 + Numero(5) * 9 + Numero(6) * 8 + Numero(7) * 7 + Numero(8) * 6 + Numero(9) * 5 + Numero(10) * 4 + Numero(11) * 3 + Numero(12) * 2

soma = soma -(11 * (int(soma / 11)))

if soma = 0 or soma = 1 then
resultado1 = 0
else
resultado1 = 11 - soma
end if
if resultado1 = Numero(13) then
soma = Numero(1) * 6 + Numero(2) * 5 + Numero(3) * 4 + Numero(4) * 3 + Numero(5) * 2 + Numero(6) * 9 + Numero(7) * 8 + Numero(8) * 7 + Numero(9) * 6 + Numero(10) * 5 + Numero(11) * 4 + Numero(12) * 3 + Numero(13) * 2
soma = soma - (11 * (int(soma/11)))
if soma = 0 or soma = 1 then
resultado2 = 0
else
resultado2 = 11 - soma
end if
if resultado2 = Numero(14) then
response.write("<h1>CNPJ válido</h1>")
else
response.write("<h1>CNPJ inválido</h1>")
end if
else
response.write("<h1>CNPJ inválido</h1>")
end if
end if
end function    %>