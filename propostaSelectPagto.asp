<!--#include file="connect.asp"-->
<%
InvoiceID = req("I")
CD = req("T")
set data = db.execute("select i.*, (select count(*) from sys_financialmovement where Type='Bill' and InvoiceID=i.id) NumeroParcelas from sys_financialinvoices i where i.id="&InvoiceID)
NumeroParcelas = ccur(data("NumeroParcelas"))

II = data("FormaID")&"_"&data("ContaRectoID")
if ref("FormaID")<>"" then
	II = ref("FormaID")
end if
%>
<div class="clearfix form-actions">
<%
set forma = db.execute("select f.*, m.PaymentMethod from sys_formasrecto f left join sys_financialpaymentmethod m on m.id=f.MetodoID order by PaymentMethod")
if not forma.eof and CD="C" then
  %>
  <div class="col-md-6">
    <label for="FormaID">Forma de Pagamento</label><br />
    <select name="FormaID" id="FormaID" required class="form-control disable" onchange="formaRecto(); allRepasses();">
        <option value="">Selecione a forma de pagamento</option>
        <option value="0_0"<%if II="0_0" then%> selected="selected"<%end if%>>Diversas</option>
        <%
        while not forma.eof
            spl = split(forma("Contas"), ", ")
            for i=0 to ubound(spl)
                if spl(i)<>"" then
                    conta = replace(spl(i), "|", "")
                    if isnumeric(conta) then
                        set contas = db.execute("select * from sys_financialcurrentaccounts where id="&conta)
                        if not contas.eof then
							if session("UnidadeID") = contas("Empresa") then
								If II=forma("id")&"_"&contas("id") or (II="" and data("FormaID")=forma("id") and data("ContaRectoID")=contas("id"))  then
									'and Acao="Forma" Then
									selected = " selected=""selected"""
									MetodoID = forma("MetodoID")
									MinimoParcelas = forma("ParcelasDe")
									if MetodoID=8 or MetodoID=10 then
										MinimoParcelas = 1
									end if
									geraParcelas = "geraParcelas('S');"
									parcelasDe = forma("ParcelasDe")
									parcelasAte = forma("ParcelasAte")
								else
									selected = ""
								End If
								%>
								<option value="<%=forma("id")%>_<%=contas("id")%>"<% =selected %>><%=forma("PaymentMethod")%> - <%=contas("AccountName")%>: De <%=forma("ParcelasDe")%> a <%=forma("ParcelasAte")%> parcelas</option>
								<%
							end if
                        end if
                    end if
                end if
            next
        forma.movenext
        wend
        forma.close
        set forma=nothing
        %>
    </select>
  </div>
<%
else
	%>
	<input type="hidden" name="FormaID" id="FormaID" value="0_0" />
	<%
end if
%>


<%
if parcelasDe<>"" then
	%>
	<div class="col-md-2">
	<%
	if MetodoID=8 or MetodoID=10 then
		%>
		<input type="hidden" value="1" name="NumeroParcelas" />
		<%
	else
		%>
		<label for="NumeroParcelas">Parcelas</label><br />
		<select onchange="geraParcelas('S');" id="NumeroParcelas" class="form-control disable" name="NumeroParcelas">
		<%
	while parcelasDe<=parcelasAte
		%><option value="<%=parcelasDe%>"<%if parcelasDe=NumeroParcelas then%> selected<%end if%>><%=parcelasDe%></option>
		<%
		parcelasDe=parcelasDe+1
	wend
		%>
		</select>
		<%
	end if
	%>
	</div>
	<%
else
	if II="0_0" then
		if II = "0_0" and data("sysActive")=0 then
			geraParcelas = "geraParcelas('S');"
		end if
		if data("sysActive")=0 then
			NumeroParcelas = 1
		end if
		%><%'=II%>
		<div class="col-md-2">
			<label>Parcelas</label><br>
			<input type="number" name="NumeroParcelas" id="NumeroParcelas" value="<%=NumeroParcelas%>" class="form-control text-right disable" onchange="geraParcelas('S');" min="1" required maxlength="3">
		</div>
		<div class="col-md-1">
			<label>Intervalo</label><br>
			<input type="number" name="Recurrence" id="Recurrence" value="<%=data("Recurrence")%>" class="form-control text-right disable" onchange="geraParcelas('S');" min="1" required maxlength="3">
		</div>
		<div class="col-md-2">
			<label>&nbsp;</label><br />
			<select class="form-control disable" name="RecurrenceType" onchange="geraParcelas('S');">
				<option value="d"<%if data("RecurrenceType")="d" then%> selected="selected"<%end if%>>Dia(s)</option>
				<option value="m"<%if data("RecurrenceType")="m" then%> selected="selected"<%end if%>>M&ecirc;s(es)</option>
				<option value="yyyy"<%if data("RecurrenceType")="yyyy" then%> selected="selected"<%end if%>>Ano(s)</option>
			</select>
		</div>
		<%
	end if
end if
%>
</div>
<%
if ref("FormaID")<>"" then
	%>
	<script>
    $(document).ready(function(e) {
        geraParcelas('S');
    });
</script>
	<%
end if
%>
