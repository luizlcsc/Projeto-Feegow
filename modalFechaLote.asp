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

set ConvenioSQL = db.execute("SELECT TipoRecebimento, DiasRecebimento FROM convenios WHERE id="&treatvalzero(ConvenioID))

if not ConvenioSQL.eof then
	TipoRecebimento=ConvenioSQL("TipoRecebimento")
    DiasRecebimento=ConvenioSQL("DiasRecebimento")

	DateFormat = split(date(), "/")
	Dia = cint(DateFormat(0))
	Mes = DateFormat(1)
	Ano = DateFormat(2)
	DataPrevisao = CalculaDataPrevisao(DiasRecebimento,TipoRecebimento,Dia,Mes,Ano)
end if

	function CalculaDataPrevisao(DiasRecebimento,TipoRecebimento,Dia,Mes,Ano)
	'seta data atual como padrão
	DataPrevisao = Dia&"/"&Mes&"/"&Ano

	'Verifica se alguma regra é válida e monta a nova data
	select case TipoRecebimento
		case 1 'Dias Corridos
			if DiasRecebimento&"" <> "" then
				if isnumeric(DiasRecebimento) then
					DataPrevisao = DateAdd("d", DiasRecebimento, date())
				end if
			end if
		case 2 'Dia Fixo do Mês Vigente
			if DiasRecebimento&"" <> "" AND  DiasRecebimento > Dia then
				Dia = DiasRecebimento
				if isDate(Dia&"/"&Mes&"/"&Ano) then
					DataPrevisao = Dia&"/"&Mes&"/"&Ano
				end if
			else
				Dia = DiasRecebimento
				if Mes = 12 then
					Mes = 1
				else
					Mes = Mes + 1
				end if
				Ano = Ano
				if isDate(Dia&"/"&Mes&"/"&Ano) then
					if Weekday(Dia&"/"&Mes&"/"&Ano) = 1  then
						DataPrevisao = DateAdd("d", 1, Dia&"/"&Mes&"/"&Ano)
					elseif Weekday(Dia&"/"&Mes&"/"&Ano) = 7 then
						DataPrevisao = DateAdd("d", 2, Dia&"/"&Mes&"/"&Ano)
					else
						DataPrevisao = Dia&"/"&Mes&"/"&Ano
					end if
				end if
			end if
		case 3 'Dia Fixo do Mês Subsequente
			if DiasRecebimento&"" <> "" then
				Dia = DiasRecebimento
				if Mes = 12 then
					Mes = 1
				else 
					Mes = Mes + 1
				end if
				Ano = Ano
				'Pula os finais de semana
				if isDate(Dia&"/"&Mes&"/"&Ano) then
					if Weekday(Dia&"/"&Mes&"/"&Ano) = 1  then
						DataPrevisao = DateAdd("d", 1, Dia&"/"&Mes&"/"&Ano)
					elseif Weekday(Dia&"/"&Mes&"/"&Ano) = 7 then
						DataPrevisao = DateAdd("d", 2, Dia&"/"&Mes&"/"&Ano)
					else
						DataPrevisao = Dia&"/"&Mes&"/"&Ano
					end if
				end if
			end if
		case 4 'Dia Fixo do 3º Mês
			if DiasRecebimento&"" <> "" then
				Dia = DiasRecebimento				
				'Verifica se o mês é Novembro ou Dezembro e seta o ano seguinte caso seja.
				if Mes = 12 then
					Mes = 3
					Ano = Ano + 1
				elseif Mes = 11 then
					Mes = 2
					Ano = Ano + 1
				elseif Mes = 10 then
					Mes = 1
					Ano = Ano + 1
				else
					Mes = Mes + 3
				end if
				'Pula os finais de semana
				if isDate(Dia&"/"&Mes&"/"&Ano) then
					if Weekday(Dia&"/"&Mes&"/"&Ano) = 1  then
						DataPrevisao = DateAdd("d", 1, Dia&"/"&Mes&"/"&Ano)
					elseif Weekday(Dia&"/"&Mes&"/"&Ano) = 7 then
						DataPrevisao = DateAdd("d", 2, Dia&"/"&Mes&"/"&Ano)
					else
						DataPrevisao = Dia&"/"&Mes&"/"&Ano
					end if
				end if
			else
				DataPrevisao = date()
			end if
		case 5 '5º Dia Útil do Mês Subsequente ou do Segundo Mês
			Dia = 0
			DiaUtil = 0
			'Verifica se o mês é Dezembro e seta o ano seguinte caso seja.
			if Mes = 12 then
				Mes = 1
				Ano = Ano + 1
			else
				Mes = Mes + 1
			end if
			'Pega somente dias úteis
			while DiaUtil <= 4
				Dia = Dia + 1
				if Weekday(Dia&"/"&Mes&"/"&Ano) = 1  then
					DiaUtil = DiaUtil
				elseif Weekday(Dia&"/"&Mes&"/"&Ano) = 7 then
					DiaUtil = DiaUtil
				else
					DiaUtil = DiaUtil + 1
				end if
			wend
			if isDate(Dia&"/"&Mes&"/"&Ano) then
				DataPrevisao = Dia&"/"&Mes&"/"&Ano
			end if
		case 6 'Último dia util do mês vigente
			Dia = 1
			Mes=10
			'Inicia no começo do mês seguinte e subtrai até encontrar um dia útil
			if Mes = 12 then
				Mes = 1
				Ano = Ano + 1
			else
				Mes = Mes + 1
			end if
			'Pega somente dias úteis
			DataPrevisao = DateAdd("d", -1, Dia&"/"&Mes&"/"&Ano)
			while Weekday(DataPrevisao) = 1 or Weekday(DataPrevisao) = 7
				DataPrevisao = DateAdd("d", -1, DataPrevisao)
			wend
		case else
			DataPrevisao = Dia&"/"&Mes&"/"&Ano
	end select
	CalculaDataPrevisao = DateValue(DataPrevisao)
end function
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
		<button class="btn btn-success btn-sm"><i class="far fa-save"></i> Fechar este Lote de Guias</button>
		<button type="button" class="btn btn-success btn-sm dropdown-toggle" data-toggle="dropdown">
			<span class="caret"></span>
		</button>
		<ul class="dropdown-menu" role="menu">
			<li><a href="#" onclick="" id="LancaConta"><i class="far fa-plus"></i> Fechar Lote e Lançar no Contas a Receber</a></li>
			<%

			if req("T") = "GuiaConsulta" then
				coluna = "ValorProcedimento"
			elseif req("T") = "GuiaHonorarios" then
				coluna = "ValorPago"
			else
				coluna = "TotalGeral"
			end if

			set g = db.execute("select count(id) Qtd, sum("&coluna&") Total, ConvenioID from tiss"&req("T")&" where id in("&req("guia")&")")

			if not g.eof then
				sqlcontas = " SELECT distinct conta.id, itensinvoice.Descricao,'"&g("Total")&"' as Total, coalesce((select distinct imposto from itensinvoice where InvoiceID = conta.id and imposto = 1),0) temImposto "&_
										" FROM sys_financialinvoices conta "&_
										" LEFT JOIN itensinvoice ON itensinvoice.InvoiceID = conta.id "&_
										" WHERE conta.AccountID="&g("ConvenioID")&" AND conta.AssociationAccountID=6 AND conta.CD='C' AND itensinvoice.Tipo='O' AND itensinvoice.Descricao LIKE 'lote%' AND conta.sysDate > DATE_SUB(CURDATE(), INTERVAL 180 DAY)"
				' response.write(sqlcontas)
				set ContasSQL = db.execute(sqlcontas)
			end if
			while not ContasSQL.eof
				if ContasSQL("temImposto") = 0 then 
			%>
					<li><a href="#" onclick="javascript:geraInvoice('<%=req("T")%>', '<%=fn(g("Total"))%>', '<%=ContasSQL("id")%>')"><i class="far fa-plus"></i> Adicionar a conta: <%=ContasSQL("Descricao")%></a></li>
			<%
				end if
				ContasSQL.movenext
				wend
				ContasSQL.close
				set ContasSQL=nothing
			%>
		</ul>
	
	</div>
    <button class="btn btn-sm btn-default" data-dismiss="modal">
    	Fechar
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