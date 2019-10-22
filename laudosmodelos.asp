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
            <table class="table table-striped">
                <tbody>
                    <tr class="success">
                        <th>Dados da Execução</th>
                    </tr>
                    <tr>
                        <td>[Data.Execucao]</td>
                    </tr>
                    <tr>
                        <td>[Atendimento.ID]</td>
                    </tr>
                    <tr>
                        <td>[Procedimento.Nome]</td>
                    </tr>
                    <tr>
                        <td>[ProfissionalExecutante.Nome]</td>
                    </tr>
                    <tr>
                        <td>[ProfissionalExecutante.Documento]</td>
                    </tr>
                    <tr>
                        <td>[ProfissionalExecutante.Assinatura]</td>
                    </tr>
                    <tr class="success">
                    	<th>Dados do Laudador</th>
                    </tr>
                    <tr>
                        <td>[ProfissionalLaudador.Nome]</td>
                    </tr>
                    <tr>
                        <td>[ProfissionalLaudador.Documento]</td>
                    </tr>
                    <tr>
                        <td>[ProfissionalLaudador.Assinatura]</td>
                    </tr>
                    <tr class="success">
                    	<th>Dados do Solicitante</th>
                    </tr>
                    <tr>
                        <td>[ProfissionalSolicitante.Nome]</td>
                    </tr>
                    <tr>
                        <td>[ProfissionalSolicitante.Conselho]</td>
                    </tr>
                    <tr>
                        <td>[ProfissionalSolicitante.CPF]</td>
                    </tr>
                    <tr>
                        <td>[ProfissionalSolicitante.Documento]</td>
                    </tr>
        		</tbody>
            </table>
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