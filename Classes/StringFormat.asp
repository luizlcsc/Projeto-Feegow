<%

'remove tags html de uma string
FUNCTION stripHTML(strHTML)
  Dim objRegExp, strOutput, tempStr
  Set objRegExp = New Regexp
  objRegExp.IgnoreCase = True
  objRegExp.Global = True
  objRegExp.Pattern = "<(.|n)+?>"
  'Replace all HTML tag matches with the empty string
  strOutput = objRegExp.Replace(strHTML, "")
  'Replace all < and > with &lt; and &gt;
  strOutput = Replace(strOutput, "<", "&lt;")
  strOutput = Replace(strOutput, ">", "&gt;")
  stripHTML = strOutput    'Return the value of strOutput
  Set objRegExp = Nothing
END FUNCTION


'corrige erros do tipo "101,101," ou ", 102 , , 129" ...
FUNCTION fix_array_comma(array_string)
    new_array = ""
    if array_string <> "" then
        items = split(array_string, ",")
        for j=0 to ubound(items)
            item = replace(items(j), " ", "")
            if item <> "" then
                if new_array="" then
                    new_array = item
                else
                    new_array = new_array&","&item
                end if
            end if
        next
        fix_array_comma=new_array
    end if
END FUNCTION

'corrige strings com caracteres que quebram no javascript (quebras de linha) ATENCAO: funcao utilizada nas agendas
FUNCTION fix_string_chars(string)
    fix_string_chars = replace(replace(string&"", chr(13), ""), chr(10), "")
END FUNCTION


'corrige strings com caracteres que quebram no javascript (quebras de linha) ATENCAO: funcao utilizada nas agendas
FUNCTION fix_string_chars_full(string)
    fix_string_chars_full = trim(replace(replace(replace(replace(replace(replace(string&"", chr(13), ""), chr(10), ""), """", "\"""),"'",""),"	",""),"\",""))
END FUNCTION

Function TratarNome(ByVal formato, ByVal str)

     result = str

    IF formato = "Maiúscula" THEN
        result = UCase(str)

    END IF

    IF NOT IsNull(str) AND formato = "Título" THEN
        splitNome = Split(str," ")
        result = ""
        for x = 0 to UBound(splitNome)
            s = splitNome(x)

            if s&"" <>"" then
                result = result&" "&UCase(Left(s,1)) &LCase(Right(s, Len(s) - 1))
            end if
        Next
    END IF

    TratarNome = Trim(result)
End Function

FUNCTION NomeNoPadrao(stringNome)
    set configuracao = db.execute("select FormatoDeNome from sys_config")


    if not configuracao.eof then

        FormatoDeNome=configuracao("FormatoDeNome")

        if not isnull(FormatoDeNome) then
            NomeNoPadrao=TratarNome(FormatoDeNome, stringNome)

        else
            NomeNoPadrao=stringNome
        end if
    else
        NomeNoPadrao=stringNome
    end if

END FUNCTION

%>