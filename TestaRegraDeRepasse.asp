<!--#include file="connect.asp"-->
<%
ID = req("I")
ExibirRegras = req("ExibirRegras")
Tabela = req("Tabela")


function badgeParametroStatus(valor, nomeCampo)
    cor="default"
    icon=""
    msg=""

     if Valor="INDEFINIDO" then
        cor="grey"
        icon="fa-minus-circle"
        msg=""
     elseif Valor="INVALIDO" then
        cor="red"
        icon="fa-times-circle"
        msg="Valor inválido para "&nomeCampo&": regra cancelada"
     elseif Valor="OK" then
        cor="green"
        icon="fa-check-circle"
        msg="Valor válido para "&nomeCampo
     end if


    badgeParametroStatus="<span data-toggle='tooltip' title='"&msg&"'> "&_
     "  <i class='fa "&icon&"' style='color: "&cor&"'></i>  "&_
     "</span>"

end function

if Tabela="sys_financialinvoices" or Tabela="itensinvoice" then
    if Tabela="itensinvoice" then
        whereInvoice = "ii.id="&ID
    end if
    if Tabela="sys_financialinvoices" then
        whereInvoice = "i.id="&ID
    end if

    set AtendimentoSQL = db.execute("SELECT COALESCE(CONCAT('P',FormaID,'_',ContaRectoID),'|P|') FormaID,  ii.id IDItem, ii.EspecialidadeID, ii.InvoiceID, ii.Quantidade, ii.ValorUnitario , ii.Executado, esp.especialidade, CONCAT(ii.Associacao,'_',ii.ProfissionalID) ExecutanteID, "&_
                                    "sp_accountname(ii.ProfissionalID, ii.Associacao) executante, NULL Forma, "&_
                                    "i.TabelaID, tab.NomeTabela, u.id UnidadeID, u.NomeFantasia, proc.GrupoID, pg.NomeGrupo, proc.id ProcedimentoID, proc.NomeProcedimento, "&_
                                    "NULL ConvenioID, NULL NomeConvenio,ii.DataExecucao, pac.NomePaciente, null FormaPagto "&_
                                    " "&_
                                    "FROM itensinvoice ii "&_
                                    "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                                    "LEFT JOIN pacientes pac ON pac.id=i.AccountID AND i.AssociationAccountID=3 "&_
                                    "LEFT JOIN especialidades esp ON esp.id=ii.EspecialidadeID "&_
                                    "LEFT JOIN tabelaparticular tab ON tab.id=i.TabelaID "&_
                                    "LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                                    "LEFT JOIN procedimentosgrupos pg ON pg.id=proc.GrupoID "&_
                                    "LEFT JOIN vw_unidades u ON u.id=i.CompanyUnitID "&_
                                    " "&_
                                    "WHERE "&whereInvoice)
end if


%>
<style>
#table-detalhes-dominios-repasse.table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
    padding: 2px;
    font-size: 11px;
}
</style>
<br>
<div class="row">
    <div class="col-md-12">
        <p>Regras que se enquadram no atendimento:</p>

        <table id="table-detalhes-dominios-repasse" class="table-responsive table table-striped table-hover table-bordered">
            <thead>
                <tr class="primary">
                    <th>RegraID</th>
                    <th>Data</th>
                    <th>Especialidade</th>
                    <th>Executante</th>
                    <th>Forma de pagamento</th>
                    <th>Tabela Particular</th>
                    <th>Unidade</th>
                    <th>Procedimento</th>
                    <th>Grupo de procedimento</th>
                    <th>Convênio</th>
                    <th>Dia da Semana</th>
                    <th>Inválido</th>
                    <th>Pontuação</th>
                </tr>
            </thead>
            <tbody>
                <%
                while not AtendimentoSQL.eof
                    Pontuacao=0
                    FormaID= AtendimentoSQL("FormaID")
                    IDItem= AtendimentoSQL("IDItem")

                    ProfissionalID= AtendimentoSQL("ExecutanteID")
                    ProcedimentoID=AtendimentoSQL("ProcedimentoID")
                    UnidadeID=AtendimentoSQL("UnidadeID")
                    TabelaID=AtendimentoSQL("TabelaID")
                    EspecialidadeID=AtendimentoSQL("EspecialidadeID")
                    DataExec=AtendimentoSQL("DataExecucao")
                    HoraExec=""
                    %>
                    <tr class="dark ">
                        <th class="text-center">-</th>
                        <th class="text-center"><%=AtendimentoSQL("DataExecucao")%></th>
                        <th class="text-center"><%=AtendimentoSQL("especialidade")%></th>
                        <th class="text-center"><%=AtendimentoSQL("executante")%></th>
                        <th class="text-center"><%=AtendimentoSQL("FormaPagto")%></th>
                        <th class="text-center"><%=AtendimentoSQL("NomeTabela")%></th>
                        <th class="text-center"><%=AtendimentoSQL("NomeFantasia")%></th>
                        <th class="text-center"><%=AtendimentoSQL("NomeProcedimento")%></th>
                        <th class="text-center"><%=AtendimentoSQL("NomeGrupo")%></th>
                        <th class="text-center"><%=AtendimentoSQL("NomeConvenio")%></th>
                        <th class="text-center"></th>
                        <th class="text-center"></th>
                        <th class="text-center"><%=Pontuacao%></th>
                    </tr>
                    <%
                    FormaID = replace(FormaID, "|", "")

                    'conferir -> FormaID pode ser |P| para todos particulares, |C| para todos convênios, |00_0| para forma predefinida de recto e > |0| para qualquer id de convênio
                    RegraRepasseSelecionada = 0
                    EspecialidadeIDsent = EspecialidadeID&""
                    pontomaior = 0
                    ProfissionalID= replace(ProfissionalID, "5_","")

                    set pprofs = db.Execute("select GrupoID from profissionais where not isnull(GrupoID) and GrupoID<>0 and id="& treatvalzero(ProfissionalID))
                    if not pprofs.eof then
                        GrupoProfissionalID = pprofs("GrupoID")
                    end if

                    set pproc = db.Execute("select GrupoID from procedimentos where not isnull(GrupoID) and GrupoID<>0 and id="& treatvalzero(ProcedimentoID))
                    if not pproc.eof then
                        GrupoProcedimentoID = "-"& pproc("GrupoID")
                    end if

                    if ProfissionalID&""<>"" and isnumeric(ProfissionalID&"") then
                        set vesp = db.execute("select EspecialidadeID from profissionais where id="& ProfissionalID&" and not isnull(EspecialidadeID) and EspecialidadeID<>0")
                        if not vesp.eof then
                            EspecialidadeID = "-"& vesp("EspecialidadeID")
                        else
                            EspecialidadeID = ""
                        end if
                    end if
                    'se a especialidade for valida postada leva em conta a postada
                    if EspecialidadeIDsent<>"" and isnumeric(EspecialidadeIDsent) and EspecialidadeIDsent<>"0" then
                        EspecialidadeID = "-"& EspecialidadeIDsent
                    end if


                    sqlDomIds = ""

                    if ExibirRegras<>"" then
                        sqlDomIds = " and id IN ("&ExibirRegras&")"
                    end if

                    set dom = db.execute("select * from rateiodominios WHERE "&_
                    "(IFNULL(Unidades,'')='' or Unidades LIKE '%|"&UnidadeID&"|%') "&_
                    " AND (IFNULL(Tabelas,'')='' or Tabelas LIKE '%|"&TabelaID&"|%') "&_
                    " AND ((IFNULL(Profissionais,'')='' or Profissionais LIKE '%|"&ProfissionalID&"|%') or "&_
                    "  (IFNULL(Profissionais,'')='' or Profissionais LIKE '%|"&EspecialidadeID&"|%'))"&_

                    " AND ((IFNULL(Procedimentos,'')='' or Procedimentos LIKE '%|"&ProcedimentoID&"|%') OR "&_
                    "  (IFNULL(Procedimentos,'')='' or Procedimentos LIKE '%|"&GrupoProcedimentoID&"|%')) "&_
                    "  "&sqlDomIds&" "&_
                    "order by Tipo desc")

                    if dom.eof then
                        %>
                        <tr><td colspan="13" class="text-center">Nenhuma regra encontrada.</td></tr>
                        <%
                    else

                        while not dom.eof
                            TabelaOK = "INDEFINIDO"
                            UnidadeOK = "INDEFINIDO"
                            FormaOK = "INDEFINIDO"
                            GrupoProfissionalOK = "INDEFINIDO"
                            DataOK = "INDEFINIDO"
                            HoraOK = "INDEFINIDO"
                            ProfissionalOK = "INDEFINIDO"
                            EspecialidadeOK = "INDEFINIDO"
                            ProcedimentoOK = "INDEFINIDO"
                            ConvenioOK = "INDEFINIDO"
                            GrupoProcedimentoOK = "INDEFINIDO"


                            Tabelas = dom("Tabelas")&""
                            Unidades = dom("Unidades")&""
                            Formas = dom("Formas")&""
                            GruposProfissionais = dom("GruposProfissionais")&""
                            Dias = dom("Dias")&""
                            Horas = dom("Horas")&""


                            esteponto = 0
                            queima = 0


                            if instr(Formas, "|"&FormaID&"|")>0 then
                                esteponto = esteponto+1
                                FormaOK = "OK"
                            else
                                if trim(Formas)<>"" then
                                    if instr(FormaID, "_") and instr(Formas, "|P|")>0 then
                                        queima = 0
                                    else
                                        queima = 1
                                        FormaOK = "INVALIDO"
                                    end if
                                end if
                            end if

                            if instr(Tabelas, "|"&TabelaID&"|")>0 then
                                esteponto = esteponto+1
                                TabelaOK = "OK"
                            else
                                if Tabelas<>"" then
                                    queima = 1
                                    TabelaOK = "INVALIDO"
                                end if
                            end if

                            if instr(dom("Profissionais"), "|"&replace(ProfissionalID&"", "5_", "")&"|")>0 or instr(dom("Profissionais"), "|"&EspecialidadeID&"|")>0 then
                                if instr(dom("Profissionais"), "|"&replace(ProfissionalID&"", "5_", "")&"|")>0 then
                                    esteponto = esteponto+1
                                    ProfissionalOK = "OK"
                                end if

                                if instr(dom("Profissionais"), "|"&EspecialidadeID&"|")>0 then
                                    esteponto = esteponto+1
                                    EspecialidadeOK = "OK"
                                end if
                            else
                                if trim(dom("Profissionais"))<>"" then
                                    queima = 1
                                    ProfissionalOK = "INVALIDO"
                                end if
                            end if
                            Procedimentos = dom("Procedimentos")
                            if instr(Procedimentos, "|"&ProcedimentoID&"|")>0 then
                                esteponto = esteponto+1
                                ProcedimentoOK = "OK"
                            else
                                if trim(Procedimentos)<>"" then
                                    'antes de queimar, ve o grupo desse procedimento e incrementa ou queima
                                    if GrupoProcedimentoID<>"" then
                                        if instr(Procedimentos, "|"&GrupoProcedimentoID&"|")>0 then
                                            esteponto = esteponto+1
                                            GrupoProcedimentoOK = "OK"
                                        else
                                            GrupoProcedimentoOK = "INVALIDO"
                                            queima = 1
                                        end if
                                    else
                                        ProcedimentoOK = "INVALIDO"
                                        queima = 1
                                    end if
                                end if
                            end if

                            if Tabelas<>"" and isnumeric(FormaID&"") and instr(Formas, "|"& FormaID &"|")=0 then
                                queima = 1
                                TabelaOK = "INVALIDO"
                            end if

                            if trim(GruposProfissionais)<>"" then

                                'antes de queimar, ve o grupo desse procedimento e incrementa ou queima

                                if GrupoProfissionalID<>"" then

                                    if instr(GruposProfissionais, "|"&GrupoProfissionalID&"|")>0 then
                                        esteponto = esteponto+1
                                        GrupoProfissionalOK="OK"

                                    else
                                        queima = 1
                                        GrupoProfissionalOK="INVALIDO"
                                    end if
                                else
                                    queima = 1
                                    GrupoProfissionalOK="INVALIDO"
                                end if
                            end if
                            if instr(Unidades, "|"&UnidadeID&"|")>0 then
                                esteponto = esteponto+1
                                UnidadeOK = "OK"
                            else
                                if trim(Unidades)<>"" then
                                    queima = 1
                                    UnidadeOK = "INVALIDO"
                                end if
                            end if
                            if isDate(DataExec&"") and trim(Dias)<>"" then
                                if instr(Dias, weekday(DataExec))>0 then
                                    esteponto = esteponto+1
                                    DataOK = "OK"
                                else
                                    queima = 1
                                    DataOK = "INVALIDO"
                                end if
                            end if

                            if queima=0 and esteponto>pontomaior then
                                RegraRepasseSelecionada = IDItem&"_"&dom("id")
                                pontomaior = esteponto
                            end if

                            TabelaBadge = badgeParametroStatus(TabelaOk, "Tabela")
                            UnidadeBadge = badgeParametroStatus(UnidadeOK, "Unidade")
                            FormaBadge = badgeParametroStatus(FormaOK, "Forma")
                            GrupoProfissionalBadge = badgeParametroStatus(GrupoProfissionalOk, "GrupoProfissional")
                            DataBadge = badgeParametroStatus(DataOK, "Data")
                            HoraBadge = badgeParametroStatus(HoraOK,"Hora")
                            ProfissionalBadge = badgeParametroStatus(ProfissionalOK,"Profissional")
                            EspecialidadeBadge = badgeParametroStatus(EspecialidadeOK,"Especialidade")
                            ProcedimentoBadge = badgeParametroStatus(ProcedimentoOK,"Procedimento")
                            GrupoProcedimentoBadge = badgeParametroStatus(GrupoProcedimentoOK,"GrupoProcedimento")
                            ConvenioBadge = badgeParametroStatus(ConvenioOK,"Convenio")

                            ClasseLinha = ""
                            DescricaoResultado=""

                            if queima=1 then
                                ClasseLinha="danger"
                                DescricaoResultado="Inválido"
                            end if
                            %>
                            <tr class=" linha-dominio" data-id="<%=IDItem&"_"&dom("id")%>">
                                <th class="text-center"><code>#<%=dom("id")%></code></th>
                                <td class="text-center"><%=DataBadge%></td>
                                <td class="text-center"><%=EspecialidadeBadge%></td>
                                <td class="text-center"><%=ProfissionalBadge%></td>
                                <td class="text-center"><%=FormaBadge%></td>
                                <td class="text-center"><%=TabelaBadge%></td>
                                <td class="text-center"><%=UnidadeBadge%></td>
                                <td class="text-center"><%=ProcedimentoBadge%></td>
                                <td class="text-center"><%=GrupoProcedimentoBadge%></td>
                                <td class="text-center"><%=ConvenioBadge%></td>
                                <td class="text-center"></td>
                                <th class="<%=ClasseLinha%> text-center"><%=DescricaoResultado%></th>
                                <th class="text-center"><%=esteponto%></th>
                            </tr>
                            <%
                        dom.movenext
                        wend
                        dom.close
                        set dom = nothing
                    end if

                    %>
<script >
$(document).ready(function(){
    var dominioSelecionado = '<%=RegraRepasseSelecionada%>';

    $(`.linha-dominio[data-id='${dominioSelecionado}']`).addClass("success");
});
</script>
                    <%

                AtendimentoSQL.movenext
                wend
                AtendimentoSQL.close
                set AtendimentoSQL=nothing
                %>
            </tbody>
        </table>
    </div>
</div>
<script >
    $(document).ready(function(){
        $('[data-toggle="tooltip"]').tooltip();
    });
</script>