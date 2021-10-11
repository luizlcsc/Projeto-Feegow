<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<%posModalPagar="fixed" %>
<!--#include file="invoiceEstilo.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))

if not reg.eof then
	if reg("sysActive")=1 then
		DataEmissao = reg("DataEmissao")
		UnidadeID = reg("UnidadeID")
        if not isnull(reg("ConvenioID")) and reg("ConvenioID")<>0 then
            set convBloq=db.execute("select BloquearAlteracoes from convenios where id="&reg("ConvenioID"))
            if not convBloq.eof then
                if convBloq("BloquearAlteracoes")=1 then
                %>
                <script type="text/javascript">
                    $(document).ready(function(){
                        $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #_NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #_UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", true);
                        //proc -> TabelaID, CodigoProcedimento, Descricao, ViaID, TecnicaID, ValorUnitario
                        //prof -> CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO
                    });
                </script>
                <%
                end if
            end if
        end if
    	Procedimentos = reg("Procedimentos")
        StatusID = reg("StatusID")
	else
        StatusID = 1
		DataEmissao = date()
		db_execute("delete from procedimentoscirurgia where GuiaID="&reg("id"))
		db_execute("delete from profissionaiscirurgia where GuiaID="&reg("id"))
'		set procs = db.execute("select id from procedimentoscirurgia where GuiaID="&reg("id"))
'		while not procs.eof
'			db_execute("delete from rateiorateios rr where rr.Temp=1 and ItemGuiaID="&procs("id"))
'		procs.movenext
'		wend
'		procs.movenext
'		set procs=nothing
		db_execute("update agendacirurgica set Procedimentos=0 where id="&reg("id"))
		if cdate(formatdatetime(reg("sysDate"),2))<date() then
			db_execute("update agendacirurgica set sysDate=NOW() where id="&reg("id"))
		end if
		UnidadeID = session("UnidadeID")
        Procedimentos = 0
	end if

	TotalProcedimentos = 0

	PacienteID = reg("PacienteID")
	CNS = reg("CNS")
	ConvenioID = reg("ConvenioID")
	PlanoID = reg("PlanoID")
	RegistroANS = reg("RegistroANS")
	NGuiaPrestador = reg("NGuiaPrestador")
	NGuiaOperadora = reg("NGuiaOperadora")
	Senha = reg("Senha")
	NumeroCarteira = reg("NumeroCarteira")
	AtendimentoRN = reg("AtendimentoRN")
	AtendimentoRN = reg("AtendimentoRN")
	NGuiaSolicitacaoInternacao = reg("NGuiaSolicitacaoInternacao")
    Contratado = reg("Contratado")
	CodigoNaOperadora = reg("CodigoNaOperadora")
	CodigoCNES = reg("CodigoCNES")
	ContratadoLocalCodigoNaOperadora = reg("ContratadoLocalCodigoNaOperadora")
	ContratadoLocalNome = reg("ContratadoLocalNome")
    LocalExternoID = reg("LocalExternoID")
	ContratadoLocalCNES = reg("ContratadoLocalCNES")
	DataInicioFaturamento = reg("DataInicioFaturamento")
	DataFimFaturamento = reg("DataFimFaturamento")
	Observacoes = reg("Observacoes")
    DataEmissao = reg("DataEmissao")
    Hora = reg("Hora")
    rdValorPlano = reg("rdValorPlano")
    Valor = reg("Valor")


	'identificadorBeneficiario = reg("identificadorBeneficiario")


	if reg("sysActive")=0 and isnumeric(ConvenioID) then
		set maiorGuia = db.execute("select cast(NGuiaPrestador as signed integer)+1 as NGuiaPrestador from agendacirurgica where not isnull(NGuiaPrestador) and NGuiaPrestador>0 and ConvenioID like '"&ConvenioID&"' order by cast(NGuiaPrestador as signed integer) desc limit 1")
		if maiorGuia.eof then
			NGuiaPrestador = 1
		else
			if not isnull(maiorGuia("NGuiaPrestador")) then
				'if len(NGuiaPrestador)<10 then
					NGuiaPrestador = maiorGuia("NGuiaPrestador")
				'else
				'	NGuiaPrestador = ""
				'end if
			else
				NGuiaPrestador = 1
			end if
		end if
	end if
end if
%>
<script type="text/javascript">
    $(".crumb-active a").html("Agenda Cirúrgica");
    $(".crumb-icon a span").attr("class", "far fa-medkit");
</script>

<form id="AgendaCirurgica" action="" method="post">
    <div class="row">
        <div class="col-md-8 ">
        </div>
        <%=quickField("simpleSelect", "StatusID", "Status", 2, StatusID, "select * from agendacirurgicastatus order by NomeStatus", "NomeStatus", " no-select2 ")%>
        <%=quickField("empresa", "UnidadeID", "Unidade", 2, UnidadeID, "", "", "")%>
    </div>
    <br>
    <input type="hidden" name="tipo" value="AgendaCirurgica" />

    <div class="admin-form theme-primary">
       <div class="panel heading-border panel-primary">
            <div class="panel-body">

                <input type="hidden" name="tipo" value="GuiaSADT" />
                <input type="hidden" name="GuiaID" value="<%=req("I")%>" />

                <div class="section-divider mt20 mb40">
                    <span> Dados do Benefici&aacute;rio </span>
                </div>

                <div class="row">
                <div class="col-md-3"><%= selectInsert("Nome", "gPacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""tissCompletaDados(1, this.value);""", "required", "") %></div>

                <div class="col-md-3 pt25">
                    <span class="radio-custom"><input type="radio" id="rdValorPlanoV" name="rdValorPlano" value="V" <% if rdValorPlano="V" then response.write(" checked ") end if %> /><label for="rdValorPlanoV">Particular</label></span>
                    <span class="radio-custom"><input type="radio" id="rdValorPlanoP" name="rdValorPlano" value="P" <% if rdValorPlano="P" then response.write(" checked ") end if %> /><label for="rdValorPlanoP">Convênio</label></span>
                </div>

                <%= quickField("simpleSelect", "gConvenioID", "Conv&ecirc;nio", 2, ConvenioID, "select * from Convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", "") %>
                <div class="col-md-2 <%= hiddenP %>" id="tissplanosguia">
                    <!--#include file="tissplanosguia.asp"-->
                </div>
                <%= quickField("text", "Senha", "Senha", 2, Senha, "", "", "") %>
                <%= quickfield("currency", "Valor", "Valor", 2, fn(Valor), "", "", "") %>
                <input type="hidden" id="NumeroCarteira" name="NumeroCarteira" value="<%= NumeroCarteira %>" />
                <input type="hidden" id="RegistroANS" name="RegistroANS" value="<%= RegistroANS %>" />
                <input type="hidden" name="identificadorBeneficiario" value="<%=identificadorBeneficiario%>" />
            </div>
            <br />

            <div class="section-divider mt20 mb40">
                <span> Dados do Contratado </span>
            </div>

            <div class="row">
                <%= quickField("text", "ContratadoLocalCodigoNaOperadora", "C&oacute;digo na Operadora", 2, ContratadoLocalCodigoNaOperadora, "", "", "") %>
                <input type="hidden" id="ContratadoLocalNome" value="<%=ContratadoLocalNome%>"/>
                <%= quickField("simpleSelect", "LocalExternoID", "Nome do Hospital/Local", 7, LocalExternoID, "select id, nomelocal from locaisexternos where sysActive=1 order by nomelocal", "nomelocal", " empty="""" required=""required""") %>
                <%= quickField("text", "ContratadoLocalCNES", "C&oacute;digo CNES", 2, ContratadoLocalCNES, "", "", "") %>
                <%= quickField("datepicker", "DataEmissao", "Data", 2, DataEmissao, "", "", " required ") %>
                <%= quickField("timepicker", "Hora", "Hora", 2, reg("Hora"), "", "", "") %>
            </div>


            <div class="section-divider mt20 mb40">
                <span> Dados da cirurgia </span>
            </div>

            <div class="row">
                <div class="col-md-12" id="procedimentoscirurgia">
                    <%server.Execute("procedimentoscirurgia.asp")%>
                </div>
            </div>

            <div class="section-divider mt20 mb40">
                <span> Equipe médica  </span>
            </div>

            <div class="row">
                <div class="col-md-12" id="profissionaiscirurgia">
                    <%server.Execute("profissionaiscirurgia.asp")%>
                </div>
            </div>

            <div class="section-divider mt20 mb40">
                <span> Outras Despesas </span>
            </div>

            <div class="row">
                <div class="col-md-12" id="acoutrasdespesas">
                    <%server.Execute("acoutrasdespesas.asp")%>
                </div>
            </div>

            <br />
            <div class="row">
                <%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, Observacoes, "", "", "") %>
                <input type="hidden" id="vProcedimentos" name="vProcedimentos" value="<%= Procedimentos %>" />
            </div>


            <br />
            <div class="clearfix form-actions no-margin">
                <button class="btn btn-primary btn-md"><i class="far fa-save"></i>Salvar</button>
            </div>
        </div>
    </div>
</div>
</form>

<script type="text/javascript">
function tissCompletaDados(T, I){
	$.ajax({
		type:"POST",
		url:"tissCompletaDados.asp?I="+I+"&T="+T+"&Part="+$("#rdValorPlanoV").prop("checked"),
		data:$("#AgendaCirurgica").serialize(),
		success:function(data){
			eval(data);
		}
	});
}
    $("#gConvenioID, #UnidadeID").change(function(){
        tissCompletaDados("Convenio", $("#gConvenioID").val());
    });

    $("#Contratado, #UnidadeID").change(function(){
        //	    alert(1);
        tissCompletaDados("Contratado", $(this).val());
    });

    $("#ContratadoSolicitanteID").change(function(){
        tissCompletaDados("ContratadoSolicitante", $(this).val());
    });

    $("#LocalExternoID").change(function(){
        tissCompletaDados("LocalExterno", $(this).val());
    });


$("#AgendaCirurgica").submit(function(){
	$.ajax({
		type:"POST",
		url:"SaveAgendaCirurgica.asp?Tipo=Honorarios&I=<%=req("I")%>",
		data:$("#AgendaCirurgica").serialize(),
		success:function(data){
			eval(data);
		}
	});
	return false;
});
/*
	function itemCirurgia(T, I, II){
	    $("#modal-table").modal('show');
	    $.ajax({
	        type:"POST",
	        url:"modalCirurgica.asp?T="+T+"&I="+I+"&II="+II,
	        data:$("#AgendaCirurgica").serialize(),
	        success:function(data){
	            $("#modal").html(data);
	        }
	    });
	}

function itemCirurgia(T, I, II){
	$("#pagar").fadeIn();
	$.ajax({
	    type:"POST",
	    url:"modalCirurgica.asp?T="+T+"&I="+I+"&II="+II,
	    data:$("#AgendaCirurgica").serialize(),
	    success:function(data){
	        $("#pagar").html(data);
	    }
	});
}*/

function itemCirurgia(T, I, II, A){
    $("[id^="+T+"]").fadeOut();
    $("[id^="+T+"]").html('');
    $("[id^=l"+T+"]").fadeIn();
    if(A!='Cancela'){
	    $("#l"+T+II).fadeOut();
	    $("#"+T+II).fadeIn();
	    $("#"+T+II).removeClass('hidden');
	    $("#"+T+II).html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
	    $.ajax({
	        type:"POST",
	        url:"modalCirurgica.asp?T="+T+"&I="+I+"&II="+II,
	        data:$("#AgendaCirurgica").serialize(),
	        success:function(data){
	            $("#"+T+II).html(data);
	        }
	    });
	}
}

function atualizaTabela(D, U){
	$.ajax({
	   type:"GET",
	   url:U,
	   success:function(data){
		   $("#"+D).html(data);
		   tissRecalcAgendaCirurgica('Recalc');
	   }
   });
}


function tissplanosguia(ConvenioID){
	$.ajax({
		type:"POST",
		url:"chamaTissplanosguia.asp?ConvenioID="+ConvenioID,
		data:$("#AgendaCirurgica").serialize(),
		success: function(data){
			$("#tissplanosguia").html(data);
		}
	})
}

function tissRecalcAgendaCirurgica(Action){
	$.ajax({
		type:"POST",
		url:"tissRecalcAgendaCirurgica.asp?I=<%=req("I")%>&Action="+Action,
		data:$("#AgendaCirurgica").serialize(),
		success: function(data){
		    $("#divTotais").html(data);
		}
	});
}

function tc(T){
	if(T=="I"){
		$("#spanContratadoE").css("display", "none");
		$("#spanContratadoI").css("display", "block");
	}else{
		$("#spanContratadoE").css("display", "block");
		$("#spanContratadoI").css("display", "none");
	}
}
function tps(T){
	if(T=="I"){
		$("#spanProfissionalSolicitanteE").css("display", "none");
		$("#spanProfissionalSolicitanteI").css("display", "block");
	}else{
		$("#spanProfissionalSolicitanteE").css("display", "block");
		$("#spanProfissionalSolicitanteI").css("display", "none");
	}
}

<%if trocaConvenioID<>"" then%>
    $("#gConvenioID").val("<%=trocaConvenioID%>");
tissCompletaDados("Convenio", $("#gConvenioID").val());
<%end if%>

function autorizaProcedimentos(procID){
    $(".btn-warning [data-value="+procID+"]").prop('disabled',true);
    $.post("tiss/solicita.php?I=<%=req("I")%>", $("#AgendaCirurgica").serialize() + "&procID="+procID+"&db=<%=session("Banco")%>" + "&ContratadoSolicitante="+$("#ContratadoSolicitanteID option:selected").text() + "&ProfissionalSolicitante=" + $("#ProfissionalSolicitanteID option:selected").text() + "&ContratadoExecutante=" + $("#Contratado option:selected").text(), function(data){
        //    eval(data);
        data = JSON.parse(data);
        if(data.response == '1'){
            $(".btn-warning [data-value="+procID+"]").prop('disabled',false);
            alert('Autorizado');
        }else{
            alert('Glosado');
        }
    });
}

$('#IdentificadorBeneficiario').keydown(function(e) {
    if(e.which == 10 || e.which == 13){
        return false;
    }
});


<%
if drCD<>"" then
    response.write(drCD)
    end if
    %>


        function rdvp() {
            if ($("#rdValorPlanoV").prop("checked")==true) {
                $("#qfgconvenioid, #tissplanosguia, #qfsenha").addClass("hidden");
                $("#qfvalor").removeClass("hidden");
            } else {
                $("#qfgconvenioid, #tissplanosguia, #qfsenha").removeClass("hidden");
                $("#qfvalor").addClass("hidden");
            }
        }

$("input[name=rdValorPlano]").change(function () { rdvp() });

rdvp();


<!--#include file="JQueryFunctions.asp"-->
</script>