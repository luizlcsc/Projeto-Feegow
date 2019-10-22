<label>Plano</label><br />
<select name="PlanoID" id="PlanoID" onchange="tissCompletaDados('Plano', this.value);" class="form-control">
    <option value="0">Selecione</option>
    <%
    set planos = db.execute("select * from conveniosplanos where ConvenioID like '"&ConvenioID&"' and sysActive=1 and NomePlano<>'' order by NomePlano")
    while not planos.eof
        %>
        <option value="<%=planos("id")%>"<%if PlanoID=planos("id") or PlanoID=cstr(planos("id")) then%> selected="selected"<%end if%>><%=planos("NomePlano")%></option>
        <%
    planos.movenext
    wend
    planos.close
    set planos=nothing
    %>
</select>