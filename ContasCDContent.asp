<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%

session("ccDe") = ref("De")
session("ccAte") = ref("Ate")
session("ccPagto") = ref("Pagto")
session("ccCompanyUnitID") = ref("CompanyUnitID")
session("ccCategoriaID") = ref("CategoriaID")
session("ccAccountID") = ref("AccountID")
session("ccNotaFiscal") = ref("NotaFiscal")
session("ccAccountAssociation") = ref("AccountAssociation")

geraRecorrente(0)

if req("X")<>"" then
    PodeApagar = True

    if req("T")="C" then
        set RecursosAdicionaisSQL = db.execute("SELECT RecursosAdicionais FROM sys_config WHERE id=1")

        if not RecursosAdicionaisSQL.eof then
            RecursosAdicionais=RecursosAdicionaisSQL("RecursosAdicionais")

            if instr(RecursosAdicionais, "|NFe|") and session("Admin")=0 then

                set NotaEmitidaSQL = db.execute("SELECT id FROM nfe_notasemitidas WHERE InvoiceID="&req("X")&" AND Situacao IN (1)")

                if not NotaEmitidaSQL.eof then
                    %>
    <script >
    showMessageDialog("Já existe uma Nota Fiscal emitida para esta conta. Caso queira excluir esta conta, favor realizar o cancelamento.");
    </script>
    <%
                PodeApagar = False
                end if
            end if
        end if

        set RepasseConsolidadoSQL = db.execute("SELECT ii.id, rr.ItemContaAPagar FROM itensinvoice ii INNER JOIN rateiorateios rr ON rr.ItemInvoiceID=ii.id WHERE ii.InvoiceiD='"&req("X")&"'")
        if not RepasseConsolidadoSQL.eof then

            if isnull(RepasseConsolidadoSQL("ItemContaAPagar")) then
                db.execute("DELETE FROM rateiorateios WHERE ItemInvoiceID="&RepasseConsolidadoSQL("id")&" AND ItemContaAPagar IS NULL")
            else
                %>
<script >
                showMessageDialog("Existe um repasse para esta conta. Para excluir a conta, desconsolide o repasse.");
</script>
                <%

                PodeApagar = False
            end if

        end if
    end if
    if PodeApagar then
        'gerar o log
        set iInvoice = db.execute("select * from sys_financialinvoices WHERE id="& req("X"))
        columns = "|AccountID|AssociationAccountID|Value|Tax|CompanyUnitID|TabelaID|"
        'oldValues = "|^"&iInvoice("AccountID")&"|^"&iInvoice("AssociationAccountID")&"|^"&iInvoice("Value")&"|^"&iInvoice("Tax")&"|^"&iInvoice("CompanyUnitID")&"|^"&iInvoice("TabelaID")&"|"
        'call createLog("X", req("X"), "sys_financialinvoices", columns, oldValues, "","")
        db_execute("delete from sys_financialinvoices where id="&req("X"))
        set vcaII = db.execute("select id from itensinvoice WHERE InvoiceID="& req("X"))
        while not vcaII.eof
            db_execute("update rateiorateios set ItemContaAPagar=NULL WHERE ItemContaAPagar="& vcaII("id"))
            db_execute("update rateiorateios set ItemContaAReceber=NULL WHERE ItemContaAReceber="& vcaII("id"))
        vcaII.movenext
        wend
        vcaII.close
        set vcaII=nothing
        db_execute("delete from itensinvoice where InvoiceID="& req("X"))
        db_execute("UPDATE propostas SET InvoiceID=null, StaID=3 WHERE InvoiceID="&req("X"))
        db_execute("UPDATE solicitacao_compra SET InvoiceID=null WHERE InvoiceID="&req("X"))
        db_execute("delete from sys_financialmovement where InvoiceID="&req("X"))
        db_execute("delete from tissguiasinvoice where InvoiceID="&req("X"))

        'Apagar a devolução
        set devolucao = db.execute("select d.invoiceID, group_concat(di.itensInvoiceID) as itensIds from devolucoes d INNER JOIN devolucoes_itens di ON di.devolucoesID=d.id WHERE d.invoiceAPagarID="& req("X"))
        if not devolucao.eof then
            db_execute("update devolucoes SET sysActive = -1 WHERE invoiceAPagarID = "&req("X"))
            InvoiceIDDevolucao = devolucao("invoiceID")
            itensIds = devolucao("itensIds")

            if itensIds&"" <> "" then
                db_execute("update itensinvoice set Executado = 'S' WHERE InvoiceID in ("& InvoiceIDDevolucao &") and id in ("& itensIds &") AND Executado = 'C' AND ProfissionalID > 0 ")
                db_execute("update itensinvoice set Executado = '' WHERE InvoiceID in ("& InvoiceIDDevolucao &") and id in ("& itensIds &") AND Executado = 'C' AND ( ProfissionalID = 0 OR ProfissionalID is null) ")
            end if
        end if
    end if


    if getConfig("ListarAutomaticamenteContas")="0" then
        Response.End
    end if
end if

c=0
Total=0
GranTotalPago=0
TotalVencido = 0
TotalAVencer = 0

CD = req("T")

if CD="C" then
	TabelaCategoria = "sys_financialincometype"
else
	TabelaCategoria = "sys_financialexpensetype"
end if
%>

<div class="row">
  <div class="col-md-12">
	<table class="table table-striped table-bordered table-hover">
	<thead>
		<tr class="success">
		    <%
		    if session("Banco")="clinic5459" and CD="C" then
		    %>
		    <th>Fatura</th>
		    <th>Envio</th>
		    <%
		    end if

		    if CD="D" then
		    %>
			<th><input type="checkbox" class="conta-a-pagar-checkbox-todas" value="" id="selecionar-todas-as-contas" title="Selecionar todas"></th>
			<%
			end if
			%>
			<th>Data</th>
			<th>Conta</th>
			<th>Descri&ccedil;&atilde;o</th>
			<th>Nota Fiscal</th>
            <th>Valor</th>
			<th>Pago</th>
			<th width="1%"></th>
		</tr>
	</thead>
	<%
	Balance = 0
	linhas = 0
	ExibiuPrimeiraLinha = "N"
	SaldoAnteriorFim = 0

	if ref("NotaFiscal")<>"" then
	    sqlNFe = " AND i.nroNFe="&ref("NotaFiscal")
	end if

	if ref("CompanyUnitID")<>"" then
		sqlUN = " AND i.CompanyUnitID IN("& replace(ref("CompanyUnitID"), "|", "") &") "
	end if

	if ref("AccountID")<>"" and instr(ref("AccountID"), "_") then
		splAcc = split(ref("AccountID"), "_")
		sqlAccount = " AND i.AssociationAccountID="&splAcc(0)&" AND i.AccountID="&splAcc(1)&" "
	end if

	if ref("Pagto")="Q" then
		sqlPagto = " AND FLOOR(m.Value)<=FLOOR(m.ValorPago) "
	elseif ref("Pagto")="N" then
		sqlPagto = " AND ((FLOOR(m.Value)>FLOOR(m.ValorPago) OR isnull(m.ValorPago)) AND m.Value>0)"
	end if

	if CD="D" then
        idUser = session("User")
        set regraspermissoes = db.execute("SELECT REPLACE(limitarcontaspagar, '|', '') AS limitarcontaspagar, IF( Permissoes like '%[%', SUBSTRING_INDEX(SUBSTRING_INDEX(Permissoes, '[', -1), ']', 1), '') RegraUsuario FROM sys_users WHERE id ="&idUser)
        if not regraspermissoes.eof then
            OcultarCategorias = regraspermissoes("limitarcontaspagar")
            RegraUsuario = regraspermissoes("RegraUsuario")
            set limitarCategoria = db.execute("SELECT limitarcontaspagar FROM regraspermissoes WHERE id = "&treatvalzero(RegraUsuario))
            if not limitarCategoria.eof then
                OcultarCategorias = limitarCategoria("limitarcontaspagar")
            end if
            if OcultarCategorias&"" <> "" then
                OcultarCategorias = replace(OcultarCategorias, "|","")
                sqlOcultarCategorias = " AND ii.CategoriaID NOT IN ("&OcultarCategorias&")"
            end if
        end if
    end if

	if (ref("CategoriaID")<>"" and isnumeric(ref("CategoriaID")) and ref("CategoriaID")<>"0") or sqlOcultarCategorias<>""  then
		lfCat = " LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id  "
		lfCatFixa = " LEFT JOIN itensinvoicefixa ii ON ii.InvoiceID=f.id "

		if ref("CategoriaID")<>"" and isnumeric(ref("CategoriaID")) and ref("CategoriaID")<>"0" then
		    sqlCat = " AND ii.CategoriaID="&ref("CategoriaID")&" "
        end if
		gpCat = " GROUP BY m.id "
		gpCatFixa = " GROUP BY f.id "

		sqlCat = sqlCat&sqlOcultarCategorias
	end if

        response.Buffer

    leftFiltroNFeStatus = " LEFT JOIN nfe_notasemitidas nfe ON nfe.InvoiceID=i.id AND nfe.Situacao=1 "

    if ref("NotaFiscalStatus")<>"" then
        SituacaoNFe = ref("NotaFiscalStatus")
        if ref("NotaFiscalStatus")="0" then
            SituacaoNfe = " != 1 "
        else
            SituacaoNfe = "= "&SituacaoNFe
        end if
        sqlFiltroNFeStatus = " AND (nfe.situacao "&SituacaoNFe

        if ref("NotaFiscalStatus")="1" then
            sqlFiltroNFeStatus= sqlFiltroNFeStatus&" OR i.nroNFe is not null"
        end if

        if ref("NotaFiscalStatus")="0" then
            sqlFiltroNFeStatus= " AND (i.nroNFe IS NULL AND (nfe.situacao IS NULL OR nfe.situacao!=1)"
        end if

        sqlFiltroNFeStatus=sqlFiltroNFeStatus&")"
    end if

    if ref("TabelaID")<>"" then
        sqlTabela = " AND i.TabelaID="&ref("TabelaID")
    end if

    if ref("AccountAssociation")<>"" then
        sqlAccountAssociation = " AND i.AssociationAccountID IN ("& replace(ref("AccountAssociation"), "|", "") &") "
        sqlAccountAssociationFixa = " AND f.AssociationAccountID IN ("& replace(ref("AccountAssociation"), "|", "") &") "
    end if
    sqlMov = "select i.AccountID ContaID, i.AssociationAccountID Assoc, i.CompanyUnitID UnidadeID, IFNULL(nfe.numeronfse, i.nroNFe) nroNFe, ifnull(m.Value, 0) Value, m.InvoiceID, m.id, m.Name, m.Date, ifnull(m.ValorPago, 0) ValorPago, m.Obs, i.sysDate, (select count(id) from arquivos where MovementID=m.id) anexos, "&_
             "(SELECT COUNT(*) FROM boletos_emitidos WHERE boletos_emitidos.InvoiceID = m.InvoiceID and boletos_emitidos.DueDate > now() and StatusID = 1) as boletos_abertos, "&_
             "(SELECT COUNT(*) FROM boletos_emitidos WHERE boletos_emitidos.InvoiceID = m.InvoiceID and now() > boletos_emitidos.DueDate and StatusID <> 3) as boletos_vencidos, "&_
             "(SELECT COUNT(*) FROM boletos_emitidos WHERE boletos_emitidos.InvoiceID = m.InvoiceID and StatusID  = 3) as boletos_pagos "&_
             " ,i.Rateado FROM sys_financialMovement m left join sys_financialinvoices i on i.id=m.InvoiceID "& lfCat & leftFiltroNFeStatus &" WHERE m.Type='Bill' AND m.Date BETWEEN "&mydatenull(ref("De"))&" AND "&mydatenull(ref("Ate"))&" AND m.CD='"&CD&"' AND i.sysActive=1 "& sqlUN & sqlNFe & sqlAccount & sqlPagto & sqlCat & sqlApenasRepasse & sqlFiltroNFeStatus & sqlTabela & sqlAccountAssociation & gpCat &" order by m.Date,m.id"


	set mov = db.execute( sqlMov )
	while not mov.eof

        response.Flush()

		Valor = mov("Value")
		ValorPago = mov("ValorPago")
		Descricao = ""
		SaldoAnterior = Balance
		Conta = accountName(mov("Assoc"), mov("ContaID"))

        if mov("Assoc")=3 and aut("pacientesV")=1 then
            Conta = "<a href='./?P=Pacientes&Pers=1&I="& mov("ContaID") &"' target='_blank'>"& Conta &"</a>"
        end if
        if session("Banco")="clinic5459" and CD="C" then
            Conta = Conta & "<code><a href='./?P=Score&Pers=1&I="& mov("ContaID") &"' target='_blank'>SCORE</a></code>"
        end if

		linkBill = "./?P=invoice&I="&mov("InvoiceID")&"&A=&Pers=1&T="&CD
		PagoSta=""

		Boleto = ""

		IF (mov("boletos_abertos") > "0") THEN
           Boleto = " <i class='fa fa-barcode text-primary'></i> "
		END IF

		IF (mov("boletos_vencidos") > "0") THEN
           Boleto = " <i class='fa fa-barcode text-danger'></i> "
        END IF

        if isnull(ValorPago) then
            ValorPago=0
        end if


		if formatnumber(Valor,2)=formatnumber(ValorPago,2) or ValorPago+0.02 > Valor then
		    PagoSta = "S"
			Paid = "<i class='fa fa-check text-success' title='Quitado'></i>"
        elseif Valor > ValorPago and ValorPago>0 then
            PagoSta="N"
            Paid = "<i class='glyphicon glyphicon-warning-sign text-warning' title='Pago parcialmente'></i>"
		else
            if mov("Date")>date() then
    			Paid = ""
                TotalAVencer = TotalAVencer + (Valor-ValorPago)
            else
                PagoSta="N"
                Paid = "<i class='fa fa-exclamation-circle text-danger' title='Vencido'></i>"
                TotalVencido = TotalVencido + (Valor-ValorPago)
            end if
		end if

		c=c+1
		Total = Total+Valor
		GranTotalPago = GranTotalPago+ValorPago
        Devedor = Valor-ValorPago


		cItens = 0
		Descricao = ""
		set itens = db.execute("select id,Tipo,ItemID,Descricao,Quantidade,CategoriaID,Executado from itensinvoice where InvoiceID="&mov("InvoiceID"))
		CategoriaItem=0
		Mostra=True
        ItemCancelado = false
		while not itens.eof

		    IF NOT ItemCancelado THEN
		        if  itens("Tipo")="S"  then
		            ItemCancelado = itens("Executado") = "C"
		        end if
		    END IF

		    CategoriaItem = itens("CategoriaID")
			if itens("Tipo")="S" then
				set proc = db.execute("select id, NomeProcedimento from procedimentos where id="&itens("ItemID"))
				if not proc.eof then
					Descricao = Descricao & "; " & left(proc("NomeProcedimento"), 35)
				end if
			elseif itens("Tipo")="M" then
				set proc = db.execute("select id, NomeProduto from produtos where id="&itens("ItemID"))
				if not proc.eof then
					Descricao = Descricao & "; " & left(proc("NomeProduto"), 35)
				end if
			elseif itens("Tipo")="O" then
				Descricao = Descricao & "; " & left(itens("Descricao"), 35)

                if aut("|repassesV|") and aut("|contasapagarV|")=0 and CD="D" then
                    if instr(lcase(itens("Descricao")), "repasse de")=0 then
                        Mostra =False
                    end if
                end if
			end if
			if itens("Quantidade")>1 then
				Descricao = Descricao &" ("&itens("Quantidade")&")"
			end if
			cItens = cItens+1
		itens.movenext
		wend
		itens.close
		set itens=nothing
'		if cItens>1 then
'			Descricao = cItens&" itens"
'		end if
		if len(Descricao)>1 then
			Descricao = right(Descricao, len(Descricao)-2)
		end if
		if isnull(Valor) then
			Valor = 0
		end if
        Anexos = ccur(mov("Anexos"))
        IconeAnexos = ""
        if Anexos>0 then
            IconeAnexos = "<span class='badge badge-system'><i class='fa fa-paperclip bigger-140'></i> "& Anexos &"</span>"
        end if

		if Mostra then
		%>
		<tr>
		    <%
		    if session("Banco")="clinic5459" and CD="C" then
		    if CategoriaItem<>"173" and (CategoriaItem="101" or CategoriaItem="167") and (PagoSta<>"S") then
		        VenctoOriginal = " ("&mov("sysDate")&")"
                set FaturaSQL = db.execute("SELECT f.id, f.Total FROM cliniccentral.faturas f LEFT JOIN cliniccentral.licencas l ON l.id = f.LicencaID WHERE l.Cliente="& mov("ContaID")&" AND f.Vencimento BETWEEN "& mydatenull(ref("De")) &" AND "& mydatenull(ref("Ate")))
                if not FaturaSQL.eof then
                    FaturaGerada= "<span class='label label-system'> R$ "& fn(FaturaSQL("Total"))&VenctoOriginal&"</span>"
                else
                    CorAlerta = "warning"
                    if mov("Date") <= dateadd("d",5,date()) then
                        CorAlerta = "danger"
                    end if
                    FaturaGerada = "<span class='label label-"&CorAlerta&"'> Não gerada"&VenctoOriginal&" </span>"
                end if
            elseif CategoriaItem="173" then
                FaturaGerada = "<span class='label label-default'> Versão antiga"&VenctoOriginal&" </span>"
            else
                FaturaGerada = ""
            end if
            cc = ""
            'pra ver se pagamento é em cartao '-'
            if not isnull(mov("ContaID")) then
                set PacienteSQL = db.execute("SELECT Religiao FROM pacientes WHERE Religiao='cc' AND id="&mov("ContaID"))
                if not PacienteSQL.eof then
                    cc = "<i class='fa fa-credit-card'></i>"
                end if
            end if

            EnvioEmail = ""
            set EnvioEmailSQL = db.execute("SELECT DataHora, ValorBoleto, VenctoBoleto, Para FROM faturasemails WHERE ReceitaID="&mov("InvoiceID"))
            if not EnvioEmailSQL.eof then
                while not EnvioEmailSQL.eof
                    EnvioEmail = EnvioEmail&"<span data-toggle='tooltip' title='Vencimento: "&EnvioEmailSQL("VenctoBoleto")&"<br> Valor: R$ "&fn(EnvioEmailSQL("ValorBoleto"))&" <br> Para: "&EnvioEmailSQL("Para")&"' class='label label-primary'> "&EnvioEmailSQL("DataHora")&" </span><br>"
                EnvioEmailSQL.movenext
                wend
                EnvioEmailSQL.close
                set EnvioEmailSQL = nothing
            end if
		    %>
		    <td style="font-size: 11px"><%=FaturaGerada%><%=cc%></td>
		    <td style="font-size: 11px"><%=EnvioEmail%></td>
		    <%
		    end if
            if CD="D" then
            %>
            <td><input type="checkbox" class="conta-a-pagar-checkbox" invoiceapagarid="<%=mov("InvoiceID")%>" value="<%=mov("id")%>"></td>
            <%
            end if
		    %>
			<td width="8%" class="text-right"><%= mov("Date") %></td>
			<td><%= Conta &" &nbsp; "& IconeAnexos %></td>
			<td>	   <a href="<%= linkBill %>"><%=Descricao%>
					<%if len(mov("Name"))>0 and Descricao<>"" then%> - <%end if%><%=left(mov("Name"),20)%>
				</a> <% IF ItemCancelado THEN %>
                                    			        <small><span title="Item Cancelado" class="label label-danger">Cancelado</span></small>
                                            <% END IF %><br /><%=mov("Obs")%>
				</td>
            <td><%=mov("nroNFe")%></td>
			<td class="text-right" nowrap title="Saldo devedor: R$ <%= fn(Devedor) %>"> <span><%= fn(Valor) %></span> <%= Paid %> <%=displayCD%>&nbsp; <%= Boleto %></td>
			<td class="text-right" title="Saldo devedor: R$ <%= fn(Devedor) %>"><%= fn(ValorPago) %>


                <% if mov("Rateado") = True then %>
                    <span title="Despesa Rateada" class="label label-warning"><i  class=" fa fa-share-alt"></i></span>
                <% end if %>
            </td>
			<td nowrap="nowrap">
				<div class="action-buttons">
					<a title="Editar" class="btn btn-xs btn-success" href="<%=linkBill%>"><i class="fa fa-edit bigger-130"></i></a>
					<a title="Detalhes" class="btn btn-xs btn-info" href="javascript:modalPaymentDetails('<%=mov("id")%>')">
                       <i class="fa fa-search-plus bigger-130"></i></a>
				</div>
			</td>
		</tr>
		<%
		end if
	mov.movenext
	wend
	mov.close
	set mov = nothing

if (aut("|contasapagarV|") and CD ="D") or (aut("|contasareceberV|") and CD ="C") then
    if cdate(ref("Ate"))>date() then

        if ref("AccountID")<>"" and instr(ref("AccountID"), "_") then
            splAcc = split(ref("AccountID"), "_")
            sqlAccount = " AND f.AssociationAccountID="&splAcc(0)&" AND f.AccountID="&splAcc(1)&" "
        end if
        'response.write(mydatenull(ref("Ate")))
        'set fixa = db.execute("select f.* from invoicesfixas f "&lfCatFixa&" where f.sysActive=1 AND coalesce(TipoContaFixaID<>2,true) and f.CD='"&CD&"' "&sqlCat&" and PrimeiroVencto<="&mydatenull(ref("Ate"))&sqlAccount&gpCatFixa & sqlAccountAssociationFixa)
        set fixa = db.execute("select f.* from invoicesfixas f "&lfCatFixa&" where f.sysActive=1 AND coalesce(TipoContaFixaID<>2,true) and f.CD='"&CD&"' "&sqlCat&" and PrimeiroVencto<="&mydatenull(ref("Ate"))&sqlAccount&gpCatFixa & sqlAccountAssociationFixa)
        'response.write("select f.* from invoicesfixas f "&lfCatFixa&" where f.sysActive=1 AND coalesce(TipoContaFixaID<>2,true) and f.CD='"&CD&"' "&sqlCat&" and DiaVencimento<=SUBSTRING_index("&mydatenull(ref("Ate"))&", '-', -1)"&sqlAccount&gpCatFixa & sqlAccountAssociationFixa)
        while not fixa.eof

            set itens = db.execute("select ifnull(proc.NomeProcedimento, i.Descricao) Item from itensinvoicefixa i left join procedimentos proc on proc.id=i.ItemID where i.InvoiceID="&fixa("id"))
            ItensFixa = ""
            while not itens.eof
                ItensFixa = itens("Item") & "<br>" &ItensFixa
            itens.movenext
            wend
            itens.close
            set itens=nothing

            Geradas = fixa("Geradas")&""

            Vencto = fixa("PrimeiroVencto")

            'if fixa("DiaVencimento")&""<>"" then
            '    DataVencimento = fixa("DiaVencimento")&"/"&split(fixa("PrimeiroVencto"), "/")(1)&"/"&split(fixa("PrimeiroVencto"), "/")(2)
            '    Vencto = DataVencimento
            'end if

            cFix = 0
            RepetirAte = fixa("RepetirAte")
            if isnull(RepetirAte) then
                RepetirAte = cdate("01/01/2500")
            else
                RepetirAte = cdate(fixa("RepetirAte"))
            end if
            while (Vencto<=cdate(ref("Ate")) ) and cdate(Vencto)<=RepetirAte
                cFix = cFix+1
                if instr(Geradas, "|"& cFix &"|")=0 and Vencto>=cdate(ref("De")) then
                    %>
                    <tr>
                        <%
                        if session("Banco")="clinic5459" and CD="C" then
                        %>
                        <td></td>
                        <td></td>
                        <%
                        end if
                        if CD="D" then
                        %>
                        <td></td>
                        <%
                        end if
                        %>
                        <td class="text-right"><%=Vencto %> <%'=RepetirAte %></td>
                        <td><%=accountName(fixa("AssociationAccountID"), fixa("AccountID")) %></td>
                        <td><%=ItensFixa %></td>
                        <td></td>
                        <td class="text-right"><%=fn(fixa("Value")) %></td>
                        <td class="text-right">0,00</td>
                        <td>
                            <div class="action-buttons">
                                <a class="btn btn-xs" href="javascript:if(confirm('Esta conta fixa está prevista. Ao editá-la a mesma será consolidada. Deseja prosseguir?'))consolidar(<%=fixa("id")%>, <%=cFix %>, '<%=Vencto %>')"><i class="fa fa-edit grey bigger-130"></i></a>
                            </div>
                        </td>
                    </tr>
                    <%
                    Total = Total+fixa("Value")
                end if
                Vencto = dateAdd(fixa("TipoIntervalo"), fixa("Intervalo")*cFix, fixa("PrimeiroVencto"))
            wend
        fixa.movenext
        wend
        fixa.close
        set fixa=nothing
    end if
end if
    %>
        <tfoot>
	        <tr>
                <%
                if CD="D" then
                %>
                <td></td>
                <%
                end if
                %>
                <th colspan="4"><%=c%> registro<%if c>1 then response.Write("s") end if %></th>
		        <th class="text-right"><%=fn(Total)%></th>
		        <th class="text-right"><%=fn(GranTotalPago)%></th>
                <th></th>
	        </tr>
	    </tfoot>
    </table>
      <%

if c=0 then
	%>
	<div class="col-md-12 text-center">N&atilde;o h&aacute; lan&ccedil;amentos para o per&iacute;odo consultado.</div>
	<%
end if
%>
  </div>
</div>


<script type="text/javascript">
    function consolidar(I, N, D){
        $.get("consolidar.asp?I="+I+"&N="+N+"&D="+D, function(data){eval(data)});
    }
    $(document).ready(function(){
        $('[data-toggle="tooltip"]').tooltip({html: true});
    });
//$("#rbtns").css("position", "absolute");
    $(function () {
        $('#grafico').highcharts({
            chart: {
                margin:0,
                backgroundColor:null,
                plotBorderWidth: null,
                plotShadow: false,
                type: 'pie',
                height: 120,
                legend: {
                    enabled:false
                },
            },
            title: {
                text: ''
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: false,
                        format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                        style: {
                            color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                        }
                    }
                }
            },
            series: [{
                name: 'Percentual',
                colorByPoint: true,
                data: [{
                    color:'green',
                    name: 'Liquidado: R$ <%=fn(GranTotalPago)%>',
                    y: <%=treatval(GranTotalPago)%>,
                    sliced:true
                }, {
                    color:'red',
                    name: 'Vencido: R$ <%=fn(TotalVencido)%>',
                    y: <%=treatval(TotalVencido)%>
                }, {
                    color:'#999',
                    name: 'A vencer: R$ <%=fn(TotalAVencer)%>',
                    y: <%=treatval(TotalAVencer)%>
                }]
            }]
        });
    });


    var $btnAcoes = $("#GerarArquivoRemessa,#GerarArquivoRemessaBeta");
    var $checkboxContasAPagar = $(".conta-a-pagar-checkbox");

    $checkboxContasAPagar.change(function() {
        var display = $checkboxContasAPagar.filter(":checked").length > 0 ? "block" : "none";

        $btnAcoes.css("display", display);
    });



    $("#selecionar-todas-as-contas").change(function() {
        $(".conta-a-pagar-checkbox").prop("checked", $(this).prop("checked")).change();
    });
</script>