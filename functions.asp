<%
Function strip_tags(text_to_strip)
    Set Regex = New RegExp
    Regex.Pattern = "<(.|\n)+?>"
    Regex.Global = True
    strip_tags = Regex.Replace(Trim(text_to_strip),"")
End Function

function clear_ref_req (val, removeQuotes)
        '1- remove all
        '2- escape
        '3- keep 

        tentativa = false
    
        val = replace(val, "'", "''")
        val = replace(val,"\", "\\")
        if removeQuotes=1 then
            val = replace(val, """", "")
        elseif removeQuotes=2 then
            val = replace(val, "\""", """")
            val = replace(val, """", "\""")
        end if
        val = replace(val,"<script>", "")
        val = replace(val,"</script>", "")
        ' val = replace(val,"&lt;", "")
        ' val = replace(val,"&gt;", "")
        val = replace(val,"&quot;", "")
        val = replace(val,"&#x27;", "")
        val = replace(val,"&#x22;", "")
        val = replace(val,"&#x7c;", "")
        
        clear_ref_req = val
end function 

function ref(ColVal)
    val = request.Form(ColVal)
    val = strip_tags(val)

    ref = clear_ref_req(val, 2)
end function

function refHTML(ColVal)
    val = request.Form(ColVal)
    refHTML = clear_ref_req(val, 3)
end function

function req(ColVal)
    val = request.QueryString(ColVal)
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


%>