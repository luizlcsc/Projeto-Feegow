<!--#include file="connect.asp"-->

<%
DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")

%>
<h3 class="text-center">Propostas Emitidas</h3>
<h4 class="text-center">Emitidas entre <%=DataDe%> e <%=DataAte%></h4>

<%
Agrupar = req("Agrupar")
splU = split(req("UnidadeID"), ", ")

for i=0 to ubound(splU)
    Status = replace(req("Status"),"|","")
    if Status<>"" then
        sqlStatus = " AND StaID in ("&Status&") "
    end if
    UnidadeID = replace(splU(i), "|", "")
		if UnidadeID="0" then
			set un = db.execute("select NomeEmpresa Nome from empresa")
		else
			set un = db.execute("select UnitName Nome from sys_financialcompanyunits where id="& UnidadeID)
		end if
		if un.EOF then
			NomeUnidade = ""
		else
			NomeUnidade = un("Nome")
		end if
	  %>
    <h4><%= NomeUnidade %></h4>
    <%
    if Agrupar="Status" then
        %>
        <table class="table table-bordered table-hover" width="100%">
	        <thead>
                <tr>
        	        <th width="40%" class="text-center">STATUS</th>
                    <th width="40%" class="text-center">QUANTIDADE</th>
                    <th width="10%" class="text-center">VALOR TOTAL</th>
                </tr>
	        </thead>
            <tbody>
                <%
		        Conta = 0
                Subtotal = 0

		        sql = "SELECT DISTINCT pp.StaID, ps.NomeStatus, (select count(id) from propostas where UnidadeID="&UnidadeID&" and StaID=pp.StaID and DataProposta between "& mydatenull(DataDe) &" and "& mydatenull(DataAte) &") qtd, (select sum(Valor) from propostas where UnidadeID="&UnidadeID&" and StaID=pp.StaID and DataProposta between "& mydatenull(DataDe) &" and "& mydatenull(DataAte) &") Valor FROM propostas pp LEFT JOIN propostasstatus ps ON ps.id=pp.StaID WHERE pp.UnidadeID="& UnidadeID &" "&sqlStatus&" AND pp.DataProposta BETWEEN "& mydatenull(DataDe) &" AND "& mydatenull(DataAte) &""
		        'response.write(sql)
		        set G = db.execute(sql)
		        while not G.eof
			        Conta = Conta+1
			        Subtotal = Subtotal+ ccur(g("Valor"))
			        %>
                    <tr>
                        <td><%= G("NomeStatus") %></td>
                        <td class="text-right"><%= G("qtd") %></td>
                        <td class="text-right"><%= fn(G("Valor")) %></td>
                    </tr>
                    <%
		        G.movenext
		        wend
		        G.close
		        set G=nothing
		        strCatsValorDist = strCatsValorDist&"|^"&Valor


		        splID = split(strCatsIDDist, "|^")
		        splNome = split(strCatsNomeDist, "|^")
		        splValor = split(strCatsValorDist, "|^")
		
		        cats = 0
		        for j=0 to ubound(splID)
			        if splValor(j)<>"" and isnumeric(splValor(j)) then
				        ValorTotal = ValorTotal + ccur(splValor(j))
				        if ValorTotal>0 then
					        coef = 100/ValorTotal
				        end if
				
				        Percentual = coef*ccur(splValor(j))
				        cats = cats+1
				        splConta = split(splNome(j), "_")
				        Nome = accountName(splConta(0), splConta(1))
				        if Nome="" then
					        Nome = "---"
				        end if
			        %>
			        <tr>
				        <td><a target="_blank" href="./?P=Conta&Pers=1&I=<%=replace(splConta(1), "3_", "")%>"><%=Nome%></a></td>
				        <td class="text-right">R$ <%=formatnumber(splValor(j), 2)%></td>
				        <td class="text-right" id="<%=splU(i) &"_"& splID(j)%>"><%=formatnumber(Percentual, 2)%>%</td>
			        </tr>
			        <%
			        end if
		        next
		        %>
		        <tr>
        	        <th colspan="2"><%=conta%> registro<%if conta>1 then response.Write("s") end if%></td>
        	        <th class="text-right">R$ <%=fn(Subtotal)%></th>
                </tr>
            </tbody>
        </table>
    <hr style="page-break-after:always; margin:0;padding:0">
    <%
    elseif Agrupar="Usuario" then
        %>
        <table class="table table-bordered table-hover" width="100%">
	        <thead>
                <tr>
        	        <th width="40%" class="text-center">USUÁRIO</th>
                    <th width="40%" class="text-center">QUANTIDADE</th>
                    <th width="10%" class="text-center">VALOR TOTAL</th>
                </tr>
	        </thead>
            <tbody>
                <%
		        Conta = 0
                Subtotal = 0

                sqlData = "AND pp.DataProposta BETWEEN "& mydatenull(DataDe) &" AND "& mydatenull(DataAte)
                if req("Status")="|5|" then
                    joinExecutado = " LEFT JOIN sys_financialinvoices i ON i.id = pp.InvoiceID "
                    sqlData = "AND i.sysDate BETWEEN "& mydatenull(DataDe) &" AND "& mydatenull(DataAte)
                end if

		        sql = "SELECT DISTINCT pp.sysUser, count(pp.id) qtd, sum(pp.Valor) Valor FROM propostas pp "&joinExecutado&" WHERE pp.UnidadeID="& UnidadeID &" "&sqlStatus & sqlData&" GROUP BY pp.sysUser"
		        'response.write(sql)
		        set G = db.execute(sql)
		        while not G.eof
			        Conta = Conta+1
			        V = g("Valor")
                    if isnull(V) then
                        V = 0
                    else
                        V = ccur(V)
                    end if
			        Subtotal = Subtotal+ V
			        %>
                    <tr>
                        <td><%= nameInTable(G("sysUser")) %></td>
                        <td class="text-right"><%= G("qtd") %></td>
                        <td class="text-right"><%= fn(G("Valor")) %></td>
                    </tr>
                    <%
		        G.movenext
		        wend
		        G.close
		        set G=nothing
		        strCatsValorDist = strCatsValorDist&"|^"&Valor


		        splID = split(strCatsIDDist, "|^")
		        splNome = split(strCatsNomeDist, "|^")
		        splValor = split(strCatsValorDist, "|^")
		
		        cats = 0
		        for j=0 to ubound(splID)
			        if splValor(j)<>"" and isnumeric(splValor(j)) then
				        ValorTotal = ValorTotal + ccur(splValor(j))
				        if ValorTotal>0 then
					        coef = 100/ValorTotal
				        end if
				
				        Percentual = coef*ccur(splValor(j))
				        cats = cats+1
				        splConta = split(splNome(j), "_")
				        Nome = accountName(splConta(0), splConta(1))
				        if Nome="" then
					        Nome = "---"
				        end if
			        %>
			        <tr>
				        <td><a target="_blank" href="./?P=Conta&Pers=1&I=<%=replace(splConta(1), "3_", "")%>"><%=Nome%></a></td>
				        <td class="text-right">R$ <%=formatnumber(splValor(j), 2)%></td>
				        <td class="text-right" id="<%=splU(i) &"_"& splID(j)%>"><%=formatnumber(Percentual, 2)%>%</td>
			        </tr>
			        <%
			        end if
		        next
		        %>
		        <tr>
        	        <th colspan="2"><%=conta%> registro<%if conta>1 then response.Write("s") end if%></td>
        	        <th class="text-right">R$ <%=fn(Subtotal)%></th>
                </tr>
            </tbody>
        </table>
    <hr style="page-break-after:always; margin:0;padding:0">
    <%
    end if
next
%>
