<!--#include file="connect.asp"-->
<%
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

if req("date")="" then
	Data = date()
else
	Data = req("date")
end if
'	response.Redirect("NovoCalendario.asp?DRId="&req("DRId")&"&date="&date()&"&Remarcar="&req("Remarcar"))
'elseif isdate(req("date")) then
'	response.Redirect("NovoCalendario.asp?DRId="&req("DRId")&"&date="&req("date")&"&Remarcar="&req("Remarcar"))
'End If
'	dDate = req("date")

'Data=dDate

iDIM = GetDaysInMonth(Month(Data), Year(Data))
iDOW = GetWeekdayMonthStartsOn(Data)

MesX=month(Data)


DataAnte=dateadd("m",-1,Data)

DataProx=dateadd("m",1,Data)
%>
      <table class="table table-bordered" width="100%">
	  <thead>
      <tr>
        <th colspan="2" class="hand" onClick="chamaCalendario('<%=DataAnte%>','<%=req("DrId")%>');"><i class="far fa-arrow-left"></i></th>
        <th colspan="3" class="text-center"><%= ucase(left(monthname(MesX),3)) & " - " & Year(Data) %></th>
        <th colspan="2" class="hand" onClick="chamaCalendario('<%=DataProx%>','<%=req("DrId")%>');" class="text-right"><i class="far fa-arrow-right"></i></th>
      </tr>
      <tr>
        <th>DO</th>
        <th>SE</th>
        <th>TE</th>
        <th>QA</th>
        <th>QI</th>
        <th>SE</th>
        <th>SA</th>
      </tr>
      </thead>
      <tbody id="ApaEsc1">
      <%
' Write spacer cells at beginning of first row if month doesn't start on a Sunday.
If iDOW <> 1 Then
	Response.Write vbTab & "<tr>" & vbCrLf
	iPosition = 1
	Do While iPosition < iDOW
		Response.Write vbTab & vbTab & "<td bgcolor=""#F7F7F7""></td>" & vbCrLf
		iPosition = iPosition + 1
	Loop
End If

' Write days of month in proper day slots
iCurrent = 1
iPosition = iDOW
Do While iCurrent <= iDIM
	' If we're at the begginning of a row then write TR
	If iPosition = 1 Then
		Response.Write vbTab & "<tr>" & vbCrLf
	End If


if day("01/02/2009")=1 then
		if cdate(iCurrent&"/"&month(Data)&"/"&year(Data))=date() then
		corF="F7F7F7"
		strong="<strong>"
		Fstrong="</strong>"
		else
		corF="FFFFFF"
		strong=""
		Fstrong=""
		end if
else
		if cdate(month(Data)&"/"&iCurrent&"/"&year(Data))=date() then
		corF="F7F7F7"
		strong="<strong>"
		Fstrong="</strong>"
		else
		corF="FFFFFF"
		strong=""
		Fstrong=""
		end if
end if
		DataClick=iCurrent&"/"&month(Data)&"/"&year(Data)
		if req("DRId")="Q" then
			Response.Write vbTab & vbTab & "<td bgcolor="""&corF&""" class=""hand"
			if cdate(DataClick)=cdate(Data) then
				response.Write(" success green")
			end if
			response.Write(""" align=""right"" onclick=""location.href='?P=NovoQuadro&Pers=1&Data="&DataClick&"';"">"&strong& iCurrent &Fstrong& "</td>" & vbCrLf)
		else
			Response.Write vbTab & vbTab & "<td bgcolor="""&corF&""" class=""hand"" align=""right"" onclick=""chamaAgenda('"&DataClick&"','"&req("DRId")&"');"">"&strong& iCurrent &Fstrong& "</td>" & vbCrLf
		end if
	If iPosition = 7 Then
		Response.Write vbTab & "</tr>" & vbCrLf
		iPosition = 0
	End If
	
	iCurrent = iCurrent + 1
	iPosition = iPosition + 1
Loop

' Write spacer cells at end of last row if month doesn't end on a Saturday.
If iPosition <> 1 Then
	Do While iPosition <= 7
		Response.Write vbTab & vbTab & "<td bgcolor=""#F7F7F7"">&nbsp;</td>" & vbCrLf
		iPosition = iPosition + 1
	Loop
	Response.Write vbTab & "</tr>" & vbCrLf
End If
%>
</tbody>
</table>
<!--#include file = "disconnect.asp"-->