<!--#include file="connect.asp"-->
<%
ActiveMedicamento = " class=""active"""

if req("id")="0" then
	sqlMedicamento = "select * from PacientesMedicamentos where sysActive=0 and sysUser="&session("User")
	set regMed = db.execute(sqlMedicamento)
	if regMed.eof then
		db_execute("insert into PacientesMedicamentos (sysActive, sysUser) values (0, "&session("User")&")")
		set regMed = db.execute(sqlMedicamento)
		MedicamentoLast = "Medicamento-Last"
	end if
	MedicamentoID = regMed("id")
	sqlFormula = "select * from PacientesFormulas where sysActive=0 and sysUser="&session("User")
	set regFor = db.execute(sqlFormula)
	if regFor.eof then
		db_execute("insert into PacientesFormulas (sysActive, sysUser) values (0, "&session("User")&")")
		set regFor = db.execute(sqlFormula)
		FormulaLast = "Formula-Last"
	end if
	FormulaID = regFor("id")
else
	Tipo = req("tipo")
	if Tipo="M" then
		Tipo="Medicamento"
	elseif Tipo="F" then
		Tipo="Formula"
    elseif Tipo="B" then
        Tipo="Bula"
	end if
	if Tipo="Medicamento" then
		MedicamentoID = req("id")
		set regMed = db.execute("select * from PacientesMedicamentos where id="&req("id"))
	elseif Tipo="Formula" then
		set regFor = db.execute("select * from PacientesFormulas where id="&req("id"))
		FormulaID = req("id")
		ActiveMedicamento = ""
		ActiveFormula = " class=""active"""
	end if
end if
%>
<style>
.mt5{
    margin-top: 5px;
}
</style>
<div class="modal-body">
    <div class="tabbable">
        <ul class="nav nav-tabs" id="myTab">
        	<%
			if Tipo="Medicamento" or Tipo="" then
				%>
                <li<%=activeMedicamento%>>
                    <a data-toggle="tab" href="#divMedicamento">
                        Medicamento
                    </a>
                </li>
        	<%
			end if
			if Tipo="Formula" or Tipo="" then
				%>
                <li<%=activeFormula%>>
                    <a data-toggle="tab" href="#Formula">
                        F&oacute;rmula
                    </a>
                </li>
			<%
			end if
			%>
        </ul>
    
        <div class="tab-content">
        	<%
			if Tipo="Medicamento" or Tipo="" then
				Prescricao = regMed("Prescricao")
				Profissionais = regMed("Profissionais")
				%>
				<div id="divMedicamento" class="tab-pane in active mt5">
                    <form id="CadastroMedicamento" action="" method="post">
                    <%=regMed("Profissionais")%>
                        <input type="hidden" name="I" value="<%=MedicamentoID%>" />
                        <input type="hidden" name="P" value="PacientesMedicamentos" />
                        <div class="row">
                            <%=quickField("text", "Medicamento", "Nome do Medicamento", 8, regMed("Medicamento"), "", "", " required" )%>
                            <%=quickField("multiple", "Profissionais", "Profissionais", 4, Profissionais, "select id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
                        </div>
                        <div class="row">
                            <%=quickField("text", "Uso", "Uso", 3, regMed("Uso"), "", "", "" )%>
                            <%=quickField("text", "Quantidade", "Quantidade", 3, regMed("Quantidade"), "", "", "" )%>
                            <%=quickField("text", "Grupo", "Grupo", 3, regMed("Grupo"), "", "", "" )%>
                            <%=quickField("text", "Apresentacao", "Apresenta&ccedil;&atilde;o", 3, regMed("Apresentacao"), "", "", "" )%>

                        </div>
                        <div class="row">
							<%=quickField("memo", "Prescricao", "Prescri&ccedil;&atilde;o", 12, Prescricao, " presc", "", " placeholder=""Como aparecer&aacute; no receitu&aacute;rio"" rows=""4""" )%>
                        </div>
                        <div class="row">
                        	<div class="col-md-6 pull-right">
                            	<%=macro("Prescricao")%>
                            </div>
                        </div>
                        <div class="row">
							<%=quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es Internas", 12, regMed("Observacoes"), "", "", " placeholder=""N&atilde;o aparecer&atilde;o no receitu&aacute;rio"" rows=""2""" )%>
                        </div>

                        <div class="panel-footer row mt5">
                            <div class="col-md-2 col-md-offset-8">
                                <button type="button" class="btn btn-default pull-right btn-block" onclick="$('#btnprescricao').click();"><i class="far fa-arrow-left"></i> Voltar</button>
                            </div>
                            <div class="col-md-2">
                                <button class="btn btn-success btn-block" id="saveMedicamento"><i class="far fa-save"></i> Salvar</button>
                            </div>
                        </div>

                    </form>
				</div>
			<%
			end if
			if Tipo="Formula" or Tipo="" then
                    Profissionais = regFor("Profissionais")
				%>
				<div id="Formula" class="tab-pane<%if Tipo="Formula" then%> in active<%end if%> mt5">
					<form id="CadastroFormula" name="CadastroFormula" action="" method="post">
							<input type="hidden" name="I" value="<%=FormulaID%>" />
							<input type="hidden" name="P" value="PacientesFormulas" />
						<div class="row">
							<%=quickField("text", "Nome", "Nome da F&oacute;rmula", 8, regFor("Nome"), "", "", " required placeholder=""D&ecirc; um nome &agrave; f&oacute;rmula""" )%>
                            <%=quickField("multiple", "Profissionais", "Profissionais", 4, Profissionais, "select id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>

						</div>
						<div class="row">
                            <%=quickField("text", "Uso", "Uso", 4, regFor("Uso"), "", "", "" )%>
							<%=quickField("text", "Quantidade", "Quantidade", 4, regFor("Quantidade"), "", "", "" )%>
							<%=quickField("text", "Grupo", "Grupo", 4, regFor("Grupo"), "", "", "" )%>
						</div>
						<div class="row mt5">
							<div class="col-md-12 ">
								<% call Subform("ComponentesFormulas", "FormulaID", FormulaID, "CadastroFormula") %>
							</div>
						</div>
						<div class="row">
							<%=quickField("memo", "Prescricao", "Prescri&ccedil;&atilde;o", 12, regFor("Prescricao"), " presc", "", " placeholder=""Como aparecer&aacute; no receitu&aacute;rio""" )%>
                        </div>
                        <div class="row">
                        	<div class="col-md-6 pull-right">
                            	<%=macro("Prescricao")%>
                            </div>
                        </div>
                        <div class="row">
							<%=quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es Internas", 12, regFor("Observacoes"), "", "", " placeholder=""N&atilde;o aparecer&atilde;o no receitu&aacute;rio""" )%>
						</div>

						<div class="panel-footer row mt5">
                            <div class="col-md-2 col-md-offset-8">
                                <button type="button" class="btn btn-default pull-right btn-block" onclick="$('#btnprescricao').click();"><i class="far fa-arrow-left"></i> Voltar</button>
                            </div>
                            <div class="col-md-2">
                                <button class="btn btn-success btn-block" id="saveFormula"><i class="far fa-save"></i> Salvar</button>
                            </div>
                        </div>


					</form>
				</div>
            	<%
			end if
			%>
         </div>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function(e) {
	<%
	call formSave("frm", "save", "")
	call formSave("CadastroMedicamento", "saveMedicamento", "ListaMedicamentosFormulas('', '', '"&MedicamentoLast&"'); $('#btnprescricao').click();")
	call formSave("CadastroFormula", "saveFormula", "ListaMedicamentosFormulas('', '', '"&FormulaLast&"'); $('#btnprescricao').click();")
	%>
	$("#tabBulas").click(function(){
		 bula($('#Medicamento').attr('value'), '');
	});
});



$(function () {  
	CKEDITOR.config.height = 130;
	$('.presc').ckeditor();
});

<%if Tipo="Bula" then%>
$("#tabBulas").click();
<%end if%>

<!--#include file="JQueryFunctions.asp"-->

</script>