<!--#include file="connect.asp"-->
<%
PacienteID = ref("PacienteID")

%>
 <form method="post" id="formAgdFut">
    <table class="table footable fw-labels" data-page-size="20">
        <thead>
            <tr>
                <th style="width: 200px"></th>
                <th>Status</th>
                <th>Data/Hora</th>
                <th>Profissional</th>
                <th>Especialidade</th>
                <th>Procedimento</th>
                <th>Valor/Convênio</th>
            </tr>
        </thead>
        <tbody>

        <%
	    c = 0
        temNovoPagamento = 0
	    agends = ""
        set pCons = db.execute("select a.id, a.rdValorPlano, a.ValorPlano, a.Data, a.Hora, a.StaID, a.Procedimentos, s.StaConsulta, p.NomeProcedimento, " &_ 
        " c.NomeConvenio, prof.NomeProfissional, esp.Especialidade NomeEspecialidade FROM agendamentos a LEFT JOIN profissionais prof on prof.id=a.ProfissionalID " &_ 
        " LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID or (a.EspecialidadeID is null and prof.EspecialidadeID=esp.id) " &_ 
        " LEFT JOIN procedimentos p on a.TipoCompromissoID=p.id LEFT JOIN staconsulta s ON s.id=a.StaID LEFT JOIN convenios c on c.id=a.ValorPlano " &_ 
        " WHERE DATE_FORMAT(a.Data, '%Y-%m-%d') >= DATE_FORMAT(now(),'%Y-%m-%d') AND a.PacienteID="&PacienteID&" ORDER BY a.Data ASC, a.Hora ASC")
        while not pCons.EOF
            jaTemValorPago = 0
            
            'Buscar a movement dos agendamentos 
            sqlMovement = "select mov.id as movementID, SUM(mov.ValorPago) ValorPago, SUM(mov.Value) Value from sys_financialmovement mov INNER JOIN sys_financialinvoices inv ON inv.id = mov.InvoiceID " &_ 
                    " LEFT JOIN itensinvoice ii ON ii.InvoiceID = inv.id WHERE ii.AgendamentoID = " & pCons("id") & " GROUP BY(ii.AgendamentoID)"
            set Movs = db.execute(sqlMovement)
            
		    c = c+1
            valorPagar = 0
		    if pCons("rdValorPlano")="V" then
                'if aut("areceberareceberpaciente") then
    			    Pagto = "R$ " & formatnumber(0&pCons("ValorPlano"), 2)
                    valorPagar = pCons("ValorPlano")
                'else
                '    Pagto = ""
                'end if
		    else
			    Pagto = pCons("NomeConvenio")
		    end if
		    agends = agends & pCons("id") & ","
		
		    consHora = pCons("Hora")
		    if not isnull(consHora) then
			    consHora = formatdatetime(consHora, 4)
		    end if


            select case pCons("StaID")
                case 1
                    classe = "alert"
                case 2, 3
                    classe = "success"
                case 4
                    classe = "warning"
                case 5, 8
                    classe = "primary"
                case 6, 11
                    classe = "danger"
                case else
                    classe = "dark"
            end select

            NomeProcedimento = pCons("NomeProcedimento")
            VariosProcedimentos = pCons("Procedimentos")&""
            if VariosProcedimentos<>"" then
                NomeProcedimento = VariosProcedimentos
            end if

            %>
            <tr class="row-<%=classe %>" onclick="">
                <td>
                <% if not Movs.eof then %>
                    <%
                    if Movs("ValorPago")&"" = "" then %>
                    <%=btnParcela(Movs("movementID"), 0, valorPagar, "", "C", "")%>
                    <%
                    else 
                    jaTemValorPago = 1
                    %>
                    <%=btnParcela(Movs("movementID"), Movs("ValorPago"), valorPagar, "", "C", "")%>
                    <% 
                    end if 
                    %>
                    
                <% end if %>
                </td>
                <td class="pn">
                    <span class="label label-<%=classe %> mn">
                        <%=left(pCons("StaConsulta"), 18) %>
                    </span>
                </td>
                <td><%="<img src=""assets/img/"&pCons("StaID")&".png"">"%> &nbsp; <%=pCons("Data")&" - "&consHora %></td>
                <td><%=left(pCons("NomeProfissional"), 30) %></td>
                <td><%=left(pCons("NomeEspecialidade"), 30) %></td>
                <td><%=left(NomeProcedimento, 30) %></td>
                <td><%=Pagto%></td>
                <td><button class="btn btn-info btn-xs" data-agendamentoid="<%= pCons("id") %>" id="hist<%=pCons("id")%>">Detalhes</button>
                    <% if jaTemValorPago = 0 then %>
                    <a class="btn btn-warning btn-xs" onclick="remarcar('<%=pCons("id")%>')" href="#">Remarcar </a>
                    <% end if %>
                    <a class="btn btn-primary btn-xs" href="./?P=Agenda-1&Pers=1&AgendamentoID=<%=pCons("id")%>" target="_blank" title="Ir para agendamento"><i class="fa fa-external-link"></i></a>
                    
                    <div id="divhist<%=pCons("id")%>" style="position:absolute; display:none;z-index: 99999; background-color:#fff; margin-left:-740px; border:1px solid #2384c6; width:800px; height:200px; overflow-y:scroll">Carregando...</div>
                    
                </td>
            </tr>
            <%
        pCons.MoveNext
        wend
        pCons.close
        set pCons=nothing
	
	    if c=0 then
		    txt = "Nenhum agendamento."
	    elseif c=1 then
		    txt = "1 agendamento."
	    else
		    txt = c& " agendamentos."
	    end if
    %>
    </tbody>
    </table>
        <input id="AccountID" type="hidden" name="AccountID" value="<%= "3_"& PacienteID %>" />
    </form>
    <div class="row">
	    <div class="col-xs-8">
    	    <%=txt%>
        </div>
        <div class="col-xs-4">
            <a href="#" class="btn btn-primary btn-sm pull-right" onClick="pagarTodos()">Pagar</a>
        </div>
    </div>
    <script>$(function(){ if('<%=c%>' == 0) { $(".badgefuturo").hide() } $(".badgefuturo").html('<%=c%>') })</script>