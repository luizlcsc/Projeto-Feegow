<!--#include file="connect.asp"-->
<%
convenio    = req("convenio")

sql = "select * from impostos_associacao where convenio = "&convenio
set impostos = db_execute(sql)

while not impostos.eof then



wend