<!--#include file="connect.asp"-->

<div class="widget-box transparent">
    <div class="widget-header widget-header-flat">
        <h4><i class="far fa-user blue"></i> OPERADORES ATIVOS</h4>
        <div class="widget-toolbar">
            <div><a class="btn btn-sm btn-success" href="?P=Operador&I=N&Pers=1"><i class="far fa-plus"></i> INSERIR</a></div>
        </div>
    </div>
</div>


<div class="row">
    <table class="table table-striped table-hover">
    	<thead>
        	<th>Nome</th>
        	<th>E-mail</th>
        	<th></th>
        </thead>
        <tbody>
        	<%
			if req("X")<>"" and isnumeric(req("X")) then
				db_execute("delete from cliniccentral.licencasusuariosmulti where Cupom='"&session("Partner")&"' AND id="&req("X")&" AND Admin=0")
				response.Redirect("./?P=Operadores&Pers=1")
			end if
			
			set ops = db.execute("select * from cliniccentral.licencasusuariosmulti where Cupom='"&session("Partner")&"'")
			while not ops.eof
				link = "./?P=Operador&Pers=1&I="&ops("id")
				%>
				<tr>
                	<td><a href="<%=link%>"><%=ops("Nome")%></a></td>
                	<td><%=ops("Email")%></td>
                	<td nowrap width="1%">
                    	<a class="btn btn-xs btn-success" href="<%=link%>"><i class="far fa-edit"></i></a>
                    	<%
						if ops("Admin")=0 then
						%>
                        	<a class="btn btn-xs btn-danger" href="javascript:if(confirm('Tem certeza de que deseja excluir este operador?'))location.href='./?P=Operadores&Pers=1&X=<%=ops("id")%>'"><i class="far fa-remove"></i></a>
                        <%
						end if
						%>
                    </td>
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