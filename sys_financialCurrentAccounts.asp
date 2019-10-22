<!--#include file="connect.asp"-->
<!--#include file="DefaultForm.asp"-->
<%
tableName=request.QueryString("P")
id=request.QueryString("I")
if id="" then
	call DefaultForm(tableName, id)
else

	if ref("E")="E" then
		sql = "update sys_financialCurrentAccounts set Proprietario='"&ref("Proprietario")&"', AccountName='"&ref("AccountName")&"', AccountType="&refNull("AccountType")&", Holder='"&ref("Holder")&"', Document='"&ref("Document")&"',UsuariosConfirmadores='"&ref("UsuariosConfirmadores")&"', Bank="&refNull("Bank")&", Branch='"&ref("Branch")&"', CurrentAccount='"&ref("CurrentAccount")&"', CreditAccount="&refNull("CreditAccount")&", DaysForCredit='"&ref("DaysForCredit")&"', BestDay='"&ref("BestDay")&"', PercentageDeducted="&treatvalzero(ref("PercentageDeducted"))&", Currency='"&ref("Currency")&"', DueDay='"&ref("DueDay")&"', BestDay='"&ref("BestDay")&"', Empresa="&treatvalzero(ref("Empresa"))&", sysActive=1 where id="&id
		db_execute(sql)
		response.Write(sql)
		response.Redirect("?P=sys_financialCurrentAccounts&Pers=Follow")
	end if

	if id="N" then
		sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
		set vie = db.execute(sqlVie)
		if vie.eof then
			db_execute("insert into "&tableName&" (sysUser, sysActive) values ("&session("User")&", 0)")
			set vie = db.execute(sqlVie)
		end if
		response.Redirect("?P="&tableName&"&I="&vie("id")&"&Pers=1")
	end if

	set reg = db.execute("select * from "&tableName&" where id="&id)
	if reg.eof then
		response.Redirect("?P="&request.QueryString("P")&"&I=N&Pers=1")
	else
		id = reg("id")
		AccountType = reg("AccountType")
		rCurrency = reg("Currency")
	end if
	%>
	<%

	id=request.QueryString("I")
    call insertRedir(request.QueryString("P"), request.QueryString("I"))
    set reg = db.execute("select * from sys_financialcurrentaccounts where id="&request.QueryString("I"))

    %>
    <%=header(req("P"), "Cadastro de Conta Corrente", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
	<br>
	<div class="panel">
	<div class="panel-body">


	<form method="post" name="frm" id="frm" action="save.asp">

                <input type="hidden" name="I" value="<%=req("I")%>" />
                <input type="hidden" name="P" value="<%=req("P")%>" />
<%=header(req("P"), "Cadastro de Conta Corrente", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
	<input type="hidden" name="E" value="E" />
    <input type="hidden" name="id" value="<%=id%>" />
	<div class="row">
    	<div class="col-md-4">
        	<div class="row">
			<%=quickField("select", "AccountType", "Tipo de Conta", "12", AccountType, "select * from sys_financialaccounttype where sysActive=1", "AccountType", "")%>
            <%=quickField("empresa", "Empresa", "Unidade", "10", reg("Empresa"), "", "", "")%>

			<input type="hidden" name="Moeda" value="BRL" />
            </div>
        </div>
		<div class="col-md-8" id="accountDetails">
			carregando...
		</div>
	</div>
	</form>

</div>
</div>
	<script language="javascript">

    saveAll = _ => {
        $("#frm").submit();
    };

	$(document).ready(function(e) {
        <%call formSave("frm, #WS, #frmRegras", "save", "")%>
        document.querySelector('#Salvar').addEventListener('click', saveAll, false);
        if ($("#AccountType").val() === '3') {
            document.querySelector('#Salvar').removeEventListener('click', saveAll, false);
        }
    });

	function accountDetails(){
		$.ajax({
			type: "POST",
			url: "accountDetails.asp",
			data: $('#frm').serialize(),
			success: function( data )
			{
			  $("#accountDetails").html(data);
			}
		});
	}

	$("#AccountType").change(function(){
		accountDetails();
		document.querySelector('#Salvar').addEventListener('click', saveAll, false);
		if ($("#AccountType").val() === '3') {
		   document.querySelector('#Salvar').removeEventListener('click', saveAll, false);
		}
	});

	accountDetails();

	let persistPercentualConfiguracao = ()=>{

	};

	document.querySelector('#Salvar').addEventListener('click', persist, false);
	function persist() {
		persistPercentualConfiguracao(saveAll);
	}
	</script>
	<%
end if
%>