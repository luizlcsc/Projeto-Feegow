<%
Function strip_tags(text_to_strip)
    Set Regex = New RegExp
    Regex.Pattern = "<(.|\n)+?>"
    Regex.Global = True
    strip_tags = Regex.Replace(Trim(text_to_strip),"")
    strip_tags = replace(strip_tags, "<", "")
    strip_tags = replace(strip_tags, ">", "")
End Function

function clear_ref_req (val, escapeQuotes)
        '1- remove all
        '2- escape
        '3- keep 

        tentativa = false
    
        'EH UM CARACTER FANTASMA . NAO REMOVER A LINHA DE BAIXO !!!!!
        val = replace(val, "​", "")
        
        val = replace(val, "'", "''")
        val = replace(val,"\", "\\")
        val = replace(val,"<script>", "")
        val = replace(val,"</script>", "")
        ' val = replace(val,"&lt;", "")
        ' val = replace(val,"&gt;", "")
        val = replace(val,"&quot;", "")
        val = replace(val,"&#x27;", "")
        val = replace(val,"&#x22;", "")
        val = replace(val,"&#x7c;", "")

        'if escapeQuotes=1 then
        '    val = replace(val, """", "")
        'elseif escapeQuotes=2 or escapeQuotes=3 then
        'end if
        val = replace(val, """", "&quot;")

        clear_ref_req = val
end function 

function ref(ColVal)
    val = request.Form(ColVal)
    'val = forceInputInteger(ColVal, val)
    val = strip_tags(val)

    ref = clear_ref_req(val, 2)
end function

function intval(textVal)
     if not isnumeric(textVal) and textVal<>"N" and textVal<>"" then
        textVal = 0
    end if
    intval = textVal
end function

function customLog(logType, message)
    filename = Request.ServerVariables("SCRIPT_NAME")&"?P="&req("P")

    db.execute("INSERT INTO cliniccentral.custom_log (LicenseID,LogType, FileName, Line, Message) Values ("&LicenseID&", "&logType&", '"&filename&"', 0, '"&clear_ref_req(message,2)&"')")
end function

function stringIsNumericArray(str)
    isNumericArray = False

    if instr(str&"",",")>0 then
        isNumericArray = True

        splRef = split(replace(str,"|",""),",")
        for i=0 to ubound(splRef)
            n = trim(splRef(i))

            if not isnumeric(n) then
                isNumericArray = False
            end if
        next
    end if

    stringIsNumericArray=isNumericArray
end function

function forceInputInteger(colValKey, val)

    if val&""<>"" then
        rightSufix = lcase(right(colValKey, 2)&"")
        accountIdMulti = left(val, 4)

        if colValKey="I" or colValKey="II" or colValKey="X" or (rightSufix="id" and instr(accountIdMulti,"_")=0 and colValKey<>"selectID") then
            isNumericArray = stringIsNumericArray(val)
            isAcceptableValue = val = "undefined" or val = "ALL" or val = "null" or (left(val,1)="|" and right(val,1)="|")

            if not isNumericArray and not isAcceptableValue then
                forcedIntVal = val
                forcedIntVal = intval(forcedIntVal)

                if forcedIntVal&""<>val&"" then
                    call customLog(10, colValKey&": "&val &" changed to "&forcedIntVal)
                end if

                val=forcedIntVal
            end if
        end if
    end if
    forceInputInteger=val
end function

function refHTML(ColVal)
    val = request.Form(ColVal)
    refHTML = clear_ref_req(val, 3)
end function

function req(ColVal)
    val = request.QueryString(ColVal)
    'val = forceInputInteger(ColVal, val)
    val = strip_tags(val)
    req = clear_ref_req(val, 1)
end function

function reqHTML(ColVal)
    reqHTML = clear_ref_req(request.QueryString(ColVal), 3)
end function

function refNull(ColVal)
	if ref(ColVal)&"" = "" then
		refNull = "NULL"
	else
		refNull = ref(ColVal)
	end if
end function

function unscapeOutput(outputVal)
    unscapeOutput = replace(outputVal&"","&quot;", """")
end function

function reqf(P)

    if request.QueryString(P)<>"" then
        reqf = req(P)
    else

        reqf = ref(P)
    end if
end function

startTime = timer

function getPageLoadtime()
    endTime = timer
    timeDiff = endTime-startTime
    if startTime<=0 then
        timeDiff = 0
    end if

    dd(timeDiff)
end function

function dd(variable)
    description=""
    variableType = TypeName(variable)


    if variableType="Variant()" then
        description = description & "["
        itemsInArray=0

        for each x in variable
            if itemsInArray>0 then
                description = description&","
            end if

            description = description&""""&x&""""
            itemsInArray=itemsInArray+1
        next
        description = description & "]"
    elseif variableType="Recordset" then
        description = "["&chr(13)
        j = 0
        while not variable.eof
            IF j <> 0 THEN
                 description = description&str&","
            END IF
            j = j+1
            i = 0
            str = chr(32)&"{"
            for each x in variable.Fields
                i = i+1
                str = str&chr(13)&chr(32)&chr(32)&""""&x.name&""":"""&replace(x.value&"","""","'")&""""
                IF i < variable.Fields.Count THEN
                    str = str&","
                END IF
            next
            str = str&chr(13)&chr(32)&"}"
        variable.movenext
        wend

        description = description&str&chr(13)&"]"

    elseif isnull(variable) then
        description="NULL"
    else
        description = variable
    end if

    response.write("<pre>"&description&"</pre>")
    Response.End
end function

function injection()
%>
<script>
new PNotify({
    title: 'Ocorreu um erro!',
    text:'Operação não permitida',
    type: 'danger',
    delay: 10000
});
</script>

<%
    Response.End
end function


function CalculoSemanalQuinzenal(FrequenciaSemanas, InicioVigencia)
    CalculoSemanalQuinzenal = true
    if isnumeric(FrequenciaSemanas) then
        if InicioVigencia&"" = "" then
            InicioVigencia = date()
        end if
        if FrequenciaSemanas>1 then
            NumeroDeSemanaPassado = datediff("w",InicioVigencia,Data)
            RestoDivisaoNumeroSemana = NumeroDeSemanaPassado mod FrequenciaSemanas
            if RestoDivisaoNumeroSemana>0 then
                CalculoSemanalQuinzenal=False
            end if
        end if
    end if
end function

Function in_array(element, arr)
  in_array = False
  For i=0 To Ubound(arr)
     If Trim(arr(i)) = Trim(element) Then
        in_array = True
        Exit Function      
     End If
  Next
End Function

%>