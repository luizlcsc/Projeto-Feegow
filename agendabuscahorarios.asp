<!--#include file="connect.asp"-->
<%
ProfissionalID = req("ProfissionalID")
Data = req("Data")
CarrinhoID = req("CarrinhoID")
diaN = req("diaN")
Horarios = ref("H")

spl = split(Horarios, "|")
for i=0 to ubound(spl)
    if spl(i)<>"" then
        spl2 = split(spl(i), "_")
        Hora = spl2(0)
        LocalID = spl2(1)
        if isdate(Hora) then
            db.execute("insert into agendabuscahorarios set ProfissionalID="& treatvalzero(ProfissionalID) &", ProcedimentoID="& treatvalnull(ref("ProcedimentoID")) &", Especialidades='"& ref("Especialidades") &"', Data="& mydatenull(Data) &", CarrinhoID="& CarrinhoID &", Hora='"& Hora &"', LocalID="& treatvalzero(LocalID) &", sysUser="& session("User") )
        end if
    end if
next
'teste
%>
ocor(<%= req("ocor") %>);