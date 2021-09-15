	<div class="table-responsive">

        <table id="t<%=nomeTabela %>" class="table table-bordered table-hover" width="100%">
	        <thead>
                <tr class="success">
        	        <th>PRONT</th>
        	        <th class="text-center">PACIENTE</th>
                    <th class="text-center">DATA</th>
                    <th class="text-center">HORA</th>
                    <th class="text-center">SERVI&Ccedil;O / PROCEDIMENTO</th>
                    <th>SITUAÇÃO</th>
                    <th>CONV&Ecirc;NIO</th>
                    <th>RECEBIMENTO</th>
                    <th class="text-center hidden-print">FATOR</th>
                    <% if session("Banco")="clinic5351" or session("Banco")="clinic5760" then %>
                    <th>REPASSES</th>
                    <% end if %>
                    <th class="text-center">VALOR</th>
                </tr>
	        </thead>
            <tbody>
                <%
                TotalValorRepasse = 0

                strFat = ""

		        strForma = ""
		        strConv = ""
		        umOUoutro = ""
		        abrePar = ""
		        fechaPar = ""
		        umEoutro = ""
		        if reqf("Forma")<>"" then
			        strForma = " rdValorPlano in('"&replace(reqf("Forma"), ", ", "', '")&"') "
		        end if
		        if reqf("ConvenioID")<>"" then
			        strConv = " ValorPlano in("& reqf("ConvenioID") &") "
		        end if
		        if strForma<>"" and strConv<>"" then
			        umOUoutro = " OR "
			        abrePar = "("
			        fechaPar = ")"
		        end if
		        if strForma<>"" or strConv<>"" then
			        umEoutro = " AND "
		        end if
                if inStr(reqf("Forma"), "V") then'!!!!!!!!!!!!!!!!
                    sqlParticular = "(select ii.id ItemInvoiceID, 'ItemInvoiceID' coluna, ii.id idColuna, 'Faturado' Situacao, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorPlano, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorFinal, NULL Fator, i.AccountID PacienteID, 'V' rdValorPlano, ii.DataExecucao Data, ii.HoraExecucao HoraInicio, ii.HoraFim, proc.NomeProcedimento, proc.TipoProcedimentoID, pac.id Prontuario, pac.NomePaciente, 'Particular' NomeConvenio, 100 segundoProcedimento, 100 terceiroProcedimento, 100 quartoProcedimento, ii.ItemID ProcedimentoID, 0 ConvenioID, 0 ValorPago from itensinvoice ii left join sys_financialinvoices i on i.id=ii.InvoiceID left join procedimentos proc on proc.id=ii.ItemID left join pacientes pac on pac.id=i.AccountID where ii.`DataExecucao`>="&mydatenull(DataDe)&" and `DataExecucao`<="&mydatenull(DataAte)&" AND ProfissionalID="&prof("id")&" AND CompanyUnitID="&splU(i)&" and ii.Associacao IN(0, 5) "& sqlProcedimentosParticular &" ORDER BY ii.DataExecucao) "&_
                    " UNION ALL"
                end if
                if reqf("ConvenioID")<>"" then
                    sqlConvenio = "(select '0', 'GuiaConsultaID' coluna, gc.id idColuna, 'Faturado' Situacao, gc.ValorProcedimento ValorPlano, gc.ValorProcedimento ValorFinal, NULL Fator, gc.PacienteID, 'P' rdValorPlano, gc.DataAtendimento Data, NULL HoraInicio, NULL HoraFim, procgc.NomeProcedimento, procgc.TipoProcedimentoID, gc.PacienteID Prontuario, pacgc.NomePaciente, convgc.NomeConvenio, convgc.segundoProcedimento, convgc.terceiroProcedimento, convgc.quartoProcedimento, gc.ProcedimentoID, gc.ConvenioID, ifnull(ValorPago, 0) ValorPago from tissguiaconsulta gc left join procedimentos procgc on procgc.id=gc.ProcedimentoID left join pacientes pacgc on pacgc.id=gc.PacienteID left join convenios convgc on convgc.id=gc.ConvenioID where gc.`DataAtendimento`>="&mydatenull(DataDe)&" and gc.`DataAtendimento`<="&mydatenull(DataAte)&" AND gc.ConvenioID IN ("&reqf("ConvenioID")&") AND ifnull(gc.ProfissionalEfetivoID, gc.ProfissionalID)="&prof("id")&" AND gc.UnidadeID="&splU(i) & sqlProcedimentosConvenioGC &" ORDER BY gc.DataAtendimento)"&_
                    " UNION ALL "&_
                    "(select '0', 'ItemGuiaID', igs.id, 'Faturado', igs.ValorTotal, igs.ValorTotal, igs.Fator, gs.PacienteID, 'P', igs.Data, igs.HoraInicio, igs.HoraFim, procigs.NomeProcedimento, procigs.TipoProcedimentoID, gs.PacienteID, pacgs.NomePaciente, convgs.NomeConvenio, convgs.segundoProcedimento, convgs.terceiroProcedimento, convgs.quartoProcedimento, igs.ProcedimentoID, gs.ConvenioID, ifnull(igs.ValorPago, 0) ValorPago from tissprocedimentossadt igs left join tissguiasadt gs on gs.id=igs.GuiaID left join procedimentos procigs on procigs.id=igs.ProcedimentoID left join pacientes pacgs on pacgs.id=gs.PacienteID left join convenios convgs on convgs.id=gs.ConvenioID where igs.`Data`>="&mydatenull(DataDe)&" AND gs.ConvenioID IN ("&reqf("ConvenioID")&") and igs.`Data`<="&mydatenull(DataAte)&" AND igs.ProfissionalID="&prof("id")&" AND gs.UnidadeID="&splU(i) & sqlProcedimentosConvenioGS &" ORDER BY igs.Data)"&_
                    " UNION ALL "
                end if

                if instr(ref("Forma"), "V")=0 then
                    sqlBloqPart = " AND ap.rdValorPlano<>'V' "
                end if

		        sql = sqlParticular & sqlConvenio & "(select '0', NULL, NULL, 'Não Faturado', ap.ValorPlano, ap.ValorFinal, ap.Fator, at.PacienteID, ap.rdValorPlano, at.`Data`, at.HoraInicio, at.HoraFim, proc.NomeProcedimento, proc.TipoProcedimentoID, pac.id Prontuario, pac.NomePaciente, conv.NomeConvenio, conv.segundoProcedimento, conv.terceiroProcedimento, conv.quartoProcedimento, ap.ProcedimentoID, ap.ValorPlano, 0 ValorPago from atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID LEFT JOIN procedimentos proc on ap.ProcedimentoID=proc.id LEFT JOIN pacientes pac on pac.id=at.PacienteID LEFT JOIN convenios conv on conv.id=ap.ValorPlano WHERE ProfissionalID="&prof("id")&" and `Data`>="&mydatenull(DataDe)&" and `Data`<="&mydatenull(DataAte)&" AND at.UnidadeID="&splU(i)& sqlProcedimentosAtendimento & umEoutro & abrePar & strForma & umOUoutro & strConv & fechaPar & sqlBloqPart & " order by Data, HoraInicio)"
                'if reqf("Debug")="1" then
                '    response.Write sql 
                'end if

             '   if reqf("AgruparConvenio")="" then
    		        set G = db.execute(sql)
             '   else
             '       response.write( sql )
             '        set G = db.execute("SELECT * FROM (" & sql &") t ORDER BY rdValorPlano desc, t.ConvenioID")
             '   end if
		        Subtotal = 0
		        SubtotalNovo = 0
		        Conta = 0
		        while not G.eof
                    Oculta = 0
			        Prontuario = right("0000000"&G("Prontuario"),7)
			        response.Flush()
			        ProcedimentoID = G("ProcedimentoID")
			        TipoProcedimentoID = G("TipoProcedimentoID")
			        ConvenioID = G("ConvenioID")
			        PlanoID = 0
			        PacienteID = G("PacienteID")
			        Caso = 0
			        NomePaciente = G("NomePaciente")
                    Situacao = G("Situacao")
                    Data = G("Data")
			        Valor = G("ValorFinal")
                    Fator = G("Fator")
                    DetPag = ""
                    db_execute("insert into tempfaturamento (sysUser, Data, ProcedimentoID, ProfissionalID, ConvenioID, Valor, PacienteID, Situacao, UnidadeID) values ("& session("User") &", "& mydatenull(G("Data")) &", "& G("ProcedimentoID") &", "& prof("id") &", "& treatvalzero(G("ConvenioID")) &", "& treatvalzero(G("ValorPlano")) &", "& G("PacienteID") &", '"& G("Situacao") &"', "& splU(i) &")")
                    if isnull(Fator) then
                        Fator = 1
                    end if
			        if G("rdValorPlano")="V" then
				        Convenio = "Particular"
                        ConvenioID = 0
			        else
				        ConvenioID = G("ConvenioID")
				        Convenio = G("NomeConvenio")
			        end if
                    if ConvenioID=0 and Situacao="Faturado" then
                        set idesc = db.execute("select pm.PaymentMethod from itensdescontados idesc LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE ItemID="&G("ItemInvoiceID"))
                        while not idesc.eof
                            DetPag = DetPag & idesc("PaymentMethod") &" <br> "
                        idesc.movenext
                        wend
                        idesc.close
                        set idesc=nothing
                    end if
                    if ConvenioID<>0 then
                        DetPag = ccur(G("ValorPago"))
                    end if
        '			segundoProcedimento = G("segundoProcedimento")
        '			terceiroProcedimento = G("terceiroProcedimento")
        '			quartoProcedimento = G("quartoProcedimento")

                    if isnull(NomePaciente) or NomePaciente="" then
                        Oculta = 1
                    end if

			        if Situacao = "Faturado" then
                        strFat = strFat &    ";"& ProcedimentoID &"|"&  PacienteID &"|"& Data &"|"& rdValorPlano &";"
                    else
                        if instr(strFat , ";"& ProcedimentoID &"|"&  PacienteID &"|"& Data &"|"& rdValorPlano &";") then
                            Oculta = 1
                        end if
                    end if
                    if Situacao="Faturado" and instr(reqf("Faturamento"), "|F|")=0 then
                        Oculta = 1
                    end if
                    if Situacao="Não Faturado" and instr(reqf("Faturamento"), "|NF|")=0 then
                        Oculta = 1
                    end if
                    if  G("ConvenioID")=0 and instr(reqf("Recebimento"), "|R|")=0 and DetPag<>"" then
                        Oculta = 1
                    end if
                    if  G("ConvenioID")=0 and instr(reqf("Recebimento"), "|NR|")=0 and DetPag="" then
                        Oculta = 1
                    end if
                    if G("ConvenioID")<>0 and instr(reqf("Recebimento"), "|R|")=0 and isnumeric(DetPag) then
                        if DetPag>0 then
                            Oculta = 1
                        end if
                    end if
                    if G("ConvenioID")<>0 and instr(reqf("Recebimento"), "|NR|")=0 and isnumeric(DetPag) then
                        if DetPag=0 then
                            Oculta = 1
                        end if
                    end if
                    if G("ConvenioID")<>0 then
                        DetPag = fn(DetPag)
                    end if

                    if Oculta = 0 then
			            Subtotal = Subtotal+Valor

				        Conta = Conta+1
				        if G("rdValorPlano")="V" then
					        tempConv=0
				        else
					        tempConv=ConvenioID
				        end if
	        '			response.Write("insert into tempfaturamento (sysUser, ProcedimentoID, ConvenioID, Valor) values ("&session("User")&", "&ProcedimentoID&", "&ConvenioID&", "&treatvalzero(ValorNovo)&")")
	        '			db_execute("insert into tempfaturamento (sysUser, ProcedimentoID, ConvenioID, Valor) values ("&session("User")&", "&ProcedimentoID&", "&treatvalzero(ConvenioID)&", "&treatvalzero(Valor)&")")

                        idColuna = ""
                        if Situacao="Faturado" then
                            idColuna = replace(G("Data"), "/", "") &"_"& G("ProcedimentoID") &"_"& prof("id") &"_"& G("PacienteID") &"_F"
                        else
                            idColuna = replace(G("Data"), "/", "") &"_"& G("ProcedimentoID") &"_"& prof("id") &"_"& G("PacienteID") &"_NF"
                        end if
                        'Preciso fazer a ordenação por data porém está bugando no datatable, resolvi transformar a data em ID e colocar na primeira coluna para ordernar por ele.
                        orderData = replace(G("Data"), "/", "")
				        %>
				        <tr class="linhaPac">
				            <td style="display: none">orderData</td>
					        <td><%=Prontuario%> </td>
					        <td id="<%= idColuna %>">
                                <a class="btn btn-xs btn-primary btnPac hidden-print" href="./?P=Pacientes&Pers=1&I=<%=PacienteID %>&Ct=1" target="_blank"><i class="far fa-external-link"></i></a>
                                <%=left(NomePaciente&" ", 24)%>
                        
                                <%'="<br /> ;"& ProcedimentoID &"|"&  PacienteID &"|"& Data &"|"& rdValorPlano &";" %>
					        </td>
					        <td><%=G("Data")%></td>
					        <td nowrap><% If not isnull(G("HoraInicio")) and not isnull(G("HoraFim")) Then %><%=formatdatetime(G("HoraInicio"),4)%> - <%=formatdatetime(G("HoraFim"),4)%><% End If %></td>
					        <td><%=left(G("NomeProcedimento")&" ", 50)%></td>
                            <td><%=Situacao %></td>
					        <td><%=Convenio %>
                            <td class="text-right">
                                <%=DetPag %>
                                <%'="<br />"&strFat %>
					        </td>
					        <td class="text-right hidden-print"><%=fn(Fator)%></td>
                            <% if session("Banco")="clinic5351" or session("Banco")="clinic5760" then


                                if not isnull(G("idColuna")) and not isnull(G("coluna")) then
                                    set vcaRepasse = db.execute("select ifnull(sum(Valor),0) ValorRepasse from rateiorateios where modoCalculo='N' and "& G("coluna") &"="& G("idColuna") &" and ContaCredito='5_"& prof("id") &"' ")
                                    if not vcaRepasse.eof then
                                        ValorRepasse = vcaRepasse("ValorRepasse")
                                    else
                                        ValorRepasse = 0
                                    end if
                                    set vcaRepasse = db.execute("select ifnull(sum(Valor),0) ValorRepasseInv from rateiorateios where modoCalculo='I' and "& G("coluna") &"="& G("idColuna") &" and ContaCredito='5_"& prof("id") &"' ")
                                    if not vcaRepasse.eof then
                                        ValorRepasseI = vcaRepasse("ValorRepasseInv")
                                    else
                                        ValorRepasseI = 0
                                    end if
                                else
                                    ValorRepasse = 0
                                end if
                                ValorRepasse = ValorRepasse - ValorRepasseI
                                TotalValorRepasse = TotalValorRepasse + ValorRepasse
                                %>
                            <td class="text-right"><%= fn(ValorRepasse) %></td>
                            <% end if %>
					        <td class="text-right"><%=formatnumber(Valor,2)%></td>
				        </tr>
				        <%
			        end if
			        UltimoPaciente = NomePaciente
		        G.movenext
		        wend
		        G.close
		        set G=nothing
		
		        TotalGeral = TotalGeral+Subtotal
                TotalAtendimentos = TotalAtendimentos + Conta
		        %>
            </tbody>
            <tfoot>
		        <tr>
        	        <td colspan="8"><strong><%=Conta%> procedimento(s)</strong></td>
        	        <td class="text-right"><strong>SUBTOTAL:</strong></td>
                    <% if session("Banco")="clinic5351" or session("Banco")="clinic5760" then %>
                    <td class="text-right"><%= fn(TotalValorRepasse) %></td>
                    <% end if %>
                    <td class="text-right"><strong><%=formatnumber(Subtotal,2)%></strong></td>
                </tr>
            </tfoot>
        </table>
    </div>
        <hr style="page-break-after:auto; margin:0;padding:0">
