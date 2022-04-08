<style>
.codigo {
    width:55px !important; 
    height:55px !important; 
    padding-left:1px !important; 
    text-align:center !important; 
    margin-left:5px !important;        
    font-size: 22px !important;
}


</style>
<img class="login-logo" src="assets/img/login_logo.svg" border="0" width="124" height="36">
<div style="margin-top: 15px;">
    <span class="textoTitulo">Redefinição de senha</span>
</div>
<div style="text-align:left; " id="login-conteudo-validar-codigo">     
    <div style="margin-bottom: 45px;margin-top:45px;">
        <p>Insira abaixo o código de verificação enviado:</p>
    </div>
    <div style="text-align:center;" class="codigo-inputs" >          
        <div class="d-inline"><input onkeyup="proximo(this);" tabindex="0" class="codigo" type="text" name="auth1" id="auth1" autocomplete="off" maxlength="6" value="" required></div>
        <div class="d-inline"><input onkeyup="proximo(this);" tabindex="1" class="codigo" type="text" name="auth2" id="auth2" autocomplete="off" maxlength="1" value="" required></div>
        <div class="d-inline"><input onkeyup="proximo(this);" tabindex="2" class="codigo" type="text" name="auth3" id="auth3" autocomplete="off" maxlength="1" value="" required></div>
        <div class="d-inline"><input onkeyup="proximo(this);" tabindex="3" class="codigo" type="text" name="auth4" id="auth4" autocomplete="off" maxlength="1" value="" required></div>
        <div class="d-inline"><input onkeyup="proximo(this);" tabindex="4" class="codigo" type="text" name="auth5" id="auth5" autocomplete="off" maxlength="1" value="" required></div>
        <div class="d-inline"><input onkeyup="proximo(this);" tabindex="5" class="codigo" type="text" name="auth6" id="auth6" autocomplete="off" maxlength="1" value="" required></div>
    </div>
</div>

<div style="display:none" id="login-conteudo-redefinir-senha" class="row" style="margin-top: 10px;" > 
        <div style="margin-bottom: 45px;margin-top:45px;" class="col-md-12">
            <p>Digite a nova senha abaixo:</p>
        </div>
        
        <div class="col-md-5"  style="padding-left: 10px">
            <div class="form-group">
                <input type="password" class="form-control" onblur="" id="senha" placeholder="Senha" tabindex="6" onKeyUp="senhaValida();">

                <div id="confirmacao-status" class="pt10"></div>
            </div>
        </div>
        <div class="col-md-5" >
            <div class="form-group">
                <input type="password" class="form-control" id="confirmacao" placeholder="Confirmação" tabindex="7" onKeyUp="senhasIguais();">
            </div>
        </div>
        
        <div class='col-md-2'>
            <button type="submit" class="btn btn-primary" id="btnEnviar" tabindex="8" onclick="" disabled>Redefinir</button>
        </div>
</div>

<script>
    var ev = '<%=req("ev")%>';

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

    function getCodigo(){
        var codigo = "";

        for(let i=0;i<6;i++){
            codigo += $(`.codigo:eq(${i})`).val();
        }
        return codigo;
    }

    function validaCodigo(){
        $.get("modulos/login/ValidaCodigoRedefinicaoSenha.asp", {
            codigo: getCodigo(),
            ev: ev
        },function(data){
            if(data.success){
                $("#login-conteudo-validar-codigo").fadeOut(function(){
                    $("#login-conteudo-redefinir-senha").fadeIn();
                });
            }
        });
    }

    function proximo(obj)
    {
        if(getCodigo().length === 6){
            validaCodigo();
        }

        var v = $(obj).val();
        if(v.length === 6){
            var vSplit = v.split("");
            for(let i=0;i<vSplit.length;i++){
                $(`.codigo-inputs .codigo:eq(${i})`).val(vSplit[i]);
            }
            return false;
        }

        if(v.length==1)
        {
            var tab = $(obj).attr("tabindex");
            tab++;
            // $("[tabindex='"+tab+"']").val("");
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
            $('#confirmacao-status').html("");
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