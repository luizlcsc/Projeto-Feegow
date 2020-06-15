<!--#include file="connect.asp"-->
<%
if recursoadicional(4) = 4 then
  set cFF = db.execute("SELECT parametros FROM cliniccentral.clientes_servicosadicionais WHERE LicencaID='"&replace(session("banco"),"clinic","")&"' AND ServicoID=4")
  configFF = cFF("parametros")&""
  
  valorSplit=Split(configFF,"|")
  for each valor in valorSplit
    ff_chave = valorSplit(0)&""
    ff_host1 = valorSplit(1)&""
    ff_host2 = valorSplit(2)&""
    'CASO APRESENTE ERRO DEVIDO CONEXÃO SER LOCAL, UTILIZAR URL2
  next

  cFF.close
  set cFF = nothing
else
  response.write("Integração PABX não foi configurada corretamente.")
  response.end()
end if

ff_host = ff_host1
'if Request.ServerVariables("HTTP_HOST") <> "localhost" then 
'  ff_host  = "http://192.168.0.23/futurofone_api"
'else
'  ff_host  = "http://feegow.futurotec.com.br/futurofone_api"
'end if
%>