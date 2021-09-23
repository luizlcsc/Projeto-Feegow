<!--#include file="connect.asp"-->
<%
if req("X")<>"" then
	db_execute("delete from profissionaiscirurgia where id="&req("X"))
end if
%>
<table width="100%" class="table table-striped table-bordered table-condensed table-hover">
  <thead>
    <tr>
      <th width="20" align="center" nowrap> </th>
      <th width="50" align="center" nowrap>Seq. Ref.</th>
      <th width="70" align="center" nowrap>Grau Part.</th>
      <th align="center" nowrap>Nome do Profissional</th>
      <th width="140" align="center" nowrap>Cod. na Operadora/CPF</th>
      <th width="60" align="center" nowrap>Conselho</th>
      <th width="95" align="center" nowrap>Nº no Conselho</th>
      <th width="30" align="center" nowrap>UF</th>
      <th width="75" align="center" nowrap>Código CBO</th>
      <th width="30" align="center" nowrap><button type="button" class="btn btn-info btn-xs" onClick="itemCirurgia('Profissionais', <%=req("I")%>, 0);"><i class="far fa-plus"></i></button></th>
    </tr>
  </thead>
  <tbody>
  <%
  set p = db.execute("select * from profissionaiscirurgia where GuiaID="&req("I"))
  while not p.eof
  	set pro = db.execute("select p.NomeProfissional, cons.TISS as ConselhoTISS from profissionais as p left join conselhosprofissionais as cons on cons.id=p.Conselho where p.id="&p("ProfissionalID"))
	if pro.eof then
		NomeProfissional = "<em>Profissional exclu&iacute;do</em>"
		ConselhoTISS = "-"
	else
		NomeProfissional = pro("NomeProfissional")
		ConselhoTISS = pro("ConselhoTISS")
	end if
  %>
    <tr id="lProfissionais<%=p("id") %>">
      <td align="center"><button type="button" class="btn btn-xs btn-success" onClick="itemCirurgia('Profissionais', <%=req("I")%>, <%=p("id")%>);"><i class="far fa-edit"></i></button></td>
      <td align="center"><%=p("Sequencial")%></td>
      <td align="center"><%=right(p("GrauParticipacaoID"),2)%></td>
      <td align="left"><%=NomeProfissional%></td>
      <td align="center"><%=p("CodigoNaOperadoraOuCPF")%></td>
      <td align="center"><%=ConselhoTISS%></td>
      <td align="center"><%=p("DocumentoConselho")%></td>
      <td align="center"><%=p("UFConselho")%></td>
      <td align="center"><%=p("CodigoCBO")%></td>
      <td align="center"><button type="button" class="btn btn-xs btn-danger" onClick="atualizaTabela('profissionaiscirurgia', 'profissionaiscirurgia.asp?I=<%=req("I")%>&X=<%=p("id")%>')"><i class="far fa-remove"></i></button></td>
    </tr>
    <tr>
        <td colspan="10" class="hidden" id="Profissionais<%=p("id") %>"></td>
    </tr>
  <%
  p.movenext
  wend
  p.close
  set p=nothing
  %>
  <tr>
      <td id="Profissionais0" colspan="10"></td>
  </tr>
  </tbody>
</table>
