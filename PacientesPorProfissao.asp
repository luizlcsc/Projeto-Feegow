<!--#include file="connect.asp"-->

<h4>Pacientes por Previs&atilde;o de Retorno</h4>
<form id="Relatorio" name="Relatorio" method="get" action="">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="P" value="<%=req("TipoRel")%>" />
<input type="hidden" name="TipoRel" value="<%=req("TipoRel")%>" />
<input type="hidden" name="E" value="E" />
<div class="clearfix form-actions">
  <table class="table table-bordered table-striped" width="100%" border="0">
    <tr>
      <td width="20%"><div align="left">Profiss&atilde;o</div></td>
      <td width="80%"><div align="left">
        <select name="Profissao">
            <option value="">Nenhuma</option>
          <%
	  set b=db.execute("select distinct Profissao from pacientes where Profissao<>'' order by Profissao")
	  while not b.eof
	  %>
          <option value="<%=b("Profissao")%>"<%if req("Profissao")=b("Profissao") then%> selected="selected"<%end if%>><%=b("Profissao")%></option>
          <%
	  b.movenext
	  wend
	  b.close
	  set b=nothing
	  %>
        </select>
      </div></td>
    </tr>
    <tr>
      <td><div align="left"></div></td>
      <td><div align="left">
        <button class="btn btn-success btn-sm" type="submit" name="Gerar"><i class="far fa-list"></i> Listar</button>
      </div></td>
    </tr>
  </table>
  <br />
<br />
</div>
</form>

<form method="post" action="Etiquetas.asp" target="_blank">
<% if req("E")="E" then
 %><table class="table table-bordered table-striped" width="100%" border="0">
<tr><th>Nome</th><th>Sexo</th><th>Profiss&atilde;o</th><th>Bairro</th><th>Cidade</th></tr>
<%
c=0
set p = db.Execute("Select id, NomePaciente, Sexo, Profissao, Bairro, Cidade, sysActive from pacientes where sysActive=1 and Profissao like '"&req("Profissao")&"' order by NomePaciente")
while  not p.eof
c=c+1
		gerEt="S"
%><tr onClick="location.href='./?P=Pacientes&Pers=1&I=<%=p("id")%>';">
<td><div align="left"><%=p("NomePaciente")%>
  <input type="hidden" name="Et" value="<%=p("id")%>" />
</div></td>
<td><div align="left"><%=getSexo(p("Sexo"))%></div></td>
<td><div align="left"><%=p("Profissao")%></div></td>
<td><div align="left"><%=p("Bairro")%></div></td>
<td><div align="left"><%=p("Cidade")%></div></td>
</tr>
<%
p.moveNext
wend
set p=nothing
%>
</table>
<br />
<br />
<%=c%> paciente(s) encontrado(s).<br />
<% end if
 %>
 <!--#include file="gerEt.asp"-->
 </form>