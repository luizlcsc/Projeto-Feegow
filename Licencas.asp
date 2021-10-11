<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<script >
$(".crumb-active a").html("Gerenciamento de licenças");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Ativas");
    $(".crumb-icon a span").attr("class", "far fa-hospital");
</script>
<div class="panel mt15">
     <div class="panel-heading">
        <span class="panel-title">
            Licenças ativas
        </span>
        <span class="panel-controls">
            <button class="btn btn-sm btn-success" onclick="javascript:location.href='?P=Licenca&I=N&Pers=1'"><i class="far fa-plus"></i> INSERIR</button>
        </span>
    </div>
    <div class="panel-body">
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
    </div>
</div>
