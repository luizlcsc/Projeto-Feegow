<!--#include file="connect.asp"-->
<%
save = ref("save")
redirect = ref("redirect")

set reg = db.execute("select * from PacientesAtestados where Atestado like '"&ref("atestado")&"' and PacienteID="&ref("PacienteID")&" and date(Data)='"&mydate(date())&"'")
if reg.EOF then
    if cbool(save) then
        'inclusão do atendimentoID se houver atendimento em curso
        'verifica se tem atendimento aberto
        set atendimentoReg = db.execute("select * from atendimentos where PacienteID="&ref("PacienteID")&" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
        if(atendimentoReg.EOF) then
            db_execute("insert into PacientesAtestados (PacienteID, Titulo, Atestado, sysUser, UnidadeID) values ("&ref("PacienteID")&", '"&ref("TituloAtestado")&"', '"&refhtml("atestado")&"', "&session("User")&","&session("UnidadeID")&")")
        else
            'salva com id do atendimento
            db_execute("insert into PacientesAtestados (PacienteID, Titulo, Atestado, sysUser, AtendimentoID, UnidadeID) values ("&ref("PacienteID")&", '"&ref("TituloAtestado")&"', '"&refhtml("atestado")&"', "&session("User")&", "&atendimentoReg("id")&","&session("UnidadeID")&")")
        end if
	    set reg = db.execute("select * from pacientesatestados where PacienteID="&ref("PacienteID")&" order by id desc LIMIT 1")

    else
        AtestadoId = ref("AtestadoId")
        set reg = db.execute("select * from pacientesatestados where id="&AtestadoId)
    end if

end if
recursoPermissaoUnimed = recursoAdicional(12)
%>
<div class="modal-body">
    <div class="row">
        <div class="col-md-10">
        <%
			src="Atestado.asp?AtestadoID="&reg("id")
		%>
         <%
        if getConfig("UtilizarFormatoImpressao")=1 or recursoPermissaoUnimed=4  then
        'if   session("Banco")="clinic100000" or session("Banco")="clinic5760" or session("Banco")="clinic1526" or session("Banco")="clinic6865" or session("Banco")="clinic6273" or session("Banco")="clinic1526" or recursoPermissaoUnimed=4 then
        %>
        <object class="sensitive-data" style="width:100%; height: 600px;" id="ImpressaoAtestado" width="800" data="" type="text/html"></object>
        <%
        else
        %>
        <iframe class="sensitive-data" width="100%" height="600px" src="<%=src%>" id="ImpressaoAtestado" name="ImpressaoAtestado" frameborder="0"></iframe>
        <%
        end if
        %>
        </div>
        <div class="col-md-2">
            <label><input type="checkbox" id="Carimbo" name="Carimbo" class="ace" checked="checked" onclick="window.frames['ImpressaoAtestado'].Carimbo(this.checked);" />
                <span class="lbl"> Carimbar</span>
            </label>
            <label><input type="checkbox" id="Timbrado" name="Timbrado" class="ace" checked onclick="window.frames['ImpressaoAtestado'].TimbradoAtestado(this.checked);" />
                <span class="lbl"> Papel Timbrado</span>
            </label>
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
    'if   session("Banco")="clinic100000" or session("Banco")="clinic5760" or session("Banco")="clinic1526" or session("Banco")="clinic6865" or session("Banco")="clinic6273" or session("Banco")="clinic1526" or recursoPermissaoUnimed=4 then
    %>
        timbrado = $("#Timbrado").prop("checked") ==true?1:0;
        carimbo = $("#Carimbo").prop("checked") ==true?1:0;

        url = domain+"print/medical-certificate/<%=reg("id")%>?assinaturaDigital=1&showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&tk="+localStorage.getItem("tk");
        console.log(url)
        $("#ImpressaoAtestado").prop("data", url);
    <%
    end if
    if cbool(redirect) then
    %>

    pront('timeline.asp?PacienteID=<%=ref("PacienteID")%>&Tipo=|Atestado|');
    <%end if%>

    gtag('event', 'novo_atestado', {
        'event_category': 'atestado',
        'event_label': "Botão 'Salvar' clicado.",
    });

    $("#AtestadoID").val("<%=reg("id")%>");

    $("#Timbrado").on("change",()=>{
        timbrado = $("#Timbrado").prop("checked") ==true?1:0;
        url = domain+"print/medical-certificate/<%=reg("id")%>?assinaturaDigital=1&showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&tk="+localStorage.getItem("tk");
        $("#ImpressaoAtestado").prop("data", url);
    });
    $("#Carimbo").on("change",()=>{
        carimbo = $("#Carimbo").prop("checked") ==true?1:0;
        url = domain+"print/medical-certificate/<%=reg("id")%>?assinaturaDigital=1&showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&tk="+localStorage.getItem("tk");
        $("#ImpressaoAtestado").prop("data", url);
    });


</script>