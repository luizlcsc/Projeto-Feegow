<link href="assets/css/core-screen.css" rel="stylesheet" media="screen" type="text/css" />
<link href="assets/css/core.css" rel="stylesheet" media="print" type="text/css" />
<link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
<style>
#areaImpressao{
    padding: 36px;
}
</style>
<%
response.Charset="utf-8"
%>
<!--#include file="connect.asp"-->
<!--#include file="./Classes/TagsConverte.asp"-->
<a style="
    border-radius: 8px;
    padding: 5px;
    margin: 15px; position:fixed; background-color:#0CF; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px;" href="#" onclick="javascript:print();" class="hidden-print" rel="areaImpressao">
	<strong>IMPRIMIR</strong>
</a>
<div id="areaImpressao" class="container-fluid">
<%

'FUNCAO DESATIVADA 08/07/2020 | Migrado 100% para a nova função TagsConverte
'function replaceProposta(PropostaID,valor)
'    IF PropostaID > 0 THEN
'        set PropostaSQL = db.execute("SELECT NomeProfissional, propostas.sysUser, tabelaparticular.NomeTabela FROM propostas LEFT JOIN profissionais ON profissionais.id = propostas.ProfissionalID LEFT JOIN tabelaparticular ON  tabelaparticular.id = propostas.TabelaID WHERE propostas.id = "&PropostaID)
'        if not PropostaSQL.eof then
'            valor = replace(valor, "[Proposta.ID]",PropostaID)
'            valor = replace(valor, "[Proposta.ProfissionalSolicitante]", PropostaSQL("NomeProfissional")&"" )
'            valor = replace(valor, "[Proposta.Criador]", nameInTable(PropostaSQL("sysUser"))&"" )
'            valor = replace(valor, "[Proposta.Tabela]",PropostaSQL("NomeTabela")&"")
'        end if
'    END IF

'    replaceProposta = valor
'end function

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


    'CONVERSOR DE TAG ANTIGO
    'CabecalhoProposta = replaceTags(getImpressos("CabecalhoProposta")&" ", PacienteID, session("User"), session("UnidadeID"))
    'CabecalhoProposta = replaceProposta(PropostaID,CabecalhoProposta)
    'RodapeProposta = replaceTags(getImpressos("RodapeProposta")&" ", PacienteID, session("User"), session("UnidadeID"))
    'RodapeProposta = replaceProposta(PropostaID,RodapeProposta)

    'CONVERSOR DE TAG NOVO || RAFAEL MAIA 01/07/2020
    set ProfissionalSQL = db.execute("SELECT p.id AS ProfissionalID, p.NomeProfissional "_
    &"FROM propostas "_
    &"LEFT JOIN profissionais AS p ON p.id = propostas.ProfissionalID "_
    &"WHERE propostas.id = "&req("PropostaID"))
        ProfissionalID = ProfissionalSQL("ProfissionalID")
    ProfissionalSQL.close
    set ProfissionalSQL=nothing
    
    CabecalhoProposta = getImpressos("CabecalhoProposta")
    CabecalhoProposta = TagsConverte(CabecalhoProposta,"PacienteID_"&PacienteID&"|ProfissionalID_"&ProfissionalID&"|PropostaID_"&PropostaID,"")

    RodapeProposta    = getImpressos("RodapeProposta")
    RodapeProposta    = TagsConverte(RodapeProposta,"PacienteID_"&PacienteID&"|ProfissionalID_"&ProfissionalID&"|PropostaID_"&PropostaID,"")    
    
end if

if req("Agrupada")="1" then
    itensSql = "SELECT T.*, Quantidade*ValorUnitario+(Quantidade*Acrescimo)-(Quantidade*Desconto) AS total "&_
        " FROM ( "&_
        " SELECT ii.ItemID, prop.UnidadeID, MAX(ii.Prioridade) AS Prioridade, group_concat(proc.NomeProcedimento SEPARATOR ', ') AS NomeProcedimento, sum(ii.ValorUnitario) AS ValorUnitario, 1 AS Quantidade, sum(ii.Acrescimo) AS Acrescimo, sum(ii.Desconto) AS Desconto,ii.TipoDesconto AS TipoDesconto,proc.DiasLaudo AS DiasLaudo,prop.TabelaID AS Tabela "&_
        " FROM itensproposta ii "&_
        " LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
        " LEFT JOIN propostas prop ON prop.id=ii.PropostaID "&_
        " WHERE ii.PropostaID="& PropostaID &_
        " GROUP BY proc.GrupoID "&_
        " ORDER BY Prioridade DESC, ii.id ASC) AS T"
else
    itensSql = "SELECT T.*,Quantidade*ValorUnitario+(Quantidade*Acrescimo)-(Quantidade*Desconto) as total FROM ("&_
        "SELECT "&_
        "         MAX(ii.Prioridade)    AS Prioridade"&_
        "        ,proc.NomeProcedimento AS NomeProcedimento"&_
        "        ,ii.ValorUnitario      AS ValorUnitario"&_
        "        ,ii.ItemID             AS ItemID"&_
        "        ,prop.UnidadeID        AS UnidadeID"&_
        "        ,SUM(ii.Quantidade)    AS Quantidade"&_
        "        ,ii.Acrescimo          AS Acrescimo"&_
        "        ,ii.Desconto           AS Desconto"&_
        "        ,ii.TipoDesconto       AS TipoDesconto"&_
        "        ,proc.DiasLaudo        AS DiasLaudo"&_
        "        ,prop.TabelaID         AS Tabela"&_
        "      FROM itensproposta ii"&_
        " LEFT JOIN procedimentos proc  on proc.id=ii.ItemID "&_
        " LEFT JOIN propostas prop       on prop.id=ii.PropostaID "&_
        " WHERE ii.PropostaID="&PropostaID&" "&_
        " GROUP BY proc.NomeProcedimento, ValorUnitario, proc.NomeProcedimento,Acrescimo,Desconto "&_
        " ORDER BY Prioridade DESC, ii.id ASC "&_
        ") AS T"
end if

'rw(itensSql)

set ItensResumoSQL = db.execute(itensSql)


while not ItensResumoSQL.EOF

    NomeProcedimento=ItensResumoSQL("NomeProcedimento")

    if DescricaoProposta<>"" then
        DescricaoProposta = DescricaoProposta &", "
    end if
    DescricaoProposta = DescricaoProposta & NomeProcedimento

ItensResumoSQL.movenext
wend
ItensResumoSQL.close
set ItensResumoSQL=nothing


sqlTimbrado = "select * from papeltimbrado where sysactive=1 and (unidadeid = '' or unidadeid is null or unidadeid like '%|ALL|%' or unidadeid like '%|"&session("UnidadeID")&"|%' ) and (profissionais = '' or profissionais is null or profissionais like '%|ALL|%') order by id desc limit 1"
set getTimbrado = db.execute(sqlTimbrado)
if not getTimbrado.EOF then
	Cabecalho = replaceTags(getTimbrado("Cabecalho")&" ", PacienteID, session("User"), session("Unidade"))
	Rodape = replaceTags(getTimbrado("Rodape")&" ", PacienteID, session("User"), session("Unidade"))
else
	Cabecalho=""
	Rodape=""
end if
Rodape = replace(Rodape, "[Procedimento.Nome]", DescricaoProposta)
RodapeProposta = replace(RodapeProposta, "[Procedimento.Nome]", DescricaoProposta)
Cabecalho = replace(Cabecalho, "[Procedimento.Nome]", DescricaoProposta)
CabecalhoProposta = replace(CabecalhoProposta, "[Procedimento.Nome]", DescricaoProposta)

Cabecalho = unscapeOutput(Cabecalho)
Rodape = unscapeOutput(Rodape)


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

              'response.write itensSql
                set itens = db.execute(itensSql)
    			if not itens.eof then

                    if itens("Tabela")&"" <> "0" then
                        set tabelaPrivadaSQL = db.execute("select NomeTabela from tabelaparticular where id ="&treatvalzero(itens("Tabela")))
                        if not tabelaPrivadaSQL.eof then
                            nometabela = "<br>("&tabelaPrivadaSQL("nometabela")&")"
                        end if
                    end if

                    Qtd = 0
                    TotalTotal = 0
                    TotalDesconto = 0

                    ExibirValorTotal=getConfig("ExibirValorTotal")
                    ExibirDesconto=getConfig("ExibirDesconto")
                    ExibirValorUnitario=getConfig("ExibirValorUnitario")
                    ExibirPrioridadeDePropostas=getConfig("ExibirPrioridadeDePropostas")
                    TabelasPrecoProposta=getConfig("TabelasPrecoProposta")&""

                    ExibirValoresDeTabela = TabelasPrecoProposta<>"" and TabelasPrecoProposta<>"0" 
                    ColspanFoot = 2

                    IF ExibirPrioridadeDePropostas THEN 
                        ColspanFoot = ColspanFoot+1
                    END IF
        
                    if ExibirValoresDeTabela then
                        TabelasPrecoProposta = replace(TabelasPrecoProposta, "|", "")
                        sqlTabelasValores = "SELECT id,NomeTabela FROM tabelaparticular WHERE id IN ("&TabelasPrecoProposta&") order by NomeTabela"
                    end if
    				%>
    				<h3><%=reg("TituloItens")%></h3>

                    <table style="text-align: center" width="100%" class="table table-striped table-condensed">
                    	<thead>
                        	<tr>
                        	    <% IF ExibirPrioridadeDePropostas THEN %>
                                    <th class="<%=hiddenValor%>">Prioridade</th>
                                <% END IF%>
                                <th style="text-align: center">Qtd</th>
                                <th style="text-align: center">Descrição</th>
                                <%
                                

                                if ExibirValoresDeTabela then
                                    set TabelasSQL = db.execute(sqlTabelasValores)

                                    while not TabelasSQL.eof
                                        
                                        ColspanFoot = ColspanFoot+1
                                        %>
                                        <th style="text-align: center"><%=TabelasSQL("NomeTabela")%></th>
                                        <%
                                    TabelasSQL.movenext
                                    wend
                                    TabelasSQL.close
                                    set TabelasSQL=nothing
                                else
                                    ColspanFoot = ColspanFoot+1
                                %>
                                <th style="text-align: right" align="right" class="<%=hiddenValor%>"><% IF getConfig("ExibirValorUnitario") = "1" THEN %>Valor Unitário<% END IF %></th>

                                <th style="text-align: right" align="right" class="<%=hiddenValor%>">
                                    <% IF ExibirDesconto = "1" THEN %>
                                        Desconto Unitário <%=nometabela%>
                                    <% END IF %>
                                </th>
                                <th style="text-align: right" align="right" class="<%=hiddenValor%>">
                                    <% IF ExibirDesconto = "1" THEN %>
                                        Desconto Total <%=nometabela%>
                                    <% END IF %>
                                </th>
                                <th style="text-align: right" align="right" class="<%=hiddenValor%>">
                                <% IF ExibirValorTotal = "1" THEN %>
                                    Valor Total
                                <% END IF %>
                                </th>
                                <%
                                end if
                                %>
                            </tr>
                        </thead>
                        <tbody>
                        <%
    					while not itens.EOF
                            TabelaID = itens("Tabela")&""
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
                            DescontoQtd = Desconto*itens("Quantidade")

    						if Desconto&""<>"" then
    						    TotalDesconto = TotalDesconto + (Desconto * itens("Quantidade"))
    						end if

    						TotalTotal = TotalTotal+Total
    						%>
    						<tr>
                            	<% IF ExibirPrioridadeDePropostas THEN %>
                            	    <td class="<%=hiddenValor%>"><%= prioridadeList.Item(itens("Prioridade")&"")%></td>
                                <% END IF%>
                            	<td><%=itens("Quantidade")%></td>
                            	<td><%=itens("NomeProcedimento")%></td>
                                <%
                                if ExibirValoresDeTabela then
                                    set TabelasSQL = db.execute(sqlTabelasValores)

                                    while not TabelasSQL.eof
                                        

                                        ValorAgendamentoTabela = calcValorProcedimento(itens("ItemID"), TabelasSQL("id"), itens("UnidadeID"), "", "", "", "")
                                        %>
                                        <td style="text-align: center"><%=fn(ValorAgendamentoTabela)%></td>
                                        <%
                                    TabelasSQL.movenext
                                    wend
                                    TabelasSQL.close
                                    set TabelasSQL=nothing
                                else
                                %>
    							<td class="<%=hiddenValor%>" align="right"><% IF ExibirValorUnitario = "1" THEN %>R$ <%=formatnumber(ValorUnitarioSemDesconto,2)%><% END IF %></td>

                                <td class="<%=hiddenValor%>" align="right"><% IF ExibirDesconto = "1" THEN %>R$ <%=formatnumber(Desconto,2)%><% END IF %></td>
                                <td class="<%=hiddenValor%>" align="right"><% IF ExibirDesconto = "1" THEN %>R$ <%=formatnumber(DescontoQtd,2)%><% END IF %></td>
                            	<td class="<%=hiddenValor%>" align="right"><% IF ExibirValorTotal = "1" THEN %>R$ <%=formatnumber(Total,2)%><% END IF %></td>
                                <%
                                end if
                                %>
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
                            	<th align="left" colspan="<%=ColspanFoot%>"><%=Qtd%> ite<%if Qtd>1 then%>ns<%else%>m<%end if%></th>
                                <%
                                if not ExibirValoresDeTabela then
                                %>
                            	<th style="text-align: right" class="<%=hiddenValor%>" align="right"><% IF ExibirDesconto = "1" THEN %> <% END IF %></th>
                            	<th style="text-align: right" class="<%=hiddenValor%>" align="right"><% IF ExibirDesconto = "1" THEN %>R$ <%=formatnumber(TotalDesconto,2)%><% END IF %></th>
                            	<th style="text-align: right" class="<%=hiddenValor%>" align="right"><% IF ExibirValorTotal = "1" THEN %>R$ <%=formatnumber(TotalTotal,2)%><% END IF %></th>
                                <%
                                end if
                                %>
                            </tr>
                        </tfoot>
                    </table>
                    <br><br>
    				<%
    			end if


    			set formas = db.execute("select pp.Descricao,p.PacienteID from pacientespropostasformas pp "_
                &"LEFT JOIN propostas p ON p.id=pp.PropostaID "_
                &"WHERE pp.PropostaID="&PropostaID)

    			if not formas.eof then
    				%>
    				<h3><%=reg("TituloPagamento")%></h3>

                    <table width="100%" class="table table-striped table-condensed">
                        <tbody>
                        <%
    					while not formas.EOF
    						'Descricao = formas("Descricao")
                            Descricao = TagsConverte(formas("Descricao"),"PacienteID_"&formas("PacienteID"),"")
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

    			Preparo=""

    			if instr(RodapeProposta, "[Procedimentos.Preparo]")>0 then
                      set getProcedimentos = db.execute("SELECT GROUP_CONCAT(ItemID SEPARATOR ', ') Itens FROM itensproposta WHERE Tipo='S' AND PropostaID="&PropostaID)
                      if not getProcedimentos.EOF then
                          set getPreparos = db.execute("SELECT NomeProcedimento, TextoPreparo FROM procedimentos WHERE id IN ("&getProcedimentos("Itens")&") ")
                          while not getPreparos.EOF
                              NomeProcedimento = "<b>"&getPreparos("NomeProcedimento")&"</b>"
                              TextoPreparo = getPreparos("TextoPreparo")
                              if TextoPreparo&""<>"" then
                                  TemPreparo = TRUE
                                  Preparo = Preparo & "<br>" & NomeProcedimento & "<br>" & TextoPreparo& "<br>"
                              end if
                          getPreparos.movenext
                          wend
                          getPreparos.close
                          set getPreparos=nothing
                          if TemPreparo then
                             Preparo = "<h3>Preparos</h3>" & Preparo
                          end if
                      end if


                      RodapeProposta = replace(RodapeProposta, "[Procedimentos.Preparo]", "")
                end if
    			%>



        	<div>
                <%=replaceTags(ObservacoesProposta&" ", PacienteID, session("User"), session("Unidade"))%>
            </div>
        	<div style="text-align: left; " height="1">
                <%= RodapeProposta %>
            </div>
        	<div height="1">
                <%= Rodape %>
            </div>
</div>
</div>
<%if TemPreparo then%>
<div style='page-break-after:always'></div>
<div style='text-align: left;'>
<%=Preparo%>
</div>
<%end if%>
<script src="assets/js/jquery-1.6.2.min.js"></script>
<script src="assets/js/jquery.PrintArea.js_4.js"></script>
<script src="assets/js/core.js"></script>
