<%
function recordToJSON(reg)
    result = "["
    j = 0
    while not reg.eof
        IF j <> 0 THEN
             result = result&str&","
        END IF
        j = j+1
        i = 0
        str = "{"
        for each x in reg.Fields
            i = i+1
            str = str&""""&x.name&""":"""&replace(replace(replace(x.value&"","""","'"),chr(13),""),chr(10),"")&""""
            IF i < reg.Fields.Count THEN
                str = str&","
            END IF
        next
        str = str&"}"
    reg.movenext
    wend

    result = result&str&"]"

    recordToJSON = result
end function

function fieldToJSON(reg)

    str = "{"
            for each x in reg
                i = i+1
                str = str&""""&x.name&""":"""&replace(x.value&"","""","'")&""""

                IF i < reg.Count THEN
                    str = str&","
                END IF
    next
    str = str&"}"

    fieldToJSON = str
end function

function consoleLogJSONFields(reg)
    %>
<script>
    console.log(<%=fieldToJSON(reg)%>)
</script>
<%
end function

function consoleLogJSONRecord(reg)
    %>
<script>
    console.log(<%=recordToJSON(reg)%>)
</script>
<%
end function


function responseJson(stringJson)
    Response.ContentType = "application/json"
    response.Write(stringJson)
    Response.End
end function

function jsonHeader(param1)
    Response.ContentType = "application/json"
end function
%>