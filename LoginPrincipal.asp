<% if req("ev")<>"" THEN %>
    <style>
    .codigo {
            width:25px !important; 
            padding-left:1px !important; 
            text-align:center !important; 
            margin-left:5px !important;        
        }


    </style>
    <div style="text-align:left; margin-top:10px;">
        <span class="textoTitulo">Redefinir Senha</span>
    </div>
    <div style="text-align:left; margin-top:20px;">
        <div style="text-align:center;" >               
            <div class="d-inline"><input onkeyup="proximo(this);" tabindex="0" class="codigo" type="text" name="auth1" id="auth1" maxlength="1" value="" placeholder="C" required></div>
            <div class="d-inline"><input onkeyup="proximo(this);" tabindex="1" class="codigo" type="text" name="auth2" id="auth2" maxlength="1" value="" placeholder="Ó" required></div>
            <div class="d-inline"><input onkeyup="proximo(this);" tabindex="2" class="codigo" type="text" name="auth3" id="auth3" maxlength="1" value="" placeholder="D" required></div>
            <div class="d-inline"><input onkeyup="proximo(this);" tabindex="3" class="codigo" type="text" name="auth4" id="auth4" maxlength="1" value="" placeholder="I" required></div>
            <div class="d-inline"><input onkeyup="proximo(this);" tabindex="4" class="codigo" type="text" name="auth5" id="auth5" maxlength="1" value="" placeholder="G" required></div>
            <div class="d-inline"><input onkeyup="proximo(this);" tabindex="5" class="codigo" type="text" name="auth6" id="auth6" maxlength="1" value="" placeholder="O" required></div>
        </div>
        <div class="form-group" style="margin-top: 10px;">
            <div class="form-group">
                <input type="password" class="form-control" onblur="" id="senha" placeholder="Senha" tabindex="6" onKeyUp="senhaValida();" maxlength="8">
            </div>
            <div style="text-align:center; margin:10px;">
            <span id="password-status"></span>
            </div>
            <div class="form-group">
                <input type="password" class="form-control" id="confirmacao" placeholder="Confirmação" tabindex="7" onKeyUp="senhasIguais();" maxlength="8">
            </div>
            <div style="text-align:center; margin:10px;">
            <span id="confirmacao-status"></span>
            </div>
        </div>
        <button type="submit" class="btn btn-primary" id="btnEnviar" tabindex="8" onclick="" disabled>Enviar</button>
    </div> 

    <script>

        $('#btnEnviar').click(function( event ) 
        {
            event.preventDefault();
            var novasenha     = $('#senha').val();
            var confirmaSenha = $('#confirmacao').val();
           postUrl("login/rdfpassword",
                          { novasenha: novasenha,
                            confirmacaoSenha: confirmaSenha,
                            auth1: $('#auth1').val(),
                            auth2: $('#auth2').val(),
                            auth3: $('#auth3').val(),
                            auth4: $('#auth4').val(),
                            auth5: $('#auth5').val(),
                            auth6: $('#auth6').val(),
                            ev: '<%=req("ev") %>' } ,
                        function(data)
                        {
                            if (data.success =='1')
                            {
                                alert('Senha atualizada!'); 
                                $(location).attr('href', '?P=Login');                  
                            }
                            else
                            {
                                alert(data.mensagem);
                            }
                        }           
                    );
        });

        function proximo(obj)
        {
            if($(obj).val().length==1)
            {            
                var tab = $(obj).attr("tabindex");
                tab++;
                $("[tabindex='"+tab+"']").val("");
                $("[tabindex='"+tab+"']").focus();
            }
        }

        function senhasIguais()
        {
            if ($('#senha').val() != $('#confirmacao').val())
            {
                $('#confirmacao-status').html("<span style='color:red'>As Senhas não coincidem! </span>");                
                $('#btnEnviar').prop( "disabled", true );
            }
            else
            {
                $('#confirmacao-status').html("<span style='color:green'>OK! </span>");
                $('#btnEnviar').prop( "disabled", false );
            }
        }

        function senhaValida()
        {
            var p = $('#senha').val();
            var retorno = false;
            var letrasMaiusculas = /[A-Z]/;
            var letrasMinusculas = /[a-z]/; 
            var numeros = /[0-9]/;
            var caracteresEspeciais = /[!|@|#|$|%|^|&|*|(|)|-|_]/;
            if(p.length > 8)
            {
                $('#password-status').html("<span style='color:red'>A senha deve conter no máximo 8 caracteres</span>");
                return retorno;
            }
            if(p.length < 8)
            {
                $('#password-status').html("<span style='color:red'>Mínimo de 8 caracteres esperados</span>");
                return retorno;
            }
            var auxMaiuscula = 0;
            var auxMinuscula = 0;
            var auxNumero = 0;
            var auxEspecial = 0;
            for(var i=0; i<p.length; i++)
            {
                if(letrasMaiusculas.test(p[i]))
                auxMaiuscula++;
                else if(letrasMinusculas.test(p[i]))
                auxMinuscula++;
                else if(numeros.test(p[i]))
                auxNumero++;
                else if(caracteresEspeciais.test(p[i]))
                auxEspecial++;
            }
            if (auxMaiuscula > 0)
            {
                if (auxMinuscula > 0)
                {
                    if (auxNumero > 0)
                    {
                        if (auxEspecial) 
                        {
                            $('#password-status').html("<span style='color:green'><b>Senha Forte!</b></span>");
                            retorno = true;
                        }
                        else
                        {
                            $('#password-status').html("<span style='color:orange'>Insira CARACTERES ESPECIAIS</span>");
                            retorno = false;
                        }
                    }
                    else
                    {
                        $('#password-status').html("<span style='color:orange'>Insira NUMEROS</span>");
                        retorno = false;
                    }
                }
                else
                {
                    $('#password-status').html("<span style='color:red'>Insira LETRAS</span>"); 
                    retorno = false;
                }
            }
            else
            {
                $('#password-status').html("<span style='color:red'>Insira letras MAIÚSCULAS</span>");
                retorno = false;        
            }
            return retorno;
        }
    </script>
<% 
    else 
%>
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
        <button type="submit" class="botao" data-style="zoom-in" id="Entrar"> <span class="btn-entrar-txt" style="padding-right: 10px;">Entrar</span><i style="font-size: 12px" class="icon-btn-login fal fa-arrow-right"></i></button>
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

<% end if %>