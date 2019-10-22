<!--#include file="connect.asp"-->
<%
AtendimentoID = request.QueryString("AtendimentoID")
set atendimento = db.execute("select a.*, p.* from atendimentos as a left join pacientes as p on a.PacienteID=p.id where a.id="&AtendimentoID)
set un = db.execute("select * from sys_users where id="&session("User"))
UsuariosNotificar = un("UsuariosNotificar")&" "
PacienteID = atendimento("PacienteID")
%>
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title">Finalizando Atendimento &raquo; <small><%=atendimento("NomePaciente")%></small></h4>
</div>
<div class="modal-body">
    <div class="row">
    	<div class="col-xs-5" style="height:345px; overflow:auto; overflow-x:hidden;">
        	<table class="table table-striped table-hover">
			<%
            set proc = db.execute("select * from procedimentos where sysActive=1 order by NomeProcedimento")
            while not proc.eof
                %>
                <tr>
					<td><%=left(proc("NomeProcedimento"),35)%></td>
                    <td width="1%"><button type="button" onclick="addProc('AddProc', <%=proc("id")%>)" class="btn btn-success btn-xs"><i class="fa fa-chevron-right"></i></button></td>
                </tr>
                <%
            proc.movenext
            wend
            proc.close
            set proc=nothing
            %>
            </table>
        </div>
        <div class="col-xs-7">


            <h5>Lan&ccedil;amentos Realizados Hoje &raquo; <small>Receitas/Guias</small></h5>
			<%
			Data = date()
			%>
            <!--#include file="ContaDetalheLanctos.asp"-->




            <div id="procedimentosAdicionados">
	            <%server.Execute("finalizaAdicionaProcedimento.asp")%>
            </div>
        </div>
    </div>
    <hr />
    <div class="row">
<form method="post" action="" id="frmFimAtendimento">
        <div class="col-md-12"><label for="UsuariosNotificados">Selecione abaixo o(s) usu&aacute;rio(s) que receber&atilde;o a notifica&ccedil;&atilde;o para lan&ccedil;amento da receita ou da guia.</label><br />
			<select multiple="" class="width-80 chosen-select tag-input-style" id="UsuariosNotificar" name="UsuariosNotificar">
			<%
			set pus = db.execute("select u.*, p.NomeProfissional, f.NomeFuncionario from sys_users as u left join profissionais as p on (p.id=u.idInTable and u.Table='Profissionais') left join funcionarios as f on (f.id=u.idInTable and u.Table='Funcionarios') order by u.NameColumn, f.NomeFuncionario, p.NomeProfissional")
			while not pus.eof
				NomeColuna = pus("NameColumn")
				if not isnull(pus(""&NomeColuna&"")) then
					%>
					<option value="|<%=pus("id")%>|"<%if instr(UsuariosNotificar, "|"&pus("id")&"|")>0 then%> selected="selected"<%end if%>><%=pus(""&NomeColuna&"")%> &raquo; <%=pus("Table")%></option>
					<%
				end if
			pus.movenext
			wend
			pus.close
			set pus=nothing
			%>
			</select>
        </div>
</form>
                    <%'=quickField("multiple", "UsuariosNotificar", "Selecione abaixo o(s) usu&aacute;rio(s) que receber&atilde;o a notifica&ccedil;&atilde;o para lan&ccedil;amento da receita ou da guia TISS.", 12, UsuariosNotificar, "select * from funcionarios where sysActive=1 order by NomeFuncionario", "NomeFuncionario", "")%>
    </div>
</div>
<div class="modal-footer no-margin-top">
	<button class="btn btn-sm btn-warning pull-right" type="button" onClick="atender(0, <%= atendimento("PacienteID") %>, 'Encerrar')"><i class="fa fa-stop"></i> Finalizar</button>
    
</div>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
function addProc(T, I){
	$.ajax({
		type:"POST",
		url:"finalizaAdicionaProcedimento.asp?T="+T+"&I="+I+"&AtendimentoID=<%=AtendimentoID%>",
		success: function(data){
			$("#procedimentosAdicionados").html(data);
		}
	});
}

function expand(I){
	if($("#div"+I).css("display")=="none"){
		$("#div"+I).slideDown(500);
		$("#chevron"+I).attr("class", "fa fa-chevron-up");
	}else{
		$("#div"+I).slideUp(500);
		$("#chevron"+I).attr("class", "fa fa-chevron-down");
	}
}
</script>