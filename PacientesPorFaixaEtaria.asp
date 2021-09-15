<%
if isnumeric(req("De")) and not req("De")="" then
	De=req("De")
else
	De=1
end if
if isnumeric(req("A")) and not req("A")="" then
	A=req("A")
else
	A=30
end if
%>
<!--#include file="connect.asp"-->

<form id="Relatorio" name="Relatorio" method="get" action="">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="P" value="Relatorio" />
<input type="hidden" name="TipoRel" value="<%=req("TipoRel")%>" />
<input type="hidden" name="E" value="E" />
<div class="clearfix form-actions">
        <div class="col-md-2">De<br />
            <input name="De" type="text" id="De" value="<%=De%>" class="form-control" size="3" maxlength="3" />
          </div>
          <div class="col-md-2">
          &nbsp;<br />
            <select name="tipoDe" class="form-control">
              <option value="yyyy"<%if req("tipoDe")="yyyy" then%> selected="selected"<%end if%>>Anos</option>
              <option value="m"<%if req("tipoDe")="m" then%> selected="selected"<%end if%>>Meses</option>
              <option value="d"<%if req("tipoDe")="d" then%> selected="selected"<%end if%>>Dias</option>
            </select>
          </div>
          <div class="col-md-1">
          </div>
          <div class="col-md-2">A<br />
              <input name="A" type="text" id="A" value="<%=A%>" size="3" class="form-control" maxlength="3" />
           </div>
           <div class="col-md-2">&nbsp;<br />
              <select name="tipoA" id="tipoA" class="form-control">
                <option value="yyyy"<%if req("tipoA")="yyyy" then%> selected="selected"<%end if%>>Anos</option>
                <option value="m"<%if req("tipoA")="m" then%> selected="selected"<%end if%>>Meses</option>
                <option value="d"<%if req("tipoA")="d" then%> selected="selected"<%end if%>>Dias</option>
              </select>
           </div>
           <div class="col-md-2">&nbsp;<br />
	        <button type="submit" class="btn btn-block btn-success" name="Gerar"><i class="far fa-list"></i> Gerar</button>
          </div></td>
        </tr>
      </table>
    </div>
</div>
<%
if req("E")="E" then
	diasDe=dateAdd(req("tipoDe"),-De,date())
	diasDe=dateDiff("d",diasDe,date())
	diasA=dateAdd(req("tipoA"),-A,date())
	diasA=dateDiff("d",diasA,date())
%>
<table width="100%" class="table table-striped table-bordered">
<thead>
<tr>
	<th>Nome</th>
	<th>Sexo</th><th>Nascimento</th><th>Bairro</th><th>Cidade</th>
</tr>
</thead>
<tbody>
<%
c=0
set p = db.Execute("Select * from pacientes where sysActive=1 and not isnull(Nascimento) order by Nascimento desc")
while not p.eof
	tempoVida=dateDiff("d", p("Nascimento"), date())
	if tempoVida>=diasDe and tempoVida<=diasA then
	c=c+1
%><tr onclick="location.href='?PPacientes&Pers=1&I=<%=p("id")%>';">
<td><div align="left"><%=p("NomePaciente")%></div></td>
<td><div align="left"><%=getSexo(p("Sexo"))%></div></td>
<td><div align="left"><%=p("Nascimento")%></div></td>
<td><div align="left"><%=p("Bairro")%></div></td>
<td><div align="left"><%=p("Cidade")%></div></td>
</tr>
<%
	end if
p.moveNext
wend
set p=nothing
%>
</tbody>
</table>
<br />
<br />
<%=c%> paciente(s) encontrado(s).<% end if
 %></form>