<link href="assets/css/core-screen.css" rel="stylesheet" media="screen" type="text/css" />
<link href="assets/css/core.css" rel="stylesheet" media="print" type="text/css" />
<%

response.Charset="utf-8"

function replacePagto(txt, Total)
	on error resume next
	'response.Write(txt&"<hr>")
	txt = trim(txt&" ")
	'primeiro separa todas as tags que existem na expressao
	spl = split(txt, "{{")
	for i=0 to ubound(spl)
		if instr(spl(i), "}}")>0 then
			spl2 = split(spl(i), "}}")
			Crua = spl2(0)
			Formula = lcase(Crua)
			Formula = replace(Formula, "total", Total)
			Formula = eval(Formula)
			Formula = formatnumber(Formula, 2)
			if isnumeric(Formula) then
				Formula = "R$ "&Formula
			else
				Formula = "{{ERRO_NA_FORMULA}}"
			end if
			txt = replace(txt, "{{"&Crua&"}}", Formula)
	'		response.Write(Formula&"<br><br>")
		end if
	next
	response.Write(txt)
end function


%>
<!--#include file="connect.asp"-->
<a style="position:fixed; background-color:#0CF; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px;" href="#" class="print" rel="areaImpressao">
	<img src="assets/img/printer.png" border="0" alt="IMPRIMIR" title="IMPRIMIR" align="absmiddle"> <strong>IMPRIMIR</strong>
</a>
<div id="areaImpressao">
<%
PropostaID = req("PropostaID")

set reg=db.execute("select * from propostas where id="&PropostaID)
if not reg.EOF then
	RodapeProposta = reg("ObservacoesProposta")
	PacienteID = reg("PacienteID")
end if

set getImpressos = db.execute("select * from Impressos")
if not getImpressos.EOF then
	Cabecalho = replaceTags(getImpressos("Cabecalho")&" ", PacienteID, session("User"), session("Unidade"))
	Rodape = replaceTags(getImpressos("Rodape")&" ", PacienteID, session("User"), session("Unidade"))
	CabecalhoProposta = replaceTags(getImpressos("CabecalhoProposta")&" ", PacienteID, session("User"), session("Unidade"))
end if


%>
<title>Proposta</title>

<table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
    	<td height="1">
            <%= Cabecalho %>
        </td>
    </tr>
	<tr>
    	<td height="1">
            <%= CabecalhoProposta %>
        </td>
    </tr>
    <tr>
    	<td valign="top">
            <%
			set itens = db.execute("select ii.*, proc.NomeProcedimento from itensproposta ii LEFT JOIN procedimentos proc on proc.id=ii.ItemID where ii.PropostaID="&PropostaID)
			if not itens.eof then
				%>
				<h3><%=reg("TituloItens")%></h3>
                
                <table width="100%" class="table table-striped table-condensed">
                	<thead>
                    	<th>Qtd</th>
                    	<th>Descrição</th>
                        <%if req("v")<>"0" then %>
                    	<th>Valor Unitário</th>
                    	<th>Valor Total</th>
                        <%end if %>
                    </thead>
                    <tbody>
                    <%
					Qtd = 0
					TotalTotal = 0
					while not itens.EOF
						ValorUnitario = itens("ValorUnitario")-itens("Desconto")+itens("Acrescimo")
						Total = ValorUnitario*itens("Quantidade")
						Qtd = Qtd+itens("Quantidade")
						TotalTotal = TotalTotal+Total
						%>
						<tr>
                        	<td><%=itens("Quantidade")%></td>
                        	<td><%=itens("NomeProcedimento")%></td>
                    <%if req("v")<>"0" then %>
                        	<td align="right">R$ <%=formatnumber(ValorUnitario,2)%></td>
                        	<td align="right">R$ <%=formatnumber(Total,2)%></td>
                            <%end if %>
                        </tr>
						<%
					itens.movenext
					wend
					itens.close
					set itens=nothing
					%>
                    </tbody>
                    <%if req("v")<>"0" then %>
                    <tfoot>
                    	<tr>
                        	<th align="left" colspan="3"><%=Qtd%> ite<%if Qtd>1 then%>ns<%else%>m<%end if%></th>
                        	<th align="right">R$ <%=formatnumber(TotalTotal,2)%></th>
                        </tr>
                    </tfoot>
                    <%end if %>
                </table>
                <br><br>
				<%
			end if


			set formas = db.execute("select * from pacientespropostasformas where PropostaID="&PropostaID)
			if not formas.eof then
				%>
				<h3><%=reg("TituloPagamento")%></h3>
                
                <table width="100%" class="table table-striped table-condensed">
                    <tbody>
                    <%
					while not formas.EOF
						Descricao = formas("Descricao")
						%>
						<tr>
                        	<td width="75%"><%=replacePagto(Descricao, TotalTotal)%></td>
                        </tr>
						<%
					formas.movenext
					wend
					formas.close
					set formas=nothing
					%>
                    </tbody>
                </table>
                <br><br>
				<%
			end if


			set outros = db.execute("select * from pacientespropostasoutros where PropostaID="&PropostaID)
			if not outros.eof then
				%>
				<h3><%=reg("TituloOutros")%></h3>
                
                <table width="100%" class="table table-striped table-condensed">
                    <tbody>
                    <%
					while not outros.EOF
						%>
						<tr>
                        	<td><%=outros("Descricao")%></td>
                        	<td><%=outros("Valor")%></td>
                        </tr>
						<%
					outros.movenext
					wend
					outros.close
					set outros=nothing
					%>
                    </tbody>
                </table>
                <br><br>
				<%
			end if
			%>
            
            
            
        </td>
    </tr>
    <tr>
    	<td>
            <%=replaceTags(RodapeProposta&" ", PacienteID, session("User"), session("Unidade"))%>
        </td>
    </tr>
	<tr>
    	<td height="1">
            <%= Rodape %>
        </td>
    </tr>
</table>
</div>
<script src="assets/js/jquery-1.6.2.min.js"></script>
<script src="assets/js/jquery.PrintArea.js_4.js"></script>
<script src="assets/js/core.js"></script>
