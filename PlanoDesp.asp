<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<%
db_execute("delete from cliniccentral.rel_analise WHERE UsuarioID="&session("User"))

if req("De") = "" then
	De = DiaMes("P", date())
else
    De = req("De")
end if
if req("Ate")="" then
    Ate = DiaMes("U", date())
else
    Ate = req("Ate")
end if

set u = db.execute("SELECT GROUP_CONCAT(NomeFantasia SEPARATOR ', ') Empresas FROM (	SELECT '0' id, NomeFantasia FROM empresa 	UNION ALL 	SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1 ) t WHERE id IN ( "& replace(req("U"), "|", "") &" )")
Empresas = u("Empresas")

tipo = req("Pars")
CD="D"

if req("R")="" then
    %>

    <form method="get" action="PrintStatement.asp" id="frmfiltros" target="_blank">
        <input type="hidden" name="R" value="PlanoDesp" />
	    <input type="hidden" name="Pars" value="<%=tipo%>">
        <div class="form-actions" id="filtros">
          <div class="row">
            <%=quickField("datepicker", "De", "De", 2, De, "", "", "")%>
            <%=quickField("datepicker", "Ate", "Até", 2, Ate, "", "", "")%>
            <%=quickField("empresaMultiIgnore", "U", "Unidade", 3, "|"&session("UnidadeID")&"|", "", "", "")%>
            <%=quickField("simpleSelect", "TipoData", "Tipo de Data", 2, "V", "select 'I' id, 'Competência' TipoData UNION ALL select 'V', 'Vencimento' UNION ALL select 'P', 'Pagamento'", "TipoData", " semVazio no-select2 ")%>
            <div class="col-md-2 pt25"><label><input type="checkbox" name="Ocultar" value="S"<%if req("Ocultar")="S" then%> checked<%end if%> class="ace"><span class="lbl"> Ocultar valores zerados</span></label>
            </div>
            <div class="col-md-1 pt25">
                <button class="btn btn-primary" id="btnFiltrar">GERAR</button>
            </div>
          </div>
        </div>
    </form>
    <%
else
    'AQUI COMEÇA O RELATÓRIO
%>
<div class="alert alert-warningl hidden">
    <strong>Atenção!</strong> Este relatório está passando por manutenção.
</div>
    <h2 class="text-center">Análise de Despesas</h2>
    <h5 class="mtn text-center"><%= De &" - "& Ate &"<br><br>"& ucase(Empresas&"") %> </h5>
    <div class="row">
	    <div class="col-xs-12" id="container"></div>
    </div>
    <table class="table table-hover table-condensed" style="cursor:pointer">

    <%
    c0 = 0
    spl = split(tipo, ", ")
    for i=0 to ubound(spl)
	    c0 = c0+1
	    c1 = 0

	    if spl(i)="RECEITAS" then
            CD = "C"
            tabCat = "sys_financialincometype"
	        set n1 = db.execute("SELECT * FROM sys_financialincometype WHERE Category=0 ORDER BY Ordem")
	        set movs = db.execute("select m.InvoiceID, m.`Value`, (select count(id) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) Parcelas, (select SUM(Value) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) TotalInvoice FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i on m.InvoiceID=i.id WHERE m.Date BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND m.CD='"&CD&"' AND m.Type='Bill' AND i.CompanyUnitID in ("&replace(req("U"), "|", "")&")")
	        while not movs.eof

        '			response.Write("Esta parcela: "&movs("Value")&" - Total da Invoice: "&movs("TotalInvoice")&" - Parcelas: "&movs("Parcelas")&"<br>")

		        set itens = db.execute("SELECT * FROM itensinvoice WHERE InvoiceID="&movs("InvoiceID"))
		        while not itens.EOF
			        ValorItem = itens("Quantidade") * itens("ValorUnitario") - itens("Desconto") + itens("Acrescimo")
			        if movs("TotalInvoice")>0 then
				        Fator = 100 / movs("TotalInvoice")
			        else
				        Fator = 0
			        end if
			        PercItem = Fator * ValorItem
			        ValorProp = movs("Value") * (PercItem / 100)

        '				response.Write("- &gt; Total do item: "&ValorItem&" - Percentual item: "&PercItem&" - Valor Proporcional: "&ValorProp&" - Categoria: "&itens("CategoriaID")&"<br>")

			        db_execute("insert into cliniccentral.rel_analise (UsuarioID, ItemInvoiceID, CategoriaID, Valor) values ("&session("User")&", "& treatvalzero(itens("id")) &", "&treatvalzero(itens("CategoriaID"))&", "&treatvalzero(ValorProp)&")")
		        itens.movenext
		        wend
		        itens.close
		        set itens=nothing
	        movs.movenext
	        wend
	        movs.close
	        set movs=nothing

	    else
            CD = "D"
            tabCat = "sys_financialexpensetype"
			idsInvoice = ""
	        set n1 = db.execute("SELECT * FROM sys_financialexpensetype WHERE Category=0 ORDER BY Ordem")
	        set movs = db.execute("select m.InvoiceID, m.`Value`, i.Rateado, (select count(id) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) Parcelas, (select SUM(Value) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) TotalInvoice FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i on m.InvoiceID=i.id WHERE m.Date BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND m.CD='"&CD&"' AND m.Type='Bill' AND i.CompanyUnitID in ("&replace(req("U"), "|", "")&")")
	        while not movs.eof
        '			response.Write("Esta parcela: "&movs("Value")&" - Total da Invoice: "&movs("TotalInvoice")&" - Parcelas: "&movs("Parcelas")&"<br>")

		        set itens = db.execute("SELECT * FROM itensinvoice WHERE InvoiceID="&movs("InvoiceID"))
				idsInvoice = idsInvoice & movs("InvoiceID") &","
		        while not itens.EOF
			        ValorItem = itens("Quantidade") * itens("ValorUnitario") - itens("Desconto") + itens("Acrescimo")
					ValorProp = 0
			        if movs("TotalInvoice")>0 then
				        Fator = 100 / movs("TotalInvoice")
			        else
				        Fator = 0
			        end if
			        PercItem = Fator * ValorItem
			        
					Rateado = 0
					if movs("Rateado") = True then
						set itemRateado = db.execute("SELECT SUM(porcentagem)porcentagem, TipoValor FROM invoice_rateio WHERE InvoiceID="&movs("InvoiceID")& " AND CompanyUnitID in ("&replace(req("U"), "|", "")&")")
						if not itemRateado.eof then 
							if itemRateado("TipoValor") = "V" then
								ValorProp = movs("Value") - itemRateado("porcentagem")
							else 
								ValorProp = movs("Value") * itemRateado("porcentagem") / 100
							end if
						end if 
						Rateado = 1
					else
						ValorProp = movs("Value") * (PercItem / 100)
					end if
        '				response.Write("- &gt; Total do item: "&ValorItem&" - Percentual item: "&PercItem&" - Valor Proporcional: "&ValorProp&" - Categoria: "&itens("CategoriaID")&"<br>")
					
			        db_execute("insert into cliniccentral.rel_analise (UsuarioID, ItemInvoiceID, CategoriaID, Valor, Rateado) values ("&session("User")&", "& treatvalzero(itens("id")) &", "&treatvalzero(itens("CategoriaID"))&", "&treatvalzero(ValorProp)&", "&Rateado&")")
		        itens.movenext
		        wend
		        itens.close
		        set itens=nothing
	        movs.movenext
	        wend
	        movs.close
	        set movs=nothing
			idsInvoice = idsInvoice & "0"
			'Nao pode trazer as invoices que encontrou acima
			set movs2 = db.execute("select m.InvoiceID, m.`Value`, i.Rateado, ir.TipoValor, SUM(ir.porcentagem) as porcent, (select count(id) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) Parcelas, (select SUM(Value) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) TotalInvoice FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i on m.InvoiceID=i.id inner join invoice_rateio ir ON ir.InvoiceID = i.id WHERE m.Date BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND m.CD='"&CD&"' AND m.Type='Bill' AND i.id NOT IN("&idsInvoice&") AND ir.CompanyUnitID in ("&replace(req("U"), "|", "")&") GROUP BY m.id")
	        while not movs2.eof
        		set itens = db.execute("SELECT * FROM itensinvoice WHERE InvoiceID="&movs2("InvoiceID"))
		        while not itens.EOF
			        ValorItem = itens("Quantidade") * itens("ValorUnitario") - itens("Desconto") + itens("Acrescimo")
			        if movs2("TotalInvoice")>0 then
				        Fator = 100 / movs2("TotalInvoice")
			        else
				        Fator = 0
			        end if
			        PercItem = Fator * ValorItem
			        ValorProp = movs2("Value") * (PercItem / 100)

					if movs2("TipoValor") = "P" then
						ValorProp = ValorProp * (movs2("porcent") / 100)
					end if

					Rateado = 0
					if movs2("Rateado") = True then
						Rateado = 1
					end if
        '				response.Write("- &gt; Total do item: "&ValorItem&" - Percentual item: "&PercItem&" - Valor Proporcional: "&ValorProp&" - Categoria: "&itens("CategoriaID")&"<br>")
					if ValorProp > 0 then
			        db_execute("insert into cliniccentral.rel_analise (UsuarioID, ItemInvoiceID, CategoriaID, Valor, Rateado) values ("&session("User")&", "& treatvalzero(itens("id")) &", "&treatvalzero(itens("CategoriaID"))&", "&treatvalzero(ValorProp)&", "&Rateado&")")
					end if
		        itens.movenext
				wend
				itens.close
				set itens = nothing
			movs2.movenext
			wend
			movs2.close
			set movs2 = nothing
        end if

	    sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where CategoriaID!=0 AND CategoriaID IS NOT NULL AND UsuarioID="&session("User")
	    set valRecursivo = db.execute(sqlVal)


	    sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where (CategoriaID=0 or CategoriaID IS NULL) AND UsuarioID="&session("User")
		temRateionvalSemCategoria = db.execute("select count(*) as total from cliniccentral.rel_analise where Rateado = 1 AND UsuarioID = "&session("User")&" and (CategoriaID=0 or CategoriaID IS NULL) ")
	    set valSemCategoria = db.execute(sqlVal)
	    %>
	    <tr onClick="cd('')">
		    <td><%=c0%>. <%=spl(i)%></td>
		    <td class="text-right hidden">0</td>
		    <td class="text-right"><%=fn(valRecursivo("cTotal"))%></td>
	    </tr>
	    <tr onClick="cd('0')">
		    <td>0. Categoria não informada</td>
		    <td class="text-right hidden">0</td>
		    <td class="text-right"><% if ccur(temRateionvalSemCategoria("total")) > 0 then %> <span title="Despesa Rateada" class="label label-warning"><i class="far fa-share-alt"></i></span> <% end if %>  <%=fn(valSemCategoria("cTotal"))%></td>
	    </tr>
	    <%
        sqlv = ""
	    while not n1.EOF
		    c1 = c1+1
				
		    sqlv = ""
		    set grupos = db.execute("SELECT group_concat(t1.id) g1, group_concat(t2.id) g2, group_concat(t3.id) g3, group_concat(t4.id) g4 FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.category = t1.id LEFT JOIN sys_financialexpensetype AS t3 ON t3.category = t2.id LEFT JOIN sys_financialexpensetype AS t4 ON t4.category = t3.id WHERE t1.Category="&n1("id"))
		    if trim(grupos("g1")&"")<>"" and isnumeric(grupos("g1")&"") then
			    sqlv = " OR CategoriaID in ("&grupos("g1")&") /*1*/ "
		    end if
		    if trim(grupos("g2")&"")<>"" and isnumeric(grupos("g2")&"") then
			    sqlv = sqlv & " OR CategoriaID in ("&grupos("g2")&") /*2*/ "
		    end if
			g3 = trim(grupos("g3")&"")
		    if g3<>""  then
			    sqlv = sqlv & " OR CategoriaID in ("&g3&") /*31 "& g3&"*/ "
		    end if
		    if grupos("g4")&""<>"" then
			    sqlv = sqlv & " OR CategoriaID in ("&grupos("g4")&") /*4*/ "
		    end if
		
		    sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID="&session("User")&" and (CategoriaID="&n1("id")
		    if sqlv<>"" then
			    sqlVal = sqlVal & sqlv
		    end if
		    sqlVal = sqlVal & sqlv &")"

		    set valRecursivo = db.execute(sqlVal)

		    titChart = titChart & n1("Name") &"|"
		    valChart = valChart & replace(replace(formatnumber(0&valRecursivo("cTotal"),2), ".", ""), ",", ".") &"|"
		
		    subtitChart = subtitChart & "|^"
		    subvalChart = subvalChart & "|^"


             n69 = db.execute("select if(isnull(group_concat(numero)), '88888888888', group_concat(numero)) as numero from (select CONCAT(original.id,',',IFNULL(filho1.id, '88888'),',',IFNULL(filho2.id, '88888'),',',IFNULL(filho3.id, '88888'),',',IFNULL(filho4.id, '88888')) as numero from sys_financialexpensetype original left join sys_financialexpensetype filho1 on filho1.Category = original.id left join sys_financialexpensetype filho2 on filho2.Category = filho1.id left join sys_financialexpensetype filho3 on filho3.Category = filho2.id left join sys_financialexpensetype filho4 on filho4.Category = filho3.id where original.Category = "&n1("id")&") as x")
             n70 = db.execute("select sum(ifnull(Valor,0)) as valornum from cliniccentral.rel_analise where UsuarioID = "&session("User")&" and CategoriaID in ("&n69("numero")&", "&  n1("id") &" )")


			 temRateion70 = db.execute("select count(*) as total from cliniccentral.rel_analise where Rateado = 1 AND UsuarioID = "&session("User")&" and CategoriaID in ("&treatvalnull(n69("numero"))&", "&  n1("id") &" )")

		    %>
		    <tr<% if n70("valornum") = 0 and (valRecursivo("cTotal")=0 or isnull(valRecursivo("cTotal"))) AND req("Ocultar")="S"   then%> class="hidden"<%end if%> onClick="cd(<%=n1("id")%>)">
			    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>&nbsp;<%=c0 &"."& c1%>. <%=n1("Name")%></strong> <code class="hidden"><%=n1("id")%></code></td>
			    <td class="text-right hidden">0</td>
				<% 			
				' n67 = db.execute("select sum(somaFilhos) as somaFilhos from (SELECT *, (select sum(Valor) Total from cliniccentral.rel_analise where UsuarioID = 13054 and CategoriaID = sys_financialexpensetype.id) as somaFilhos FROM sys_financialexpensetype WHERE Category = "&n1("id")&" ) as t;")
				' n68 = db.execute("select sum(if(isnull(numeroTotalCada), 0, numeroTotalCada)) as num from (select *, (select sum(if(isnull(Valor), 0, Valor)) Total from cliniccentral.rel_analise where UsuarioID = "&session("User")&" and CategoriaID in (numero)) as numeroTotalCada from ( select CONCAT(original.id, ',', IFNULL(filho1.id, '88888'), ',', IFNULL(filho2.id, '88888'), ',', IFNULL(filho3.id, '88888'), ',', IFNULL(filho4.id, '88888')) as numero from sys_financialexpensetype original left join sys_financialexpensetype filho1 on filho1.Category = original.id left join sys_financialexpensetype filho2 on filho2.Category = filho1.id left join sys_financialexpensetype filho3 on filho3.Category = filho2.id left join sys_financialexpensetype filho4 on filho4.Category = filho3.id where original.Category ="&n1("id")&  ") as x ) as z")

				%>
			    <td class="text-right"><% if ccur(temRateion70("total")) > 0 then %> <span title="Despesa Rateada" class="label label-warning"><i class="far fa-share-alt"></i></span> <% end if %> <strong><%=formatnumber(0&n70("valornum"),2)%></strong></td>
		    </tr>
		    <%
		    c2 = 0
			
		    set n2 = db.execute("SELECT * FROM sys_financialexpensetype WHERE Category="&n1("id")&" ORDER BY Ordem")
		    while not n2.EOF
				idn2 = n2("id")
			    set valTotal = db.execute("select COALESCE(sum(COALESCE(Valor, 0)),0) Total from cliniccentral.rel_analise where UsuarioID="&session("User")&" and CategoriaID="&idn2)
			    c2 = c2+1
			
			    sqlv = ""
			    set grupos = db.execute("SELECT group_concat(t1.id) g1, group_concat(t2.id) g2, group_concat(t3.id) g3, group_concat(t4.id) g4 FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.category = t1.id LEFT JOIN sys_financialexpensetype AS t3 ON t3.category = t2.id LEFT JOIN sys_financialexpensetype AS t4 ON t4.category = t3.id WHERE t1.Category="&idn2)
			    if not isnull(grupos("g1")) and grupos("g1")&"" <> "" then
				    sqlv = " OR CategoriaID in ("&grupos("g1")&") /*g1*/ "
			    end if
			    if not isnull(grupos("g2"))  and grupos("g2")&"" <> "" then
				    sqlv = sqlv & " OR CategoriaID in ("&grupos("g2")&") /*g2*/ "
			    end if
				g3 = grupos("g3")
			    if not isnull(g3) then
				    sqlv = sqlv & " OR CategoriaID in ("&g3&") /*g3*/ "
			    end if
			    if not isnull(grupos("g4")) then
				    sqlv = sqlv & " OR CategoriaID in ("&grupos("g4")&") /*g4*/ "
			    end if
			    sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID="&session("User")&" and (CategoriaID="&n2("id")
				sqlRateio = "select count(*) as total from cliniccentral.rel_analise where Rateado = 1 AND UsuarioID = "&session("User")&" and (CategoriaID="&n2("id")

			    if sqlv<>"" then
				    sqlVal = sqlVal & sqlv
					sqlRateio = sqlRateio & sqlv
			    end if
			    sqlVal = sqlVal & sqlv &")"
				sqlRateio = sqlRateio & sqlv &")"
				
			
			    set valRecursivo = db.execute(sqlVal)
				cTotal = valRecursivo("cTotal")

				temRateio2 = db.execute(sqlRateio)
			    subtitChart = subtitChart & "'"& replace(n2("Name")&" ", "'", "") &"'" & ", "
			    subvalChart = subvalChart & replace(replace(fn(0&cTotal), ".", ""), ",", ".") & ", "
			    %>
			    <tr<%if (cTotal=0 or isnull(cTotal)) AND req("Ocultar")="S" then%> class="hidden"<%end if%> onClick="cd(<%=n2("id")%>)">
				    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=c0 &"."& c1 &"."& c2%>. <%=n2("Name")%></td>
					
				    <td class="text-right hidden"><%=fn(valTotal("Total"))%></td>
				    <td class="text-right"><% if ccur(temRateio2("total")) > 0 then %> <span title="Despesa Rateada" class="label label-warning"><i class="far fa-share-alt"></i></span> <% end if %> <%=fn(0&cTotal)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
			    </tr>
			    <%
			    c3 = 0
			    set n3 = db.execute("SELECT * FROM sys_financialexpensetype WHERE Category="&n2("id")&" ORDER BY Ordem")
			    while not n3.EOF
				    set val = db.execute("select sum(Valor) Total from cliniccentral.rel_analise where UsuarioID="&session("User")&" and CategoriaID="&n3("id"))
				    c3 = c3+1
				
				    sqlv = ""
				    set grupos = db.execute("SELECT group_concat(t1.id) g1, group_concat(t2.id) g2, group_concat(t3.id) g3, group_concat(t4.id) g4 FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.category = t1.id LEFT JOIN sys_financialexpensetype AS t3 ON t3.category = t2.id LEFT JOIN sys_financialexpensetype AS t4 ON t4.category = t3.id WHERE t1.Category="&n3("id"))
				    if not isnull(grupos("g1"))  and grupos("g1")&"" <> "" then
					    sqlv = " OR CategoriaID in ("&grupos("g1")&")"
				    end if
				    if not isnull(grupos("g2"))  and grupos("g2")&"" <> "" then
					    sqlv = sqlv & " OR CategoriaID in ("&grupos("g2")&")"
				    end if
				    if not isnull(grupos("g3")) then
					    sqlv = sqlv & " OR CategoriaID in ("&grupos("g3")&")"
				    end if
				    if not isnull(grupos("g4")) then
					    sqlv = sqlv & " OR CategoriaID in ("&grupos("g4")&")"
				    end if
				
				    sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID="&session("User")&" and (CategoriaID="&n3("id")
					sqlRateio = "select count(*) as total from cliniccentral.rel_analise where Rateado = 1 AND UsuarioID = "&session("User")&" and (CategoriaID="&n3("id")

				    if sqlv<>"" then
					    sqlVal = sqlVal & sqlv
						sqlRateio = sqlRateio & sqlv
				    end if
				    sqlVal = sqlVal & sqlv &")"
					sqlRateio = sqlRateio & sqlv &")"

					temRateio3 = db.execute(sqlRateio)
				
				    'response.Write(sqlVal)
				    set valRecursivo = db.execute(sqlVal)
				    %>
				    <tr<%if (valRecursivo("cTotal")=0 or isnull(valRecursivo("cTotal"))) AND req("Ocultar")="S" then%> class="hidden"<%end if%> onClick="cd(<%=n3("id")%>)">
					    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=c0 &"."& c1 &"."& c2 &"."& c3%>. <%=n3("Name")%></td>
					    <td class="text-right hidden"><%=formatnumber(0&val("Total"),2)%></td>
					    <td class="text-right"><% if ccur(temRateio3("total")) > 0 then %> <span title="Despesa Rateada" class="label label-warning"><i class="far fa-share-alt"></i></span> <% end if %> <%=formatnumber(0&valRecursivo("cTotal"),2)%></td>
				    </tr>
				    <%
				    c4 = 0
				    set n4 = db.execute("SELECT * FROM sys_financialexpensetype WHERE Category="&n3("id")&" ORDER BY Ordem")
				    while not n4.EOF
					    set val = db.execute("select sum(Valor) Total from cliniccentral.rel_analise where UsuarioID="&session("User")&" and CategoriaID="&n4("id"))
					    c4 = c4+1
				
					    sqlv = ""
					    set grupos = db.execute("SELECT group_concat(t1.id) g1, group_concat(t2.id) g2, group_concat(t3.id) g3, group_concat(t4.id) g4 FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.category = t1.id LEFT JOIN sys_financialexpensetype AS t3 ON t3.category = t2.id LEFT JOIN sys_financialexpensetype AS t4 ON t4.category = t3.id WHERE t1.Category="&n4("id"))
					    if not isnull(grupos("g1")) then
						    sqlv = " OR CategoriaID in ("&grupos("g1")&")"
					    end if
					    if not isnull(grupos("g2")) then
						    sqlv = sqlv & " OR CategoriaID in ("&grupos("g2")&")"
					    end if
					    if not isnull(grupos("g3")) then
						    sqlv = sqlv & " OR CategoriaID in ("&grupos("g3")&")"
					    end if
					    if not isnull(grupos("g4")) then
						    sqlv = sqlv & " OR CategoriaID in ("&grupos("g4")&")"
					    end if
					
					    sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID="&session("User")&" and (CategoriaID="&n4("id")
						sqlRateio = "select count(*) as total from cliniccentral.rel_analise where Rateado = 1 AND UsuarioID = "&session("User")&" and (CategoriaID="&n4("id")

					    if sqlv<>"" then
						    sqlVal = sqlVal & sqlv
							sqlRateio = sqlRateio & sqlv
					    end if
					    sqlVal = sqlVal & sqlv &")"
						sqlRateio = sqlRateio & sqlv &")"
					
						temRateio4 = db.execute(sqlRateio)

					    'response.Write(sqlVal)
					    set valRecursivo = db.execute(sqlVal)
					    %>
					    <tr<%if (valRecursivo("cTotal")=0 or isnull(valRecursivo("cTotal"))) AND req("Ocultar")="S" then%> class="hidden"<%end if%> onClick="cd(<%=n4("id")%>)">
						    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=c0 &"."& c1 &"."& c2 &"."& c3 &"."& c4%>. <%=n4("Name")%></td>
                            <td class="text-right hidden"><%=formatnumber(0&val("Total"),2)%></td>
                            <td class="text-right"><% if ccur(temRateio4("total")) > 0 then %> <span title="Despesa Rateada" class="label label-warning"><i class="far fa-share-alt"></i></span> <% end if %> <%=formatnumber(0&valRecursivo("cTotal"),2)%></td>
					    </tr>
					    <%
				    n4.movenext
				    wend
				    n4.close
				    set n4=nothing
			    n3.movenext
			    wend
			    n3.close
			    set n3=nothing
		    n2.movenext
		    wend
		    n2.close
		    set n2=nothing
	    n1.movenext
	    wend
	    n1.close
	    set n1=nothing
    next

    'db_execute("delete from cliniccentral.rel_analise WHERE UsuarioID="&session("User"))

    'Percentuais devem aparecer no gráfico.

    'Categorias e depois procedimentos, e colocar procedimentos sem categoria.%>
    </table>

    <%
    titChart = left(titChart, len(titChart)-1)
    valChart = left(valChart, len(valChart)-1)

    subtitChart = right(subtitChart, len(subtitChart)-2)
    subvalChart = right(subvalChart, len(subvalChart)-2)

end if
%>

<script type="text/javascript">
/*
$(function () {

    var colors = Highcharts.getOptions().colors,
        categories = [<%
		splChart = split(titChart, "|")
		for k=0 to ubound(splChart)%>'<%=splChart(k)%>', <%next%>],
        data = [
		<%
		c = 0
		splChart = split(titChart, "|")
		splValChart = split(valChart, "|")
		
		splSubtit = split(subtitChart, "|^")
		splSubval = split(subvalChart, "|^")
		
		for j=0 to ubound(splChart)
		%>
		{
            y: <%=splValChart(j)%>,
            color: colors[<%=c%>],
            drilldown: {
                name: '<%=splChart(j)%>',
                categories: [<%=splSubtit(j)%>],
                data: [<%=splSubval(j)%>],
                color: colors[<%=c%>]
            }
        },
		<%
		c = c+1
		next
		%> 
		],
        browserData = [],
        versionsData = [],
        i,
        j,
        dataLen = data.length,
        drillDataLen,
        brightness;


    // Build the data arrays
    for (i = 0; i < dataLen; i += 1) {

        // add browser data
        browserData.push({
            name: categories[i],
            y: data[i].y,
            color: data[i].color
        });

        // add version data
        drillDataLen = data[i].drilldown.data.length;
        for (j = 0; j < drillDataLen; j += 1) {
            brightness = 0.2 - (j / drillDataLen) / 5;
            versionsData.push({
                name: data[i].drilldown.categories[j],
                y: data[i].drilldown.data[j],
                color: Highcharts.Color(data[i].color).brighten(brightness).get()
            });
        }
    }

    // Create the chart
    $('#container').highcharts({
        chart: {
            type: 'pie'
        },
        title: {
            text: ''
        },
        yAxis: {
            title: {
                text: ''
            }
        },
        plotOptions: {
            pie: {
                shadow: false,
                center: ['50%', '50%']
            }
        },
        tooltip: {
            valueSuffix: ''
        },
        series: [{
            name: 'Categoria',
            data: browserData,
            size: '60%',
            dataLabels: {
                formatter: function () {
                    return this.y > 5 ? this.point.name : null;
                },
                color: '#ffffff',
                distance: -30
            }
        }, {
            name: 'Subcategoria',
            data: versionsData,
            size: '100%',
            innerSize: '60%',
            dataLabels: {
                formatter: function () {
                    // display only if larger than 1
                    return this.y > 1 ? '<b>' + this.point.name + ':</b> R$ ' + this.y : null;
                }
            }
        }]
    });
});

$('#frmfiltros').submit(function(){
	$('#btnFiltrar').html('Filtrando...');
	$.get("Plano.asp?"+$('#frmfiltros').serialize(), function(data) { $('#relConteudo').html(data) });
	return false;
});

*/

function cd(CategoriaID) {
	var empresas = ('<%=req("U")%>')
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $("#modal-table").modal("show");
    $.get("PlanoDespModal.asp?C=" + CategoriaID + "&Empresas=" + empresas, function (data) {
        $("#modal").html(data);
    });
}


<!--#include file="JQueryFunctions.asp"-->
</script>