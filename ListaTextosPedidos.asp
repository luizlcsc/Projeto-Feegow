<!--#include file="connect.asp"-->
<%
Filtro = ref("Filtro")

if ref("X")<>"" then
	if Filtro="TextoPedido" then
		db_execute("delete from pacientespedidostextos where id="&ref("X"))
	end if
	Filtro=""
end if

if Filtro="" then
    sql = "select id, NomePedido, 'Modelo' Tipo, 0 Ordem, IFNULL(TipoID, 99999999) as TipoID, 'ME' as TipoProcedimento, pp.sysUser from pacientesPedidostextos as pp left join prontuariosfavoritos as pf on pf.TipoID = pp.id and pf.Tipo = 'ME' and pf.sysUser = "&session("User")&" where sysActive=1 and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) UNION ALL (SELECT id,NomeProcedimento, 'Exame', 1, IFNULL(TipoID, 99999999) as TipoID, 'PE' as TipoProcedimento, pp.sysUser FROM procedimentos as pp left join prontuariosfavoritos as pf on pf.TipoID = pp.id and pf.Tipo = 'PE' and pf.sysUser = "&session("User")&" WHERE TipoProcedimentoID=3 And Ativo='on') order by TipoID, Ordem, NomePedido LIMIT 100"
	set listaTextosPedidos = db.execute(sql)
else
    sql = "select id, NomePedido,Tipo,Ordem,sysActive, IFNULL(TipoID, 99999999) as TipoID, TipoProcedimento, sysUser FROM (select id, NomePedido, 'Modelo' Tipo, 0 Ordem,sysActive, IFNULL(TipoID, 99999999) as TipoID, 'ME' as TipoProcedimento, pp.sysUser from pacientesPedidostextos as pp left join prontuariosfavoritos as pf on pf.TipoID = pp.id and pf.Tipo = 'ME' and pf.sysUser = "&session("User")&" where sysActive=1 and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) UNION ALL (SELECT id,NomeProcedimento, 'Exame', 1, sysActive, IFNULL(TipoID, 99999999) as TipoID, 'PE' as TipoProcedimento, pp.sysUser FROM procedimentos as pp left join prontuariosfavoritos as pf on pf.TipoID = pp.id and pf.Tipo = 'PE' and pf.sysUser = "&session("User")&" WHERE TipoProcedimentoID=3 And Ativo='on'))t WHERE NomePedido like '%"&Filtro&"%' and sysActive=1 order by TipoID, Ordem, NomePedido LIMIT 100"
	set listaTextosPedidos = db.execute(sql)
end if


if lcase(session("Table"))="profissionais" then
    sqlPacotes = "SELECT pp.* "&_
                 "FROM  pacotesprontuarios pp "&_
                 "LEFT JOIN (  "&_
                 "    select EspecialidadeID from profissionais   "&_
                 "    where id="&session("idInTable")&" and not isnull(EspecialidadeID)   "&_
                 "    union all "&_
                 "    select EspecialidadeID from profissionaisespecialidades "&_
                 "    where profissionalID="&session("idInTable")&" and not isnull(EspecialidadeID) "&_
                 ") esp ON pp.especialidades like CONCAT('%|', esp.EspecialidadeID, '|%') "&_
                 "WHERE (esp.EspecialidadeID IS NOT NULL OR pp.Especialidades='')  and (pp.Profissionais like '%|"&session("idInTable")&"|%' or pp.Profissionais = '' or pp.Profissionais is null) "&_
                 "AND pp.sysActive = 1  "&_
                 "AND pp.tipo = 'pedidoexame' "&_
                 "AND pp.Nome like '%"&Filtro&"%' "&_
                 "GROUP BY pp.id"
    set pacotes = db.execute(sqlPacotes)
    while not pacotes.EOF


        sqlItensPacotes = "SELECT * FROM  pacotesprontuariositens WHERE PacoteID = "&pacotes("id")
        set itemPacotes = db.execute(sqlItensPacotes)

    %>
            <tr class="pacote" id="Pacote<%=pacotes("id")%>">
            <td width="1%"><a href="javascript:void(0)"
              style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap;"
             onclick="
                <% while not itemPacotes.EOF %>
                    <% For i = 1 To (itemPacotes("Quantidade")) %>
                        aplicarTextoPedido(<%=itemPacotes("ItemID")%>,'Exame');
                    <% Next %>
                <%
                    itemPacotes.movenext
                    wend
                    itemPacotes.close
                %>
            ">
                    <i class="far fa-hand-o-left"></i>&nbsp;<i class="far fa-folder"></i>
                </a>
            </td>
            <td id="NomePedido<%=listaTextosPedidos("id")%>"> <code><%=listaTextosPedidos("Tipo")%></code> <%=pacotes("Nome")%></td>
            <td width="1%" nowrap>
            </td>
        </tr>
    <%
    pacotes.movenext
    wend

end if
%>



<% while not listaTextosPedidos.EOF %>
	<tr id="<%=listaTextosPedidos("id")%>">
        <td width="1%"><a href="javascript:aplicarTextoPedido(<%=listaTextosPedidos("id")%>,'<%=listaTextosPedidos("Tipo")%>');">
            <i class="far fa-hand-o-left"></i>
            </a>
        </td>

    	<td id="NomePedido<%=listaTextosPedidos("id")%>"> <code><%=listaTextosPedidos("Tipo")%></code> <%=listaTextosPedidos("NomePedido")%></td>

        <td width="1%" nowrap>
        <%
        if listaTextosPedidos("Tipo")="Modelo" then
            if aut("pedidosexamesA")=1 then%>
            <a class="btn btn-xs btn-success tooltip-info" href="javascript:modalTextoPedido('TextoPedido','<%=listaTextosPedidos("id") %>')">
                <i class="far fa-edit icon-edit bigger-125"></i>
            </a>
            <%
            elseif (aut("pedidosexamesA")=0 and aut("modelosprontuarioA")=1 and listaTextosPedidos("sysUser")=session("User")) then
            %>
            <a class="btn btn-xs btn-success tooltip-info" href="javascript:modalTextoPedido('TextoPedido','<%=listaTextosPedidos("id") %>')">
                <i class="far fa-edit icon-edit bigger-125"></i>
            </a>
            <%
            end if
            if aut("pedidosexamesX")=1 then%>
            <a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaTextosPedidos('TextoPedido','<%=listaTextosPedidos("id")%>')" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
                <i class="far fa-remove icon-remove bigger-125"></i>
            </a>
            <%
            elseif (aut("pedidosexamesX")=0 and aut("modelosprontuarioA")=1 and listaTextosPedidos("sysUser")=session("User")) then
            %>
            <a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaTextosPedidos('TextoPedido','<%=listaTextosPedidos("id")%>')" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
                <i class="far fa-remove icon-remove bigger-125"></i>
            </a>
            <%
		    end if
		end if
		%>
		<a href="#" class="btn btn-xs tooltip-info btnfavoritos" title="Favoritos" data-tipo="<%=ListaTextosPedidos("TipoProcedimento")%>" data-id="<%=ListaTextosPedidos("id")%>" data-placement="top" data-rel="tooltip" data-original-title="Favoritos">
        <% if ListaTextosPedidos("TipoID")<>"99999999" then %>
            <i class="far fa-star bigger-125" data-favorito="0"></i>
        <% else %>
            <i class="far fa-star-o bigger-125" data-favorito="1"></i>
        <% end if %>
        </a>
        </td>
    </tr>
    <%
listaTextosPedidos.movenext
wend
listaTextosPedidos.close
set listaTextosPedidos = nothing
    %>
	<script type="text/javascript">
    <%
if ref("Aplicar")="TextoPedido-Last" then
	set getLast = db.execute("select id, sysUser, sysActive from pacientesPedidostextos where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")
	%>
		aplicarTextoPedido(<%=getLast("id")%>);
	<%
end if


if session("sqlPedidos")<>"" then
sql = "SELECT id FROM pacientesPedidostextos WHERE 1=2 "&session("sqlPedidos")&" "
'response.write("alert("""& sql &""");")
t = 0
set meds = db.execute(sql)
while not meds.eof
t=t+1500
%>
setTimeout(function(){
    aplicarTextoPedido(<%=meds("id")%>);
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