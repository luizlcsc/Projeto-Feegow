<!--#include file="connect.asp"-->
<%
Dia=0
while Dia < 7
	Dia=Dia+1

	set VeDia=db.execute("select * from Horarios where ProfissionalID like '"&req("ProfissionalID")&"' and Dia like '"&Dia&"'")
	Atende=ref("Atende"&Dia)
	HoraDe=ref("HoraDe"&Dia)
	HoraAs=ref("HoraAs"&Dia)
	Pausa=ref("Pausa"&Dia)
	PausaDe=ref("PausaDe"&Dia)
	PausaAs=ref("PausaAs"&Dia)
	Intervalos=ref("Intervalos"&Dia)
	
	'definicao dos erros
	erro1=""
	erro2=""
	erro3=""
	if Atende="S" then
		if not isdate(ref("HoraDe"&Dia)) then
			erro1="&raquo; Horário de início de atendimento inválido."
		end if
		if not isdate(ref("HoraAs"&Dia)) then
			erro1="&raquo; Horário de fim de atendimento inválido."
		end if
		if isdate(ref("HoraDe"&Dia)) and isdate(ref("HoraAs"&Dia)) then
			if cdate(ref("HoraDe"&Dia))>=cdate(ref("HoraAs"&Dia)) then
				erro1="&raquo; Horário de fim de atendimento deve ser maior que o horário de início de atendimento."
			end if
		end if
		if not isdate(ref("Intervalos"&Dia)) then
			erro3="&raquo; Intervalo de "&weekdayname(Dia)&" inválido."&ref("Intervalos"&Dia)
		else
			if cdate(ref("Intervalos"&Dia))=cdate("00:00") then
				erro3="&raquo; Informe o intervalo entre os atendimentos.<br>"
			end if
		end if
	end if

	if Pausa="S" then
		if not isdate(ref("PausaDe"&Dia)) then
			erro2="&raquo; Horário de início de pausa inválido."
		end if
		if not isdate(ref("PausaAs"&Dia)) then
			erro2="&raquo; Horário de fim de pausa inválido."
		end if
		if isdate(ref("PausaDe"&Dia)) and isdate(ref("PausaAs"&Dia)) then
			if cdate(ref("PausaDe"&Dia))>=cdate(ref("PausaAs"&Dia)) then
				erro2="&raquo; Horário de fim de pausa deve ser maior que o horário de início da pausa."
			end if
		end if
	end if
	if erro1="" and erro2="" and erro3="" and isdate(HoraDe) and isdate(HoraAs) and isdate(PausaDe) and isdate(PausaAs) and isdate(Intervalos) then
		if VeDia.EOF then
			db_execute("insert into Horarios (ProfissionalID,Atende,Dia,HoraDe,HoraAs,Pausa,PausaDe,PausaAs,Intervalos) values ('"&req("ProfissionalID")&"','"&Atende&"','"&Dia&"','"&HoraDe&"','"&HoraAs&"','"&Pausa&"','"&PausaDe&"','"&PausaAs&"','"&Intervalos&"')")
		else
			db_execute("update Horarios set Atende='"&Atende&"',HoraDe='"&HoraDe&"',HoraAs='"&HoraAs&"',Pausa='"&Pausa&"',PausaDe='"&PausaDe&"',PausaAs='"&PausaAs&"',Intervalos='"&Intervalos&"' where id = '"&VeDia("id")&"'")
		end if
	else
		if erro1<>"" or erro2<>"" or erro3<>"" then
			algumErro = "S"
			%>
            $.gritter.add({
                title: '<i class="far fa-thumbs-down"></i> Erro no horário de <%=weekdayname(Dia)%>!',
                text: '<%=erro1%><br><%=erro2%><br><%=erro3%>',
                class_name: 'gritter-error gritter-light'
            });
			<%
		end if
	end if
wend

if algumErro="" then
	%>



		gtag('event', 'nova_grade_de_horarios', {
			'event_category': 'grade_de_horarios',
			'event_label': "Grade de Horários > Salvar",
		});
		
        $.gritter.add({
            title: '<i class="far fa-save"></i> Horários gravados com sucesso!',
            text: '',
            class_name: 'gritter-success gritter-light'
        });
	<%
end if

%>