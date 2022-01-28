<!--#include file="connect.asp"-->
<%
save = ref("save")
receituario = replace(refhtml("receituario"),"'","\")

set reg = db.execute("select * from encaminhamentos where descricao like '"&receituario&"' and PacienteID="&ref("PacienteID")&" and date(datahora)='"&mydate(date())&"'")

if reg.EOF then
    if cbool(save) then
            db_execute("insert into encaminhamentos (pacienteid, especialidadeid, profissionalemissorid, descricao) values ("&ref("PacienteID")&","&ref("EspecialidadeID")&","&session("User")&",'"&receituario&"')")
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
			src="Receituario.asp?PrescricaoID="&reg("id")
		end if
		%>

        <object style="width:100%; height: 600px;" id="ImpressaoPrescricao" width="800" data="" type="text/html"></object>
        <%
        else
        %>
        <iframe width="100%" height="600px" src="<%=src%>" id="ImpressaoPrescricao" name="ImpressaoPrescricao" frameborder="0"></iframe>
        <%
        end if
        %>
        </div>
        <div class="col-md-2">
    	    	<label><input type="checkbox" id="Carimbo" name="Carimbo" class="ace" checked="checked" onclick="window.frames['ImpressaoPrescricao'].Carimbo(this.checked);" />
                	<span class="lbl"> Carimbar</span>
                </label>

                <label>
                    <input <% if ref("ControleEspecial")<>"true" then %> checked="checked" <% end if %> type="checkbox" id="Timbrado" name="Timbrado" class="ace" />
                    <span class="lbl"> Papel Timbrado</span>
                </label>
        	<%
			if ref("ControleEspecial")="true" then
				%>
    	    	<label><input type="checkbox" id="Datar" name="Datar" class="ace" checked="checked" onclick="window.frames['ImpressaoPrescricao'].Datar(this.checked);" />
                	<span class="lbl"> Imprimir data</span>
                </label>

                <label><input type="checkbox" id="Termica" name="Termica" class="ace"  onclick="window.frames['ImpressaoPrescricao'].Vertical(this.checked);" />
                    <span class="lbl"> Imp. Térmica</span>
                </label>
                <%
			end if
			%>
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