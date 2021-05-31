<table class="table table-striped">
<%
set phis = db.execute("select * from TarefasMSGs where TarefaID like '"&req("I")&"' order by data desc, hora desc")
while not phis.eof
%>
  <tr>
    <td height="22"><em>Enviado por <%=nameinTable(phis("desession"))%> em <%=phis("data")%>, &agrave;s <%=cdate(hour(phis("hora"))&":"&minute(phis("hora")))%>.</em></td>
  </tr>
  <tr bgcolor="<%=cor%>">
    <td height="44"><div align="left"><strong>Texto:</strong><br>
    <%=replace(phis("msg")&" ",chr(13),"<br>")%></div></td>
  </tr>
<%
phis.movenext
wend
phis.close
set phis=nothing
%>
</table>
