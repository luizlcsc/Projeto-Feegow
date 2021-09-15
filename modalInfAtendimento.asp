<!--#include file="connect.asp"-->

<%
    btn = "0"
    if req("btn") <> "0" and req("btn")<> ""  then
        btn = "1"
    end if

%>
<style>
.ace {
    display: none;
}
.ace {
    position: absolute;
    overflow: hidden;
    clip: rect(0 0 0 0);
    height: 1px;
    width: 1px;
    margin: -1px;
    padding: 0;
    border: 0;
}
.eh-label {
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    -khtml-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
}
.eh-label:after {
    content:'';
    position: absolute;
    left: 10px;
    border: 1px solid #000;
    height: 12px;
    width: 12px;
}
.ace + .eh-label {
    padding-left: 26px;
    height: 19px;
    display: inline-block;
    line-height: 19px;
    background-repeat: no-repeat;
    background-position: 0 0;
    font-size: 20px;
    vertical-align: middle;
    cursor: pointer;
}
.ace:checked + .eh-label:before {
    content:'\2713';
    position: absolute;
    left: 12px;
    font-size: 24px;
    color: #008000;
    top: 4px;
}




.duplo>tbody>tr:nth-child(4n+1)>td,
.duplo>tbody>tr:nth-child(4n+2)>td
{    background-color: #f9f9f9;
}
.duplo>tbody>tr:nth-child(4n+3)>td,
.duplo>tbody>tr:nth-child(4n+4)>td
{    background-color: #ffffff;
}
</style>

<%
AtendimentoID = req("AtendimentoID")
PacienteID = ccur(req("PacienteID"))
PermitirInformarProcedimentos = getConfig("PermitirInformarProcedimentos")

if AtendimentoID = "N" then
	sqlVCA = "select * from atendimentos where sysUser="&session("User")*(-1)
	set vca = db.execute(sqlVCA)
	if vca.eof then
		db_execute("insert into atendimentos (PacienteID, AgendamentoID, sysUser, ProfissionalID, UnidadeID) values ("&PacienteID&", 0, "&session("User")*(-1)&", 0, "&session("UnidadeID")&")")
		set vca = db.execute(sqlVCA)
	else
		db_execute("update atendimentos set PacienteID="&PacienteID&" where id="&vca("id"))
		db_execute("delete from atendimentosprocedimentos where AtendimentoID="&vca("id"))
	end if
	AtendimentoID = vca("id")
	HoraInicio = time()
	HoraFim = time()
	Data = date()
	UnidadeID = session("UnidadeID")
'	response.Write("select ProfissionalID, Hora, HoraFinal from agendamentos where PacienteID="&PacienteID&" and Data="&mydatenull(Data))
	set vcAg = db.execute("select ProfissionalID, Hora, HoraFinal from agendamentos where PacienteID="&PacienteID&" and Data="&mydatenull(Data))
	if not vcAg.eof then
		ProfissionalID = vcAg("ProfissionalID")
		HoraInicio = vcAg("Hora")
		if not isnull(HoraInicio) then
			HoraInicio = formatdatetime(HoraInicio, 4)
		end if
		HoraFim = vcAg("HoraFinal")
		if not isnull(HoraFim) then
			HoraFim = formatdatetime(HoraFim, 4)
		end if
	end if
else
	set vca = db.execute("select * from atendimentos where id="&AtendimentoID)
	if not vca.eof then
		ProfissionalID = vca("ProfissionalID")
		Data = vca("Data")
		if not isnull(vca("HoraInicio")) then
			HoraInicio = formatdatetime(vca("HoraInicio"), 4)
		end if
		if not isnull(vca("HoraFim")) then
			HoraFim = formatdatetime(vca("HoraFim"),4)
		end if
		if req("Origem")="Atendimento" then
			HoraFim = time()
		end if
		UnidadeID = vca("UnidadeID")
	end if
end if


set atendimento = db.execute("select a.*, p.* from atendimentos as a left join pacientes as p on a.PacienteID=p.id where a.id="&AtendimentoID)
set un = db.execute("select *,COALESCE((SELECT concat('|',GROUP_CONCAT(UsuarioID SEPARATOR '|, |'),'|') FROM config_usuarios_solicitacoes where UnidadeID  = "&session("UnidadeID")&"),sys_users.UsuariosNotificar) as UsuariosNotificar FROM  sys_users where id="&session("User"))
if btn = "0" then
    UsuariosNotificar = un("UsuariosNotificar")&" "
end if
PacienteID = atendimento("PacienteID")
Solicitacao = req("Solicitacao")

if Solicitacao="S" then
	Titulo = "Solicitar Pagamento ou Emiss&atilde;o/Autoriza&ccedil;&atilde;o de Guia"
else
	Titulo = "Informar Atendimento"
end if

db.execute("DELETE FROM calculos_finalizar_atendimento_log WHERE AtendimentoID = "&AtendimentoID)

%>
<script >
function saveInf(AI){
	$("#btnSaveInf").prop("disabled", true);
	$("#btnSaveInf").html("salvando...");
    let excluir = $('#procedimentosAdicionados').attr('data-excluir')
	$.post("saveInf.asp?AgendamentoID=<%=req("AgendamentoID")%>&AtendimentoID="+AI+"&Origem=<%=req("Origem")%>&Solicitacao=<%=req("Solicitacao")%>&excluir="+excluir, $("#frmFimAtendimento").serialize(), function(data, status){ eval(data) });
}
</script>
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title lighter blue"><%=Titulo%> &raquo; <small><%=atendimento("NomePaciente")%></small></h4>
</div>
<form method="post" action="" id="frmFimAtendimento">
    <div class="modal-body">
    <%
	if req("Origem")="Atendimento" then
		%>
        <input type="hidden" name="inf-ProfissionalID" id="inf-ProfissionalID" value="<%=session("idInTable")%>">
        <input type="hidden" name="inf-Data" id="inf-Data" value="<%=Data%>">
        <input type="hidden" name="inf-HoraInicio" id="inf-HoraInicio" value="<%=HoraInicio%>">
        <input type="hidden" name="inf-HoraFim" id="inf-HoraFim" value="<%=HoraFim%>">
        <input type="hidden" name="UnidadeID" id="UnidadeID" value="<%=session("UnidadeID")%>">
        <%
	else
		%>
        <div class="clearfix form-actions no-margin" style="margin-bottom:7px!important">
            <%=quickField("select", "inf-ProfissionalID", "Profissional", 4, ProfissionalID, "select id, NomeProfissional from profissionais where sysActive=1 order by NomeProfissional", "NomeProfissional", "")%>
            <%=quickField("datepicker", "inf-Data", "Data", 2, Data, "", "", " required")%>
            <%=quickField("text", "inf-HoraInicio", "In&iacute;cio", 2, HoraInicio, "input-mask-l-time", "", "required")%>
            <%=quickField("text", "inf-HoraFim", "Fim", 2, HoraFim, "input-mask-l-time", "", "required")%>
            <%=quickField("empresa", "UnidadeID", "Unidade", 2, UnidadeID, "", "", "")%>
        </div>
        <%
	end if
	%>
        <div class="row">
                <%
                tamanhocoluna = 12
                if aut("finalizaratendimentoI")=1 and PermitirInformarProcedimentos="1" then
                tamanhocoluna=8
                %>

                <div id="listaProcedimentos" class="col-xs-4" style="height:345px; overflow:auto; overflow-x:hidden;">
                        <%server.Execute("finalizaListaProcedimentos.asp")%>
                </div>
                <%end if%>


            <div class="col-xs-<%=tamanhocoluna%>">
                <% Data = date() %>
                <div id="procedimentosAdicionados">
                    <%server.Execute("finalizaAdicionaProcedimento.asp")%>
                </div>
            </div>
        </div>
		<%
        if req("Origem")="Atendimento" and PermitirInformarProcedimentos="1" then
        %>
        <hr />
        <div class="row">
            <div class="col-md-4"><label for="UsuariosNotificados">Selecione abaixo o(s) usu&aacute;rio(s) que receber&atilde;o a notifica&ccedil;&atilde;o para lan&ccedil;amento da receita ou da guia.</label><br />
                <select multiple="" class=" multisel tag-input-style" id="UsuariosNotificar" name="UsuariosNotificar">
                <%
                set pus = db.execute("select u.*, p.NomeProfissional, f.NomeFuncionario from sys_users as u left join profissionais as p on (p.id=u.idInTable and u.Table='Profissionais' AND p.Ativo='on') left join funcionarios as f on (f.id=u.idInTable and u.Table='Funcionarios' AND f.Ativo='on') order by u.NameColumn, f.NomeFuncionario, p.NomeProfissional")
                while not pus.eof
                    NomeColuna = pus("NameColumn")
                    if not isnull(pus(""&NomeColuna&"")) then
                        %>
                        <option value="|<%=pus("id")%>|"
                        <%if instr(UsuariosNotificar, "|"&pus("id")&"|")>0 then%> selected="selected"<%end if%>><%=pus(""&NomeColuna&"")%> &raquo; <%=pus("Table")%></option>
                        <%
                    end if
                pus.movenext
                wend
                pus.close
                set pus=nothing
                %>
                </select>
            </div>
                        <%'=quickField("multiple", "UsuariosNotificar", "Selecione abaixo o(s) usu&aacute;rio(s) que receber&atilde;o a notifica&ccedil;&atilde;o para lan&ccedil;amento da receita ou da guia TISS.", 12, UsuariosNotificar, "select * from funcionarios where sysActive=1 order by NomeFuncionario", "NomeFuncionario", "")%>
        </div>
        <%
		end if
		%>
    </div>
</form>
<div class="modal-footer no-margin-top">
	<button class="btn btn-sm btn-primary pull-right" type="button" onClick="saveInf(<%= atendimentoID %>)" id="btnSaveInf"><i class="far fa-save"></i>
	<%
    if req("Origem")="Atendimento" then
		if req("Solicitacao")="S" then
			%>
			Solicitar Pagamento / Autorização
			<%
		else
			%>
			Finalizar Atendimento
			<%
		end if
	else
		%>
        Salvar
        <%
	end if
	%>
    </button>
</div>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
function addProc(Acao, ProcedimentoID, ConvenioID, ValorBruto){
	var inc = $('[data-val]:last').attr('data-val');
	if(inc==undefined){inc=0}
	$.post("finalizaAdicionaProcedimento.asp?Acao="+Acao+"&ProcedimentoID="+ProcedimentoID+"&ConvenioID="+ConvenioID+"&ValorBruto="+ValorBruto+"&Row="+inc+"&AtendimentoID=<%=atendimentoID%>", $("#frmFimAtendimento").serialize(), function(data){
	  if(Acao=="I"){
	      if($("[name='Forma']:checked").val() == "P"){
	          $("#fimListaAP").before( data );
	          return ;
	      }
	      <% IF getConfig("calculostabelas") THEN %>
		    let htmlPre = "";
            $("#procedimentosAdicionados table.duplo  tbody tr").each(function(key,tag){
                if($(tag).html().indexOf("Particular") != -1){
                    htmlPre += $(tag)[0].outerHTML;
                }
            });

		    let fimListaAP  = $("#fimListaAP")[0].outerHTML;
		    $("#procedimentosAdicionados table.duplo tbody").html(data+htmlPre+fimListaAP)
		  <% ELSE %>
		    $("#fimListaAP").before( data );
		  <% END IF %>
	  }else if(Acao=="X"){
            let valorInicial = $('#procedimentosAdicionados').attr('data-excluir')
            if (valorInicial == undefined){
                valorInicial= ""
            }else{
                valorInicial+=","
            }
            let excluir =  valorInicial + ProcedimentoID
            $('#procedimentosAdicionados').attr('data-excluir',excluir)
	      if($("#row"+ProcedimentoID+", #row2"+ProcedimentoID).html().indexOf("Particular") != -1){
	            $("#row"+ProcedimentoID+", #row2"+ProcedimentoID).replaceWith('');
                $("#fimListaAP").after( "<input type='hidden' name='Excluir' value='"+ProcedimentoID+"'>" );
                return ;
	      }
	      <% IF getConfig("calculostabelas") THEN %>
	        let htmlPre = "";
	        $("#procedimentosAdicionados table.duplo  tbody tr").each(function(key,tag){
	            if($(tag).html().indexOf("Particular") != -1){
	                htmlPre += $(tag)[0].outerHTML;
	            }
	        });

	      	let fimListaAP  = $("#fimListaAP")[0].outerHTML;
             $("#procedimentosAdicionados table.duplo  tbody").html(data+htmlPre+fimListaAP)
   		     $("#fimListaAP").after( "<input type='hidden' name='Excluir' value='"+ProcedimentoID+"'>" );
          <% ELSE %>
            $("#row"+ProcedimentoID+", #row2"+ProcedimentoID).replaceWith('');
            $("#fimListaAP").after( "<input type='hidden' name='Excluir' value='"+ProcedimentoID+"'>" );
          <% END IF %>
	  }else{
		$("#procedimentosAdicionados").html(data);
	  }
	});
}

function expand(I){
	if($("#div"+I).css("display")=="none"){
		$("#div"+I).slideDown(500);
		$("#chevron"+I).attr("class", "far fa-chevron-up");
	}else{
		$("#div"+I).slideUp(500);
		$("#chevron"+I).attr("class", "far fa-chevron-down");
	}
}


<%
if getConfig("BaixarItensContratadosAoFinalizarAtendimento")=0 or getConfig("NaoExibirModalFinalizacaoAtendimento")=1 or aut("finalizaratendimentoV")=0 then
    %>
    $("#btnSaveInf").click();
    <%
end if
%>
$("#pesquisar").focus();
</script>
