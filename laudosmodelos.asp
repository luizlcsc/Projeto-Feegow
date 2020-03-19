<!--#include file="connect.asp"-->
<%
call insertRedir(request.QueryString("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
Procedimentos = reg("Procedimentos")
Profissionais = reg("Profissionais")
PapelTimbradoID = reg("PapelTimbradoID")
Unidades = reg("UnidadeID")
%>
<br>
<div class="panel">
<div class="panel-body">
<form method="post" id="frm" name="frm" action="save.asp">
	<input type="hidden" name="I" value="<%=req("I")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />
	<%=header(req("P"), "Modelo de Laudos", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
<div class="row">
    <div class="col-md-12">
        <div class="row">
	        <%=quickField("text", "NomeModelo", "Nome do Modelo", 4, reg("NomeModelo"), "", "", " required")%>
            <%=quickField("simpleSelect", "PapelTimbradoID", "Papel Timbrado", 2, PapelTimbradoID, "select id, NomeModelo from papeltimbrado where sysActive=1 order by NomeModelo", "NomeModelo", "") %>
            <%=quickfield("multiple", "Procedimentos", "Procedimentos", 2, Procedimentos, "select 'Todos' NomeProcedimento, 'ALL' id UNION ALL select NomeProcedimento, id FROM procedimentos WHERE Ativo='on' and Laudo=1 and sysActive=1" , "NomeProcedimento", "") %>
            <%=quickfield("multiple", "Profissionais", "Profissionais", 2, Profissionais, "select 'Todos' NomeProfissional, 'ALL' id UNION ALL select NomeProfissional, id FROM profissionais WHERE Ativo='on' and sysActive=1" , "NomeProfissional", "") %>
            <%=quickField("multiple", "UnidadeID", "Unidades", 2, Unidades, "select 'ALL' id, ' Todos' NomeFantasia UNION ALL select 0, NomeFantasia from empresa where sysActive=1 UNION ALL select id, NomeFantasia from sys_financialcompanyunits where sysActive=1 order by NomeFantasia", "NomeFantasia", "")%>

        </div>
        <br />
       <div class="col-md-9">
           <div class="row">
               <br/>
               <%= quickfield("editor", "Cabecalho", "Cabeçalho", 12, reg("Cabecalho"), "200", "", "") %>
               <div class="row">
                   <div class="col-md-6 pull-right">
                       <%=macro("Cabecalho")%>
                   </div>
               </div>
               <%= quickfield("editor", "Rodape", "Rodapé", 12, reg("Rodape"), "200", "", "") %>
               <div class="row">
                   <div class="col-md-6 pull-right">
                       <%=macro("Rodape")%>
                   </div>
               </div>
            </div>
        </div>
        <br/>
        <br/>
        <div class="col-md-3">
            <!--#include file="Tags.asp"-->
        </div>
    </div>
</div>
<br />
<br />
<br />
<br />
<br />
<br />
</form>

</div>
</div>

<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});
</script>
<!--#include file="disconnect.asp"-->