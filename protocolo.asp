<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<%
PacienteID = req("p")
ModeloID = req("m")
FormID = req("i")
if FormID="N" then
    set vca = db.execute("select id from buiformspreenchidos where ModeloID="& ModeloID &" AND PacienteID="& PacienteID &" AND sysActive=0 AND sysUser="& session("User"))
    if vca.eof then
        db.execute("insert into buiformspreenchidos set ModeloID="& ModeloID &", PacienteID="& PacienteID &", sysUser="& session("User") &", sysActive=0")
        set vca = db.execute("select id from buiformspreenchidos where sysUser="& session("User") &" AND PacienteID="& PacienteID &" AND sysActive=0 AND ModeloID="& ModeloID &" ORDER BY id DESC LIMIT 1")
        db.execute("INSERT INTO `_"& ModeloID &"` SET id="& vca("id") &", PacienteID="& PacienteID &", sysUser="& session("User"))
    else
        db.execute("UPDATE `buiformspreenchidos` SET DataHora=NOW() WHERE id="& vca("id"))
        db.execute("UPDATE  _"& ModeloID &" SET DataHora=NOW() WHERE id="& vca("id"))
    end if
    FormID = vca("id")
end if
'response.write( FormID )
set pTitulo = db.execute("select Nome from buiforms where id='"& ModeloID&"'")
if not pTitulo.eof then
    TituloForm = pTitulo("Nome")
end if
ExibeForm = true
if getConfig("BloquearEdicaoFormulario")=1  then
    set getFormPreenchido = db.execute("SELECT date(DataHora) dataAtendimento FROM buiformspreenchidos WHERE sysActive=1 AND id = "&FormID)
    if not getFormPreenchido.eof then
        dataAtendimento = getFormPreenchido("dataAtendimento")
        if dataAtendimento <> date() then
            ExibeForm = false
            DisabledBotao = " style='pointer-events:none;' "
        end if
    end if
end if
%>
<style>
.btn-xs, .btn-group-xs > .btn {
    padding: 0px 3px;
    margin-bottom: 5px;
    margin-top: 2px;
}

</style>
<script type="text/javascript">
    function sug(CampoID, Origem, Tipo) {
        txt = $("#" + Origem + CampoID).val();
        $.post("protsug.asp?FormID=<%= FormID%>&CampoID=" + CampoID + "&Origem=" + Origem +"&Tipo="+ Tipo +"&Grupo="+ $("#GrupoID"+CampoID).val() +"&Subgrupo=" +$("#SubgrupoID"+CampoID).val() , { T: txt }, function (data) { $("#sugCid" + CampoID).html(data) });
    }

    function protAdd(Tipo, ID, FormID, CampoID) {
        $.get("protocoloAdd.asp?Tipo=" + Tipo + "&ID=" + ID + "&FormID=" + FormID + "&CampoID=" + CampoID +"&PacienteID=<%=PacienteID%>&Termo="+ $("#Cid"+CampoID).val(), function (data) {
            $(".sug").fadeOut();
            eval(data)
        });
    }
    function protList(Tipo, FormID, CampoID, Comm) {
        $.get("protocoloAdd.asp?Tipo=" + Tipo + "&FormID=" + FormID + "&CampoID=" + CampoID +"&PacienteID=<%=PacienteID%>&Comm="+ Comm, function (data) {
            $("#" + Tipo + CampoID).html(data)
        });
    }
</script>
<form id="fEst">
    <div class="row">
        <div class="col-md-10">
            <h2><%= TituloForm %></h2>
        </div>
        <%if ExibeForm then%>
        <div class="col-md-2">
            <button class="btn btn-block btn-md btn-success" type="button" onClick="salvarAtendimento('<%=FormID%>')"><i class="far fa-save"></i> Salvar Atendimento</button>
        </div>
        <%end if%>
    </div>

<div class="panel" <%=DisabledBotao%> >

    <%
set campo = db.execute("select * from buicamposforms where FormID="& ModeloID &" ORDER BY pTop")
set reg = db.execute("select * from `_"& ModeloID &"` WHERE id="& FormID)
while not campo.eof
    Rotulo = campo("RotuloCampo")
    Estruturacao = campo("Estruturacao")&""
    CampoID = campo("id")
    TipoCampoID = campo("TipoCampoID")
    Valor = ""
    Texto = campo("Texto")&""
    if campo("MaxCarac")&"" <> "" then
    input_maxlength = " maxlength='"&campo("MaxCarac")&"' "
    end if
    if campo("TipoCampoID")=1 or campo("TipoCampoID")=4 or campo("TipoCampoID")=5 or campo("TipoCampoID")=8 then
        if not reg.eof then
            Valor = reg(""& campo("id") &"")
        end if
    end if
    cols = 12

    if TipoCampoAnterior<>1 and TipoCampoAnterior<>2 and TipoCampoID=1 then
        response.write("<div class=""panel-body tipotexto"">")
    end if
    if TipoCampoAnterior=1 and TipoCampoID<>1  and TipoCampoID<>2 then
        response.write("</div>")
    end if


    select case campo("TipoCampoID")
        case 1'TEXTO SIMPLES
        %>
            <div class="col-md-4" style="position: relative; z-index:1">
                <span><b><%= campo("RotuloCampo") %></b></span>
                <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                <%= quickfield("text", "Campo"& campo("id"), "", 4, Valor, " prot campoInput ", "", input_maxlength)%>
            </div>
        <%
        case 2'DATA
        %>
            <div class="col-md-6">
                <span><b><%= campo("RotuloCampo") %></b></span>
                <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                <%= quickfield("datepicker", "Campo"& campo("id"), "", 4, Valor, " prot campoInput ", "", "")%>
            </div>
        <%
        case 4'CHECKBOX
            %>
            <div class="panel-body">
                <div class="col-md-12">
                    <span><b><%= Rotulo %></b></span>
                    <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                </div>
                <div class="row">
                    <%
                    set op = db.execute("select * from buiopcoescampos where CampoID="& CampoID)
                    while not op.eof
                        %>
                        <div class="col-xs-3 pt10">
                            <span class="checkbox-custom"><input type="checkbox" id="chk<%= CampoID &"_"& op("id") %>" name="<%= "Campo"& CampoID %>" value="|<%= op("id") %>|" <% if instr(Valor, "|"& op("id") &"|") then response.write(" checked ") end if %> onchange="saveProt(0)" /><label for="chk<%= CampoID &"_"& op("id") %>"> <%= op("Nome") %></label></span>
                        </div>
                        <% if instr(Rotulo, "Vacina")>0 then %>
                            <div class="col-xs-2"><input type="date" class="form-control" /></div>
                            <div class="col-xs-1"><input type="text" class="form-control" placeholder="Doses" /></div>
                        <%
                        end if
                    op.movenext
                    wend
                    op.close
                    set op = nothing
                        %>
                </div>
                <% if instr(Estruturacao, "Tag")>0 then %>
                <hr class="short alt hidden" />
                <center class="hidden">
                    <button type="button" class="btn btn-default" onclick="prompt('Texto')"><i class=" far fa-plus"></i> Inserir</button>
                </center>
                <% end if %>
            </div>
            <%
        case 5'RADIO
            %>
            <div class="panel-body">
                <div class="col-md-12">
                    <span><b><%= Rotulo %></b></span>
                    <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                </div>

                <div class="row">
                    <%
                    set cp = db.execute("select * from buicamposforms where id="& CampoID)
                    set op = db.execute("select * from buiopcoescampos where CampoID="& CampoID)
                    while not op.eof
                        %>
                        <div class="col-xs-3 pt10">
                            <span class="radio-custom"><input type="radio" id="chk<%= CampoID &"_"& op("id") %>" name="Campo<%= CampoID %>" value="|<%= op("id") %>|" <% if instr(Valor, "|"& op("id") &"|") then response.write(" checked ") end if %> onchange="saveProt(0)" /><label for="chk<%= CampoID &"_"& op("id") %>"> <%= op("Nome") %></label></span>
                        </div>
                        <%
                    op.movenext
                    wend
                    op.close
                    set op = nothing
                        %>
                </div>
                <% if instr(Estruturacao, "Tag")>0 then %>
                <hr class="short alt" />
                <center>
                    <button type="button" class="btn btn-default" onclick="prompt('Texto')"><i class=" far fa-plus"></i> Inserir</button>
                </center>
                <% end if %>
            </div>
            <%
        case 10'TITULO
            %>
            <div class="panel-heading" <% if Texto <> "" then %> style="height: 90px" <% End If %>>
                <span class="panel-title"><%= Rotulo %></span>
                <p class="panel-title" style="font-size:0.8em"><%= Texto %></p>
                <span class="panel-controls hidden">
                    <button type="button" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-sm btn-default hidden-xs"><i class="far fa-history"></i></button>
                </span>
            </div>
            <%
        case 8'MEMORANDO
'            Valor = reg(""& campo("id") &"")
            if instr(Estruturacao, "|CID|")>0 OR instr(Estruturacao, "|Tags|")>0 then
                cols = 6
            end if
            if instr(Estruturacao, "|CID|")>0 OR instr(Estruturacao, "|Tags|")>0 then
                chamaProtSug = "  onkeyup=""sug("& campo("id") &", 'Campo', 'CidCiap')""  "
            end if
            %>
                <div class="panel-body">
                    <div class="col-md-12">
                        <span><b><%= Rotulo %></b></span>
                        <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                    </div>
                    <div class="col-md-<%= cols %>">
                        <%= quickfield("memo", "Campo"& CampoID, "", 12, Valor, " prot campo-memo-protocolo", "", " rows=4 "& chamaProtSug &"") %>
                    </div>
                    <%
                    if instr(Estruturacao, "|CID|")>0 OR instr(Estruturacao, "|Tags|")>0 then
                        %>
                        <div class="col-md-6">
                            <%= quickfield("text", "Cid"& campo("id"), "", 12, "", "", "", " placeholder='Buscar...' autocomplete='off'  onkeyup=""sug("& campo("id") &", 'Cid', 'CidCiap')"" ") %>
                            <div id="sugCid<%= campo("id") %>" class="p10 panel panel-body sug" style="width:500px; height:400px; position:absolute; z-index:10000; display:none; overflow:auto; cursor:pointer">
                            </div>
                            <script type="text/javascript">
                                protList('ciapList', <%= FormID %>, <%= CampoID %>, '');
                            </script>
                        </div>
                        <%
                    end if
                    %>
                    <div class="col-md-12" id="ciapList<%= CampoID %>"></div>
                </div>
            <%
        case 9'TABELA

            if instr(Rotulo, "::") then
                splRotulo = split(Rotulo, "::")
                Aba = splRotulo(0)
                if instr(nomesTabelas, "|"& Aba &"::")=0 then'primeira ocorrencia
                    %>
                    <div class="panel">
                        <div class="panel-heading">
                            <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="vacinas">
                                <li id="v1" class="active"><a data-toggle="tab" href="#dadosv1">Gestante</a></li>
                                <li id="v2"><a data-toggle="tab" href="#dadosv2">Criança</a></li>
                                <li id="v3"><a data-toggle="tab" href="#dadosv3">Adulto</a></li>
                                <li id="v4"><a data-toggle="tab" href="#dadosv4">Idoso</a></li>
                            </ul>
                        </div>
                        <div class="panel-body">
                            <div class="tab-content">
                                <div id="dadosv1" class="tab-pane in active" style="overflow:scroll">
                <%
                elseif Rotulo="VACINAS:: Criança" then
                %>
                                </div>
                                <div id="dadosv2" class="tab-pane" style="overflow:scroll">
                <%
                elseif Rotulo="VACINAS:: Adulto" then %>
                                </div>
                                <div id="dadosv3" class="tab-pane" style="overflow:scroll">
                <%
                elseif Rotulo="VACINAS:: Idoso" then %>
                                </div>
                                <div id="dadosv4" class="tab-pane" style="overflow:scroll">
                <%
                end if %>

                    <%
            end if

            nomesTabelas = nomesTabelas &"|"& Rotulo

            'response.Write( nomesTabelas )

            %>

                    <table class="table table-condensed table-bordered table-hover">
                        <thead>
                            <tr class="info">
                            <%
                            set tt = db.execute("select * from buitabelastitulos where CampoID="& CampoID)
                            while not tt.eof
                                ct = 0
                                colunas = 0
                                while ct<20
                                    ct = ct+1
                                    TituloT = tt("c"&ct&"")
                                    if TituloT<>"" then
                                        colunas = colunas+1
                                        %>
                                        <th><%= TituloT %></th>
                                        <%
                                    end if
                                wend
                            tt.movenext
                            wend
                            tt.close
                            set tt = nothing

                            set tm = db.execute("select * from buitabelasmodelos where CampoID="& CampoID)
                            set tt = db.execute("select * from buitabelastitulos where CampoID="& CampoID)
                            while not tm.eof
                                %>
                                <tr>
                                    <%
                                    cm = 0
                                    while cm<colunas
                                        cm = cm+1
                                        %>
                                        <td style="min-width:150px"><%
                                            if tm("c"& cm &"")<>"" then
                                                response.write( tm("c"& cm &"") )
                                            else
                                                if tt("tp"& cm )="datepicker" then
                                                    %>
                                                    <input type="date" class="form-control" />
                                                    <%
                                                elseif tt("tp"& cm )="select" then
                                                    call quickfield("simpleSelect", "", "", 12, "", "select 'Não lembra' id, 'Não lembra' nome UNION SELECT 'Não tomou', 'Não tomou' UNION SELECT 'Referida', 'Referida' UNION SELECT 'Confirmada', 'Confirmada'", "nome", "")
                                                end if
                                            end if
                                            %></td>
                                        <%
                                    wend
                                    %>
                                </tr>
                                <%
                            tm.movenext
                            wend
                            tm.close
                            set tm = nothing
                            %>
                            </tr>
                        </thead>
                    </table>
                <% if Rotulo="VACINAS:: Idoso" then %>
                                </div>
                            </div>
                        </div>
                    </div>
                <% end if %>

            <%

        case 19'PRESCRIÇÃO
            %>
            <div class="panel-body">
                <div class="col-md-12">
                    <span><b><%= Rotulo %></b></span>
                    <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                </div>
                <div class="col-md-10">
                    <%= quickfield("text", "Campo"& CampoID, "", 12, Valor, " prot ", "", " rows=4 onkeyup=""sug("& campo("id") &", 'Campo', 'Medicamento')"" placeholder='Adicionar medicamento' onfocus=""$(this).select()"" ") %>
                    <div id="sugCid<%= campo("id") %>" class="p10 panel panel-body sug" style="width:500px; height:400px; position:absolute; z-index:10000; display:none; overflow:auto; cursor:pointer">
                    </div>
                    <script type="text/javascript">
                        protList('prescList', <%= FormID %>, <%= CampoID %>, '');
                    </script>
                </div>
                <div class="col-md-1">
                    <button type="button" class="btn btn-block btn-dark dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                        <i class="far fa-list"></i>
                        <span class="caret ml5"></span>
                    </button>
                    <ul class="dropdown-menu disabled" role="menu">
                        <li><a href="javascript:"><i class="far fa-plus"></i> Criar Modelos</a></li>
                    </ul>
                </div>
                <div class="col-md-1">
                    <button type="button" class="btn btn-block btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                        <i class="far fa-print"></i>
                        <span class="caret ml5"></span>
                    </button>
                    <ul class="dropdown-menu disabled" role="menu">
                        <li><a href="javascript:printCampo('prescricao', '<%= CampoID %>', '')"><i class="far fa-angle-right"></i> Padrão</a></li>
                        <li><a href="javascript:printCampo('prescricaoEspecial', '<%= CampoID %>', '')"><i class="far fa-angle-right"></i> Controle especial</a></li>
                    </ul>
                </div>

                <div class="col-md-1 hidden"><button type="button" onClick="printCampo('prescricao', '<%= CampoID %>', '')" class="btn btn-primary btn-block"><i class="far fa-print"></i></button></div>
                <div class="col-md-12" id="prescList<%= CampoID %>"></div>
            </div>
            <%
        case 20'PEDIDOS
            %>
                <div class="panel-body">
                    <div class="col-md-12">
                        <span><b><%= Rotulo %></b></span>
                        <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                    </div>
                        <%'= quickfield("simpleSelect", "GrupoID"&CampoID, "Grupo", 2, "", "SELECT trim(grupo) id, trim(grupo) grupo FROM cliniccentral.tusscorrelacao WHERE grupo NOT LIKE '' GROUP BY grupo ORDER BY trim(grupo)", "grupo", " onchange='opsub($(this).val(), "& CampoID &")' ") %>

                        <%'= quickfield("simpleSelect", "SubgrupoID"&CampoID, "Subgrupo", 2, "", "SELECT trim(subgrupo) id, trim(subgrupo) subgrupo FROM cliniccentral.tusscorrelacao WHERE subgrupo NOT LIKE '' GROUP BY subgrupo ORDER BY trim(subgrupo)", "subgrupo", " onchange=""sug("& CampoID &", 'Campo', 'Pedido')"" ") %>


                        <%'= quickfield("text", "Campo"& CampoID, "Buscar na TUSS", 5, Valor, " prot ", "", " rows=4 onkeyup=""sug("& campo("id") &", 'Campo', 'Pedido')"" placeholder='Buscar...' onfocus=""$(this).select()"" ") %>
                        <script type="text/javascript">
                            protList('pedList', <%= FormID %>, <%= CampoID %>, '');
                        </script>
                    <div class="col-md-10">
                        <label>Buscar na TUSS</label>
                        <input type="text" class="form-control  prot " name="Campo<%= CampoID %>" id="Campo<%= CampoID %>" value="" rows="4" onkeyup="sug(<%= CampoID %>, 'Campo', 'Pedido')" placeholder="Buscar..." onfocus="$(this).select()">

                        <div id="sugCid<%= campo("id") %>" class="p10 panel panel-body sug" style="width:500px; height:400px; position:absolute; z-index:10000; display:none; overflow:auto; cursor:pointer">
                        </div>
                    </div>
                    <div class="col-md-1 pt25">
                        <button type="button" class="btn btn-block btn-dark dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                            <i class="far fa-list"></i>
                            <span class="caret ml5"></span>
                        </button>
                        <ul class="dropdown-menu disabled" role="menu">
                        <%
                        if lcase(session("Table"))="profissionais" then
                            sqlPacotes = "SELECT pp.* "&_
                                         "FROM  pacotesprontuarios pp "&_
                                         "LEFT JOIN (  "&_
                                         "    select EspecialidadeID from profissionais   "&_
                                         "    where id="&session("idInTable")&" and not isnull(EspecialidadeID)   "&_
                                         "    union all "&_
                                         "    select EspecialidadeID from profissionaisespecialidades "&_
                                         "    where profissionalID="&session("idInTable")&" and not isnull(EspecialidadeID) "&_
                                         ") esp ON pp.especialidades like CONCAT('%|', esp.EspecialidadeID, '|%') "&_
                                         "WHERE (esp.EspecialidadeID IS NOT NULL OR pp.Especialidades='')  and (pp.Profissionais like '%|"&session("idInTable")&"|%' or pp.Profissionais = '' or pp.Profissionais is null) "&_
                                         "AND pp.sysActive = 1  "&_
                                         "AND pp.tipo = 'pedidoexame' OR pp.tipo= 'pedidosadt' "&_
                                         "AND pp.Nome like '%"&Filtro&"%' "&_
                                         "GROUP BY pp.id"
                            set pacotes = db.execute(sqlPacotes)
                            while not pacotes.EOF


                                sqlItensPacotes = "SELECT * FROM  pacotesprontuariositens WHERE PacoteID = "&pacotes("id")
                                set itemPacotes = db.execute(sqlItensPacotes)

                            %>
                            <li id="NomePedido"><a href="javascript:"><i class="far fa-angle-right"></i> <%=pacotes("Nome")%></a></li>


                            <%
                            pacotes.movenext
                            wend
                            pacotes.close
                            set pacotes = nothing

                        end if
                        %>
                            <li><a href="javascript: modalPastas('', 'Lista');"><i class="far fa-plus"></i> Criar Modelo</a></li>
                        </ul>
                    </div>
                    <div class="col-md-1 pt25"><button type="button" onClick="printCampo('pedido', '<%= CampoID %>', '')" class="btn btn-primary btn-block"><i class="far fa-print"></i></button></div>
                    <div class="col-md-12" id="pedList<%= CampoID %>"></div>
                </div>
            <%
        case 21'ATESTADOS
            %>
                <div class="panel-body">
                    <div class="col-md-12">
                       <span><b><%= Rotulo %></b></span>
                       <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                    </div>
                    <div class="row">
                        <%= quickfield("simpleSelect", "Atestado"& CampoID, "Novo atestado", 10, "", "select id, NomeAtestado from pacientesatestadostextos where sysActive=1 order by NomeAtestado", "NomeAtestado", " onchange='protAdd(""atesAdd"", $(this).val(), "&FormID&", "&CampoID&")' ") %>
                        <div class="col-xs-1" hidden><button type="button" class="btn btn-info mt25 btn-block"><i class="far fa-eye"></i></button></div>
                        <div class="col-xs-1" hidden><button type="button" onClick="printCampo('atestado', '<%= CampoID %>', '')" class="btn btn-primary mt25 btn-block"><i class="far fa-print"></i></button></div>
                    </div>
                    <div class="col-md-12" id="atesList<%= CampoID %>"></div>
                    <script type="text/javascript">
                        protList('atesList', <%= FormID %>, <%= CampoID %>, '');
                    </script>
                </div>
            <%
        case 23'ENCAMINHAMENTO
            %>
                <div class="panel-body">
                    <div class="col-md-12">
                       <span><b><%= Rotulo %></b></span>
                       <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <button type="button" class="btn btn-primary" onclick="protAdd('encAdd', <%= "'Especialista', "& FormID &", "& CampoID %>)"><i class="far fa-plus"></i> ESPECIALISTA</button>
                            <button type="button" class="btn btn-primary" onclick="protAdd('encAdd', <%= "'Equipe Multidisciplinar', "& FormID &", "& CampoID %>)"><i class="far fa-plus"></i> EQUIPE MULTIDISCIPLINAR</button>
                            <button type="button" class="btn btn-primary" onclick="protAdd('encAdd', <%= "'Pronto-Socorro', "& FormID &", "& CampoID %>)"><i class="far fa-plus"></i> PRONTO-SOCORRO</button>
                        </div>
                    </div>
                    <div class="col-md-12" id="encList<%= CampoID %>"></div>
                </div>
                <script type="text/javascript">
                    protList('encList', <%= FormID %>, <%= CampoID %>, '');
                </script>
            <%
        case 24'CARTEIRA DE VACINAÇÃO
                    %>
                    <div class="panel">
                        <div class="panel-heading">
                            <span class="panel-title"> <%= Rotulo %></span>
                            <button type="button" id="LogCampo<%=CampoID%>" title="Histórico" onClick="logCampo(<%=CampoID%>, <%=campo("TipoCampoID")%>)" class="btn btn-xs btn-default logCampo hidden-xs"><i class="far fa-history"></i></button>
                        </div>
                        <div class="panel-heading">
                            <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="vacinas<%= CampoID %>">
                                <%
                                splEst = split( replace(Estruturacao, "|", ""), ", ")
                                cEst = 0
                                for i=0 to ubound( splEst )
                                    cEst = cEst+1
                                    %>
                                    <li id="v<%= cEst %>" <% if cEst=1 then response.write(" class=""active"" ") end if %> ><a data-toggle="tab" href="#dadosv<%= cEst %>"><%= splEst(i) %></a></li>
                                    <%
                                next
                                %>
                            </ul>
                        </div>
                        <div class="panel-body">
                            <div class="tab-content">
                                <%
                                splEst = split( replace(Estruturacao, "|", ""), ", ")
                                cEst = 0
                                for j=0 to ubound( splEst )
                                    cEst = cEst+1
                                    'if ct=1 then
                                        expansor = "<button type='button' onclick=""$('.descricao').fadeToggle()"" class='btn btn-xs btn-info pull-right' title='mais informações'><i class='far fa-chevron-right'></i></button>"
                                    'else
                                    '    expansor = ""
                                    'end if
                                    %>
                                    <div id="dadosv<%= cEst %>" class="tab-pane in <% if cEst=1 then response.write(" active ") end if %> " style="overflow:scroll; height:300px; font-size:12px">
                                        <table class="table table-condensed table-bordered table-hover">
                                            <thead>
                                                <tr class="info">
                                                    <th>VACINAS <%= expansor %></th>
                                                    <th style="display:none" class="descricao">DESCRIÇÃO</th>
                                                    <%
                                                    set tt = db.execute("select * from buicvtitulo where Carteira='"& splEst(j) &"'")
                                                    while not tt.eof
                                                        ct = 5
                                                        colunas = 0
                                                        while ct<20
                                                            ct = ct+1
                                                            TituloT = tt("c"&ct&"")
                                                            if TituloT<>"" then
                                                                colunas = colunas+1
                                                                %>
                                                                <th><%= TituloT %></th>
                                                                <%
                                                            end if
                                                        wend
                                                    tt.movenext
                                                    wend
                                                    tt.close
                                                    set tt = nothing
                                                                   'response.write(colunas)

                                                    set tm = db.execute("select * from buicvmodelos where Carteira='"& splEst(j) &"' order by id")
                                                    set tt = db.execute("select * from buicvtitulo where Carteira='"& splEst(j) &"'")
                                                    while not tm.eof
                                                        %>
                                                    <tr>
                                                        <th><%= tm("vacinas") %></th>
                                                        <%
                                                        descricao = ""
                                                        set des = db.execute("select * from buicvass where Carteira='"& splEst(j) &"'")
                                                        while not des.eof
                                                            'response.write(des("coluna")&"...")
                                                            valor = tm(""&des("coluna")&"")
                                                            if valor="SIM" then
                                                                valor = "<span class='label label-success'>SIM</span>"
                                                            elseif valor="NÃO" then
                                                                valor = "<span class='label label-danger'>NÃO</span>"
                                                            end if
                                                            descricao = descricao & des("Rotulo") &": <b>"& valor &"</b><br>"
                                                        des.movenext
                                                        wend
                                                        des.close
                                                        set des = nothing
                                                        %>
                                                        <td style="display:none" class="descricao"><%= descricao %></td>
                                                        <%


                                                        cm = 5
                                                        while cm<colunas+5
                                                            cm = cm+1
                                                            if cm=1 or cm=2 then
                                                                larguraCol = "min-width:150px"
                                                            else
                                                                larguraCol = "max-width:120px"
                                                            end if
                                                            %>
                                                            <td class="p5" style="<%= larguraCol %>"><%
                                                                if tm("c"& cm &"")<>"" then
                                                                    if cm=2 then
                                                                        response.Write( descricao )
                                                                    else
                                                                        response.write( tm("c"& cm &"") )
                                                                    end if
                                                                else
                                                                    if tt("tp"& cm )="datepicker" then
                                                                        %>
                                                                        <%= quickfield("text", "cv_"& splEst(j) &"_"& CampoID &"_"& tm("id") &"_"& cm, "", 1, "", " input-mask-date ", "", " onchange=""saveProt('cv', '"& splEst(j) &"', "& tm("id") &", "& CampoID &", "& cm &")"" ") %>
                                                                        <%
                                                                    elseif tt("tp"& cm )="select" then
                                                                        call quickfield("simpleSelect", "cv_"& splEst(j) &"_"& CampoID &"_"& tm("id") &"_"& cm, "", 12, "", "select * from buicvstatus", "Status", " empty no-select2 style="""& larguraCol &"""  onchange=""saveProt('cv', '"& splEst(j) &"', "& tm("id") &", "& CampoID &", "& cm &")"" ")
                                                                    end if
                                                                end if


                                                                %></td>
                                                            <%
                                                        wend
                                                        %>
                                                    </tr>
                                                    <%
                                                tm.movenext
                                                wend
                                                tm.close
                                                set tm = nothing
                                                %>
                                                </tr>
                                            </thead>
                                        </table>
                                    </div>

                                <script type="text/javascript">
                                    <% 
                                        set cv = db.execute("select * from buicvvalores where FormPID=" & FormID & " and CampoID=" & CampoID)
                                        while not cv.eof
                                            %>
                                            $("#cv_<%= cv("Tipo") &"_"& cv("CampoID") &"_"& cv("LinhaID") &"_"& cv("Coluna") %>").val("<%= cv("Valor") %>");
                                            <%
                                        cv.movenext
                                        wend
                                        cv.close
                                        set cv = nothing
                                    %>
                                </script>
                                    <%
                                next
                                %>

                                </div>
                    </div>
                <% 'end if

    end select

    TipoCampoAnterior = campo("TipoCampoID")

campo.movenext
wend
campo.close
set campo = nothing

if TipoCampoID=1 then
    response.write("</div")
end if



%>
</div>
    <%if ExibeForm then%>
    <div class="m15">
        <button class="btn btn-md btn-success" type="button" onClick="salvarAtendimento('<%=FormID%>')"><i class="far fa-save"></i> Salvar Atendimento</button>
    </div>
    <%end if%>
</form>
<hr class="short alt" />

<script type="text/javascript">
<%
set cpFormula = db.execute("select id, Formula from buicamposforms where Formula like '%[%' and FormID=" & ModeloID)
while not cpFormula.eof
    Formula = cpFormula("Formula") & ""
    Formula = replace(replace(Formula, "'", ""), "\", "")
    splCP = split(Formula, "[")
    for i=0 to ubound(splCP)
        if instr(splCP(i), "]")>0 then
            spl2 = split(splCP(i), "]")
            NomeCampo = spl2(0)
            NomesCampos = NomesCampos & ", '"& NomeCampo &"'"
        end if
    next
cpFormula.movenext
wend
cpFormula.close
set cpFormula = nothing
if NomesCampos<>"" then
    NomesCampos = right(NomesCampos, len(NomesCampos) - 2)
    set pids = db.execute("select group_concat( concat('#Campo', id)) inputs from buicamposforms where NomeCampo IN(" & NomesCampos & ") AND FormID=" & ModeloID)
    %>
    $("<%= pids("inputs") %>").on('keyup blur', function () {

        $.post("formCalc.asp?Campo="+ $(this).attr("id"), $(".campoInput, .campoCheck, .tbl").serialize(), function (data) {
            eval(data);
        });
    });
    <%
end if
%>

    function salvarAtendimento(ID){
        $.post("saveProt.asp?FormID="+ID+"&Salvar=1", $("#fEst").serialize(), function (data) { eval(data) });
    }

    function logCampo(CampoId, TipoCampoId){
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.get("logCampoForm.asp?CampoId="+CampoId+"&TipoCampoId="+TipoCampoId+"&FormId=<%=ModeloID%>&PacienteId=<%=PacienteID%>", function (data) {
            $("#modal").html(data);
        });

    }

    function printCampo(Tipo, CampoID, ID){
        if (Tipo == "prescricao"){
           var idCampoPai = "prescList"+CampoID;
           var classCampo = "check-prescricao";
           var url = "savePrescription.asp?Tipo=Form&ControleEspecial=&PacienteID=<%=PacienteID%>";
        }
        if (Tipo == "prescricaoEspecial"){
           var idCampoPai = "prescList"+CampoID;
           var classCampo = "check-prescricao";
           var url = "savePrescription.asp?Tipo=Form&ControleEspecial=S&PacienteID=<%=PacienteID%>";
        }
        if (Tipo == "pedido"){
           var idCampoPai = "pedList"+CampoID;
           var classCampo = "check-pedido";
           var url = "LanctoPedidoSADT.asp?I=0&Tipo=Form&PacienteID=<%=PacienteID%>";

        }

        if (Tipo == "pedido" || Tipo == "prescricao" || Tipo == "prescricaoEspecial"){
            var valoresSelecionados = [];

            $("."+classCampo+":checkbox:checked", "#"+idCampoPai).each(function(){
                 valoresSelecionados.push($(this).val());
            });

            if (valoresSelecionados!=""){
                if (valoresSelecionados){
                    $.get(url+"&Ids="+valoresSelecionados, function(data, status) {
                         if (Tipo == "prescricao" || Tipo == "prescricaoEspecial"){
                             $("#modal").html(data);
                             $("#modal-table").modal('show');
                         }
                         eval(data);
                         if (erro != ""){
                             showMessageDialog(erro, "danger");
                         }else{
                             if (Tipo == "pedido" && status == "success"){
                                 guiaTISS('GuiaSADT', GuiaID);
                                 valoresSelecionados.forEach((el) => {
                                   $("#Chk"+CampoID+"-"+el).addClass("hidden").attr("checked", false);
                                   $("#Guia"+CampoID+"-"+el).removeClass("hidden").attr("href", "./?P=tissguiasadt&Pers=1&I="+GuiaID);
                                   $("#Print"+CampoID+"-"+el).removeClass("hidden").attr("onClick", "guiaTISS('GuiaSADT',"+GuiaID+")");
                                   $("#Delete"+CampoID+"-"+el).attr("disabled");
                                });
                             }
                         }
                     });
                }
            }else{
                alert("Selecione uma opção!");
            }
        }
        if (Tipo == "atestado"){
            $.post("saveAtestado.asp",{
                   PacienteID:'<%=PacienteID%>',
                   save: false,
                   AtestadoId: ID,
                   redirect: false

                   },function(data,status){
                $("#modal").html(data);
                $("#modal-table").modal('show');
            });
        }
        if (Tipo == "encaminhamento"){
            var TipoEncaminhamento = $("#encaminhamento-"+ID).html();
            $.post("modalEncaminhamento.asp",{
                   PacienteID:'<%=PacienteID%>',
                   Tipo: TipoEncaminhamento,
                   EncaminhamentoID: ID,
                   },function(data,status){
                $("#modal").html(data);
                $("#modal-table").modal('show');
            });

        }

    }

    function saveProt(T, TipoCV, LinCV, CampoIDCV, ColCV) {
        $(".sug").fadeOut();
        $.post("saveProt.asp?FormID=<%= FormID %>&T="+T+"&TipoCV="+ TipoCV +"&LinCV="+ LinCV +"&ColCV="+ ColCV +"&CampoIDCV="+ CampoIDCV, $("#fEst").serialize(), function (data) { eval(data) });
    }

    $(".prot").change(function () {
        
        saveProt(0);
    });

    CKEDITOR.on('instanceReady', function (ev) {

        ev.editor.on('blur', function (e) {
            saveProt(0);
        });
    });

    $(document).click(function () {
        $(".sug").fadeOut();
    });

    function editPront(Tipo, ID, PacienteID){
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        if (Tipo == "atestado"){
            $.get("iPront.asp?t=Atestado&p="+PacienteID+"&m=&i="+ID+"&a=&redirect=false", function (data) {
                $("#modal").html(data);
            });
        }

    }

    function modalPastas(tipo, id){
        $.post("pacotesProntuarios.asp?id="+id,{
           PacienteID:'<%=id%>'
           },function(data,status){
               $("#modal").html(data);
               $("#modal-table").modal('show');
        });
    }

    function opsub(Grupo, CampoID){
        $.get("tusssubgrupo.asp?Grupo=" + Grupo + "&CampoID=" + CampoID, function (data) { $("#SubgrupoID"+CampoID).html(data) })
    }

    function preencherPosologia(CampoId){
        var Dose = $("#Dose"+CampoId).val();
        var Apresentacao = $("#Apresentacao"+CampoId+" option:selected").text();
        var Frequencia = $("#Frequencia"+CampoId+" option:selected").text();
        var Duracao = $("#Duracao"+CampoId+" option:selected").text();
        var TempoTratamento = $("#TempoTratamento"+CampoId).val();
        var TipoTratamento = $("#TipoTempo"+CampoId+" option:selected").text();

        $("#PosologiaMedicamento"+CampoId).val(Dose+" "+Apresentacao+" de "+TempoTratamento+" em "+TempoTratamento+" "+TipoTratamento+" "+Frequencia+" "+Duracao);
        saveProt(0);
    }
    $(".campo-memo-protocolo").ckeditor();

<!--#include file="JQueryFunctions.asp"-->
</script>