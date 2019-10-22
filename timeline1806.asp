<!--#include file="connect.asp"-->
<%
if request.ServerVariables("REMOTE_ADDR")<>"::1" and request.ServerVariables("REMOTE_ADDR")<>"127.0.0.1" then
	on error resume next
end if

if req("X")<>"" then
    if req("Tipo")="|Prescricao|" then
        db_execute("delete from pacientesprescricoes where id="& req("X"))
    end if
    if req("Tipo")="|Atestado|" then
        db_execute("delete from pacientesatestados where id="& req("X"))
    end if
    if req("Tipo")="|Pedido|" then
        db_execute("delete from pacientespedidos where id="& req("X"))
    end if
end if
%>
<style type="text/css">
#folha{
		font-family: Arial, sans-serif;
		list-style-type: none;
		margin: 0px;
		padding: 0px;
		width: 760px;
		height:1200px;
		background-color:#FFFFFF;
		border:1px solid #fff;
		position:relative;
}
.campos{
		position:absolute;
		margin: 0;
		border: 2px dotted #fff;
		text-align: center;
		padding: 10px;
		background-color: #fff;
		text-align:left;
		min-height:80px!important;
}
.lembrar{
	position:absolute;
	right:0;
	display:none;
}
.campos:hover .lembrar{
	display:block;
}
.campo:hover .lembrar{
	display:block;
}
.gridster .gs-w {
    cursor:default!important;
}
@media print{
    .panel-controls{
        display: none;
    }
    #timeline.timeline-single .timeline-icon{
        background-color: #EEEEEE;
        border-radius: 50%;
        height: 35px;
        width: 35px;
        z-index: 99;
    }
}
.btn-primary.disabled{
    pointer-events:auto;
}
</style>



<div class="row">
    <div class="col-xs-12">
        <%
'on error resume next

PacienteID = req("PacienteID")
Tipo = req("Tipo")
PacienteSQL = db.execute("SELECT NomePaciente FROM pacientes WHERE id = "&PacienteID)
NomePaciente = PacienteSQL("NomePaciente")
%>
<h2 class="visible-print"><%=NomePaciente%></h2>
<%

EmAtendimento = 0
if session("Atendimentos")<>"" then
    EmAtendimento = 1
end if

if session("Banco")<>"clinic5445" then
    EmAtendimento=1
end if

select case Tipo
    case ""
        
    case "|AE|", "|L|"
        if Tipo="|AE|" then
            subTitulo = "Anamneses e Evoluções"
            rotuloBotao = "Inserir Anamnese / Evolução"
            sqlForm = " Tipo IN(1,2) "
        else
            subTitulo = "Laudos e Formulários"
            rotuloBotao = "Inserir Laudo / Formulário"
            sqlForm = " ( Tipo IN (3,4,0) OR ISNULL(Tipo) ) "
        end if

        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
            </div>
            <div class="panel-body">
                <div class="col-md-3">
                    <div class="btn-group btn-block">
                        <button type="button" class="btn btn-primary btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                            <i class="fa fa-plus"></i> <%=rotuloBotao %>
                            <span class="caret ml5"></span>
                        </button>
                        <ul class="dropdown-menu" role="menu">
                            <%

                        sqlBuiforms = "select Nome,id from buiforms where sysActive=1 and "& sqlForm &" order by Nome"

			            set forms = db.execute(sqlBuiforms)
			            while not forms.eof
				            if autForm(forms("id"), "IN", "") then
                            %>
                            <li  <% if EmAtendimento=0 then%>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<% end if%>><a  <% if EmAtendimento=1 then%>href="javascript:iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, <%=forms("id")%>, 'N', '');"<% end if %>><i class="fa fa-plus"></i> <%=forms("Nome")%></a></li>
                            <%
				            end if
			            forms.movenext
			            wend
			            forms.close
			            set forms = nothing
			            if aut("buiformsI") and session("Banco")<>"clinic522" then
                            %>
                            <li class="divider"></li>
                            <li><a href="./?P=buiforms&Pers=Follow"><i class="fa fa-cog"></i> Gerenciar modelos de <%=lcase(subTitulo) %></a></li>
                            <%
			            end if
                            %>
                        </ul>
                    </div>
                </div>
                <%
                if Tipo="|L|" and (session("Banco")="clinic100000" or session("Banco")="clinic5445") then
                set WorklistDoPacienteSQL = db.execute("SELECT * FROM worklist WHERE PacienteID="&PacienteID)

                if not WorklistDoPacienteSQL.eof then
                %>
                <div class="col-md-3">
                    <a class="btn btn-default" type="button" href="https://clinic.feegow.com.br/feegow_components/diagnext/openInViewer?patient=<%=PacienteID%>"><i class="fa fa-laptop"></i> Abrir Worklist</a>
                </div>
                <%
                end if
                end if
                %>
            </div>
        </div>
        <%
    case "|Diagnostico|"
        subTitulo = "Diagnósticos"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
            </div>
            <div class="panel-body">
                <div class="col-md-3">
                    <button type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%else %>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, 'N', '');" <%end if%>>
                        <i class="fa fa-plus"></i> Inserir Diagnóstico
                    </button>
                </div>
            </div>
        </div>
        <%
    case "|Prescricao|"
        subTitulo = "Prescrições"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %> </span>
            </div>
            <%
            if aut("prescricoesI") then
            %>
            <div class="panel-body">
                <div class="col-md-3">
                    <button type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%else%>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>>
                        <i class="fa fa-plus"></i> Inserir Prescrição
                    </button>
                </div>
            </div>
            <%
            end if
            %>
        </div>
        <%
    case "|Atestado|"
        subTitulo = "Textos e Atestados"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
            </div>
            <%
            if aut("atestadosI")=1 then
            %>
            <div class="panel-body">
                <div class="col-md-3">
                    <button type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right" <% else%>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>>
                        <i class="fa fa-plus"></i> Inserir Texto / Atestado
                    </button>
                </div>
            </div>
            <%
            end if
            %>
        </div>
        <%
    case "|Pedido|"
        subTitulo = "Pedidos de Exame"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
            </div>
            <%
            if aut("pedidosexamesI")=1 then
            %>
            <div class="panel-body">
                <div class="col-md-3">
                    <div class="btn-group btn-block">
                        <button type="button" class="btn btn-primary btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                            <i class="fa fa-plus"></i> Inserir Pedido de Exame
                            <span class="caret ml5"></span>
                        </button>
                        <ul class="dropdown-menu" role="menu">
                            <li <% if EmAtendimento=0 then %>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%end if%>><a <% if EmAtendimento=1 then %>href="javascript:iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>><i class="fa fa-plus"></i> Pedido Padrão</a></li>
                            <li <% if EmAtendimento=0 then %>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%end if%>><a <% if EmAtendimento=1 then %>href="javascript:iPront('<%=replace("PedidosSADT", "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>><i class="fa fa-plus"></i> Pedido em Guia de SP/SADT</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            <%
            end if
            %>
        </div>
        <%
    case "|Imagens|"
        %>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title"><i class="fa fa-camera"></i> Imagens do Paciente</span>
    </div>
    <div id="divImagens" class="panel-body pn">
        <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=PacienteID %>&Tipo=I"></iframe>
    </div>
</div>




<link rel="stylesheet" href="assets/css/colorbox.css" />
<style type="text/css">
.tools {
    background-color: #fff;
    padding: 10px;
    position: absolute;
    z-index: 10;
    width: 100%;
    opacity: 0;
    transition: opacity 300ms;
    transition-timing-function: ease-in-out;
}

.tools-b {
    bottom:0;
}

.mix:hover .tools {
    opacity: 0.93;
}

#avpw_powered_branding{
	display:none!important;
	visibility:hidden!important;
}
</style>

<!-- Instantiate Feather -->
<script type="text/javascript">
    var featherEditor = new Aviary.Feather({
        apiKey: 'e8fb4c93fc2c4946bd4a5725faa30ebb',
        theme: 'light', // Check out our new 'light' and 'dark' themes!
        tools: 'all',
        appendTo: '',
        language: 'pt_BR',
        onSave: function (imageID, newURL) {
            var img = document.getElementById(imageID);
            var fileName = $("#"+imageID).attr("data-path");
            img.src = newURL;
            $.post('save.php?IP=<%=sServidor%>&setMain=1', {id:fileName,url: newURL});
            featherEditor.close();
        },
        onSave: function(imageID, newURL) {
            var img = document.getElementById(imageID);
            img.src = newURL;
		   
            $.post("https://clinic.feegow.com.br/save.php?IP=<%=sServidor%>&PacienteID=<%=req("PacienteID")%>&B=<%=session("Banco")%>", {url:newURL}, function(data){
                atualizaAlbum(0); 
                featherEditor.close(); 
            });
        },
        postUrl: 'https://clinic.feegow.com.br/save.php?IP=<%=sServidor%>&PacienteID=<%=req("PacienteID")%>&B=<%=session("Banco")%>',
        onError: function(errorObj) {
            alert(errorObj.message);
        }
    });
    function launchEditor(id, src) {
        featherEditor.launch({
            image: id,
            url: src
        });
        return false;
    }

</script>


<div id='injection_site'></div>
<form id="frmComparar">
    <div id="ImagensPaciente"><%server.execute("Imagens.asp")%></div>
</form>
        <%



    case "|Arquivos|"
        %>

        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title"><i class="fa fa-file"></i> Arquivos do Paciente</span>
            </div>
            <div class="panel-body pn">
                <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=PacienteID %>&Tipo=A"></iframe>
            </div>
        </div>
        <div id="ArquivosPaciente"><%server.execute("Arquivos.asp") %></div>
        <%
end select    
%>
    </div>


    <div class="col-xs-12">

        <div id="timeline" class="timeline-single mt30">

            <%
    if instr(Tipo, "|AE|")>0 then
    	sqlAE = " union all (select fp.id, fp.ModeloID, fp.sysUser, 'AE', f.Nome, 'bar-chart', 'info', fp.DataHora, f.Tipo from buiformspreenchidos fp LEFT JOIN buiforms f on f.id=fp.ModeloID WHERE f.Tipo IN(1, 2) AND (fp.sysActive=1 OR fp.sysActive IS NULL) AND PacienteID="&PacienteID&") "
    end if
    
    if instr(Tipo, "|L|")>0 then
        sqlL = 	" union all (select fp.id, fp.ModeloID, fp.sysUser, 'L', f.Nome, 'align-left', 'primary', fp.DataHora, f.Tipo from buiformspreenchidos fp LEFT JOIN buiforms f on f.id=fp.ModeloID WHERE (f.Tipo IN(3, 4, 0) or isnull(f.Tipo)) AND (fp.sysActive=1 OR fp.sysActive IS NULL) AND PacienteID="&PacienteID&") "
    end if

	if instr(Tipo, "|Prescricao|")>0 then
        sqlPrescricao = " union all (select id, ControleEspecial, sysUser, 'Prescricao', 'Prescrição', 'flask', 'warning', `Data`, Prescricao from pacientesprescricoes WHERE PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Diagnostico|")>0 then
        sqlDiagnostico = " union all (select d.id, '', d.sysUser, 'Diagnostico', 'Hipótese Diagnóstica', 'stethoscope', 'dark', d.DataHora, concat('<b>', IFNULL(cid.Codigo,''), ' - ', IFNULL(cid.Descricao,''), '</b><br>', IFNULL(d.Descricao,'')) FROM pacientesdiagnosticos d LEFT JOIN cliniccentral.cid10 cid on cid.id=d.CidID WHERE PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Atestado|")>0 then
        sqlAtestado = " union all (select id, '', sysUser, 'Atestado', ifnull(Titulo, 'Atestado'), 'file-text-o', 'success', `Data`, Atestado from pacientesatestados  WHERE PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Pedido|")>0 then
        sqlPedido = " union all (select id, '', sysUser, 'Pedido', 'Pedido de Exame', 'hospital-o', 'system', `Data`, PedidoExame from pacientespedidos WHERE PacienteID="&PacienteID&") "
        sqlPedido = sqlPedido & " union all (select id, '', sysUser, 'PedidosSADT', 'Pedido SP/SADT', 'hospital-o', 'system', `Data`, IndicacaoClinica from pedidossadt WHERE sysActive=1 and PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|ImagensXXXXXX|")>0 then
        sqlImagens = " union all (select '0', Tipo, '0', 'Imagens', 'Imagens', 'camera', 'alert', DataHora, '' from arquivos WHERE Tipo='I' AND PacienteID="&PacienteID&" GROUP BY date(DataHora) ) "
    end if

    if instr(Tipo, "|ArquivosXXXXXX|")>0 then
        sqlArquivos = " union all (select '0', Tipo, '0', 'Arquivos', 'Arquivos', 'file', 'danger', DataHora, '' from arquivos WHERE Tipo='A' AND PacienteID="&PacienteID&" GROUP BY date(DataHora) ) "
    end if



                 c=0

    sql = "select * from ( (select '' id, '' Modelo, '' sysUser, '' Tipo, '' Titulo, '' Icone, '' cor, '' DataHora, '' Conteudo limit 0) "&_ 
                sqlAE & sqlL & sqlPrescricao & sqlDiagnostico & sqlAtestado & sqlPedido & sqlImagens & sqlArquivos &_
                ") t ORDER BY DataHora DESC"
             set ti = db.execute( sql )
             while not ti.eof
                 Ano = year(ti("DataHora"))
                 if UltimoAno<>Ano then
                    abreAno = "          <div class=""timeline-divider mtn hidden-xs"">            <div class=""divider-label"">"&Ano&"</div>          </div>          <div class=""row"">          <div class=""col-sm-6 right-column"">"
                    if c>0 then
                        abreAno = "</div></div>" & abreAno
                    end if
                 else
                    abreAno = ""
                 end if
                 UltimoAno = Ano

                 response.write( abreAno )

                 c = c + 1
                exibe = 1
                if ti("Tipo")="AE" or ti("Tipo")="L" then
                	if ti("Tipo")="L" then
		                sqlTipo = " and (buiforms.Tipo=3 or buiforms.Tipo=4 or buiforms.Tipo=0 or isnull(buiforms.Tipo))"
	                else
		                sqlTipo = " and (buiforms.Tipo=1 or buiforms.Tipo=2)"
	                end if

                    set preen = db.execute("select buiformspreenchidos.id idpreen, buiforms.Nome, buiformspreenchidos.ModeloID, buiformspreenchidos.Autorizados, buiformspreenchidos.sysUser preenchedor, buiformspreenchidos.PacienteID, buiformspreenchidos.DataHora, buiforms.* from buiformspreenchidos left join buiforms on buiformspreenchidos.ModeloID=buiforms.id where buiformspreenchidos.id="& ti("id") &" order by buiformspreenchidos.DataHora desc, id desc")
                    if not preen.eof then
	                    if preen("preenchedor")=session("User") or preen("Autorizados")="|ALL|" or isnull(preen("Autorizados")) then
		                    if preen("Autorizados")="|ALL|" or isnull(preen("Autorizados")) then
			                    icone = "unlock"
		                    else
			                    icone = "lock"
		                    end if

                            if autForm(preen("ModeloID"), "VO", "")=true or autForm(preen("ModeloID"), "AO", "")=true or preen("preenchedor")=session("User") then
                                exibe = 1
                            else
                                exibe = 0
                            end if
                        end if
                    end if
                end if
                if exibe=1 then
             %>


            <div class="timeline-item">
                <div class="timeline-icon hidden-xs">
                    <span class="fa fa-<%=ti("icone") %> text-<%=ti("cor") %>"></span>
                </div>
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title">
                            <span class="fa fa-align-justify"></span>
                            <% if ti("sysUser")<>0 then response.write( nameInTable(ti("sysUser")) ) end if %>
                            <code><%=ti("Titulo") %></code>
                        </span>

                        <span class="panel-controls hidden-xs">
                            <a href="javascript:iPront('<%=ti("Tipo") %>', <%=PacienteID%>, '<%=ti("Modelo")%>', <%=ti("id") %>, '');">
                                <i class="fa fa-search-plus"></i>
                            </a>
                            <% if cstr(session("User"))=ti("sysUser")&"" and aut("prescricoesX")>0 then %>
                                <a href="javascript:if(confirm('Tem certeza de que deseja apagar esta prescrição?'))pront('timeline.asp?PacienteID=<%= PacienteID %>&Tipo=|<%= ti("Tipo") %>|&X=<%= ti("id") %>');">
                                    <i class="fa fa-remove"></i>
                                </a>
                            <% end if %>
                        </span>

                        <div class="panel-header-menu pull-right mr10 text-muted fs12"><%
                            if not isnull(ti("DataHora")) then
                                response.write( formatdatetime( ti("DataHora"), 2) &" - "& ft( ti("DataHora")) )
                            end if
                            %> </div>
                    </div>
                    <div class="panel-body timelineApp" <% if device()<>"" then %> style="overflow-x:scroll!important" <% end if %> >
                <%
'                response.Write( Rotulo & Valor  &"<br>{{"& ti("Tipo") &"}}" )
                select case ti("Tipo")
                    case "AE", "L"
                        response.Write("<small>")
                            set reg = db.execute("select * from `_"& ti("Modelo") &"` where id="& ti("id"))
                            if not reg.eof then

                                set pcampos = db.execute("select * from buicamposforms where FormID="&ti("Modelo")&" and TipoCampoID NOT IN(7,10,11,12,14,15) ORDER BY Ordem")
                                while not pcampos.eof
                                    Rotulo = trim(pcampos("RotuloCampo")&"")
                                    if Rotulo<>"" then
                                        Rotulo = "<b>"&Rotulo&" </b> "
                                    end if
                                    if pcampos("TipoCampoID")=9 then
                                        Valor = ""
                                    else
                                        Valor = trim(reg(""&pcampos("id")&"")&"")
                                    end if
                                    select case pcampos("TipoCampoID")
                                        case 3
                                            if Valor<>"" and Valor<>"uploads/" then
                                            %>
                                            <div class="media-body">
                                                <b><%=Rotulo %></b><br />
                                                <img src="uploads/<%=Valor %>" class="mw140 mr25 mb20">
                                            </div><br />
                                            <%
                                            end if
                                        case 4, 5, 6
                                            if instr(Valor, "|")>0 or (Valor<>"" and isnumeric(Valor)) then
                                                set vals = db.execute("select group_concat(Nome SEPARATOR '; ') Valor from buiopcoescampos where id IN("& replace(Valor, "|", "") &")")
                                                if not vals.eof then
                                                    Valor = vals("Valor")
                                                    response.Write( Rotulo & Valor  &"<br>" )
                                                end if
                                            end if
                                        case 9
                                            %>
                                            <table class="table table-condensed table-bordered">
                                                <thead>
                                                    <tr class="info">
                                                        <%
                                                        Largura = ccur(pcampos("Largura"))
                                                        cLarg = 0
                                                        set pTit = db.execute("select * from buitabelastitulos where CampoID="& pcampos("id"))
                                                        while cLarg<Largura
                                                            cLarg = cLarg + 1
                                                            %>
                                                            <th><%= pTit("c"& cLarg) %></th>
                                                            <%
                                                        wend
                                                        %>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <%
                                                    set regTab = db.execute("select * from buitabelasvalores where CampoID="& pCampos("id")&" and FormPreenchidoID="& ti("id"))
                                                    while not regTab.eof
                                                    %>
                                                    <tr>
                                                        <%
                                                        cLarg = 0
                                                        while cLarg<Largura
                                                            cLarg = cLarg + 1
                                                            %>
                                                            <td><%= regTab("c"& cLarg) %></td>
                                                            <%
                                                        wend
                                                        %>
                                                    </tr>
                                                    <%
                                                    regTab.movenext
                                                    wend
                                                    regTab.close
                                                    set regTab = nothing
                                                    %>
                                                </tbody>
                                            </table>
                                            <%
                                        case else
                                            if Valor<>"" and Valor<>"<p><br></p>" then
                                               if left(Valor, 5)="{\rtf" then
                                                    call limpa("_"&ti("Modelo"), pcampos("id"), reg("id"))
                                                    
                                               end if
                                               response.Write( Rotulo & Valor  &"<br>" )
                                            end if
                                    end select
                                    'response.Write( Rotulo & Valor  &"<br>[["& pcampos("TipoCampoID") &"]]" )
                                pcampos.movenext
                                wend
                                pcampos.close
                                set pcampos=nothing
                             end if
                    response.Write("</small>")
                    case "Pedido"
                        set ProcedimentosPedidoSQL = db.execute("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&ti("id"))
                        %>
                        <ul>
                        <%
                        while not ProcedimentosPedidoSQL.eof
                            Obs = ProcedimentosPedidoSQL("Observacoes")

                            if Obs<>""  then
                                Obs = " - "& Obs
                            end if
                            %>
                            <li><%=ProcedimentosPedidoSQL("NomeProcedimento")%><%=Obs%></li>
                            <%
                        ProcedimentosPedidoSQL.movenext
                        wend
                        ProcedimentosPedidoSQL.close
                        set ProcedimentosPedidoSQL = nothing
                        %>
                        </ul>
                        <%
                        response.Write("<small>" & ti("Conteudo") & "</small>")
                    case "Diagnostico", "Prescricao", "Atestado"
                        response.Write("<small>" & ti("Conteudo") & "</small>")
                    case "PedidosSADT"
                        set psadt = db.execute("select tproc.descricao from pedidossadtprocedimentos pps LEFT JOIN cliniccentral.procedimentos tproc ON tproc.tipoTabela=pps.TabelaID AND pps.CodigoProcedimento=tproc.Codigo where pps.PedidoID="& ti("id"))
                        while not psadt.eof
                            %>
                            <%= psadt("Descricao") %><br />
                            <%
                        psadt.movenext
                        wend
                        psadt.close
                        set psadt = nothing
                        %>
                        <br />
                        <em><%= ti("Conteudo") %></em>
                        <%
                    case "ImagensXXXXXXXXXXXXXX"
                        %>
                    <div class="row">
                        <%
                            set im = db.execute("select * from arquivos where date(DataHora)="&mydatenull(ti("DataHora"))&" AND Tipo='I' AND PacienteID="&PacienteID)
                            while not im.eof
                             %>
                      <span>
                        <a class="gallery-item" href="./../feegowclinic/uploads/<%=im("NomeArquivo") %>"><img style="height:100px" src="./../feegowclinic/uploads/<%=im("NomeArquivo") %>" class="img-thumbnail" title="<%=im("Descricao") %>" alt="<%=im("Descricao") %>">
                        </a>
                      </span>
                        <%
                            im.movenext
                            wend
                            im.close
                            set im=nothing
                             %>
                    </div>
                        <%
                    case "Arquivos"
                            %>
                       <div class="row">
                         <%
                            set im = db.execute("select * from arquivos where date(DataHora)="&mydatenull(ti("DataHora"))&" AND Tipo='A' AND PacienteID="&PacienteID)
                            while not im.eof
                             %>
                             <div class="col-xs-2">
                                <div class="panel-tile text-center br-a br-light">
                                    <div class="panel-body bg-light dark">
                                        <a href="uploads/<%=im("NomeArquivo") %>" target="_blank">
                                            <h1 class="fs35 mbn"><i class="fa fa-download"></i></h1>
                                        </a>
                                    </div>
                                    <div class="panel-footer bg-white br-t br-light p12">
                                        <span class="fs11">
                                            <%=im("Descricao") %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        <%
                            im.movenext
                            wend
                            im.close
                            set im=nothing
                             %>
                        </div>
                        <%
                end select
                %>
                    </div>
                </div>
            </div>
            <%
                end if
              ti.movenext
              wend
              ti.close
              set ti=nothing

                  if c>0 then
                    response.Write("</div></div>             <div class=""timeline-divider"">            <div class=""divider-label"">"&Ano&"</div>          </div>")
                  end if
              %>
        </div>


    </div>

</div>


<script type="text/javascript">
    $('[data-toggle="tooltip"]').tooltip();
    function iPront(t, p, m, i, a) {
        $("#modal-form .panel").html("<center><i class='fa fa-2x fa-circle-o-notch fa-spin'></i></center>");
        if(t=='AE'||t=='L'){
            mfpform('#modal-form');
        }else{
            mfp('#modal-form');
        }
        $.get("iPront.asp?t=" + t + "&p=" + p + "&m=" + m + "&i=" + i  + "&a=" + a, function (data) {
            $("#modal-form .panel").html(data);
        })
    }

function sendWorklist(ProcedimentoID, FormID){
    $.get("../feegow_components/diagnext/newworklist", {
        p:ProcedimentoID, i:FormID, u:<%=session("UnidadeID")%>, user:<%=session("User")%>
    });
}
</script>