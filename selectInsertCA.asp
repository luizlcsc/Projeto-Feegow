<!--#include file="connect.asp"-->
<%
selectUnion = ""
splUnions = split(ref("associations"), ", ")
for un=0 to ubound(splUnions)
	resultado = aaTable(splUnions(un))
	sqlWhereOr = ""
	colunaValor=resultado(2)

	if resultado(0)="profissionais" or resultado(0)="fornecedores" then
        Ativo = " AND Ativo='on' "
    else
        Ativo = ""
    end if

	if resultado(0)="profissionais" or resultado(0)="profissionalexterno" then
        sqlWhereOr = " OR replace(replace(DocumentoConselho,'-',''),'.','') LIKE '%"&replace(ref("typed"), " ", "%")&"%' "
        colunaValor=" CONCAT(IFNULL(NomeProfissional,''), ' (',IFNULL(DocumentoConselho,''),')') "
    end if

	if resultado(0)="profissionais" or resultado(0)="Pacientes" then
        nomeSocial = " OR NomeSocial like '"&replace(ref("typed"), " ", "%")&"%' "
    else
        nomeSocial = ""
    end if

    active = " and sysActive=1 "
    if resultado(0)="caixa" then
        active = " and Descricao like '%Aberto%' and isnull(dtFechamento) "
    end if
    'response.write(resultado(1))

    IF (resultado(1) = "Paciente") THEN
	    selectUnion = selectUnion&"(select id, '"&splUnions(un)&"' associacao, '"&resultado(1)&"' recurso, "&colunaValor&" coluna from `"&resultado(0)&"` where ("&resultado(2)&" like '"&replace(ref("typed"), " ", "%")&"%' "&nomeSocial&sqlWhereOr&") "&Ativo&active&" order by "&resultado(2)&" limit 50) UNION ALL "
	ELSE
	    selectUnion = selectUnion&"(select id, '"&splUnions(un)&"' associacao, '"&resultado(1)&"' recurso, "&colunaValor&" coluna from `"&resultado(0)&"` where ("&resultado(2)&" like '"&replace(ref("typed"), " ", "%")&"%' "&nomeSocial&Ativo&sqlWhereOr&") "&active&" order by "&resultado(2)&" limit 50) UNION ALL "
	END IF
	'strInserts = strInserts&"<label><input type=""radio"" name=""radio"&ref("selectID")&""" class=""ace""><span class=""lbl""> "&resultado(1)&"</span></label>"

	if aut(lcase(resultado(0))&"I")=1 and splUnions(un)<>5 and splUnions(un)<>4  then
		strInserts = strInserts&"<option value="""&splUnions(un)&""">"&resultado(1)&"</option>"
	end if
next

if session("Banco")="clinic100000" OR session("Banco")="clinic5459" then
    'response.write("Banco: "&session("Banco"))
    'response.write("<br><br>")
    'response.write("selectUnion: "&selectUnion)
	selectUnion = selectUnion&"(SELECT p.id id, '3' associacao, 'Licença' recurso, COALESCE(lu.Nome, lu.Email) coluna FROM `cliniccentral`.`licencasusuarios` lu LEFT JOIN `cliniccentral`.`licencas` l ON l.id=lu.LicencaID LEFT JOIN pacientes p ON p.id=l.Cliente where l.Cliente<>0 AND l.Cliente IS NOT NULL AND (lu.Nome like '"&replace(ref("typed"), " ", "%")&"%' OR lu.Email like '"&replace(ref("typed"), " ", "%")&"%') AND lu.Nome <> '' AND lu.Email <> '' order by COALESCE(lu.Nome, lu.Email) limit 50) UNION ALL "
	'response.write("<br><br>")
    'response.write("selectUnion: "&selectUnion)
end if


selectUnion = left(selectUnion, len(selectUnion)-11)
if session("Banco")="clinic5760" then
    'response.Write(selectUnion &"<br>")
end if
'set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName like '"&ref("resource")&"'")
'sql = replace(dadosResource("sqlSelectQuickSearch"), "[TYPED]", ref("typed"))
'sql = replace(sql, "[campoSuperior]", ref("campoSuperior"))

'response.Write(sql)

'response.Write(selectUnion)

set ConfigSQL = db.execute("select ValidarCPFCNPJ, BloquearCPFCNPJDuplicado from sys_config where id=1")
ValidarFornecedor=False
if not ConfigSQL.eof then
    if ConfigSQL("ValidarCPFCNPJ")&""="S" or ConfigSQL("BloquearCPFCNPJDuplicado")&""="S" then
        ValidarFornecedor=True
    end if
end if

set list = db.execute(selectUnion)
if list.eof then
	%>
    <ul class="select-insert">
        <li><small>Nenhum encontrado &raquo;
        <%
        if strInserts<>"" then
        %>
        Cadastrar &raquo; <select style="width: 70%;float:left" id="tabela<%=ref("selectID")%>" class="form-control input-sm select-sm"><%=strInserts%></select><button style="width: 25%;float: left;" type="button" class="btn btn-sm btn-primary ml10" id="button-insert-<%=ref("selectID")%>"><i class="far fa-plus"></i> Inserir</button></small>
        </li>
    </ul>
	<%
	scriptInsert="S"
	end if
else
	while not list.eof
		if recurso="" then
			%>
			<table border="1" class="table table-condensed table-striped">
			<tr>
			<%
		end if
		if recurso<>list("recurso") and recurso<>"" then
			%></td><%
		end if
		if recurso<>list("recurso") then
			%><td width="100" style="vertical-align:top"><div class="SelectMultipleTitle"><%=ucase(list("recurso"))%></div><%
		end if
		
		recurso = list("recurso")
if session("Banco")="clinic5760" then
    'response.Write(selectUnion &"<br>")
end if
            if list("recurso")<>"Caixa" or (list("recurso")="Caixa" and instr(list("Coluna"), "Aberto")>0) then
		    %>
		    <div type="button" class="select-insert-item text-left" data-title="<%=list("coluna")%>" data-valor="<%=list("associacao")&"_"&list("id")%>" <%= replace(replace(ref("othersToSelect"), "onchange", "onclick"), "this.id", "'select-"&ref("selectID")&"'") %>>
                <%=list("coluna")%></div>
		    <%
            end if
	list.movenext
	wend
	list.close
	set list=nothing
	%></td>
    </tr>
	</table>
	<%
end if
%>
</ul>
<script type="text/javascript">
jQuery(function($) {
<%
if scriptInsert = "" then
	%>
	$("#<%=ref("selectID")%>").val(0);
	$(".select-insert-item").click(function(){
		$("#search<%=ref("selectID")%>").val($(this).attr("data-title"));
		$("#<%=ref("selectID")%>").val($(this).attr("data-valor")).change();
		$("#resultSelect<%=ref("selectID")%>").css("display", "none");
	});
	<%
else
	%>
  $("#button-insert-<%=ref("selectID")%>").click(function(){
	$(this).val("Salvando...");
	var tabela = $("#tabela<%=ref("selectID")%>").val();
	var validarFornecedor = '<% if ValidarFornecedor then %>1<% else %>0<% end if %>';

	if(tabela.toLowerCase() === "fornecedores" && validarFornecedor == 1){
        location.href='?P=Fornecedores&Pers=1&I=N';
	}else{
        $.post("selectInsertSaveCA.asp",{
               selectID:'<%=ref("selectID")%>',
               typed:'<%=ref("typed")%>',
               <%=OutrosCampos%>
               tabela:tabela,
                associations: '<%=ref("associations")%>',
                mainFormColumn:'<%'=dadosResource("mainFormColumn")%>',
                campoSuperior: '<%=ref("campoSuperior")%>'
               },function(data,status){
                eval(data);
        });
    }
  });
  $("#search<%=name%>").click(function(){
	this.select();
  });
	<%
	if carregaFuncoes="S" then
		%><!--#include file="jQueryFunctions.asp"--><%
	end if
end if
%>
});
</script>