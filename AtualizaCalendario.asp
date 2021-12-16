<%InicioProcessamento = Timer%>
<!--#include file="connect.asp"-->
<%
on error resume next
profisionalid = req("profissionalid")
localid = req("localid")
ano = req("ano")
mes = req("mes")

for dia=1 to 31 
    dataalvo = ano&"-"&mes&"-"&dia
    dataDMA = dia&"/"&mes&"/"&ano
    if isdate(dataalvo) then
        if localid="" then
            db.execute("DELETE from agendaocupacoes where ProfissionalID="&profisionalid&" and Data="&mydatenull(dataalvo))
            localid = "NULL"
        else
            db.execute("DELETE from agendaocupacoes where ProfissionalID="&profisionalid&" and LocalID="& treatvalzero(localid) &" and Data="&mydatenull(dataalvo))
        end if
        'if Weekday(dataalvo) <> 1 and Weekday(dataalvo) <> 7 then            
            sql  = " INSERT INTO agendaocupacoes (`Data`, ProfissionalID, EspecialidadeID, LocalID, HLivres, HAgendados, HBloqueados) "&_
                " VALUES ('"&dataalvo&"',"&profisionalid&",NULL,"&localid&", "&_
                " COALESCE((SELECT TIMESTAMPDIFF(HOUR,horade, horaa)*60/intervalo +1  "&_
                " FROM assfixalocalxprofissional WHERE (iniciovigencia <= NOW() OR iniciovigencia IS NULL) "&_
                " AND (fimvigencia >=NOW() OR fimvigencia IS NULL)  "&_ 
                " AND profissionalid = "&profisionalid&"  AND diasemana = if(DATE_FORMAT('"&dataalvo&"','%w')+1 = 8 , 1,DATE_FORMAT('"&dataalvo&"','%w')+1)),0),  "&_
                " (SELECT COUNT(id) from agendamentos a  "&_
                " WHERE a.Data= '"&dataalvo&"' and a.ProfissionalID=1 ),  "&_
                " (SELECT COUNT(id) from compromissos c  "&_
                " WHERE c.ProfissionalID=1 and DataDe<='"&dataalvo&"' and DataA>='"&dataalvo&"' "&_
                " and DiasSemana =  if(DATE_FORMAT('"&dataalvo&"','%w')+1 = 8 , 1,DATE_FORMAT('"&dataalvo&"','%w')+1)));"

            db.execute(sql)
            ' Eliminar ocupacoes sem grade
            if localid="" then
                db.execute("DELETE from agendaocupacoes where HLivres=0 and ProfissionalID="&profisionalid&" and Data="&mydatenull(dataalvo))
                localid = "NULL"
            else
                db.execute("DELETE from agendaocupacoes where HLivres=0 and ProfissionalID="&profisionalid&" and LocalID="& treatvalzero(localid) &" and Data="&mydatenull(dataalvo))
            end if   
        'end if      
    end if 
next 
call agendaOcupacoes(profisionalid, dataDMA)

%>

<!--#include file = "disconnect.asp"-->
