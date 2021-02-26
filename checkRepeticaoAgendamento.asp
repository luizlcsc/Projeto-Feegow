<!--#include file="connect.asp"-->
<!--#include file="validar.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/FuncoesRepeticaoMensalAgenda.asp"-->
<!--#include file="Classes/GradeAgendaUtil.asp"-->
<%
if req("rpt") <> "S" then
    Response.ContentType = "application/json"
    Response.write("{""existeAgendamentosFuturos"":  false}")     
    Response.end
end if

rptDataInicio = cdate(req("Data"))
rptTerminaRepeticao = req("TerminaRepeticao")
rptIntervaloRepeticao = req("IntervaloRepeticao")
rptRepeticaoOcorrencias = 1
Repeticao = req("Repeticao")
repetirDias = req("repetirDias")
tipoDiaMes = req("tipoDiaMes")
rfTempo=req("Tempo")
rfHora=req("Hora")
rfProfissionalID=req("ProfissionalID")
rfEspecialidadeID=req("EspecialidadeID")
rdEquipamentoID=req("EquipamentoID")
indicacaoID=req("indicacaoId")
rfData=req("Data")

listDates = array()

if isdate(rfData) then
    rfData = cdate(rfData)
end if

    if req("rpt")="S" then
        rptDataInicio = cdate(req("Data"))
        rptTerminaRepeticao = req("TerminaRepeticao")
        rptIntervaloRepeticao = req("IntervaloRepeticao")
        rptRepeticaoOcorrencias = 1
        Repeticao = req("Repeticao")
        repetirDias = req("repetirDias")
        tipoDiaMes = req("tipoDiaMes")
        if repetirDias="" then
            repetirDias = cstr(weekday(Data))
        end if

        if rptTerminaRepeticao="N" then
            rptRepeticaoDataFim = dateAdd("yyyy", 2, rptDataInicio)
        elseif rptTerminaRepeticao="O" then
            if rptRepeticaoOcorrencias<>"" and isnumeric(rptRepeticaoOcorrencias) then
                rptRepeticaoOcorrencias = cint( req("RepeticaoOcorrencias") )
            end if
        elseif rptTerminaRepeticao="D" then
            if isdate(req("RepeticaoDataFim")) and req("RepeticaoDataFim")<>"" then
                rptRepeticaoDataFim = cdate(req("RepeticaoDataFim"))
            else
                rptRepeticaoDataFim = rptDataInicio
            end if
        end if

        if tipoDiaMes="DiaSemana" and Repeticao="M" then
            'Repeticao = "S"
            'rptIntervaloRepeticao = ccur(rptIntervaloRepeticao)*4
            repetirDias = cstr( weekDay(rptDataInicio) )
            diaSemana = weekDay(rptDataInicio)
            nthDiaSemaMes = nth_date(rptDataInicio)
        end if

        rptDataLoop = rptDataInicio
        rptOcorrencias = 0
        Maximo = 200
        while ( (rptTerminaRepeticao="O" and rptOcorrencias<rptRepeticaoOcorrencias) or (rptRepeticaoDataFim<>"O" and rptDataLoop<rptRepeticaoDataFim) ) and rptC<Maximo
            select case Repeticao
                case "D"
                    rptDataLoop = dateAdd("d", rptIntervaloRepeticao, rptDataLoop)
                    replica = 1
                case "S"
                    rptDataLoop = dateAdd("d", 1, rptDataLoop)
                    if weekDay(rptDataLoop)=1 and ccur(rptIntervaloRepeticao)>1 then
                        rptDataLoop = dateAdd("d", (ccur(rptIntervaloRepeticao)-1)*7, rptDataLoop)
                    end if
                    if instr(repetirDias, weekday(rptDataLoop))>0 then
                        replica = 1
                    else
                        replica = 0
                    end if
                case "M"
                    rptDataLoop = dateadd( "m", ccur(rptIntervaloRepeticao), rptDataLoop )

                    if  tipoDiaMes="DiaSemana" then
                        datas = datas_da_semana(rptDataLoop,diaSemana)
                        slp = split(datas, ",")
                        max = ubound(slp)+1

                        parocuraraqui = nthDiaSemaMes
                        if nthDiaSemaMes > max then
                            parocuraraqui = max
                        end if

                        rptDataLoop = DateSerial(year(slp(parocuraraqui-1)),Month(slp(parocuraraqui-1))+intervaloMensal, Day(slp(parocuraraqui-1)))
                    end if

                    if rptTerminaRepeticao<>"O" then
                        if rptDataLoop<=rptRepeticaoDataFim then
                            replica = 1
                        else
                            replica = 0
                        end if
                    else
                        replica = 1
                    end if
                case "A"
                    rptDataLoop = dateAdd("yyyy", rptIntervaloRepeticao, rptDataLoop)
                    replica = 1
            end select
            if replica=1 then
                rptC = rptC + 1
                
                rptOcorrencias = rptOcorrencias+1

                ReDim Preserve listDates(UBound(listDates) + 1)                
                listDates(UBound(listDates)) = mydatenull(rptDataLoop)		        

            end if
        wend

        if UBound(listDates) < 0 then 
            Response.ContentType = "application/json"
            Response.write("{""existeAgendamentosFuturos"":  false}")     
            Response.end       
        end if

        UnidadeID = session("UnidadeID")
        sqlUnidadesBloqueio = ""
        if UnidadeID&"" <> "" and session("Partner")="" then
            sqlUnidadesBloqueio = sqlUnidadesBloqueio&" OR c.Unidades LIKE '%|"&UnidadeID&"|%'"
        end if

        datesString = Join(listDates, ", " )
        itensArray=replace(datesString, "'", "")
        itensArray=Split(itensArray,", ")
        validaBloqueio = 0
        
        for each itensValor in itensArray
            bloqueioSql = getBloqueioSql(rfProfissionalID, itensValor, sqlUnidadesBloqueio)
            set bloq = db.execute(bloqueioSql)
            if not bloq.eof then
            validaBloqueio = 1
            end if
        next

        set existsDatesConflict = db.execute("select count(id) >= 1 as existeAgendamento from agendamentos where ProfissionalID = "&rfProfissionalID&" AND Data in ("&datesString&") and Hora = '"&rfHora&"'") 

        if existsDatesConflict("existeAgendamento") = "1" or validaBloqueio = 1 then
            Response.ContentType = "application/json"
            Response.write("{""existeAgendamentosFuturos"":  true}")    
            Response.end                
        end if          

        Response.ContentType = "application/json"
        Response.write("{""existeAgendamentosFuturos"":  false}")     
        Response.end            
    end if
%>