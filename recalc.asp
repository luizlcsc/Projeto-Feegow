<!--#include file="connect.asp"-->
<%
T = ref("T")
Voucher = req("Voucher")

TipoConta = ""
'if T = "D" then
'    TipoConta = "ContasAPagar"
'elseif T = "C" then
if T = "C" then
    TipoConta = "ContasAReceber"
end if

inputs = ref("inputs")
inputAlterado = req("input")
if ref("NumeroParcelas")<>"" then
    NumeroParcelas = ccur(ref("NumeroParcelas"))
else
    NumeroParcelas = 0
end if
ParcelasID = ref("ParcelasID")
Total = 0

VoucherDesconto = 0
if Voucher<>"" then
    set VoucherSQL = db.execute("SELECT Valor,TipoValor FROM voucher WHERE Codigo='"&Voucher&"'")
    if not VoucherSQL.eof then
        VoucherDesconto = ccur(VoucherSQL("Valor"))
        VoucherTipoDesconto = VoucherSQL("TipoValor")
    end if
end if

CompanyUnitID = "%|"&ref("CompanyUnitID")&"|%"
spl = split(inputs, ", ")
for i=0 to ubound(spl)

	ProcedimentoID = ref("ItemID"&spl(i))
	Quantidade = ref("Quantidade"&spl(i))
	ValorUnitario = ref("ValorUnitario"&spl(i))
	Desconto = ref("Desconto"&spl(i))
	Acrescimo = ref("Acrescimo"&spl(i))
	if Quantidade="" or not isnumeric(Quantidade) then
		Quantidade = 0
	end if
	if ValorUnitario="" or not isnumeric(ValorUnitario) then
		ValorUnitario = 0
	end if
	if Desconto="" or not isnumeric(Desconto) then
		Desconto = 0
	end if
	if Acrescimo="" or not isnumeric(Acrescimo) then
		Acrescimo = 0
	end if

	Quantidade = ccur(Quantidade)
	ValorUnitario = ccur(ValorUnitario)
	Desconto = ccur(Desconto)
	Percent = 0
	if Desconto <> 0 and ValorUnitario <> 0 then
		Percent = Desconto * 100 / ValorUnitario
		Percent = Replace(Percent,",",".")
	end if


    if VoucherDesconto > 0 then
        if VoucherTipoDesconto="V" then
            Desconto = VoucherDesconto
        else
            Desconto = ValorUnitario * (VoucherDesconto/100)
        end if

        %>
            $("#<%="Desconto"&spl(i)%>").val("<%=fn(Desconto)%>").attr("readonly","readonly");
        <%
    end if

	Desconto2 = Replace(Desconto, ",",".")
	Acrescimo = ccur(Acrescimo)
	Subtotal = Quantidade * (ValorUnitario - Desconto + Acrescimo)

    if Desconto > 0 and T <> "D" and Voucher="" then
        sqlRegraSuperior = "SELECT IFNULL(group_concat(RegraID), '') regras FROM regrasdescontos WHERE ((TipoDesconto = 'P' AND DescontoMaximo>="&Percent&") OR (TipoDesconto = 'V' AND DescontoMaximo>="&Desconto2&")) AND "&_
                                        "(Procedimentos IS NULL OR Procedimentos ='' OR Procedimentos LIKE '%|"&ProcedimentoID&"|%') AND "&_
                                        " (Unidades IS NULL OR Unidades ='' OR Unidades LIKE '"&CompanyUnitID&"' OR Unidades = "&treatvalzero(CompanyUnitID)&") "&_
                                        "  AND ( Recursos = '' OR Recursos LIKE '%|"&TipoConta&"|%') AND RegraID IS NOT NULL"
        set RegraSQLSuperior = db.execute(sqlRegraSuperior)
        if not RegraSQLSuperior.eof then
            Regras = RegraSQLSuperior("regras")&""

            if Regras<> "" then
                set RegraSQL = db.execute("SELECT group_concat(Regra)regras FROM regraspermissoes WHERE id in ("&Regras&")")

                RegraIDArray = split(Regras, ",")

                For j = 0 to Ubound(RegraIDArray)
                    RegraIDArray(j) = " su.RegraID = '"&RegraIDArray(j)&"'  "
                Next

                RegraLike = Join(RegraIDArray, " or ")
                sqlRegra = "SELECT su.id, und.NomeFantasia, su.UnidadeID FROM sys_users su "&_
                                " INNER JOIN (SELECT 'profissionais' Tipo, id, Ativo, NomeProfissional Nome FROM profissionais WHERE sysActive=1 UNION ALL SELECT 'funcionarios' Tipo,id, Ativo, NomeFuncionario Nome FROM funcionarios WHERE sysActive=1)tab ON tab.Tipo= su.Table AND tab.id = su.idInTable "&_
                                " LEFT JOIN (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)und ON und.id= su.UnidadeID "&_
                                " WHERE tab.Ativo='on' and ("&RegraLike&") AND su.id = "&session("user")&" ORDER BY tab.Nome"

                set UsuariosComRegraSQL = db.execute(sqlRegra)
                if UsuariosComRegraSQL.eof then
                    'Validar se na tabela itensinvoice ja possui o valor do desconto, se ja estiver manter
                    idItensInvoice = spl(i)

                    'Subtotal = Quantidade * (ValorUnitario + Acrescimo)
                    'sqlIntesInvoice = "select ValorUnitario, IFNULL(Desconto, 0) Desconto from itensinvoice where id = " & idItensInvoice
                    'set itensInvoice = db.execute(sqlIntesInvoice)
                    'if not itensInvoice.eof then
                    '    if ccur(itensInvoice("Desconto")) = Desconto then
                    Subtotal = Quantidade * (ValorUnitario - Desconto + Acrescimo)
                    '    end if
                    'end if

                end if
            end if
        end if
    end if

	Total = Total+Subtotal
	%>
	$("#sub<%=spl(i)%>").html("R$ <%=formatnumber(Subtotal, 2)%>");
    <%
next

%>
$("#total").html("R$ <%=fn(Total)%>");
$("#Valor").val("<%=fn(Total)%>");

<%
par = split(ParcelasID, ", ")
for j=0 to ubound(par)
    t = Total
    if NumeroParcelas > 0 then
        t = Total/NumeroParcelas
    end if
	%>
	$("#Value<%=par(j)%>").val("<%=formatnumber(t, 2)%>");
    $("#Value<%=par(j)%>").attr("value", "<%=formatnumber(t, 2)%>");
    $("#pend<%=par(j)%>").html("<%=formatnumber(t, 2)%>")
    <%
next
%>

$(".parcela").prop("disabled", false);