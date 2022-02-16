<!--#include file="connect.asp"-->
<%
if ref("ControleEspecial")="true" then
    ControleEspecial = "checked"
end if

save = ref("save")
set reg = db.execute("select * from PacientesPrescricoes where Prescricao = '"&refhtml("receituario")&"' and PacienteID="&ref("PacienteID")&" and date(Data)='"&mydate(date())&"'")

if reg.EOF then
    if cbool(save) then
        'inclusão do atendimentoID na prescricao se houver atendimento em curso
        'verifica se tem atendimento aberto
        set atendimentoReg = db.execute("select * from atendimentos where PacienteID="&ref("PacienteID")&" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
        if(atendimentoReg.EOF) then
            db_execute("insert into PacientesPrescricoes (PacienteID, Prescricao, ControleEspecial, sysUser, UnidadeID) values ("&ref("PacienteID")&", '"&refhtml("receituario")&"', '"&ControleEspecial&"', "&session("User")&","&session("UnidadeID")&")")
        else
            'salva preccricao com id do atendimento
            db_execute("insert into PacientesPrescricoes (PacienteID, Prescricao, ControleEspecial, sysUser, AtendimentoID, UnidadeID) values ("&ref("PacienteID")&", '"&refhtml("receituario")&"', '"&ControleEspecial&"', "&session("User")&", "&atendimentoReg("id")&","&session("UnidadeID")&")")
        end if

        set reg = db.execute("select * from PacientesPrescricoes where PacienteID="&ref("PacienteID")&" order by id desc LIMIT 1")
    else
        PrescricaoId = ref("PrescricaoId")
        set reg = db.execute("select * from PacientesPrescricoes where id="&PrescricaoId)
    end if
else
	db_execute("update PacientesPrescricoes set ControleEspecial='"&ControleEspecial&"' where id="&reg("id"))
end if
recursoPermissaoUnimed = recursoAdicional(12)
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
        <%
        if getConfig("UtilizarFormatoImpressao")=1 or recursoPermissaoUnimed=4  then
        'if   session("Banco")="clinic100000" or session("Banco")="clinic6867" or session("Banco")="clinic5567" or session("Banco")="clinic6173" or session("Banco")="clinic6865" or session("Banco")="clinic6321" or session("Banco")="clinic1526" or session("Banco")="clinic6006"  or session("Banco")="clinic6273" or session("Banco")="clinic6256" or recursoPermissaoUnimed=4  then
        %>

        <object class="sensitive-data" style="width:100%; height: 600px;" id="ImpressaoPrescricao" width="800" data="" type="text/html"></object>
        <%
        else
        %>
        <iframe class="sensitive-data" width="100%" height="600px" src="<%=src%>" id="ImpressaoPrescricao" name="ImpressaoPrescricao" frameborder="0"></iframe>
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
                <i class="far fa-remove"></i>
                Fechar
            </button>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">


</div>
<script type="text/javascript">
    <%
    if getConfig("UtilizarFormatoImpressao")=1 or recursoPermissaoUnimed=4  then
    'if  session("Banco")="clinic100000" or session("Banco")="clinic6867" or session("Banco")="clinic5567" or session("Banco")="clinic6173" or session("Banco")="clinic6321" or session("Banco")="clinic6865" or session("Banco")="clinic1526" or session("Banco")="clinic6006" or session("Banco")="clinic6256" or session("Banco")="clinic6273" or recursoPermissaoUnimed=4 then
    %>
    var timbrado = $("#Timbrado").prop("checked") ==true?1:0;
    var imprimeData = 1;
    var impressaoTermica = 0;
    var carimbo = 1;
        
    gtag('event', 'nova_prescricao', {
        'event_category': 'prescricao',
        'event_label': "Botão 'Salvar' clicado.",
    });

    url = domain+"print/prescription/<%=reg("id")%>?assinaturaDigital=1&showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&showImpressaoTermica="+impressaoTermica+"&showData="+imprimeData+"&tk="+localStorage.getItem("tk");

    console.log(url);
    $("#ImpressaoPrescricao").prop("data", url);
    <%
    end if
    %>
    pront('timeline.asp?PacienteID=<%=ref("PacienteID")%>&Tipo=|Prescricao|');
    $("#PrescricaoId").val("<%=reg("id")%>");

    $("#Timbrado").on("change",()=>{
        timbrado = $("#Timbrado").prop("checked") ==true?1:0;
        url = domain+"print/prescription/<%=reg("id")%>?assinaturaDigital=1&showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&showImpressaoTermica="+impressaoTermica+"&showData="+imprimeData+"&tk="+localStorage.getItem("tk");
        $("#ImpressaoPrescricao").prop("data", url);
    });
    $("#Datar").on("change",()=>{
        imprimeData = $("#Datar").prop("checked") ==true?1:0;
        url = domain+"print/prescription/<%=reg("id")%>?assinaturaDigital=1&showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&showImpressaoTermica="+impressaoTermica+"&showData="+imprimeData+"&tk="+localStorage.getItem("tk");
        $("#ImpressaoPrescricao").prop("data", url);
    });
    $("#Carimbo").on("change",()=>{
        carimbo = $("#Carimbo").prop("checked") ==true?1:0;
        url = domain+"print/prescription/<%=reg("id")%>?assinaturaDigital=1&showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&showImpressaoTermica="+impressaoTermica+"&showData="+imprimeData+"&tk="+localStorage.getItem("tk");
        $("#ImpressaoPrescricao").prop("data", url);
    });
    $("#Termical").on("change",()=>{
        impressaoTermica = $("#Termical").prop("checked") ==true?1:0;
        url = domain+"print/prescription/<%=reg("id")%>?assinaturaDigital=1&showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&showImpressaoTermica="+impressaoTermica+"&showData="+imprimeData+"&tk="+localStorage.getItem("tk");
        $("#ImpressaoPrescricao").prop("data", url);
    });

</script>