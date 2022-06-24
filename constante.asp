<!--#include file="Classes/LogService.asp"-->
<%
if session("User")="" then
    call sendLogSessionExpired()
    %>
    $("#disc").html('<i class="far fa-plug"></i> VOC&Ecirc; EST&Aacute; DESCONECTADO. <a class="btn btn-default" href="./?P=Login&qs=<%=ref("qs")%>">VOLTAR AO LOGIN</a>');
    $("#disc").removeClass('hidden');
    <%
else
    %>
    $("#disc").addClass('hidden');
    <!--#include file="connect.asp"-->
    <!--#include file="Classes/StringFormat.asp"-->

    <%


    if (session("OtherCurrencies")="phone") and session("Banco")<>"clinic5459" then
        if recursoAdicional(9) = 4 or recursoAdicional(21) = 4 or recursoAdicional(4) = 4 then
	    %>
	    <!--#include file="callsSoft.asp"-->
	    <%
        end if
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
        'msgEspera = "<i class='far fa-users "& corEspera &"'></i> " & msgEspera
        %>
        $('#espera').html("<%=msgEspera %>");
        <%


	    notiftarefas = buscaAtu("notiftarefas")
	    if instr(notiftarefas, "|DISCONNECT|")>0 then
		    db.execute("update sys_users set notiftarefas='"&replace(trim(notiftarefas&" "), "|DISCONNECT|", "")&"' where id="&buscaAtu("id"))

		    session.Abandon()
		    %>
		    location.href='./?P=Login&qs=<%=ref("qs")%>';
		    <%
	    end if
	    'CHAMADA DE VOZ
       
	    if buscaAtu("chamar")<>"" and not isnull(buscaAtu("chamar")) then
		    've se ainda está chamando ou se mudou o status


            chamar = buscaAtu("chamar")

            if chamar&""<>"" and instr(chamar, "|")=0 then
                chamar="|"&chamar
            end if

            MyString = Mid(chamar, 2)
            spl = split(MyString, "|")
		    'spl = split(buscaAtu("chamar"), "_")

            list = array()
            for i=0 to ubound(spl)
                ReDim Preserve list(UBound(list) + 1)
                list(UBound(list)) = spl(i)            
            next
        
            list2 = array()
            for u=0 to ubound(list)
                spl = split(list(u), "_")
                ReDim Preserve list2(UBound(list2) + 1)
                list2(UBound(list2)) = " (a.profissionalID="&spl(0)& " and  a.PacienteID="&spl(1)&") "            
            next

            JoinLike = Join(list2, " or ")

		    StaChamando = 5
            set RecursosAdicionaisSQL = db.execute("SELECT RecursosAdicionais FROM sys_config WHERE id=1")

            if not RecursosAdicionaisSQL.eof then
                if instr(RecursosAdicionaisSQL("RecursosAdicionais"), "|PreConsulta|") then
		            StaChamando = "5,105,106"
		        end if
		    end if

		    set seAinda = db.execute("select a.*, l.NomeLocal from agendamentos a LEFT JOIN locais l on l.id=a.LocalID where a.StaID IN ("&StaChamando&") and "&JoinLike)            		                    
            
            listPacientProfissionalId = array()
            listPacientProfissionalNomeLocal = array()                  
            while not seAinda.eof
                ReDim Preserve listPacientProfissionalId(UBound(listPacientProfissionalId) + 1)
                listPacientProfissionalId(UBound(listPacientProfissionalId)) = seAinda("ProfissionalID")&"_"&seAinda("PacienteID")              

                ReDim Preserve listPacientProfissionalNomeLocal(UBound(listPacientProfissionalNomeLocal) + 1)
                listPacientProfissionalNomeLocal(UBound(listPacientProfissionalNomeLocal)) = seAinda("NomeLocal")&""
            seAinda.movenext
            wend
            seAinda.close
            set seAinda=nothing

            JoinLikeListPacientProfissionalId = Join(listPacientProfissionalId, "|")
            JoinLikeListPacientProfissionalNomeLocal = Join(listPacientProfissionalNomeLocal, "|")

            if JoinLikeListPacientProfissionalNomeLocal&""="" then
                JoinLikeListPacientProfissionalNomeLocal = "|"
            end if

            if JoinLikeListPacientProfissionalId <> "" then              	
			    %>
			    $("#speak").attr("src", "speak.asp?C=<%=JoinLikeListPacientProfissionalId%>&NomeLocal=<%=JoinLikeListPacientProfissionalNomeLocal %>");

			    /*$("#speak").fadeIn(2000);
                setTimeout(function(){$("#speak").fadeOut(500)}, 27000);
                setTimeout(function(){$("#legend").fadeOut(500)}, 27000);*/
			    <%               
		    end if
		    db_execute("update sys_users set chamar='' where id="&session("User"))
	    end if
        'teste para atualizar lista de usuarios online no chat
        %>
        if($("#txtPesquisar").is(":focus")==false){
            if($(".sb-r-o").length > 0){
                chatUsers();
            }
        }
	    <!--#include file="chatStatus.asp"-->
        <%
	    'ATUALIZA CHAT
	    if not isnull(buscaAtu("novasmsgs")) and instr(buscaAtu("novasmsgs"), "|")>0 then
		    spl = split(buscaAtu("novasmsgs"), "|")
		    for i=0 to ubound(spl)
			    if spl(i)<>"" and isnumeric(spl(i)) then
                set buscaChatName = db.execute("select lu.Nome from sys_users u left join cliniccentral.licencasusuarios lu ON lu.id=u.id where u.id="&spl(i))
				    if not buscaChatName.eof then
				    set msg = db.execute("SELECT Mensagem FROM chatmensagens WHERE De = "&spl(i)&" AND Para = "&session("User")&" AND visualizado=0 ORDER BY id DESC LIMIT 1")

				    if not msg.eof then
                        %>
                        if($("#chat_<%=spl(i)%>").parents(".dockmodal-body").length != 0){
                            chatUpdate(<%=spl(i)%>);
                        }else{
                            callWindow(<%=spl(i)%>, '<%=buscaChatName("Nome")%>');
                            //callTalk(<%=spl(i)%>, <%=session("User")%>, '', 'body_<%=spl(i)%>');
                        }
                        <% IF (getConfig("SonsNotificacao")) THEN %>
                        document.getElementById("audioNotificacao").play();
                        <% END IF %>
                        chatNotificacao('Nova mensagem de <%=buscaChatName("Nome")%>', '<%=fix_string_chars_full(msg("Mensagem")&"")%>');
                        <%
                        end if
                    end if
                    'modificação sanderson, update na mensagem ja lida, para não aparecer toda hora para o usuario
				    'db_execute("update sys_users set novasmsgs='"&replace(buscaAtu("novasmsgs"), "|"&session("User")&"|", "")&"' where id="&spl(i))
                    'db_execute("update sys_users set novasmsgs='"&replace(buscaAtu("novasmsgs"), "|"&spl(i)&"|", "")&"' where id="&session("User"))

			    end if
		    next
	    end if
	    'TAREFAS
	    tarefasVencidas = 0
        tarefasTotais = 0
	    if instr(notiftarefas, ",")>0 then
		    spl = split(notiftarefas, "|")
            tarefasTotais= ubound(spl)
		    ' for i=0 to ubound(spl)
			'     if instr(spl(i), ",") then
			' 	    spl2 = split(spl(i), ",")
			' 	    if isdate(spl2(1)) and spl2(1)<>"" then
			' 		    if cdate(spl2(1))<now() then
			' 			    tarefasVencidas = tarefasVencidas+1
			' 		    end if
			' 	    elseif isnumeric(spl2(0)) and not isdate(spl2(1)) then
			' 		    tarefasVencidas = tarefasVencidas+1
			' 	    end if
			'     end if
		    ' next
	    end if

	    if tarefasTotais>0 then
		    %>
		    $("#notifTarefas").html("<i class='far fa-tasks'></i><span class='badge badge-danger'><%=tarefasTotais%></span>");
		    <%
        else
            %>
            $("#notifTarefas").html("<i class='far fa-tasks'></i>")
            <%
	    end if
        Notificacoes = ""
        cNot = 0
    
	    if buscaAtu("TemNotificacao") then
	        set NotificacoesSQL = db_execute("SELECT n.*, nt.TextoNotificacao, NT.Descricao DescricaoNotificacao "&_
            "FROM notificacoes n INNER JOIN cliniccentral.notificacao_tipo nt ON nt.id=n.TipoNotificacaoID "&_
            "WHERE n.StatusID IN (1,2) AND TipoNotificacaoID != 4 AND n.UsuarioID="&buscaAtu("id")&" "&_
            "ORDER BY id DESC LIMIT 20")
            
	        while not NotificacoesSQL.eof
	            cNot=cNot+1
	            userName = left(nameInTable(NotificacoesSQL("CriadoPorID")),15)

	            TextoNotificacao = replace(replace(NotificacoesSQL("TextoNotificacao"),chr(13),""),chr(10),"")

	            'TextoNotificacao = replace(TextoNotificacao, "[DATA_HORA]", datediff("d", NotificacoesSQL("DataHora"), time()))
	            TextoNotificacao = replace(TextoNotificacao, "[USUARIO_CRIADOR.NOME]", userName)
	            TextoNotificacao = replace(TextoNotificacao, "[METADATA.TEXTO]", replace(replace(NotificacoesSQL("metadata"), chr(10), " "), chr(13), " "))
	            TextoNotificacao = replace(TextoNotificacao, "[NOTIFICACAO.ID]", NotificacoesSQL("id"))
	            TextoNotificacao = replace(TextoNotificacao, "[ID_RELATIVO]", NotificacoesSQL("NotificacaoIDRelativo"))
	            TextoNotificacao = replace(TextoNotificacao, "[TIPO_NOTIFICACAO]", NotificacoesSQL("DescricaoNotificacao"))

                Notificacoes = Notificacoes & TextoNotificacao

	        NotificacoesSQL.movenext
	        wend
	        NotificacoesSQL.close
	        set NotificacoesSQL=nothing
	    end if

        'Buscar os descontos pendentes

        set NotificacoesSQL = db.execute("SELECT count(n.id) total FROM notificacoes n INNER JOIN cliniccentral.notificacao_tipo nt ON nt.id=n.TipoNotificacaoID WHERE n.StatusID IN (1) AND TipoNotificacaoID = 4 AND n.UsuarioID="&Session("User"))
        if not NotificacoesSQL.eof then 
            if ccur(NotificacoesSQL("total")) > 0 then 
                %>
                    openModal("<div class='row'><div class='col-md-12'> Existem descontos pendentes de aprovação. <br><br> <a style='float:right' class='btn btn-success btn-sm' href='?P=DescontoPendente&Pers=1'><i class='far fa-percentage'></i> Ver descontos</a> </div></div>", "Descontos Pendentes", true, false, "sm")
                     $("#audioNotificacao").trigger("play");
                <%
                sqlAtualizar = "update notificacoes set StatusID = 2 where StatusID IN (1) AND TipoNotificacaoID = 4 AND UsuarioID="&Session("User")
                db.execute(sqlAtualizar)
            end if
        end if
        NotificacoesSQL.close
        set NotificacoesSQL=nothing
	
        'Adicionar notificação se ouver ainda algum desconto para ser aprovado

	    'NOTIFICAÇÕES DE COBRANÇA
	    if 1=1 then
		    notiflanctos = buscaAtu("notiflanctos")
		    if len(notiflanctos)>2 then
			    splnotiflanctos = split(notiflanctos, "|")
			    for nl=0 to ubound(splnotiflanctos)
				    if isnumeric(splnotiflanctos(nl)) and splnotiflanctos(nl)<>"" then
					    set atend = db.execute("select at.*, p.NomePaciente, p.Foto from atendimentos as at left join pacientes as p on at.PacienteID=p.id where at.id="&splnotiflanctos(nl)&" and not isnull(p.NomePaciente)")
					    if not atend.eof then
						    if atend("Foto")<>"" and not isnull(atend("Foto")) then
							    FotoNotif = arqEx(atend("Foto"), "Perfil")
						    else
							    FotoNotif = "assets/img/atFim.png"
						    end if
						    cNot = cNot+1



                            Notificacoes = Notificacoes & "<div class='media'><a class='media-left' href='#'> <img src='"& FotoNotif &"' class='mw40' alt='avatar'> </a> <div class='media-body'> <h5 class='media-heading'>"&atend("NomePaciente")&" <small class='text-muted'></small> </h5> Por "&nameInTable(atend("sysUser"))&" </div> <div class='media-right'> <div class='media-response'> ATENDIMENTO</div> <div class='btn-group'> <button onclick=\""location.href='?P=Pacientes&Pers=1&I="&atend("PacienteID")&"&A="&atend("id")&"&Ct=1'\"" type='button' class='btn btn-default btn-xs light'> <i class='far fa-check text-success'></i> FECHAR CONTA</button> <button type='button' class='btn btn-default btn-xs light hidden'> <i class='far fa-remove'></i> </button> </div> </div> </div>"

						    'Notificacoes = Notificacoes&"<li class=\""dropdown-header\""><img src=\"""
						    'Notificacoes = Notificacoes&"\"" width=\""44\"" class=\""img-circle\"">Paciente: <strong id=\""lancto"&atend("id")&"\"">"&atend("NomePaciente")&"</strong> <br /><small>Por "&nameInTable(atend("sysUser"))&"</small><br /><button type=\""button\"" class=\""btn btn-xs btn-success btn-block\"" onclick=\""location.href='?P=Pacientes&Pers=1&I="&atend("PacienteID")&"&A="&atend("id")&"&Ct=1';\""><i class=\""far fa-money\""></i> FECHAR CONTA</button></li>"
                                
                            atend.close
                            set atend=nothing
					    end if
				    end if
			    next
		    end if


		    if Notificacoes<>"" then
			    %>
    	        $("#Notificacoes").html(`<%=Notificacoes%>`);
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
								    text: 'Paciente: <strong id="lancto<%=atend("id")%>"><%=atend("NomePaciente")%></strong> <br /><small>Por <%=nameInTable(atend("sysUser"))%></small><br /><button type="button" class="btn btn-xs btn-success btn-block" onclick="location.href=\'?P=Conta&Pers=1&I=<%=atend("PacienteID")%>&A=<%=atend("id")%>\';"><i class="far fa-money"></i> FECHAR CONTA</button>',
								    class_name: 'gritter-error gritter-light',
								    image: '<%if atend("Foto")<>"" and not isnull(atend("Foto")) then%>/uploads/<%=atend("Foto")%><%else%>assets/img/atFim.png<%end if%>',
								    sticky: true
							    });
						    }
						    <%
                            atend.close
                            set atend=nothing
					    end if
				    end if
			    next
		    end if
	    end if


		if req("P")="Agenda-1" or req("P")="Agenda-S" or req("P")="AgendaMultipla" then
			'grava o agendamento que está aberto
			if req("AgAberto")<>"undefined" and req("AgAberto")<>"" then
				db.execute("update sys_users set AgAberto='"& req("AgAberto") &"' where id="& session("User"))
			else
				db.execute("update sys_users set AgAberto='' where id="& session("User") &" and AgAberto<>''")
			end if

		end if
    end if

    if device()="" then
        if session("MasterPwd")&"" <> "S" then
	        db.execute("update sys_users set UltRef="&mydatetime(now())&" where id="&session("User"))
        end if
	    if not isnull(buscaAtu("UltPac")) then
	    %>
	    if($("#btnFicha").length === 0){
            $.get("nullpac.asp", function(data){});
        }
	    <%
	    end if
    else
	    db.execute("update sys_users set UltRefDevice="&mydatetime(now())&" where id="&session("User"))
	    if not isnull(buscaAtu("UltPac"))  then
		    set pac = db.execute("select id, NomePaciente from pacientes where id="&buscaAtu("UltPac"))
		    if not pac.eof then
			    %>

			    if (mensagemPaciente && $("#btnFicha").length===0){
                    new PNotify({
                        title: 'Paciente no PC: <%=pac("NomePaciente")%>',
                        text: "<a href='./?P=Pacientes&I=<%=pac("id")%>&Pers=1' class='btn btn-warning btn-block btn-default'>Paciente no PC: <%=pac("NomePaciente")%></a>",
                        image: 'assets/img/Doctor.png',
                        sticky: true,
                        type: 'system'
                    });
                    mensagemPaciente=false;
                }
			    //$("#divDevice").css("display", "block");
                //$("#divDevice").html("<a href='./?P=Pacientes&I=<%=pac("id")%>&Pers=1' class='btn btn-warning btn-block btn-default'>Paciente no PC: <%=pac("NomePaciente")%></a>");
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

    'db_execute("update cliniccentral.licencasusuarios set URL='"&Request.ServerVariables("URL")&"', UltRef=NOW() where id="&session("User"))


    'desativa processo de logoff do user logado
    if right(minute(time()), 1)="5" or right(minute(time()), 1)="0" and false then

        if session("Admin")=1 then
            set LicencaSQL = dbc.execute("SELECT Status FROM cliniccentral.licencas WHERE id="&replace(session("Banco"), "clinic", "")&" AND Status='B'")

            if not LicencaSQL.eof then
                db.execute("update sys_users set notiftarefas=concat(notiftarefas, '|DISCONNECT|') where date(UltRef)=curdate() and DATE_SUB(CURTIME(), INTERVAL 2 MINUTE) <= UltRef ")
            end if
        end if

        'db.execute("update cliniccentral.licencas set ultimoRefresh=now() where id="& replace(session("Banco"), "clinic", ""))
    end if

    if req("P")="Home" then
        set numeroProdutosValidade = db.execute("SELECT COUNT(distinct p.id) total FROM estoqueposicao ep INNER JOIN produtos p ON p.id = ep.ProdutoID WHERE ep.Quantidade > 0 AND ep.Validade IS NOT NULL AND p.sysActive = 1 AND (DATEDIFF(validade, CURDATE()) >= 0 AND DATEDIFF(validade, CURDATE()) <= ( IFNULL(p.DiasAvisoValidade, (SELECT IFNULL(DiasVencimentoProduto, 5) DiasVencimentoProduto FROM sys_config LIMIT 1))))")
        %>
        setTimeout(function(){
            $("#prodVencer").html("<%=numeroProdutosValidade("total") %>");
        }, 1000);
        <%
    end if 

    %>
    <!--#include file="disconnect.asp"-->

<%
end if
%>
$("#timeInat").val(0);