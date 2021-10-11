<!--#include file="connect.asp"-->
<%
valorMinimoParcela = getConfig("ValorMinimoParcelamento")

if ref("A")="E" then
    Id=req("Id")
    'db.execute("UPDATE pendencia_contatos_executantes SET sysUser="&session("User")&", sysActive=-1 WHERE id = " & Id)

    ' insere um novo registro ao invés de excluir (a pedido do Walder)
    set pendenciaProcedimento = db.execute("SELECT PendenciaProcedimentoID, ExecutanteID FROM pendencia_contatos_executantes WHERE id="&Id)
    if not pendenciaProcedimento.eof then
        PendenciaProcedimentoID = pendenciaProcedimento("PendenciaProcedimentoID")
        ExecutanteID            = pendenciaProcedimento("ExecutanteID")
        Observacoes             = "Agendamento excluído pelo usuário"
        db.execute("INSERT INTO pendencia_contatos_executantes (PendenciaProcedimentoID, ExecutanteID, AssociacaoID, Observacoes, sysUser) " &_
        "VALUES ("&PendenciaProcedimentoID&", "&ExecutanteID&", 5, '"&Observacoes&"', "&session("User")& ")")
%>
        showMessageDialog("Agendamento Retirado.", "success");
        setTimeout(function(){
            location.reload();
        }, 500);
<% else %>
    showMessageDialog("Não foi possível excluir.", "danger");
        setTimeout(function(){
            location.reload();
        }, 500);
<% end if
    Response.end
end if 

PendenciaProcedimentoID=req("PendenciaProcedimentoID")
ProfissionalID=req("ProfissionalID")
PacienteID=req("PacienteID")

set PendenciaSQL = db.execute("SELECT pend.*, ab.ProcedimentoID, ab.EspecialidadeID FROM pendencias pend INNER JOIN pendencia_procedimentos pp ON pp.PendenciaID=pend.id LEFT JOIN agendacarrinho ab ON ab.id=pp.BuscaID WHERE pp.id="&PendenciaProcedimentoID)

if req("A")="I" then

    StatusID=req("StatusID")

    data = ""

    if req("data-avulsa") <> "" then
        splData = split(req("data-avulsa"),"/")
        data = splData(2)&"-"&splData(1)&"-"&splData(0)
    end if

    if (StatusID = 5 or StatusID = 6) and (data = "" or req("Hora") = "") then
%>
        alert('É necessário selecionar uma data e hora');
<%
    else

        profissionalSemAgenda = false

        if StatusID = 5 or StatusID = 6 then

            sql = " SELECT *  " &_
                " FROM ( " &_
                "    SELECT ProfissionalID" &_
                "    FROM assfixalocalxprofissional aflp " &_
                "    WHERE (InicioVigencia IS NULL or InicioVigencia <= '"&data&"') AND (FimVigencia IS NULL or FimVigencia >= '"&data&"') " &_
                "    AND aflp.DiaSemana = DATE_FORMAT('"&data&"','%w')+1 "&_
                "    UNION ALL  " &_
                "    SELECT ProfissionalID " &_
                "    FROM assperiodolocalxprofissional aplp  " &_
                "    WHERE DataDe <= '"&data&"' AND DataA >= '"&data&"'  " &_
                ") t " &_
                " WHERE t.ProfissionalID = "& ProfissionalID

            set resAgendaProfissional = db.execute(sql)

            if resAgendaProfissional.eof then
                profissionalSemAgenda = true
            end if
        end if
        
        if profissionalSemAgenda = false then

            if (StatusID = 5 or StatusID = 6) and (IsNull(req("LocalID"))) then
            %>
                alert('O campo Local é obrigatorio!');
            <%
            else
                db.execute("INSERT INTO pendencia_contatos_executantes (PendenciaProcedimentoID, ExecutanteID, AssociacaoID, StatusID, Valor, Observacoes, Contato, Data, Hora, sysUser, LocalID) VALUES "&_
                "("&PendenciaProcedimentoID&", "&ProfissionalID&", 5, "&treatvalzero(StatusID)&", "&treatvalzero(req("Valor"))&", '"&req("Observacoes")&"', '"&req("Contato")&"', "&mydatenull(data)&", "&mytime(req("Hora"))&", "&session("User")&", '"&req("LocalID")&"')")
                %>
                showMessageDialog("Registro salvo com sucesso", "success");
                setTimeout(function(){
                    location.reload();
                }, 500);
                <%
            end if
        else
            %>
            new PNotify({
						title: 'Erro',
                        text: 'Não há agenda disponível para a data/hora informada',
						type: 'danger',
						delay: 3000
					});
            <%
        end if
    end if
    Response.End
end if

Valor = calcValorProcedimento(PendenciaSQL("ProcedimentoID"), 0, UnidadeID, ProfissionalID, EspecialidadeID, 0, "")

set ProfissionalSQL = db.execute("SELECT COALESCE(NomeSocial, NomeProfissional) NomeProfissional, Cel1, Tel1, Cel2, Tel2, CONCAT(Endereco, (CASE WHEN Numero <> '' THEN CONCAT(', ',Numero) ELSE '' END), (CASE WHEN Complemento <> '' THEN CONCAT(', ',Complemento) ELSE '' END), (CASE WHEN Bairro <> '' THEN CONCAT(' - ',Bairro) ELSE '' END), (CASE WHEN Cidade <> '' THEN CONCAT(' - ',Cidade) ELSE '' END)) Endereco FROM profissionais WHERE id="&ProfissionalID)

UltimaData = ""
UltimaHora = ""
UltimaObservacao = ""
UltimoContato = ""

set UltimoContatoSQL = db.execute("SELECT StatusID, Data, TIME_FORMAT(Hora,'%H:%i') Hora, Observacoes, Contato FROM pendencia_contatos_executantes WHERE PendenciaProcedimentoID="&PendenciaProcedimentoID&" AND ExecutanteID="&ProfissionalID&" AND sysActive = 1 ORDER BY id desc ")
if not UltimoContatoSQL.eof then
    StatusID = UltimoContatoSQL("StatusID")
    UltimaData = UltimoContatoSQL("Data")
    UltimaHora = UltimoContatoSQL("Hora")
    if StatusID then
        UltimaObservacao = UltimoContatoSQL("Observacoes")
    else
        UltimaObservacao = ""
    end if
    UltimoContato = UltimoContatoSQL("Contato")
end if

%>
<!--#include file="modal.asp"-->
<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h4 class="lighter blue">Contatar executante</h4>
        </div>

        <div class="col-md-4" style="margin-top: 10px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>
</div>

<form id="formContatoExecutante" onsubmit="return false">
    <input type="hidden" id="A" name="A" value="I">
    <input type="hidden" id="ProfissionalID" name="ProfissionalID" value="<%=ProfissionalID%>">
    <input type="hidden" id="PendenciaProcedimentoID" name="PendenciaProcedimentoID" value="<%=PendenciaProcedimentoID%>">
    <input type="hidden" id="ProcedimentoID" name="ProcedimentoID" value="<%=ProcedimentoID%>">

<div class="panel-body">
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
                                                " JOIN pendencias pe ON pe.PacienteID = pa.id WHERE pa.id = "&PendenciaSQL("PacienteID"))
Contato = ""

if not sqlPaciente.EOF then
    NomePaciente = sqlPaciente("id")&" - "&sqlPaciente("NomePaciente")
    NascimentoData = sqlPaciente("NascimentoData")
    IdadePaciente = " ("&sqlPaciente("Idade")&" anos)"

'FIXO
    if sqlPaciente("Contato1") <> "" then
        Contato = sqlPaciente("Contato1")
    end if

    if sqlPaciente("Contato2") <> "" then
        if Contato <> "" then
            Contato = Contato&" - "
        end if
        Contato = Contato&sqlPaciente("Contato2")
    end if

'CELULAR
    if sqlPaciente("Contato3") <> "" then
        if Contato <> "" then
            Contato = Contato&" / "
        end if
        Contato = Contato&sqlPaciente("Contato3")
    end if

    if sqlPaciente("Contato4") <> "" then
        if Contato <> "" and sqlPaciente("Contato3") = "" then
            Contato = Contato&" / "
        elseif sqlPaciente("Contato3") <> "" then
            Contato = Contato&" - "
        end if
        Contato = Contato&sqlPaciente("Contato4")
    end if

'SEM CONTATO
    if Contato = "" then
        Contato = "SEM TELEFONE"
    end if
else
    NomePaciente = ""
    NascimentoData = ""
    IdadePaciente = ""
    Contato = ""
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
            <b>Contato:</b> <%=Contato%>
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
                        A Vista
                    </th>
                    <th>
                        3x
                    </th>
                    <th>
                        6x
                    </th>
                    <th width="10%">
                    </th>
                </tr>
            </thead>
            <tbody>
<%
    set cart = db.execute("select ac.AgendamentoID, "&_
                              " pp.id as ppid, ac.id, "&_
                              " proc.NomeProcedimento, "&_
                              " comp.NomeComplemento, "&_
                              " prof.NomeProfissional, "&_
                              " prof.NomeSocial, "&_
                              " ac.Zona, "&_
                              " ac.EspecialidadeID, "&_
                              " a.Data, "&_
                              " a.Hora, "&_
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
                              " WHERE pp.id="&PendenciaProcedimentoID)
        while not cart.eof
            valorProcedimento = 0
            parcelaTres = 0
            parcelaSeis = 0
            if cart("ProcedimentoID") <> "" and  not isnull(cart("ProcedimentoID")) then
                valorProcedimento = calcValorProcedimento(cart("ProcedimentoID"), cart("TabelaID"), "", ProfissionalID, cart("EspecialidadeID"), "", "")
                sqlDesconto = "SELECT ParcelasDe, ParcelasAte, Acrescimo FROM sys_formasrecto WHERE tipoDesconto = 'P' AND (procedimentos LIKE '%|ALL|%' OR procedimentos LIKE '%|" & cart("ProcedimentoID") & "|%') " &_
                                            " AND MetodoID IN (8,9,10) limit 1"

                set descontos = db.execute(sqlDesconto)
                                
                parcelaTres = valorProcedimento / 3
                parcelaSeis = valorProcedimento / 6

                id_procedimento = cart("ProcedimentoID")

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
                if not isnull(cart("AgendamentoID")) then
                    set AgendamentoSQL = db.execute("SELECT loc.NomeLocal, a.ValorPlano, a.rdValorPlano, a.Data, a.Hora, loc.UnidadeID as uID, " &_ 
                        " IF(loc.UnidadeID = 0, (select CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Endereco from empresa where id = loc.UnidadeID), " &_ 
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

                        Endereco = AgendamentoSQL("Enderecos")

                    end if
                end if

                set ExecutanteSQL = db.execute(" SELECT COALESCE(prof.NomeSocial, prof.NomeProfissional) NomeProfissional, "&_
                                                    " ce.Data, ce.LocalID"&_
                                                    " FROM pendencia_contatos_executantes ce "&_
                                                    " INNER JOIN profissionais prof ON prof.id = ce.ExecutanteID "&_
                                                    " WHERE ce.PendenciaProcedimentoID = "&cart("ppid")&_
                                                    " AND ce.StatusID IN (6) ORDER BY ce.id DESC LIMIT 1")
                NomeProfissional=""
                Data=""

                if not ExecutanteSQL.eof then
                    NomeProfissional=ExecutanteSQL("NomeProfissional")
                    Data=ExecutanteSQL("Data")
                    LocalID=ExecutanteSQL("LocalID")
                end if
                %>
                <tr>
                    <td>
                        <%=cart("NomeProcedimento")%>
                    </td>
                    <td>
                        <%= cart("NomeComplemento") %>
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
                        <button class="btn btn-warning btn-xs" type="button" onclick="openComponentsModal('procedimentosListagemPaciente.asp?ProfissionalID=<%=ProfissionalID%>&ProcedimentoID=<%=cart("ProcedimentoID")%>&PacienteID=<%=PendenciaSQL("PacienteID")%>', true, 'Restrições', true, '')"><i class="fa fa-exclamation-circle"></i></button>
                        <button class="btn btn-success btn-xs" type="button" onclick="openComponentsModal('procedimentosModalPreparo.asp?ProfissionalID=<%=ProfissionalID%>&ProcedimentoId=<%=cart("ProcedimentoID")%>&PacientedId=<%=PendenciaSQL("PacienteID")%>&requester=AgendaMultipla', true, 'Preparo', true, '')"><i class="fa fa-list-alt"></i></button>
                    </td>
                </tr>
<%
            cart.movenext
        wend
        cart.close
        set cart = nothing
%>
        </tbody>
    </table>
    <br>
    <table class="table table-bordered">
        <thead>
            <tr class="primary">
                <th colspan="4">
                    Dados do executor
                </th>
                <th width="30%">
                    Contato
                </th>
            </tr>
        </head>
        <tbody>
            <tr>
                <td>
                    Nome do executor
                </td>
                <td>
                    <%=ProfissionalSQL("NomeProfissional")%>
                </td>
                <td>
                    Telefone
                </td>
                <td>
                    <%=ProfissionalSQL("Tel1")%> / <%=ProfissionalSQL("Tel2")%>
                </td>
                <td rowspan="2">
                    <textarea class="form-control" id="Contato" name="Contato"><%=UltimoContato%></textarea>
                </td>
            </tr>
            <tr>
                <td>
                    Endereço
                </td>
                <td>
                    <%=ProfissionalSQL("Endereco")%>
                </td>
                <td>
                    Celular
                </td>
                <td>
                    <%=ProfissionalSQL("Cel1")%> / <%=ProfissionalSQL("Cel2")%>
                </td>
            </tr>
        </tbody>
    </table>
    <br>
<%
function dayOfWeek(day)
    select case day
        Case 1
            dayOfWeek = "Domingo"
        Case 2
            dayOfWeek = "Segunda-feira"
        Case 3
            dayOfWeek = "Terça-feira"
        Case 4
            dayOfWeek = "Quarta-feira"
        Case 5
            dayOfWeek = "Quinta-feira"
        Case 6
            dayOfWeek = "Sexta-feira"
        Case 7
            dayOfWeek = "Sábado"
    end select
end function

function dayOfWeekShort(day)
    select case day
        Case 1
            dayOfWeekShort = "Dom"
        Case 2
            dayOfWeekShort = "Seg"
        Case 3
            dayOfWeekShort = "Ter"
        Case 4
            dayOfWeekShort = "Qua"
        Case 5
            dayOfWeekShort = "Qui"
        Case 6
            dayOfWeekShort = "Sex"
        Case 7
            dayOfWeekShort = "Sab"
    end select
end function

            sql = "SELECT FimVigencia, DiaSemana, HoraDe, HoraA, Intervalo, ProfissionalID, DataDe, DataA, NomeLocal, (SELECT NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa WHERE id = 1 UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive = 1) as t WHERE id = l.UnidadeID) as Unidade  " &_
                    "FROM ( " &_
                    "    SELECT DATE_FORMAT(FimVigencia, '%d/%m/%Y') FimVigencia, DiaSemana, HoraDe, HoraA, Intervalo, ProfissionalID, '' DataDe, '' DataA, LocalID " &_
                    "    FROM assfixalocalxprofissional aflp " &_
                    "    WHERE (InicioVigencia IS NULL or InicioVigencia <= curdate()) AND (FimVigencia IS NULL or FimVigencia >= curdate()) " &_
                    "    UNION ALL  " &_
                    "    SELECT 0 FimVigencia, '-1' DiaSemana, HoraDe, HoraA, Intervalo, ProfissionalID, DataDe, DataA, LocalID " &_
                    "    FROM assperiodolocalxprofissional aplp  " &_
                    "    WHERE DataDe <= curdate() AND DataA >= curdate()  " &_
                    ") t " &_
                    " LEFT JOIN locais l ON l.id = t.LocalID " &_ 
                    " LEFT JOIN sys_financialcompanyunits sf ON sf.id = l.UnidadeID " &_ 
                    "WHERE " &_
                    "t.ProfissionalID = "& ProfissionalID 
            
            if Regiao <> "" then
                sql = sql & " AND sf.Regiao = '" & Regiao & "'  "
            end if

            set agendamento = db.execute(sql)
            if not agendamento.eof then 
            %>

<table class="table table-striped table-hover table-condensed table-agenda">
    <tr>
        <th>Data / Dia Semana</th>
        <th>Horários</th>
        <th>Consultório/Sala</th>
        <th>Unidade</th>
        <th>Fim da vigência</th>
    </tr>
    <% while not agendamento.eof %>
    <tr>
        <td>
        <%
        if agendamento("DiaSemana") = "-1" then 
            response.write(agendamento("DataDe") & " a " & agendamento("DataA"))
        else 
            diaSemana = dayOfWeek(agendamento("DiaSemana"))
            response.write(diaSemana)
        end if
        %>
        </td>
        <td><%=ft(agendamento("HoraDe"))%> as <%=ft(agendamento("HoraA"))%></td>
        <td><%=agendamento("NomeLocal")%></td>
        <td><%=agendamento("Unidade")%></td>
        <td><%=agendamento("FimVigencia")%></td>
    </tr>

    <%
            agendamento.movenext
        wend
        agendamento.close
        set agendamento = nothing
    %>
</table>
<%
    end if
%>

    <br>
    <table class="table table-bordered">
        <thead>
            <tr class="primary">
                <th width="18%">
                    Data
                </th>
                <th width="10%">
                    Hora
                </th>
                <th colspan="2">
                    Status
                </th>
                <th>
                    Local
                </th>
                <th>
                    Observações
                </th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>
                    <div class="input-group">
                        <input id="data-avulsa" name="data-avulsa" autocomplete="off" class="form-control input-mask-date date-picker" type="text" data-date-format="dd/mm/yyyy" value="<%=UltimaData%>">
                        <span class="input-group-addon">
                        <i class="fa fa-calendar bigger-110"></i>
                        </span>
                    </div>
                </td>
                <td>
                    <input type="text" name="Hora" id="Hora" value="<%=UltimaHora%>" class="form-control input-mask-hour">
                </td>
                <td colspan="2">
                    <select class='class-status' id='StatusID' name='StatusID'>
                        <%
                        set SQLStatus = db.execute("SELECT id , NomeStatus FROM cliniccentral.pendencia_executante_status")
                        while not SQLStatus.eof
                        %>
                            <option value="<%=SQLStatus("id")%>" <% if SQLStatus("id") = StatusID then response.write("selected") end if %>><%=SQLStatus("NomeStatus")%>
                        <%
                        SQLStatus.movenext
                        wend

                        SQLStatus.close
                        set SQLStatus = nothing
                        %>
                    </select>
                    <script>$('.class-status').select2();</script>
                </td>
                <td rowspan="100%">
                    <select class='class-local' id='LocalID' name='LocalID'>
                       
                        <%
                        set SQLLocais = db.execute("SELECT DISTINCT L.id, L.NomeLocal FROM locais L INNER JOIN procedimento_profissional_unidade PU ON L.UnidadeID = PU.id_unidade WHERE PU.id_profissional = " & ProfissionalID & " AND sysActive = 1 ORDER BY L.NomeLocal ASC")
                        
                        while not SQLLocais.eof
                        %>
                            <option value="<%= SQLLocais("id") %>" <% if SQLLocais("id") = LocalID then response.write("selected") end if %>><%=SQLLocais("NomeLocal") %>
                        <%
                        
                        SQLLocais.movenext
                        wend

                        SQLLocais.close
                        set SQLLocais = nothing
                        %>
                    </select>
                    <script>$('.class-local').select2();</script>
                </td>
                <td rowspan="100%" style="height: 100%">
                    <textarea class="form-control" name="Observacoes" id="Observacoes" style="width: 100%; height: 100%;"><%=UltimaObservacao%></textarea>
                </td>
            </tr>
            <tr class="primary">
                <th>
                    Zonas
                </th>
                <th width="14%">
                    Data
                </th>
                <th>
                    Observação
                </th>
                <th width="5%" style="text-align:center">
                    Turno
                </th>
            </tr>
            <tr>
                <td rowspan="100%">
                    <%=PendenciaSQL("Zonas")%>
                </td>
            </tr>
<%
            set DiasSQL = db.execute("SELECT id, DATE_FORMAT(Data,'%d/%m/%Y') AS Data, DATE_FORMAT(Data, '%Y-%m-%d') AS DataValor, DATE_FORMAT(Data,'%w')+1 DiaSemana, Data AS ordernar, TurnoManha, TurnoTarde, Observacao FROM pendencia_data WHERE PendenciaID = "&PendenciaSQL("id")&" ORDER BY ordernar")

            while not DiasSQL.eof

                checked=""

                if DiasSQL("Data")=UltimaData&"" then
                    checked=" checked "
                end if
%>
                <tr>
                    <td>
                        <div class="radio-custom radio-info "><input style="z-index:0" <%=checked%> type="radio" name="Data" id="data-<%=DiasSQL("id")%>" value="<%=DiasSQL("Data")%>" /><label for="data-<%=DiasSQL("id")%>"><%=DiasSQL("Data")%>-<%=dayOfWeekShort(DiasSQL("DiaSemana"))%></label></div>
                    </td>
                    <td>
                        <%=DiasSQL("Observacao")%>
                    </td>
                    <td>
                        <% if DiasSQL("TurnoManha") = "M" then response.write("<span class='badge badge-info'>Manhã</span>") end if %> <% if DiasSQL("TurnoTarde") = "T" then response.write("<span class='badge badge-warning'>Tarde</span>") end if %>
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
</div>
    <input type="hidden" id="Valor" name="Valor" value="<%=valorProcedimento%>">
    <div class="modal-footer no-margin-top">
        <button type="button" class="btn btn-secondary pull-right m5" data-dismiss="modal">Fechar</button><button onclick="salvar()" type="button" class="btn btn-primary pull-right m5">Salvar contato</button>
    </div>
</form>

<script>

    $('.input-mask-date').mask('99/99/9999');
    $('.input-mask-hour').mask('99:99');

    $("input[type='radio']").on("click", function(){
        $("#data-avulsa").val($( "input:checked" ).val())
    });

    $('.date-picker').datepicker({autoclose:true}).next().on(ace.click_event, function(){
        $(this).prev().focus();
    });

    idPacient = document.getElementsByName("PacienteID")[0].value;

    $(document).ready(function() {
        $("#formContatoExecutante").submit(function(e){
            e.preventDefault();
        });
    });

    function salvar() {
        $.get("PendenciaExecutanteContato.asp", $("#formContatoExecutante").serialize(), function(data) {
            eval(data);
            closeComponentsModal();
        });
    }

    <!--#include file="JQueryFunctions.asp"-->
</script>