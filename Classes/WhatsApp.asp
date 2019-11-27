<%

function celularValido(celular)
    CelularFormatadado = "55"& replace(replace(replace(replace(Celular&"", "(", ""),")","")," ",""),"-","")

    PrimeiroDigito = right(left(CelularFormatadado, 5),1)
    
    if PrimeiroDigito&"" <> "9" then
        celularValido= False
    else
        celularValido=True
    end if
end function

function formataCelularWhatsApp(celular)
    CelularFormatadado = "55"& replace(replace(replace(replace(Celular&"", "(", ""),")","")," ",""),"-","")
    formataCelularWhatsApp=CelularFormatadado
end function

%>