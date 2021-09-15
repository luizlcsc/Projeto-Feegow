<!--#include file="connect.asp"-->
<%
Filtro = ref("Filtro")

if ref("X")<>"" then
	if Filtro="TextoAtestado" then
		db_execute("delete from pacientesatestadostextos where id="&ref("X"))
	end if
	Filtro=""
end if

if Filtro="" then
	set listaTextosAtestados = db.execute("select *, IFNULL(TipoID, 99999999) as TipoID from pacientesatestadostextos as pt left join prontuariosfavoritos as pf on pf.TipoID = pt.id and pf.Tipo = 'A' and pf.sysUser = "&session("User")&"  where sysActive=1 and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) order by TipoID, NomeAtestado")
else
	set listaTextosAtestados = db.execute("select *, IFNULL(TipoID, 99999999) as TipoID from pacientesatestadostextos as pt left join prontuariosfavoritos as pf on pf.TipoID = pt.id and pf.Tipo = 'A' and pf.sysUser = "&session("User")&" where NomeAtestado like '%"&Filtro&"%' and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) and sysActive=1 order by TipoID, NomeAtestado")
end if
while not listaTextosAtestados.EOF
	'TextoAtestado = listaTextosAtestados("TextoAtestado")
    if 1=2 then
	%>
	<div class="profile-activity clearfix">
		<div>
			<strong><span id="NomeAtestado<%=listaTextosAtestados("id")%>"><%=listaTextosAtestados("NomeAtestado")%></span></strong>
			<span id="TituloAtestado<%=listaTextosAtestados("id")%>" class="hidden"></span>
			<div class="time hidden">
				<i class="far fa-list bigger-110"></i>
				<span id="TextoAtestado<%=listaTextosAtestados("id")%>"><%=TextoAtestado%></span>
			</div>
		</div>
	
		<div class="tools action-buttons">
			<span class="tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Aplicar">
			<a href="#" data-toggle="modal" class="blue" onClick="aplicarTextoAtestado(<%=listaTextosAtestados("id")%>)">
				<i class="far fa-hand-o-left icon-hand-left bigger-125"></i>
			</a>
			</span>
            <%if aut("atestadosA")=1 then%>
			<span class="tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Editar">
			<a class="green tooltip-info" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar modelos de atestados e textos para futuras emiss&otilde;es" data-rel="tooltip" data-placement="top" title="" onclick="modalTextoAtestado('TextoAtestado', <%=listaTextosAtestados("id")%>)">
				<i class="far fa-edit icon-edit bigger-125"></i>
			</a>
			</span>
			<%
			end if
            if aut("atestadosX")=1 then
			%>
			<span class="tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
			<a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaTextosAtestados('TextoAtestado', <%=listaTextosAtestados("id")%>)" class="red">
				<i class="far fa-remove icon-remove bigger-125"></i>
			</a>
			</span>
			<%end if%>
		</div>
	</div>
    <%
    end if
    %>
	<tr id="<%=listaTextosAtestados("id")%>">
        <td width="1%"><a href="javascript:aplicarTextoAtestado(<%=listaTextosAtestados("id")%>);">
            <i class="far fa-hand-o-left"></i>
            </a>
        </td>

    	<td id="NomeAtestado<%=listaTextosAtestados("id")%>" style="word-break: break-word;"> <%=listaTextosAtestados("NomeAtestado")%></td>

        <td width="1%" nowrap>
        <%if aut("atestadosA")=1 then%>
		<a class="btn btn-xs btn-success tooltip-info" href="javascript:modalTextoAtestado('TextoAtestado','<%=listaTextosAtestados("id") %>')">
			<i class="far fa-edit icon-edit bigger-125"></i>
		</a>
		<%
		elseif (aut("atestadosA")=0 and aut("modelosprontuarioA")=1 and listaTextosAtestados("sysUser")=session("User")) then%>
		<a class="btn btn-xs btn-success tooltip-info" href="javascript:modalTextoAtestado('TextoAtestado','<%=listaTextosAtestados("id") %>')">
			<i class="far fa-edit icon-edit bigger-125"></i>
		</a>
		<%
        end if
        if aut("atestadosX")=1 then
        %>
		<a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaTextosAtestados('TextoAtestado','<%=listaTextosAtestados("id")%>')" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
			<i class="far fa-remove icon-remove bigger-125"></i>
		</a>
        <%
        elseif (aut("atestadosX")=0 and aut("modelosprontuarioA")=1 and listaTextosAtestados("sysUser")=session("User")) then
        %>
		<a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaTextosAtestados('TextoAtestado','<%=listaTextosAtestados("id")%>')" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
			<i class="far fa-remove icon-remove bigger-125"></i>
		</a>
        <%end if%>
        <a href="#" class="btn btn-xs tooltip-info btnfavoritos" title="Favoritos" data-tipo="A" data-id="<%=ListaTextosAtestados("id")%>" data-placement="top" data-rel="tooltip" data-original-title="Favoritos">
            <% if ListaTextosAtestados("TipoID")<>"99999999" then %>
                <i class="far fa-star bigger-125" data-favorito="0"></i>
            <% else %>
                <i class="fas fa-star bigger-125" data-favorito="1"></i>
            <% end if %>
            </a>
        </td>
    </tr>
    <%
listaTextosAtestados.movenext
wend
listaTextosAtestados.close
set listaTextosAtestados = nothing
    %>
	<script type="text/javascript">
    <%
if ref("Aplicar")="TextoAtestado-Last" then
	set getLast = db.execute("select id, sysUser, sysActive from pacientesatestadostextos where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")
	%>
		aplicarTextoAtestado(<%=getLast("id")%>);
	<%
end if


if session("sqlAtestados")<>"" then
sql = "SELECT id FROM pacientesatestadostextos WHERE 1=2 "&session("sqlAtestados")&" "
'response.write("alert("""& sql &""");")
t = 0
set meds = db.execute(sql)
while not meds.eof
t=t+1500
%>
setTimeout(function(){
    aplicarTextoAtestado(<%=meds("id")%>);;
}, <%=t%>);
<%
meds.movenext
wend
meds.close
set meds = nothing
        
session("sqlMedicamentos") = ""
end if
%>

	</script>
<script src="favoritarprontuario.js"></script>