<!--#include file="connect.asp"-->
<%
SET dependenciaSQL = db.execute("SELECT * FROM tarefas_dependencias WHERE id = '"&req("depId")&"'")
if not dependenciaSQL.eof then
  tarDep_dependencia  = dependenciaSQL("dependencia")
  tarDep_responsaveis = dependenciaSQL("responsaveis")
  tarDep_prazo        = dependenciaSQL("prazo")
  tarDep_finalizada   = dependenciaSQL("finalizada")
  tarDep_descricao    = dependenciaSQL("descricao")
end if
%>
<div class="row">
  <div class="col-md-6">
    <%=quickField("text", "dependencia", "Dependência", "", tarDep_dependencia, "", "", "")%>
  </div>
  <div class="col-md-6">
    <%=quickfield("multiple", "dependenciaResponsaveis", "Atribuído ao(s) Usuário(s)", "", tarDep_responsaveis, "SELECT id,Nome FROM (SELECT su.id,prof.NomeProfissional Nome FROM profissionais prof INNER JOIN sys_users su ON su.idInTable=prof.id AND su.table='profissionais' WHERE prof.Ativo='on' AND prof.sysActive=1 UNION ALL SELECT su.id,func.NomeFuncionario Nome FROM funcionarios func INNER JOIN sys_users su ON su.idInTable=func.id AND su.table='funcionarios' WHERE func.Ativo='on' AND func.sysActive=1)t ORDER BY t.Nome", "Nome", "")%>
  </div>
</div>
<div class="row">
  
  <div class="col-md-6">
    <%=quickfield("datepicker", "dependenciaPrazo", "Prazo", 12, tarDep_prazo, "", "", "")%>
  </div>
  <div class="col-md-6">
    <%=quickfield("datepicker", "dependenciaConclusao", "Finalizado", 12, tarDep_finalizada, "", "", "")%>
  </div>
</div>
<div class="row">
  <div class="col-md-12" style="margin-top:10px">
    <%=quickField("editor", "dependenciaDescricao", "Descrição", 12, tarDep_descricao, "200", "", "")%>
  </div>
</div>

<script language="javascript">


	<!--#include file="jQueryFunctions.asp"-->

  </script>