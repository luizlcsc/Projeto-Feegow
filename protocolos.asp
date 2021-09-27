<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->


<style>
    #formProtocolos .panel-heading{
        position: sticky;
        top: 12%;
        z-index: 3;
    }
</style>

<br />

<%
tableName = "protocolos"
I = req("I")
if I="N" then
	sqlVie = "select * from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive) values ("&session("User")&", 0)")
		set vie = db.execute(sqlVie)
	end if
    response.Redirect("./?P=Protocolos&I="&vie("id")&"&Pers=1")
else
	set data = db.execute("select * from "&tableName&" where id="&I)
	if data.eof then
        response.Redirect("./?P=Protocolos&I="&req("I")&"&Pers=1")
	end if
end if

if req("I")<>"N" then
    set getProtocolo = db.execute("SELECT * FROM protocolos WHERE id="&treatvalzero(req("I")))
    if not getProtocolo.eof then
        ProtocoloID = getProtocolo("id")
        NomeProtocolo = getProtocolo("NomeProtocolo")
        GrupoID = getProtocolo("GrupoID")
        Procedimentos = getProtocolo("Procedimentos")
        Referencia = getProtocolo("Referencia")
        NCiclos = getProtocolo("NCiclos")
        AUC = getProtocolo("AUC")
        Marcacao = getProtocolo("Marcacao")
        MaxDias = getProtocolo("MaxDias")
        Periodicidade = getProtocolo("Periodicidade")
        Duracao = getProtocolo("Duracao")
        Ativo = getProtocolo("Ativo")
    end if
end if


sqlBloquear = "select count(id)as qtd from pacientesprotocolosmedicamentos where ProtocoloID = "&ProtocoloID&" and sysActive = 1"
bloquear = db.execute(sqlBloquear)

if CInt(bloquear("qtd")) > 0 then
    bloquear = 1
else
    bloquear = 0
end if


%>

<form method="post" id="formProtocolos" name="formProtocolos">

    <input type="hidden" id="idProtocolo" name="I" value="<%=req("I")%>" />

    <div class="tabbable panel">
        <div class="tab-content panel-body">
            <div id="divCadastroProtocolo" class="tab-pane in active">
                <div class="col-md-12">
                <%=quickField("text", "NomeProtocolo", "Nome <code>#"&ProtocoloID&"</code>", 3, NomeProtocolo, "", "", "required")%>
                <%=quickfield("simpleSelect", "Procedimentos", "Procedimentos", 3, Procedimentos, "select id, NomeProcedimento from procedimentos where sysActive=1 and ativo='on' order by NomeProcedimento", "NomeProcedimento", "empty required") %>
                <%=quickField("simpleSelect", "GrupoID", "Grupo", 2, GrupoID, "select * from protocolosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", "")%>
                    <div class="col-md-1">
                        <label>
                            Ativo
                            <div class="switch round mt10">
                                <input type="checkbox" <% If Ativo="on" or isnull(Ativo) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo">
                                <label for="Ativo">Label</label>
                            </div>
                        </label>
                    </div>
                    <div class="col-md-1">
                        <button type="button" id="travar" class="btn btn-warning btn-block mt20" onClick="RegraProtocolo('<%=I%>')"><i class="far fa-lock"></i></button>
                    </div>
                    <div class="col-md-2" title="Este protocolo está em uso e não pode ser alterado" >
                        <button id='salvar' type="submit" class="btn btn-primary btn-block mt20"><i class="far fa-save"></i> Salvar</button>
                    </div>
                </div>
                <div class="col-md-12 mt10">
                <%=quickField("text", "Referencia", "Ref. Bibliográfica", 2, Referencia, "", "", "")%>
                <%=quickField("number", "NCiclos", "Nº Ciclos", 1, NCiclos, "text-right", "", "min=""1"" required") %>
                <%=quickField("text", "AUC", "AUC", 1, AUC, "input-mask-brl text-right", "", " placeholder=""0,00"" ")%>
                <%=quickField("number", "Marcacao", "Máx. agendam. p/ dia", 2, Marcacao, "text-right ", "", "") %>
                <%=quickField("number", "MaxDias", "Máx. dias Ciclo", 2, MaxDias, "text-right", "", "min=""1"" required") %>
                <%=quickField("number", "Periodicidade", "Periodicidade", 2, Periodicidade, "text-right", "", "min=""1"" required") %>
                <%=quickField("number", "Duracao", "Duração do Tratamento", 2, Duracao, " text-right ", "", "") %>
                </div>
            </div>
        </div>


        <div class="panel-heading">
            <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab">
                <li class="active">
                    <a data-toggle="tab" href="#Medicamentos" id="Medicamentos">
                        <i class="far fa-flask bigger-110"></i> Medicamentos
                    </a>
                </li>

                <li>
                    <a data-toggle="tab" href="#Kits" id="Kits">
                        <i class="far fa-medkit bigger-110"></i> Kits
                    </a>
                </li>
                <li>
                    <a data-toggle="tab" href="#Documentos" id="Documentos">
                        <i class="far fa-file bigger-110"></i> Documentos
                    </a>
                </li>
                <div style="float: right">
                    <button type="button" id="btnMedicamentos" class="btn btn-primary btn-sm m10" name="TipoBotao" onclick="addMedicamentos('<%=I%>')" value="Medicamentos">
                        <i class="far fa-plus"></i> Adicionar Medicamentos
                    </button>
                    <button type="button" id="btnKits" class="btn btn-primary btn-sm m10 hidden" name="TipoBotao" onclick="addKits('<%=I%>')" value="Kits">
                        <i class="far fa-plus"></i> Adicionar Kits
                    </button>
                    <button type="button" id="btnDocumentos" class="btn btn-primary btn-sm m10 hidden" name="TipoBotao" onclick="addDocumentos('<%=I%>')" value="Documentos">
                        <i class="far fa-plus"></i> Documentos
                    </button>
                </div>
            </ul>
        </div>

        <div class="panel-body">
            <div class="tab-content pn br-n">
                <div id="ProtocolosMedicamentosTabela" class="tab-pane active">
                    <%server.Execute("ProtocolosMedicamentosTabela.asp")%>
                </div>


                <div id="ProtocolosKitsTabela" class="tab-pane">
                    <%server.Execute("ProtocolosKitsTabela.asp")%>
                </div>

                <div id="ProtocolosDocumentos" class="tab-pane">
                    <%server.Execute("ProtocolosDocumentos.asp")%>
                </div>
            </div>
        </div>
    </div>
</form>

<script type="text/javascript">
    $("#Medicamentos").on("click", function (){
       $("#btnDocumentos").addClass("hidden");
       $("#btnKits").addClass("hidden");
       $("#btnMedicamentos").removeClass("hidden");

       $("#ProtocolosKitsTabela").removeClass("active");
       $("#ProtocolosDocumentos").removeClass("active");
       $("#ProtocolosMedicamentosTabela").addClass("active");

    });
    $("#Kits").on("click", function (){
       $("#btnMedicamentos").addClass("hidden");
       $("#btnDocumentos").addClass("hidden");
       $("#btnKits").removeClass("hidden");

       $("#ProtocolosMedicamentosTabela").removeClass("active");
       $("#ProtocolosDocumentos").removeClass("active");
       $("#ProtocolosKitsTabela").addClass("active");
    });
    $("#Documentos").on("click", function (){
       $("#btnMedicamentos").addClass("hidden");
       $("#btnKits").addClass("hidden");
       $("#btnDocumentos").removeClass("hidden");

       $("#ProtocolosMedicamentosTabela").removeClass("active");
       $("#ProtocolosKitsTabela").removeClass("active");
       $("#ProtocolosDocumentos").addClass("active");

       getDocumentos('<%=req("I")%>')
       block()
    });

    $('#formProtocolos').on('submit', function(e){
        e.preventDefault();

        var id = $('#idProtocolo').val()

        $.post("saveProtocolo.asp?I=" + id, $("#formProtocolos").serialize(), function(data){
            eval(data);
        }); 
    });

    function RegraProtocolo(ID) {
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
        $.post("protocolosregras.asp?I="+ID, function (data) {
            $("#modal").html(data);

        });
        $("#modal").addClass("modal-lg");

    }
    function addMedicamentos(ID){
    	$.post("ProtocolosMedicamentosTabela.asp?Tipo=I&I="+ID, $("#formProtocolos").serialize(), function(data, status){$("#ProtocolosMedicamentosTabela").html(data);});
    }
    function addKits(ID){
    	$.post("ProtocolosKitsTabela.asp?Tipo=I&I="+ID, $("#formProtocolos").serialize(), function(data, status){$("#ProtocolosKitsTabela").html(data);});
    }
    function copiarProtocolo(ID) {
        $.post("ProtocoloDuplicar.asp?I="+ID,  function(data){
            eval(data);
        });
    }
</script>

<script type="text/javascript">
    let bloquear = '<%=bloquear%>';
    block()
    function block(){
        if(bloquear == 1){
            $('#formProtocolos #salvar').attr('disabled',true)
            $('#formProtocolos #salvar').parent().attr('data-toggle',"tooltip")
            $('#formProtocolos #salvar').parent().attr('data-placement',"top")
            $('[data-toggle="tooltip"]').tooltip()
            $('#formProtocolos input').attr('disabled',true)
            $('#formProtocolos button[id!="travar"]').attr('disabled',true)
            $('#Ativo').attr('disabled',false)
            setTimeout(() => {
                $('#formProtocolos .select2').css('pointer-events',"none")
                $('#formProtocolos .multiselect').css('pointer-events',"none")
                $('#formProtocolos .multiselect').css('background-color',"#fafafa")
                $('#formProtocolos .select2-selection').css('background-color','#fafafa')
                $('select').attr('disabled',true)
            }, 200);
            $('#Ativo').click(event=>{
                let valor = (($('#Ativo').prop('checked'))?'on':'off')

                $.post(`saveProtocolo.asp?I=<%=I%>&soAtivo=${valor}`, function(data){
                    eval(data);
                });
            })
        }
    }

    $(".crumb-active").html("<a href='#'>Cadastro de Protocolo</a>");
    $(".crumb-icon a span").attr("class", "far fa-th-list");
    $(".crumb-trail").removeClass("hidden");
    $("#rbtns").html("<div class='topbar-right'><button class='btn btn-sm btn-alert' onclick='copiarProtocolo(<%=I%>)'><i class='far fa-files-o'></i> COPIAR</button> <a class='btn btn-sm btn-success' href='./?P=Protocolos&I=N&Pers=1'><i class='far fa-plus'></i> INSERIR</a></div>");
</script>