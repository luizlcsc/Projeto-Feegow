<!--#include file="connect.asp"-->
<!--#include file="Classes/Restricao.asp"-->
<%
CarrinhoID = ref("CarrinhoID")
LocalID = ref("LocalID")
UnidadeID = ref("UnidadeID")
Dias = ref("Dias")
ProcedimentoID = ref("ProcedimentoID")
TabelaID = ref("tabelaid")
PropostaID = ref("PropostaID")

Zona = ref("zona")

datas = split(Dias, ",")

EspecialidadeID = "" 
GrupoID = ""

valorMinimoParcela = getConfig("ValorMinimoParcelamento")

dim restricaoObj
set restricaoObj = new Restricao

'sql = "select *, ro.ProfissionalID as ProfissionalOcupacao from agenda_horarios ro LEFT JOIN agendacarrinho ac ON ac.id = ro.CarrinhoID LEFT JOIN profissionais p ON p.id = ro.ProfissionalID where ro.Situacao = 'V' and CarrinhoID = " & CarrinhoID & " AND ro.LocalID = " & LocalID & " AND ro.UnidadeID = " & UnidadeID & " GROUP BY ro.ProfissionalID  "
sql = " SELECT *, ro.ProfissionalID as ProfissionalOcupacao "&_ 
      " FROM agenda_horarios ro "&_
      " LEFT JOIN agendacarrinho ac ON ac.id = ro.CarrinhoID "&_
      " LEFT JOIN profissionais p ON p.id = ro.ProfissionalID "&_ 
      " WHERE ro.Situacao = 'V' "&_
      " AND CarrinhoID = " & CarrinhoID  &_ 
      " AND ro.UnidadeID = " & UnidadeID &_ 
      " GROUP BY ro.ProfissionalID  "

set ocupacoes = db.execute(sql)
k = 0
while not ocupacoes.eof 
    k = k + 1
    cor = "#FFFFFF"
    if (k mod 2) = 0 then
        cor = "#DDDDDD"
    end if

    ObsAgenda = ocupacoes("ObsAgenda")
    EspecializacaoID = ocupacoes("EspecializacaoID")
    ProfissionalID = ocupacoes("ProfissionalOcupacao")

    valorProcedimento = calcValorProcedimento(ProcedimentoID, TabelaID, UnidadeID, ocupacoes("ProfissionalOcupacao"), EspecialidadeID, GrupoID, "")

    sqlDesconto = "SELECT ParcelasDe, ParcelasAte, Acrescimo FROM sys_formasrecto WHERE tipoDesconto = 'P' AND (procedimentos LIKE '%|ALL|%' OR procedimentos LIKE '%|" & ProcedimentoID & "|%') " &_
                                        " AND MetodoID IN (8,9,10) limit 1"

    set descontos = db.execute(sqlDesconto)
                    
    parcelaTres = ccur(valorProcedimento) / 3
    parcelaSeis = ccur(valorProcedimento) / 6

    if not descontos.eof then
        if descontos("ParcelasDe") <= 3 then
            parcelaTres = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (3 * 100 )
        end if

        if descontos("ParcelasAte") >= 6 then
            parcelaSeis = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (6 * 100)
        end if
        'response.write("<!--" & parcelaTres & "|" & valorProcedimento & "|" & descontos("Acrescimo") & "| -->")
    end if

        'response.write("<table class='table table-condensed' style='background-color:"&cor&";'>")
        response.write("<tr >")
        response.write("<td style='vertical-align: top;'>")
            'INFORMAÇÕES SOBRE PAGAMENTO
            response.write("<div class='row'>")
                response.write("<div class='col-md-12 qf' id='qfvalor'>")
                    response.write("<label for='Valor'>A vista</label><br>")
                    response.write("<div class='input-group'>")
                        response.write("<span class='input-group-addon'>R$</span>")
                        response.write("<input type='text' name='Valor' disabled class='form-control input-mask-brl' value='" & fn(valorProcedimento) & "' >")
                    response.write("</div>")
                response.write("</div>")
        
                response.write("<div class='col-md-12 qf' id='qfvalor3x'>")
                    response.write("<label for='Valor3x'>Valor 3x</label><br>")
                    response.write("<div class='input-group'>")
                        response.write("<span class='input-group-addon'>R$</span>")
                        response.write("<input type='text' name='Valor3x' disabled class='form-control input-mask-brl' value='" & fn(parcelaTres) & "' >")
                    response.write("</div>")
                response.write("</div>")

            if ccur(valorProcedimento) >= ccur(valorMinimoParcela) then 
                response.write("<div class='col-md-12 qf' id='qfvalor6x'>")
                response.write("<label for='Valor6x'>Valor 6x</label><br>")
                response.write("<div class='input-group'>")
                response.write("<span class='input-group-addon'>R$</span>")

                response.write("<input type='text' name='Valor6x' disabled class='form-control input-mask-brl' value='" & fn(parcelaSeis) & "' >")
                response.write("</div>")
                response.write("</div>")
            end if
            response.write("</div>")
            'DADOS DO PROFISSIONAL
            response.write("<div class='row' style='margin:10px 0'>")
                
                NomeProfissional =  ocupacoes("NomeProfissional")
                if  ocupacoes("NomeSocial")&"" <> "" then
                    NomeProfissional =  ocupacoes("NomeSocial")
                end if
                response.write("<div class='col-md-12 qf' style='padding:0'>")
                    response.write("<strong>Profissional:</strong><br>"&NomeProfissional)
                response.write("</div'>")
                
                response.write("<div class='input-group'>")
                    if ObsAgenda&""<>"" then 
                        response.write("<button onclick='obs(" & ProfissionalID & ");' type='button' class='btn btn-xs btn-dark'><i class='fa fa-comment'></i> OBSERVAÇÃO</button>")
                    end if
                    if ccur(restricaoObj.possuiRestricao(ProcedimentoID)) > 0 then
                        response.write("<button class=""btn btn-warning btn-xs"" type=""button"" id=""restricaoModal""> <i class=""fa fa-caret-square-o-left""></i> </button>")
                    end if


                response.write("</div>")
                

                if EspecializacaoID&""<>"" then 
                    sqlEspecializacao = "select Subespecialidade, ExecutaForaClinica, Observacoes from subespecialidades s INNER JOIN profissionaissubespecialidades ps ON ps.SubespecialidadeID = s.id where ps.ProfissionalID = " & ProfissionalID& " AND s.id = " & EspecializacaoID
                    
                    set espV = db.execute(sqlEspecializacao)
                    if not espV.eof then
                        response.write("<div class='col-md-4 qf'>")
                            response.write("<br /><button type='button' title='"&espV("Observacoes")&"' class='btn btn-xs btn-danger mt20'>"&espV("Subespecialidade")&"</button>")
                            if espV("ExecutaForaClinica") = "S" then 
                                response.write("<br /><small>Realizado fora da clínica</small>")
                            end if
                        response.write("</div'>")
                    end if
                end if

                if ccur(restricaoObj.possuiPreparo(ProcedimentoID)) > 0 then
                %>
                <div class='col-md-4 qf'>
                    <button class='btn btn-success btn-xs' type='button' onclick="abrirModalPreparo2('<%=ProcedimentoID%>',document.getElementById('bPacienteID').value,'<%=ProfissionalID%>')"><i class='fa fa-lock'></i></button>
                </div>
                <%
                end if

                

            response.write("</div>")




        response.write("</td>")
        
        
        for i=0 to ubound(datas)
			
            response.write("<td style='width: 13.5%;'>")

            set sqlUltimoHorarioAgendado = db.execute("select DISTINCT CarrinhoID, Hora, Encaixe, GradeID from agenda_horarios ro  where data = "&mydatenull(datas(i))&" and ro.ProfissionalID = "& ProfissionalID &"  AND CarrinhoID IS NULL" &_ 
                " ORDER BY ro.Hora desc LIMIT 1 ") 
            
            verificaLimiteAgendamento = false
            if isnumeric(getConfig("TotalDeAgendasLiberadas")) then
                if getConfig("TotalDeAgendasLiberadas") > 0 then
                    verificaLimiteAgendamento = true 
                end if
            end if
            
            sqlGradeEncaixe = "SELECT GradeEncaixe " &_
                    "FROM assfixalocalxprofissional ap " &_
                    "INNER JOIN agenda_horarios ro ON ap.id = ro.GradeID " &_
                    "WHERE ro.ProfissionalID = "& ProfissionalID &"  AND CarrinhoID = " & CarrinhoID & " AND UnidadeID = " & UnidadeID & " " &_  
                    "AND data = " & mydatenull(datas(i)) & " AND ap.GradeEncaixe = 'S'"
            set reGradeEncaixe = db.execute(sqlGradeEncaixe)
            if not reGradeEncaixe.eof then
                GradeEncaixe = reGradeEncaixe("GradeEncaixe")
            else
                GradeEncaixe = ""
                temGrade = 0
            end if

            sqlHorarios = "select DISTINCT Hora, Encaixe, GradeID from agenda_horarios ro  where ro.Situacao = 'V' and ro.ProfissionalID = "& ProfissionalID &"  AND CarrinhoID = " & CarrinhoID &_ 
                " AND UnidadeID = " & UnidadeID 
            if mydatenull(now()) = mydatenull(datas(i)) then 
                sqlHorarios = sqlHorarios & " AND data = " & mydatenull(datas(i)) 
            else 
                sqlHorarios = sqlHorarios & " AND data = " & mydatenull(datas(i)) 
            end if 

            sqlHorarios = sqlHorarios & "ORDER BY ro.Data asc, ro.Hora asc "
            
            'response.write(sqlHorarios)
            if GradeEncaixe="S" then
                gradeVirtual = true
            else
                gradeVirtual = false
            end if

            if gradeVirtual = true then
                horarioAgendadoSQL =    "SELECT LEFT(agehor.Hora,5) AS hora FROM agenda_horarios agehor "&chr(13)&_ 
                                        "WHERE agehor.ProfissionalID="& ProfissionalID &chr(13)&_ 
                                        "AND agehor.UnidadeID = "& UnidadeID &chr(13)&_ 
                                        "AND agehor.Situacao='A' "&chr(13)&_ 
                                        "AND DATA = "&mydatenull(datas(i))&chr(13)&_ 
                                        "ORDER BY agehor.Hora DESC "

                btnHorarioAgendado      = ""
                btnHorarioAgendadoHTML  = ""


                set horarioAgendado = db.execute(horarioAgendadoSQL)
                if not horarioAgendado.eof then
                    while not horarioAgendado.eof
                        btnHorarioAgendadoHTML = "<div class=""col-xs-4 pn"" style=""min-width: 43px; cursor: no-drop;""> <button class='btn btn-xs btn-block btn-default text-center' disabled>"&horarioAgendado("hora")&"</button> </div>"

                        if btnHorarioAgendado = "" then
                            btnHorarioAgendado = btnHorarioAgendadoHTML
                        else
                            btnHorarioAgendado = btnHorarioAgendadoHTML&btnHorarioAgendado
                        end if
                    horarioAgendado.movenext
                    wend
                end if
                horarioAgendado.close
                set horarioAgendado = nothing


                response.write("<div style='width:100%; height:170px; overflow:scroll; overflow-x:hidden' class='horariosLista btn-group'>"&chr(13)&_
                            btnHorarioAgendado&chr(13)&_ 
                            "</div>")


            end if

            if gradeVirtual = false then
                set horarios = db.execute(sqlHorarios)
                temHorario = 0
                if not horarios.eof then

                    sqlHorariosTemHorario = " SELECT COUNT(DISTINCT Hora) total "&_ 
                                            " FROM agenda_horarios ro "&_ 
                                            " WHERE ro.Situacao = 'V' "&_ 
                                            " AND ro.ProfissionalID = "& ProfissionalID &_ 
                                            " AND CarrinhoID = " & CarrinhoID &_ 
                                            " AND UnidadeID = " & UnidadeID
                    if mydatenull(now()) = mydatenull(datas(i)) then 
                        sqlHorariosTemHorario = sqlHorariosTemHorario & " AND data = " & mydatenull(datas(i)) 
                    else 
                        sqlHorariosTemHorario = sqlHorariosTemHorario & " AND data = " & mydatenull(datas(i)) 
                    end if 
                    
                    response.write("<div style='width:100%; height:170px; overflow:scroll; overflow-x:hidden' class='horariosLista'>")

                    %>
                

                    <%
                    set temHorarios = db.execute(sqlHorariosTemHorario)
                    temHorario = 0
                    temGrade = 0

                    mdCol = 4
                    
                    if not temHorarios.eof then 

                        if ccur(temHorarios("total")) = 2 then
                            mdCol = 6
                        elseif ccur(temHorarios("total")) = 2 then
                            mdCol = 12
                        end if

                        if ccur(temHorarios("total")) > 0 then 
                            temHorario = 1
                            temGrade = 1
                        end if
                    end if

                    GradeID = 0
                    TotalHorariosFim = 0

                    ' REGRA DE MARCAR EM ORDEM
                    MarcarOrdem             = 0
                    temLimite               = false
                    horarioInicio           = ""
                    horarioFim              = ""
                    TipoLimiteHorario       = ""
                    verificaLimiteAgendamento = false
                    if isnumeric(getConfig("TotalDeAgendasLiberadas")) then
                        TotalDeAgendasLiberadas = getConfig("TotalDeAgendasLiberadas") 
                    else
                        TotalDeAgendasLiberadas = 0
                    end if

                    sqlPossuiMarcarOrdem = "SELECT MarcarOrdem, IFNULL(MarcarEmOrdemHoraA,'') MarcarEmOrdemHoraA, COALESCE(TipoLimiteHorario, 'I') TipoLimiteHorario " &_
                        "FROM assfixalocalxprofissional ap " &_
                        "INNER JOIN agenda_horarios ro ON ap.id = ro.GradeID " &_
                        "WHERE ro.Situacao = 'V' and ro.ProfissionalID = "& ProfissionalID &"  AND CarrinhoID = " & CarrinhoID & " AND UnidadeID = " & UnidadeID & " " &_  
                        "AND data = " & mydatenull(datas(i)) & " AND ap.MarcarOrdem = 'S'" &_
                        "ORDER BY ro.Hora ASC " &_
                        "LIMIT 1"

                    set verificaMarcarOrdem = db.execute(sqlPossuiMarcarOrdem)
                    
                    if not verificaMarcarOrdem.eof then
                        temLimite = true

                        horaMarcarEmOrdem = verificaMarcarOrdem("MarcarEmOrdemHoraA")
                        TipoLimiteHorario = verificaMarcarOrdem("TipoLimiteHorario")

                        if (TipoLimiteHorario = "I") then
                            horaDirection = "ASC"
                        else
                            horaDirection = "DESC"
                        end if

                        if (horaMarcarEmOrdem <> "") then
                            if (TipoLimiteHorario = "I") then
                                horaWhere = "WHERE Hora >= '" & horaMarcarEmOrdem & "'"
                            else 
                                horaWhere = "WHERE Hora <= '" & horaMarcarEmOrdem & "'"
                            end if
                        else
                            horaWhere = ""
                        end if

                        horaInicioSql = "SELECT Hora FROM (" & sqlHorarios & ") as t " & horaWhere & " ORDER BY Hora " & horaDirection & " LIMIT " & TotalDeAgendasLiberadas
                        set horaInicioQuery = db.execute(horaInicioSql)
                        if not horaInicioQuery.eof then 
                            while not horaInicioQuery.eof 
                                if TipoLimiteHorario = "I" then
                                    if horarioInicio = "" then
                                        horarioInicio = formatdatetime(horaInicioQuery("Hora"), 4)
                                    end if
                                    horarioFim = formatdatetime(horaInicioQuery("Hora"), 4)
                                else
                                    if horarioFim = "" then
                                        horarioFim = formatdatetime(horaInicioQuery("Hora"), 4)
                                    end if
                                    horarioInicio = formatdatetime(horaInicioQuery("Hora"), 4)
                                end if
                                horaInicioQuery.movenext
                            wend
                        end if

                    end if

                    'response.write("<pre>"&horarioInicio&"</pre>")
                    'response.write("<pre>"&horarioFim&"</pre>")

                    if not horarios.eof then 
    %>
                        <div class="btn-group">
    <%
                        
                        while not horarios.eof 

                            temHorario = 1

                            'inicio regra tem limite Marcar em Ordem
                            if temLimite then

                                if (formatdatetime(horarios("Hora"), 4) >= horarioInicio and formatdatetime(horarios("Hora"), 4) <= horarioFim and MarcarOrdem < TotalDeAgendasLiberadas) then
                                    MarcarOrdem = MarcarOrdem + 1


                            %>
                                    <div class='col-xs-4 pn' style="min-width: 43px">
                                        <% if not horarios("Encaixe") then %>
                                        
                                            <button style="width:100%" onclick="abreAgenda('<%=formatdatetime(horarios("Hora"), 4)%>', null, '<%=datas(i)%>', '<%=ProfissionalID%>', '<%=ocupacoes("EspecialidadeID")%>', '', 
                                                    '<%=ProcedimentoID%>', '<%=LocalID%>', 'Valor', '<%=CarrinhoID%>', '<%=fn(valorProcedimento)%>', '0', '<%=PropostaID%>')"
                                                type='button' class='btn btn-xs btn-block btn-primary text-center'>
                                                <%=formatdatetime(horarios("Hora"), 4)%>
                                            </button> 

                                        <% end if %>
                                    </div>
                                <% else %>
                                    <div class='col-xs-4 pn' style="min-width: 43px">
                                        <button onclick="verificaPermissao('<%=formatdatetime(horarios("Hora"), 4)%>', null, '<%=datas(i)%>', '<%=ProfissionalID%>', '<%=ocupacoes("EspecialidadeID")%>', '', 
                                                    '<%=ProcedimentoID%>', '<%=LocalID%>', 'Valor', '<%=CarrinhoID%>', '<%=fn(valorProcedimento)%>', '0', <%=session("User")%>)" type='button' class='btn btn-xs btn-block btn-warning warning text-center'>
                                            <%=formatdatetime(horarios("Hora"), 4)%>
                                        </button> 
                                    </div>
                                <% end if 
                            'fim regra temLimite Marcar em Ordem
                            else  
                                if not horarios("Encaixe") then %>

                                    <button style="min-width: 43px" onclick="abreAgenda('<%=formatdatetime(horarios("Hora"), 4)%>', null, '<%=datas(i)%>', '<%=ProfissionalID%>', '<%=ocupacoes("EspecialidadeID")%>', '',
                                            '<%=ProcedimentoID%>', '<%=LocalID%>', 'Valor', '<%=CarrinhoID%>', '<%=fn(valorProcedimento)%>', '0', '<%=PropostaID%>')"
                                            type='button' class='btn btn-xs col-md-<%=mdCol%> btn-primary text-center'>
                                            <%=formatdatetime(horarios("Hora"), 4)%>
                                    </button>

                                <% 
                                end if
                            end if
                            horarios.movenext
                        wend
                        %>
                        </div>
                        <%
                    end if
                    response.write("</div>")
                    %>
                    

                    <%
                end if
        end if
                %>
                <%
                sqlHorariosVazios = "select DISTINCT Hora, Encaixe, GradeID from agenda_horarios ro  where ro.Situacao = 'V' and ro.ProfissionalID = "& ProfissionalID &"  AND CarrinhoID = " & CarrinhoID &_ 
                    " AND UnidadeID = " & UnidadeID 
                if mydatenull(now()) = mydatenull(datas(i)) then 
                    sqlHorariosVazios = sqlHorariosVazios & " AND data = " & mydatenull(datas(i)) & " and Hora >= TIME(NOW()) "
                else 
                    sqlHorariosVazios = sqlHorariosVazios & " AND data = " & mydatenull(datas(i)) 
                end if 
                if verificaLimiteAgendamento and not sqlUltimoHorarioAgendado.eof then
                    sqlHorariosVazios = sqlHorariosVazios & " AND Hora >= SUBSTRING('" & sqlUltimoHorarioAgendado("Hora") & "', 11, 16) "
                    sqlHorariosVazios = sqlHorariosVazios & " ORDER BY ro.Data asc, ro.Hora asc "
                    sqlHorariosVazios = sqlHorariosVazios & " LIMIT " & getConfig("TotalDeAgendasLiberadas")
                else
                    sqlHorariosVazios = sqlHorariosVazios & "ORDER BY ro.Data asc, ro.Hora asc "
                end if
                set horariosVazios = db.execute(sqlHorariosVazios)

                if (temHorario = 1 and temGrade = 1) or GradeEncaixe = "S"  then
                %>
				<div class="btn-group" style="width:100%">
                <%
                if GradeEncaixe = "S" then
                %>
                    <a onclick="abreAgenda('', null, '<%=datas(i)%>', '<%=ProfissionalID%>', '<%=ocupacoes("EspecialidadeID")%>', '', 
                    '<%=ProcedimentoID%>', '<%=LocalID%>', 'Valor', '<%=CarrinhoID%>', '<%=fn(valorProcedimento)%>', '-1')"
                        type='button' class='col-md-12 mt15 btn btn-xs  btn-alert text-center' >
                        <i class="fal fa-calendar"></i> Grade Virtual
                    </a>
                <%
                else
                    response.write("<a href='#' class=' col-md-9 mt15 btn btn-xs btn-system' onClick='AbreAgendaDiaria("""&datas(i)&""", """&ProfissionalID&""", """&UnidadeID&""")'><i class='fa fa-calendar'></i> Grade Padrão</a>")
                %>
                    <a onclick="abreAgenda('', null, '<%=datas(i)%>', '<%=ProfissionalID%>', '<%=ocupacoes("EspecialidadeID")%>', '', 
                    '<%=ProcedimentoID%>', '<%=LocalID%>', 'Valor', '<%=CarrinhoID%>', '<%=fn(valorProcedimento)%>', '-1')"
                        type='button' class='col-md-3 mt15 btn btn-xs  btn-alert text-center' >
                        <i class="fal fa-calendar-plus"></i>
                    </a>
                <%
                %>
                    
                <%
                end if
                %>
                </div>
                <% 
                end if
            response.write("</td>")
        next
        response.write("</tr>")
    'response.write("</table>")
    ocupacoes.movenext
wend
%>

<script>
    $("#restricaoModal").click(function() {
        const restricaoModal_pacienteID = document.getElementById('bPacienteID').value;
        if (restricaoModal_pacienteID){
            openComponentsModal('procedimentosListagemPaciente.asp?ProfissionalID=<%=ProfissionalID%>&ProcedimentoID=<%=ProcedimentoID%>&PacienteID='+document.getElementById('bPacienteID').value+'', true, 'Restrições', true, '');
        }else{
            showMessageDialog("Selecione um paciente", "danger")
        }
    });
</script>
