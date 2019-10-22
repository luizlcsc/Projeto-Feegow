<!--#include file="connect.asp"-->
<%
Conta = req("Conta")
if Conta<>"" then
	splConta = split(Conta, "_")
	Assoc = splConta(0)
	id = splConta(1)
	if Assoc="4" then
		Tabela = "funcionarios"
	elseif Assoc="5" then
		Tabela = "profissionais"
	end if
	set cx = db.execute("select c.* from caixa c LEFT JOIN sys_users su on su.Table='"&Tabela&"' and idInTable="&id&" where c.sysUser=su.id order by dtAbertura desc limit 100")
	if cx.eof then
		%>
		<br>Nenhum caixa encontrado para o usuário selecionado.
		<%
	else
		%>
		<label>Caixas do usuário</label>
		<select id="AccountID" name="AccountID" onChange="$('#DateFrom').val( $(this).find(':selected').attr('data-DateFrom') )" required class="form-control">
        <option value="">Selecione um caixa</option>
		<%
		while not cx.eof
			if isnull(cx("dtFechamento")) then
				Descricao = "Aberto em "&formatdatetime(cx("dtAbertura"), 2)
			else
				Descricao = "De "&formatdatetime(cx("dtAbertura"), 2)&" a "&formatdatetime(cx("dtFechamento"), 2)
			end if
			%>
			<option data-DateFrom="<%=formatdatetime(cx("dtAbertura"), 2)%>" value="7_<%=cx("id")%>"><%=Descricao%></option>
			<%
		cx.movenext
		wend
		cx.close
		set cx=nothing
		%>
		</select>
        <input type="hidden" name="DateFrom" id="DateFrom" value="">
        <input type="hidden" name="DateTo" id="DateTo" value="<%=date()%>">
		<%
	end if
end if
%>
