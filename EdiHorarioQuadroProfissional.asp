<!DOCTYPE html>
<html lang="en">
	<head>
		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		<link rel="stylesheet" href="assets/css/jquery-ui-1.10.3.custom.min.css" />
		<link rel="stylesheet" href="assets/css/chosen.css" />
		<link rel="stylesheet" href="assets/css/datepicker.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-timepicker.css" />
		<link rel="stylesheet" href="assets/css/daterangepicker.css" />
		<link rel="stylesheet" href="assets/css/colorpicker.css" />
		<link rel="stylesheet" href="assets/css/jquery.gritter.css" />
		<link rel="stylesheet" href="assets/css/select2.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-editable.css" />
		<script type="text/javascript" src="assets/js/jquery.min.js"></script>
        <script type="text/javascript" src="assets/js/jquery.maskedinput.min.js"></script>
        </head>
    <body>
<!--#include file="connect.asp"-->
<%
if req("X")<>"" then
	db_execute("delete from assfixalocalxprofissional where id = '"&req("X")&"'")
	refresh="s"
end if

if isnumeric(req("assId")) and not req("assId")="" then
	id=ccur(req("assId"))
else
	id=0
end if

LocalID = req("LocalID")
diaSemana = req("diaSemana")
HoraDe = "00:00"
HoraA = "00:00"
Intervalo = 30
if req("assId")<>"" then
	ProfissionalID = req("ProfissionalID")
	HoraDe = req("HoraDe")
	HoraA = req("HoraA")
	Intervalo = req("Intervalo")
end if
if ref("E")="E" then
	ProfissionalID = ref("ProfissionalID")
	HoraDe = ref("HoraDe")
	HoraA = ref("HoraA")
	diaSemana = ref("diaSemana")
	Intervalo = ref("Intervalo")
	if not isdate(HoraDe) or not isdate(HoraA) then
		erro="Preencha o per&iacute;odo com hor&aacute;rios v&aacute;lidos (formato HH:MM)."
	else
		if cdate(HoraDe)>=cdate(HoraA) then
			erro="O hor&aacute;rio inicial deve ser menor que o hor&aacute;rio final."
		else
			set vHL=db.execute("select * from assfixalocalxprofissional where diaSemana="&diaSemana&" and LocalID="&LocalID&" and id<>"&id&"")
			while not vHL.eof
''				if cdate(vHL("HoraA"))>=cdate(HoraDe) then
	''			erro="Este local j� est� ocupado no per�odo selecionado."&vHL("id")&"/"&id
		''		end if
			''	if cdate(vHL("HoraDe"))<=cdate(HoraA) then
				''erro="Este local j� est� ocupado no per�odo selecionado."&vHL("id")&"/"&id
				''end if
				%><%''=erro%><%
			vHL.moveNext
			wend
			vHL.close
			set vHL=nothing
			''set vHP
			
		end if
	end if
	'if ref("ProfissionalID")="0" then
	'	erro="Selecione um profissional."
	'end if
	if erro="" then
		if id=0 then
			db_execute("insert into assfixalocalxprofissional (DiaSemana, HoraDe, HoraA, ProfissionalID, LocalID, Intervalo) values ('"&diaSemana&"', '"&HoraDe&"', '"&HoraA&"', '"&ProfissionalID&"', '"&LocalID&"', "&treatvalnull(Intervalo)&")")
		else
			db_execute("update assfixalocalxprofissional set DiaSemana='"&diaSemana&"', HoraDe='"&HoraDe&"', HoraA='"&HoraA&"', ProfissionalID='"&ProfissionalID&"', LocalID='"&LocalID&"', Intervalo="&treatvalnull(Intervalo)&" where id = '"&id&"'")
		end if
		refresh="s"
	else%><font color="#FF0000"><strong><%=erro%></strong></font><%
	end if
end if
if refresh="s" then
%>
<script>
parent.location='./?P=EdiProfQD&Pers=1&LId=<%=req("LocalID")%>&Data=<%=date()%>';
</script>
<%
end if
%>
<form name="frm" id="frm" method="post" action="">
<table width="100%" border="0" cellspacing="2" cellpadding="2">
  <tr bgcolor="#F5E2EC">
    <td><strong>Dia da Semana</strong><br />
	<select class="form-control" name="diaSemana">
	<%
	d=0
	while d<7
	d=d+1
	%><option value="<%=d%>"<%if diaSemana=cstr(d) then%> selected="selected"<%end if%>><%=weekdayname(d)%></option>
	<%wend%>
	</select></td>
    <td width="20%">
      De 
        <input name="HoraDe" type="time" id="HoraDe" class="form-control input-mask-time" value="<%=HoraDe%>" size="5" maxlength="5" />
    </td>
    <td width="20%">
      &agrave;s<br>
      <input name="HoraA" type="time" id="HoraA" class="form-control input-mask-time" value="<%=HoraA%>" size="5" maxlength="5" />
    </td>
    <td width="20%">
    	Intervalo em minutos<br>
        <input type="number" class="form-control" name="Intervalo" id="Intervalo" value="<%=Intervalo%>">
    </td>
  </tr>
  <tr>
    <td>Profissional<br />
	<select name="ProfissionalID" class="form-control">
	<option value="0">Sem profissional definido</option>
	<%
	set pp=db.execute("select * from profissionais where sysActive=1 order by NomeProfissional")
	while not pp.eof
	%><option value="<%=pp("id")%>"<%if ProfissionalID=cstr(pp("id")) then%> selected="selected"<%end if%>><%=pp("NomeProfissional")%></option>
	<%
	pp.moveNext
	wend
	pp.close
	set pp=nothing
	%>
	</select>	</td>
    <td nowrap>
    <label>&nbsp;</label><br>
    <button type="submit" class="btn btn-sm btn-primary" name="Confirmar"><i class="far fa-save"></i> Salvar</button>
	<%if id>0 then%><button class="btn btn-sm btn-danger" type="button" onClick="location.href='?P=EdiHorarioQuadroProfissional&X=<%=id%>&LocalID=<%=req("LocalID")%>';"><i class="far fa-remove"></i> Excluir</button><%end if%>
	<input type="hidden" name="E" value="E" />
	
	</td>
  </tr>
</table>
</form>
	</body>
    <script>
	<!--#include file="jQueryFunctions.asp"-->
</html>