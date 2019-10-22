<%
'retorna o próximo dia útil, considerando feriados. Passar 0 para periodoDias caso queira o próximo dia útil de uma determinada data
function ProximoDiaUtil(data, periodoDias)

    set SQLdataPrevisao = db.execute(" SELECT  (IF(DAYOFWEEK(t.DataPrevisao) = '6' OR DAYOFWEEK(t.DataPrevisao) = '7', "&_
                                    " IF(DAYOFWEEK(t.DataPrevisao)='6', DATE_ADD(t.DataPrevisao, INTERVAL + 3 DAY), "&_
                                    " DATE_ADD(t.DataPrevisao, INTERVAL + 2 DAY)), "&_
                                    " DATE_ADD(t.DataPrevisao, INTERVAL + 1 DAY))) AS DataAtualizada "&_
                                    " FROM (SELECT DATE_ADD('"&data&"' , INTERVAL '"&periodoDias&"' DAY ) AS DataPrevisao) t;")

    resProximoDiaUtil = SQLdataPrevisao("DataAtualizada")

    set SQLFeriados = db.execute("SELECT 1 AS Feriado FROM feriados WHERE DAYOFMONTH(data) = DAYOFMONTH('"&resProximoDiaUtil&"') AND MONTH(data) = MONTH('"&resProximoDiaUtil&"');")

    if not SQLFeriados.EOF then
        ProximoDiaUtil = ProximoDiaUtil(resProximoDiaUtil,0)
    else 
        ProximoDiaUtil = resProximoDiaUtil
    end if
    
    set SQLdataPrevisao = nothing
    set SQLFeriados = nothing

end function
%>