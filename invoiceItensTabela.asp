<!--#include file="connect.asp"-->
<!--#include file="RepasseLinhaFuncao.asp"-->
<input type="hidden" name="E" value="E" />
<table width="100%" class="table table-striped">
    <thead>
        <tr>
            <th>
            <div class="row">
            	<div class="col-xs-2">Executado</div>
	            <div class="col-xs-3">Profissional</div>
	            <div class="col-xs-2">Valor</div>
            	<div class="col-xs-2">Desconto</div>
            	<div class="col-xs-3">Detalhes</div>
            </div>
            </th>
            <th width="1%"></th>
        </tr>
     </thead>
     <tbody>
<%

I = ccur(req("I"))'I é item de invoice, que puxa seu grupo
Add = req("Add")
Remove = req("Remove")
Numera = 0
InvoiceID = req("InvoiceID")

function linhaItem(id, ValorUnitario, Executado, DataExecucao, HoraExecucao, HoraFim, ProfissionalID, Desconto, Numera)
	if ValorUnitario<>"" and isnumeric(ValorUnitario) then ValorUnitario=formatnumber(ValorUnitario,2) end if
	if Desconto<>"" and isnumeric(Desconto) then Desconto=formatnumber(Desconto,2) end if
	%>
    <tr><td>
    <div class="row">
    	<div class="col-xs-2"><span class="label label-info label-lg arrowed-in arrowed-right hidden"><%=Numera%></span>
        	<label><input type="radio" class="ace" name="Executado<%=id%>" required="required" id="Executado<%=id%>" value="S"<%
			if Executado="S" then response.Write(" checked") end if%> /><small class="lbl">Sim</small></label>
        	<label><input type="radio" class="ace" name="Executado<%=id%>" required="required" id="Executado<%=id%>" value="N"<%
			if Executado="N" then response.Write(" checked") end if%> /><small class="lbl">N&atilde;o</small></label>
        </div>
		<%
		call quickField("simpleSelect", "ProfissionalID"&id, " ", 3, ProfissionalID, "select id, NomeProfissional from profissionais where sysActive=1", "NomeProfissional", " onchange='repasses("&id&")' onchange='abreRateio("&n&")'")
		call quickField("text", "ValorUnitario"&id, " ", 2, ValorUnitario, " input-mask-brl text-right valor", "", "") 
		call quickField("text", "Desconto"&id, " ", 2, Desconto, " input-mask-brl text-right desconto", "", "") 
		%>
		<div class="col-md-3"><button type="button" class="btn btn-info btn-block" onclick="rateio(<%=id%>);"><i class="far fa-chevron-down"></i> Detalhes <i class="far fa-user-md"></i></button></div>
    </div>
	<div class="row expandRateio" id="divRateio<%=id%>">
        <div class="col-xs-2"></div>
		<%
		call quickField("datepicker", "DataExecucao"&id, "Data de Execu&ccedil;&atilde;o", 3, DataExecucao, " input-sm", "", "")
		call quickField("text", "HoraExecucao"&id, "Hora In&iacute;cio", 2, HoraExecucao, " input-mask-time input-sm", "", "")
		call quickField("text", "HoraFim"&id, "Hora Fim", 2, HoraFim, " input-mask-time input-sm", "", "")
		%>
		<div class="col-xs-3"><label>&nbsp;</label><br />
		
        <div class="btn-group pull-right">
            <button class="btn btn-sm btn-primary dropdown-toggle" data-toggle="dropdown"><i class="far fa-plus"></i> Adicionar <i class="far fa-chevron-down"></i></button>
            <ul class="dropdown-menu dropdown-primary">
                <li><a href="javascript:AddRepasse('<%=id%>', 1, 'F');">Fun&ccedil;&atilde;o ou repasse</a></li>
                <li><a href="javascript:AddRepasse('<%=id%>', 1, 'M');">Material ou medicamento</a></li>
            </ul>
        </div>
    </div>
    <div class="spacer">&nbsp;</div>
	<div class="col-md-12" id="divRepasses<%=id%>"><!--#include file="divRepasses.asp"--></div>
    </div></td>



	<td><button type="button" class="btn btn-danger" onClick="Remove(<%=id%>);"><i class="far fa-remove"></i></button></td></tr>

<%
end function

if ref("E")="" then
	if I=0 then
		str = "|-1|"
	else
		str = "db"
	end if
else
	str = ref("str")
end if


if isnumeric(Remove) and Remove<>"" then
	str = replace(str, "|"&Remove&"|", "")
end if

'response.Write(ref("str"))

contaParalela = 0
if str="db" then
	set pitem = db.execute("select * from itensinvoice where id="&I)
	if not pitem.EOF then
		ItemID = pitem("ItemID")
		set itens = db.execute("select p.id, p.NomeProcedimento, i.* from itensinvoice as i left join procedimentos as p on i.ItemID=p.id where i.ItemID="&ItemID&" and InvoiceID="&InvoiceID&" order by i.id")
		while not itens.eof
			Numera = Numera+1
			if not isnull(itens("HoraExecucao")) then HoraExecucao=right(itens("HoraExecucao"), 8) else HoraExecucao="" end if
			if not isnull(itens("HoraFim")) then HoraFim=right(itens("HoraFim"), 8) else HoraFim="" end if
			call( linhaItem(itens("id"), itens("ValorUnitario"), itens("Executado"), itens("DataExecucao"), HoraExecucao, HoraFim, itens("ProfissionalID"), itens("Desconto"), Numera) )
			newstr = newstr&"|"&itens("id")&"|"
		itens.movenext
		wend
		itens.close
		set itens = nothing
	end if
else
	spl = split(str, "|")
	for i=0 to ubound(spl)
		if spl(i)<>"" then
			if ccur(spl(i))<contaParalela then
				contaParalela = ccur(spl(i))
			end if
			Numera = Numera+1
			call( linhaItem(spl(i), ref("ValorUnitario"&spl(i)), ref("Executado"&spl(i)), ref("DataExecucao"&spl(i)), ref("HoraExecucao"&spl(i)), ref("HoraFim"&spl(i)), ref("ProfissionalID"&spl(i)), ref("Desconto"&spl(i)), Numera) )
			newstr = newstr&"|"&spl(i)&"|"
		end if
	next
end if

if isnumeric(Add) and Add<>"" then
	if ccur(Add)>0 then
		c=0
		while c<ccur(Add)
			c=c+1
			contaParalela = contaParalela-1
			Numera = Numera+1
			call( linhaItem(contaParalela, ref("Valor"), "", "", "", "", "", ref("Desconto"), Numera) )
			newstr = newstr&"|"&contaParalela&"|"
		wend
	end if
end if
%>
    </tbody>
    <tfoot>
      <tr>
    	<td colspan="6"><%=Numera%> itens</td>
        <td colspan="2"><%if c>1 then%><button type="button" class="btn btn-danger btn-block btn-xs" onClick="removeItem('Grupo', <%=ItemID%>); $('#modal-table').modal('hide');"><i class="far fa-remove"></i> Remover Todos</button><%end if%></td>
      </tr>
    </tfoot>
</table>

<input type="hidden" name="str" value="<%=newstr%>" />

<script language="javascript">
	<!--#include file="jQueryFunctions.asp"-->
	function rateio(n){
		if($('#divRateio'+n).css("display")=="none"){
			$('#divRateio'+n).slideDown(500);
		}else{
			$('#divRateio'+n).slideUp(500);
		}
	}

	function repasses(Item){
		$.ajax({
			type:"POST",
			url:"chamaDivRepasses.asp?Item="+Item+"&Change=Profissional",
			data:$("#formItem").serialize(),
			success:function(data){
				$("#divRepasses"+Item).html(data);
			}
		});
	}
	$("#Quantidade").val(<%=Numera%>);
</script>