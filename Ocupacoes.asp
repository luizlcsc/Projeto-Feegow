<!--#include file="connect.asp"-->
<%

Tipo = req("Tipo")
Data = req("Data")

Agendas = split(ref("Ocupacoes"),", ")

for i=0 to ubound(Agendas)
    spl = split(Agendas(i), "_")
    ProfissionalID = spl(0)
    LocalID = spl(1)
 '   Data = DataSplt(i)
    HBloqueados = ref("OcupProfBloq"& ProfissionalID &"_"& LocalID)
    HAgendados = ref("OcupProfOcu"& ProfissionalID &"_"& LocalID)
    HLivres = ref("OcupProfLivres"& ProfissionalID &"_"& LocalID)

    'response.write(ProfissionalID)


    if LocalID="" then
        db.execute("DELETE from agendaocupacoes where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(Data))
    else
        db.execute("DELETE from agendaocupacoes where ProfissionalID="&ProfissionalID&" and LocalID="& treatvalzero(LocalID) &" and Data="&mydatenull(Data))
    end if

    db.execute(  "insert into agendaocupacoes (ProfissionalID, LocalID, Data, HLivres, HBloqueados, HAgendados) values ("&ProfissionalID&","&treatvalzero(LocalID)&", "&mydatenull(Data)&", "& treatvalzero(HLivres) &", "& treatvalzero(HBloqueados) &", "& treatvalzero(HAgendados) &")")
next
%>
<!--#include file="disconnect.asp"-->