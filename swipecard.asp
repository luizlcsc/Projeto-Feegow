<%
Leitor = ref("Leitor")

'GOLDEN CROSS
'%cristiane maia ferreira cruz?
';4039101267027714273879016904200000000?

'UNIMED-RIO
'%silvio maia da silva?
';00370000008906320=041709=003706313107?

'BRADESCO
'%b9601770557227188013 caina fernandes do couto  16065010140502   ?
';9601770557227188013=16065010140502000?



Leitor = replace(replace(replace(replace(Leitor, "%", ""), "?", ""), chr(10), ""), chr(13), "")

if Leitor<>"" then
	spl = split(Leitor, ";")
	Nome = spl(0)
	Carteira = mid(spl(1), 15, 10)
	
	Validade = ref("Validade")
	Validade = right(Validade, 4)&"-"&mid(Validade, 4, 2)&"-"&left(Validade, 2)
	response.Redirect("index.php?Nome="&Nome&"&Carteira="&Carteira&"&Validade="&Validade)
end if
%>

<br>
Nome: <%=Nome%><br>
Carteira: <%=Carteira%><br>
Validade: <%=Validade%><br>


<br>
<br>


Passar carteirinha
<form method="post" action="" id="frmLeitor">
Validade<br />
<input type="date" required="required" name="Validade" id="Validade" value="<%=ref("Validade")%>" />
<br />
<br />

<textarea id="Leitor" name="Leitor" placeholder="Clique aqui e passe o cart&atilde;o"></textarea>
<div style="border:1px dotted #960; display:none" id="Passando"></div>

<input type="submit" style="display:none" value="Passar">
</form>
<%
if ref("Leitor")<>"" then
	
end if
%>
<script language="javascript">
document.getElementById('Validade').focus();

var typingTimer;
$(document).ready(function(){
  $("#Leitor").keyup(function(){
		$("#Passando").css("display", "block");
		$("#Passando").html("Passe a carteirinha no leitor...");
		$("#Leitor").css("visibility", "hidden");
		clearTimeout(typingTimer);
		if ($("#Leitor").val) {
			typingTimer = setTimeout(f_envia, 400);
		}
  });
});
/*
var typingTimer;
$(document).ready(function(){
  $("#search").keyup(function(){
	if($("#search").val().length>0){
		clearTimeout(typingTimer);
		if ($("#search").val) {
			typingTimer = setTimeout(f_envia, 400);
		}
	}else{
		$("#resultSelect").css("display", "none");
		$("#").val("0");
	}
  });
  $("#search").click(function(){
	this.select();
  });
});
*/
function f_envia(){
	if($("#Leitor").val()!=""){
		$("#frmLeitor").submit();
	}
}
</script>