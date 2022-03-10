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
    fix_string_chars_full = trim(replace(replace(replace(replace(replace(replace(replace(string&"", chr(13), ""), chr(10), ""), """", " "),"'",""),"	",""),"\",""),"`",""))
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
        'resultado = mid(resultado,1,len(resultado)-2) 'REMOVER 2 ÚLTIMOS CARACTERS
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

      resultado = replace(resultado,"|","")
      if right(trim(resultado),1) = "," then
       converteEncapsulamento = mid(resultado,1,len(resultado)-1) 'REMOVER ÚLTIMO CARACTERS
      else
        converteEncapsulamento = resultado
      end if

      'converteEncapsulamento = resultado

      'converteEncapsulamento = replace(resultado,"|","")

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

'REMOVE VALOR CONCATENADO VAZIO GERALMENTE UTILIZADO NO IN(|123|, |475|,|)
Function removeNullDelimiter(Conteudo)
  Conteudo = trim(Conteudo)
  if right(trim(Conteudo),4) = "|, |" then
      ConteudoTratado =  mid(Conteudo,1,len(Conteudo)-3)
  end if
  if right(trim(Conteudo),1) = "," then
      ConteudoTratado =  mid(Conteudo,1,len(Conteudo)-1)
  end if
  if ConteudoTratado&"" = "" then
    removeNullDelimiter = Conteudo
  else
    removeNullDelimiter = ConteudoTratado
  end if
End Function
'Response.write(removeNullDelimiter("1, 1, 1, 2, "))
'Response.write(removeNullDelimiter("|1|, |2|, |9|, |17|, |240829|, |240832|, |241301|, |-83|, |-84|, |-94|, |"))
Function RemoveCaractersRegex(Conteudo,QuebraLinha)
  Set regEx = New RegExp
  'regEx.Pattern = "[^\w]"
  regEx.Pattern = "[^\w\s]|[ºª]"
  regEx.Global = True
  valorTratado = regEx.Replace(Conteudo, "")
  if QuebraLinha=false then
    valorTratado = replace(replace(valorTratado,chr(13)," "),chr(10)," ")
  end if
  valorTratado = replace(replace(valorTratado,"  "," "),"  "," ")
  RemoveCaractersRegex = valorTratado
End Function
Function RemoveCaracters(Conteudo,Valores) 
AddVal = Valores 'Exemplo("!?:;*/") 
RemVal = "" 
Texto = "" 
    if Conteudo <> "" then 
        For X = 1 to Len(Conteudo) 
            Letra = mid(Conteudo,X,1) 
            Pos_Val = inStr(AddVal,Letra) 
                if Pos_Val > 0 then 
                    Letra = mid(RemVal,Pos_Val,1) 
                end if 
            Texto = Texto & Letra 
        next 
        RemoveCaracters = replace(replace(Texto&"","  "," "),"  "," ")
    end if 
end function

function formatCPF(cpf)
    if cpf&"" <> "" then
        cpfSemFormatacao = RemoveCaracters(cpf," .-/")
        TamanhoCPF = Len(cpfSemFormatacao)
        if TamanhoCPF = 11 then
            Campo1 = Left(cpfSemFormatacao,3)
            Campo2 = Mid(cpfSemFormatacao,4,3)
            Campo3 = Mid(cpfSemFormatacao,7,3)
            Campo4 = Right(cpfSemFormatacao,2)
            formatCPF = Campo1&"."&Campo2&"."&Campo3&"-"&Campo4
        else
            formatCPF = cpf
        end if
    else
        formatCPF = cpf&""
    end if
end function

Function AlteraCaracters(Conteudo,De,Para)
'EXEMPLO DE USO
'response.write(AlteraCaracters("Oi. Tudo Bem?",".?",",!"))

Texto = "" 
    if Conteudo <> "" then 
        For X = 1 to Len(Conteudo) 
            Letra = mid(Conteudo,X,1) 
            Pos_Acento = inStr(De,Letra) 
                if Pos_Acento > 0 then 
                    Letra = mid(Para,Pos_Acento,1) 
                end if 
            Texto = Texto & Letra 
        next 
        AlteraCaracters = Texto 
    end if 
end function

Function RemoveAcentoPalavras(Conteudo) 
CAcento = "àáâãäèéêëìíîïòóôõöùúûüÀÁÂÃÄÈÉÊËÌÍÎÒÓÔÕÖÙÚÛÜçÇñÑ" 
SAcento = "aaaaaeeeeiiiiooooouuuuAAAAAEEEEIIIOOOOOUUUUcCnN" 
Texto = "" 
    if Conteudo <> "" then 
        For X = 1 to Len(Conteudo) 
            Letra = mid(Conteudo,X,1) 
            Pos_Acento = inStr(CAcento,Letra) 
                if Pos_Acento > 0 then 
                    Letra = mid(SAcento,Pos_Acento,1) 
                end if 
            Texto = Texto & Letra 
        next 
        RemoveAcentoPalavras = Texto 
    end if 
end function


%>