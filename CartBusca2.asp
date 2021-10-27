<!--#include file="connect.asp"-->
<!--#include file="functionOcupacaoMultiplaFiltros.asp"-->
<style>
    .preto {
        background-color:#000;
        color:#fff;
    }

    .unidade:before {
        content:"-";
        display:block;
        line-height:5px;
        text-indent:-100%;
        visibility: hidden;
    }

    .tooltip .arrow:before {
        border-top-color: #008ec3 !important;
    }

    .tooltip .tooltip-inner {
        background-color: #008ec3;
    }

    #cartbusca thead tr td {
        border-bottom-width: 1px;
    }
</style>

<div class="row mb20">
    <div class="col-md-12">
        <hr class="short alt" />
    </div>
    <div class="col-md-4"></div>
    <div class="col-md-3">
        <button onclick="buscarDias('Manha')" type="button" class="btn btn-default btn-sm btnturno btnmanha"> Manhã </button>
        <button onclick="buscarDias('Tarde')" type="button" class="btn btn-default btn-sm btnturno btntarde"> Tarde </button>
    </div>
    <div class="col-md-2"></div>
    <div class="col-md-3">
        <button type="button" onclick="desistencia()" class="btn btn-warning btn-sm" title="Desistência"><i class="far fa-remove"></i> Desistência</button>
        <button onclick="RegistrarMultiplasPendencias()" type="button" class="btn btn-danger btn-sm" title="Pendência"><i class="far fa-puzzle-piece"></i> Pendência</button>
        <button onclick="FinalizarBusca()" type="button" class="btn btn-primary btn-sm" title="Finalizar busca"><i class="far fa-check"></i> Finalizar</button>
    </div>
</div>
<%
if isdate(ref("Data")) = false then
    response.write("Selecione uma data")
    response.end()
end if

lDe = cdate(ref("Data"))
lAte = lDe+6

htmlData = ""
RegiaoEscolhida = ref("Regiao")&""
turno = ref("turno")&""
sessaoAgenda = ref("sessaoAgenda")
PropostaID = ref("PropostaID")

db.execute("delete from agenda_horarios where sysUser="& session("User")&" AND sessaoAgenda ='"&sessaoAgenda&"'")
set ac = db.execute("select * from agendacarrinho WHERE sysUser="& session("User") &" AND sessaoAgenda ='"&sessaoAgenda&"' AND ISNULL(Arquivado)")
ocor = 0

procedimentoCarrinhoSQL = "SELECT GROUP_CONCAT(procedimentoID) procedimentoid FROM agendacarrinho WHERE sysUser="& session("User") &" AND sessaoAgenda = '"&sessaoAgenda&"' AND ISNULL(Arquivado)"
set procedimentoCarrinho = db.execute(procedimentoCarrinhoSQL)

if not procedimentoCarrinho.eof then
    novaData = ref("Data")
    splitNovaData = split(novaData,"/")
    dataFormatada = splitNovaData(2)&"-"&splitNovaData(1)&"-"&splitNovaData(0)

    queryOld = 0
    if queryOld =1 then
        '====== QUERY OLD - BKP ======'
        agendasFuturasSQL = "SELECT COUNT(*) total, DATE_FORMAT(MIN(ass.InicioVigencia),'%d/%m/%Y') dataFutura, proc.NomeProcedimento, proc.id "&_
        " FROM profissionais prof"&_
        " JOIN procedimento_profissional_unidade ppu ON ppu.id_profissional = prof.id"&_
        " JOIN assfixalocalxprofissional ass ON ass.ProfissionalID = prof.id"&_
        " JOIN procedimentos proc ON proc.id = ppu.id_procedimento"&_
        " WHERE ppu.id_procedimento IN ("&procedimentoCarrinho("procedimentoid")&")"&_
        " AND (ass.InicioVigencia > DATE_ADD('"&dataFormatada&"', INTERVAL 6 DAY))"&_
        " AND ppu.id_unidade IS NOT NULL GROUP BY proc.id"
    else
        agendasFuturasSQL = " SELECT                                                                                                     "&chr(13)&_
        " COUNT(*) total, DATE_FORMAT(MIN(assFixPro.InicioVigencia),'%d/%m/%Y') dataFutura, pro.NomeProcedimento, pro.id                                                             "&chr(13)&_
        " FROM procedimento_profissional_unidade proProUni                                                                               "&chr(13)&_
        " LEFT JOIN assfixalocalxprofissional assFixPro ON assFixPro.ProfissionalID = proProUni.id_profissional                          "&chr(13)&_
        " LEFT JOIN procedimentos pro ON pro.id = proProUni.id_procedimento                                                              "&chr(13)&_
        " WHERE pro.id IN ("&procedimentoCarrinho("procedimentoid")&")                                                                                                     "&chr(13)&_
        " AND proProUni.id_unidade IS NOT NULL                                                                                           "&chr(13)&_
        " AND (	                                                                                                                         "&chr(13)&_
        " 		assFixPro.InicioVigencia BETWEEN COALESCE(assFixPro.InicioVigencia, '"&dataFormatada&"') AND COALESCE(assFixPro.FimVigencia, '"&dataFormatada&"')"&chr(13)&_
        " 		AND                                                                                                                          "&chr(13)&_
        " 		assFixPro.FimVigencia BETWEEN COALESCE(assFixPro.InicioVigencia, '"&dataFormatada&"') AND COALESCE(assFixPro.FimVigencia, '"&dataFormatada&"')   "&chr(13)&_
        " 	 )                                                                                                                            "&chr(13)&_
        " GROUP BY pro.id                                                                                                                "
    end if
    set agendasFuturas = db.execute(agendasFuturasSQL)
    if not agendasFuturas.eof then
        if ccur(agendasFuturas("total")) > 0 then
            agendaDiponivelAviso =  "<strong>* Há mais agendas disponíveis nas próximas semanas para:</strong> "
            while not agendasFuturas.eof
                
                NomeProcedimento = " <span class=""badge badge-warning"">"&agendasFuturas("NomeProcedimento")&"</span> "
                agendaDiponivelAviso = agendaDiponivelAviso&NomeProcedimento

            agendasFuturas.movenext
            wend
            
            agendaDiponivelAviso = agendaDiponivelAviso

            response.write(agendaDiponivelAviso)
        end if                
    end if
    agendasFuturas.close
    set agendasFuturas = nothing
end if

while not ac.eof

    'response.write("<strong>DEBUG CARRINHO ID: " & ac("id") & "</strong><br><br>")
    diaN = 0
    diaAdd = 0
    while diaN < 6

        Data = cdate(ref("Data"))+diaAdd
        DiaSemana = weekday(Data)
        
        if DiaSemana = 1 then 
            diaAdd = diaAdd + 1
            Data = cdate(ref("Data"))+diaAdd
        end if

        if ocor = 0 then
            htmlData = htmlData & "," & Data
        end if
        diaN = diaN + 1
        diaAdd = diaAdd + 1
    wend
    
    sqlProfissionais=""

    Especialidades = ""
    if isnull(ac("EspecialidadeID")) = false and ac("EspecialidadeID") <> 0 then
        Especialidades = ac("EspecialidadeID")
    end if
 
    ProfissionalID = ""
    if isnull(ac("ProfissionalID")) = false and ac("ProfissionalID") <> 0 then
        ProfissionalID = ac("ProfissionalID")
    end if
    
    'pegar os locais da zona
    locais = ""
    if RegiaoEscolhida <> "" and RegiaoEscolhida <> "all" then
        locais = "0"
        sqlZona = "select group_concat(concat('UNIDADE_ID',id)) ids from sys_financialcompanyunits fc where  Regiao LIKE '%" & RegiaoEscolhida & "%' and (OcultoAgenda != 'S' OR OcultoAgenda IS NULL) "
        set zonas = db.execute(sqlZona)
        
        if not zonas.eof then 
            if zonas("ids")&"" <> "" then 
                locais = zonas("ids")
            end if 
        end if
    end if
    
    if ac("ProcedimentoID") <> "" then
        
        ParEspecialidadeID = ""
        ParEspecializacaoID = ""

        if ac("EspecialidadeID") <> "" then
            ParEspecialidadeID = ac("EspecialidadeID")
        end if 

        if ac("EspecializacaoID") <> "" then
            ParEspecializacaoID = ac("EspecializacaoID")
        end if 

        ProfissionalID2 = ProfissionalID&""
        call ocupacao(ref("Data"), (cdate(ref("Data"))+6), ParEspecialidadeID, ac("ProcedimentoID"), ProfissionalID2, "", locais, ParEspecializacaoID, ac("id"), "nao", sessaoAgenda)
        
    end if 
    ocor = 1
ac.movenext
wend

ac.close
set ac = nothing

linhaIndex = 0

set relatorio = db.execute("SELECT l.NomeLocal, ro.LocalID, ro.UnidadeID " &_
                            "FROM  agenda_horarios ro " &_
                            "LEFT JOIN locais l ON l.id = ro.LocalID " &_
                            "WHERE ro.Situacao = 'V' AND ro.sysUser="& session("User") & " AND ro.sessaoAgenda = '"&sessaoAgenda&"' GROUP BY UnidadeID  ORDER BY NomeLocal ")

if not relatorio.eof then
    htmlData = right(htmlData, len(htmlData)-1)
    datas = split(htmlData, ",")

    arrayDS = array("DOM","SEG","TER","QUA","QUI","SEX","SÁB")

    %>
    <table id="cartbusca" class="table table-condensed table-bordered mt5">
    <%

    while not relatorio.eof
        sql = "SELECT NomeFantasia, id, Enderecos Endereco FROM (SELECT 0 id, NomeFantasia, CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Enderecos, Regiao FROM empresa WHERE id=1 and (OcultoAgenda != 'S' OR OcultoAgenda IS NULL) UNION ALL SELECT id,NomeFantasia, CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Enderecos, Regiao FROM sys_financialcompanyunits WHERE sysActive=1 and (OcultoAgenda != 'S' OR OcultoAgenda IS NULL))t WHERE t.id="&relatorio("UnidadeID") 

        If RegiaoEscolhida <> "" Then
            sql = sql & " and t.Regiao ='"&RegiaoEscolhida&"'"
        End if

        set UnidadeSQL = db.execute(sql)
        NomeFantasia = ""
        UnidadeID = ""
        Endereco = ""
        if not UnidadeSQL.eof then
            NomeFantasia = UnidadeSQL("NomeFantasia")
            UnidadeID = UnidadeSQL("id")
            Endereco = UnidadeSQL("Endereco")
        end if
        if UnidadeID <> "" then 
%>
    <thead class="unidade">
<%
        procedimentosRelatorioSQL = "SELECT DISTINCT CarrinhoID " &_
                                    "FROM  agenda_horarios ro " &_
                                    "WHERE ro.Situacao = 'V' AND ro.sysUser="& session("User") & " AND ro.sessaoAgenda = '"&sessaoAgenda&"' AND ro.LocalID = " & relatorio("LocalID") & " ORDER BY ro.UnidadeID, ro.LocalID ASC "
        'response.write(procedimentosRelatorioSQL)        
        set procedimentosRelatorio = db.execute(procedimentosRelatorioSQL)

%>
    <tr class="preto" style="background: #555279">
        <td><span data-toggle="tooltip" title="<%=Endereco%>"><%=NomeFantasia%></span></td>
        <%
        for i=0 to ubound(datas)
            diadasemana = arrayDS(weekday(datas(i))-1)

            response.write("<td style='width: 13.5%'>" & datas(i) &" - " &diadasemana& "</td>")
        next
        %>
    </tr>
    </thead>
<%
    while not procedimentosRelatorio.eof 
    CarrinhoID = procedimentosRelatorio("CarrinhoID")
    set carrinhos = db.execute("SELECT IFNULL(NomeProcedimento, '') AS Procedimento, " &_ 
                                "    IFNULL(especialidade, '') AS NomeEspecialidade, " &_
                                "    IFNULL(NomeProfissional, '') AS Profissional, " &_
                                "    IFNULL(ac.ProcedimentoID, '') AS IdProcedimento, TabelaID, Zona  " &_
                                "    ,IFNULL(p.id, 0) AS IdProfissional  " &_
                                "FROM  agendacarrinho ac  " &_
                                "LEFT JOIN procedimentos pp ON pp.id = ac.ProcedimentoID " &_
                                "LEFT JOIN profissionais p ON p.id = ac.ProfissionalID " &_
                                "LEFT JOIN especialidades e ON e.id = ac.EspecialidadeID " &_
                                "WHERE ac.id = " & CarrinhoID)
    titulo = ""
    ProcedimentoID = 0
    TabelaID = 0
    IdProfissional=0
    Zona = ""

    if not carrinhos.eof then
        titulo = titulo + carrinhos("Procedimento")
        if carrinhos("NomeEspecialidade") <> "" then 
            titulo = titulo + " / " + carrinhos("NomeEspecialidade")
        end if

        if carrinhos("Profissional") <> "" then 
            titulo = titulo + " / " + carrinhos("Profissional")
        end if 
        ProcedimentoID = carrinhos("IdProcedimento")

        TabelaID = carrinhos("TabelaID")
        
        Zona = carrinhos("Zona")
    end if
%>
    <thead>
    <tr class="dark linha-item" style="cursor: pointer" data-value-propostaid="<%=PropostaID%>" data-index="<%=linhaIndex%>" data-value-zona="<%=Zona%>"  data-value-tabelaid="<%=TabelaID%>" data-value-procedimento="<%=ProcedimentoID%>" data-value-carrinho="<%=CarrinhoID%>" data-value-local="<%= relatorio("LocalID") %>" data-value-unidade="<%= relatorio("UnidadeID") %>" data-value-dias="<%=htmlData%>">
        <td><%=titulo%></td>
<%

    for i=0 to ubound(datas)
        if turno = "" then 
         sqlTotal = "SELECT DATA, UnidadeID, totalAgendamento, Turno " &_
                " FROM  " &_
                " ( " &_
                " SELECT DATA, UnidadeID, COUNT(*) totalAgendamento, 'M' Turno " &_
                " FROM agenda_horarios ro " &_
                " INNER JOIN agendacarrinho ac  " &_
                " ON ac.id = ro.CarrinhoID  " &_
                " WHERE ro.sysUser = " & session("User") & " "&_
                " AND ro.sessaoAgenda = '"&sessaoAgenda&"'"&_
                " AND CarrinhoID =  " & CarrinhoID  & " " &_
                " AND ac.ProcedimentoID = " & treatvalzero(ProcedimentoID)  & " " &_ 
                " AND ro.Hora <= '13:00:00' " &_
                " AND ro.Data = " & mydatenull(datas(i)) & " " &_
                " AND ro.UnidadeID = " & treatvalzero(relatorio("UnidadeID")) & " " &_
                " AND ro.Situacao = 'V' " &_
                " AND ro.Encaixe != '-1' " &_
                " GROUP BY UnidadeID, DATA " &_
                " UNION ALL " &_
                " SELECT DATA, UnidadeID, COUNT(*) totalAgendamento, 'T' Turno " &_
                " FROM agenda_horarios ro  " &_
                " INNER JOIN agendacarrinho ac  " &_
                " ON ac.id = ro.CarrinhoID " &_
                " WHERE ro.sysUser = "& session("User") & " " &_
                " AND ro.sessaoAgenda = '"&sessaoAgenda&"'"&_
                " AND CarrinhoID = " & CarrinhoID  & " "&_
                " AND ac.ProcedimentoID = " & treatvalzero(ProcedimentoID)  & " " &_
                " AND ro.Hora > '13:00:00' " &_
                " AND ro.Data = " & mydatenull(datas(i)) & " " &_
                " AND ro.UnidadeID = " & treatvalzero(relatorio("UnidadeID")) &_
                " AND ro.Situacao = 'V' " &_
                " AND ro.Encaixe != '-1' " &_
                " GROUP BY UnidadeID, DATA " &_
                " ) t " &_
                " ORDER BY UnidadeID, DATA, Turno "
        elseif turno = "Manha" then
         sqlTotal = "SELECT DATA, UnidadeID, totalAgendamento, Turno " &_
                " FROM  " &_
                " ( " &_
                " SELECT DATA, UnidadeID, COUNT(*) totalAgendamento, 'M' Turno " &_
                " FROM agenda_horarios ro " &_
                " INNER JOIN agendacarrinho ac  " &_
                " ON ac.id = ro.CarrinhoID  " &_
                " WHERE ro.sysUser = " & session("User") & " "&_
                " AND ro.sessaoAgenda = '"&sessaoAgenda&"'"&_
                " AND CarrinhoID =  " & CarrinhoID  & " " &_
                " AND ac.ProcedimentoID = " & treatvalzero(ProcedimentoID)  & " " &_ 
                " AND ro.Hora <= '13:00:00' " &_
                " AND ro.Data = " & mydatenull(datas(i)) & " " &_
                " AND ro.UnidadeID = " & treatvalzero(relatorio("UnidadeID")) & " " &_
                " AND ro.Situacao = 'V' " &_
                " AND ro.Encaixe != '-1' " &_
                " GROUP BY UnidadeID, DATA " &_
                " ) t " &_
                " ORDER BY UnidadeID, DATA, Turno "
        else

            sqlTotal = "SELECT DATA, UnidadeID, totalAgendamento, Turno " &_
                " FROM  " &_
                " ( " &_
                " SELECT DATA, UnidadeID, COUNT(*) totalAgendamento, 'T' Turno " &_
                " FROM agenda_horarios ro " &_
                " INNER JOIN agendacarrinho ac  " &_
                " ON ac.id = ro.CarrinhoID  " &_
                " WHERE ro.sysUser = " & session("User") & " "&_
                " AND ro.sessaoAgenda = '"&sessaoAgenda&"'"&_
                " AND CarrinhoID =  " & CarrinhoID  & " " &_
                " AND ac.ProcedimentoID = " & treatvalzero(ProcedimentoID)  & " " &_ 
                " AND ro.Hora > '13:00:00' " &_
                " AND ro.Data = " & mydatenull(datas(i)) & " " &_
                " AND ro.UnidadeID = " & treatvalzero(relatorio("UnidadeID")) & " " &_
                " AND ro.Situacao = 'V' " &_
                " AND ro.Encaixe != '-1' " &_
                " GROUP BY UnidadeID, DATA " &_
                " ) t " &_
                " ORDER BY UnidadeID, DATA, Turno "
        end if

        sqlTemEncaixe = "SELECT COUNT(DATA) total " &_
                " FROM agenda_horarios ro " &_
                " INNER JOIN agendacarrinho ac ON ac.id = ro.CarrinhoID  " &_
                " WHERE ro.sysUser = " & session("User") & " "&_
                " AND ro.sessaoAgenda = '"&sessaoAgenda&"'"&_
                " AND CarrinhoID =  " & CarrinhoID  & " " &_
                " AND ac.ProcedimentoID = " & treatvalzero(ProcedimentoID)  & " " &_ 
                " AND ro.Data = " & mydatenull(datas(i)) & " " &_
                " AND ro.UnidadeID = " & treatvalzero(relatorio("UnidadeID")) & " " &_
                " AND ro.Encaixe = '1' " &_
                " GROUP BY UnidadeID, DATA " 
        'response.write("<hr>"&sqlTotal)
        set totais = db.execute(sqlTotal)
        set temEncaixe = db.execute(sqlTemEncaixe)
        dia = ""
        lblEncaixe = ""
        classEncaixe = ""
            if not temEncaixe.eof then 
                if ccur(temEncaixe("total")) > 0 then 
                    lblEncaixe   = " (E)"
                    classEncaixe = "bg-success"
                end if
            end if
        if totais.eof then 
            response.write("<td class='" & classEncaixe & "' style='width: 12%'>0M 0T"&lblEncaixe&"</td>")
        end if 
        temTotal = 0
        while not totais.eof 
            temTotal = 1
            classe = ""

            if dia = ""  then
                response.write("<td class='bg-success' style='width: 12%'>")
                dia = totais("DATA")
            end if
            if dia <> totais("DATA") then
                response.write(lblEncaixe&"</td><td class='bg-success' style='width: 12%'>")
                dia = totais("DATA")
            end if
            response.write(totais("totalAgendamento") & totais("Turno") & " ")
            totais.movenext
        wend
        if temTotal = 1 then 
            response.write(lblEncaixe&"</td>")
        end if
    next

%>
    </tr>
    </thead>
    <tbody id="detalhes-<%=linhaIndex%>" class="profissionaisDetalhes" style="display: none">
    </tbody>    
<%
    linhaIndex = linhaIndex + 1
    procedimentosRelatorio.movenext
    wend 
%>
<%
    end if
    relatorio.movenext
%>
<%
    wend
end if
%>
</table>

<div class="row mt20">
<div class="col-md-offset-2 col-md-2">
    <button onclick="buscarDias('menosdias')" type="button" class="btn btn-default btn-xs btn-block"><i class="far fa-minus"></i> Menos dias</button>
</div>

<div class="col-md-4">
    <button onclick="buscarAllZonas()" type="button" class="btn btn-primary btn-xs btn-block"> Mais regiões</button>
</div>

<div class="col-md-2">
    <button onclick="buscarDias()" type="button" class="btn btn-default btn-xs btn-block"><i class="far fa-plus"></i> Mais dias</button>
</div>
</div>

<script>

    $(document).ready(function(){
        $('[data-toggle="tooltip"]').tooltip();   
    });

    $(function(){
        const detalhesRequests = {};
        $(".linha-item").on("click", function(){
            var elem     = $(this);
            var index    = elem.data('index');
            var elemBody = $('#detalhes-' + index);
            
            if (!elem.data('loading')) {

                $('.profissionaisDetalhes:not(#detalhes-' + index + ')').hide();
                for (let req of Object.keys(detalhesRequests)) {
                    if (req !== index) {
                        detalhesRequests[req].abort();
                        $('.linha-item[data-index=' + index + ']').data('loading', '');
                    }
                }
                
                if(!elemBody.is(":visible")){
                    elemBody.show();
                    elemBody.html('<tr><td class="text-center" colspan="8"><i class="far fa-circle-o-notch fa-spin"></i> Carregando...</td></tr>');
                    elem.data('loading', true);

                    detalhesRequests[index] = $.post('buscarProfissionalAgenda.asp', {
                        CarrinhoID : $(this).attr("data-value-carrinho"),
                        LocalID: $(this).attr("data-value-local"),
                        UnidadeID : $(this).attr("data-value-unidade"),
                        Dias : $(this).attr("data-value-dias"),
                        ProcedimentoID : $(this).attr("data-value-procedimento"),
                        tabelaid : $(this).attr("data-value-tabelaid"),
                        zona : $(this).attr("data-value-zona"),
                        PropostaID: $(this).attr("data-value-propostaid")
                    }, function(data){
                        elemBody.html(data);
                        elem.data('loading', '');
                        delete detalhesRequests[index];
                    }).fail(function() {
                        elemBody.hide();
                        elem.data('loading', '');
                        delete detalhesRequests[index];
                    });
                }else{
                    elemBody.hide();
                    elemBody.html('');
                }
            }
            
        });
        <% if turno = "Manha" then %>
            $(".btnmanha").addClass("active")
        <% elseif turno = "Tarde" then %>
            $(".btntarde").addClass("active")
        <% end if %>
    })

    function obs(ProfissionalID, obj) {

        $.get("ObsAgenda.asp?ProfissionalID=" + ProfissionalID, function (data) {
            
            $("#modalObservacao").modal("show")
            $(".modalObservacaoBody").html(data)

        });
    }
</script>