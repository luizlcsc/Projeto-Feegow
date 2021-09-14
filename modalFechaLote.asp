<!--#include file="connect.asp"-->
<form method="post" action="" name="frmModal" id="frmModal">
<%
set ult = db.execute("select Lote from tisslotes order by Lote desc limit 1")
if ult.eof then
	Lote=1
else
	Lote = ult("Lote")+1
end if

ConvenioID=req("ConvenioID")

set ConvenioSQL = db.execute("SELECT DiasRecebimento, DataRecebimentoEspecifico FROM convenios WHERE id="&treatvalzero(ConvenioID))

if not ConvenioSQL.eof then
    DiasRecebimento=ConvenioSQL("DiasRecebimento")
    DataRecebimentoEspecifico=ConvenioSQL("DataRecebimentoEspecifico")

	DateFormat = split(date(), "/")
	Dia = cint(DateFormat(0))

	if DataRecebimentoEspecifico&"" <> "" AND  DataRecebimentoEspecifico > Dia then
		Dia = DataRecebimentoEspecifico
		Mes = DateFormat(1)
		Ano = DateFormat(2)
		if isDate(Dia&"/"&Mes&"/"&Ano) then
			DataPrevisao = Dia&"/"&Mes&"/"&Ano
		end if
	else
		Dia = DataRecebimentoEspecifico
		if DateFormat(1) = 12 then
			Mes = 1
		else 
			Mes = DateFormat(1) + 1
		end if
		Ano = DateFormat(2)
		if isDate(Dia&"/"&Mes&"/"&Ano) then
			DataPrevisao = Dia&"/"&Mes&"/"&Ano
		end if
	end if

    if DiasRecebimento&"" <> "" then
        if isnumeric(DiasRecebimento) then
            DataPrevisao = DateAdd("d", DiasRecebimento, date())
        end if
    end if
end if

%>
	<div class="modal-header">
    	<h4>Fechar Lote</h4>
    </div>
    <div class="modal-body">
    	<div class="row">
           	<%=quickfield("text", "Lote", "N&deg; do Lote", 2, Lote, "text-right", "", "")%>
        	<div class="col-md-3">
            	<label>Refer&ecirc;ncia</label><br />
            	<select class="form-control" name="Mes">
                	<%
					c=0
					while c<12
						c=c+1
						%><option value="<%=c%>"<%if c=month(date()) then%> selected="selected"<%end if%>><%=monthname(c)%></option><%
					wend
					%>
                </select>
            </div>
            <div class="col-md-2">
            	<label>&nbsp;</label><br />
            	<select name="Ano" class="form-control">
                	<%
					c=year(date())-1
					while c<year(date())+2
						%><option value="<%=c%>"<%if c=year(date()) then%> selected="selected"<%end if%>><%=c%></option><%
						c=c+1
					wend
					%>
                </select>
            </div>
            <div class="col-md-4">
            	<label>Ordenar por</label><br />
            	<select name="Ordem" class="form-control">
					<option value="Data">Data do Preenchimento</option>
					<option value="Numero">N&uacute;mero da Guia</option>
					<option value="Paciente">Nome do Paciente</option>
					<option value="Solicitacao">Data da Solicitação</option>
                </select>
            </div>
            <div class="col-md-4">
                <label for="LoteObs">Observações</label>
                <textarea name="Obs" id="LoteObs" class="form-control"></textarea>
            </div>

            <%=quickfield("datepicker", "PrevisaoRecebimento", "Previsão de recebimento ", 3, DataPrevisao, "", "", "")%>

        </div>
    </div>

<div class="modal-footer">
	<div class="btn-group">
		<button class="btn btn-success btn-sm"><i class="fa fa-save"></i> Fechar este Lote de Guias</button>
		<button type="button" class="btn btn-success btn-sm dropdown-toggle" data-toggle="dropdown">
			<span class="caret"></span>
		</button>
		<ul class="dropdown-menu" role="menu">
			<li><a href="#" onclick="" id="LancaConta"><i class="fa fa-plus"></i> Fechar Lote e Lançar no Contas a Receber</a></li>
			<%

			if req("T") = "GuiaConsulta" then
				coluna = "ValorProcedimento"
			elseif req("T") = "GuiaHonorarios" then
				coluna = "Procedimentos"
			else
				coluna = "TotalGeral"
			end if

			set g = db.execute("select count(id) Qtd, sum("&coluna&") Total, ConvenioID from tiss"&req("T")&" where id in("&req("guia")&")")

			if not g.eof then
				sqlcontas = " SELECT distinct conta.id, itensinvoice.Descricao,'"&g("Total")&"' as Total "&_
										" FROM sys_financialinvoices conta "&_
										" LEFT JOIN itensinvoice ON itensinvoice.InvoiceID = conta.id "&_
										" LEFT JOIN sys_financialmovement mov ON mov.InvoiceID = conta.id "&_
										" WHERE conta.AccountID="&g("ConvenioID")&" AND conta.AssociationAccountID=6 AND conta.CD='C' AND itensinvoice.Tipo='O' AND itensinvoice.Descricao LIKE 'lote%' AND (mov.ValorPago=0 OR mov.ValorPago IS NULL) AND conta.sysDate > DATE_SUB(CURDATE(), INTERVAL 180 DAY)"
				' response.write(sqlcontas)
				set ContasSQL = db.execute(sqlcontas)
			end if
			while not ContasSQL.eof
			%>
					<li><a href="#" onclick="javascript:geraInvoice('<%=req("T")%>', '<%=fn(g("Total"))%>', '<%=ContasSQL("id")%>')"><i class="fa fa-plus"></i> Adicionar a conta: <%=ContasSQL("Descricao")%></a></li>
			<%
				ContasSQL.movenext
				wend
				ContasSQL.close
				set ContasSQL=nothing
			%>
		</ul>
	
	</div>
    <button class="btn btn-sm btn-default" data-dismiss="modal">
    	<i class="fa fa-remove"></i> Cancelar</button>
    </button>
</div>
</form>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
$("#frmModal").submit(function(){
	$.ajax({
		   type:"POST",
		   url:"saveLote.asp?Acao=Inserir&T=<%=req("T")%>&ConvenioID=<%=req("ConvenioID")%>",
		   data:$("#frmModal, #guias").serialize(),
		   success:function(data){
			   eval(data);
		   }
		   });
	return false;
});

$("#LancaConta").click(function(){
	$.ajax({
		   type:"POST",
		   url:"saveLote.asp?Acao=Inserir&T=<%=req("T")%>&ConvenioID=<%=req("ConvenioID")%>&CriaInvoice=1",
		   data:$("#frmModal, #guias").serialize(),
		   success:function(data){
			   eval(data);
		   }
		   });
	return false;
});
</script>