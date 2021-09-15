<!--#include file="connect.asp"-->

<form id="Relatorio" name="Relatorio" method="get" action="">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="P" value="Relatorio" />
<input type="hidden" name="TipoRel" value="<%=req("TipoRel")%>" />
<input type="hidden" name="E" value="E" />
<div class="clearfix form-actions">
  <div class="col-md-4"><label>Conv&ecirc;nio</label><br>
    <select name="ConvenioID" class="form-control" required>
        <option value="">Selecione</option>
        <%
    set b=db.execute("select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio")
    while not b.eof
    %>
        <option value="<%=b("id")%>"<%if req("ConvenioID")=cstr(b("id")) then%> selected="selected"<%end if%>><%=b("NomeConvenio")%></option>
        <%
    b.movenext
    wend
    b.close
    set b=nothing
    %>
	</select>
  </div>
  <div class="col-md-2">
  	<label>&nbsp;</label><br>
        <button type="submit" class="btn btn-block btn-success" name="Gerar"><i class="far fa-list"></i> Gerar</button>
  </div>
</div>
</form>

<form method="post" action="Etiquetas.asp" target="_blank">
<% if req("E")="E" then
 %><table width="100%" border="0" class="table table-striped table-bordered">
 <thead>
<tr bgcolor="#CCCCCC"><th>Nome</th><th>Sexo</th><th>Nascimento</th><th>Telefone</th><th>Celular</th><th>E-mail</th></tr>
</thead>
<tbody>
<%
c=0
set p = db.Execute("select pc.*, p.* from pacientesconvenios as pc inner join pacientes as p on pc.PacienteID=p.id where pc.ConvenioID="&req("ConvenioID")&" and not isnull(pc.PacienteID) order by p.NomePaciente")
while  not p.eof
c=c+1
		gerEt="S"
%><tr onClick="location.href='?P=Pacientes&I=<%=p("id")%>&Pers=1';">
<td><div align="left"><%=p("NomePaciente")%>
  <input type="hidden" name="Et" value="<%=p("id")%>" />
</div></td>
<td nowrap="nowrap"><div align="left"><%=getSexo(p("Sexo"))%></div></td>
<td><div align="left"><%=p("Nascimento")%></div></td>
<td><div align="left"><%=p("Tel1")%></div></td>
<td nowrap="nowrap"><div align="left"><%=p("Cel1")%></div></td>
<td><div align="left"><%=p("Email1")%></div></td>
</tr>
<%
p.moveNext
wend
set p=nothing
%>
</tbody>
</table>
<br />
<br />
<%=c%> paciente(s) encontrado(s).<br />
<% end if
 %>
 <!--#include file="gerEt.asp"-->
 </form>