<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
set dadosUser = db.execute("select su.*, lu.AlterarSenhaAoLogin from sys_users su "&_
                           "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id = su.id "&_
                           "where su.`Table` like '"&req("T")&"' and su.idInTable="&req("I"))
alterarSenha = ""
if dadosUser.EOF then
	comAcesso = "N"
	id = 0
else

    id = dadosUser("id")
    if dadosUser("AlterarSenhaAoLogin") = "1" then
        alterarSenha = " disabled "
        alterarSenhaIcon = " far fa-check-circle "
    end if
	set dadosAcesso = dbc.execute("select * from licencasusuarios where id="&dadosUser("id")&" and LicencaID="&replace(session("Banco"), "clinic", ""))
	if dadosAcesso.eof then
		comAcesso = "N"
	else
		if dadosAcesso("Email")&""="" then
			comAcesso="N"
		else
			comAcesso = "S"
			EmailAcesso = dadosAcesso("Email")
            idUsuario = dadosAcesso("id")
            Home = dadosAcesso("Home")
		end if
        if session("Banco")="clinic5459" then
            Ramal = dadosUser("Ramal")
        end if
	end if

    if dadosUser("AlterarSenhaAoLogin")&""="1"then
        AlterarSenhaAoLogin = "S"
    end if

end if

PessoaID = req("I")
T = lcase(req("T"))
if T="profissionais" then
	NomeColuna = "NomeProfissional"
elseif T="funcionarios" then
	NomeColuna = "NomeFuncionario"
end if
set pnome = db.execute("select "&NomeColuna&", Ativo from "&T&" where id="&PessoaID)
if not pnome.eof then
	Nome = pnome(""&NomeColuna&"")
	Ativo = pnome("Ativo")
end if


if comAcesso="N" or Ativo&""="" then
	msg = "<div class=""badge badge-danger"">Usu&aacute;rio sem acesso ao sistema</div>"
else
	msg = "<div class=""badge badge-success"">Usu&aacute;rio com acesso ao sistema</div>"
end if

%>
<form method="post" id="frmAcesso" name="frmAcesso" action="">
<input type="hidden" name="I" id="I" value="<%=req("I")%>">
<input type="hidden" name="T" id="T" value="<%=req("T")%>">
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">
                Dados de Acesso de <%=Nome%>
            </span>
            <span class="panel-controls">
                <button type="submit" class="btn btn-sm btn-primary"> <i class="far fa-key"></i> Salvar </button>
            </span>
        </div>
        <div class="panel-body">
            <div class="row admin-form">


                <input type="hidden" name="E" value="E">
                <div class="col-md-5">
                    E-mail de acesso<br>
                    <label for="User" class="field prepend-icon">
                        <input type="email" class="form-control" name="User" placeholder="E-mail" value="<%= EmailAcesso %>" autofocus />
                        <label for="username" class="field-icon">
                        <i class="far fa-user"></i>
                        </label>
                    </label>
                </div>
                <div class="col-md-3">
                            Definir senha de acesso<br>
                    <label for="password" class="field prepend-icon">
                        <input type="password" class="form-control" name="password" id="senha-acesso" placeholder="Senha" autocomplete="new-password" />
                        <label for="password" class="field-icon">
                        <i class="far fa-lock"></i>
                        </label>
                    </label>
                    <span id="erro-senha" style="color: #cf0100;font-size: 12px;display: none;">A senha deve possuir mais de 8 caracteres. Ao menos um número e uma letra.</span>
                </div>
                <div class="col-md-3">
                        Confirme a senha<br>
                    <label for="password2" class="field prepend-icon">
                        <input type="password" class="form-control" autocomplete="new-password" name="password2" id="senha-confirmacao-acesso" placeholder="Senha" />
                        <label for="password2" class="field-icon">
                        <i class="far fa-lock"></i>
                        </label>
                    </label>
                </div>

                </div>

                <div class="row"><br>
                    <div class="col-md-4">
                        <button <%=alterarSenha%> class="btn btn-primary btn-sm btn-block" id="solicitar-alteracao-de-senha" type="button"><i class="<%=alterarSenhaIcon%>"></i> Solicitar que o usuário altere a senha após login</button>
                    </div>
                </div>

            <hr class="short alt" />

                        <%if session("banco")="clinic105" and idUsuario<>"" then %>
                        <div id="biometria">
                            <a class="btn btn-default btn-block" href="javascript:ajxContent('CadastroBiometria', <%=idUsuario %>, 1, 'biometria');"><img src="assets/img/fingerprint.png" border="0" /> Cadastrar impressão digital</a>
                        </div>
                        <%end if %>


            <div class="row">
                <%= quickfield("simpleSelect", "Home", "Página inicial do usuário", 4, Home, "select '' id, 'Tela inicial' Descricao UNION ALL select 'Agenda-1', 'Agenda Diária' UNION ALL select 'Checkin', 'Check-in' UNION ALL select 'AgendaMultipla', 'Agenda Múltipla' UNION ALL select 'ListaEspera', 'Sala de Espera' UNION ALL select 'Financeiro', 'Financeiro'", "Descricao", "semVazio") %>
                <% if session("Banco")="clinic5459" then call quickfield("text", "Ramal", "Ramal", 2, Ramal, "", "", "") end if %>
            </div>
            <hr class="short alt" />

            <div class="clearfix form-actions">
                <div class="col-xs-12">
                     <span id="msg"><%=msg%></span>
                </div>
            </div>
        </div><!-- /widget-body -->
    </div><!-- /login-box -->
</form>
<script type="text/javascript">
var $senha = $("#senha-acesso");
var $erroSenha = $("#erro-senha");

$("#frmAcesso").submit(function(){
        var str = $senha.val();
        var regex = /(?:[A-Za-z].*?\d|\d.*?[A-Za-z])/;
        var hasNumerAndLetter = !!str.match(regex);
        var moreThan8 = str.length >= 8;

        if((moreThan8 && hasNumerAndLetter ) || str.length === 0){
            $erroSenha.fadeOut();

            $.ajax({
            		type:"POST",
            		url:"saveAcesso2.asp",
            		data:$("#frmAcesso").serialize(),
            		success:function(data){
            			eval(data);
            		}
            	});
        }else{
            $erroSenha.fadeIn();
        }

	return false;
    });

$("#solicitar-alteracao-de-senha").click(function() {
    $(this).attr("disabled",true);
    var id = parseInt('<%=id%>');

    if(id>0){
        $.get("SolicitarAlteracaoDeSenha.asp", {id: id} , function(data) {
            showMessageDialog("O usuário será solicitado para alterar a senha no próximo login.", "success");
        });
    }
});

    $("#Ramal").change(function () {
        $.get("saveRamal.asp?U=<%= id %>&Ramal=" + $(this).val(), function (data) { eval(data) });
    });
</script>