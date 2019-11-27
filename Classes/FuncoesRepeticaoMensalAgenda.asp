<%

function datas_da_semana(parData, dia_da_semana)
    myPrimeiro =  DateSerial(year(parData), Month(parData), "1")
    myUltimoDia = DateAdd("d",-1,DateAdd("m",1,"1" & "/" & MONTH(parData) & "/" & YEAR(parData)))
    myloop = myPrimeiro
    dataRetorno = ""

    while  myloop <= myUltimoDia 
        if dia_da_semana = weekday(myloop) then
            dataRetorno = dataRetorno&myloop&","
        end if
        myloop = DateAdd("d", 1, myloop)
    wend
    datas_da_semana = Left(dataRetorno, Len(dataRetorno) - 1)
end function

function nth_date(parData)
    mdatas = datas_da_semana(parData,weekday(parData))
    mslp = split(mdatas, ",")
    retorno =0
    for t = 0 to ubound(mslp)
        if mslp(t) = parData&"" then
        retorno = t
        end if
    next
    nth_date = retorno+1
end function

%>