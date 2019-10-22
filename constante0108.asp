﻿<%
if session("User")="" then
    %>
    $("#disc").html('<i class="fa fa-plug"></i> VOC&Ecirc; EST&Aacute; DESCONECTADO. <a class="btn btn-default" href="./?P=Login">VOLTAR AO LOGIN</a>');
    $("#disc").removeClass('hidden');
    <%
else
    %>
    $("#disc").addClass('hidden');
    <!--#include file="connect.asp"-->
    <%
    if session("OtherCurrencies")="phone" then
	    %>
	    <!--#include file="callsSoft.asp"-->
	    <%
    end if
    set buscaAtu = db.execute("select * from sys_users where id="&session("User"))
    if not buscaAtu.eof then
        strUnid = "|"&session("UnidadeID")&","
        if lcase(session("table"))="profissionais" then
            Espera = buscaAtu("Espera")
            EsperaVazia = buscaAtu("EsperaVazia")&""
            if instr(EsperaVazia, strUnid)=0 then
                evUnidade = 0
            else
                evSpl = split( EsperaVazia, strUnid )
                evSpl2 = split(evSpl(1), "|")
                evUnidade = ccur( evSpl2(0) )
            end if
            'faz o rodapé do aguardo
            if Espera=0 and evUnidade=0 then
            '    msgEspera = "Nenhum paciente aguardando"
            '    corEspera = ""
                msgEspera = ""
                corEspera = ""
            elseif Espera=0 and evUnidade<>0 then
            '    msgEspera = evUnidade & " paciente"&plural(evUnidade, "")&" ger"&plural(evUnidade, "al")&" aguardando"
            '    corEspera = ""
                msgEspera = Espera
                corEspera = ""
            elseif Espera<>0 and evUnidade=0 then
                'msgEspera = "<b><span class='text-success'>" & Espera & " paciente"& plural(Espera, "") &" seu"& plural(Espera, "") &" aguardando</span></b>"
                'corEspera = "text-success"
                msgEspera = Espera
                corEspera = ""
            else
                'msgEspera = "<b><span class='text-success'>Pacientes aguardando: " & Espera &" seu"& plural(Espera, "") &" </span></b> - " & evUnidade & " ger"& plural(evUnidade, "al")
                'corEspera = "text-success"
                msgEspera = Espera
                corEspera = ""
            end if
        else
            EsperaTotal = buscaAtu("EsperaTotal")&""
            if instr(EsperaTotal, strUnid)=0 then
                etUnidade = 0
            else
                etSpl = split( EsperaTotal, strUnid )
                etSpl2 = split(etSpl(1), "|")
                etUnidade = ccur( etSpl2(0) )
            end if
            'faz o rodapé do aguardo
            if etUnidade=0 then
            '    msgEspera = "Nenhum paciente aguardando"
            '    corEspera = ""
                msgEspera = ""
            else
            '    msgEspera = etUnidade & " paciente"&plural(etUnidade, "")&" ger"&plural(etUnidade, "al")&" aguardando"
            '    corEspera = ""
                msgEspera = ""'pacientes da unidade esperando
            end if
        end if
        'msgEspera = "<i class='fa fa-users "& corEspera &"'></i> " & msgEspera
        %>
        $('#espera').html("<%=msgEspera %>");
        <%


	    notiftarefas = buscaAtu("notiftarefas")
	    if instr(notiftarefas, "|DISCONNECT|")>0 then
		    db_execute("update sys_users set notiftarefas='"&replace(trim(notiftarefas&" "), "|DISCONNECT|", "")&"' where id="&buscaAtu("id"))
		    session.Abandon()
		    %>
		    location.href='./?P=Login';
		    <%
	    end if
	    'CHAMADA DE VOZ
	    if buscaAtu("chamar")<>"" and not isnull(buscaAtu("chamar")) then
		    've se ainda está chamando ou se mudou o status
		    spl = split(buscaAtu("chamar"), "_")
		    set seAinda = db.execute("select a.*, l.NomeLocal from agendamentos a LEFT JOIN locais l on l.id=a.LocalID where a.StaID=5 and a.profissionalID="&spl(0)&" and a.PacienteID="&spl(1))
		    if not seAinda.EOF then
			    %>
			    $("#speak").attr("src", "speak.asp?C=<%=buscaAtu("chamar")%>&NomeLocal=<%=seAinda("NomeLocal") %>");
			    /*$("#speak").fadeIn(2000);
                setTimeout(function(){$("#speak").fadeOut(500)}, 27000);
                setTimeout(function(){$("#legend").fadeOut(500)}, 27000);*/
			    <%
		    end if
		    db_execute("update sys_users set chamar='' where id="&session("User"))
	    end if
	    'ATUALIZA CHAT
	    if not isnull(buscaAtu("novasmsgs")) and instr(buscaAtu("novasmsgs"), "|")>0 then
		    spl = split(buscaAtu("novasmsgs"), "|")
		    for i=0 to ubound(spl)
			    if spl(i)<>"" and isnumeric(spl(i)) then
				    %>
                    //if($("#chat_<%=spl(i)%>").css("display")=="none"){
                	    callWindow(<%=spl(i)%>);
                    //}else{
	                //    callTalk(<%=spl(i)%>, <%=session("User")%>, '', 'body_<%=spl(i)%>');
                    //}
                    <%
				    db_execute("update sys_users set novasmsgs='"&replace(buscaAtu("novasmsgs"), "|"&session("User")&"|", "")&"' where id="&spl(i))
			    end if
		    next
	    end if
	    'TAREFAS
	    tarefasVencidas = 0
	    if instr(notiftarefas, ",")>0 then
		    spl = split(notiftarefas, "|")
		    for i=0 to ubound(spl)
			    if instr(spl(i), ",") then
				    spl2 = split(spl(i), ",")
				    if isdate(spl2(1)) and spl2(1)<>"" then
					    if cdate(spl2(1))<now() then
						    tarefasVencidas = tarefasVencidas+1
					    end if
				    elseif isnumeric(spl2(0)) and not isdate(spl2(1)) then
					    tarefasVencidas = tarefasVencidas+1
				    end if
			    end if
		    next
	    end if
	    if tarefasVencidas>0 then
		    %>
		    $("#notifTarefas").html("<i class='fa fa-tasks'></i><span class='badge badge-danger'><%=tarefasVencidas%></span>");
		    <%
	    end if
	
	    'NOTIFICAÇÕES DE COBRANÇA
	    if 1=1 then
		    Notificacoes = ""
		    notiflanctos = buscaAtu("notiflanctos")
		    cNot = 0
		    if len(notiflanctos)>2 then
			    splnotiflanctos = split(notiflanctos, "|")
			    for nl=0 to ubound(splnotiflanctos)
				    if isnumeric(splnotiflanctos(nl)) and splnotiflanctos(nl)<>"" then
					    set atend = db.execute("select at.*, p.NomePaciente, p.Foto from atendimentos as at left join pacientes as p on at.PacienteID=p.id where at.id="&splnotiflanctos(nl)&" and not isnull(p.NomePaciente)")
					    if not atend.eof then
						    if atend("Foto")<>"" and not isnull(atend("Foto")) then
							    FotoNotif = "/uploads/"&atend("Foto")
						    else
							    FotoNotif = "assets/img/atFim.png"
						    end if
						    cNot = cNot+1



                            Notificacoes = Notificacoes & "<div class='media'><a class='media-left' href='#'> <img src='"& FotoNotif &"' class='mw40' alt='avatar'> </a> <div class='media-body'> <h5 class='media-heading'>"&atend("NomePaciente")&" <small class='text-muted'></small> </h5> Por "&nameInTable(atend("sysUser"))&" </div> <div class='media-right'> <div class='media-response'> ATENDIMENTO</div> <div class='btn-group'> <button onclick=\""location.href='?P=Pacientes&Pers=1&I="&atend("PacienteID")&"&A="&atend("id")&"&Ct=1'\"" type='button' class='btn btn-default btn-xs light'> <i class='fa fa-check text-success'></i> FECHAR CONTA</button> <button type='button' class='btn btn-default btn-xs light hidden'> <i class='fa fa-remove'></i> </button> </div> </div> </div>"

						    'Notificacoes = Notificacoes&"<li class=\""dropdown-header\""><img src=\"""
						    'Notificacoes = Notificacoes&"\"" width=\""44\"" class=\""img-circle\"">Paciente: <strong id=\""lancto"&atend("id")&"\"">"&atend("NomePaciente")&"</strong> <br /><small>Por "&nameInTable(atend("sysUser"))&"</small><br /><button type=\""button\"" class=\""btn btn-xs btn-success btn-block\"" onclick=\""location.href='?P=Pacientes&Pers=1&I="&atend("PacienteID")&"&A="&atend("id")&"&Ct=1';\""><i class=\""fa fa-money\""></i> FECHAR CONTA</button></li>"
					    end if
				    end if
			    next
		    end if







		    if Notificacoes<>"" then
			    %>
    	        $("#Notificacoes").html("<%=Notificacoes%>");
                $("#box-bell").addClass("purple");
                $("#bell").addClass("fa-animated-bell");
                $("#badge-bell").html("<%=cNot%>");
        	    <%
            end if
	    else
		    notiflanctos = buscaAtu("notiflanctos")
		    if len(notiflanctos)>2 then
			    splnotiflanctos = split(notiflanctos, "|")
			    for nl=0 to ubound(splnotiflanctos)
				    if isnumeric(splnotiflanctos(nl)) and splnotiflanctos(nl)<>"" then
					    set atend = db.execute("select at.*, p.NomePaciente, p.Foto from atendimentos as at left join pacientes as p on at.PacienteID=p.id where at.id="&splnotiflanctos(nl))
					    if not atend.eof then
						    %>
						    if($("#lancto<%=atend("id")%>").html()==null){
							    $.gritter.add({
								    title: 'ATENDIMENTO INFORMADO',
								    text: 'Paciente: <strong id="lancto<%=atend("id")%>"><%=atend("NomePaciente")%></strong> <br /><small>Por <%=nameInTable(atend("sysUser"))%></small><br /><button type="button" class="btn btn-xs btn-success btn-block" onclick="location.href=\'?P=Conta&Pers=1&I=<%=atend("PacienteID")%>&A=<%=atend("id")%>\';"><i class="fa fa-money"></i> FECHAR CONTA</button>',
								    class_name: 'gritter-error gritter-light',
								    image: '<%if atend("Foto")<>"" and not isnull(atend("Foto")) then%>/uploads/<%=atend("Foto")%><%else%>assets/img/atFim.png<%end if%>',
								    sticky: true
							    });
						    }
						    <%
					    end if
				    end if
			    next
		    end if
	    end if
    end if

    if device()="" then
	    db_execute("update sys_users set UltRef="&mydatetime(now())&" where id="&session("User"))
	    if not isnull(buscaAtu("UltPac")) then
	    %>
	    if($("#btnFicha").val()==undefined){
            $.get("nullpac.asp", function(data){});
        }
	    <%
	    end if
    else
	    db_execute("update sys_users set UltRefDevice="&mydatetime(now())&" where id="&session("User"))
	    if not isnull(buscaAtu("UltPac")) then
		    set pac = db.execute("select id, NomePaciente from pacientes where id="&buscaAtu("UltPac"))
		    if not pac.eof then
			    %>
			    $("#divDevice").css("display", "block");
                $("#divDevice").html("<a href='./?P=Pacientes&I=<%=pac("id")%>&Pers=1' class='btn btn-warning btn-block btn-default'>Paciente no PC: <%=pac("NomePaciente")%></a>");
			    <%
		    end if
	    end if
    end if

    if req("SP")="TotemPrint" then
        set vca = db.execute("select id, Senha from guiche where Sta='Imprimir' limit 1")
        if not vca.eof then
            %>
            $("#bodyTicket").html("<h4 style='text-align:center'>SENHA</h4><h1 style='text-align:center'><%=zeroEsq(vca("Senha"), 4)%></h1><center><img src='logo/altaclinicas_pb.png' style='width:3cm' /></center>");
            print();
            <%
            db_execute("update guiche set Sta='Espera' where id="&vca("id"))
        else
            %>
            $("#bodyTicket").html("Prompt de impressão...");
            <%
        end if
    end if
    if req("SP")="Totem" then
        set vca = db.execute("select id, Senha from guiche where Sta='Imprimir' limit 1")
        if vca.eof then
            %>
            $("#btnGerar").removeClass("hidden");
            $("#divImprimir").addClass("hidden");
            <%
        end if
    end if
    if req("P")="PreEspera" then
        %>
        listaPreEspera();
        <%
    end if

db_execute("update cliniccentral.licencasusuarios set URL='"&Request.ServerVariables("URL")&"', UltRef=NOW() where id="&session("User"))

    %>
    <!--#include file="disconnect.asp"-->

<%
end if
%>

