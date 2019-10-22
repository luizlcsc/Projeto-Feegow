<!--#include file="connect.asp"-->
<div class="row">
    <div class="col-md-4">
		<div class="btn-group">
            <button class="btn btn-sm btn-info dropdown-toggle" data-toggle="dropdown">
                <i class="fa fa-plus"></i> Inserir Formul&aacute;rio
                <span class="fa fa-caret-down icon-on-right"></span>
            </button>
            <ul class="dropdown-menu dropdown-info">
            <%
			if request.QueryString("Tipo")="L" then
				sqlTipo = " and (Tipo=3 or Tipo=4 or Tipo='')"
			else
				sqlTipo = " and (Tipo=1 or Tipo=2)"
			end if
			set forms = db.execute("select * from buiforms where sysActive=1"&sqlTipo&" order by Nome")
			while not forms.eof
				if autForm(forms("id"), "IN", "") then
				%>
                <li><a href="javascript:callForm(<%=request.QueryString("PacienteID")%>, <%=forms("id")%>, 'N');"><i class="fa fa-plus"></i> <%=forms("Nome")%></a></li>
				<%
				end if
			forms.movenext
			wend
			forms.close
			set forms = nothing
			if aut("buiformsI") and session("Banco")<>"clinic522" then
			%>
                <li class="divider"></li>
                <li><a href="./?P=buiforms&Pers=Follow"><i class="fa fa-cog"></i> Gerenciar modelos de formul&aacute;rios</a></li>
            <%
			end if
			%>
            </ul>
        </div>
        <button type="button" onclick="printForm();" class="btn btn-sm btn-info">
            <i class="fa fa-print"></i> Imprimir
		</button>
	</div>
	<div class="col-md-8" id="HistoricoForms">
    	<!--#include file="HistoricoForms.asp"-->
    </div>
</div>
<div class="hr dotted"></div>
<div class="row">
	<div class="col-md-12" id="divCallForm">
    </div>
</div>

<div class="alert alert-block alert-info hidden">
	<button class="close" data-dismiss="alert" type="button"><i class="fa fa-remove"></i></button> 
    <a href="./?P=buiforms&Pers=Follow"><i class="fa fa-cog"></i> Configurar modelos de anamnese, evolu&ccedil;&otilde;es, laudos e formul&aacute;rios.</a>
</div>

<script language="javascript">
function callForm(PacienteID, ModeloID, FormID){
	$.ajax({
		type:"POST",
		data:$("#formForm").serialize(),
		url:"callForm.asp?PacienteID="+PacienteID+"&ModeloID="+ModeloID+"&FormID="+FormID,
		success:function(data){
			$("#divCallForm").html(data);
		}
	});
}
<%
session("FP"&request.QueryString("Tipo"))=""

			if request.QueryString("Tipo")="L" then
				sqlTipo = " and (buiforms.Tipo=3 or buiforms.Tipo=4)"
			else
				sqlTipo = " and (buiforms.Tipo=1 or buiforms.Tipo=2)"
			end if
if session("FP"&request.QueryString("Tipo"))="" or session("FP"&request.QueryString("Tipo"))="N" then
	set vcaPreenchido = db.execute("select buiformspreenchidos.id idpreen, buiformspreenchidos.ModeloID, buiforms.Tipo from buiformspreenchidos left join buiforms on buiformspreenchidos.ModeloID=buiforms.id where PacienteID="& request.QueryString("PacienteID") &" and buiformspreenchidos.sysUser="&session("User")&sqlTipo&" order by DataHora desc")
	if vcaPreenchido.EOF then
		set modelo = db.execute("select * from buiforms where sysActive=1"&sqlTipo)
		if not modelo.eof then
			if session("banco")<>"clinic811" then
				%>
				callForm(<%= request.QueryString("PacienteID") %>, <%=modelo("id")%>, 'N');
				<%
				session("FP"&request.QueryString("Tipo")) = "N"
			end if
		end if
	else
		session("FP"&request.QueryString("Tipo")) = vcaPreenchido("idpreen")
		%>
		callForm(<%= request.QueryString("PacienteID") %>, <%=vcaPreenchido("ModeloID")%>, <%=vcaPreenchido("idpreen")%>);
		<%
	end if
else'acho q daqui pra baixo nao tem mais funcao, ja q eu to zerando a sessao ali em cima
'	response.Write("("&session("FP"&request.QueryString("Tipo"))&")")
'	response.Write("select * from buiformspreenchidos where id="&session("FP"&request.QueryString("Tipo")))
	set getPreenchido = db.execute("select * from buiformspreenchidos where id="&session("FP"&request.QueryString("Tipo")))
	if not getPreenchido.EOF then
		%>
		callForm(<%= request.QueryString("PacienteID") %>, <%=getPreenchido("ModeloID")%>, <%=session("FP"&request.QueryString("Tipo"))%>);
		<%
	end if
end if
%>
//!!!!IPRESSAOP DO FORM
function printForm(){
	$.ajax({
		url:'imprimirForm.asp?PacienteID=<%=request.QueryString("PacienteID")%>&FormID='+$("#FormID").val()+'&ModeloID='+$("#ModeloID").val(),
		success:function(data){
			$("#modal").html(data);
		}
	});
	$("#modal-table").modal('show');
}
function atualizaHistorico(){
	$.ajax({
		type:"GET",
		url:"HistoricoForms.asp?Tipo=<%=request.QueryString("Tipo")%>&PacienteID=<%=request.QueryString("PacienteID")%>",
		success:function(data){
			$("#HistoricoForms").html(data);
		}
	});
}

function staPreen(I, S){
	$.ajax({
		   type:"GET",
		   url:"Autorizados.asp?T=Form&I="+I+"&S="+S,
		   success:function(data){
			   atualizaHistorico();
		   }
	});
}
</script>