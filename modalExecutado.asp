<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
II = ref("II")
CHK = ref("CHK")
set ai = db.execute("select ii.*, i.CompanyUnitID, i.FormaID, i.ContaRectoID from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID where ii.id="&II)

InvoiceID = ai("InvoiceID")
HoraExecucao = ai("HoraExecucao")
DataExecucao = ai("DataExecucao")
Descricao = ai("Descricao")
CompanyUnitID = ai("CompanyUnitID")
ItemID = ai("ItemID")
FormaID = ai("FormaID")&"_"&ai("ContaRectoID")
if not isnull(HoraExecucao) then HoraExecucao=formatdatetime(HoraExecucao,3) end if
HoraFim = ai("HoraFim")
Associacao = ai("Associacao")
if Associacao=0 then
    Associacao = 5
end if
Executado = ai("Executado")
ProfissionalID = ai("ProfissionalID")
if not isnull(HoraFim) then HoraFim=formatdatetime(HoraFim,3) end if
if Executado="S" then
    ItemExecutadoJaSalvo="S"
    checked = " checked "
else
    set ap = db.execute("select ap.*, a.ProfissionalID, a.Data, a.HoraInicio, a.HoraFim from atendimentosprocedimentos ap left join atendimentos a on a.id=ap.AtendimentoID where a.Data=date(now()) and ap.ProcedimentoID like '"&ItemID&"' and ap.ItemInvoiceID=0")
    if not ap.eof then
        Executado = "S"
        Associacao = 5
        ProfissionalID = ap("ProfissionalID")
        DataExecucao = ap("Data")
        HoraExecucao = ft(ap("HoraInicio"))
        HoraFim = ft(ap("HoraFim"))
        
        autoCalcRepasse = "calcRepasse("&II&"); $('#Executado"&II&"').prop('checked', true);"
        
    end if
end if


NaoPermitirAlterarExecutante=False
MensagemBloqueioExecutante=""
set RepasseSQL = db.execute("SELECT rr.ItemContaAPagar FROM rateiorateios rr WHERE rr.ItemInvoiceID="&II)
if not RepasseSQL.eof then
    if not RepasseSQL.eof then
        NaoPermitirAlterarExecutante=True
        MensagemBloqueioExecutante="Existem repasses consolidados para esta conta. Para alterar por favor desconsolide os repasses."
    end if
end if

if ItemExecutadoJaSalvo="S" AND getConfig("NaoPermitirAlterarExecutante") AND session("Admin")<>1 then
    NaoPermitirAlterarExecutante=True
    MensagemBloqueioExecutante="Não é possível alterar o executante."
end if

PermissaoParaAlterar=True

if getConfig("NaoPermitirAlterarExecutante")=1 and aut("areceberpacienteV")=0 and aut("contasareceberV")=0 and session("table")="profissionais" then
    PermissaoParaAlterar=False
    ProfissionalID=session("idInTable")
    Associacao = 5
    DataExecucao=date()
end if

disabledExecutado =""

if NaoPermitirAlterarExecutante then
    disabledExecutado=" disabled"
end if

if Executado="S" then
    disabledExecutado = disabledExecutado & " required" 
end if

%>

<form method="post" action="" id="frmExecutado">
    <input type="hidden" name="CompanyUnitID" value="<%=CompanyUnitID %>" />
    <input type="hidden" name="FormaID" value="<%=FormaID %>" />
    <input type="hidden" name="ItemID<%=II %>" value="<%=ItemID %>" />
    <input type="hidden" name="InvoiceID" value="<%=InvoiceID %>" />

    <div class="modal-header">
        <h4 class="lighter blue">Dados da Execu&ccedil;&atilde;o
            <div class="widget-toolbar no-border">
                <button class="bootbox-close-button close" id="FecharExecutado" type="button"><i class="far fa-remove"></i></button>
            </div>
        </h4>
    </div>
    <div class="modal-body">
        <div class="row">
            <%
            if NaoPermitirAlterarExecutante then
            %>
<div class="col-md-12">
    <div class="alert alert-warning">
        <strong>Atenção!</strong> <%=MensagemBloqueioExecutante%>
    </div>
</div>
<script >
    $("#btn-save-executado").attr("disabled", true)
</script>
            <%
            end if
            %>

            <%=quickField("simpleCheckbox", "Executado"&II, "Executado", "6", Executado, "", "", ""&disabledExecutado)%>
        </div>
        <br>

        <%
        if PermissaoParaAlterar then
        %>
        <div class="row">
            <div class="col-md-6">
                <label>Executante</label><br />
                <%=simpleSelectCurrentAccounts("ProfissionalID"&II, "5, 8, 2", Associacao&"_"&ProfissionalID, " onchange=""espProfChange("& II &");"" "&disabledExecutado,"")%>

            </div>
            <div id="divEspecialidadeID<%= II %>">
                <%
                if ProfissionalID<> "" then
                    sqlEspecialidades = "select esp.EspecialidadeID id, e.especialidade from (select EspecialidadeID from profissionais where id="& ProfissionalID &" and not isnull(EspecialidadeID) union all	select EspecialidadeID from profissionaisespecialidades where profissionalID="& ProfissionalID &" and not isnull(EspecialidadeID)) esp left join especialidades e ON e.id=esp.EspecialidadeID"
                else
                    sqlEspecialidades = "select * from especialidades order by especialidade"
                end if

                if session("Banco")="clinic6118" then
                    if Executado<>"S" then
                        camposRequired=""
                    else
                        camposRequired=" required empty"
                    end if
                end if
                %>
                <%= quickField("simpleSelect", "EspecialidadeID"&II, "Especialidade", 6, EspecialidadeID, sqlEspecialidades, "especialidade", " no-select2 "&camposRequired&disabledExecutado) %>
            </div>
        </div>
        <%
        else
        %>
<div class="col-md-6">
<span><strong>Executante: </strong> <%=session("nameUser")%></span>
        <input type="hidden" name="EspecialidadeID<%=II%>" value="<%=EspecialidadeID%>">
        <input type="hidden" name="ProfissionalID<%=II%>" value="<%=Associacao&"_"&ProfissionalID%>">
</div>
        <%
        end if
        %>
        <div class="row">
        <%
        if PermissaoParaAlterar then
        %>
            <%= quickField("datepicker", "DataExecucao"&II, "Data da Execu&ccedil;&atilde;o", 6, DataExecucao,"" , "", ""&disabledExecutado) %>
        <%
        else
        %>
<div class="col-md-6">

        <span><strong>Data:</strong><%=DataExecucao%></span>
        <input type="hidden" name="DataExecucao<%=II%>" value="<%=DataExecucao%>">
</div>
        <%
        end if
        %>
            <%= quickField("text", "HoraExecucao"&II, "<i class='far fa-clock-o'></i> In&iacute;cio", 3, HoraExecucao, " input-mask-l-time", "", "") %>
            <%= quickField("text", "HoraFim"&II, "<i class='far fa-clock-o'></i> Fim", 3, HoraFim, " input-mask-l-time", "", "") %>

        </div>
        <div class="row">
                <%= quickField("memo", "Descricao"&II, "Observações", 12, Descricao, "", "", "") %>
        </div>
        <hr />

<div class="row">
    <div class="col-md-12" style="max-height: 250px; overflow-y: scroll">
        <%
        LogsItensInvoiceSQL = renderLogsTable("itensinvoice", II, 0)
        %>
    </div>
</div>

        <div class="row" id="rat<%=II %>">
        <%
		Row = II
		if Executado="S" then
			set rats = db.execute("select rr.*, f.ContaPadrao from rateiorateios rr LEFT JOIN rateiofuncoes f on f.id=rr.FuncaoID where rr.ItemInvoiceID=" & II & " AND rr.Variavel='S'")
			while not rats.eof
                valorGravado = "S"'valor do banco, nao sugerido
				FM = rats("FM")
				Variavel = rats("Variavel")
				ProdutoID = rats("ProdutoID")
				FuncaoID = rats("FuncaoID")
				ContaCredito = rats("ContaCredito")
				ContaPadrao = rats("ContaPadrao")
				ValorUnitario = rats("ValorUnitario")
				Sobre = rats("Sobre")
				Funcao = rats("Funcao")
				Valor = rats("Valor")
				TipoValor = rats("TipoValor")
				Quantidade = rats("Quantidade")
                if FuncaoID<0 then
                    set tp = db.execute("select TabelasPermitidas from procedimentosequipeparticular where id="&FuncaoID*(-1))
                    if tp.eof then
                        TabelasPermitidas = ""
                    else
                        TabelasPermitidas = tp("TabelasPermitidas")
                    end if
                end if
				%>
				<!--#include file="invoiceLinhaRepasse.asp"-->
				<%
			rats.movenext
			wend
			rats.close
			set rats=nothing
		end if
        %>
        </div>
    </div>
    <div class="modal-footer">
        <button id="btn-save-executado" class="btn btn-success btn-sm"><i class="far fa-save"></i> Salvar</button>
    </div>
</form>

<script type="text/javascript">


function calcRepasse(id){
    $.post("invoiceRepasse.asp?Row="+ id +"&InvoiceID=<%=InvoiceID %>", $("#frmExecutado").serialize(), function(data){ $("#rat"+id).html(data) });
 
}

function espProfChange(I){
    $.post("divEspecialidadeII.asp?Change=1&C=6&R="+I, { ProfissionalID: $('#ProfissionalID'+I).val() }, function(data){ $("#divEspecialidadeID"+I).html(data) });
}

$("#frmExecutado").submit(function(){
	$.post("saveExecutado.asp?II=<%=II %>", $("#frmExecutado").serialize(), function(data, status){ eval(data) });
	return false;
});


<% IF aut("agendamentosantigosA")=0  THEN %>
        $(function() {
                var d = new Date();
                 d.setDate(d.getDate()-1);
                 $("input[id^=DataExecucao]").datepicker("setStartDate",d);
                 $("input[id^=DataExecucao]").change(function() {
                   let dataSelecionada = $(this).val().replace(/(\d{2})\/(\d{2})\/(\d{4}).*/, '$3$2$1');
                   let dataAtual = new Date().toLocaleDateString('pt-BR').replace(/(\d{2})\/(\d{2})\/(\d{4}).*/, '$3$2$1');
                   if(dataSelecionada < dataAtual){
                       $(this).val("");
                       $(this).focus();
                   }
                 });
        });
<% END IF %>

$("#FecharExecutado").click(function(){
    $("#pagar").fadeOut();
});

$("#ProfissionalID<%=II%>").change(function(){
    if($(this).val()==""){
        $("#Executado<%=II%>").prop("checked", false);
        $("#ProfissionalID<%=II%>, #DataExecucao<%=II%>").removeAttr("required");
    }else{
        $("#Executado<%=II%>").prop("checked", true);
        $("#ProfissionalID<%=II%>, #DataExecucao<%=II%>").prop("required", true);
        calcRepasse(<%=II%>);
      
    }
});

$("#Executado<%=II%>").click(function(){
    if($(this).prop("checked")==false){
        $("#ProfissionalID<%=II%>").val("").change();
        $("#ProfissionalID<%=II%>, #DataExecucao<%=II%>").removeAttr("required");
    }else{
        $("#ProfissionalID<%=II%>, #DataExecucao<%=II%>").prop("required", true);
    }
});

<%=autoCalcRepasse%>

<!--#include file="jQueryFunctions.asp"-->
</script>
<!--#include file="disconnect.asp"-->