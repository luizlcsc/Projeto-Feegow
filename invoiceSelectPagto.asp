<!--#include file="connect.asp"-->
<%
InvoiceID = req("I")
CD = req("T")

sql = "select i.*, (select count(*) from sys_financialmovement where Type='Bill' and InvoiceID=i.id) NumeroParcelas from sys_financialinvoices i where i.id="&InvoiceID
set data = db.execute(sql)

NumeroParcelas = 1
if not data.eof then
    NumeroParcelas = ccur(data("NumeroParcelas"))
end if

if not data.eof then
    if data("sysActive")=0 then
        if ref("CompanyUnitID")="" then
            UnidadeID = session("UnidadeID")
        else
            UnidadeID = ref("CompanyUnitID")
        end if
    else
        if ref("CompanyUnitID")="" then
            UnidadeID = data("CompanyUnitID")
        else
            UnidadeID = ref("CompanyUnitID")
        end if
    end if
else
    UnidadeID = session("UnidadeID")
end if


if not data.eof then
    II = data("FormaID")&"_"&data("ContaRectoID")   
end if

if ref("FormaID")<>"" then
    II = ref("FormaID")
end if

count = 0


if CD="D" then
    OcultaSelect = "S"
else
    if (session("Banco")="clinic100000X" or session("Banco")="clinic2901") and 1=1 then
        set pp = db.execute("select * from planopagto")
        selectFormas = "<div class=""col-md-6""> <input type='hidden' name='FormaID' id='FormaID' value='0_0'> <label for=""FormaID"">Plano de Pagamento</label><br /><select name=""PlanoPagto"" id=""PlanoPagto"" class=""form-control disable"" onchange=""planPag($(this).val()); allRepasses();"">"
            selectFormas = selectFormas &"<option value=''></option>"
            while not pp.eof
                selectFormas = selectFormas &"<option value='"& pp("id") &"'>"& pp("NomePlano") &"</option>"
                optionSelect = "S"
            pp.movenext
            wend
            pp.close
            set pp=nothing
        selectFormas = selectFormas & "</select>"
    else
    
        eventt = " onchange=""formaRecto(); allRepasses();"" "
        if req("chamaParcelas") = "N" then
            eventt = "  "
        end if
        
        selectFormas = "<div class=""col-md-6""><label for=""FormaID"">Forma de Pagamento</label><br /><select name=""FormaID"" id=""FormaID"" required class=""form-control disable"" "&eventt&">"
        selectFormas = selectFormas & "<option value=''>Selecione a forma de pagamento</option>"
        selectFormas = selectFormas & "<option value='0_0'"
        if II="0_0" then
            selectFormas = selectFormas & " selected='selected'"
        end if
        selectFormas = selectFormas & ">Diversas</option>"

        sqlForma = "select f.*, m.PaymentMethod from sys_formasrecto f left join sys_financialpaymentmethod m on m.id=f.MetodoID order by PaymentMethod"
        set forma = db.execute(sqlForma)

        sqlFormaNome = "select distinct m.PaymentMethod as nome from sys_formasrecto f left join sys_financialpaymentmethod m on m.id=f.MetodoID order by PaymentMethod"
        set formaNome = db.execute(sqlFormaNome)

        Dim diListNome
        Set diListNome = Server.CreateObject("Scripting.Dictionary")
        while not formaNome.eof
            t = formaNome("nome")
            'response.write(formaNome("nome"))
            diListNome.Add t, t   
        formaNome.movenext 
        wend
        formaNome.close
        set formaNome=nothing

        while not forma.eof
            FRID = forma("id")
            Unidades = forma("Unidades")
            UnidadesExcecao = forma("UnidadesExcecao")
            selectFormas = selectFormas & "<optgroup label='"&forma("PaymentMethod")&"'>"      
            if forma("MetodoID")=1 OR forma("MetodoID")=2 OR forma("MetodoID")=7 then
                if Unidades="|ALL|" OR (Unidades="|ONLY|" and instr(UnidadesExcecao, "|"&UnidadeID&"|")) OR (Unidades="|EXCEPT|" and instr(UnidadesExcecao, "|"&UnidadeID&"|")=0) then
                    FormaID = forma("id")&"_0"
                    if II=FormaID then
                        selected = " selected "
                        if ref("FormaID")<>"" then
                            ParcelasDe = forma("ParcelasDe")
                            ParcelasAte = forma("ParcelasAte")
                            MetodoID = forma("MetodoID")
                        end if
                    else
                        selected = ""
                    end if
                    optionSelect = "S"
                    selectFormas = selectFormas & "<option data-frid='"& FRID &"' value='"&FormaID&"' "&selected&">"&forma("PaymentMethod") & ": " & escreveParcelas (forma("ParcelasDe"), forma("ParcelasAte")) &"</option>"
                end if
            else
                contasSelecionadas = trim(forma("Contas")&" ")
                if instr(contasSelecionadas, "|ALL|") then
                    sqlWhereContas = ""
                elseif contasSelecionadas<>"" then
                    sqlWhereContas = " AND id IN("&replace(contasSelecionadas, "|", "")&")"
                end if
                set contas = db.execute("select * from sys_financialcurrentaccounts where AccountType=(select AccountTypesC from sys_financialpaymentmethod where id="&treatvalzero(forma("MetodoID"))&") AND Empresa="&treatvalzero(UnidadeID) & sqlWhereContas)



                                             
 
                 
                while not contas.eof
                    FormaID = forma("id")&"_"&contas("id")
                    if II=FormaID then
                        selected = " selected "
                        if ref("FormaID")<>"" then
                            ParcelasDe = forma("ParcelasDe")
                            ParcelasAte = forma("ParcelasAte")
                            MetodoID = forma("MetodoID")
                        end if
                    else
                        selected = ""
                    end if
                    optionSelect = "S"
                    selectFormas = selectFormas & "<option data-frid='"& FRID &"' value='"&FormaID&"' "& selected &">"&forma("PaymentMethod")& " - "&contas("AccountName")&": " & escreveParcelas (forma("ParcelasDe"), forma("ParcelasAte")) & "</option>"
                contas.movenext
                wend              
                  

                contas.close
                set contas=nothing
            end if

       selectFormas = selectFormas & "</optgroup>"

      
        forma.movenext 
        wend


        



        forma.close
        set forma=nothing

        selectFormas = selectFormas & "</select>"
    end if
end if


'response.write(selectFormas)
%>







<div class="clearfix form-actions">

<%

if optionSelect = "" then
    OcultaSelect = "S"
end if
if OcultaSelect="" then
    response.Write(selectFormas)



'        while not forma.eof
'            spl = split(forma("Contas"), ", ")
'            for i=0 to ubound(spl)
'                if spl(i)<>"" then
'                    conta = replace(spl(i), "|", "")
'                    if isnumeric(conta) then
'                        set contas = db.execute("select * from sys_financialcurrentaccounts where id="&conta)
'                        if not contas.eof then
'							if UnidadeID = contas("Empresa") then
'								If II=forma("id")&"_"&contas("id") or (II="" and data("FormaID")=forma("id") and data("ContaRectoID")=contas("id"))  then
'									'and Acao="Forma" Then
'									selected = " selected=""selected"""
'									MetodoID = forma("MetodoID")
'									MinimoParcelas = forma("ParcelasDe")
'									if MetodoID=8 or MetodoID=10 then
'										MinimoParcelas = 1
'									end if
'									geraParcelas = "geraParcelas('S');"
'									parcelasDe = forma("ParcelasDe")
'									parcelasAte = forma("ParcelasAte")
'								else
'									selected = ""
'								End If

'								response.Write("<option value="""&forma("id")&"_"&contas("id")&""" selected >"&forma("PaymentMethod")&" - "&contas("AccountName")&": De "&forma("ParcelasDe")&" a "&forma("ParcelasAte")&" parcelas</option>")

'							end if
'                        end if
'                    end if
'                end if
'            next
'        forma.movenext
'        wend
'        forma.close
'        set forma=nothing
        %>
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
        <% if req("chamaParcelas")<>"N" then %>
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

        <% if req("chamaParcelas")<>"N" then %>
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
        <% end if %>

		<%
	end if
end if
%>
</div>
<script type="text/javascript">
<%
if ref("FormaID")<>"" and req("chamaParcelas")<>"N" then
	%>
    $(document).ready(function(e) {
        geraParcelas('S');
    });
	<%
end if

if req("FormaID")<>"" and isnumeric(req("FormaID")) then
    inps = split(ref("inputs"), ", ")
    FRID = req("FormaID")
    for i = 0 to ubound(inps)
        Desconto = 0
        Acrescimo = 0
        ProcedimentoID = ref("ItemID"& inps(i))
        if ProcedimentoID<>"" and ProcedimentoID<>"0" and isnumeric(ProcedimentoID) then

            sql = "SELECT * FROM sys_formasrecto WHERE (Procedimentos LIKE '%|ALL|%' OR (Procedimentos LIKE '%|" & ProcedimentoID & "|%' AND Procedimentos LIKE '%|ONLY|%') OR (Procedimentos LIKE '%|EXCEPT|%' AND Procedimentos NOT LIKE '%|"& ProcedimentoID &"|%')) AND (Unidades = '|ALL|' OR (Unidades = '|ONLY|' AND UnidadesExcecao LIKE '%|" & ref("CompanyUnitID") & "|%') OR (Unidades = '|EXCEPT|' AND UnidadesExcecao NOT LIKE '%|" & ref("CompanyUnitID") & "|%')) AND id=" & FRID

            set vcaFR = db.execute(sql)
            if not vcaFR.eof then
                Quantidade = ccur(ref("Quantidade"& inps(i)))
                ValorUnitario = ccur(ref("ValorUnitario"& inps(i)))
                Desconto = ccur(vcaFR("Desconto"))
                tipoDesconto = vcaFR("tipoDesconto")
                if tipoDesconto="V" then
                    Desconto = Desconto * Quantidade
                else
                    Fator = ccur(Desconto)/100
                    Desconto = Fator * ValorUnitario
                end if
                Acrescimo = ccur(vcaFR("Acrescimo"))
                tipoAcrescimo = vcaFR("tipoAcrescimo")
                if tipoAcrescimo="V" then
                    Acrescimo = Acrescimo * Quantidade
                else
                    Fator = ccur(Acrescimo)/100
                    Acrescimo = Fator * ValorUnitario
                end if
            end if
        end if
        %>
        //$("#Desconto<%=inps(i)%>").val("<%=fn(Desconto)%>").change();
        var NovoDesconto = "<%=fn(Desconto)%>";
        var DescontoAnterior = $("#Desconto<%=inps(i)%>").attr("data-desconto")
        if(NovoDesconto > DescontoAnterior){
            $("#Desconto<%=inps(i)%>").val("<%=fn(Desconto)%>").change();
        }else{
            $("#Desconto<%=inps(i)%>").val(DescontoAnterior).change();
        }

        $("#Acrescimo<%=inps(i)%>").val("<%=fn(Acrescimo)%>").change();
        /*var NovoAcrescimo = "<%=fn(Acrescimo)%>";
        var AcrescimoAnterior = $("#Acrescimo<%=inps(i)%>").attr("data-acrescimo")
        if(NovoAcrescimo > AcrescimoAnterior){
            $("#Acrescimo<%=inps(i)%>").val("<%=fn(Acrescimo)%>").change();
        }else{
            $("#Acrescimo<%=inps(i)%>").val(AcrescimoAnterior).change();;
        }*/
        <%
    next
end if
    %>
$(function(){
    $("#FormaID").on('change', function(){

        var val = $(this).val()
        if(val == "0_0"){
            $(".CampoDesconto").val("0,00").change();
        }
    });
});
</script>
