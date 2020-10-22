<!--#include file="Classes/Connection.asp"-->
<!--#include file="Classes/Environment.asp"-->
<%
set dbc = newConnection("", "")

PasswordSalt = getEnv("FC_PWD_SALT", "SALT_")

'VERIFICA SE USUÁRIO DE ACESSO EXISTE
if request.form("opt") = "verificaUsuarioAcesso" then

    sqlUsuarioAcesso = "SELECT * FROM licencasusuarios WHERE email = '"&request.form("email")&"'"

    set verificaUsuarioAcesso = dbc.execute(sqlUsuarioAcesso)

    if verificaUsuarioAcesso.EOF then
%>
        msgErro("Não localizamos o seu e-mail na nossa base");
<%
    else 
%>
        $.post("LoginRecuperarSenha.asp",{email:$("#User").val(),opt:'selecionarEmail'},function(data){
            $("#divFormLogin").html(data);
        });
<%
    end if

'ALTERA A SENHA
elseif request.form("opt") = "salvarNovaSenha" and request.form("email") <> "" then
    response.write(PasswordSalt&request.form("password"))
    if (request.form("password") <> "" and request.form("newpassword") <> "") and (request.form("password") = request.form("newpassword")) then
        dbc.execute("UPDATE licencasusuarios SET Senha = '"&request.form("password")&"', SenhaCript = SHA1('"&PasswordSalt&request.form("password")&"') WHERE Email = '"&request.form("email")&"' AND MD5(id)='"&request.form("hashControl")&"'")
%>
        alert('Senha alterada com sucesso');
        window.location = '/';
<%
    end if

'GERA CÓDIGO PARA ENVIAR PARA O E-MAIL
elseif request.form("opt") = "regerarCodigo" or (request.form("opt") = "gerarCodigo" and request.form("email") <> "" and request.form("emailenviar") <> "") then

    varEmailEnviar = split(request.form("emailenviar"),"|")

    sqlVerificaEmail = " SELECT lu.id AS LicencaUsuarioID, "&_ 
                                      " luas.id, "&_
                                      " luas.DataExpirar, "&_
                                      " lu.Bloqueado, "&_
                                      " luas.Tentativas, "&_
                                      " lu.LicencaID, "&_
                                      " lu.id UsuarioID"&_
                                 " FROM licencasusuarios lu "&_
                            " LEFT JOIN licencasusuariosalterarsenhas luas ON luas.LicencaUsuarioID = lu.id "&_
                                " WHERE email='"&request.form("email")&"' "&_
                                "   AND MD5(lu.id) = '"&varEmailEnviar(1)&"'"

    set verificaEmail = dbc.execute(sqlVerificaEmail)

    if not verificaEmail.EOF then

        sqlUsuario = "SELECT * FROM clinic"&verificaEmail("LicencaID")&".sys_users WHERE id = "&verificaEmail("UsuarioID")

        set Usuario = dbc.execute(sqlUsuario)

        if varEmailEnviar(0) = "emailprincipal" then

            EmailEnviar = request.form("email")
        
        else

            sqlEmail = "SELECT "&varEmailEnviar(0)&" AS email "&_
                        " FROM clinic"&verificaEmail("LicencaID")&"."&Usuario("Table")&" WHERE id = "&Usuario("idInTable")

            set Email = dbc.execute(sqlEmail)

            EmailEnviar = Email("Email")

        end if

        dim max
        max = 10
        Randomize

        authCode = Int(max*rnd)&Int(max*rnd)&Int(max*rnd)&Int(max*rnd)&Int(max*rnd)&Int(max*rnd)
        sqlHashCod = "SELECT MD5(CURRENT_TIMESTAMP()) AS hashcod"
        set varhashCod = dbc.execute(sqlHashCod)

        if verificaEmail("id") then
            dbc.execute("UPDATE licencasusuariosalterarsenhas SET sysActive = 1, DataExpirar = NULL, Tentativas = 0, AuthCode = '"&authCode&"', EmailEnviar = '"&EmailEnviar&"', hashcod='"&varhashCod("hashcod")&"' WHERE id = "&verificaEmail("id"))
        else
            dbc.execute("INSERT INTO licencasusuariosalterarsenhas (LicencaUsuarioID, Tentativas, AuthCode, sysActive, hashcod, EmailEnviar) VALUES ("&verificaEmail("LicencaUsuarioID")&",0,'"&authCode&"',1,'"&varhashCod("hashcod")&"','"&EmailEnviar&"')")
        end if
%>
        carregaFormInserirCodigo('<%=varhashCod("hashcod")%>','<%=varEmailEnviar(1)%>','<%=request.form("email")%>')
<% 
    else

        response.write("E-mail não cadastrado")

    end if
'RETORNA OS E-MAILS DO USUÁRIO
elseif request.form("opt") = "retornaEmail" and request.form("email") <> ""  then

    possuiRegistro = 0

    sqlRetornaLicencaID = " SELECT MD5(lu.id) hashControl, "&_
                          "        lu.id, "&_
                          "        lu.LicencaID, "&_
                          "        CONCAT(LEFT(IFNULL(p.NomeSocial, p.NomePaciente),18),'...') NomeEmpresa, "&_
                          "        CONCAT(LEFT(SUBSTRING_INDEX(lu.Email,'@',1),2),'*****@', SUBSTRING_INDEX(lu.Email,'@',-1)) Email "&_
                          "   FROM licencasusuarios lu "&_
                          "   JOIN licencas l ON l.id = lu.LicencaID "&_
                       " LEFT JOIN clinic5459.pacientes p ON p.id = l.Cliente "&_
                          "  WHERE lu.email = '"&request.form("email")&"'"

    set retornaLicencaID = dbc.execute(sqlRetornaLicencaID)

    while not retornaLicencaID.EOF

        possuiRegistro = possuiRegistro+1

        if possuiRegistro = 1 then
            checked = "checked='checked'"
        else
            checked = ""
        end if
        
        response.write("<span class='textoCodigoVerificacao'>"&retornaLicencaID("NomeEmpresa")&" <code>"&retornaLicencaID("LicencaID")&"</code></span><br><br><label class='container-radio'><input type='radio' name='email' id='emailprincipal' value='emailprincipal|"&retornaLicencaID("hashControl")&"' "&checked&">"&retornaLicencaID("Email")&"<span class='checkmark'></span></label><br>")

        sqlVerificaEsquema = "SELECT table_name "&_
                            " FROM information_schema.tables "&_
                            " WHERE table_schema = 'clinic"&retornaLicencaID("LicencaID")&"' "&_
                            " AND table_name = 'sys_users';"

        set verificaEsquema = dbc.execute(sqlVerificaEsquema)

        if not verificaEsquema.EOF then

            sqlRetornaUsuario = "SELECT * FROM clinic"&retornaLicencaID("LicencaID")&".sys_users WHERE id = "&retornaLicencaID("id")

            set retornaUsuario = dbc.execute(sqlRetornaUsuario)

            if not retornaUsuario.EOF then

                sqlRetornaEmails = "SELECT (CASE WHEN Email1 IS NOT NULL AND TRIM(Email1) <> '' THEN CONCAT(LEFT(SUBSTRING_INDEX(Email1,'@',1),2),'*****@', SUBSTRING_INDEX(Email1,'@',-1)) ELSE '' END) AS Email1, "&_
                                " (CASE WHEN Email2 IS NOT NULL AND TRIM(Email2) <> '' THEN CONCAT(LEFT(SUBSTRING_INDEX(Email2,'@',1),2),'*****@', SUBSTRING_INDEX(Email2,'@',-1)) ELSE '' END) AS Email2"&_
                                " FROM clinic"&retornaLicencaID("LicencaID")&"."&retornaUsuario("Table")&" WHERE id = "&retornaUsuario("idInTable")

                set retornaEmails = dbc.execute(sqlRetornaEmails)

                if not retornaEmails.EOF then

                    if retornaEmails("Email1") <> "" or retornaEmails("Email2") <> "" then
                        
                        if retornaEmails("Email1") <> "" then
                            response.write("<label class='container-radio'><input type='radio' name='email' id='email1' value='email1|"&retornaLicencaID("hashControl")&"'>"&retornaEmails("Email1")&"<span class='checkmark'></span></label><br>")
                        end if
                        if retornaEmails("Email2") <> "" then
                            
                            response.write("<label class='container-radio'><input type='radio' name='email' id='email2' value='email2|"&retornaLicencaID("hashControl")&"'>"&retornaEmails("Email2")&"<span class='checkmark'></span></label>")
                        end if
                    end if
                end if
            
                retornaEmails.close
                set retornaEmails = nothing

            end if

            retornaUsuario.close
            set retornaUsuario = nothing

        end if

        verificaEsquema.close
        set verificaEsquema = nothing

        retornaLicencaID.movenext
    wend

    retornaLicencaID.close
    set retornaLicencaID = nothing

    if possuiRegistro = 0 then
        response.write("<span class='textoRecuperarSenha'>Nenhum e-mail cadastrado para recebimento do código. Favor entrar em contato com a central de atendimento.</span>")
    end if
'VERIFICA SE O CÓDIDO É VÁLIDO
elseif request.form("opt") = "validarCodigo" and request.form("email") <> "" and request.form("authCode") <> "" then

    sqlValidarCodigo = " SELECT luas.AuthCode, "&_
                       " luas.Tentativas, "&_
                       " luas.id, "&_
                       " (case when DataExpirar IS NULL then 'S' when DataExpirar >= CURRENT_TIMESTAMP() then 'N' when DataExpirar <= CURRENT_TIMESTAMP() then 'S' END) AS Expirado "&_
                       " FROM licencasusuariosalterarsenhas luas "&_
                       " JOIN licencasusuarios lu ON lu.id = luas.LicencaUsuarioID "&_
                       " WHERE lu.email = '"&request.form("email")&"'"&_
                       " AND MD5(lu.id) = '"&request.form("hashControl")&"'"

    set validarCodigo =  dbc.execute(sqlValidarCodigo)

    if not validarCodigo.EOF then

        if validarCodigo("AuthCode") <> request.form("authCode") and validarCodigo("Expirado") = "N"  then
%>
            msgErro("Número de tentativas excedidas. Fique calmo, respire fundo e tente novamente ou ligue para o nosso suporte");
<%
        elseif validarCodigo("AuthCode") <> request.form("authCode") and validarCodigo("Tentativas") => 3 and validarCodigo("Expirado") = "S" then

            dbc.execute("UPDATE licencasusuariosalterarsenhas SET DataExpirar = DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL 2 MINUTE) WHERE id = "&validarCodigo("id"))

        elseif validarCodigo("AuthCode") <> request.form("authCode") and validarCodigo("Tentativas") < 3 then

            dbc.execute("UPDATE licencasusuariosalterarsenhas SET Tentativas = Tentativas+1 WHERE id = "&validarCodigo("id"))
%>
            msgErro("Código inválido");
<%
        elseif validarCodigo("AuthCode") = request.form("authCode") then
%>
            carregaFormNovaSenha('<%=request.form("email")%>','<%=request.form("hashControl")%>')
<%
        end if

    end if
'FORMULÁRIO PARA CADASTRAR NOVA SENHA
elseif request.form("opt") = "novaSenha" and request.form("email") <> "" then
%>
<input type="hidden" id="User" value="<%=request.form("email")%>">
<input type="hidden" id="hashControl" value="<%=request.form("hashControl")%>">
<br>
<span class="textoTitulo">Recuperação de senha</span>
<br>
<br>
<br>
<br>
<br>
<br>
<span class="textoTituloInput">Digite uma nova senha</span>
<br>
<input type="password" class="senha" placeholder="nova senha" type="password" name="password" id="password" required>
<span id="erro-senha" style="color: #cf0100;font-size: 12px;display: none;">A senha deve possuir mais de 8 caracteres, ao menos um número e uma letra.</span>
<br>
<br>
<br>
<span class="textoTituloInput">Confirme a senha</span>
<br>
<input type="password" class="senha" placeholder="confirmar senha" type="password" name="newpassword" id="newpassword" required>
<span id="erro-senha-diferente" style="color: #cf0100;font-size: 12px;display: none;">As senhas devem ser iguais.</span>
<br>
<br>
<div style="text-align: center">
<span class="textoDicaSenha">Use pelo menos oito caracteres, misturando letras
maiúsculas e caracteres especiais. Não use uma
senha de outro site ou algo muito óbvio, como
o nome do seu animal de estimação.</span>
</div>
<br>
<br>
<br>
<br>
<br>
<button type="submit" class="botao" data-style="zoom-in" onclick="return false" id="enviarCodigo">SALVAR</button>

<div class="modal" tabindex="-1" role="dialog" id="meuModal">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Título do modal</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Fechar">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>Texto do corpo do modal, é aqui.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
        <button type="button" class="btn btn-primary">Salvar mudanças</button>
      </div>
    </div>
  </div>
</div>

<script>
    $(document).ready(function() {

        var $senha = $("#password");
        var $novaSenha = $("#newpassword");
        var $erroSenha = $("#erro-senha");
        var $erroSenhaDiferente = $("#erro-senha-diferente");

        $("#enviarCodigo").click(function() {

            var str = $senha.val();
            //var regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{8,})/;
            var regex = /(?:[A-Za-z].*?\d|\d.*?[A-Za-z])/;
            var hasNumerAndLetter = !!str.match(regex);
            var moreThan8 = str.length >= 8;

            if (((moreThan8 && hasNumerAndLetter ) || str.length === 0)) {
                $erroSenha.fadeOut();

                if ($senha.val() === $novaSenha.val()) {
                    $erroSenhaDiferente.fadeOut();
                    $.post("LoginRecuperarSenha.asp",{email:$("#User").val(),opt:'salvarNovaSenha',password:$("#password").val(),newpassword:$("#newpassword").val(),hashControl:$("#hashControl").val()},function(data){
                        eval(data);
                    });
                } else {
                    $erroSenhaDiferente.fadeIn();
                }
            } else {
                $erroSenha.fadeIn();
            } 
	        window.location.href = "https://app.feegow.com";
        });        
    });

    function carregaFormLogin(email) {
        $.post("LoginRecuperarSenha.asp",{email:email,opt:'novaSenha'},function(data){
            $("#divFormLogin").html(data);
        });
    }
</script>

<%
'FORMULÁRIO PARA INSERÇÃO DO CÓDIGO
elseif request.form("opt") = "inserirCodigo" and request.form("email") <> "" then
%>
<input type="hidden" id="User" value="<%=request.form("email")%>">
<input type="hidden" id="hashControl" value="<%=request.form("hashControl")%>">
<br>
<span class="textoTitulo">Recuperação de senha</span>
<br>
<br>
<br>
<br>
<div style="text-align:center">
    <span class="textoRecuperarSenha">Isso ajuda a mostrar que essa conta realmente pertence a você</span>
</div>
<br>
<div style="text-align:center">
    <img src="assets/img/login_recuperacao_senha.png">
</div>
<br>
<br>
<br>
<br>
<input type="text" class="" type="text" name="authCode" id="authCode" placeholder="digite o código" maxlength="6" autofocus required>
<span id="erro-codigo" style="color: #cf0100;font-size: 12px;display: none;"></span>
<br>
<br>
<br>
<button type="submit" class="botao" data-style="zoom-in" onclick="return false" id="enviarCodigo">PRÓXIMA</button>

<script>
    $(document).ready(function() {

        $("#enviarCodigo").click(function() {
            $.post("LoginRecuperarSenha.asp",{email:$("#User").val(),opt:'validarCodigo',authCode:$("#authCode").val(),hashControl:$("#hashControl").val()},function(data){
                eval(data);
            });
        });        
    });
    
    function carregaFormNovaSenha(email,hashControl) {
        $.post("LoginRecuperarSenha.asp",{email:email,opt:'novaSenha',hashControl:hashControl},function(data){
            $("#divFormLogin").html(data);
        });
    }

    function msgErro(msg) {
        $("#erro-codigo").html(msg);
        $("#erro-codigo").fadeIn();
    }
</script>

<%
'FORMULÁRIO PARA SELECIONAR O E-MAIL
elseif request.form("opt") = "selecionarEmail" and request.form("email") <> "" then
%>
<input type="hidden" id="User" value="<%=request.form("email")%>">
<br>
<span class="textoTitulo">Recuperação de senha</span>
<br>
<br>
<br>
<br>
<br>
<br>
<span class="textoCodigoVerificacao">E-mail para receber o código de verificação:</span>
<br>
<br>
<br>
<br>
<div id="divEmails"></div>
<br>
<br>
<br>
<br>
<br>
<button type="submit" class="botao" data-style="zoom-in" onclick="return false" id="enviarCodigo">PRÓXIMA</button>

<script>
    $(document).ready(function() {
        $.post("LoginRecuperarSenha.asp",{email:$("#User").val(),opt:'retornaEmail'},function(data){
            $("#divEmails").html(data);
            
            if ($("#email").length == 0) {
                $("#enviarCodigo").attr("disabled",false);
            }
        });

        $("#enviarCodigo").click(function() {
            $.post("LoginRecuperarSenha.asp",{emailenviar: $("input[name='email']:checked").val(), email:$("#User").val(),opt:'gerarCodigo',authCode:$("#authCode").val()},function(data){
                eval(data);
            });
        });        
    });

    function carregaFormInserirCodigo(hash,hashControl,email) {

        $.post(domain +"/api/esqueciminhasenha",{hash:hash},function(){
            $.post("LoginRecuperarSenha.asp",{email:email,opt:'inserirCodigo',hashControl:hashControl},function(data){
                $("#divFormLogin").html(data);
            }); 
        }).fail(function(data){alert("ops");});
    }
</script>
<%
'FORMULÁRIO INICIAL
else
%>
<br>
<span class="textoTitulo">Recuperação de senha</span>
<br>
<br>
<br>
<br>
<div style="text-align:center">
    <span class="textoRecuperarSenha">Isso ajuda a mostrar que essa conta realmente pertence a você</span>
</div>
<br>
<div style="text-align:center">
    <img src="assets/img/login_recuperacao_senha.png">
</div>
<br>
<br>
<br>
<span class="textoTituloInput">E-mail</span>
<br>
<input type="email" class="usuario" type="email" name="User" id="User" placeholder="digite seu e-mail de acesso" autofocus required>
<span id="erro-codigo" style="color: #cf0100;font-size: 12px;display: none;"></span>
<br>
<br>
<br>
<button type="submit" class="botao" data-style="zoom-in" onclick="return false" id="enviarCodigo">PRÓXIMA</button>

<script>
    $(document).ready(function() {
        $("#enviarCodigo").click(function() {
            $.post("LoginRecuperarSenha.asp",{email:$("#User").val(),opt:'verificaUsuarioAcesso'},function(data){
                eval(data);
            });
        });        
    });

    function msgErro(msg) {
        $("#erro-codigo").html(msg);
        $("#erro-codigo").fadeIn();
    }
</script>
<%
end if
%>