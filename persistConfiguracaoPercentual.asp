<!--#include file="connect.asp"-->
<%
minimoString = Request.Form("minimo")
maximoString = Request.Form("maximo")
percentualString = Request.Form("percentual")
bandeiraString = Request.Form("bandeira")
id = Request.QueryString("id")

minimoArray = split(minimoString, "||")
maximoArray = split(maximoString, "||")
percentualArray = split(percentualString, "||")
bandeiraArray = split(bandeiraString, "||")

db.execute("delete from sys_financial_current_accounts_percentual where sys_financialCurrentAccountId = "&id)
for key=0 to ubound(minimoArray)            
response.write( bandeiraArray(key))
    bandeira = "null"
    if(bandeiraArray(key) <> 0) then
        bandeira = bandeiraArray(key)   
    end if
    db.execute("insert into sys_financial_current_accounts_percentual(minimo, maximo, acrescimoPercentual, sysUser, sysActive, sys_financialCurrentAccountId, bandeira) values ("&minimoArray(key)&", "&maximoArray(key)&", "&treatvalzero(percentualArray(key))&", "&session("User")&", 1, "&id&", "&bandeira&");")       
next
%>