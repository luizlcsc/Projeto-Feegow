    <div style="margin-top: 15px;">
        <span class="textoTitulo">Faça o login na sua conta</span>
    </div>
    <div style="margin-top: 30px;">
        <label for="User" class="textoTituloInput" >E-mail</label>
        <input type="email" class="usuario" type="email" name="User" id="User" value="<%=User %>" placeholder="digite seu e-mail de acesso" autofocus required>
    </div>
    <div style="margin-top: 20px;">
        <label for="password" class="textoTituloInput">Senha</label>
        <input type="password" class="senha" placeholder="senha" type="password" value="<%=PasswordValue%>" name="password" id="password" required>
    </div>
    <div class="container" style="margin-top: 10px;">
        <div class="row">
            <div class="col">
                <label class="container-checkbox">Lembrar dados de acesso
                <input type="checkbox" name="Lembrarme" id="Lembrarme" value="S" <%if request.cookies("User")<>"" or request.form("Lembrarme")="S" then response.write(" checked ") end if %>>
                <span class="checkmark"></span>
                </label>
            </div>
            <div class="col">
                <label class="container-checkbox">
                    <span id="esqueciSenha"><i class="fal fa-question-circle"></i> Esqueceu sua senha?</span>
                </label>
            </div>
        </div>
    </div>

    <div style="margin-top: 50px; text-align:center;">

    <%
    if SolicitaDesafio then
        %>
<div data-callback="recaptchaSuccess" class="g-recaptcha" data-sitekey="6LcYU94cAAAAAE-wjHMKmWdjz5-JlEukwcyVqzj4"></div>
<br>
        <%
    end if
    %>
        <button <% if SolicitaDesafio then response.write("disabled") end if %> type="submit" class="botao" data-style="zoom-in" id="Entrar"> <span class="btn-entrar-txt" style="padding-right: 10px;">Entrar</span><i style="font-size: 12px" class="icon-btn-login fal fa-arrow-right"></i></button>
    </div>
    <div class="login-erro" style="display: <% if ErroLogin then response.write("block") else response.write("none") end if%>">
        <i class="far fa-exclamation-circle"></i>
        <%=ErroLoginMsg%> <% if errorCode <> "" then %><br><small style="float:right;color: #ff000075;"><%=errorCode%></small> <% end if %>
    </div>
    <script>
        $(document).ready(function() {
            $("#esqueciSenha").click(function() {
            $("#divError").html("");
            postUrl("login/fgtpassword", {
                "invoices": '0'
            }, function (data) {
            $("#divFormLogin").html(data);
            })});            
        });
    </script>
