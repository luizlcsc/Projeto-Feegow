<!--#include file="connect.asp"-->

<%
if req("I")<>"N" then
	set op = db.execute("select * from cliniccentral.licencas where id="&req("I")&" and Cupom='"&session("Partner")&"'")
	if not op.eof then
		NomeEmpresa = op("NomeEmpresa")
		NomeContato = op("NomeContato")
		Status = op("Status")
		set adm = db.execute("select * from cliniccentral.licencasusuarios where LicencaID="&req("I")&" AND Admin=1 LIMIT 1")
		if not adm.EOF then
			NomeAdmin = adm("Nome")
			EmailAdmin = adm("Email")
			SenhaAdmin = adm("Senha")
		end if
	end if
end if
if ref("NomeEmpresa")<>"" and ref("NomeContato")<>"" then
	if req("I")="N" then
		db_execute("insert into cliniccentral.licencas (NomeContato, NomeEmpresa, Cliente, IP, Ativo, LocaisAcesso, Logo, FimTeste, Status, Cupom) values ('"&ref("NomeContato")&"', '"&ref("NomeEmpresa")&"', 515, '"&request.ServerVariables("REMOTE_ADDR")&"', 1, 'Todos', '"&session("Partner")&".png', NOW(), 'C', '"&session("Partner")&"')")
		set pult = db.execute("select id from cliniccentral.licencas where Cupom='"&session("Partner")&"' order by id desc limit 1")
		db_execute("insert into cliniccentral.licencasusuarios (Nome, Tipo, Email, Senha, LicencaID, Admin) values ('"&ref("NomeContato")&"', 'NomeProfissional', '"&ref("EmailAdmin")&"', '"&ref("SenhaAdmin")&"', "&pult("id")&", 1)")
		%>
		<!--#include file="generatePartner.asp"-->
		<%
	else
		db_execute("update cliniccentral.licencas set NomeContato='"&ref("NomeContato")&"', NomeEmpresa='"&ref("NomeEmpresa")&"', `Status`='"&ref("Status")&"' WHERE id="&req("I")&" AND Cupom='"&session("Partner")&"'")
		db_execute("update cliniccentral.licencasusuarios set Nome='"&ref("NomeContato")&"', Email='"&ref("EmailAdmin")&"', Senha='"&ref("SenhaAdmin")&"' WHERE LicencaID="&req("I")&" AND Admin=1 LIMIT 1")
	end if
	response.Redirect("./?P=Licencas&Pers=1")
end if
%>

<div class="widget-box transparent">
    <div class="widget-header widget-header-flat">
        <h4><i class="far fa-hospital blue"></i> CADASTRO DE LICENÇA</h4>
    </div>
</div>

<form method="post" action="">
    <div class="row">
      <div class="col-md-4 col-md-offset-4">
        <div class="row">
        <%
        if 0 then
        %>
            <%=quickField("text", "NomeEmpresa", "Nome da Empresa", 12, NomeEmpresa, "", "", " required")%>
            <%=quickField("text", "NomeContato", "Responsável", 12, NomeContato, "", "", " required")%>
            <%=quickField("email", "EmailAdmin", "E-mail do Administrador", 12, EmailAdmin, "", "", " required")%>
            <%=quickField("password", "SenhaAdmin", "Senha do Administrador", 12, SenhaAdmin, "", "", " required")%>
            <%=quickField("simpleSelect", "Status", "Status", 12, Status, "select 'C' id, 'Ativo' NomeSta UNION ALL select 'B', 'Bloqueado'", "NomeSta", "")%>
            <div class="col-md-12 text-center">
            	<label>&nbsp;</label><br>
            	<button class="btn btn-sm btn-primary"><i class="far fa-save"></i> SALVAR</button>
            </div>
            <%
            else
            %>
<div class="alert alert-warning">
    Para criar a licença por favor entre em contato conosco.
</div>
            <%
            end if
            %>
        </div>
      </div>
    </div>
</form>