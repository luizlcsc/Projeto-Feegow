<!--#include file="connect.asp"-->

<form id="Relatorio" name="Relatorio" method="get" action="">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="P" value="Relatorio" />
<input type="hidden" name="TipoRel" value="<%=req("TipoRel")%>" />
<input type="hidden" name="E" value="E" />
<div class="clearfix form-actions">
	<div class="col-md-4">Grau de Instru&ccedil;&atilde;o<br />
            <select name="grauinstrucao" class="form-control">
                <option value="0">Todos</option>
              <%
          set b=db.execute("select * from grauinstrucao")
          while not b.eof
          %>
              <option value="<%=b("id")%>"<%if req("grauinstrucao")=cStr(b("id")) then%> selected="selected"<%end if%>><%=b("grauinstrucao")%></option>
              <%
          b.movenext
          wend
          b.close
          set b=nothing
          %>
            </select>
    </div>
    <div class="col-md-2">&nbsp;<br />
        <button type="submit" class="btn btn-block btn-success" name="Gerar"><i class="far fa-list"></i> Gerar</button>
    </div>
</div>
<%
if req("E")="E" then
	if req("grauinstrucao")="0" then grauinstrucao="%" else grauinstrucao=req("grauinstrucao") end if
set esc=db.execute("select distinct grauinstrucao from pacientes where not grauinstrucao like '' and grauinstrucao like '"&grauinstrucao&"' order by grauinstrucao")
while not esc.eof
set pesc=db.execute("select * from grauinstrucao where id = '"&esc("grauinstrucao")&"'")
	if not pesc.eof then grauinstrucao=pesc("grauinstrucao") else grauinstrucao="N&atilde;o informada" end if
%>
<p align="center"><h2 align="center"><strong><%=grauinstrucao%></strong></h2></p>
		<table width="100%" class="table table-striped table-bordered">
        <thead>
		<tr><th width="42%">Nome</th>
		<th width="14%" nowrap="nowrap">Cidade</th>
		<th width="15%">E-mail</th>
		<th width="29%">Telefone</th>
		</tr>
        </thead>
        <tbody>
		<%
		c=0
		set p = db.Execute("Select * from pacientes where grauinstrucao like '"&esc("grauinstrucao")&"' order by NomePaciente")
		while  not p.eof
		c=c+1
		%>
		<tr onclick="location.href='?P=Pacientes&I=<%=p("id")%>&Pers=1';">
		<td><div align="left"><%=p("NomePaciente")%></div></td>
		<td><div align="left"><%=p("Cidade")%></div></td>
		<td><div align="left"><%=p("Email1")%></div></td>
		<td><div align="left"><%=p("Tel1")%></div></td>
		</tr>
		<%
		p.moveNext
		wend
		set p=nothing
		%>
        </tbody>
		</table>

	<br />
		<em><%=c%> paciente(s) encontrado(s).
	</em><br /><br />
	<%
esc.movenext
wend
esc.close
set esc=nothing

end if
%>
</form>