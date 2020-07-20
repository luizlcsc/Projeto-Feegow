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

'*************************************************************
'*DESCREVER CADA FUNÇÃO E COLOCAR UM EXEMPLO DE USO/APLICAÇÃO*
'*************************************************************

function converteEncapsulamento(tipo,valor)
  Select Case tipo
    Case ",|" ''CONVERTE VALORES "item1,item2,item3" PARA "|item1|, |item2|, |item3|"
      valor_array=Split(valor,",")
      for each valor_item in valor_array
          valor_pipe = "|"&valor_item&"|"
          if resultado="" then
            resultado = valor_pipe
          else
            resultado = resultado&", "&valor_pipe
          end if
      next
      if right(trim(resultado),1) = "," then
        resultado = left(string,(len(string)-2)) 'REMOVER 2 ÚLTIMOS CARACTERS
      end if

      converteEncapsulamento = resultado

    Case "|," 'CONVERTE VALORES "|item1|, |item2|, |item3|" PARA "item1,item2,item3"
      valor_array=Split(valor,"|,")
      for each valor_item in valor_array
          valor_virgula = trim(valor_item)
          if resultado="" then
            resultado = valor_virgula
          else
            resultado = resultado&","&valor_virgula
          end if
      next
      converteEncapsulamento = replace(resultado,"|","")

    Case ",'" 'CONVERTE VALORES "item1,item2,item3" PARA "'item1','item2','item3'"
      valor_array=Split(valor,",")
      for each valor_item in valor_array
          valor_pipe = "'"&valor_item&"'"
          if resultado="" then
            resultado = valor_pipe
          else
            resultado = resultado&", "&valor_pipe
          end if
      next
      converteEncapsulamento = resultado


  End Select
end function
'TESTES convertePipeVirgula()
'response.write(convertePipeVirgula("|,","|ALL|, |622|, |588|") )


'REMOVE ITENS DUPLICADOS DE UMA STRING SEPARADOS POR UM DELIMITADOR
Function removeDuplicatas(conteudo,delimitador)
  Set oDict = Server.CreateObject("Scripting.Dictionary")
  oDict.CompareMode = vbTextCompare
  For Each word In Split(conteudo, delimitador)
      oDict(word) = Null
  Next
  removeDuplicatas = Join(oDict.Keys, delimitador)
  
  Set oDict = Nothing
End Function
'TESTE
'response.write(removeDuplicatas("ONLY,ONLY,ONLY,-51,-52,-50,1",","))
%>