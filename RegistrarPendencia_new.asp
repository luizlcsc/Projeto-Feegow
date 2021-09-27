<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<!--#include file="Classes/Restricao.asp"-->
<%
PacienteID = req("PacienteID")&""
PendenciaID = req("PendenciaID")&""
MultiplaFiltros = req("MultiplaFiltros")
valorMinimoParcela = getConfig("ValorMinimoParcelamento")

totalDuplicidade = "0"

bloquear = false

if PendenciaID <> "" and not bloquear then

    set VerificaBloqueio = db.execute("SELECT Nome, UsuarioID FROM pendencia_sessao ps JOIN cliniccentral.licencasusuarios lu ON lu.id = ps.UsuarioID WHERE ps.PendenciaID = "&PendenciaID)

    if not VerificaBloqueio.eof then

        if VerificaBloqueio("UsuarioID") <> session("User") then
            bloquear = true
            response.write("Esta proposta está em uso por "&VerificaBloqueio("Nome"))
        end if
    end if

end if

if not bloquear then

    ProcedimentoID = req("ProcedimentoID")
    UnidadeID = req("UnidadeID")
    BuscaID = req("BuscaID[]")
    Zonas = req("Regiao")

    if BuscaID = "" then
        BuscaID = req("BuscaID")
    end if

    Contato = ref("Contato")

    if PendenciaID = "" then
        PendenciaID = ref("PendenciaID")
    end if

    if PacienteID = "" then
        PacienteID = ref("PacienteID2")
    end if

if PendenciaID = "" then

    BuscasSplt = split(BuscaID, ",")

    sqlPendencia = ("INSERT INTO pendencias (PacienteID, StatusID, sysUser, sysActive) VALUES "&_
        " ("& treatvalzero(PacienteID) &", 9, "&session("User")&",-1)")

    db.execute(sqlPendencia)

    set PendenciaSQL = db.execute("SELECT LAST_INSERT_ID() AS id")
    PendenciaID = PendenciaSQL("id")

    db.execute("INSERT INTO pendencia_timeline (PendenciaID, StatusID, DataInicio, Ativo, sysUser) VALUES ("&PendenciaID&",1,CURRENT_TIMESTAMP,1,"&session("User")&")")

    for i=0 to ubound(BuscasSplt)
        BuscaID = BuscasSplt(i)

        sqlProcedimento = "INSERT INTO pendencia_procedimentos (PendenciaID, BuscaID, StatusID, sysUser) VALUES ("&PendenciaID&", "&BuscaID&", 1, "&session("User")&")"

        db.execute(sqlProcedimento)
    next

end if

db.execute("INSERT INTO pendencia_sessao (UsuarioID, PendenciaID) VALUES ("&session("User")&","&PendenciaID&")")

set PendenciaSQL = db.execute("SELECT * "&_ 
                             " FROM pendencias "&_
                             " WHERE id="&PendenciaID)

UnidadeID=PendenciaSQL("UnidadeID")
PacienteID=PendenciaSQL("PacienteID")
Zonas=PendenciaSQL("Zonas")
Requisicao=PendenciaSQL("Requisicao")
Contato=PendenciaSQL("Contato")
ObsRequisicao=PendenciaSQL("ObsRequisicao")
ObsContato=PendenciaSQL("ObsContato")
ObsTurno=PendenciaSQL("ObsTurno")

set DiasSQL = db.execute("SELECT id, Data, TurnoManha, TurnoTarde, Observacao FROM pendencia_data WHERE PendenciaID = "&PendenciaID)

%>
<style>
.btn-info:hover, .btn-info:focus, .btn-info:active, .btn-info.active, .open > .dropdown-toggle.btn-info {
    background-color: #264cc9 !important;
}
</style>
<% 
set sqlPaciente = db.execute(" SELECT DISTINCT pa.id, "&chr(13)&_
                            " TRIM(pa.NomePaciente) NomePaciente, "&chr(13)&_
                            " COALESCE(DATE_FORMAT(Nascimento, '%d/%m/%Y'),'(SEM DATA DE NASCIMENTO)') NascimentoData, "&chr(13)&_
                            " COALESCE(TIMESTAMPDIFF(YEAR, Nascimento, CURDATE()),'') Idade,"&chr(13)&_
                            " pa.Tel1 AS Contato1, "&chr(13)&_
                            " pa.Tel2 AS Contato2, "&chr(13)&_
                            " pa.Cel1 AS Contato3, "&chr(13)&_
                            " pa.Cel2 AS Contato4, "&chr(13)&_
                            " TRIM(NomePaciente) AS NomeOrdem "&chr(13)&_
                            " FROM pacientes pa "&chr(13)&_
                            " JOIN pendencias pe ON pe.PacienteID = pa.id WHERE pa.id = "&PacienteID)

ContatoTel = ""

if not sqlPaciente.EOF then
    NomePaciente = sqlPaciente("id")&" - "&sqlPaciente("NomePaciente")
    NascimentoData = sqlPaciente("NascimentoData")
    IdadePaciente = " ("&sqlPaciente("Idade")&" anos)"

'FIXO
    if sqlPaciente("Contato1") <> "" then
        ContatoTel = sqlPaciente("Contato1")
    end if

    if sqlPaciente("Contato2") <> "" then
        if ContatoTel <> "" then
            ContatoTel = ConContatoTeltato&" - "
        end if
        ContatoTel = ContatoTel&sqlPaciente("Contato2")
    end if

'CELULAR
    if sqlPaciente("Contato3") <> "" then
        if ContatoTel <> "" then
            ContatoTel = ContatoTel&" / "
        end if
        ContatoTel = ContatoTel&sqlPaciente("Contato3")
    end if

    if sqlPaciente("Contato4") <> "" then
        if ContatoTel <> "" and sqlPaciente("Contato3") = "" then
            ContatoTel = ContatoTel&" / "
        elseif sqlPaciente("Contato3") <> "" then
            ContatoTel = ContatoTel&" - "
        end if
        ContatoTel = ContatoTel&sqlPaciente("Contato4")
    end if

'SEM CONTATO
    if ContatoTel = "" then
        ContatoTel = "SEM TELEFONE"
    end if
else
    NomePaciente = ""
    NascimentoData = ""
    IdadePaciente = ""
    ContatoTel = ""
end if

%>
<table width="100%" class="table table-bordered">
    <tr class="primary">
        <th>
            <b>Paciente:</b> <%=NomePaciente%>
        </th>
        <th>
            <b>Nascimento:</b> <%=NascimentoData&IdadePaciente%>
        </th>
        <th>
            <b>Contato:</b> <%=ContatoTel%>
        </th>
        <th width="1%" style="text-align: right">
            <a href='?P=Pacientes&I=<%=PacienteID%>&Pers=1' target='_blank' class='btn btn-xs btn-primary'>Ver Cliente</button>
        </th>
    </tr>
</table>
<br>
<table width="100%" class="table table-bordered">
    <thead>
        <tr class="primary">
            <th>
                Procedimento
            </th>
            <th>
                Complemento
            </th>
            <th>
                Executor
            </th>
            <th>
                Data
            </th>
            <th>
                Hora
            </th>
            <th>
                Local
            </th>
            <th>
                A Vista
            </th>
            <th>
                3x
            </th>
            <th>
                6x
            </th>
            <th width="2%">
                R
            </th>
        </tr>
    </thead>
    <tbody>
<%
        totalAVista = 0
        totalParcelaTres = 0
        totalParcelaSeis = 0

        sql = "select ac.AgendamentoID, "&_
                              " pp.id as ppid, ac.id, "&_
                              " proc.NomeProcedimento, "&_
                              " comp.NomeComplemento, "&_
                              " COALESCE(prof.NomeSocial, prof.NomeProfissional) NomeProfissional, "&_
                              " prof.NomeSocial, "&_
                              " ac.Zona, "&_
                              " ac.EspecialidadeID, "&_
                              " a.Data, "&_
                              " ep.especialidade, "&_
                              " ac.ProcedimentoID, "&_
                              " ac.ProfissionalID, "&_
                              " ac.TabelaID "&_
                              " FROM pendencia_procedimentos pp "&_
                              " INNER JOIN agendacarrinho ac ON ac.id=pp.BuscaID "&_
                              " LEFT JOIN procedimentos proc ON proc.id=ac.ProcedimentoID "&_
                              " LEFT JOIN complementos comp ON comp.id=ac.ComplementoID "&_
                              " LEFT JOIN profissionais prof ON prof.id=ac.ProfissionalID "&_
                              " LEFT JOIN agendamentos a ON a.id=ac.AgendamentoID "&_
                              " LEFT JOIN especialidades ep ON ep.id = ac.EspecialidadeID "&_
                              " WHERE pp.PendenciaID="&PendenciaID&_ 
                              " AND pp.sysActive = 1"

        set cart = db.execute(sql)

        set restricaoObj = new Restricao

        while not cart.eof
            valorProcedimento = 0
            parcelaTres = 0
            parcelaSeis = 0
            if cart("ProcedimentoID") <> "" and  not isnull(cart("ProcedimentoID")) then
                valorProcedimento = calcValorProcedimento(cart("ProcedimentoID"), cart("TabelaID"), "", cart("ProfissionalID"), cart("EspecialidadeID"), "")
                sqlDesconto = "SELECT ParcelasDe, ParcelasAte, Acrescimo FROM sys_formasrecto WHERE tipoDesconto = 'P' AND (procedimentos LIKE '%|ALL|%' OR procedimentos LIKE '%|" & cart("ProcedimentoID") & "|%') " &_
                                            " AND MetodoID IN (8,9,10) limit 1"

                set descontos = db.execute(sqlDesconto)
                                
                parcelaTres = valorProcedimento / 3
                parcelaSeis = valorProcedimento / 6

                if not descontos.eof then
                    if descontos("ParcelasDe") <= 3 then
                        parcelaTres = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (3 * 100 )
                    end if

                    if descontos("ParcelasAte") >= 6 then
                        parcelaSeis = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (6 * 100)
                    end if
                end if

            end if

                Endereco = ""
                NomeProfissional=""
                Data=""
                Hora=""
                if not isnull(cart("AgendamentoID")) then
                    set AgendamentoSQL = db.execute("SELECT loc.NomeLocal, a.ValorPlano, a.rdValorPlano, a.Data, a.Hora, loc.UnidadeID as uID, " &_ 
                        " IF(loc.UnidadeID = 0, (select CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Enderecos from empresa where id = loc.UnidadeID), " &_ 
                        " (select CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Enderecos from sys_financialcompanyunits where id = loc.UnidadeID) ) Enderecos " &_
                        " FROM agendamentos a LEFT JOIN locais loc ON loc.id=a.LocalID WHERE a.id="&cart("AgendamentoID"))
                       
                    if not AgendamentoSQL.eof then

                        AVista = "Convenio"
                        valorProcedimento = 0
                        parcelaTres = 0
                        parcelaSeis = 0

                        if AgendamentoSQL("rdValorPlano") = "V" then 
                            valorProcedimento = AgendamentoSQL("ValorPlano")    

                            if not descontos.eof then
                                if descontos("ParcelasDe") <= 3 then
                                    parcelaTres = valorProcedimento * descontos("Acrescimo") / (3 * 100)
                                end if

                                if descontos("ParcelasAte") >= 6 then
                                    parcelaSeis = valorProcedimento * descontos("Acrescimo") / (6 * 100)
                                end if
                            end if
                        end if

                        NomeLocal = AgendamentoSQL("NomeLocal")
                        Data = AgendamentoSQL("Data")
                        Hora = formatdatetime(AgendamentoSQL("Hora"),4)
                        Endereco = AgendamentoSQL("Enderecos")

                    end if
                end if

                set ExecutanteSQL = db.execute(" SELECT COALESCE(prof.NomeSocial, prof.NomeProfissional) NomeProfissional, "&_
                                                    " ce.Data, ce.Hora "&_
                                                    " FROM pendencia_contatos_executantes ce "&_
                                                    " INNER JOIN profissionais prof ON prof.id = ce.ExecutanteID "&_
                                                    " WHERE ce.PendenciaProcedimentoID = "&cart("ppid")&_
                                                    " AND ce.StatusID IN (6)")
               

                if not ExecutanteSQL.eof then
                    NomeProfissional=ExecutanteSQL("NomeProfissional")
                     Data=ExecutanteSQL("Data")
                     if ExecutanteSQL("Hora") <> "" then
                        splHora = split(ExecutanteSQL("Hora"), " ")
                        splSemSegundo = split(splHora(1),":")
                        Hora=splSemSegundo(0)&":"&splSemSegundo(1)
                    end if
                end if

                totalAVista = totalAVista + valorProcedimento
                totalParcelaTres = totalParcelaTres + parcelaTres
                totalParcelaSeis = totalParcelaSeis + parcelaSeis

                %>
                <tr>
                    <td>
                        <%=cart("NomeProcedimento")%>
                    </td>
                    <td>
                        <%= cart("NomeComplemento") %>
                    </td>
                    <td>
                        <%= cart("NomeProfissional") %>
                    </td>
                    <td>
                        <%=Data%>
                    </td>
                    <td>
                        <%=Hora%>
                    </td>
                    <td>
                        <span data-toggle="tooltip" title="<%= Endereco %>" href="#" class=""><%= NomeLocal %></span>
                    </td>
                    <td>
                        R$ <%= fn(valorProcedimento) %>
                    </td>
                    <td>
                        R$ <%= fn(parcelaTres) %>
                    </td>
                    <td>
                        <% if ccur(valorProcedimento) >= ccur(valorMinimoParcela) then %> 
                            R$ <%=fn(parcelaSeis)%>
                            <% else 
                            response.write(" - ")
                        end if %>
                    </td>
                    <td style="text-align:center">
                        <!--button class="btn btn-warning btn-xs" type="button" onclick="abrirModal('procedimentosListagem.asp?ProcedimentoId=<%=cart("ProcedimentoId")%>&PacientedId=<%=PacienteID%>','Restrições')"><i class="fa fa-caret-square-o-left"></i></button -->
                        <%
                            if ccur(restricaoObj.possuiRestricao(cart("ProcedimentoId"))) > 0 then
                        %>
                        <button class="btn btn-warning btn-xs" type="button" onclick="abrirModalRestricaoPendencia (<%=cart("ProcedimentoId")%>,<%=PacienteID%>)"><i class="fa fa-caret-square-o-left"></i></button>
                        <%
                            end if
                        %>
                    </td>
                </tr>
<%
            cart.movenext
        wend
        cart.close
        set cart = nothing
%>
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>R$ <%=fn(totalAVista)%></td>
                    <td>R$ <%=fn(totalParcelaTres)%></td>
                    <td>
                        <% if ccur(totalAVista) >= ccur(valorMinimoParcela) then %> 
                            R$ <%=fn(totalParcelaSeis)%>
                        <% else 
                            response.write(" - ")
                        end if %>
                    </td>
                    <td></td>
                </tr>
            </tbody>
        </table>

    <script>
        function abrirModalRestricaoPendencia (ProcedimentoID,PacienteID) {
            $.ajax({
                type: 'GET',
                url: 'procedimentosListagem.asp?ProcedimentoId=' + ProcedimentoID + '&PacientedId=' + PacienteID + '&requester=RegistrarPendencia&criarPendencia=Nao',
                data: true
            }).done(function(data) { 
                $(".modalpendencias_new").modal("show")
                $(".modalpendenciasbody_new").html(data)
            });
        }

        function carregaRestricaoProcedimento(procedimentoID) {
            $.post("procedimentosListagem.asp?ProcedimentoId="+procedimentoID+"&PacientedId=<%=PacienteID%>",function(data){
                $("#tdCollapseRestricaoProcedimento_"+procedimentoID).html(data)
            })
        }
<%
    
    if ccur(valorMinimoParcela) > ccur(totalAVista) then
    %>
        $(".show-parc-seis").hide();
    <%
    end if
    %>
    </script>
<br>
<table width="100%" class="table table-bordered">
    <thead>
        <tr class="primary">
            <th style="text-align:center" width="20%">
                UNIDADE DE PENDÊNCIA
            </th>
            <th style="text-align:center" width="20%">
                ZONA
            </th>
            <th style="text-align:center" width="60%">
                SELEÇÃO DE DIAS
            </th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td style="vertical-align:top">
            <div class="btn-group btn-group-toggle" data-toggle="buttons">
                <% set Empresa = db.execute("select * from empresa where OcultoAgenda <> 'S'") %>
                <% while not Empresa.eof %>
                    <label class="btn btn-info btn-sm btn-block <% if UnidadeID = 0 then response.write("active") end if %>">
                        <input type="radio" name="UnidadeID" id="option0" value="0" autocomplete="off" <% if UnidadeID = 0 then response.write("checked") end if %>> <%=Empresa("NomeEmpresa")%>
                    </label>
                <% Empresa.movenext
                wend
                Empresa.close
                set Empresa=nothing %>
                <% set Unidades = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 and (OcultoAgenda <> 'S' OR OcultoAgenda IS NULL)  order by UnitName") %>
                
                <% while not Unidades.eof %>
                        <label class="btn btn-info btn-sm btn-block <% if Unidades("id") = UnidadeID then response.write("active") end if %>">
                            <input type="radio" name="UnidadeID" id="option<%=Unidades("id")%>" autocomplete="off" value="<%=Unidades("id")%>" <% if Unidades("id") = UnidadeID then response.write("checked") end if %>> <%=Unidades("NomeFantasia")%>
                        </label>
                    
                <%Unidades.movenext
                wend
                Unidades.close
                set Unidades=nothing %>
            </div>
            </td>
            <td style="vertical-align: top">
                <table width="100%">
                    <thead>
                        <tr>
                        <td width="90%">
                            <div id="divZona">

                            </div>
                        </td>
                        <td style="text-align: center">
                            <button type="button" class="btn btn-sm btn-success" id="insereZona" onclick="$('#insereZona').prop('disabled', true);insereZona2()"><li class="fa fa-plus"></li></button>
                        </td>
                        </tr>
                    </thead>
                </table>
                <br>
                <table class="table" id="tblZona" width="100%">
                    <tbody>
<%
if Zonas <> "" then
    zonaSplt = split(Zonas, ",")
    for z=0 to ubound(zonaSplt)

%>
                        <tr>
                            <td width="90%">
                                <input type="hidden" name="zona[]" value="<%=zonaSplt(z)%>"><%=zonaSplt(z)%>
                            </td>
                            <td>
                                <button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="removeZona(this)">
                                    <i class="fa fa-trash"></i>
                                </button>
                            </td>
                        </tr>
<%
    next
end if
%>
                    </tbody>
                </table>
                <script>

                    $(document).ready(function(){
                        $('#insereZona').dblclick(function(e){
                            e.preventDefault();
                        });   
                    });

                    carregaZona();

                    function insereZona2() {

                        var a = $("#Regiao").val();

                        if (a != null) {
                            var b = $("#Regiao option:selected").text();
                            $('#tblZona tbody').append(`<tr>
                                                            <td width="90%">
                                                                <input type="hidden" name="zona[]" value="${a}">${b}
                                                            </td>
                                                            <td>
                                                                <button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="removeZona(this)">
                                                                    <i class="fa fa-trash"></i>
                                                                </button>
                                                            </td>
                                                        </tr>`);
                            carregaZona();
                        } 
                    }

                    function carregaZona() {
                        var zonaValor = [];
                        var inputZonaValor = $("input[type='hidden'][name^='zona']").map(function() {
                            return $.trim($(this).val());
                        }).toArray();
                        
                        if (inputZonaValor.length > 0) {
                            zonaValor = " AND Regiao NOT IN ('"+inputZonaValor.join("','")+"')";
                        }

                        $.post("pendenciasUtilities.asp", {
                            acao: "carregaZona",
                            zonaValor: zonaValor,
                        }, function(data) {
                            $("#divZona").html(data);
                            $('#insereZona').prop('disabled', false);
                        });
                    }

                    function removeZona(ele) {
                        $(ele).parent().parent().remove();
                        carregaZona();
                    }
                </script>
            </td>
            <td style="vertical-align:top">
                <table width="100%">
                    <tr>
                        <td width="240px" style="vertical-align:top">
                            <link href="css/vanillaCalendar.css" rel="stylesheet">
                            <div style="max-height: 300px; overflow: auto; padding: 5px;width: 280px">
                                <div id="v-cal">
                                    <div class="vcal-header">
                                        <button class="vcal-btn" type="button" data-calendar-toggle="previous">
                                            <svg height="24" version="1.1" viewbox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M20,11V13H8L13.5,18.5L12.08,19.92L4.16,12L12.08,4.08L13.5,5.5L8,11H20Z"></path>
                                            </svg>
                                        </button>
                                        <div class="vcal-header__label" data-calendar-label="month">
                                            March 2017
                                        </div>
                                        <button class="vcal-btn" type="button" data-calendar-toggle="next">
                                            <svg height="24" version="1.1" viewbox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M4,11V13H16L10.5,18.5L11.92,19.92L19.84,12L11.92,4.08L10.5,5.5L16,11H4Z"></path>
                                            </svg>
                                        </button>
                                    </div>
                                    <div class="vcal-week">
                                        <span>SEG</span>
                                        <span>TER</span>
                                        <span>QUA</span>
                                        <span>QUI</span>
                                        <span>SEX</span>
                                        <span>SAB</span>
                                        <span>DOM</span>
                                    </div>
                                    <div class="vcal-body" data-calendar-area="month"></div>
                                </div>
                                <div class="container2 dias _dias flex-wrap flex-start">
                                </div>
                                <script src="js/vanillaCalendar.js" type="text/javascript"></script>
                            </div>
                        </td>
                        <td style="vertical-align:top">
                            <table class="table" id="tblDias" width="100%">
                                <tbody>
<%
                                    set DiasSQL = db.execute("SELECT id, DATE_FORMAT(Data, '%d/%m/%Y') AS Data, Data as ordernar, TurnoManha, TurnoTarde, Observacao FROM pendencia_data WHERE PendenciaID = "&PendenciaID&" ORDER BY ordernar")

                                    while not DiasSQL.eof
%>
                                            <tr>
                                              <td width="15%">
                                                <input type="hidden" name="Dias|x<%=DiasSQL("id")%>" value="<%=DiasSQL("Data")%>">
                                                <b><%=DiasSQL("Data")%></b>
                                              </td>
                                              <td>
                                                <input class="form-control" type="text" name="Dias|x<%=DiasSQL("id")%>" value="<%=DiasSQL("Observacao")%>">
                                              </td>
                                              <td width="150px">
                                                <div class="btn-group btn-group-toggle" data-toggle="buttons">
                                                <label class="btn btn-sm btn-info <% if DiasSQL("TurnoManha") = "M" then response.write("active") end if %>">
                                                    <input type="checkbox" name="DiasM|x<%=DiasSQL("id")%>" id="Contato1" value="M" autocomplete="off" <% if DiasSQL("TurnoManha") = "M" then response.write("checked") end if %>> MANHÃ
                                                </label>
                                                <label class="btn btn-sm btn-info <% if DiasSQL("TurnoTarde") = "T" then response.write("active") end if %>">
                                                    <input type="checkbox" name="DiasT|x<%=DiasSQL("id")%>" id="Contato2" value="T" autocomplete="off" <% if DiasSQL("TurnoTarde") = "T" then response.write("checked") end if %>> TARDE
                                                </label>
                                                </div>
                                              </td>
                                              <td width="10%">
                                                <button type="button" class="btn btn-sm btn-danger remove-item-subform remover-data" remove-selected-day="<%=DiasSQL("Data")%>" onclick="$(this).parent().parent().remove();removeSelectedDay('<%=DiasSQL("Data")%>')">
                                                  <i class="fa fa-trash"></i>
                                                </button>
                                              </td>
                                            </tr> 
<%
                                        DiasSQL.movenext
                                    wend

                                    DiasSQL.close
                                    set DiasSQL = nothing
%>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </tbody>
</table>
<script>
    vanillaCalendar.init({
        disablePastDays: true
    });

    function removeSelectedDay(data){
        vanillaCalendar.removeSelectedDay(data)
    }
</script>
<br>
<style>
    .custom{ width: 33% !important;}
    .custom2{ width: 50% !important;}
</style>
<table width="100%" class="table table-bordered">
    <thead>
        <tr class="primary">
            <th style="text-align:center" width="50%">
                REQUISIÇÃO
            </th>
            <th style="text-align:center" width="50%">
                CONTATO
            </th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td style="text-align:center">
                <div class="btn-group btn-group-toggle" data-toggle="buttons" style="width:100%">
                    <label class="btn btn-sm btn-info custom <% if Requisicao = "C" then response.write("active") end if %>">
                        <input type="radio" class="custom-control-input" name="Requisicao" id="Requisicao1" value="C" autocomplete="off" <% if Requisicao = "C" then response.write("checked") end if %>> CENTRAL
                    </label>
                    <label class="btn btn-sm custom btn-info <% if Requisicao = "P" then response.write("active") end if %>">
                        <input type="radio" class="custom-control-input" name="Requisicao" id="Requisicao2" value="P" autocomplete="off" <% if Requisicao = "P" then response.write("checked") end if %>> PARTICULAR
                    </label>
                    <label class="btn btn-sm custom btn-info <% if Requisicao = "S" then response.write("active") end if %>">
                        <input type="radio" class="custom-control-input" name="Requisicao" id="Requisicao3" value="S" autocomplete="off" <% if Requisicao = "S" then response.write("checked") end if %>> SUS
                    </label>
                </div>
            </td>
            <td style="text-align: center">
                <div class="btn-group btn-group-toggle" data-toggle="buttons"  style="width:100%">
                    <label class="btn btn-sm btn-info custom2 <% if Contato = "P" then response.write("active") end if %>">
                        <input type="radio" name="Contato" id="Contato1" value="P" autocomplete="off" <% if Contato = "P" then response.write("checked") end if %>> PACIENTE
                    </label>
                    <label class="btn btn-sm custom2 btn-info <% if Contato = "O" then response.write("active") end if %>">
                        <input type="radio" name="Contato" id="Contato2" value="O" autocomplete="off" <% if Contato = "O" then response.write("checked") end if %>> OUTRO
                    </label>
                </div>
            </td>
        </tr>
        <tr>
            <td>            
                <label for="textRequisicao">Observação</label>
                <textarea class="form-control" name="ObsRequisicao" id="ObsRequisicao"><%=ObsRequisicao%></textarea>
            </td>
            <td>
                <label for="textContato">Observação</label>
                <textarea class="form-control" name="ObsContato" id="ObsContato"><%=ObsContato%></textarea>
            </td>
        </tr>
    </tbody>
</table>

<input type="hidden" name="diasSelecionados" id="diasSelecionados" value="">
<div id="msg-alert">
</div>
    <input type="hidden" value="Salvar" name="Acao">
    <input type="hidden" value="1" name="StatusID">
    <input type="hidden" value="<%=PendenciaID%>" name="PendenciaID">
    <input type="hidden" value="<%=BuscaID%>" name="BuscaID">												   
    <input type="hidden" value="<%=PacienteID%>" name="PacienteID">

<div id="modalpendencias_new" class="modalpendencias_new modal fade">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="modal-title">Restrições</h4>
      </div>
      <div class="modal-body modalpendenciasbody_new" >
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<script>

    $(document).ready(function () {
        $(document).on('show.bs.modal', '.modal', function (event) {
            var zIndex = 1040 + (10 * $('.modal:visible').length);
            $(this).css('z-index', zIndex);
            setTimeout(function() {
                $('.modal-backdrop').not('.modal-stack').css('z-index', zIndex - 1).addClass('modal-stack');
            }, 0);
        });

        $('head').append('<style type="text/css">.modal .modal-body {max-height: ' + ($('body').height() * .8) + 'px;overflow-y: auto;}.modal-open .modal{overflow-y: hidden !important;}</style>');

        $("#form-components").submit(function(e){
            e.preventDefault();
        });

        $(".modal-footer").html(`<button type="button" class="btn btn-secondary pull-right m5" onclick="salvar(true)">Salvar e fechar</button>
        <button type="button" class="btn btn-primary pull-right m5" onclick="salvar(false)">Salvar e continuar</button>`);
    });

function abrirModal(parURL,titulo) {

    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
    $("#modal").css("z-index","9999");

    $.get(parURL, function (data) {
        $("#modal").html(`<div class="modal-header ">
                                <div class="row">
                                    <div class="col-md-8">
                                        <h4 class="lighter blue">${titulo}</h4>
                                    </div>
                                    <div class="col-md-4" style="margin-top: 10px;">
                                        <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
                                    </div>
                                </div>
                            </div>`);
        $("#modal").append(`<div class="modal-body"></div>`);
        //$("#modal").append(`<div class="modal-footer no-margin-top"></div>`);
       // $(".modal-footer").append(`<button type="button" class="btn btn-secondary pull-right m5" data-dismiss="modal">Fechar</button></div>`);
        $(".modal-body").append(data);
    });
}

    function controleTextArea(id,bool) {
        $("#"+id).prop("disabled",bool);
    }

    function salvar(fechar) { 

        var retorno = true;

        $("#msg-alert").html("");

        if (!$("input[name='UnidadeID']").is(':checked')) {
            retorno = false;
            $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar a <b>UNIDADE DE PENDÊNCIA</b> </div>`);
        }

        if($("input[name='zona[]']").length == 0){
            retorno = false;
            $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar a <b>ZONA</b> </div>`);
        }

        if($("input[name^='Dias']").length == 0){
            retorno = false;
            $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar o <b>DIA</b> </div>`);
        }

        if (($("input[name='Requisicao']:checked").val() == "P" || $("input[name='Requisicao']:checked").val() == "S") && $.trim($("#ObsRequisicao").val()) == "") {
            retorno = false;
            $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor escrever uma observação para a <b>REQUISIÇÃO</b> </div>`);
        }

        if (!$("input[name='Requisicao']").is(':checked')) {
            retorno = false;
            $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar a <b>REQUISIÇÃO</b> </div>`);
        }
        
        if ($("input[name='Contato']:checked").val() == "O" && $.trim($("#ObsContato").val()) == "") {
            retorno = false;
            $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor escrever uma observação para o <b>CONTATO</b> </div>`);
        }

        if (!$("input[name='Contato']").is(':checked')) {
            retorno = false;
            $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar a <b>CONTATO</b> </div>`);
        }

        if (!retorno) {
            return false;
        }

        var diasSelecionados = [];

        $("#tblDias tr").each(function(tr){
            var arrDias = $(this).find("input[type=hidden][name^=Dias]").val();
            var arrTurnoM = $(this).find("input[type=checkbox][name^=DiasM]:checked").val();
            var arrTurnoT = $(this).find("input[type=checkbox][name^=DiasT]:checked").val();
            var arrObs = $(this).find("input[type=text][name^=Dias]").val();

            strData = arrDias;
            arrData = strData.split("/");
            novaData = arrData[2]+"-"+arrData[1]+"-"+arrData[0];
            diasSelecionados.push(novaData+","+arrTurnoM+","+arrTurnoT+","+arrObs);
        });

        $("#diasSelecionados").val(diasSelecionados.join("|"));

        $.post("savePendencia.asp", $("#form-components").serialize(), function(data) {
            eval(data);
        });

        if (fechar) {
            <%
                if MultiplaFiltros = "sim" then
            %>
                Limpar(100)
            <%
                end if
            %>
            $("#modal-components").modal("hide");
        } else {
            <%
                if MultiplaFiltros = "sim" then
            %>
                window.location.href = "./?P=Pendencias&Pers=1&I=<%=PacienteID%>";
            <%
                end if
            %>
        }

        return false;
    }

    <!--#include file="jQueryFunctions.asp"-->

    $(function(){
        $(".enviar").on('click', function(){
            //$(this).attr("disabled", "");
            //$(this).prop("disabled", false);
        } );
        $("#Requisicao").on('change', function(){
            var value = $(this).val();
            $("#ObsRequisicao").prop("required", false);
            if(value != "C"){
                $("#ObsRequisicao").prop("required", true);
            }
        });
        $(".components-modal-submit-btn").on('click', function(){
            $(this).attr("disabled", "");
            $(this).prop("disabled", false);
        });
        $(".contato-paciente-outros").on('change', function(){
            var value = $(this).val();
            $("#ObsContato").prop("required", false);
            if(value == "O"){
                $("#ObsContato").prop("required", true);
            }
        });
    })

    
</script>
<% 
response.end()
end if
%>