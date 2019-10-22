<div class="row">
    <ul class="hidden pagination pull-right">
        <li class="active"><a href="#">Diário</a></li>
        <li class="hidden"><a href="#">Semanal</a></li>
        <li><a href="#">Mensal</a></li>
        <li class="hidden"><a href="#">Anual</a></li>
    </ul>
</div>


<!--#include file="connect.asp"-->
<%
'(Number($("#D1_01032016").html())+Number($("#D14_01032016").html())).toFixed(2)

response.Charset="utf-8"
De = cdate(req("De"))
Ate = cdate(req("Ate"))
%>
<div class="page-header">
    <h1 class="text-center">
        Fluxo de Caixa
    </h1>
    <h4 class="text-center">
    	De <%=De%> até <%=Ate%>
    </h4>
</div>
<div>
	<table class="table table-bordered">
    	<thead>
        	<tr>
            <th rowspan="2"></th>
            <%
			Data = De
			while Data<Ate
				DataCurta = left(Data,5)
				%>
            	<th colspan="2" class="text-center"><%=DataCurta%></th>
                <%
				Data = dateadd("d", 1, Data)
			wend
			%>
            <th class="text-center" colspan="2">Total</th>
            </tr>
        	<tr>
            <%
			Data = De
			while Data<Ate
				DataCurta = left(Data,5)
				%>
            	<th class="text-center">Prev.</th>
            	<th class="text-center">Real.</th>
                <%
				Data = dateadd("d", 1, Data)
			wend
			%>
              <th class="text-center">Prev.</th>
              <th class="text-center">Real.</th>
            </tr>
        </thead>
        <tbody>
        	<tr>
<th>Receitas</th>
            <%
			Data = De
			tRecPrev = 0
			tRecReal = 0
			while Data<Ate
				set prev = db.execute("select sum(Value) Previsto from sys_financialmovement where Type='Bill' and CD='C' and Date="&mydatenull(Data))
				if isnull(prev("Previsto")) then
					Previsto = 0
				else
					Previsto = prev("Previsto")
				end if
				set real = db.execute("select sum(Value) Realizado from sys_financialmovement where Type='Pay' and CD='D' and Date="&mydatenull(Data))
				if isnull(real("Realizado")) then
					Realizado = 0
				else
					Realizado = real("Realizado")
				end if
				recPrev = recPrev&"|"&Previsto
				recReal = recReal&"|"&Realizado
				%>
            	<td class="text-right"><%=formatnumber(Previsto, 2)%></td>
            	<td class="text-right"><%=formatnumber(Realizado, 2)%></td>
                <%
				tRecPrev = tRecPrev + Previsto
				tRecReal = tRecReal + Realizado
				Data = dateadd("d", 1, Data)
			wend
			%>
            	<th class="text-right"><%=formatnumber(tRecPrev, 2)%></th>
            	<th class="text-right"><%=formatnumber(tRecReal, 2)%></th>
            </tr>
        	<tr>
<th>Despesas</th>
            <%
			Data = De
			tDesPrev = 0
			tDesReal = 0
			while Data<Ate
				set prev = db.execute("select sum(Value) Previsto from sys_financialmovement where Type='Bill' and CD='D' and Date="&mydatenull(Data))
				if isnull(prev("Previsto")) then
					Previsto = 0
				else
					Previsto = prev("Previsto")
				end if
				set real = db.execute("select sum(Value) Realizado from sys_financialmovement where Type='Pay' and CD='C' and Date="&mydatenull(Data))
				if isnull(real("Realizado")) then
					Realizado = 0
				else
					Realizado = real("Realizado")
				end if
				desPrev = desPrev&"|"&Previsto
				desReal = desReal&"|"&Realizado
				%>
            	<td class="text-right"><%=formatnumber(Previsto, 2)%></td>
            	<td class="text-right"><%=formatnumber(Realizado, 2)%></td>
                <%
				tDesPrev = tDesPrev + Previsto
				tDesReal = tDesReal + Realizado
				Data = dateadd("d", 1, Data)
			wend
			%>
            	<th class="text-right"><%=formatnumber(tDesPrev, 2)%></th>
            	<th class="text-right"><%=formatnumber(tDesReal, 2)%></th>
            </tr>


        	<tr>
<th>Resultado</th>
            <%
			splRecPrev = split(recPrev, "|")
			splRecReal = split(recReal, "|")
			splDesPrev = split(desPrev, "|")
			splDesReal = split(desReal, "|")
			
			
			Data = De
			c = 1
			tResPrev = 0
			tResReal = 0
			while Data<Ate
				resPrev = ccur(splRecPrev(c))-ccur(splDesPrev(c))
				resReal = ccur(splRecReal(c))-ccur(splDesReal(c))
				if resPrev>0 then
					classRP = "success"
				elseif resPrev<0 then
					classRP = "danger"
				else
					classRP = ""
				end if
				if resReal>0 then
					classRR = "success"
				elseif resReal<0 then
					classRR = "danger"
				else
					classRR = ""
				end if
				%>
            	<td class="text-right <%=classRP%>"><%=formatnumber(resPrev, 2)%></td>
            	<td class="text-right <%=classRR%>"><%=formatnumber(resReal, 2)%></td>
                <%
				tResPrev = tResPrev + resPrev
				tResReal = tResReal + resReal
				Data = dateadd("d", 1, Data)
				c = c+1
				acuPrev = acuPrev&"|"&resPrev
				acuReal = acuReal&"|"&resReal
			wend
			%>
            	<th class="text-right"><%=formatnumber(tResPrev, 2)%></th>
            	<th class="text-right"><%=formatnumber(tResReal, 2)%></th>
            </tr>

        	<tr>
<td><strong>Acumulado</strong></td>
            <%
			splRecPrev = split(recPrev, "|")
			splRecReal = split(recReal, "|")
			splDesPrev = split(desPrev, "|")
			splDesReal = split(desReal, "|")
			
			
			Data = De
			acuPrev = right(acuPrev, len(acuPrev)-1)
			acuReal = right(acuReal, len(acuReal)-1)
			splAcuPrev = split(acuPrev, "|")
			splAcuReal = split(acuReal, "|")


			resPrev = 0
			resReal = 0
			for i=0 to ubound(splAcuPrev)
				resPrev = resPrev + ccur(splAcuPrev(i))
				resReal = resReal + ccur(splAcuReal(i))







				if resPrev>0 then
					classRP = "success"
				elseif resPrev<0 then
					classRP = "danger"
				else
					classRP = ""
				end if
				if resReal>0 then
					classRR = "success"
				elseif resReal<0 then
					classRR = "danger"
				else
					classRR = ""
				end if
				%>
            	<td class="text-right <%=classRP%>"><%=formatnumber(resPrev, 2)%></td>
            	<td class="text-right <%=classRR%>"><%=formatnumber(resReal, 2)%></td>
                <%
				Data = dateadd("d", 1, Data)
				c = c+1
			next
			%>
            	<th class="text-right <%=classRP%>"><%=formatnumber(resPrev, 2)%></th>
            	<th class="text-right <%=classRR%>"><%=formatnumber(resReal, 2)%></th>
            </tr>


        	<tr>
<td><strong>Lucratividade</strong></td>
            <%
			
			Data = De
			c = 0
	'		response.Write( acuReal )
			while Data<Ate
					if ccur(splRecPrev(c+1))<>0 then
						resPrev = (ccur(splAcuPrev(c)) / ccur(splRecPrev(c+1))) * 100
					elseif ccur(splDesPrev(c+1))<>0 then
						resPrev = (ccur(splAcuPrev(c)) / ccur(splDesPrev(c+1))) * 100
					else
						resPrev = 0
					end if
	
					if ccur(splRecReal(c+1))<>0 then
						resReal = (ccur(splAcuReal(c)) / ccur(splRecReal(c+1))) * 100
					elseif ccur(splDesReal(c+1))<>0 then
						resReal = (ccur(splAcuReal(c)) / ccur(splDesReal(c+1))) * 100
					else
						resReal = 0
					end if
	
					%>
					<td class="text-right"><%=formatnumber(resPrev, 1)%>%</td>
					<td class="text-right"><%=formatnumber(resReal, 1)%>%</td>
					<%
					Data = dateadd("d", 1, Data)
				c = c+1
			wend

			if tRecPrev<>0 then
				tLucPrev = (tResPrev / tRecPrev) * 100
			elseif tDesPrev<>0 then
				tLucPrev = (tResPrev / tDesPrev) * 100
			else
				tLucPrev = 0
			end if

			if tRecReal<>0 then
				tLucReal = (tResReal / tRecReal) * 100
			elseif tDesReal<>0 then
				tLucReal = (tResReal / tDesReal) * 100
			else
				tLucReal = 0
			end if
			%>
            	<th class="text-right"><%=formatnumber(tLucPrev, 1)%>%</th>
            	<th class="text-right"><%=formatnumber(tLucReal, 1)%>%</th>
            </tr>

        </tbody>
        <tfoot>
        	<tr>
            	<td></td>
            </tr>
        </tfoot>
    </table>
</div>