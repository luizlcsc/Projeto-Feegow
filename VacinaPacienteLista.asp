
<!--#include file="connect.asp"-->
<style>
.observacao + .tooltip > .tooltip-inner {
  background-color: #FFFFFF; 
  color: #000000; 
  border: 1px solid gray;
  padding: 8px;
  font-size: 13px!important;
  max-width:600px;
}
</style>
<%
PacienteID = ref("PacienteID")
Status = ref("Status")

whereAnd = " AND vps.sysActive = 1 "

if Status = "Pendentes" then

    whereAnd = " AND vps.sysActive = 1 "&_
               " AND (SELECT COUNT(*) "&_
               "        FROM vacina_aplicacao va "&_
               "       WHERE va.VacinaPacienteSerieID = vps.id "&_
               "         AND va.StatusID IN (1,2)) > 0"

elseif Status = "Aplicadas" then

    whereAnd = " AND vps.sysActive = 1 "&_
               " AND (SELECT COUNT(*) "&_
               "        FROM vacina_aplicacao va "&_
               "       WHERE va.VacinaPacienteSerieID = vps.id "&_
               "         AND va.StatusID = 3) > 0 "&_
               " AND (SELECT COUNT(*) "&_
               "        FROM vacina_aplicacao va "&_
               "       WHERE va.VacinaPacienteSerieID = vps.id "&_
               "         AND va.StatusID IN (1,2)) = 0 "

elseif Status = "Canceladas" then

    whereAnd = " AND vps.sysActive = 1 "&_
               " AND (SELECT COUNT(*) "&_
               "        FROM vacina_aplicacao va "&_
               "       WHERE va.VacinaPacienteSerieID = vps.id "&_
               "         AND va.StatusID = 4) > 0 "&_
               " AND (SELECT COUNT(*) "&_
               "        FROM vacina_aplicacao va "&_
               "       WHERE va.VacinaPacienteSerieID = vps.id "&_
               "         AND va.StatusID IN (1,2,3)) = 0 "
end if

                set series = db.execute(" SELECT vs.titulo, "&_
                                        " vs.id, "&_ 
                                        " vps.id AS VacinaPacienteID, "&_ 
                                        " p.NomeProcedimento, "&_
                                        " vs.VacinaID, "&_
                                        " v.ContraIndicacoes, "&_
                                        " v.Cuidados, "&_
                                        " v.Reacoes, "&_
                                        " vps.Observacao "&_
                                        " FROM vacina_serie vs "&_
                                        " JOIN vacina v ON v.id = vs.VacinaID "&_
                                        " JOIN procedimentos p ON p.id = v.ProcedimentoID "&_
                                        " JOIN vacina_paciente_serie vps ON vps.SerieID = vs.id "&_
                                        " WHERE vps.PacienteID = "&PacienteID&whereAnd)

                while not series.EOF

                    Observacao = series("Observacao")

                    set permiteExcluir = db.execute(" SELECT COUNT(*) AS total "&_
                                                    " FROM vacina_aplicacao va "&_
                                                    " JOIN vacina_paciente_serie vps ON vps.id = va.VacinaPacienteSerieID "&_
                                                    " JOIN vacina_serie_dosagem vsd ON vsd.SerieID = vps.SerieID AND vsd.id = va.VacinaSerieDosagemID "&_
                                                    " WHERE vps.sysActive = 1 "&_ 
                                                    " AND va.StatusID IN (3) "&_
                                                    " AND vps.PacienteID = "&PacienteID&_
                                                    " AND vps.id = "&series("VacinaPacienteID"))
%>
                    <br>
                    <table class="table">
                        <thead class="thead-light">
                            <tr class="table=active">
                                <th>Vacina: <%=series("NomeProcedimento")%> <button class="btn btn-info btn-xs" type="button" data-toggle="collapse" data-target="#detalheVacina-<%=series("VacinaPacienteID")%>">Detalhes</button> / Série: <%=series("titulo")%> <% if Observacao <> "" then response.write(" <a href='#'> <span class='observacao far fa-info-circle bigger-110' data-toggle='tooltip' data-original-title='"&Observacao&"'></span></a>") end if %></th>
                                <th width="10%" style="text-align:right"><% if permiteExcluir("total") = "0" and aut("vacinapacienteX") then %><button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="javascript:if(confirm('Tem certeza de que deseja excluir este pedido de vacina?'))excluirSerie(<%=series("VacinaPacienteID")%>)"><i class="far fa-trash"></i></button> <% end if %></th>
                            </tr>
                        </thead>
                    </table>
                    <div class="collapse" id="detalheVacina-<%=series("VacinaPacienteID")%>">
                        <div class="card card-body">
                            <table class="table table-bordered">
                                <thead>
                                    <tr class="info">
                                        <th width="25%">Contraindicação</th>
                                        <th width="35%">Reações</th>
                                        <th width="40%">Cuidados</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>
                                            <%=series("ContraIndicacoes")%>
                                        </td>
                                        <td>
                                            <%=series("Reacoes")%>
                                        </td>
                                        <td>
                                            <%=series("Cuidados")%>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <br>
                        </div>
                    </div>
                    
                    <table class="table table-hover table-bordered table-striped">
                        <thead>
                            <tr class="primary">
                                <th width="10%">Status</th>
                                <th width="8%">Previsão</th>
                                <th width="5%">Ordem</th>
                                <th width="12%">Dose</th>
                                <th width="5%">Via</th>
                                <th width="8%">Lado</th>
                                <th width="22%">Unidade</th>
                                <th width="12%">Administrado por</th>
                                <th width="10%">Administrado</th>
                                <% if aut("vacinapacienteA") then %>
                                <th width="8%"></th>
                                <% end if %>
                            </tr>
                        </thead>
                        <tbody>
<%                      
                    permiteExcluir.close
                    set permiteExcluir = nothing
                    set dosagens = db.execute( " SELECT va.id, "&_
                                                " vs.id as SerieID, "&_
                                                " vas.NomeStatus, "&_ 
                                                " va.StatusID, "&_
                                                " DATE_FORMAT(va.DataPrevisao, '%d/%m/%Y') AS DataPrevista, "&_
                                                " vsd.Ordem, "&_
                                                " p.NomeProduto AS Dosagem, "&_
                                                " vsd.Descricao, "&_
                                                " va.UsuarioIDAplicacao, va.Lote, va.id AS VacinaAplicacaoID, "&_
                                                " vps.id AS VacinaPacienteSerieID, "&_
                                                " va.Observacao AS Observacao, "&_
                                                " vva.SiglaViaAplicacao, vva.NomeViaAplicacao, "&_
                                                " (CASE WHEN va.LadoAplicacao = 1 THEN 'Direito' WHEN va.LadoAplicacao = 2 THEN 'Esquerdo' END) AS LadoAplicacao, "&_
                                                " e.NomeFantasia, "&_
                                                " DATE_FORMAT(va.DataAplicacao, '%d/%m/%Y') AS DataAplicacao "&_
                                                " FROM vacina_serie_dosagem vsd "&_ 
                                                " JOIN produtos p ON p.id = vsd.ProdutoID "&_
                                                " JOIN vacina_serie vs ON vs.id = vsd.SerieID "&_
                                                " JOIN vacina_paciente_serie vps ON vps.SerieID = vs.id "&_
                                                " JOIN vacina_aplicacao va ON va.VacinaPacienteSerieID = vps.id AND va.VacinaSerieDosagemID = vsd.id "&_
                                                " JOIN vacina v ON v.id = vs.VacinaID "&_
                                                " JOIN cliniccentral.vacina_aplicacao_status vas ON vas.id = va.StatusID "&_
                                                " LEFT JOIN cliniccentral.vacina_via_aplicacao vva ON vva.id = va.ViaAplicacaoID "&_
                                                " LEFT JOIN (SELECT 0 AS id, NomeFantasia FROM empresa UNION SELECT id, NomeFantasia FROM sys_financialcompanyunits) e ON e.id = va.UnidadeID"&_
                                                " WHERE vps.sysActive = 1 "&_
                                                " AND vs.id = "&series("id")&_
                                                " AND vps.PacienteID = "&PacienteID&_
                                                " AND vps.id ="&series("VacinaPacienteID")&_
                                                " ORDER BY vps.id, vsd.Ordem ")

                    while not dosagens.EOF

                        administradoPor = ""
                        tratamento = ""
                        aplicacaoObservacao = dosagens("Observacao")

                        if dosagens("UsuarioIDAplicacao") > 0 then

                            usuario = db.execute("SELECT su.Table, su.NameColumn, su.idInTable FROM sys_users su WHERE id = "&dosagens("UsuarioIDAplicacao"))

                            if usuario("Table") = "profissionais" then
                                administradoPor = db.execute("SELECT t.Tratamento, (IF (COALESCE(trim(NomeSocial), p.NomeProfissional)='',p.NomeProfissional,COALESCE(trim(NomeSocial), p.NomeProfissional))) AS descricao FROM profissionais p LEFT JOIN tratamento t on t.id = p.TratamentoID WHERE p.id = "&usuario("idInTable"))
                                tratamento = administradoPor("Tratamento")&" "&administradoPor("descricao")
                            else
                                administradoPor = db.execute("SELECT "&usuario("NameColumn")&" AS descricao FROM "&usuario("Table")&" WHERE id ="&usuario("idInTable"))
                                tratamento = administradoPor("descricao")
                            end if
                        end if

                        select case dosagens("StatusID")
                            case "1"
                                spanClass = "badge-warning"
                            case "2"
                                spanClass = "badge-primary"
                            case "3"
                                spanClass = "badge-success"
                            case "4"
                                spanClass = "badge-danger"
                        end select
%>
                    <tr>
                        <td><span class="badge <%=spanClass%>"><%=dosagens("NomeStatus")%></span></td>
                        <td style="text-align: center"><%=dosagens("DataPrevista")%> <p></td>
                        <td style="text-align: center"><%=dosagens("Ordem")%></td>
                        <td><%=dosagens("Dosagem")%>
                            <% if aplicacaoObservacao <> "" then %>
                                <a href='#' onclick="modalVacinaPaciente('VacinaPacienteAplicacao.asp?StatusID=<%=dosagens("StatusID")%>&DataAplicacao=<%=dosagens("DataAplicacao")%>&NomeViaAplicacao=<%=dosagens("NomeViaAplicacao")%>&LadoAplicacao=<%=dosagens("LadoAplicacao")%>&Unidade=<%=dosagens("NomeFantasia")%>&Dose=<%=dosagens("Dosagem")%>&Observacao=<%=aplicacaoObservacao%>', <%= PacienteID%>, <%= dosagens("id")%>, '', '');">
                                    <span class='observacao far fa-info-circle bigger-110' data-toggle='tooltip' data-original-title='<%=aplicacaoObservacao%>'></span>
                                </a>
                            <% end if %>
                        </td>
                        <td style="text-align: center"><%=dosagens("SiglaViaAplicacao")%></td>
                        <td><%=dosagens("LadoAplicacao")%></td>
                        <td><%=dosagens("NomeFantasia")%></td>
                        <td><%=tratamento%></td>
                        <td style="text-align:center"><%=dosagens("DataAplicacao")%></td>
                        <% if aut("vacinapacienteA") then %>
                        <td style="text-align:center">
<%
                            if (dosagens("StatusID") = 1 or dosagens("StatusID") = 2) then
%>
                            <button type="button" class="btn btn-xs btn-success" onclick="modalVacinaPaciente('VacinaPacienteAplicacao.asp', <%= PacienteID%>, <%= dosagens("id")%>, '', '');"><li class="glyphicon glyphicon-pushpin"></li></button>
                            <button type="button" class="btn btn-xs btn-info" onclick="modalVacinaPaciente('VacinaPacienteAlteracao.asp', <%= PacienteID%>, <%= dosagens("id")%>, <%= dosagens("VacinaPacienteSerieID")%>, <%= dosagens("Ordem")%>);"><i class="far fa-edit icon-edit bigger-125"></i></button>
<%
                            end if
%>
                        </td>
                        <% end if %>
                    </tr>
<%
                        dosagens.movenext
                    wend
                    dosagens.close
                    set dosagens = nothing

                    series.movenext
                    %> </tbody></table> <%
                wend

                series.close
                set series = nothing
%>
<script>
$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});
</script>