<!--#include file="connect.asp"-->
<%
Filtro = ref("Filtro")
ConvenioID = ref("ConvenioID")
Grupo = ""

if instr(Filtro,"Grupo: ") then
    FiltroSplt = split(Filtro, "Grupo: ")

    Filtro = FiltroSplt(0)
    Grupo=FiltroSplt(1)

    sqlFiltro = " pg.NomeGrupo LIKE '"&Grupo&"%'"
    sqlFitro2 = ""

else
    sqlFiltro="cp.codigo like '%"&Filtro&"%' or cp.descricao like '%"&Filtro&"%' "
    sqlFitro2 = " AND tpt.Codigo like '%"&Filtro&"%' or tpt.Descricao like '%"&Filtro&"%' or proc.NomeProcedimento like '%"&Filtro&"%' "
end if


if Filtro="" and Grupo="" then
	set listaTextosPedidos = db.execute("select * from cliniccentral.procedimentos   where 0  limit 100")
else
    sql = "select cp.id as id, cp.descricao as descricao, cp.codigo as codigo,  p.GrupoID as GrupoID, IFNULL(TipoID, 99999999) as TipoID, 'PS' as TipoProcedimento  from cliniccentral.procedimentos cp "&_
          "LEFT JOIN prontuariosfavoritos as pf on pf.TipoID = cp.id and pf.Tipo = 'PS' and pf.sysUser = "&session("User")&" "&_
          "LEFT JOIN tissprocedimentostabela t ON (t.Codigo=cp.codigo AND t.TabelaID=22 AND t.sysActive=1) LEFT JOIN tissprocedimentosvalores pv ON pv.ProcedimentoTabelaID=t.id "&_
          "LEFT JOIN procedimentos p ON p.id=pv.ProcedimentoID LEFT JOIN procedimentosgrupos pg ON pg.id=p.GrupoID where ("&sqlFiltro&" ) and cp.tipoTabela='22' "

    if ConvenioID > 0 then
    sql = sql & " UNION ALL " &_
                    " SELECT tpv.ProcedimentoTabelaID as id, IFNULL(tpt.Descricao, proc.NomeProcedimento) as descricao, tpt.Codigo as codigo, 0 as GrupoID, IFNULL(TipoID, 99999999) as TipoID, 'PST' as TipoProcedimento "&_
                    " FROM tissprocedimentosvalores tpv "&_
                    " LEFT JOIN prontuariosfavoritos as pf on pf.TipoID = tpv.id and pf.Tipo = 'PST' and pf.sysUser = "&session("User")&" "&_
                    " INNER JOIN tissprocedimentostabela tpt ON (tpt.id=tpv.ProcedimentoTabelaID AND (tpt.TabelaID=22 OR tpt.TabelaID=99 OR tpt.TabelaID=101) AND tpt.sysActive=1)"&_
                    " INNER JOIN procedimentos proc ON proc.id=tpv.ProcedimentoID "&_
                    " WHERE tpv.ConvenioID=" & ConvenioID & " AND tpt.sysActive=1 AND proc.sysActive=1 " & sqlFitro2
    end if

    sql = sql & " order by descricao limit 100 "


    set listaTextosPedidos = db.execute(sql)
end if

especialidade = ""
espec = 0
ProfissionalID = 0
if lcase(session("Table"))="profissionais" then
    set profEsp = db.execute("select EspecialidadeID from profissionais where id="&session("idInTable"))
    if not profEsp.eof then
        especialidade = profEsp("EspecialidadeID")
        if especialidade&""="" or especialidade=0 then
            espec = 1
        end if
    end if
    ProfissionalID = session("idInTable")
end if

sqlQuery = "select id, Nome, IFNULL(TipoID, 99999999) as TipoID, 'PT' as TipoProcedimento, '' codigo, '' descricao from pacotesprontuarios as p left join prontuariosfavoritos as pf on pf.TipoID = p.id and pf.Tipo = 'PT' and pf.sysUser = "&session("User")&" "&_
           "where Nome like '%"& Filtro &"%' and p.tipo='pedidosadt' and (p.especialidades like '%|"&especialidade&"|%' or p.especialidades = '' or 1 = "&espec&") and (p.Profissionais like '%|"&ProfissionalID&"|%' or p.Profissionais = '' or p.Profissionais is null) "&_
           "union all "&_
           "select  id, concat(codigo, ' - ', descricao) Nome, IFNULL(TipoID, 99999999) as TipoID, 'PS' as TipoProcedimento, codigo, descricao from prontuariosfavoritos fav left join cliniccentral.procedimentos cproc ON cproc.id=fav.TipoID WHERE concat(codigo, ' - ', descricao) like '%"& Filtro &"%' and fav.Tipo='PS' and fav.sysUser = "&session("User")&" "&_
           "union all "&_
           "select  id, concat(codigo, ' - ', descricao) Nome, IFNULL(TipoID, 99999999) as TipoID, 'PST' as TipoProcedimento, codigo, descricao from prontuariosfavoritos fav left join tissprocedimentostabela tpt ON tpt.id=fav.TipoID WHERE concat(codigo, ' - ', descricao) like '%"& Filtro &"%' and fav.Tipo='PST' and fav.sysUser = "&session("User")&" "&_
           "order by TipoProcedimento desc, descricao, TipoID, Nome  "
set pp = db.execute(sqlQuery)


while not pp.eof
    aplicacoes = ""
    if pp("TipoProcedimento")="PT" then
        set pi = db.execute("select * from pacotesprontuariositens where PacoteID="& pp("id"))
        while not pi.eof
            aplicacoes = aplicacoes & "aplicarPedidoSADT('"& pi("ItemID") &"', 22, '');"
        pi.movenext
        wend
        pi.close
        set pi = nothing
    elseif pp("TipoProcedimento")="PS" or pp("TipoProcedimento")="PST" then
        descricao = replace(pp("descricao"), """", "")
        aplicacoes = "aplicarPedidoSADT('"& pp("codigo") &"', 22, '"&descricao&"');"
    end if

    %>
	<tr id="">
        <td width="1%" nowrap>
            <a onclick="<%= aplicacoes %>" href="javascript:void(0);">
                <i class="far fa-hand-o-left"></i>
            </a>
            <%if pp("TipoProcedimento")="PT" then%>
            <a href="javascript:aplicarPedidoSADT('', 22, '');">
                <i class="far fa-folder"></i>
            </a>
            <%end if%>

        </td>

    	<td class="text-left">
    	    <b>
            <%= pp("Nome") %>
            </b>
        </td>

        <td>
            <a href="#" class="btn btn-xs tooltip-info btnfavoritos" title="Favoritos" data-tipo="<%=pp("TipoProcedimento")%>" data-id="<%=pp("id")%>" data-placement="top" data-rel="tooltip" data-original-title="Favoritos">
            <% if pp("TipoID")<>"99999999" then %>
                <i class="fas fa-star bigger-125" data-favorito="0"></i>
            <% else %>
                <i class="far fa-star bigger-125" data-favorito="1"></i>
            <% end if %>
            </a>
        </td>

    </tr>
    <%
pp.movenext
wend
pp.close
set pp = nothing

while not listaTextosPedidos.EOF
    listaDescricoes = replace(listaTextosPedidos("descricao")&"", """", "")
    %>
	<tr id="<%=listaTextosPedidos("id")%>">
        <td width="1%"><a href="javascript:aplicarPedidoSADT('<%=listaTextosPedidos("codigo")%>', 22, '<%=listaDescricoes%>');">
            <i class="far fa-hand-o-left"></i>
            </a>
        </td>

    	<td class="text-left"> <b><%=listaTextosPedidos("codigo") &":</b> "& listaTextosPedidos("descricao")%></td>

        <td>
            <a href="#" class="btn btn-xs tooltip-info btnfavoritos" title="Favoritos" data-tipo="<%=listaTextosPedidos("TipoProcedimento")%>" data-id="<%=listaTextosPedidos("id")%>" data-placement="top" data-rel="tooltip" data-original-title="Favoritos">
            <% if listaTextosPedidos("TipoID")<>"99999999" then %>
                <i class="fas fa-star bigger-125" data-favorito="0"></i>
            <% else %>
                <i class="far fa-star bigger-125" data-favorito="1"></i>
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


        function aplicarPedidoSADT(Codigo, Tabela, Descricao) {
            $.post("PedidoSADT.asp?i=" + $("#PedidoSADTID").val() +"&p="+ $("#PacienteID").val(), {
                Codigo: Codigo,
                Tabela: Tabela,
                Descricao :Descricao
                }, function (data) {
                $("#PedidoSADT").html(data);
            });
        }

	</script>
<script src="favoritarprontuario.js"></script>