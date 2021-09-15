<!--#include file="connect.asp"-->
<div class="modal-header">
    <button type="button" onclick="$('.parcela').prop('checked', false); $('#pagar').fadeOut();" class="close" data-dismiss="modal">×</button>

    <h4 class="lighter blue">Detalhes do Cheque</h4>
</div>
<form id="formCheque" method="post" action="">
<div class="modal-body">
<%

function CurrentAccountsSimpleSelect(id, associations, selectedValue, others, accountType)
	splAssociations = split(associations,", ")
	%>
		<select class="form-control select2-single" id="<%= id %>" name="<%= id %>"<%= others %>>
			<option value="">&nbsp;</option>
			<%
			for t=0 to uBound(splAssociations)
				if splAssociations(t)="0" then
					%>
					<option value="0"<% If selectedValue="0" Then %> selected="selected"<% End If %>>Posi&ccedil;&atilde;o (Empresa)</option>
                    <option value="PRO"<% If selectedValue="PRO" Then %> selected="selected"<% End If %>>Profissional Executor</option>
					<%
				elseif splAssociations(t)="00" then
					%>
					<option value="0"<% If selectedValue="0" Then %> selected="selected"<% End If %>>Posi&ccedil;&atilde;o (Empresa)</option>
					<%
				else
					set Associations = db.execute("select * from cliniccentral.sys_financialaccountsAssociation where id="&splAssociations(t))
					while not Associations.EOF
                        sql = Associations("sql")
                        
                        if accountType<>"" and splAssociations(t)="1" then
                            sql = replace(sql,"where","where  accounttype in("&accountType&") and")
                        end if
                        
						set AssRegs = db.execute(sql&" limit 10000")
						while not AssRegs.EOF
						%><option value="<%=Associations("id")&"_"&AssRegs("id")%>"<%if Associations("id")&"_"&AssRegs("id")=selectedValue then%> selected="selected"<%end if%>><%= AssRegs(""&Associations("column")&"") %> &raquo; <%= Associations("AssociationName") %></option>
						<%
						AssRegs.movenext
						wend
						AssRegs.close
						set AssRegs = nothing
					Associations.movenext
					wend
					Associations.close
					set Associations=nothing
				end if
			next
			%>
		</select>
	<%
end function

I = req("I")
CD = req("TipoCheque")

'tipo cheque D eh contas a pagar; C eh a receber
if CD="C" then
    set cheque = db.execute("select c.*, lu.Nome NomeUsuario, mov.sysDate, ca.AccountName, b.BankName from sys_financialissuedchecks c "&_
     " LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=c.AccountID "&_
     " LEFT JOIN sys_financialbanks b ON b.id=ca.Bank "&_
     " INNER JOIN sys_financialmovement mov ON mov.id=c.MovementID "&_
     " LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=mov.sysUser where c.id="&I)
    if not cheque.eof then
%>
<strong>Conta: </strong> <%=cheque("AccountName")%><br>
<strong>Banco: </strong> <%=cheque("BankName")%><br>
<strong>Número:</strong> <%=cheque("CheckNumber")%> <br>
<strong>Data do cheque: </strong><%=cheque("CheckDate")%> <br>
<strong>Usuário: </strong> <%=cheque("NomeUsuario")%><br>
<strong>Data do pagamento: </strong><%=cheque("sysDate")%> <br>

<%
    end if
else
    set cheque = db.execute("select * from sys_financialreceivedchecks where id="&I)
    if not cheque.eof then
        %>
        <div class="row">
            <%=quickfield("simpleSelect", "BankID", "Banco", 4, cheque("BankID"), "select id, concat(BankNumber, ' - ', BankName) Banco from sys_financialbanks", "Banco", "")%>
            <%=quickfield("text", "Branch", "N&deg; da Agência", 2, cheque("Branch"), "", "", "")%>
            <%=quickfield("text", "Account", "N&deg; da Conta", 2, cheque("Account"), "", "", "")%>
            <%=quickfield("text", "CheckNumber", "N&deg; do Cheque", 2, cheque("CheckNumber"), "", "", "")%>
            <%=quickfield("datepicker", "CheckDate", "Data do Cheque", 2, cheque("CheckDate"), "", "", "")%>
        </div>
        <div class="row">
            <%=quickfield("text", "Holder", "Emitente", 6, cheque("Holder"), "", "", "")%>
            <%=quickfield("text", "Document", "CPF / CNPJ", 3, cheque("Document"), "", "", "")%>
            <%=quickfield("text", "BorderoID", "N&deg; do Border&ocirc;", 3, cheque("BorderoID"), "", "", "")%>
        </div>
        <div class="row">
            <div class="col-md-6">
                <label for="ContaCorrente">Localiza&ccedil;&atilde;o</label><br>
                <%=CurrentAccountsSimpleSelect("ContaCorrente", "1, 2, 4, 5, 6", cheque("AccountAssociationID")&"_"&cheque("AccountID"), "","1,2")%>
            </div>
            <div class="col-md-3" id="divDataMovimentacao">
                <label for="DataMovimentacao">Data da Movimenta&ccedil;&atilde;o</label><br />
                <%=quickfield("datepicker", "DataMovimentacao", "", 3, date(), "", "", "")%>
            </div>
            <%=quickfield("simpleSelect", "StatusID", "Status", 3, cheque("StatusID"), "select * from cliniccentral.chequestatus", "Descricao", "")%>
            <div class="col-md-3" id="divDataCompensacao">
                <label for="DataCompensacao">Data da Compensa&ccedil;&atilde;o</label><br />
                <% 
                    if cheque("datacompensacao") <> "" then
                        response.write(quickfield("datepicker", "DataCompensacao", "", 3, cheque("datacompensacao"), "", "", ""))
                    else
                        response.write(quickfield("datepicker", "DataCompensacao", "", 3, date(), "", "", ""))
                    end if 
                %>
            </div>
        </div>



        <%
    end if
end if
%>
</div>
<%
if CD<>"C" then
%>
<div class="modal-footer">
	<button class="btn btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
</div>
<%
end if
%>
</form>
<%
if CD<>"C" then
%>
<script>
<!--#include file="jQueryFunctions.asp"-->
$("#formCheque").submit(function(){
	$.post("saveChequeRecebido.asp?I=<%=I%>&Origem=<%=ref("Origem")%>", $("#formCheque").serialize(), function(data, status){ eval(data) });
	return false;
});

$("#ContaCorrente").change(function(){
	if($("#ContaCorrente").val()!="<%= cheque("AccountAssociationID")&"_"&cheque("AccountID") %>"){
		$("#divDataMovimentacao").fadeIn();
	}else{
		$("#divDataMovimentacao").fadeOut();
	}
});

$("#StatusID").change(function(){
	if($("#StatusID").val()=="4"){
		$("#divDataCompensacao").fadeIn();
	}else{
		$("#divDataCompensacao").fadeOut();
	}
});

$("#divDataMovimentacao").css("display", "none");
if ("<%=cheque("datacompensacao") %>"==""){
    $("#divDataCompensacao").css("display", "none");
}


<% IF cheque("StatusID") = 3 THEN %>
    $("#formCheque select,#formCheque input,#formCheque button").attr("disabled","disabled");
<% END IF %>


setTimeout(function(){
    $("#ContaCorrente").select2();
    }, 1000);

</script>
<%
end if
%>