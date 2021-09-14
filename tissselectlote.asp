<!--#include file="connect.asp"-->
<label>Situa&ccedil;&atilde;o</label><br />
<select name="LoteID" class="form-control select2-single">
    <option value="">Todas as Guias</option>
    <option value="0"<%if req("LoteID")="0" then%> selected<%end if%>>Guias Fora de Lote</option>
    <option value="-1"<%if req("LoteID")="-1" then%> selected<%end if%>>Guias não pagas</option>
    <%
	if req("ConvenioID")<>"" and req("T")<>"" then
		if req("T")="GuiaConsulta" or req("T")="guiaconsulta"then
			sql = "select distinct g.LoteID, l.Lote from tissguiaconsulta g left join tisslotes l on l.id=g.LoteID where g.ConvenioID="&req("ConvenioID")&" and g.LoteID<>0 and g.sysActive=1 order by l.Lote desc"
		elseif req("T")="GuiaSADT" or req("T")="guiasadt"then
			sql = "select distinct g.LoteID, l.Lote from tissguiasadt g left join tisslotes l on l.id=g.LoteID where g.ConvenioID="&req("ConvenioID")&" and g.LoteID<>0 and g.sysActive=1 order by l.Lote desc"
		elseif req("T")="GuiaHonorarios" or req("T")="guiahonorarios" then
			sql = "select distinct g.LoteID, l.Lote from tissguiahonorarios g left join tisslotes l on l.id=g.LoteID where g.ConvenioID="&req("ConvenioID")&" and g.LoteID<>0 and g.sysActive=1 order by l.Lote desc"
		elseif req("T")="GuiaInternacao" or req("T")="guiainternacao" then
            sql = "select distinct g.LoteID, l.Lote from tissguiainternacao g left join tisslotes l on l.id=g.LoteID where g.ConvenioID="&req("ConvenioID")&" and g.LoteID<>0 and g.sysActive=1 order by l.Lote desc"
        elseif req("T")="GuiaQuimioterapia" or req("T")="guiaquimioterapia" then
            sql = "select distinct g.LoteID, l.Lote from tissguiainternacao g left join tisslotes l on l.id=g.LoteID where g.ConvenioID="&req("ConvenioID")&" and g.LoteID<>0 and g.sysActive=1 order by l.Lote desc"
        end if

		set lotes = db.execute(sql)
		while not lotes.eof%>
        	<option value="<%=lotes("LoteID")%>"<%if cstr(lotes("LoteID"))=req("LoteID") then%> selected<%end if%>>Lote <%=lotes("Lote")%></option>
			<%
		lotes.movenext
		wend
		lotes.close
		set lotes=nothing
	end if
	%>
</select>
<script type="text/javascript">
    <!--#include file="jQueryFunctions.asp"-->
</script>