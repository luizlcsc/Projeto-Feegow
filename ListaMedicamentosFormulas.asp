<!--#include file="connect.asp"-->
<%
Filtro = req("Filtro")

if ref("X")<>"" then
	if req("Filtro")="M" then
'		response.Write("delete from PacientesMedicamentos where id="&ref("X"))
		db_execute("delete from PacientesMedicamentos where id="&ref("X"))
	else
		db_execute("delete from PacientesFormulas where id="&ref("X"))
	end if
	Filtro=""
end if

limite = 200
c = 0
TipoMedicamento = req("TipoMedicamento")
if TipoMedicamento<>"" then
    sqlTipoMedicamento = " WHERE Tipo = '"&TipoMedicamento&"'"
end if
if instr(Filtro, "Grupo:")=0 then
    set listaFormulas = db.execute("select id, Nome, Quantidade, Tipo, Observacoes, TipoID, sysUser, Uso FROM ( select id, Nome, Quantidade, 'F' as Tipo, Observacoes, IFNULL(TipoID, 99999999) as TipoID, pa.sysUser, pa.Uso from PacientesFormulas as pa left join prontuariosfavoritos as pf on pf.TipoID = pa.id and pf.Tipo = 'F' and pf.sysUser = "&session("User")&" where Nome like '%"&Filtro&"%' and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) and sysActive=1  "&_
        " UNION ALL "&_
        " select id, Medicamento as 'Nome', Apresentacao as 'Quantidade', 'M' as 'Tipo', Observacoes, IFNULL(TipoID, 99999999) as TipoID, pm.sysUser, pm.Uso from PacientesMedicamentos as pm left join prontuariosfavoritos as pf on pf.TipoID = pm.id and pf.Tipo = 'M' and pf.sysUser = "&session("User")&" where Medicamento like '%"&Filtro&"%' and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) and sysActive=1)t   "&_
        " "&sqlTipoMedicamento&" order by TipoID, Nome limit "&limite)
else
    Grupo = trim(replace(Filtro, "Grupo:", ""))
    set listaFormulas = db.execute("select id, Nome, Quantidade, 'F' as Tipo, Observacoes, IFNULL(TipoID, 99999999) as TipoID, pa.sysUser, '' Uso from PacientesFormulas as pa left join prontuariosfavoritos as pf on pf.TipoID = pa.id and pf.Tipo = 'F' and pf.sysUser = "&session("User")&" where Grupo like '"&Grupo&"' and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) and sysActive=1 "&_
    " UNION ALL "&_ 
    " select id, Medicamento, Apresentacao, 'M', Observacoes, IFNULL(TipoID, 99999999) as TipoID, pm.sysUser, '' Uso from PacientesMedicamentos as pm left join prontuariosfavoritos as pf on pf.TipoID = pm.id and pf.Tipo = 'M' and pf.sysUser = "&session("User")&"  where Grupo like '"&Grupo&"' and (profissionais is null or profissionais='' or profissionais like '%|"&session("idInTable")&"|%' or "&session("Admin")&"=1) and sysActive=1 "&_
    " order by TipoID, Nome limit "&limite)
end if
while not listaFormulas.EOF
	c = c+1
	%>
	<tr id="<%=listaFormulas("id")%>" data-tipo="<%=listaFormulas("Tipo")%>">
	<td >
        <div class="row">
            <div class="col-md-1"><a href="javascript:aplicarFormula(<%=listaFormulas("id")%>, '<%=listaFormulas("Tipo")%>', '<%=listaFormulas("Uso") %>');">
                <i class="far fa-hand-o-left"></i>
                </a>
            </div>

            <div class="col-md-7" ><code style="float: left;"><%=listaFormulas("Tipo") %></code> <div  data-toggle="tooltip" title="<%=listaFormulas("Observacoes")%>" style="font-size: 12px; line-height: normal; font-weight: normal"><%=listaFormulas("Nome")%></div> </div>

            <div class="col-md-4" >
            <%if aut("prescricoesA")=1 then%>

            <a class="btn btn-xs btn-success tooltip-info" href="javascript:modalMedicamento('<%=listaFormulas("Tipo") %>', '<%=listaFormulas("id") %>')">
                <i class="far fa-edit icon-edit bigger-125"></i>
            </a>
            <%
            elseif (aut("prescricoesA")=0 and aut("modelosprontuarioA")=1 and listaFormulas("sysUser")=session("User")) then
            %>
            <a class="btn btn-xs btn-success tooltip-info" href="javascript:modalMedicamento('<%=listaFormulas("Tipo") %>', '<%=listaFormulas("id") %>')">
                <i class="far fa-edit icon-edit bigger-125"></i>
            </a>
            <%
            end if

            if aut("prescricoesX")=1 then
            %>
            <a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaMedicamentosFormulas('<%=listaFormulas("Tipo") %>', <%=listaFormulas("id")%>)" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
                <i class="far fa-remove icon-remove bigger-125"></i>
            </a>
            <%elseif (aut("prescricoesX")=0 and aut("modelosprontuarioA")=1 and listaFormulas("sysUser")=session("User")) then
            %>
            <a href="javascript:if(confirm('Tem certeza de que deseja excluir este modelo?'))ListaMedicamentosFormulas('<%=listaFormulas("Tipo") %>', <%=listaFormulas("id")%>)" class="btn btn-xs btn-danger tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Excluir">
                <i class="far fa-remove icon-remove bigger-125"></i>
            </a>
            <%end if%>

            <a href="#" class="btn btn-xs tooltip-info btnfavoritos" title="Favoritos" data-tipo="<%=listaFormulas("Tipo")%>" data-id="<%=listaFormulas("id")%>" data-placement="top" data-rel="tooltip" data-original-title="Favoritos">
            <% if listaFormulas("TipoID")<>"99999999" then %>
                <i class="far fa-star bigger-125" data-favorito="0"></i>
            <% else %>
                <i class="far fa-star-o bigger-125" data-favorito="1"></i>
            <% end if %>
            </a>
            </div>
        </div>
    </td>
    </tr>
<%
listaFormulas.movenext
wend
listaFormulas.close
set listaFormulas = nothing

if c=limite then
	%>
	<tr><td colspan="3" class="red">Exibindo somente os 200 primeiros. <br>Para visualizar mais, busque acima.</td></tr>
	<%
end if
%>

<script type="text/javascript">
    <%
    if ref("Aplicar")="Medicamento-Last" then
	    set getLast = db.execute("select id, sysUser, sysActive from PacientesMedicamentos where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")
	    %>
	    aplicarFormula(<%=getLast("id")%>, 'M');
	    <%
    end if
    if ref("Aplicar")="Formula-Last" then
	    set getLast = db.execute("select id, sysUser, sysActive from PacientesFormulas where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")
	    %>
		    aplicarFormula(<%=getLast("id")%>, 'F');
	    <%
    end if
    if session("sqlMedicamentos")<>"" then
        sql = "SELECT id FROM pacientesmedicamentos  WHERE 1=2 "&session("sqlMedicamentos")&" "
        'response.write("alert("""& sql &""");")
        t = 0
        set meds = db.execute(sql)
        while not meds.eof
            t=t+1500
            %>
            setTimeout(function(){
                aplicarFormula(<%=meds("id")%>, 'M');;
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