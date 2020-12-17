<%
function validaCriteriosSenha(passwordInput, passwordInputConfirmation)

    if len(passwordInput)<8 then
        validaCriteriosSenha="A senha deve conter no mínimo 8 caracteres."
    else
        Set myRegExp = New RegExp
        myRegExp.Pattern = "[0-9]"
        HasNumber = myRegExp.Test(ref("password"))

        Set myRegExp = New RegExp
        myRegExp.Pattern = "[a-zA-Z]"
        HasLetter = myRegExp.Test(ref("password"))

        if not HasNumber and HasLetter then
            validaCriteriosSenha="A senha deve conter um número e uma letra."
        end if
    end if

    if passwordInput<>passwordInputConfirmation then
        validaCriteriosSenha="As senhas digitadas não conferem."
    end if

end function
%>
