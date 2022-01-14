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
        db.execute("DELETE from agendaocupacoes where ProfissionalID="&profisionalid&" and Data="&mydatenull(dataalvo)&";")
        localid = "NULL"
        
        sqlbloqueios  = "SELECT if((TIMESTAMPDIFF(HOUR,afl.horade, afl.horaa)*60/afl.intervalo) < (TIMESTAMPDIFF(HOUR,c.horade, c.horaa)*60/afl.intervalo) , "&_ 
                        "(TIMESTAMPDIFF(HOUR,afl.horade, afl.horaa)*60/afl.intervalo) +1, "&_ 
                        "(TIMESTAMPDIFF(HOUR,c.horade, c.horaa)*60/afl.intervalo)+1) "&_
                        " FROM compromissos c "&_
                        " INNER JOIN assfixalocalxprofissional afl ON afl.ProfissionalID = c.ProfissionalID "&_ 
                        "                                         AND (afl.LocalID = c.LocalID OR c.LocalID IS NULL) "&_ 
                        "                                         AND afl.DiaSemana = if(DATE_FORMAT('"&dataalvo&"','%w')+1 = 8, 1, DATE_FORMAT('"&dataalvo&"','%w')+1) "&_
                        " WHERE c.ProfissionalID='"&profisionalid&"' AND c.DataDe <= '"&dataalvo&"' AND c.DataA >= '"&dataalvo&"' "&_ 
                        " AND DiasSemana LIKE CONCAT('%', (if(DATE_FORMAT('"&dataalvo&"','%w')+1 = 8, 1, DATE_FORMAT('"&dataalvo&"','%w')+1)),'%') "&_
                        " AND (iniciovigencia <= '"&dataalvo&"' OR iniciovigencia IS NULL) AND (fimvigencia >='"&dataalvo&"' OR fimvigencia IS NULL) "

        sqlhoraslivres = "SELECT SUM((TIMESTAMPDIFF(HOUR,horade, horaa)*60/intervalo) + 1) "&_
                         " FROM assfixalocalxprofissional WHERE (iniciovigencia <= '"&dataalvo&"' OR iniciovigencia IS NULL) "&_
                         " AND (fimvigencia >='"&dataalvo&"' OR fimvigencia IS NULL)  "&_ 
                         " AND profissionalid = "&profisionalid&"  AND diasemana = if(DATE_FORMAT('"&dataalvo&"','%w')+1 = 8 , 1,DATE_FORMAT('"&dataalvo&"','%w')+1)"

        sqlAgendamentos = "SELECT COUNT(id) from agendamentos a  "&_
                          " WHERE a.Data= '"&dataalvo&"' and a.ProfissionalID='"&profisionalid&"' AND staid NOT IN (11,15) AND sysactive = 1 "

        sql  =  " INSERT INTO agendaocupacoes (`Data`, ProfissionalID, EspecialidadeID, LocalID, HLivres, HAgendados, HBloqueados) "&_
                " VALUES ('"&dataalvo&"',"&profisionalid&",NULL,"&localid&", "&_
                " COALESCE(("&sqlhoraslivres&"),0), COALESCE(("&sqlagendamentos&"),0), COALESCE(("&sqlbloqueios&"),0));"
        db.execute(sql)
        ' Eliminar ocupacoes sem grade
        if localid="" then
            db.execute("DELETE from agendaocupacoes where HLivres=0 and ProfissionalID="&profisionalid&" and Data="&mydatenull(dataalvo))
            localid = "NULL"
        else
            db.execute("DELETE from agendaocupacoes where HLivres=0 and ProfissionalID="&profisionalid&" and LocalID="& treatvalzero(localid) &" and Data="&mydatenull(dataalvo))
        end if   
    end if 
next 
call agendaOcupacoes(profisionalid, dataDMA)

%>

<!--#include file = "disconnect.asp"-->
