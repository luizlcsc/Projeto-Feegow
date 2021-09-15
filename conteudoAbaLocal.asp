<h4 class="lighter">Intervalo em Minutos</strong></h4>
<table class="table">
<thead>
<tr>
<%
n=0
while n<7
n=n+1
%>
<th class="success"><%=uCase(left(weekdayname(n),3))%></th><%
wend
%>
</tr>
</thead>
<tbody>
<tr>
<%
splInt=split(strInt,",")
n=0
while n<7
n=n+1
%>
<td>
<input class="form-control input-sm text-right" type="text" size="1" maxlength="3" id="dia<%=n%>local<%=pLoc("id")%>" value="<%=splInt(n)%>" />
</td>
<%
wend
%>
</tr>
</tbody>
</table>
<button type="button" class="btn btn-xs btn-block btn-primary" value="SALVAR" onClick="interQuadro(<%=pLoc("id")%>);"><i class="far fa-save"></i> SALVAR</button>
<button type="button" class="btn btn-xs btn-block btn-success" value="EDITAR PROFISSIONAIS" onclick="location.href='?P=EdiProfQD&Pers=1&LId=<%=pLoc("id")%>&Data=<%
if req("Data")="" then
	response.Write(date())
else
	response.Write(req("Data"))
end if
%>';"><i class="far fa-calendar"></i> EDITAR PROFISSIONAIS</button>
