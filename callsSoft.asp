﻿$("#calls").html("");
<%
function repTel(Coluna)
	repTel = "replace(replace(replace(replace(replace("&Coluna&", '-', ''), ' ', ''), '(', ''), ')', ''), '\'','')"
end function




'SE TEM RELIGAÇÕES A FAZER
if req("Recontatar")<>"" then
    set prec = db.execute("select cr.*, c.Telefone, c.Resultado, c.Subresultado from chamadasrecontatar cr left join chamadas c on c.id=cr.ChamadaOrigemID where cr.id="&req("Recontatar"))
    set pcontant = db.execute("select * from chamadas where id="&prec("ChamadaOrigemID"))
    db_execute("insert into chamadas (StaID, sysUserAtend, DataHoraAtend, RE, Telefone, Contato, Resultado, Subresultado) values (1, "&session("User")&", now(), 2, '"&prec("Telefone")&"', '"&prec("Contato")&"', "&treatvalnull(prec("Resultado"))&", "&treatvalnull(prec("Subresultado"))&")")
    db_execute("delete from chamadasrecontatar where id="&req("Recontatar"))
end if


'STATUS => -1 rejeitada/nao atendida, 0 chamando, 1 atendida, 2 finalizada

'response.Write("select * from chamadas where (StaID=0 OR StaID=1 and sysUserAtend="&session("User")&") AND RejeitadaPor NOT LIKE '|"&session("User")&"|'")
set vcaCalls = db.execute("select * from chamadas where (StaID=0 OR StaID=1) and sysUserAtend="&session("User")&" AND (RejeitadaPor NOT LIKE '|"&session("User")&"|' OR RejeitadaPor IS NULL)")
if not vcaCalls.EOF and (recursoAdicional(21) = 4 or recursoAdicional(4) = 4) then
	%>
	$("#calls").css("display", "block");
	$("#calls").css("padding", "10px");
	$("#calls").css("z-index", "1000000");
    <%
    strCalls = "<h4 class='blue'><strong>NOVO CONTATO</strong></h4><hr><table class='table table-striped table-hover'>"
    while not vcaCalls.EOF
		Telefone = vcaCalls("Telefone")&""
        Telefone = replace(replace(replace(replace(replace(Telefone, "-", ""), " ", ""), "(", ""), ")", ""),"'","")
        if instr(vcaCalls("Telefone")&"", "@") then
    		set ident = db.execute("SELECT id, NomePaciente FROM pacientes WHERE trim(Email1)=trim('"&Telefone&"') OR trim(Email2)=trim('"&Telefone&"')")
        else
            sql = "SELECT id, NomePaciente FROM pacientes WHERE "&repTel("Tel1")&"='"&Telefone&"' OR "&repTel("Tel2")&"='"&Telefone&"' OR "&repTel("Cel1")&"='"&Telefone&"' OR "&repTel("Cel2")&"='"&Telefone&"'"
            'response.write(sql)
    		set ident = db.execute( sql)
        end if
		if not ident.EOF and trim(Telefone&"")<>"" then
			Nome = "<a href='./?P=pacientes&Pers=1&I="&ident("id")&"'>"&ident("NomePaciente")&"</a>"
			if isnull(vcaCalls("Contato")) then
				db_execute("update chamadas set Contato='3_"&ident("id")&"' where id="&vcaCalls("id"))
			end if
			PacienteID = ident("id")
		else
			Nome = "<em>Número não identificado</em>"
			PacienteID = 0
		end if
		if vcaCalls("StaID")=0 then
			strCalls = strCalls &"<tr><td><button type='button' class='btn btn-xs btn-success' title='Atender' onClick='callSta("&vcaCalls("id")&", 1)'><i class='fa fa-phone-square'></i></button> &nbsp; <button type='button' class='btn btn-xs btn-danger' title='Rejeitar' onClick=\""callSta("&vcaCalls("id")&", '-1')\""><i class='fa fa-remove'></i></button> "&Telefone&" &raquo; "&Nome
			if PacienteID<>"" then
				set age = db.execute("select a.Data, a.Hora, p.NomeProfissional from agendamentos a LEFT JOIN profissionais p on p.id=a.ProfissionalID WHERE PacienteID="&PacienteID&" AND Data>=DATE(NOW())")
				while not age.EOF
					strCalls = strCalls & "<div class='pull-right'>"& age("NomeProfissional") &" <button type='button' class='btn btn-xs btn-success'><i class='fa fa-calendar'></i> "& age("Data") &" - "& formatdatetime(age("Hora"), 4) &"</button></div>"
				age.movenext
				wend
				age.close
				set age=nothing
			end if

			strCalls = strCalls &" </td></tr>"
		elseif vcaCalls("StaID")=1 then
			strCalls = strCalls &"<tr id=\""linhaLigacao"&vcaCalls("id")&"\""><td><button type='button' class='btn btn-xs btn-info' title='Finalizar' onClick=\""callSta("&vcaCalls("id")&", 2)\"">Finalizar</button> "&Telefone&" &raquo; "& Nome &" </td></tr>"
			%>
            if( $("#AbrirEncaixe").val()==undefined && $("#searchSolicitantes").val()==undefined ){
                var leftWin = '100px';
            }else{
                var leftWin = '1000px';
            }

			if ($("#detalheLigacao<%=vcaCalls("id")%>").length==0){
            	$("#calls").before("<div class='dragavel' id='detalheLigacao<%=vcaCalls("id")%>' style='background-color:#fff; box-shadow: 0px 4px 8px 0px rgba(0, 0, 0, 0.2), 0px 6px 20px 0px rgba(0, 0, 0, 0.19); padding: 10px; border-radius: 10px; position:fixed; width:1050px; height:600px; top:100px; left:"+leftWin+"; z-index:10000000; overflow-x:hidden; overflow-y:scroll'>Carregando dados da ligação</div>");
                $.get("detalheLigacao.asp?CallID=<%=vcaCalls("id")%>", function(data){ $("#detalheLigacao<%=vcaCalls("id")%>").html(data) });
            }
			<%

		end if
	vcaCalls.movenext
	wend
	vcaCalls.close
	set vcaCalls=nothing
	strCalls = strCalls &"</table>"
	%>
    $("#calls").html("<%=strCalls%>");
	<%

	'marca como nao atendida (-1) todas as que estao tocando há mais de 1 minuto
'	db_execute("update chamadas SET StaID=-1 WHERE StaID=0 AND DataHora<DATE_ADD(NOW(), INTERVAL -1 MINUTE)")
	db.execute("update chamadas SET StaID=-1 WHERE StaID=0 AND DataHora<DATE_ADD(NOW(), INTERVAL -100 MINUTE)")

    aparece = "S"
end if

set vcaReligar = db.execute("select * from chamadasrecontatar where Data=date(now()) and Hora<=time(now()) and sysUser="&session("User"))
if not vcaReligar.EOF then
	%>
	$("#calls").css("display", "block");
	$("#calls").css("padding", "10px");
	$("#calls").css("z-index", "1000000");
    <%
    strCalls = "<h4 class='red'><strong>RECONTATAR</strong></h4><hr><table class='table table-striped table-hover'>"
    while not vcaReligar.EOF
   		set ident = db.execute("SELECT id, NomePaciente FROM pacientes WHERE id = '"&replace(vcaReligar("Contato")&"", "3_", "")&"'")
		if not ident.EOF then
			Nome = "<a href='./?P=pacientes&Pers=1&I="&ident("id")&"'>"&ident("NomePaciente")&"</a>"
			PacienteID = ident("id")
		else
			Nome = "<em>Número não identificado</em>"
			PacienteID = 0
		end if
		strCalls = strCalls &"<tr><td><button type='button' class='btn btn-xs btn-success' title='Recontatar' onClick='recontatar("&vcaReligar("id")&")'><i class='fa fa-phone-square'></i></button> &nbsp;  "&formatdatetime(vcaReligar("Hora"),4)&" &raquo; "&Nome

		strCalls = strCalls &" </td></tr>"
	vcaReligar.movenext
	wend
	vcaReligar.close
	set vcaReligar=nothing
	strCalls = strCalls &"</table>"
	%>
    $("#calls").html("<%=strCalls%>");
	<%


    aparece = "S"
end if
'marca como nao atendida (-1) todas as que estao tocando há mais de 1 minuto
db.execute("update chamadas SET StaID=-1 WHERE StaID=0 AND DataHora<DATE_ADD(NOW(), INTERVAL -1 MINUTE)")
'	db_execute("update chamadas SET StaID=-1 WHERE StaID=0 AND DataHora<DATE_ADD(NOW(), INTERVAL -100 MINUTE)")

if aparece="" then
	%>
	$("#calls").css("display", "none");
	<%
end if
%>
  $(function() {
    $( "#calls, .dragavel" ).draggable();
    $( ".dragavel" ).resizable();
  });