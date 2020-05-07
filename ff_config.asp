<%
ff_chave = "e003bde12f72da07e6524159265921d8"
if Request.ServerVariables("HTTP_HOST") = "localhost" then 
  ff_host  = "http://192.168.0.23/futurofone_api"
else
  ff_host  = "http://feegow.futurotec.com.br/futurofone_api"
end if
%>