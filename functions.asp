<%
Function strip_tags(text_to_strip)
    Set Regex = New RegExp
    Regex.Pattern = "<(.|\n)+?>"
    Regex.Global = True
    strip_tags = Regex.Replace(Trim(text_to_strip),"")
End Function

function clear_ref_req (val)
        tentativa = false
        if instr(UCase(val)," AND ") OR instr(UCase(val)," OR ") OR instr(UCase(val)," SELECT ") OR instr(UCase(val)," FROM ") OR instr(UCase(val)," GROUP BY ") OR instr(UCase(val)," CONCAT ") OR instr(UCase(val)," CONCAT_WS") OR instr(UCase(val)," DELETE ") OR instr(UCase(val)," UNION ") OR instr(UCase(val)," JOIN ") OR instr(UCase(val),"CONCAT") OR instr(UCase(val),"UPDATEXML") OR instr(UCase(val),"'") OR instr(UCase(val),"\") OR instr(UCase(val),"<script>") OR instr(UCase(val),"</script>") OR instr(UCase(val),"&lt;") OR instr(UCase(val),"&gt;") OR instr(UCase(val),"&quot;") OR instr(UCase(val),"&#x27;") OR instr(UCase(val),"&#x22;") OR instr(UCase(val),"&#x7c;") OR instr(UCase(val),"(ELT") OR instr(UCase(val),";") OR instr(UCase(val),"drop") OR instr(UCase(val),"table") OR instr(UCase(val),"--") OR instr(UCase(val),"%") OR instr(UCase(val),"EXECUTE") OR instr(UCase(val),"EXEC") OR instr(UCase(val),"EVAL") OR instr(UCase(val),"WHERE") OR instr(UCase(val),"SP_EXECUTESQL") OR instr(UCase(val),"UPDATE")then
            val = replace(val, "'", "''")
            val = replace(val,"\", "\\")
            val = replace(val,"<script>", "")
            val = replace(val,"</script>", "")
            val = replace(val,"&lt;", "")
            val = replace(val,"&gt;", "")
            val = replace(val,"&quot;", "")
            val = replace(val,"&#x27;", "")
            val = replace(val,"&#x22;", "")
            val = replace(val,"&#x7c;", "")
            val = replace(val," AND ", "")
            val = replace(val," OR ", "")
            val = replace(val,"GROUP BY", "")
            val = replace(val,"CONCAT", "")
            val = replace(val,"CONCAT_WS", "")
            val = replace(val,"DELETE", "")
            val = replace(val," UNION ", "")
            val = replace(val,"JOIN", "")
            val = replace(val,"SELECT", "")
            val = replace(val,"CONCAT", "")
            val = replace(val,"UPDATEXML", "")
            val = replace(val,";", "")
            val = replace(val,"DROP", "")
            val = replace(val,"TABLE", "")
            val = replace(val,"--", "")
            val = replace(val,"%", "")
            val = replace(val,"EXECUTE", "")
            val = replace(val,"EXEC", "")
            val = replace(val,"EVAL", "")
            val = replace(val,"WHERE", "")
            val = replace(val,"SP_EXECUTESQL", "")
            val = replace(val,"UPDATE", "")
            tentativa = true
        end if 
        
        if tentativa then 
            injection()
        end if
        clear_ref_req = val
end function 

function ref(ColVal)

    val = request.Form(ColVal)
    val = strip_tags(val)

    ref = clear_ref_req(val)
end function

function refHTML(ColVal)
    val = request.Form(ColVal)
    refHTML = clear_ref_req(val)
end function

function req(ColVal)
    val = request.QueryString(ColVal)
    val = strip_tags(val)
    req = clear_ref_req(val)
end function

function reqHTML(ColVal)
    reqHTML = clear_ref_req(request.QueryString(ColVal))
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