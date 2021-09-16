<!--#include file="connect.asp"-->
<%
HLivres = 0
HAgendados = 0
HBloqueados = 0

Data=req("Data")

ProfissionalID=req("ProfissionalID")
DiaSemana=weekday(Data)
mesCorrente=month(Data)

DiaSemana = weekday(Data)
Hora = cdate("00:00")
set Horarios = db.execute("select ass.*, l.NomeLocal, '0' TipoGrade, l.UnidadeID, '0' GradePadrao, '' Procedimentos from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
if Horarios.EOF then
    sqlAssfixa = "select ass.*, l.NomeLocal, l.UnidadeID, '1' GradePadrao from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) order by ass.HoraDe"
    set Horarios = db.execute(sqlAssfixa)
end if
while not Horarios.EOF
    MostraGrade=True

    if Horarios("GradePadrao")=1 then
        FrequenciaSemanas = Horarios("FrequenciaSemanas")
        InicioVigencia = Horarios("InicioVigencia")

        if FrequenciaSemanas>1 then
            NumeroDeSemanaPassado = datediff("w",InicioVigencia,Data)
            RestoDivisaoNumeroSemana = NumeroDeSemanaPassado mod FrequenciaSemanas

            if RestoDivisaoNumeroSemana>0 then
                MostraGrade=False
            end if
        end if
    end if
    if MostraGrade then
    LocalID = Horarios("LocalID")
    Procedimentos = Horarios("Procedimentos")&""

        GradeID=Horarios("id")

        if Horarios("TipoGrade")=0 then
            UnidadeID=Horarios("UnidadeID")

            if Horarios("GradePadrao")="0" then
                GradeID="0"
            end if

            Intervalo = Horarios("Intervalo")
            if isnull(Intervalo) then
                Intervalo = 30
            end if
            HoraDe = cdate(Horarios("HoraDe"))
            HoraA = cdate(Horarios("HoraA"))
            Hora = HoraDe

            Bloqueia = ""
            if Procedimentos<>"" and session("RemSol")<>"" then
                set procRem = db.execute("select TipoCompromissoID from agendamentos where id="& session("RemSol"))
                if not procRem.eof then
                    if instr(Procedimentos, "|"& procRem("TipoCompromissoID") &"|")=0 then
                        Bloqueia = "S"
                    end if
                end if
            end if


            while Hora<=HoraA
                HoraID = formatdatetime(Hora, 4)
                HoraID = replace(HoraID, ":", "")

                HLivres = HLivres+1

                HorariosLivres = HorariosLivres & "["& HoraID &", "& LocalID &", "& ProfissionalID &", "& GradeID &"]"

                Hora = dateadd("n", Intervalo, Hora)
            wend
        else
            txtHorarios = Horarios("Horarios")&""
            if instr(txtHorarios, ",") then
                splHorarios = split(txtHorarios, ",")
                for ih=0 to ubound(splHorarios)
                    HoraPers = trim(splHorarios(ih))
                    if isdate(HoraPers) then
                        HLivres = HLivres+1
                        HoraID = horaToID(HoraPers)
                        
                        HorariosLivres = HorariosLivres & "["& HoraID &", "& LocalID &", "& ProfissionalID &", "& GradeID &"]"

                    end if
                next
            end if
        end if
    end if
Horarios.movenext
wend
Horarios.close
set Horarios=nothing

            set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.Encaixe, a.Tempo, a.FormaPagto, a.Notas, p.NomePaciente, p.IdImportado,a.PacienteID, p.Tel1, p.Cel1, proc.NomeProcedimento,proc.Cor, s.StaConsulta, a.rdValorPlano, a.ValorPlano,a.Procedimentos, a.Primeira, c.NomeConvenio, l.NomeLocal, (select Resposta from agendamentosrespostas where AgendamentoID=a.id limit 1) Resposta from agendamentos a "&_
            "left join pacientes p on p.id=a.PacienteID "&_ 
            "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_ 
            "left join staconsulta s on s.id=a.StaID "&_ 
            "left join convenios c on c.id=a.ValorPlano "&_ 
			"left join locais l on l.id=a.LocalID "&_ 
            "where a.Data="&mydatenull(Data)&" and a.ProfissionalID="&ProfissionalID&" order by Hora")
				
            while not comps.EOF
                FormaPagto = comps("FormaPagto")
                Tempo = 0
                ValorProcedimentosAnexos = 0

				NomeProcedimento = comps("NomeProcedimento")
				VariosProcedimentos = comps("Procedimentos")&""
				if VariosProcedimentos<>"" then
					NomeProcedimento = VariosProcedimentos
				end if


                'soma o tempo dos procedimentos anexos
                if VariosProcedimentos<>"" and instr(VariosProcedimentos, ",") then
                    set ProcedimentosAnexosTempoSQL = db.execute("SELECT sum(Tempo)Tempo, sum(IF(rdValorPlano='V',ValorPlano,0))Valor FROM agendamentosprocedimentos WHERE Tempo IS NOT NULL AND AgendamentoID="&comps("id"))
                    if not ProcedimentosAnexosTempoSQL.eof then
                        if not isnull(ProcedimentosAnexosTempoSQL("Tempo")) then
                            Tempo = Tempo + ccur(ProcedimentosAnexosTempoSQL("Tempo"))
                        end if
                        if not isnull(ProcedimentosAnexosTempoSQL("Valor")) then
                            ValorProcedimentosAnexos = ValorProcedimentosAnexos + ccur(ProcedimentosAnexosTempoSQL("Valor"))
                        end if
                    end if
                end if


				if comps("rdValorPlano")="V" then
					if (lcase(session("table"))="profissionais" and cstr(session("idInTable"))=ProfissionalID) or (session("admin")=1) or aut("|valordoprocedimentoV|")=1 then
						Valor = comps("ValorPlano")
						if not isnull(Valor) then
							Valor = Valor + ValorProcedimentosAnexos
							Valor = "R$ "&formatnumber(Valor, 2)
						else
							Valor = "R$ 0,00"
						end if
					else
						Valor = "Particular"
					end if
					if aut("areceberpacienteV")=0 then
						Valor = ""
					end if
				else
					Valor = comps("NomeConvenio")
				end if
                HoraComp = HoraToID(comps("Hora"))
				Horario = comps("Hora")
				if isnull(Horario) then
					Horario = "00:00"
				end if
				if not isnull(comps("Hora")) then
					compsHora = formatdatetime( comps("Hora"), 4 )
				else
					compsHora = ""
				end if

				'->hora final
				if not isnull(comps("Tempo")) and comps("Tempo")<>"" and isnumeric(comps("Tempo")) then
					Tempo = Tempo + ccur(comps("Tempo"))
				end if
				if isdate(Horario) and Horario<>"" then
					HoraFinal = dateadd("n", Tempo, Horario)
					HoraFinal = formatdatetime( HoraFinal, 4 )
					HoraFinal = HoraToID(HoraFinal)
					if HoraFinal<=HoraComp then
						HoraFinal = ""
					end if
				else
					HoraFinal = ""
				end if
				'<-hora final


                linkAg = " onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')"" "
                Conteudo = "<tr id="""&HoraComp&""" data-toggle=""tooltip"" data-html=""true"" data-placement=""bottom"" title="""&replace(replace(replace(comps("NomePaciente")&" ", "'", "\'"), chr(10), ""), chr(13), "")&"<br>Prontuário: "&Prontuario&"<br>"
				if instr(omitir, "tel1")=0 then
					Conteudo = Conteudo & "Tel.: "&replace(comps("Tel1")&" ", "'", "\'")&"<br>"
				end if
				if instr(omitir, "cel1")=0 then
					Conteudo = Conteudo & "Cel.: "&replace(comps("Cel1")&" ", "'", "\'")&"<br>"
				end if
                'if session("Banco")="clinic5594" then
                    Conteudo = Conteudo & "Notas: "&replace(replace(replace(replace(comps("Notas")&"", chr(13), ""), chr(10), ""), "'", ""), """", "")&"<br>"
                'end if
				Conteudo = Conteudo & """ data-id="""&comps("id")&""">"&_
				"<td width=""1%"" "& linkAg &">"
				if not isnull(comps("Resposta")) then
					Conteudo = Conteudo & "<i class=""far fa-envelope pink""></i> "
				end if
				if comps("Primeira")=1 then
                    Conteudo = Conteudo & "<i class=""far fa-flag blue"" title=""Primeira vez""></i>"
                end if
				if comps("LocalID")<>LocalID then
					Conteudo = Conteudo & "<i class=""far fa-exclamation-triangle grey"" title=""Agendado para &raquo; "&replace(comps("NomeLocal")&" ", "'", "\'")&"""></i>"
				end if
				Conteudo = Conteudo & "</td><td width=""1%"" nowrap><button type=""button"" data-hora="""&replace( compsHora, ":", "" )&""" class=""btn btn-xs btn-default btn-comp"" "& linkAg &">"&compsHora&"</button>"
                if session("Banco")="clinic4134" then
                    Conteudo = Conteudo & "<button type=""button"" onclick=""abreAgenda(\'"&HoraComp&"\', 0, \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')"" class=""btn btn-xs btn-system ml5""><i class=""far fa-plus""></i></button>"
                end if
                Conteudo = Conteudo & "</td>"&_
				"<td nowrap "& linkAg &"><img src=""assets/img/"&comps("StaID")&".png""> "
				if comps("Encaixe")=1 then
					Conteudo = Conteudo & "&nbsp;<span class=""label bg-alert label-sm arrowed-in mr10 arrowed-in-right"">Encaixe</span>"
				end if
				Conteudo = Conteudo & "<span class=""nomePac"">"&replace(replace(replace(comps("NomePaciente")&" ", "'", "\'"), chr(10), ""), chr(13), "")&"</span>"
				CorProcedimento = ""
				if comps("Cor") <> "#fff" and not isnull(comps("Cor")) then
					CorProcedimento = "<div class=""mr5 mt5"" style=""float:left;position:relative;background-color:"&comps("Cor")&";height:5px;width:5px;border-radius:50%""></div>"
				end if

				rotulo = "&nbsp;"&replace(Valor&" ", "'", "\'")
				if (session("Banco")="clinic100000" or session("Banco")="clinic2263" or session("Banco")="clinic5856") and comps("rdValorPlano")="V" then
					set TabelaSQL = db.execute("SELECT t.NomeTabela FROM tabelaparticular t LEFT JOIN pacientes p ON p.Tabela=t.id WHERE p.id = "&comps("PacienteID"))
					if not TabelaSQL.eof then
					    rotulo = TabelaSQL("NomeTabela")
					end if
				end if


				Conteudo = Conteudo & "</td>"&_
				"<td class=""text-center hidden-xs"" "& linkAg &"><span class=""nomePac"" style=""max-width:600px!important"">"&CorProcedimento&replace(NomeProcedimento&" ", "'", "\'")&"</span></td>"&_
				"<td class=""text-center hidden-xs"" "& linkAg &">"&comps("StaConsulta")&"</td>"&_
				"<td class=""text-right nomeConv hidden-xs"" "& linkAg &"><small>"& sinalAgenda(FormaPagto) & rotulo &"</small></td>"&_
				"</tr>"
				HAgendados = HAgendados+1


				if comps("LocalID")<>LocalID then
					LocalDiferenteDaGrade=1
					classeL = ".l"&comps("LocalID")&", .l"
                else
                    LocalDiferenteDaGrade=0
                    classeL = ".l"&comps("LocalID")
				end if
            %>
            var classe = "<%=classeL%>";

            var LocalDiferenteDaGrade = "<%=LocalDiferenteDaGrade%>";
            if(LocalDiferenteDaGrade==="1"){
                if( $(".l<%= comps("LocalID") %>").length>0 ){
                    classe = ".l<%= comps("LocalID") %>";
                }else{
                    classe = "<%=classeL%>";
                }
            }


            var HorarioAdicionado = false;
            var Status = '<%=comps("StaID")%>';

            $( classe ).each(function(){
                if( $(this).attr("data-horaid")=='<%=HoraComp%>' && (Status !== "11" && Status !== "22"))
                {
                    HorarioAdicionado=true;
                    $(this).replaceWith('<%= conteudo %>');
                    return false;
                }
            });
            if(!HorarioAdicionado){
                $( classe + ", .l").each(function(){
                        if ( $(this).attr("data-horaid")>'<%=HoraComp%>' )
                        {
                            $(this).before('<%=conteudo%>');
                            return false;
                        }
                });
            }
                <%
				if HoraFinal<>"" then
					%>
					if(Status !== "11" && Status !== "22"){
                        $( ".vazio" ).each(function(){
                            if( $(this).attr("data-horaid")>'<%=HoraComp%>' && $(this).attr("data-horaid")<'<%=HoraFinal%>' )
                            {
                                $(this).replaceWith('');
                                //return false;
                            }
                        });
                    }
					<%
				end if
            comps.movenext
            wend
            comps.close
            set comps = nothing


            bloqueioSql = "select c.* from compromissos c where (c.ProfissionalID="&ProfissionalID&" or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"&ProfissionalID&"%|'))) AND (c.Unidades LIKE '%|"&UnidadeID&"|%' or c.Unidades='' OR c.Unidades IS NULL) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"

			set bloq = db.execute(bloqueioSql)
			while not bloq.EOF
				HoraDe = HoraToID(bloq("HoraDe"))
				HoraA = HoraToID(bloq("HoraA"))
                Conteudo = "<tr id=""'+$(this).attr('data-hora')+'"" onClick=""abreBloqueio("&bloq("id")&", \'\', \'\');"">"&_ 
				"<td width=""1%""></td><td width=""1%""><button type=""button"" class=""btn btn-xs btn-danger"">'+$(this).attr('data-hora')+'</button></td>"&_ 
				"<td nowrap><img src=""assets/img/bloqueio.png""> <span class=""nomePac"">"&replace(bloq("Titulo")&" ", "'", "\'")&"</span></td>"&_ 
				"<td class=""hidden-xs text-center""></td>"&_ 
				"<td class=""hidden-xs hidden-sm text-center""></td>"&_ 
				"<td class=""hidden-xs text-right nomeConv""></td>"&_ 
				"</tr>"

				HBloqueados = HBloqueados+1
				%>
				$( ".vazio" ).each(function(){
					if( $(this).attr("id")>='<%=HoraDe%>' && $(this).attr("id")<'<%=HoraA%>' ){
						$(this).replaceWith('<%= conteudo %>');
					}
				});
				$( ".btn-comp" ).each(function(){
					if( $(this).attr("data-hora")>='<%=HoraDe%>' && $(this).attr("data-hora")<'<%=HoraA%>' )
					{
						$(this).removeClass("btn-default");
						$(this).addClass("btn-danger");
						$(this).html( $(this).html() + ' <i class="far fa-lock"></i>' );
					}
				});
				<%
			bloq.movenext
			wend
			bloq.close
			set bloq=nothing
				%>


<%= HorariosLivres %>

<!--#include file = "disconnect.asp"-->
