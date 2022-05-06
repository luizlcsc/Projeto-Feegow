<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
tabela = req("T")
idInTable = req("I")

set dadosUser = db.execute("select su.*, lu.AlterarSenhaAoLogin from sys_users su "&_
                            "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id = su.id "&_
                            "where su.`Table` like '"&tabela&"' and su.idInTable="&idInTable)

if tabela="profissionais" then
	NomeColuna = "NomeProfissional"
elseif tabela="funcionarios" then
	NomeColuna = "NomeFuncionario"
end if

set pnome = db.execute("select "&NomeColuna&" from "&tabela&" where id="&idInTable)

if not pnome.eof then
	Nome = pnome(""&NomeColuna&"")
end if

set dadosAcesso = dbc.execute("select * from licencasusuarios where id="&dadosUser("id")&" and LicencaID="&replace(session("Banco"), "clinic", ""))

EmailAcesso = dadosAcesso("Email")
idUsuario = dadosAcesso("id")
Home = dadosAcesso("Home")

%>
<form method="post" id="frmAcesso" name="frmAcesso" action="">
<input type="hidden" name="I" id="I" value="<%=idInTable%>">
<input type="hidden" name="T" id="T" value="<%=tabela%>">
<input type="hidden" name="User" value="<%= EmailAcesso %>" >
<input type="hidden" name="Acao" value="Redefinir">
        <p>Bem-vindo <%=Nome%>, redefina sua senha</p>
            <div class="row admin-form">
                <div class="col-md-6 mt10">
                     <label> Definir senha de acesso</label>
                    <label for="password" class="field prepend-icon">
                        <input type="password" class="form-control" autocomplete="off" name="password" id="senha-acesso" placeholder="Senha" autofocus/>
                        <label for="password" class="field-icon">
                        <i class="far fa-lock"></i>
                        </label>
                    </label>
                    <span id="erro-senha" style="color: #cf0100;font-size: 12px;display: none;">A senha deve possuir mais de 8 caracteres. Ao menos um número e uma letra.</span>
                </div>
                </div>
            <div class="row admin-form mt10">
                <div class="col-md-6">
                        <label>Confirme a senha</label>
                    <label for="password2" class="field prepend-icon">
                        <input type="password" class="form-control" autocomplete="off" name="password2" id="senha-confirmacao-acesso" placeholder="Senha" />
                        <label for="password2" class="field-icon">
                        <i class="far fa-lock"></i>
                        </label>
                    </label>
                </div>
            </div>
        </div>
</form>

<script language="javascript">

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
                        console.log(data);
            			eval(data);
            		}
            	});
        }else{
            $erroSenha.fadeIn();
        }

	return false;
});
</script>