<!--#include file="connect.asp"-->
<%
set reg = db.execute("select * from PacientesAtestados where Atestado like '"&ref("atestado")&"' and PacienteID="&ref("PacienteID")&" and date(Data)='"&mydate(date())&"'")
if reg.EOF then

    'inclusão do atendimentoID se houver atendimento em curso
    'verifica se tem atendimento aberto
    set atendimentoReg = db.execute("select * from atendimentos where PacienteID="&ref("PacienteID")&" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
    if(atendimentoReg.EOF) then
	    db_execute("insert into PacientesAtestados (PacienteID, Titulo, Atestado, sysUser) values ("&ref("PacienteID")&", '"&ref("TituloAtestado")&"', '"&ref("atestado")&"', "&session("User")&")")
    else
        'salva com id do atendimento
        db_execute("insert into PacientesAtestados (PacienteID, Titulo, Atestado, sysUser, AtendimentoID) values ("&ref("PacienteID")&", '"&ref("TituloAtestado")&"', '"&ref("atestado")&"', "&session("User")&", "&atendimentoReg("id")&")")
    end if

	set reg = db.execute("select * from pacientesatestados where PacienteID="&ref("PacienteID")&" order by id desc")
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
        <object style="width:100%; height: 600px;" id="ImpressaoAtestado" width="800" data="" type="text/html"></object>
        <%
        else
        %>
        <iframe width="100%" height="600px" src="<%=src%>" id="ImpressaoAtestado" name="ImpressaoAtestado" frameborder="0"></iframe>
        <%
        end if
        %>
        </div>
        <div class="col-md-2">
            <label><input type="checkbox" id="Carimbo" name="Carimbo" class="ace" checked="checked" onclick="window.frames['ImpressaoAtestado'].Carimbo(this.checked);" />
                <span class="lbl"> Carimbar</span>
            </label>
            <label><input type="checkbox" id="Timbrado" name="Timbrado" class="ace" checked  onclick="window.frames['ImpressaoAtestado'].Timbrado(this.checked);" />
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
<script type="text/javascript">

    <%
    if getConfig("UtilizarFormatoImpressao")=1 or recursoPermissaoUnimed=4  then
    'if   session("Banco")="clinic100000" or session("Banco")="clinic5760" or session("Banco")="clinic1526" or session("Banco")="clinic6865" or session("Banco")="clinic6273" or session("Banco")="clinic1526" or recursoPermissaoUnimed=4 then
    %>
        timbrado = $("#Timbrado").prop("checked") ==true?1:0;
        carimbo = $("#Carimbo").prop("checked") ==true?1:0;

        url = domain+"print/medical-certificate/<%=reg("id")%>?showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&tk="+localStorage.getItem("tk");
        console.log(url)
        $("#ImpressaoAtestado").prop("data", url);
    <%
    end if
    %>
    pront('timeline.asp?PacienteID=<%=ref("PacienteID")%>&Tipo=|Atestado|');

    $("#Timbrado").on("change",()=>{
        timbrado = $("#Timbrado").prop("checked") ==true?1:0;
        url = domain+"print/medical-certificate/<%=reg("id")%>?showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&tk="+localStorage.getItem("tk");
        $("#ImpressaoAtestado").prop("data", url);
    });
    $("#Carimbo").on("change",()=>{
        carimbo = $("#Carimbo").prop("checked") ==true?1:0;
        url = domain+"print/medical-certificate/<%=reg("id")%>?showPapelTimbrado="+timbrado+"&showCarimbo="+carimbo+"&tk="+localStorage.getItem("tk");
        $("#ImpressaoAtestado").prop("data", url);
    });


</script>