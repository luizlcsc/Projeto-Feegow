
<meta charset="UTF-8"/>

<input type="hidden" name="FormID" id="FormID" value="<%=formID%>" />
<%
'response.write(request.QueryString)
if req("i")<>"" and isnumeric(req("i")) then
	response.write("<script type='text/javascript'>")
    if req("IFR")="S" then
        %>
        $(document).ready(function(){
        <%
    end if
	set val = db.execute("select * from _"&req("m")&" where id="&req("i"))
	if not val.eof then
		set camVals = db.execute("select * from buicamposforms where FormID="&req("m"))
		while not camVals.eof
			set vca = db.execute("select i.table_name from information_schema.`COLUMNS` i where i.TABLE_SCHEMA='"&session("banco")&"' and i.TABLE_NAME='_"&req("m")&"' and i.COLUMN_NAME='"&camVals("id")&"'")
			if not vca.eof then
                if camVals("TipoCampoID")=4 OR camVals("TipoCampoID")=5 then

                    if IsObject(val) then
                        valor = val(""&camVals("id")&"")&""
                    else
                        valor = ""
                    end if
                    if valor<>"" then
                        spl = split(valor, ", ")
                        for ival=0 to ubound(spl)
                            response.write("$(""input[name='input_"& camVals("id")&"'][value='"& spl(ival) &"']"").prop(""checked"", true);")
                        next
                    end if
                else
                    if IsObject(val) then
                        valor = val(""&camVals("id")&"")&""
                    else
                        valor = ""
                    end if
				    valor = replace(valor, chr(13), "")
				    valor = replace(valor, chr(10), "")
				    response.write("$('[name=input_"& camVals("id")&"]').val("""& valor &""");")
                end if

                if camVals("TipoCampoID")=8 then
                    response.write("$('#input_"& camVals("id")&"mem').html($('#input_"& camVals("id")&"').val());")
                end if
			end if
		camVals.movenext
		wend
		camVals.close
		set camVals = nothing
	end if
    if req("IFR")="S" then
        %>
        });
        <%
    end if
	response.write("</script>")
end if

    formHTML = getForm("HTML")&""
    formHTML = replaceTags(formHTML, PacienteID, session("User"), session("UnidadeID"))
    response.Write(formHTML)


	%>