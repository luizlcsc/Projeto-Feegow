<!--#include file="connect.asp"-->
<%
Filtro = ref("Filtro")
EspecialidadeID = ref("EspecialidadeID")
if ref("X")<>"" then
	if Filtro="Encaminhamento" then
		db_execute("update encaminhamentostextos set sysActive=-1 where id="&ref("X"))
	end if
	Filtro=""
end if

if Filtro="" then
	set listaEncaminhamentos = db.execute("select *, IFNULL(TipoID, 99999999) as TipoID from encaminhamentostextos as pt left join prontuariosfavoritos as pf on pf.TipoID = pt.id and pf.Tipo = 'A' and pf.sysUser = "&session("User")&"  where sysActive=1 and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) and (especialidades is null or especialidades='' or especialidades like '%|"&EspecialidadeID&"|%' or "&session("Admin")&"=1) order by TipoID")
else
	set listaEncaminhamentos = db.execute("select *, IFNULL(TipoID, 99999999) as TipoID from encaminhamentostextos as pt left join prontuariosfavoritos as pf on pf.TipoID = pt.id and pf.Tipo = 'A' and pf.sysUser = "&session("User")&" where NomeAtestado like '%"&Filtro&"%' and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) and (especialidades is null or especialidades='' or especialidades like '%|"&EspecialidadeID&"|%' or "&session("Admin")&"=1) and sysActive=1 order by TipoID")
end if
while not listaEncaminhamentos.EOF
	'TextoAtestado = listaTextosAtestados("TextoAtestado")
    if 1=2 then
	%>
	<div class="profile-activity clearfix">
		<div>
			<strong><span id="NomeEncaminhamento<%=listaEncaminhamentos("id")%>"><%=listaEncaminhamentos("NomeAtestado")%></span></strong>
			<span id="TituloEncaminhamento<%=listaEncaminhamentos("id")%>" class="hidden"></span>
			<div class="time hidden">
				<i class="fa fa-list bigger-110"></i>
				<span id="Encaminhamento<%=listaEncaminhamentos("id")%>"><%=Encaminhamento%></span>
			</div>
		</div>
	
		<div class="tools action-buttons">
			<span class="tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Aplicar">
			<a href="#" data-toggle="modal" class="blue" onClick="aplicarEncaminhamento(<%=listaEncaminhamentos("id")%>)">
				<i class="fa fa-hand-o-left icon-hand-left bigger-125"></i>
			</a>
			</span>
            <%if aut("atestadosA")=1 then%>
			<span class="tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Editar">
			<a class="green tooltip-info" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar modelos de encaminhamentos para futuras emiss&otilde;es" data-rel="tooltip" data-placement="top" title="" onclick="modalEncaminhamento('Encaminhamentos', <%=listaEncaminhamentos("id")%>)">
				<i class="fa fa-edit icon-edit bigger-125"></i>
			</a>
			</span>
			<%
			end if
            if aut("atestadosX")=1 then
			%>
			<span class="tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
			<a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaEncaminhamentos('Encaminhamento', <%=listaEncaminhamentos("id")%>)" class="red">
				<i class="fa fa-remove icon-remove bigger-125"></i>
			</a>
			</span>
			<%end if%>
		</div>
	</div>
    <%
    end if
    %>
	<tr id="<%=listaEncaminhamentos("id")%>">
        <td width="1%"><a href="javascript:aplicarEncaminhamento(<%=listaEncaminhamentos("id")%>);">
            <i class="fa fa-hand-o-left"></i>
            </a>
        </td>

    	<td id="NomeAtestado<%=listaEncaminhamentos("id")%>" style="word-break: break-word;"> <%=listaEncaminhamentos("NomeModelo")%></td>

        <td width="1%" nowrap>
        <%if aut("atestadosA")=1 then%>
		<a class="btn btn-xs btn-success tooltip-info" href="javascript:modalEncaminhamento('Encaminhamento','<%=listaEncaminhamentos("id") %>')">
			<i class="fa fa-edit icon-edit bigger-125"></i>
		</a>
		<%
		elseif (aut("atestadosA")=0 and aut("modelosprontuarioA")=1 and listaTextosAtestados("sysUser")=session("User")) then%>
		<a class="btn btn-xs btn-success tooltip-info" href="javascript:modalEncaminhamento('Encaminhamento','<%=listaEncaminhamentos("id") %>')">
			<i class="fa fa-edit icon-edit bigger-125"></i>
		</a>
		<%
        end if
        if aut("atestadosX")=1 then
        %>
		<a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaEncaminhamentos('Encaminhamento','<%=listaEncaminhamentos("id")%>')" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
			<i class="fa fa-remove icon-remove bigger-125"></i>
		</a>
        <%
        elseif (aut("atestadosX")=0 and aut("modelosprontuarioA")=1 and listaTextosAtestados("sysUser")=session("User")) then
        %>
		<a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaEncaminhamentos('Encaminhamento','<%=listaEncaminhamentos("id")%>')" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
			<i class="fa fa-remove icon-remove bigger-125"></i>
		</a>
        <%end if%>
        <a href="#" class="btn btn-xs tooltip-info btnfavoritos" title="Favoritos" data-tipo="A" data-id="<%=listaEncaminhamentos("id")%>" data-placement="top" data-rel="tooltip" data-original-title="Favoritos">
            <% if listaEncaminhamentos("TipoID")<>"99999999" then %>
                <i class="fa fa-star bigger-125" data-favorito="0"></i>
            <% else %>
                <i class="fa fa-star-o bigger-125" data-favorito="1"></i>
            <% end if %>
            </a>
        </td>
    </tr>
    <%
listaEncaminhamentos.movenext
wend
listaEncaminhamentos.close
set listaEncaminhamentos = nothing
    %>
	<script type="text/javascript">
    <%
if ref("Aplicar")="Encaminhamento-Last" then
	set getLast = db.execute("select id, sysUser, sysActive from encaminhamentostextos where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")
	%>
		aplicarEncaminhamento(<%=getLast("id")%>);
	<%
end if

%>

	</script>
<script src="favoritarprontuario.js"></script>