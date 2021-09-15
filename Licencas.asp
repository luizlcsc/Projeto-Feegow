<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->

<div class="widget-box transparent">
    <div class="widget-header widget-header-flat">
        <h4><i class="far fa-hospital-o blue"></i> LICENÇAS ATIVAS</h4>
        <div class="widget-toolbar">
            <div><a class="btn btn-sm btn-success" href="?P=Licenca&I=N&Pers=1"><i class="far fa-plus"></i> INSERIR</a></div>
        </div>
    </div>
</div>


<div class="row">
    <table class="table table-striped table-hover">
    	<thead>
        	<th>Empresa</th>
        	<th>Status</th>
        </thead>
        <tbody>
        	<%
			'if req("X")<>"" and isnumeric(req("X")) then
			'	db_execute("delete from cliniccentral.licencasusuariosmulti where Cupom='"&session("Partner")&"' AND id="&req("X")&" AND Admin=0")
			'	response.Redirect("./?P=Operadores&Pers=1")
			'end if
			
			set ops = dbc.execute("select * from cliniccentral.licencas where Cupom='"&session("Partner")&"'")
			while not ops.eof
				link = "./?P=Licenca&Pers=1&I="&ops("id")
				%>
				<tr>
                	<td><a href="<%=link%>"><%=ops("NomeEmpresa")%></a></td>
                	<td><%=ops("Status")%></td>
                </tr>
				<%
			ops.movenext
			wend
			ops.close
			set ops=nothing
			%>
        </tbody>
    </table>
</div>