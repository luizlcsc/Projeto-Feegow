<!--#include file="connect.asp"-->
<%
save = ref("save")
receituario = replace(refhtml("receituario"),"'","\")

set reg = db.execute("select * from encaminhamentos where descricao like '"&receituario&"' and PacienteID="&ref("PacienteID")&" and date(datahora)='"&mydate(date())&"'")

if reg.EOF then
    if cbool(save) then
            db_execute("insert into encaminhamentos (pacienteid, especialidadeid, profissionalemissorid, descricao, sysactive, UnidadeID) values ("&ref("PacienteID")&","&ref("EspecialidadeID")&","&session("User")&",'"&receituario&"', 1, "&session("UnidadeID")&")")

        set reg = db.execute("select * from encaminhamentos where PacienteID="&ref("PacienteID")&" order by id desc LIMIT 1")
    else
        EncaminhamentoId = ref("EncaminhamentoId")
        set reg = db.execute("select * from encaminhamentos where id="&EncaminhamentoId)
    end if
end if
%>
<div class="modal-body">
    <div class="row">
        <div class="col-md-10">
        <%
		if ControleEspecial="checked" then
			src="ControleEspecial.asp?PrescricaoID="&reg("id")
		else
			src="printEncaminhamento.asp?TipoEncaminhamento=Encaminhamento&PacienteID="&ref("PacienteID")&"&EncaminhamentoID="&reg("id")&"&EspecialidadeId="&ref("EspecialidadeID")
		end if
        if getConfig("UtilizarFormatoImpressao")=1 or recursoPermissaoUnimed=4  then
		%>

        <object style="width:100%; height: 600px;" id="ImpressaoEncaminhamento" width="800" data="" type="text/html"></object>
        <%
        else
        %>
        <iframe width="100%" height="600px" src="<%=src%>" id="ImpressaoEncaminhamento" name="ImpressaoEncaminhamento" frameborder="0"></iframe>
        <%
        end if
        %>
        </div>
        <div class="col-md-2">
    	    	<label><input type="checkbox" id="Carimbo" name="Carimbo" class="ace" checked="checked" onclick="window.frames['ImpressaoEncaminhamento'].Carimbo(this.checked);" />
                	<span class="lbl"> Carimbar</span>
                </label>

                <label>
                    <input type="checkbox" id="Timbrado" name="Timbrado" class="ace" checked="checked" onclick="window.frames['ImpressaoEncaminhamento'].Timbrado(this.checked);" />
                    <span class="lbl"> Papel Timbrado</span>
                </label>
                <hr />
            <button class="btn btn-sm btn-success btn-block" data-dismiss="modal">
                <i class="fa fa-remove"></i>
                Fechar
            </button>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">


</div>