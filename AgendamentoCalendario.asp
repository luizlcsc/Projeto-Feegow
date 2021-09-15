<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

Function GetDaysInMonth(iMonth, iYear)
	Dim dTemp
	dTemp = DateAdd("d", -1, DateSerial(iYear, iMonth + 1, 1))
	GetDaysInMonth = Day(dTemp)
End Function

Function GetWeekdayMonthStartsOn(dAnyDayInTheMonth)
	Dim dTemp
	dTemp = DateAdd("d", -(Day(dAnyDayInTheMonth) - 1), dAnyDayInTheMonth)
	GetWeekdayMonthStartsOn = WeekDay(dTemp)
End Function

Function SubtractOneMonth(dDate)
	SubtractOneMonth = DateAdd("m", -1, dDate)
End Function

Function AddOneMonth(dDate)
	AddOneMonth = DateAdd("m", 1, dDate)
End Function

Dim dDate     ' Date we're displaying calendar for
Dim iDIM      ' Days In Month
Dim iDOW      ' Day Of Week that month starts on
Dim iCurrent  ' Variable we use to hold current day of month as we write table
Dim iPosition ' Variable we use to hold current position in table

dDate = date()
if req("Data")="" then
	Data = date()
else
	Data = req("Data")
end if

iDIM = GetDaysInMonth(Month(Data), Year(Data))
iDOW = GetWeekdayMonthStartsOn(Data)

MesX=month(Data)


DataAnte=dateadd("m",-1,Data)
DataAnte=day(DataAnte)&"/"&month(DataAnte)&"/"&year(DataAnte)

DataProx=dateadd("m",1,Data)
DataProx=day(DataProx)&"/"&month(DataProx)&"/"&year(DataProx)

set feriados = db.execute("select day(Data) Dia, NomeFeriado from feriados where sysActive=1 and month(Data)="&month(Data))
while not feriados.eof
	strFeriados = strFeriados&"|"&feriados("Dia")&"|"
feriados.movenext
wend
feriados.close
set feriados=nothing
%>
<style>
	#tblCalendario .badge{
		padding:3px 4px!important
	}
</style>
<table width="100%" class="panel pn bs-component table table-condensed hidden-print" id="tblCalendario">
<thead>
      <tr class="active">
        <th colspan="2" class="hand" onClick="changeMonth('<%=dateadd("m", -1, Data)%>');"><i class="far fa-chevron-left"></i></th>
        <th colspan="3" class="text-center"><%= ucase(left(monthname(MesX),3)) & " - " & Year(Data) %></th>
        <th colspan="2" class="hand text-right" onClick="changeMonth('<%=dateadd("m", 1, Data)%>');" class="text-right"><i class="far fa-chevron-right"></i></th>
      </tr>
      <tr>
        <th width="14%">DO</th>
        <th width="14%">SE</th>
        <th width="14%">TE</th>
        <th width="14%">QA</th>
        <th width="14%">QI</th>
        <th width="14%">SE</th>
        <th width="14%">SA</th>
      </tr>
</thead>
<tbody>
	  <%
' Write spacer cells at beginning of first row if month doesn't start on a Sunday.
If iDOW <> 1 Then
	Response.Write vbTab & "<TR>" & vbCrLf
	iPosition = 1
	Do While iPosition < iDOW
		Response.Write vbTab & vbTab & "<TD bgcolor=""""></TD>" & vbCrLf
		iPosition = iPosition + 1
	Loop
End If

' Write days of month in proper day slots
iCurrent = 1
iPosition = iDOW
Do While iCurrent <= iDIM
	' If we're at the begginning of a row then write TR
	If iPosition = 1 Then
		Response.Write vbTab & "<TR>" & vbCrLf
	End If


if day("01/02/2009")=1 then
		if cdate(iCurrent&"/"&month(Data)&"/"&year(Data))=date() then
		corF="FFFF66"
		strong="<strong>"
		Fstrong="</strong>"
		else
		corF="FFFFFF"
		strong=""
		Fstrong=""
		end if
else
		if cdate(month(Data)&"/"&iCurrent&"/"&year(Data))=date() then
		corF="FFFF66"
		strong="<strong>"
		Fstrong="</strong>"
		else
		corF="FFFFFF"
		strong=""
		Fstrong=""
		end if
end if
		DataClick = iCurrent&"/"&month(Data)&"/"&year(Data)
		DataClick = formatdatetime(DataClick, 2)
		DataClickClass = replace(DataClick, "/", "-")
		if instr(strFeriados, "|"&iCurrent&"|")=0 then
			aBadge = ""
			fBadge = ""
		else
			aBadge = "<span class=""badge badge-warning"">"
			fBadge = "</span>"
		end if

		Response.Write vbTab & vbTab & "<TD class=""hand dia-calendario text-center "&DataClickClass&" d"&weekday(iPosition)
        if cdate(DataClick)=date() then
            response.write(" info ")
        end if
        response.Write """ id="""&DataClick&""">" & strong & aBadge& iCurrent & fBadge
		
		IF getConfig("ExibirProgressoAgendamentosAgendas") THEN
		%>
			<div class="progress progress-small progress-striped active" style="margin:10px 0 0 0!important; height:3px!important" id="prog<%=replace(DataClick, "/", "")%>"></div>
		<%
		END IF

		response.Write Fstrong & "</TD>" & vbCrLf
		If iPosition = 7 Then
			Response.Write vbTab & "</TR>" & vbCrLf
			iPosition = 0
		End If
	
	iCurrent = iCurrent + 1
	iPosition = iPosition + 1
Loop

' Write spacer cells at end of last row if month doesn't end on a Saturday.
If iPosition <> 1 Then
	Do While iPosition <= 7
		Response.Write vbTab & vbTab & "<TD>&nbsp;</TD>" & vbCrLf
		iPosition = iPosition + 1
	Loop
	Response.Write vbTab & "</TR>" & vbCrLf
End If
%>
<tr class="hidden">
	<td height="70"><div class="Locais" id="nl1"></div></td>
	<td><div class="Locais" id="nl2"></div></td>
	<td><div class="Locais" id="nl3"></div></td>
	<td><div class="Locais" id="nl4"></div></td>
	<td><div class="Locais" id="nl5"></div></td>
	<td><div class="Locais" id="nl6"></div></td>
	<td><div class="Locais" id="nl7"></div></td>
</tr>
</tbody>
</table>





<script type="text/javascript">
$('.dia-calendario').click(function(){
	$("#Data").val($(this).attr("id"));
	loadAgenda($(this).attr("id"), $('#ProfissionalID').val());
	af('f');
});

<%if req("Data")<>"" and req("ProfissionalID")<>"" then
    call agendaOcupacoes(req("ProfissionalID"), req("Data"))
end if%>

 </script>
 <!--#include file="disconnect.asp"-->