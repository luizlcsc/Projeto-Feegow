<link href="assets/css/core-screen.css" rel="stylesheet" media="screen" type="text/css" />
<link href="assets/css/core.css" rel="stylesheet" media="print" type="text/css" />
<link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">

<%
response.Charset="utf-8"



%>
<!--#include file="connect.asp"-->
<a style="position:fixed; background-color:#0CF; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px;" href="#" onclick="javascript:print();" class="hidden-print" rel="areaImpressao">
	<img src="assets/img/printer.png" border="0" alt="IMPRIMIR" title="IMPRIMIR" align="absmiddle"> <strong>IMPRIMIR</strong>
</a>
<div id="areaImpressao" class="container-fluid">
<%

function replaceProposta(PropostaID,valor)
    IF PropostaID > 0 THEN
        set PropostaSQL = db.execute("SELECT NomeProfissional, propostas.sysUser FROM propostas LEFT JOIN profissionais ON profissionais.id = propostas.ProfissionalID WHERE propostas.id = "&PropostaID)
        if not PropostaSQL.eof then
            valor = replace(valor, "[Proposta.ID]",PropostaID)
            valor = replace(valor, "[Proposta.ProfissionalSolicitante]", PropostaSQL("NomeProfissional")&"" )
            valor = replace(valor, "[Proposta.Criador]", nameInTable(PropostaSQL("sysUser"))&"" )
        end if
    END IF

    replaceProposta = valor
end function

Dim prioridadeList
Set prioridadeList=Server.CreateObject("Scripting.Dictionary")
prioridadeList.Add "1"," - "
prioridadeList.Add "2","Baixa"
prioridadeList.Add "3","Média"
prioridadeList.Add "4","Alta"
prioridadeList.Add "5","Altíssima"

PropostaID = req("PropostaID")
PrazoEntrega = 0

if session("Banco")="clinic4456" and lcase(session("Table"))="profissionais" and not session("Admin")=1 then
    hiddenValor = " hidden "
end if

if aut("valordoprocedimentoV")<>1 then
    hiddenValor = " hidden "
end if

set reg=db.execute("select * from propostas where id="&PropostaID)
if not reg.EOF then
	ObservacoesProposta = reg("ObservacoesProposta")
	PacienteID = reg("PacienteID")
end if

set getImpressos = db.execute("select * from Impressos")
if not getImpressos.EOF then
	'Cabecalho = replaceTags(getImpressos("Cabecalho")&" ", PacienteID, session("User"), session("UnidadeID"))
	'Rodape = replaceTags(getImpressos("Rodape")&" ", PacienteID, session("User"), session("UnidadeID"))
	CabecalhoProposta = replaceTags(getImpressos("CabecalhoProposta")&" ", PacienteID, session("User"), session("UnidadeID"))
	CabecalhoProposta = replaceProposta(PropostaID,CabecalhoProposta)
	RodapeProposta = replaceTags(getImpressos("RodapeProposta")&" ", PacienteID, session("User"), session("UnidadeID"))
	RodapeProposta = replaceProposta(PropostaID,RodapeProposta)
end if



sqlTimbrado = "select * from papeltimbrado where sysactive=1 and (unidadeid = '' or unidadeid is null or unidadeid like '%|ALL|%' or unidadeid like '%|"&session("UnidadeID")&"|%' ) and (profissionais = '' or profissionais is null or profissionais like '%|ALL|%') order by id desc limit 1"
set getTimbrado = db.execute(sqlTimbrado)
if not getTimbrado.EOF then
	Cabecalho = replaceTags(getTimbrado("Cabecalho")&" ", PacienteID, session("User"), session("Unidade"))
	Rodape = replaceTags(getTimbrado("Rodape")&" ", PacienteID, session("User"), session("Unidade"))
else
	Cabecalho=""
	Rodape=""
end if

if MarcaDagua <> "" then
            %>
<style>
#areaImpressao{
    <%=MarcaDagua%>;
    background-size: 450px;
    background-repeat: no-repeat;
    background-position: center center;
    min-height:80%;
}

.conteudo-prescricao{
    padding: 35px;
}

h1, h2, h3, h4, h5, p{
    padding: 0;
}

body, td, th{
    padding: 0;
}

body{
    padding: 0;
}
/*2250*/
/*150*/
</style>
            <%
end if

%>
<style>

body{
    background-color: #fff!important;
}
</style>
<title>Proposta</title>
<style>
.hidden{
    display: none;
}
</style>
    <div >
<div>
                <%= Cabecalho %>
</div>
<div>
                <%= CabecalhoProposta %>
</div>
                <%
    			'set itens = db.execute("select ii.*, proc.NomeProcedimento, proc.DiasLaudo from itensproposta ii LEFT JOIN procedimentos proc on proc.id=ii.ItemID where ii.PropostaID="&PropostaID&" ORDER BY Prioridade Desc" )
    			set itens = db.execute("SELECT T.*,Quantidade*ValorUnitario+(Quantidade*Acrescimo)-(Quantidade*Desconto) as total FROM ("&_
                                        "SELECT "&_
                                        "         MAX(Prioridade)  AS Prioridade"&_
                                        "       ,NomeProcedimento  AS NomeProcedimento"&_
                                        "        ,ValorUnitario    AS ValorUnitario"&_
                                        "        ,SUM(Quantidade)  AS Quantidade"&_
                                        "        ,Acrescimo        AS Acrescimo"&_
                                        "        ,Desconto         AS Desconto"&_
                                        "        ,TipoDesconto     AS TipoDesconto"&_
                                        "        ,DiasLaudo        AS DiasLaudo"&_
                                        "      FROM itensproposta ii"&_
                                        " LEFT JOIN procedimentos proc on proc.id=ii.ItemID "&_
                                        " WHERE ii.PropostaID="&PropostaID&" "&_
                                        " GROUP BY proc.NomeProcedimento, ValorUnitario, proc.NomeProcedimento,Acrescimo,Desconto "&_
                                        " ORDER BY Prioridade Desc "&_
                                        ") AS T")
    			if not itens.eof then
    				%>
    				<h3><%=reg("TituloItens")%></h3>

                    <table style="text-align: center" width="100%" class="table table-striped table-condensed">
                    	<thead>
                        	<tr>
                        	    <% IF getConfig("ExibirPrioridadeDePropostas") THEN %>
                                    <th class="<%=hiddenValor%>">Prioridade</th>
                                <% END IF%>
                                <th style="text-align: center">Qtd</th>
                                <th style="text-align: center">Descrição</th>
                                <th style="text-align: right" align="right" class="<%=hiddenValor%>"><% IF getConfig("ExibirDesconto") = "1" THEN %>Valor Unitário<% END IF %></th>

                                <th style="text-align: right" align="right" class="<%=hiddenValor%>">


                                <% IF getConfig("ExibirDesconto") = "1" THEN %>
                                     Desconto Unitário
                                <% END IF %>
                                </th>

                                <th style="text-align: right" align="right" class="<%=hiddenValor%>">Valor Total</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
    					Qtd = 0
    					TotalTotal = 0
    					TotalDesconto = 0
    					while not itens.EOF
    					    Desconto = itens("Desconto")
    					    Acrescimo = itens("Acrescimo")
    					    Prioridade = itens("Prioridade")
    					    if itens("TipoDesconto")="P" then
    					        Desconto = itens("Desconto") /100 * itens("ValorUnitario")
    					    end if
    						ValorUnitarioSemDesconto = itens("ValorUnitario")
    						ValorUnitario = itens("ValorUnitario")-Desconto+Acrescimo
    						Total = ValorUnitario*itens("Quantidade")
    						Qtd = Qtd+itens("Quantidade")

    						if Desconto&""<>"" then
    						    TotalDesconto = TotalDesconto + (Desconto * itens("Quantidade"))
    						end if

    						TotalTotal = TotalTotal+Total
    						%>
    						<tr>
                            	<% IF getConfig("ExibirPrioridadeDePropostas") THEN %>
                            	    <td class="<%=hiddenValor%>"><%= prioridadeList.Item(itens("Prioridade")&"")%></td>
                                <% END IF%>
                            	<td><%=itens("Quantidade")%></td>
                            	<td><%=itens("NomeProcedimento")%></td>
    							<td class="<%=hiddenValor%>" align="right"><% IF getConfig("ExibirDesconto") = "1" THEN %>R$ <%=formatnumber(ValorUnitarioSemDesconto,2)%><% END IF %></td>
                            	<td class="<%=hiddenValor%>" align="right"><% IF getConfig("ExibirDesconto") = "1" THEN %>R$ <%=formatnumber(Desconto,2)%><% END IF %></td>
                            	<td class="<%=hiddenValor%>" align="right">R$ <%=formatnumber(Total,2)%></td>
                            </tr>
    						<%
    						itensPrazoEntrega = itens("DiasLaudo")

    						if isnumeric(itensPrazoEntrega) then
                                if itensPrazoEntrega > PrazoEntrega then
                                    PrazoEntrega = itensPrazoEntrega
                                end if
    						end if
    					itens.movenext
    					wend
    					itens.close
    					set itens=nothing
    					%>
                        </tbody>
                        <tfoot>
                        	<tr>
                            	<th align="left" colspan="<% IF getConfig("ExibirPrioridadeDePropostas")=0 THEN %>3<%else%>4<%end if%>"><%=Qtd%> ite<%if Qtd>1 then%>ns<%else%>m<%end if%></th>
                            	<th style="text-align: right" class="<%=hiddenValor%>" align="right"><% IF getConfig("ExibirDesconto") = "1" THEN %>R$ <%=formatnumber(TotalDesconto,2)%><% END IF %></th>
                            	<th style="text-align: right" class="<%=hiddenValor%>" align="right">R$ <%=formatnumber(TotalTotal,2)%></th>
                            </tr>
                        </tfoot>
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
                            Descricao = replace(Descricao, chr(10), "<br>")
    						%>
    						<tr>
                            	<td class="<%=hiddenValor%>" width="75%"><%=replacePagto(Descricao, TotalTotal)%></td>
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
                            	<td class="<%=hiddenValor%>"><%=outros("Valor")%></td>
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
    			RodapeProposta = replace(RodapeProposta, "[Previsao.Entrega]", PrazoEntrega)

    			if instr(RodapeProposta, "[Procedimentos.Preparo]")>0 then
                    set getProcedimentos = db.execute("SELECT GROUP_CONCAT(ItemID SEPARATOR ', ') Itens FROM itensproposta WHERE Tipo='S' AND PropostaID="&PropostaID)
                    if not getProcedimentos.EOF then
                        Preparo = "<h3>Preparos</h3>"
                        set getPreparos = db.execute("SELECT NomeProcedimento, TextoPreparo FROM procedimentos WHERE id IN ("&getProcedimentos("Itens")&") ")
                        if getPreparos.EOF then
                            Preparo = Preparo & "<br><i>Nenhum preparo.</i><br>"
                        end if
                        while not getPreparos.EOF
                            NomeProcedimento = "<b>"&getPreparos("NomeProcedimento")&"</b>"
                            TextoPreparo = getPreparos("TextoPreparo")
                            if TextoPreparo&""<>"" then
                                Preparo = Preparo & "<br>" & NomeProcedimento & "<br>" & TextoPreparo &"<br>"
                            end if
                        getPreparos.movenext
                        wend
                        getPreparos.close
                        set getPreparos=nothing
                    end if


                    RodapeProposta = replace(RodapeProposta, "[Procedimentos.Preparo]", Preparo)
    			end if
    			%>



        	<div>
                <%=replaceTags(ObservacoesProposta&" ", PacienteID, session("User"), session("Unidade"))%>
            </div>
        	<div height="1">
                <%= RodapeProposta %>
            </div>
        	<div height="1">
                <%= Rodape %>
            </div>
</div>
</div>
<script src="assets/js/jquery-1.6.2.min.js"></script>
<script src="assets/js/jquery.PrintArea.js_4.js"></script>
<script src="assets/js/core.js"></script>
