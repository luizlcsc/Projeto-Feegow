<!--#include file="connect.asp"-->
<%
Agendas = split(ref("ProfissionalID[]"),",")
on error resume next

ProfissionalIDSplt  = split(ref("ProfissionalID[]"),",")
LocalIDSplt         = split(ref("LocalID[]"),",")
DataSplt            = split(ref("Data[]"),",")
HBloqueadosSplt     = split(ref("HBloqueados[]"),",")
HAgendadosSplt      = split(ref("HAgendados[]"),",")
HLivresSplt         = split(ref("HLivres[]"),",")

for i=0 to ubound(Agendas)
    ProfissionalID  = ProfissionalIDSplt(i)
    LocalID         = LocalIDSplt(i)
    Data            = DataSplt(i)
    HBloqueados     = HBloqueadosSplt(i)
    HAgendados      = HAgendadosSplt(i)
    HLivres         = HLivresSplt(i)

    response.write(ProfissionalID)

    'set vca = db.execute("select id from agendaocupacoes where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(Data))

    'if LocalID="" then
    '    db.execute("DELETE from agendaocupacoes where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(Data))
    'else
    '    db.execute("DELETE from agendaocupacoes where ProfissionalID="&ProfissionalID&" and LocalID="& treatvalzero(LocalID) &" and Data="&mydatenull(Data))
    'end if

    'db.execute(  "insert into agendaocupacoes (ProfissionalID, LocalID, Data, HLivres, HBloqueados, HAgendados) values ("&ProfissionalID&","&treatvalzero(LocalID)&", "&mydatenull(Data)&", "& HLivres &", "& HBloqueados &", "& HAgendados &")")
next
%>
<!--#include file="disconnect.asp"-->