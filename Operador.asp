<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
Ativo="on"
if req("I")<>"N" then
	set op = dbc.execute("select * from cliniccentral.licencasusuariosmulti where id="&req("I")&" and Cupom='"&session("Partner")&"'")
	if not op.eof then
		Nome = op("Nome")
		Email = op("Email")
		Senha = op("Senha")
		Ativo = op("Ativo")
	end if
end if
if ref("Email")<>"" and ref("Senha")<>"" then
	if req("I")="N" then
		dbc.execute("insert into cliniccentral.licencasusuariosmulti (Nome, Email, Senha, LicencaAtual, Admin, Cupom, Permissoes) values ('"&ref("Nome")&"', '"&ref("Email")&"', '"&ref("Senha")&"', '"&replace(session("Banco"), "clinic", "")&"', 0, '"&session("Partner")&"', '"&permissoesPadrao()&"')")
	else
		dbc.execute("update cliniccentral.licencasusuariosmulti set Ativo='"&ref("Ativo")&"', Nome='"&ref("Nome")&"', Email='"&ref("Email")&"', Senha='"&ref("Senha")&"' WHERE id="&req("I")&" AND Cupom='"&session("Partner")&"'")
	end if
	response.Redirect("./?P=Operadores&Pers=1")
end if
%>

<script >
$(".crumb-active a").html("Operadore");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Editar");
    $(".crumb-icon a span").attr("class", "far fa-table");
</script>
<div class="panel mt15">

    <div class="panel-body">
        <form method="post" action="">
            <div class="row">
              <div class="col-md-4 col-md-offset-4">
                <div class="row">
                    <%=quickField("text", "Nome", "Nome", 10, Nome, "", "", "")%>
                    <div class="col-md-2">
                        <label for="Ativo">Ativo</label><br />
                            <div class="switch round">
                                <input <% If Ativo="on" or isnull(Ativo) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo" type="checkbox" />
                                <label for="Ativo"></label>
                            </div>
                    </div>
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
    </div>
</div>