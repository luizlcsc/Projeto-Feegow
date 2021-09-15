<!--#include file="functions.asp"-->
  <link rel="stylesheet" type="text/css" href="assets/fonts/icomoon/icomoon.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/magnific/magnific-popup.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/footable/css/footable.core.min.css">
  
  <link rel="stylesheet" type="text/css" href="vendor/plugins/fullcalendar/fullcalendar.min.css">
  <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
  <link rel="stylesheet" type="text/css" href="assets/admin-tools/admin-forms/css/admin-forms.css">
  <link rel="shortcut icon" href="assets/img/feegowclinic.ico" type="image/x-icon" />
  <link href="vendor/plugins/select2/css/core.css" rel="stylesheet" type="text/css"> 
  <link href="vendor/plugins/select2/select2-bootstrap.css" rel="stylesheet" type="text/css"> 
  <link rel="stylesheet" href="assets/css/old.css" />
  <link rel="stylesheet" type="text/css" href="vendor/plugins/ladda/ladda.min.css">
<style type="text/css">
    *{
        overflow:hidden;
    }
</style>
<%

'Substitua o valor do par�metro abaixo pelo n�mero do c�digo de barras.
WBarCode( req("NumeroCodigo") )


Sub WBarCode( Valor )
'Dim f, f1, f2, i
'Dim texto
Const fino = 2
Const largo = 6
Const altura = 100
Dim BarCodes(99)

if isempty(BarCodes(0)) then
  BarCodes(0) = "00110"
  BarCodes(1) = "10001"
  BarCodes(2) = "01001"
  BarCodes(3) = "11000"
  BarCodes(4) = "00101"
  BarCodes(5) = "10100"
  BarCodes(6) = "01100"
  BarCodes(7) = "00011"
  BarCodes(8) = "10010"
  BarCodes(9) = "01010"
  for f1 = 9 to 0 step -1
    for f2 = 9 to 0 Step -1
      f = f1 * 10 + f2
      texto = ""
      for i = 1 To 5
        texto = texto & mid(BarCodes(f1), i, 1) + mid(BarCodes(f2), i, 1)
      next
      BarCodes(f) = texto
    next
  next
end if

'Desenho da barra


' Guarda inicial
%><style type="text/css">
<!--
body {
	margin:0;
    background-color:#fff;
}
-->
</style>
<% if req("BPrint")<>"hdn" then %>
    <button style="position:absolute" onclick="print()" class="btn btn-primary hidden-print"><i class="far fa-print"></i></button>
<% end if %>
<div align="center"><img src=p.gif width=<%=fino%> height=<%=altura%> border=0><img 
src=b.gif width=<%=fino%> height=<%=altura%> border=0><img 
src=p.gif width=<%=fino%> height=<%=altura%> border=0><img 
src=b.gif width=<%=fino%> height=<%=altura%> border=0><img 

<%
texto = valor
if len( texto ) mod 2 <> 0 then
  texto = "0" & texto
end if


' Draw dos dados
do while len(texto) > 0
  i = cint( left( texto, 2) )
  texto = right( texto, len( texto ) - 2)
  f = BarCodes(i)
  for i = 1 to 10 step 2
    if mid(f, i, 1) = "0" then
      f1 = fino
    else
      f1 = largo
    end if
    %>
    src=p.gif width=<%=f1%> height=<%=altura%> border=0><img 
    <%
    if mid(f, i + 1, 1) = "0" Then
      f2 = fino
    else
      f2 = largo
    end if
    %>
    src=b.gif width=<%=f2%> height=<%=altura%> border=0><img 
    <%
  next
loop

' Draw guarda final
%>
src=p.gif width=<%=largo%> height=<%=altura%> border=0><img 
src=b.gif width=<%=fino%> height=<%=altura%> border=0><img 
src=p.gif width=<%=1%> height=<%=altura%> border=0>
  
  <%
end sub
%>