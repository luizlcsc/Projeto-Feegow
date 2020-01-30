<!--#include file="connect.asp"-->
<%
call insertRedir(request.QueryString("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
Tipo = reg("Tipo")
PapelTimbradoID = reg("PapelTimbradoID")
%>
<br>
<div class="panel">
<div class="panel-body">
<form method="post" id="frm" name="frm" action="save.asp">
	<input type="hidden" name="I" value="<%=req("I")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />
	<%=header(req("P"), "Modelo de Encaminhamentos", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
<div class="row">
    <div class="col-md-12">
        <div class="row">
	        <%=quickField("text", "NomeEncaminhamento", "Nome do Encaminhamento", 6, reg("NomeEncaminhamento"), "", "", " required")%>
            <%=quickField("simpleSelect", "PapelTimbradoID", "Papel Timbrado", 3, PapelTimbradoID, "select id, NomeModelo from papeltimbrado where sysActive=1 order by NomeModelo", "NomeModelo", "") %>
            <%=quickfield("multiple", "Tipo", "Tipo", 3, Tipo, "select 'Especialista' id, 'Especialista' Tipo UNION select 'Equipe Multidisciplinar' id, 'Equipe Multidisciplinar' Tipo UNION select 'Pronto-Socorro' id, 'Pronto-Socorro' Tipo " , "Tipo", "") %>
        </div>
        <br />
       <div class="col-md-9">
           <div class="row">
               <br/>
               <%= quickfield("editor", "Conteudo", "Conteúdo", 12, reg("Conteudo"), "600", "", "") %>
               <div class="row">
                   <div class="col-md-6 pull-right">
                       <%=macro("Conteudo")%>
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
                        <th>Dados do Atendimento</th>
                    </tr>
                    <tr>
                        <td>[Paciente.ProntuarioDiagnosticos]</td>
                    </tr>
                    <tr>
                        <td>[Paciente.ProntuarioPrescricoes]</td>
                    </tr>
                    <tr>
                        <td>[Encaminhamento.Motivo]</td>
                    </tr>
                    <tr>
                        <td>[Encaminhamento.Obs]</td>
                    </tr>
                    <tr>
                        <td>[Encaminhamento.Encaminhado]</td>
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