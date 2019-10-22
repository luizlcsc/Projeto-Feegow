<div class="row">
    <ul class="pagination pull-right">
        <li class="active"><a href="#">Diário</a></li>
        <li><a href="#">Semanal</a></li>
        <li><a href="#">Mensal</a></li>
        <li><a href="#">Anual</a></li>
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
	<table class="table table-condensed table-bordered">
    	<thead>
        	<tr class="danger">
            <th rowspan="2">DESPESAS</th>
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
            </tr>
        	<tr class="danger">
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
            </tr>
        </thead>
        <tbody>
        <%
		set tipodes = db.execute("select distinct i.* from sys_financialexpensetype i")
		while not tipodes.eof
			%>
        	<tr>
            	<td><%=tipodes("Name")%></td>
            <%
			Data = De
			while Data<Ate
				%>
            	<td class="text-right" id="DP<%=tipoDes("id")&"_"&replace(Data, "/", "")%>">0.00</td>
            	<td class="text-right" id="DR<%=tipoDes("id")&"_"&replace(Data, "/", "")%>">0.00</td>
                <%
				Data = dateadd("d", 1, Data)
			wend
			%>
            </tr>
            <%
		tipodes.movenext
		wend
		tipodes.close
		set tipodes=nothing
		%>
        </tbody>
        <tfoot>
        	<tr>
            	<td></td>
            </tr>
        </tfoot>
    </table>
</div>