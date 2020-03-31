<!--#include file="connect.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "& req("P") &" where id="& req("I"))
%>
<form method="post" id="frm" name="frm" action="save.asp">
    <%=header(req("P"), "Papel Timbrado", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <%= quickfield("text", "NomeModelo", "Nome do Modelo", 4, reg("NomeModelo"), "", "", "") %>
                <%= quickfield("multiple", "Profissionais", "Profissionais", 4, reg("Profissionais"), "select 'ALL' id, ' Todos' NomeProfissional UNION ALL select id, NomeProfissional from profissionais where ativo='on' and sysActive=1 order by NomeProfissional", "NomeProfissional", "") %>
                <%= quickField("multiple", "UnidadeID", "Unidades", 4, reg("UnidadeID"), "select 'ALL' id, ' Todos' NomeFantasia UNION ALL select 0, NomeFantasia from empresa where sysActive=1 UNION ALL select id, NomeFantasia from sys_financialcompanyunits where sysActive=1 order by NomeFantasia", "NomeFantasia", "")%>
            </div>

            <h3 style="font-weight:300; margin:20px 0; color: #3498db; border-bottom:1px solid #efefef"> Personalização</h3>
            <div class="row">
                <%= quickfield("number", "mRight", "Margem Dir. (px)", 2, reg("mRight"), "", "", "") %>
                <%= quickfield("number", "mLeft", "Margem Esq. (px)", 2, reg("mLeft"), "", "", "") %>
                <%= quickfield("number", "mTop", "Margem Sup. (px)", 2, reg("mTop"), "", "", "") %>
                <%= quickfield("number", "mBottom", "Margem Inf. (px)", 2, reg("mBottom"), "", "", "") %>
                <%= quickfield("number", "font-size", "Tamanho da Fonte (px)", 2, reg("font-size"), "", "", " min='1'") %>
                <%= quickfield("cor", "color", "Cor da Fonte", 2, reg("color"), "", "", "") %>
            </div>
            <div class="row">
                <%= quickfield("simpleSelect", "font-family", "Fonte padrão", 4, reg("font-family"), "select * from cliniccentral.`font-family`", "font-family", "") %>
                <%= quickfield("number", "line-height", "Altura da Linha", 2, reg("line-height"), "", "", " min='1'") %>
            </div>
            <div class="row">
                <br/>
                <%= quickfield("editor", "Cabecalho", "Cabeçalho", 12, reg("Cabecalho"), "200", "", "") %>
                <div class="row">
                    <div class="col-md-6">
                        <br>
                        <%RecursoTag = "PapelTimbrado"%>
                        <!--#include file="Tags.asp"-->
                    </div>
                </div>
                <%= quickfield("editor", "Rodape", "Rodapé", 12, reg("Rodape"), "200", "", "") %>
                </div>
            </div>
        </div>
    </div>
</form>
<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});
</script>