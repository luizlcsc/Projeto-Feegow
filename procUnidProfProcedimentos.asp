<!--#include file="connect.asp"-->
<%
id_profissional = request.form("id_profissional")
id_unidade = request.form("id_unidade")
grupoid = request.form("grupoid")

sql = " SELECT id, "&_
        " NomeProcedimento "&_
        " FROM procedimentos p "&_
        " WHERE p.GrupoID not in (select id from procedimentosgrupos pg where pg.sysActive = 1 and (pg.NomeGrupo like '%Laboratório%')) "&_
        " AND sysActive=1 "&_
        " AND Ativo='on' " &_ 
        " AND p.GrupoID = "&grupoid&_
        " AND p.id NOT IN (SELECT id_procedimento FROM procedimento_profissional_unidade WHERE id_profissional = "&id_profissional&" AND id_unidade = "&id_unidade&")"&_
        " order by NomeProcedimento "

set resSql = db.execute(sql)

%>
<div class="col-md-12">
<table class="table table-hover table-bordered">
  <thead>
    <tr class="system">
      <th colspan="100%">Procedimentos</th>
    </tr>
  </thead>
  <tbody>
<%
    while not resSql.eof
%>
        <tr class="success">
        <td width="95%"><%=resSql("NomeProcedimento")%></td>
        <td style="text-align:center">
            <button type="button" class="btn btn-xs btn-success dark" onclick="persistProcedimento('I',$('#id_unidade').val(),<%=resSql("id")%>)">
                <i class="fa fa-plus"></i>
            </button>
        </td>
        </tr>
<%
        resSql.movenext
    wend

    resSql.close
    set resSql = nothing
%>
  </tbody>
</table>
</div>