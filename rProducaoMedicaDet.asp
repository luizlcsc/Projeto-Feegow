<!--#include file="connect.asp"-->

<style type="text/css">
body, tr, td, th {
	font-size:9px!important;
	padding:2px!important;
}

.btnPac {
    visibility:hidden;
}

.linhaPac:hover .btnPac {
    visibility:visible;
}

</style>

<%
response.CharSet="utf-8"

TotalGeral = 0
db_execute("delete from tempfaturamento where sysUser="&session("User"))

DataDe = req("DataDe")
DataAte = req("DataAte")

response.Buffer
%>
<h3 class="text-center">Produ&ccedil;&atilde;o - Analítico</h3>
<h5 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h5>

<%
if req("ProfissionalID")="" then
    erro = "Selecione ao menos um profissional"
end if
if req("Forma")="" and req("ConvenioID")="" then
    erro = "Selecione ao menos uma forma de faturamento (particular ou convênio)"
end if
if erro="" then

    splU = split(req("Unidades"), ", ")
    for i=0 to ubound(splU)
	      Total = 0
	      set prof = db.execute("select p.*, u.id UsuarioID from profissionais p left join sys_users u on u.idInTable=p.id and `Table` like 'profissionais' where p.sysActive=1 and p.Ativo='on' "&sqlProf&" and p.id in("&req("ProfissionalID")&") order by p.NomeProfissional")
	      while not prof.eof
	  	    if isnull(prof("UsuarioID")) then
			    UsuarioID = 0
		    else
			    UsuarioID = prof("UsuarioID")
		    end if
		    if splU(i)="0" then
			    set un = db.execute("select NomeFantasia Nome from empresa")
		    else
			    set un = db.execute("select UnitName Nome from sys_financialcompanyunits where id="&splU(i))
		    end if
		    if un.EOF then
			    NomeUnidade = ""
		    else
			    NomeUnidade = un("Nome")
		    end if
        if UltimaUnidade<>NomeUnidade then
	          %>
		        <h4><%= ucase(NomeUnidade& " ") %></h4>
              <%
        end if
        UltimaUnidade=NomeUnidade


        nomeTabela = splU(i) &"_"& prof("id")


        tabelas = tabelas & "|" & nomeTabela
        %>

        <h5><%=ucase(prof("NomeProfissional"))%></h5>

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
                    <th class="text-center hidden-print">FATOR</th>
                    <th class="text-center">VALOR</th>
                </tr>
	        </thead>
            <tbody>
                <%
                strFat = ""

		        strForma = ""
		        strConv = ""
		        umOUoutro = ""
		        abrePar = ""
		        fechaPar = ""
		        umEoutro = ""
		        if req("Forma")<>"" then
			        strForma = " rdValorPlano in('"&replace(req("Forma"), ", ", "', '")&"') "
		        end if
		        if req("ConvenioID")<>"" then
			        strConv = " ValorPlano in("& req("ConvenioID") &") "
		        end if
		        if strForma<>"" and strConv<>"" then
			        umOUoutro = " OR "
			        abrePar = "("
			        fechaPar = ")"
		        end if
		        if strForma<>"" or strConv<>"" then
			        umEoutro = " AND "
		        end if
                if inStr(req("Forma"), "V") then'!!!!!!!!!!!!!!!!
                    sqlParticular = "(select ii.id ItemInvoiceID, 'Faturado' Situacao, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorPlano, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorFinal, NULL Fator, i.AccountID PacienteID, 'V' rdValorPlano, ii.DataExecucao Data, ii.HoraExecucao HoraInicio, ii.HoraFim, proc.NomeProcedimento, proc.TipoProcedimentoID, pac.id Prontuario, pac.NomePaciente, 'Particular' NomeConvenio, 100 segundoProcedimento, 100 terceiroProcedimento, 100 quartoProcedimento, ii.ItemID ProcedimentoID, 0 ConvenioID from itensinvoice ii left join sys_financialinvoices i on i.id=ii.InvoiceID left join procedimentos proc on proc.id=ii.ItemID left join pacientes pac on pac.id=i.AccountID where ii.`DataExecucao`>="&mydatenull(DataDe)&" and `DataExecucao`<="&mydatenull(DataAte)&" AND ProfissionalID="&prof("id")&" AND CompanyUnitID="&splU(i)&" and ii.Associacao IN(0, 5) ORDER BY ii.DataExecucao) "&_
                    " UNION ALL"
                end if
                if req("ConvenioID")<>"" then
                    sqlConvenio = "(select '0', 'Faturado' Situacao, gc.ValorProcedimento ValorPlano, gc.ValorProcedimento ValorFinal, NULL Fator, gc.PacienteID, 'P' rdValorPlano, gc.DataAtendimento Data, NULL HoraInicio, NULL HoraFim, procgc.NomeProcedimento, procgc.TipoProcedimentoID, gc.PacienteID Prontuario, pacgc.NomePaciente, convgc.NomeConvenio, convgc.segundoProcedimento, convgc.terceiroProcedimento, convgc.quartoProcedimento, gc.ProcedimentoID, gc.ConvenioID from tissguiaconsulta gc left join procedimentos procgc on procgc.id=gc.ProcedimentoID left join pacientes pacgc on pacgc.id=gc.PacienteID left join convenios convgc on convgc.id=gc.ConvenioID where gc.`DataAtendimento`>="&mydatenull(DataDe)&" and gc.`DataAtendimento`<="&mydatenull(DataAte)&" AND gc.ConvenioID IN ("&req("ConvenioID")&") AND ifnull(gc.ProfissionalEfetivoID, gc.ProfissionalID)="&prof("id")&" AND gc.UnidadeID="&splU(i)&" ORDER BY gc.DataAtendimento)"&_
                    " UNION ALL "&_
                    "(select '0', 'Faturado', igs.ValorTotal, igs.ValorTotal, igs.Fator, gs.PacienteID, 'P', igs.Data, igs.HoraInicio, igs.HoraFim, procigs.NomeProcedimento, procigs.TipoProcedimentoID, gs.PacienteID, pacgs.NomePaciente, convgs.NomeConvenio, convgs.segundoProcedimento, convgs.terceiroProcedimento, convgs.quartoProcedimento, igs.ProcedimentoID, gs.ConvenioID from tissprocedimentossadt igs left join tissguiasadt gs on gs.id=igs.GuiaID left join procedimentos procigs on procigs.id=igs.ProcedimentoID left join pacientes pacgs on pacgs.id=gs.PacienteID left join convenios convgs on convgs.id=gs.ConvenioID where igs.`Data`>="&mydatenull(DataDe)&" AND gs.ConvenioID IN ("&req("ConvenioID")&") and igs.`Data`<="&mydatenull(DataAte)&" AND igs.ProfissionalID="&prof("id")&" AND gs.UnidadeID="&splU(i)&" ORDER BY igs.Data)"&_
                    " UNION ALL "
                end if
		        sql = sqlParticular & sqlConvenio & "(select '0', 'Não Faturado', ap.ValorPlano, ap.ValorFinal, ap.Fator, at.PacienteID, ap.rdValorPlano, at.`Data`, at.HoraInicio, at.HoraFim, proc.NomeProcedimento, proc.TipoProcedimentoID, pac.id Prontuario, pac.NomePaciente, conv.NomeConvenio, conv.segundoProcedimento, conv.terceiroProcedimento, conv.quartoProcedimento, ap.ProcedimentoID, ap.ValorPlano from atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID LEFT JOIN procedimentos proc on ap.ProcedimentoID=proc.id LEFT JOIN pacientes pac on pac.id=at.PacienteID LEFT JOIN convenios conv on conv.id=ap.ValorPlano WHERE ProfissionalID="&prof("id")&" and `Data`>="&mydatenull(DataDe)&" and `Data`<="&mydatenull(DataAte)&" AND UnidadeID="&splU(i)& umEoutro & abrePar & strForma & umOUoutro & strConv & fechaPar & " order by Data, HoraInicio)"

                '    response.Write sql 

		        set G = db.execute(sql)
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
                            DetPag = DetPag & " -&gt; "& idesc("PaymentMethod") &" <br> "
                        idesc.movenext
                        wend
                        idesc.close
                        set idesc=nothing
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
				        %>
				        <tr class="linhaPac">
					        <td><%=Prontuario%></td>
					        <td><a class="btn btn-xs btn-primary btnPac hidden-print" href="./?P=Pacientes&Pers=1&I=<%=PacienteID %>&Ct=1" target="_blank"><i class="far fa-external-link"></i></a> <%=left(NomePaciente&" ", 24)%>
                        
                                <%'="<br /> ;"& ProcedimentoID &"|"&  PacienteID &"|"& Data &"|"& rdValorPlano &";" %>
					        </td>
					        <td><%=G("Data")%></td>
					        <td nowrap><% If not isnull(G("HoraInicio")) and not isnull(G("HoraFim")) Then %><%=formatdatetime(G("HoraInicio"),4)%> - <%=formatdatetime(G("HoraFim"),4)%><% End If %></td>
					        <td><%=left(G("NomeProcedimento")&" ", 50)%></td>
                            <td><%=Situacao %></td>
					        <td><%=Convenio & DetPag %>
                                <%'="<br />"&strFat %>
					        </td>
					        <td class="text-right hidden-print"><%=fn(Fator)%></td>
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
		        %>
            </tbody>
            <tfoot>
		        <tr>
        	        <td colspan="7"><strong><%=Conta%> procedimento(s)</strong></td>
        	        <td class="text-right"><strong>SUBTOTAL:</strong></td>
                    <td class="text-right"><strong><%=formatnumber(Subtotal,2)%></strong></td>
                </tr>
            </tfoot>
        </table>
    </div>
        <hr style="page-break-after:auto; margin:0;padding:0">
	  	        <%
		        Total = Total+Subtotal
		        TotalNovo = TotalNovo+SubtotalNovo
	          prof.movenext
	          wend
	          prof.close
	          set prof = nothing
	          %>
        <%
    next
    %>
    <hr>

    <%
    if req("resumoProc")="S" then
    %>
    <table class="table table-striped table-bordered" width="100%">
      <thead>
  	    <tr>
    	    <th colspan="3">Resumo por Procedimento</th>
        </tr>
      </thead>
      <tbody>
	    <%
	    set res = db.execute("select distinct tf.ProcedimentoID, proc.NomeProcedimento, (select count(*) from tempfaturamento where ProcedimentoID=tf.ProcedimentoID and sysUser="&session("User")&") qtd, (select sum(valor) from tempfaturamento where sysUser="&session("User")&" and ProcedimentoID=tf.ProcedimentoID) total from tempfaturamento tf left join procedimentos proc on proc.id=tf.ProcedimentoID where not isnull(NomeProcedimento) and tf.sysUser="&session("User")&" order by proc.NomeProcedimento")
	    TotalProcs = 0
	    TotalProcsValor = 0
	    while not res.EOF
		    TotalProcs = TotalProcs+ccur(res("qtd"))
		    TotalProcsValor = TotalProcsValor+ccur(res("total"))
		    %>
		    <tr>
        	    <td><%=res("NomeProcedimento")%></td>
        	    <td class="text-right"><%=res("qtd")%></td>
        	    <td class="text-right">R$ <%=formatnumber(res("total"), 2)%></td>
            </tr>
		    <%
	    res.movenext
	    wend
	    res.close
	    set res=nothing
	    %>
      </tbody>
      <tfoot>
        <tr>
    	    <td><strong>TOTAL GERAL</strong></td>
            <td class="text-right"><strong><%=TotalProcs%></strong></td>
            <td class="text-right"><strong>R$ <%=formatnumber(TotalProcsValor, 2)%></strong></td>
        </tr>
      </tfoot>
    </table>
    <% End If %>
    <%
    if req("resumoConv")="S" then
    %>
    <table class="table table-striped table-bordered" width="100%">
      <thead>
  	    <tr>
    	    <th colspan="3">Resumo por Conv&ecirc;nio</th>
        </tr>
      </thead>
      <tbody>
	    <%
	    set res = db.execute("select distinct tf.ConvenioID, conv.NomeConvenio, (select count(*) from tempfaturamento where ConvenioID=tf.ConvenioID and sysUser="&session("User")&") qtd, (select sum(valor) from tempfaturamento where sysUser="&session("User")&" and ConvenioID=tf.ConvenioID) total from tempfaturamento tf left join convenios conv on conv.id=tf.ConvenioID where not isnull(NomeConvenio) and tf.sysUser="&session("User")&" order by conv.NomeConvenio")
	    TotalProcs = 0
	    TotalProcsValor = 0
	    while not res.EOF
		    TotalProcs = TotalProcs+ccur(res("qtd"))
		    TotalProcsValor = TotalProcsValor+ccur(res("total"))
		    %>
		    <tr>
        	    <td><%=res("NomeConvenio")%></td>
        	    <td class="text-right"><%=res("qtd")%></td>
        	    <td class="text-right">R$ <%=formatnumber(res("total"), 2)%></td>
            </tr>
		    <%
	    res.movenext
	    wend
	    res.close
	    set res=nothing
	    %>
      </tbody>
      <tfoot>
        <tr>
    	    <td><strong>TOTAL GERAL</strong></td>
            <td class="text-right"><strong><%=TotalProcs%></strong></td>
            <td class="text-right"><strong>R$ <%=formatnumber(TotalProcsValor, 2)%></strong></td>
        </tr>
      </tfoot>
    </table>
    <% End If %>

    <h5 class="text-right">Total: R$ <%=formatnumber(TotalGeral, 2)%></h5>
<%else%>

<div class="alert alert-warning">
    Erro: <%=erro%>
</div>

<%end if%>






            
			<script type="text/javascript">
			    jQuery(function ($) {
                    <%
                    splTabelas = split(tabelas, "|")
                    for tb=1 to ubound(splTabelas)
                    %>

					var oTable<%=tb%> = $('#t<%=splTabelas(tb)%>').dataTable( {
					"aoColumns": [ null,null,null, null,null,null,null,null,null ] } );

                    <%
                    next
                    %>
				})
			</script>