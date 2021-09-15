<div class="label label-primary btn-block arrowed-in arrowed-in-right label-lg"><%=Rotulo%></div>
<div class="row">
	<%=quickfield("select", "Inserir"&tipo, "Adicionar propriedade", 12, "", "select id, Descricao from buiformsparametros where id not in(select e.ParametroID from buiformsestilo e left join buiformsparametros p on p.id=e.ParametroID where e.FormID="&FormID&" and e.Elemento='"&Tipo&"') UNION ALL select '0', '--- Selecione ---' order by Descricao", "Descricao", " onchange=""editStyle('Add', '"&Tipo&"', '"&Rotulo&"', this.value, '');""")%>
</div>
<%
set campos = db.execute("select e.*, p.Descricao from buiformsestilo e left join buiformsparametros p on p.id=e.ParametroID where e.FormID="&FormID&" and e.Elemento='"&Tipo&"'")
while not campos.eof
	%>
    <div class="row">
		<%=quickfield("text", "campo-"&campos("id"), campos("Descricao"), 10, campos("Valor"), "", "", " onblur=""editStyle('Update', '"&Tipo&"', '"&Rotulo&"', "&campos("id")&", this.value);""")%>
        <div class="col-md-2"><label>&nbsp;</label><br>
	        <button type="button" class="btn btn-danger btn-sm" onClick="if(confirm('Tem certeza de que deseja remover este estilo?'))editStyle('Remove', '<%=Tipo%>', '<%=Rotulo%>', <%=campos("id")%>, '');"><i class="far fa-remove"></i></button>
        </div>
    </div>
	<%
campos.movenext
wend
campos.close
set campos = nothing
%>