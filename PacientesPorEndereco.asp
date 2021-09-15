<!--#include file="connect.asp"-->

<form id="Relatorio" name="Relatorio" method="get" action="">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="P" value="Relatorio" />
<input type="hidden" name="TipoRel" value="<%=req("TipoRel")%>" />
<input type="hidden" name="E" value="E" />
<div class="clearfix form-actions">
  <div class="col-md-4"><label>Endere&ccedil;o</label><br>
  	<input type="text" class="form-control" size="50" maxlength="20" value="<%=req("Endereco")%>" name="Endereco" />
  </div>
  <div class="col-md-3"><label>Bairro</label><br>
    <select name="Bairro" class="form-control">
        <option value="">Indiferente</option>
        <%
    set b=db.execute("select distinct Bairro from pacientes where Bairro<>'' order by Bairro")
    while not b.eof
    %>
        <option value="<%=b("Bairro")%>"<%if req("Bairro")=b("Bairro") then%> selected="selected"<%end if%>><%=b("Bairro")%></option>
        <%
    b.movenext
    wend
    b.close
    set b=nothing
    %>
	</select>
  </div>
  <div class="col-md-3"><label>Cidade</label><br>
  	<select name="Cidade" class="form-control">
    <option value="">Indiferente</option>
          <%
	  set b=db.execute("select distinct Cidade from pacientes where Cidade<>'' order by Cidade")
	  while not b.eof
	  %>
          <option value="<%=b("Cidade")%>"<%if req("Cidade")=b("Cidade") then%> selected="selected"<%end if%>><%=b("Cidade")%></option>
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
<tr bgcolor="#CCCCCC"><th>Nome</th><th>Sexo</th><th>Endere&ccedil;o</th><th>Bairro</th><th>Cidade</th></tr>
</thead>
<tbody>
<%
c=0
set p = db.Execute("Select * from pacientes where sysActive=1 and Endereco like '%"&req("Endereco")&"%' and Bairro like '%"&req("Bairro")&"%' and Cidade like '%"&req("Cidade")&"%' order by NomePaciente")
while  not p.eof
c=c+1
		gerEt="S"
%><tr onClick="location.href='?P=Pacientes&I=<%=p("id")%>&Pers=1';">
<td><div align="left"><%=p("NomePaciente")%>
  <input type="hidden" name="Et" value="<%=p("id")%>" />
</div></td>
<td><div align="left"><%=getSexo(p("Sexo"))%></div></td>
<td><div align="left"><%=p("Endereco")%></div></td>
<td><div align="left"><%=p("Bairro")%></div></td>
<td><div align="left"><%=p("Cidade")%></div></td>
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