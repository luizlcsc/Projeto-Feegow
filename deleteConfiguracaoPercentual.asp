<!--#include file="connect.asp"-->
<%
sys_financialCurrentAccountId = req("sys_financialCurrentAccountId")
minimo = req("minimo")
maximo = req("maximo")
percentual = req("percentual")

if minimo = "" or maximo = "" then
    response.end
end if

db.execute(" delete"&_ 
                 " from sys_financial_current_accounts_percentual "&_
                " where minimo = "&minimo&_
                  " and maximo = "&maximo&_
                   " and acrescimoPercentual = "&treatvalzero(percentual)&_ 
                  " and sys_financialCurrentAccountId = "&sys_financialCurrentAccountId)
    'db.execute("delete from sys_financial_current_accounts_percentual where id = "&id)
 
%>