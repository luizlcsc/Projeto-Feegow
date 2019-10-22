<!--#include file="connect.asp"-->
<%
Dia=0
while Dia < 7
	Dia=Dia+1

	set VeDia=db.execute("select * from Horarios where ProfissionalID like '"&request.QueryString("ProfissionalID")&"' and Dia like '"&Dia&"'")
	Atende=request.Form("Atende"&Dia)
	HoraDe=request.Form("HoraDe"&Dia)
	HoraAs=request.Form("HoraAs"&Dia)
	Pausa=request.Form("Pausa"&Dia)
	PausaDe=request.Form("PausaDe"&Dia)
	PausaAs=request.Form("PausaAs"&Dia)
	Intervalos=request.Form("Intervalos"&Dia)
	
	'definicao dos erros
	erro1=""
	erro2=""
	erro3=""
	if Atende="S" then
		if not isdate(request.Form("HoraDe"&Dia)) then
			erro1="&raquo; Horário de início de atendimento inválido."
		end if
		if not isdate(request.Form("HoraAs"&Dia)) then
			erro1="&raquo; Horário de fim de atendimento inválido."
		end if
		if isdate(request.Form("HoraDe"&Dia)) and isdate(request.Form("HoraAs"&Dia)) then
			if cdate(request.Form("HoraDe"&Dia))>=cdate(request.Form("HoraAs"&Dia)) then
				erro1="&raquo; Horário de fim de atendimento deve ser maior que o horário de início de atendimento."
			end if
		end if
		if not isdate(request.Form("Intervalos"&Dia)) then
			erro3="&raquo; Intervalo de "&weekdayname(Dia)&" inválido."&request.Form("Intervalos"&Dia)
		else
			if cdate(request.Form("Intervalos"&Dia))=cdate("00:00") then
				erro3="&raquo; Informe o intervalo entre os atendimentos.<br>"
			end if
		end if
	end if

	if Pausa="S" then
		if not isdate(request.Form("PausaDe"&Dia)) then
			erro2="&raquo; Horário de início de pausa inválido."
		end if
		if not isdate(request.Form("PausaAs"&Dia)) then
			erro2="&raquo; Horário de fim de pausa inválido."
		end if
		if isdate(request.Form("PausaDe"&Dia)) and isdate(request.Form("PausaAs"&Dia)) then
			if cdate(request.Form("PausaDe"&Dia))>=cdate(request.Form("PausaAs"&Dia)) then
				erro2="&raquo; Horário de fim de pausa deve ser maior que o horário de início da pausa."
			end if
		end if
	end if
	if erro1="" and erro2="" and erro3="" and isdate(HoraDe) and isdate(HoraAs) and isdate(PausaDe) and isdate(PausaAs) and isdate(Intervalos) then
		if VeDia.EOF then
			db_execute("insert into Horarios (ProfissionalID,Atende,Dia,HoraDe,HoraAs,Pausa,PausaDe,PausaAs,Intervalos) values ('"&request.QueryString("ProfissionalID")&"','"&Atende&"','"&Dia&"','"&HoraDe&"','"&HoraAs&"','"&Pausa&"','"&PausaDe&"','"&PausaAs&"','"&Intervalos&"')")
		else
			db_execute("update Horarios set Atende='"&Atende&"',HoraDe='"&HoraDe&"',HoraAs='"&HoraAs&"',Pausa='"&Pausa&"',PausaDe='"&PausaDe&"',PausaAs='"&PausaAs&"',Intervalos='"&Intervalos&"' where id = '"&VeDia("id")&"'")
		end if
	else
		if erro1<>"" or erro2<>"" or erro3<>"" then
			algumErro = "S"
			%>
            $.gritter.add({
                title: '<i class="fa fa-thumbs-down"></i> Erro no horário de <%=weekdayname(Dia)%>!',
                text: '<%=erro1%><br><%=erro2%><br><%=erro3%>',
                class_name: 'gritter-error gritter-light'
            });
			<%
		end if
	end if
wend

if algumErro="" then
	%>
        $.gritter.add({
            title: '<i class="fa fa-save"></i> Horários gravados com sucesso!',
            text: '',
            class_name: 'gritter-success gritter-light'
        });
	<%
end if

%>