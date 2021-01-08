<!--#include file="connect.asp"-->
<%

descontosIds = req("descontos")

set rsDescontos = db.execute("SELECT Status FROM descontos_pendentes WHERE id IN (" & descontosIds & ")")

countTotal     = 0
countReprovado = 0
countAprovado  = 0
while not rsDescontos.eof
    countTotal = countTotal + 1
    if rsDescontos("Status") = 1 then
        countAprovado = countAprovado + 1
    end if
    if rsDescontos("Status") = -1 then
        countReprovado = countReprovado + 1
    end if
    rsDescontos.movenext
wend
rsDescontos.close
set rsDescontos=nothing

if countReprovado > 0 then ' se tem algum desconto reprovado, recusa no checkin
    response.write(2)
elseif countAprovado = countTotal then ' se todos foram aprovados, aceita o checkin
    response.write(1)
else
    response.write(0)  ' aguarda aprovação/reprovação
end if

%>