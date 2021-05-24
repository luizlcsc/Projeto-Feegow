<%
Function strip_tags(text_to_strip)
    Set Regex = New RegExp
    Regex.Pattern = "<(.|\n)+?>"
    Regex.Global = True
    strip_tags = Regex.Replace(Trim(text_to_strip),"")
End Function

function clear_ref_req (val)
        val = strip_tags(val)
        val = replace(val, "'", "''")
        val = replace(val,"\", "\\")
        val = replace(val,"<script>", "")
        val = replace(val,"</script>", "")
        val = replace(val,"&amp;", "")
        val = replace(val,"&lt;", "")
        val = replace(val,"&gt;", "")
        val = replace(val,"&quot;", "")
        val = replace(val,"&#x27;", "")
        val = replace(val,"&#x22;", "")
        val = replace(val,"&#x27;", "")
        clear_ref_req = val
end function 

function ref(Val)
	' ref = replace(replace(ref(Val), "'", "''"), "\", "\\")

    val = request.Form(Val)

    ref = clear_ref_req(val)
end function

function req(Val)
	' req = replace(request.QueryString(Val), "'", "''")
    req = clear_ref_req(request.QueryString(Val))
end function

function refNull(Val)
	if ref(Val)&"" = "" then
		refNull = "NULL"
	else
		refNull = ref(Val)
	end if
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

%>