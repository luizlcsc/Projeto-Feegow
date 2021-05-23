
<br>
<span class="textoTitulo">Faça o login na sua conta</span>
<br>
<br>
<br>
<br>
<br>
<br>
<span class="textoTituloInput">E-mail</span>
<br>
<input type="email" class="usuario" type="email" name="User" id="User" value="<%=User %>" placeholder="digite seu e-mail de acesso" autofocus required>
<br>
<br>
<br>
<span class="textoTituloInput">Senha</span>
<br>
<input type="password" class="senha" placeholder="senha" type="password" value="<%=PasswordValue%>" name="password" id="password" required>
<br>
<br>
<div class="container">
    <div class="row">
        <div class="col">
            <label class="container-checkbox">Lembrar dados de acesso
            <input type="checkbox" name="Lembrarme" id="Lembrarme" value="S" <%if request.cookies("User")<>"" or ref("Lembrarme")="S" then response.write(" checked ") end if %>>
            <span class="checkmark"></span>
            </label>
        </div>
        <div class="col">
            <label class="container-checkbox">
                <span id="esqueciSenha"><img src="assets/img/login_esqueceu_senha.png" style="width: 10.2px;"> Esqueceu sua senha?</span>
            </label>
        </div>
    </div>
</div>
<br>
<br>
<br>
<br>
<br>
<button type="submit" class="botao" data-style="zoom-in" id="Entrar">ENTRAR</button>
<script>

    $(document).ready(function() {
        $("#esqueciSenha").click(function() {
            $("#divError").html("");
            $.post("LoginRecuperarSenha.asp",function(data){
                $("#divFormLogin").html(data);
            });
        });        
    });
            
</script>