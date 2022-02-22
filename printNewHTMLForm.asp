<%
response.Charset="utf-8"
%>
		<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		<!--link rel="stylesheet" href="assets/css/animate.css" />-->

		<!--[if IE 7]>
		  <link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" />
		<![endif]-->



<link rel="stylesheet" type="text/css" href="site/jquery.gridster.css">
<link rel="stylesheet" type="text/css" href="site/demo.css">
<link rel="stylesheet" type="text/css" href="buiforms.css">
<script type="text/javascript" src="assets/js/jquery.min.js"></script>
<script src="site/jquery.gridster.js" type="text/javascript" charset="utf-8"></script>
	<!-- fonts -->

<body class="mr10">
<%
'response.write(request.QueryString)


formHTML = unscapeOutput(getForm("HTML"))
formHTML = replaceTags(formHTML, PacienteID, session("User"), session("UnidadeID"))
response.Write(formHTML)

if req("FormID")<>"" and isnumeric(req("FormID")) then
	response.write("<script type='text/javascript'>")
	set val = db.execute("select * from _"&req("ModeloID")&" where id="&req("FormID"))
	if not val.eof then
		set camVals = db.execute("select * from buicamposforms where FormID="&req("ModeloID"))
		while not camVals.eof
			set vca = db.execute("select i.table_name from information_schema.`COLUMNS` i where i.TABLE_SCHEMA='"&session("banco")&"' and i.TABLE_NAME='_"&req("ModeloID")&"' and i.COLUMN_NAME='"&camVals("id")&"'")
			if not vca.eof then
                if camVals("TipoCampoID")=4 then
                    valor = val(""&camVals("id")&"")&""
                    if valor<>"" then
                        spl = split(valor, ", ")
                        for ival=0 to ubound(spl)
                            response.write("$(""input[name='input_"& camVals("id")&"'][value='"& spl(ival) &"']"").prop(""checked"", true);")
                        next
                    end if
                else
				    valor = val(""&camVals("id")&"")&""
				    valor = replace(valor, chr(13), "")
				    valor = replace(valor, chr(10), "")
				    response.write("$('[name=input_"& camVals("id")&"]').val("""& valor &""");")
                end if
			end if
		camVals.movenext
		wend
		camVals.close
		set camVals = nothing
	end if
	response.write("</script>")
end if
%>
</body>