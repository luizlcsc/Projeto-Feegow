<!--#include file="connect.asp"-->

<%
if req("I")<>"N" then
	set op = db.execute("select * from cliniccentral.licencasusuariosmulti where id="&req("I")&" and Cupom='"&session("Partner")&"'")
	if not op.eof then
		Nome = op("Nome")
		Email = op("Email")
		Senha = op("Senha")
	end if
end if
if ref("Email")<>"" and ref("Senha")<>"" then
	if req("I")="N" then
		db_execute("insert into cliniccentral.licencasusuariosmulti (Nome, Email, Senha, LicencaAtual, Admin, Cupom, Permissoes) values ('"&ref("Nome")&"', '"&ref("Email")&"', '"&ref("Senha")&"', '"&replace(session("Banco"), "clinic", "")&"', 0, '"&session("Partner")&"', '"&permissoesPadrao()&"')")
	else
		db_execute("update cliniccentral.licencasusuariosmulti set Nome='"&ref("Nome")&"', Email='"&ref("Email")&"', Senha='"&ref("Senha")&"' WHERE id="&req("I")&" AND Cupom='"&session("Partner")&"'")
	end if
	response.Redirect("./?P=Operadores&Pers=1")
end if
%>

<div class="widget-box transparent">
    <div class="widget-header widget-header-flat">
        <h4><i class="far fa-user blue"></i> CADASTRO DE OPERADOR</h4>
    </div>
</div>

<form method="post" action="">
    <div class="row">
      <div class="col-md-4 col-md-offset-4">
        <div class="row">
            <%=quickField("text", "Nome", "Nome", 12, Nome, "", "", "")%>
            <%=quickField("text", "Email", "E-mail", 12, Email, "", "", "")%>
            <%=quickField("password", "Senha", "Senha", 12, Senha, "", "", "")%>
            <div class="col-md-12 text-center">
            	<label>&nbsp;</label><br>
            	<button class="btn btn-sm btn-primary"><i class="far fa-save"></i> SALVAR</button>
            </div>
        </div>
      </div>
    </div>
</form>