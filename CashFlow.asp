	<table class="table table-striped table-bordered">
	<tr>
		<th>FLUXO DE SA&Iacute;DA</th>
			<%
			currentDate = cdate(session("DateFrom"))
			while currentDate<=cdate(session("DateTo"))
				%>
				<th><%=left(currentDate,5)%></th>
				<%
				currentDate = dateAdd("d", 1, currentDate)
			wend
			%>
		<th>Total</th>
	</tr>
	<%
	'set
	'while
	
	%>
		<tr>
			<td>Categoria</td>
            <%
			currentDate = cdate(session("DateFrom"))
			while currentDate<=cdate(session("DateTo"))
				%>
				<td><%=left(currentDate,5)%></td>
				<%
				currentDate = dateAdd("d", 1, currentDate)
			wend
			%>
			<td>Valor total da Cat</td>
		</tr>
	<%
	'wend
	%>
	<tr>
		<td>TOTAL</td>
            <%
			currentDate = cdate(session("DateFrom"))
			while currentDate<=cdate(session("DateTo"))
				%>
				<td><%=left(currentDate,5)%></td>
				<%
				currentDate = dateAdd("d", 1, currentDate)
			wend
			%>
		<td>Valor total Geral</td>
	</tr>
	</table>
