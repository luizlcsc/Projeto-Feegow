<!--#include file="connect.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
Procedimentos = reg("Procedimentos")
Unidades = reg("UnidadeID")
TelaCheckin = reg("TelaCheckin")
%>
<br>
<div class="panel">
<div class="panel-body">
<form method="post" id="frm" name="frm" action="save.asp">
	<input type="hidden" name="I" value="<%=req("I")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />
	<%=header(req("P"), "Modelo de Impressão dos Procedimentos", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
<div class="row">
    <div class="col-md-12">
        <div class="row">
	        <%=quickField("text", "NomeModelo", "Nome do Modelo", 6, reg("NomeModelo"), "", "", " required")%>
            <%=quickfield("multiple", "Procedimentos", "Procedimentos", 3, Procedimentos, "select 'Todos' NomeProcedimento, 'ALL' id UNION ALL select NomeProcedimento, id FROM procedimentos WHERE Ativo='on' and sysActive=1" , "NomeProcedimento", "") %>
            <%=quickField("multiple", "UnidadeID", "Unidades", 3, Unidades, "select 'ALL' id, ' Todos' NomeFantasia UNION ALL select 0, NomeFantasia from empresa where sysActive=1 UNION ALL select id, NomeFantasia from sys_financialcompanyunits where sysActive=1 order by NomeFantasia", "NomeFantasia", "")%>

        </div>
        <br />
        <div class="row">
            <%=quickField("simpleCheckbox", "TelaCheckin", "Imprimir este impresso na tela de Checkin", "6", TelaCheckin, "", "", "")%>
        </div>
        <br />
       <div class="row">
           <br/>
           <%= quickfield("editor", "Cabecalho", "Conteúdo", 10, reg("Cabecalho"), "600", "", "") %>
           <!--#include file="Tags.asp"-->
           <%'= quickfield("editor", "Rodape", "Rodapé", 12, reg("Rodape"), "200", "", "") %>
           <div class="row">
               <div class="col-md-6 pull-right">
                   <%'=macro("Rodape")%>
               </div>
           </div>
        </div>
        <br />
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