<!--#include file="connect.asp"-->
<%
AtendimentoID = req("AtendimentoID")
Tipo = req("T")
ID = req("I")
if Tipo="AddProc" then
	'A função que adiciona primeiro vê o id do procedimento e do paciente. Depois verifica se o plano do paciente cobre aquele procedimento. Se cobrir ele adiciona o pré-guia, caso contrá o pré-receita com o valor do agendamento
	set atend = db.execute("select * from atendimentos where id="&AtendimentoID)
	set conv = db.execute("select * from pacientesconvenios where PacienteID="&atend("PacienteID")&" and not isnull(ConvenioID) and not ConvenioID=0 and not Matricula like ''")
	if not conv.eof then
		rdValorPlano = "P"
		ValorPlano = conv("ConvenioID")
		FormaID = ValorPlano
	else
		set proc = db.execute("select * from procedimentos where id="&ID)
		rdValorPlano = "V"
		ValorPlano = proc("Valor")
		FormaID = "P"
	end if

	db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, rdValorPlano, ValorPlano) values ("&AtendimentoID&", "&ID&", '"&rdValorPlano&"', "&treatvalzero(ValorPlano)&")")
	set pultAP = db.execute("select id from atendimentosprocedimentos where AtendimentoID="&AtendimentoID&" order by id desc limit 1")
	DominioID = dominioRepasse(FormaID, session("idInTable"), ID)
	
	call materiaisInformados(DominioID, session("User"), pultAP("id"))
end if
if Tipo="DelProc" then
	db_execute("delete from atendimentosprocedimentos where id="&ID)
	db_execute("delete from atendimentosmateriais where AtendProcID="&ID)
end if
%>
<h5>Procedimentos &raquo; <small>Clique nos itens que dever&atilde;o ser informados</small></h5>
<%

if AtendimentoID<>"N" then
	set procs = db.execute("select ap.*, p.NomeProcedimento, p.Valor, at.PacienteID from atendimentosprocedimentos as ap left join procedimentos as p on p.id=ap.ProcedimentoID left join atendimentos as at on at.id=ap.AtendimentoID where AtendimentoID="&AtendimentoID)
	if procs.eof then
		%>Voc&ecirc; ainda n&atilde;o informou nenhum procedimento realizado neste atendimento.<%
	else
		%>
		<table class="table table-striped table-hover">
		<%
		while not procs.eof
			ValorParticular = procs("Valor")
			if not isnull(ValorParticular) then
				ValorParticular = formatnumber(ValorParticular, 2)
			end if
			
			set conv = db.execute("select * from pacientesconvenios where PacienteID="&procs("PacienteID")&" and not isnull(ConvenioID)")
			if not conv.eof then
				IDConvenio = conv("ConvenioID")
			end if
	
			if procs("rdValorPlano")="P" then
				icone = "far fa-credit-card"
				IDConvenio = procs("ValorPlano")
			else
				icone = "far fa-money"
				ValorParticular = procs("ValorPlano")
			end if
			%>
			<tr>
				<td>
				<form name="proc<%=procs("id")%>" id="proc<%=procs("id")%>" action="" method="post">
				<i class="<%=icone%>"></i> <%=procs("NomeProcedimento")%>
				<button type="button" onclick="expand(<%=procs("id")%>);" class="btn btn-info btn-xs pull-right">Detalhar <i id="chevron<%=procs("id")%>" class="far fa-chevron-down"></i></button>
				<button type="button" onclick="if(confirm('Tem certeza de que deseja excluir este registro?'))addProc('DelProc', <%=procs("id")%>)" class="btn btn-danger btn-xs pull-right"><i class="far fa-remove"></i></button>
				<div id="div<%=procs("id")%>" style="display:none">
	
					<div class="row">
						<div class="col-md-5">
						  <label><input type="radio" onchange="saveAP(<%=procs("id")%>);" name="rdValorPlano" id="<%=procs("id")%>" required value="V"<% If procs("rdValorPlano")="V" Then %> checked="checked"<% End If %> class="ace valplan" style="z-index:-1" /><span class="lbl"> Particular</span></label><br />
							<label><input type="radio" onchange="saveAP(<%=procs("id")%>);" name="rdValorPlano" id="<%=procs("id")%>" required value="P"<% If procs("rdValorPlano")="P" Then %> checked="checked"<% End If %> class="ace valplan" style="z-index:-1" /><span class="lbl"> Conv&ecirc;nio</span></label>
						</div>
						<div class="col-md-7" id="divValor<%=procs("id")%>"<% If (procs("rdValorPlano")<>"V" or isnull(procs("rdValorPlano"))) Then %> style="display:none"<% End If %>>
							<label for="Valor">Valor</label>
							<%=quickField("currency", "Valor"&procs("id"), "", 5, ValorParticular, "", "", " onchange='saveAP("&procs("id")&")';")%>
						</div>
						<div class="col-md-7" id="divConvenio<%=procs("id")%>"<% If (procs("rdValorPlano")<>"P" or isnull(procs("rdValorPlano"))) Then %> style="display:none"<% End If %>>
							<%=selectInsert("Conv&ecirc;nio", "ConvenioID"&procs("id"), IDConvenio, "convenios", "NomeConvenio", " onchange=""saveAP("&procs("id")&")""", "", "")%>
						</div>
					</div>
					<div class="row">
					   <%=quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 12, procs("Obs"), "", "", " onchange='saveAP("&procs("id")&")';")%>
					</div>
						<%
						set mat = db.execute("select am.*, p.NomeProduto from atendimentosmateriais am left join produtos p on p.id=am.ProdutoID where am.AtendProcID="&procs("id"))
						if not mat.eof then
						%>
						<table class="table table-striped table-bordered" width="100%">
							<thead>
								<tr>
									<th>Material Utilizado</th>
									<th>Quantidade</th>
								</tr>
							</thead>
							<tbody>
							<%
							while not mat.eof
								%>
								<tr>
									<td><%=mat("NomeProduto")%> (UN)</td>
									<td><%=quickField("text", "Mat"&mat("id"), "", 5, formatnumber(mat("Quantidade"),2), " input-mask-brl text-right input-sm", "", "")%> </td>
								</tr>
								<%
							mat.movenext
							wend
							mat.close
							set mat=nothing
							%>
							</tbody>
						</table>
						<%
						end if
						%>
	
				</div>
				</form>
				</td>
			</tr>
			<%
		procs.movenext
		wend
		procs.close
		set procs=nothing
		%>
		</table>
		<%
	end if
end if
%>

<script language="javascript">
$(".valplan").click(function(){
	var tipo =$(this).val();
	var id = $(this).attr("id");
	if(tipo=="V"){
		$("#divConvenio"+id).hide();
		$("#divValor"+id).show();
	}else{
		$("#divConvenio"+id).show();
		$("#divValor"+id).hide();
	}
});

function saveAP(ProcAtID){
	$.ajax({
		type:"POST",
		url:"salvaProcedimentoFinalizacao.asp?ProcAtID="+ProcAtID,
		data:$("#proc"+ProcAtID).serialize(),
		success: function(data){
			eval(data);
		}
	});
}

<!--#include file="jQueryFunctions.asp"-->
</script>