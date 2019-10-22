<!--#include file="connect.asp"-->
<%
spl = split(ref("AssID"), ", ")
for i=0 to ubound(spl)
    AssID = spl(i)
    set ass = db.execute("select * from assfixalocalxprofissional where id="& AssID)
    Intervalo = ass("Intervalo")
    meioIntervalo = cint(Intervalo/2)
    HoraDe = ass("HoraDe")
    HoraA = ass("HoraA")
    PrimeiroHorario = dateAdd("n", meioIntervalo, HoraDe)
    UltimoHorario = dateAdd("n", "-"&meioIntervalo, HoraA)
    IDRetorno = 15424
    'response.write("alert('"& ft(HoraDe) &" - "& ft(PrimeiroHorario) &" - "& ft(UltimoHorario) &"');")
    db.execute("insert into assfixalocalxprofissional (DiaSemana, HoraDe, HoraA, ProfissionalID, LocalID, Intervalo, Compartilhada, Especialidades, Procedimentos, Convenios, Profissionais, TipoGrade, MaximoRetornos, MaximoEncaixes, InicioVigencia, FimVigencia, FrequenciaSemanas, Mensagem) select DiaSemana, "& mytime(PrimeiroHorario) &", "& mytime(UltimoHorario) &", ProfissionalID, LocalID, Intervalo, '', Especialidades, '|"& IDRetorno &"|', Convenios, Profissionais, TipoGrade, 0, 0, InicioVigencia, FimVigencia, FrequenciaSemanas, 'Agenda de encaixes' Mensagem from assfixalocalxprofissional where id="& AssID)
    db.execute("update assfixalocalxprofissional set MaximoRetornos=0, MaximoEncaixes=0 where id="& AssID)
next
%>
location.reload();