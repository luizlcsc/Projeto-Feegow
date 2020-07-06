﻿<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
if ref("De")<>"" then
    De = ref("De")
else
    De = date()-30
end if
if ref("Ate")<>"" then
    Ate = ref("Ate")
else
    Ate = date()
end if
%>
<style>
    .whatsApp-Ativo{
        text-decoration: underline;
        color: cornflowerblue;
        cursor: pointer;
    }
</style>
<table class="table table-condensed table-hover table-striped table-condensed">
    <thead>
        <tr class="primary">
            <th width="1%">
                <div class="radio-custom square radio-primary mt5">
                  <input type="checkbox" name="cklaudostodos" id="cklaudostodos" class="cklaudostodos" value="<%= link %>" />
                  <label for="cklaudostodos">&nbsp;</label>
                </div>
            </th>
            <th>Identificação</th>
            <th>Data</th>
            <th>Prev. Entrega</th>
            <th>Paciente</th>
            <th>Celular</th>
            <th>Profissional</th>
            <th>Procedimento</th>
            <th>Convênio</th>
            <th>Status</th>
            <th width="1%"></th>
            <th width="5%"></th>
        </tr>
    </thead>
    <tbody>
    <%
    set GroupMarketplaceSetup = db.execute("SET SESSION group_concat_max_len = 1000000;")
    set pProcsLaudar = db.execute("select group_concat(id) ProcsLaudar from procedimentos WHERE Laudo=1 AND Ativo='on'")
    procsLaudar = pProcsLaudar("ProcsLaudar")
        'response.write(procsLaudar)
    Procedimentos = ""
    if isnull(procsLaudar) then
        %>
        <tr>
            <td colspan="9">
                <em>Nenhum procedimento com laudo habilitado. Habilite a opção de laudo no cadastro dos procedimentos em que deseja utilizar este recurso.</em>
            </td>
        </tr>
        <%

    else
        if ref("ProcedimentoID")<>"0" then
            if instr(ref("ProcedimentoID"), "G")=0 then
                sqlProcP = " AND ii.ItemID="& ref("ProcedimentoID") &" "
                sqlProcGS = " AND gps.ProcedimentoID="& ref("ProcedimentoID") &" "
                Procedimentos = ref("ProcedimentoID")
            else
                set gp = db.execute("select group_concat(id) Procedimentos from procedimentos where Laudo=1 AND GrupoID="& replace(ref("ProcedimentoID"), "G", ""))
                Procedimentos = gp("Procedimentos") &""
                if Procedimentos="" then
                    Procedimentos = 0
                end if
                sqlProcP = " AND ii.ItemID IN("& Procedimentos &") "
                sqlProcGS = " AND gps.ProcedimentoID IN("& Procedimentos &") "
            end if
        end if
        if ref("PacienteID")<>"" then
            sqlPacP = " AND i.AccountID="& ref("PacienteID") &" "
            sqlPacGS = " AND gs.PacienteID="& ref("PacienteID") &" "
        end if

        if ref("Unidades")<>"" then
            Unidades = replace(ref("Unidades"),"|","")


            sqlUnidadesP = " AND i.CompanyUnitID IN ("& Unidades &") "
            sqlUnidadesG = " AND gs.UnidadeID IN ("& Unidades &") "
        end if

        if ref("Status")<>"" then
            Status = replace(ref("Status"),"|","")
            sqlStatus = " AND l.StatusID IN ("& Status &") "

            if instr(replace(ref("Status"),"|",""), 1) then
                sqlStatus = " AND ( l.StatusID IN ("& Status &") OR l.id IS NULL )"
            end if


        end if

        if ref("ProfissionalID")<>"0" then
            sqlProf = " AND (IFNULL(l.ProfissionalID, t.ProfissionalID)="& ref("ProfissionalID") &" "
            if lcase(session("Table"))="profissionais" then
                'sqlProf = sqlProf & " OR ISNULL(l.ProfissionalID) "
            end if
            sqlProf = sqlProf & ") "
        end if

        sqlDataII = ""
        sqlDataI = ""
        sqlDataGPS = ""
        'sqlPrevisao = " AND l.PrevisaoEntrega BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
        sqlPrevisao =  "AND (SELECT max(DataResultado) "&_
                        " FROM labs_invoices_exames lie  "&_
                        " INNER JOIN labs_invoices_amostras lia ON lia.id = lie.AmostraID "&_
                        " INNER JOIN cliniccentral.labs_exames le ON le.id  = lie.LabExameID "&_
                        " WHERE lia.InvoiceID = t.invoiceid)  BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "

        if ref("TipoData")="1" then
            sqlDataII = " AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlDataI = " and i.sysDate BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlDataGPS = " AND gps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlPrevisao = ""
        end if

        IF Procedimentos <> "" THEN
            filtroGrupo = " ii.ItemID in ("&Procedimentos&") AND "
        END IF
        sqldiaslaudo  = " IF(t.ProcedimentoID =0,(SELECT le.DiasResultado + le.DiasAdicionais "&_
                        " FROM cliniccentral.labs_exames le  "&_ 
                        " INNER JOIN labs_invoices_exames lia ON (lia.LabExameID = le.id)  "&_
                        " WHERE lia.InvoiceID = t.invoiceid  order by le.DiasResultado desc limit 1) ,proc.DiasLaudo) as DiasLaudo , "&_
                        "(SELECT max(DataResultado) "&_
                        " FROM labs_invoices_exames lie  "&_
                        " INNER JOIN labs_invoices_amostras lia ON lia.id = lie.AmostraID "&_
                        " INNER JOIN cliniccentral.labs_exames le ON le.id  = lie.LabExameID "&_
                        " WHERE lia.InvoiceID = t.invoiceid) AS DataPrevisao "

        sqlnomelab = "(SELECT lab.NomeLaboratorio "&_
                     "   FROM labs_invoices_exames lie "&_
                     "   INNER JOIN cliniccentral.labs_exames le ON (le.id = lie.labexameid) "&_
                     "   INNER JOIN cliniccentral.labs lab ON (lab.id = le.labid) "&_
                     "   WHERE lie.invoiceid = ii.invoiceid LIMIT 1 ) AS nomelab "

        sqllabid = "(SELECT le.labid "&_
                     "   FROM labs_invoices_exames lie "&_
                     "   INNER JOIN cliniccentral.labs_exames le ON (le.id = lie.labexameid) "&_
                     "   WHERE lie.invoiceid = ii.invoiceid LIMIT 1 ) AS labid "

        sql = " SELECT tab.*, DataPrevisao AS DataAtualizada  FROM "&_
            " (SELECT (SELECT count(arq.id) FROM arquivos arq WHERE arq.PacienteID=t.PacienteID )TemArquivos, proc.SepararLaudoQtd, t.quantidade, t.id IDTabela, t.Tabela, t.DataExecucao, t.PacienteID, t.NomeConvenio, t.ProcedimentoID, "& sqldiaslaudo &" , IF(t.ProcedimentoID =0, 'Laboratório',NomeProcedimento)NomeProcedimento, prof.NomeProfissional,pac.Cel1, IF( pac.NomeSocial IS NULL OR pac.NomeSocial ='', pac.NomePaciente, pac.NomeSocial)NomePaciente, IF(t.Tabela='sys_financialinvoices', t.id, l.id) Identificacao, t.Associacao, t.ProfissionalID, t.labid, invoiceid, nomelab  FROM ("&_
            " SELECT ii.id,ii.Quantidade quantidade, 'itensinvoice' Tabela, ii.DataExecucao, ii.ItemID ProcedimentoID, i.AccountID PacienteID, ii.ProfissionalID, ii.Associacao, 'Particular' NomeConvenio, "&sqllabid&", ii.InvoiceID invoiceid, "&sqlnomelab&" FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE ii.Tipo='S' AND ii.Executado='S' AND ii.ItemID IN ("& procsLaudar &") "& sqlDataII & sqlUnidadesP & sqlProcP & sqlPacP &_
            " UNION ALL "&_
            " SELECT i.id, ii.Quantidade quantidade,  'sys_financialinvoices' Tabela, i.sysDate DataExecucao, 0 ProcedimentoID, i.AccountID PacienteID,ii.ProfissionalID, ii.Associacao, 'Particular' NomeConvenio, ls.labid, i.id invoiceid , '' nomelab FROM sys_financialinvoices i INNER JOIN labs_solicitacoes ls ON ls.InvoiceID=i.id INNER JOIN itensinvoice ii ON ii.InvoiceID = i.id WHERE "&filtroGrupo&" ii.Executado = 'S' "& sqlDataI & sqlUnidadesP & sqlPacP &" GROUP BY i.id"&_
            " UNION ALL "&_
            " SELECT gps.id, gps.Quantidade quantidade,  'tissprocedimentossadt', gps.Data, gps.ProcedimentoID, gs.PacienteID, gps.ProfissionalID, gps.Associacao, conv.NomeConvenio, 0 labid, 0 invoiceid, '' as nomelab FROM tissguiasadt gs LEFT JOIN tissprocedimentossadt gps ON gps.GuiaID=gs.id LEFT JOIN convenios conv ON conv.id=gs.ConvenioID WHERE gps.ProcedimentoID IN("& procsLaudar &") "& sqlDataGPS & sqlProcGS & sqlPacGS & sqlUnidadesG &_
            ") t LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID INNER JOIN pacientes pac ON pac.id=t.PacienteID "&_
            " LEFT JOIN Laudos l ON (l.Tabela=t.Tabela AND l.IDTabela=t.id) "&_
            " LEFT JOIN labs_exames_procedimentos lep ON (lep.ProcedimentoID=t.ProcedimentoID) "&_
            " LEFT JOIN cliniccentral.labs_exames le ON le.id  = lep.LabExameID "&_
            " LEFT JOIN profissionais prof ON prof.id=IFNULL(t.ProfissionalID, l.ProfissionalID ) WHERE 1 and lep.id is null "& sqlProf & sqlStatus & sqlPrevisao & " GROUP BY t.id ORDER BY pac.NomePaciente ) as tab"
        'response.write (sql)
        set ii = db.execute( sql )


        msgPadraoTemplate = "Olá *[Paciente.Nome]*!%0a%0a O resultado do seu laudo de *[Procedimento.Nome]* se encontra *[Laudo.Status]*."

        LicencaID=replace(session("Banco"), "clinic","")

        set TextoEmail = db.execute(" SELECT sys_smsemail.TextoSMS FROM cliniccentral.areapaciente"&chr(13)&_
                                    " JOIN sys_smsemail ON sys_smsemail.id = areapaciente.ModeloID  "&chr(13)&_
                                    " WHERE LicencaID = "&LicencaID)

        IF not TextoEmail.EOF THEN
            msgPadraoTemplate = TextoEmail("TextoSMS")
        END IF

        counter=0
        while not ii.eof
            quantidade = ii("quantidade")
            ExibirSufixoQuantidade=False

            for contador = 1 to quantidade

                Status = ""
                if not isnull(ii("DiasLaudo")) then
                    DiasLaudo = ii("DiasLaudo")
                else
                    DiasLaudo = 0
                end if

                DataExecucao = ii("DataExecucao")
                Tabela = ii("Tabela")
                IDTabela = ii("IDTabela")
                ProcedimentoID = ii("ProcedimentoID")
                PacienteID = ii("PacienteID")
                ItemN = contador
                disabledEdit=""
                'Identificacao = ii("Identificacao")
                if  ii("NomeProcedimento") = "Laboratório" then
                    Previsao  =  ii("DataAtualizada")
                ELSE
                    Previsao  = dateAdd("d", DiasLaudo, DataExecucao)
                END IF

                sql = "select l.id, ls.Status, l.PrevisaoEntrega from laudos l LEFT JOIN laudostatus ls ON ls.id=l.StatusID where l.Tabela='"& Tabela &"' and l.IDTabela="& IDTabela &" and l.Serie="&ItemN
                ' response.write (sql)
                set vca = db.execute(sql)
                if not vca.eof then
                    Status = vca("Status")
                    'Previsao = vca("PrevisaoEntrega")
                    IDLaudo = vca("id")
                    link = "I="& IDLaudo
                    adicionaLinha = 1

                else
                    link = "T="& Tabela &"&Pac="& PacienteID &"&IDT="& IDTabela &"&Proc="& ProcedimentoID &"&E="& DataExecucao&"&IT="&ItemN
                    Status = "Pendente"
                    'Identificacao = 0

                    adicionaLinha = 1

                    if ItemN>1 then
                        adicionaLinha = 0
                    end if

                    if ii("SepararLaudoQtd") = 1 then
                        adicionaLinha = 1
                        ExibirSufixoQuantidade=True
                    end if

                end if

                NomeProfissional = ii("NomeProfissional")

                if ii("Associacao")<>5 then
                    NomeProfissional=accountName(ii("Associacao"), ii("ProfissionalID"))
                end if

                ExamesLaboratoriais = False
                ExamesDetalhamento = ""

                if right("0000000"&ii("Identificacao") ,7) = right("0000000"&ref("id") ,7) or ref("id")&""="" then


                    if isnull(ii("Identificacao")) and Tabela="sys_financialinvoices" then
                        disabledEdit = " disabled "
                    end if

                    NomeProcedimento = ii("NomeProcedimento")

                    if NomeProcedimento&"" = "" then
                        NomeProcedimento = ""
                    end if

                    if adicionaLinha =1 then

                    'msgPadrao = replaceTags(msgPadraoTemplate, PacienteID, session("UserID"), session("UnidadeID"))
                    msgPadrao = msgPadraoTemplate
                    msgPadrao = replace(msgPadrao, "[Paciente.Nome]", TratarNome("Título", ii("NomePaciente")))
                    msgPadrao = replace(msgPadrao, "[Laudo.Status]", LCase(Status&""))

                    if ExamesLaboratoriais then
                        msgPadrao = replace(msgPadrao, "[Procedimento.Nome]", "Exames Laboratoriais")
                    else
                        msgPadrao = replace(msgPadrao, "[Procedimento.Nome]", LCase(NomeProcedimento))
                    end if

                    ClassePrevisao=""
                    StatusClasse="warning"

                    if Status="Liberado" then
                        StatusClasse="success"
                    end if

                    if Previsao&"" <> "" then
                        if Status="Pendente" and cdate(Previsao)< date() then
                            ClassePrevisao="label label-rounded label-danger"
                        end if
                    end if
                    %>
                    <%if NomeProcedimento = "Laboratório" then %>
                    <tr class="view" >
                    <% else %>
                    <TR>
                    <% end if %> 
                        <td>
                            <div class="radio-custom square radio-dark ">
                              <input type="checkbox" name="cklaudos" id="cklaudo-<%=counter%>" class="cklaudos" value="<%= link %>" />
                              <label for="cklaudo-<%=counter%>">&nbsp;</label>
                            </div>
                        </td>
                        <td data-id="<%=ii("Identificacao")%>"><code><%= right("0000000"&ii("Identificacao") ,7)%><% if ExibirSufixoQuantidade then %>-<%=ItemN%><% end if %></code></td>
                        <td><%= DataExecucao %></td>
                        <td><span class="<%=ClassePrevisao%>"><%= Previsao %></span></td>
                        <td><small><a target="_blank" href="?P=pacientes&I=<%=ii("PacienteID")%>&Pers=1"><%= left(ii("NomePaciente"), 24) %></a></small></td>
                        <td class="whatsapp" msg="<%=msgPadrao%>"><small><%= ii("Cel1") %></small></td>
                        <td><small><%= left(NomeProfissional, 20) %></small></td>
                        <td> 
                            <%if NomeProcedimento = "Laboratório" then %>
                                <span class="label label-system" title="Ver Detalhes" onclick="esconder('<%=ii("Identificacao")%>',<%=ii("invoiceid")%> );"> <i class="fa fa-flask"></i> <small><%=NomeProcedimento %></small> </span>
                            <%else %>
                                <small><%=NomeProcedimento %></small>
                            <%end if%>
                        </td>
                        <td><%= ii("NomeConvenio") %></td>
                        <td id="status<%=ii("invoiceid") %>"><span  class="label label-rounded label-<%=StatusClasse%>"><%= Status %></span></td>
                        <td><% if cint(ii("TemArquivos")) > 0 then %><span data-toggle="tooltip" title="<%=ii("TemArquivos")%> arquivo(s) anexo(s)" class="label label-rounded label-info"><i class="fa fa-paperclip"></i></span><% end if %></td>
                        <td>
                            <div class="btn-group" style="float: right">
                            <% if Status = "Pendente" or Status="Parcial" then %>
                                <% if ii("labid")="1" then %>
                                    <a id="a<%=ii("invoiceid") %>"  class="btn btn-sm btn-alert" <%=disabledEdit%> href="javascript:syncLabResult(['<%=ii("invoiceid") %>'],'<%=ii("labid") %>'); $('#<%=ii("invoiceid") %>').toggleClass('fa-flask fa-spinner fa-spin');" title="Solicitar Resultado São Marcos"><i id="<%=ii("invoiceid") %>" class="fa fa-flask"></i></a>
                                <% end if %>
                                <% if ii("labid")="2" then %>
                                    <a id="a<%=ii("invoiceid") %>" class="btn btn-sm btn-" <%=disabledEdit%> href="javascript:syncLabResult([<%=ii("invoiceid") %>],'<%=ii("labid") %>'); $('#<%=ii("invoiceid") %>').toggleClass('fa-flask fa-spinner fa-spin');" title="Solicitar Resultado Diagnósticos do Brasil" ><i id="<%=ii("invoiceid") %>" class="fa fa-flask"></i></a>
                                <% end if %>
                                <% if ii("labid")="3" then %>
                                    <a id="a<%=ii("invoiceid") %>" class="btn btn-sm btn-" <%=disabledEdit%> href="javascript:syncLabResult([<%=ii("invoiceid") %>],'<%=ii("labid") %>'); $('#<%=ii("invoiceid") %>').toggleClass('fa-flask fa-spinner fa-spin');" title="Solicitar Resultado Álvaro" ><i id="<%=ii("invoiceid") %>" class="fa fa-flask"></i></a>
                                <% end if %>
                            <% end if %>
                             <% if ii("labid")="1" then %>
                                 <a class="btn btn-sm btn-default" <%=disabledEdit%> target="_blank" href="./?P=Laudo&Pers=1&formid=648&Pac=<%=PacienteID%>&invoiceid=<%=ii("invoiceid") %>"><i class="fa fa-edit"></i></a>
                             <% elseif ii("labid")="2" then %>
                                <a class="btn btn-sm btn-default" <%=disabledEdit%> target="_blank" href="./?P=Laudo&Pers=1&formid=739&Pac=<%=PacienteID%>&invoiceid=<%=ii("invoiceid") %>"><i class="fa fa-edit"></i></a>
                            <% else %> 
                                <a class="btn btn-sm btn-default" <%=disabledEdit%> target="_blank" href="./?P=Laudo&Pers=1&<%=link%>"><i class="fa fa-edit"></i></a>
                            <% end if %>
                            <button class="btn btn-sm btn-info hidden"><i class="fa fa-print"></i></button>
                            </div>
                        </td>
                    </tr>
                    <% if NomeProcedimento = "Laboratório"  then%>
                    <TR id="tr<%=ii("Identificacao")%>" style="display: none;">
                        <TD> &nbsp;<TD>
                        <TD colspan="100%"> 
                            <DIV id="div<%=ii("Identificacao")%>"> </DIV>
                        </TD> 
                    </TD>
                    <% end if %>
                    <%
                    end if

                end if
            next
            counter = counter + 1
        ii.movenext
        wend
        ii.close
        set ii = nothing
    end if
    set ultimasync = db.execute("SELECT * FROM labs_integracao_log WHERE metodo = 'SINCRONIZACAO_CRON' ORDER BY id DESC LIMIT 1")
    if not ultimasync.eof THEN 
    %>
    <TR><TD colspan="100%">        
        <div class="col-md-3 " style="float: right;">
            <p style="margin-top: 10px; opacity: 0.80">Última sincronização:<%=ultimasync("DataHora") %></p>
        </div>              
    </TD></TR>
    <% end if %>
    </tbody>
</table>

<script>

function esconder(elemento,invoiceid){
    var linha = '#tr'+elemento;
    var conteudo = '#div'+elemento;
    $(linha).toggle();

    $(conteudo).html('<center>Carregando...</center>');
    postUrl("labs-integration/diagbrasil/get-Exames-html", {
        "invoiceid": invoiceid
    }, function (data) {
        if(data.success) {
           $(conteudo).html(data.html);
        } else {
           $(conteudo).html('Não foi possivel obter a Informação do exame !');           
        }
    }); 

}

$(document).ready(function(){
   $('[data-toggle="tooltip"]').tooltip();

   $(".whatsapp").each((arg,arg1) => {
       let tel = arg1.innerHTML;

       let telefone ="55"+tel.replace(/[^0-9.]/g, "");
       if(telefone.substring(4,5) === "9" && telefone.length > 11){
         $(arg1).addClass("whatsApp-Ativo");
         $(arg1).on('click',() => {
            if(!whatsAppAlertado){
                    whatsAppAlertado=true;
                    showMessageDialog("<strong>Atenção!</strong> Para enviar uma mensagem via WhatsApp é preciso ter a ferramenta instalada em seu computador.  <a target='_blank' href='https://www.whatsapp.com/download/'>Clique aqui para instalar.</a>",
                    "warning", "Instalar o WhatsApp", 60 * 1000);
            }

             let msg = $(arg1).attr("msg");

             if(msg){
                   var url = "whatsapp://send?phone="+telefone+"&text="+msg;
                   $(arg1).append("<i class='success fa fa-check-circle'></i>");
                   const link = document.createElement('a');
                   link.href = url;
                   link.target = '_blank';
                   document.body.appendChild(link);
                   link.click();
                   link.remove();
             }

          });
       }
   });
});
</script>
<script>
<!--#include file="jQueryFunctions.asp"-->
$('[data-toggle="popover"]').popover();

function syncLabResult(invoices, labid =1) {
    var caminhointegracao = "";
    var url = "";
    switch (labid) {
        case '1':      
            caminhointegracao = "matrix"; 
            break;
        case '2': 
            caminhointegracao = "diagbrasil";
            break;
        case '3':
            caminhointegracao = "alvaro";
            break;
        default:
            alert ('Erro ao integrar com Laboratório');
            return false;
    }  
    url = "labs-integration/"+caminhointegracao+"/sync-invoice";
    postUrl(url, {
        "invoices": invoices
    }, function (data) {
        if(data.success) {
            alert(data.content);
            
            switch (data.status) {
                case 1:
                    var htmlstatus = '<span  class="label label-rounded label-warning">Pendente</span>';
                    break;

                case 2:
                    var htmlstatus = '<span  class="label label-rounded label-success">Liberado</span>';
                    $("#a"+invoices).hide();
                    break;

                case 3:
                    var htmlstatus = '<span  class="label label-rounded label-warning">Parcial</span>';
                    break;
                
                case 4:
                    var htmlstatus = '<span  class="label label-rounded label-info">Sincronizado</span>';
                    $("#a"+invoices).hide(); 
                    break;
                default:
                    var htmlstatus = '<span  class="label label-rounded label-warning">Pendente</span>';
            }
            $("#status"+invoices).html(htmlstatus);
            $("#tr"+invoices).hide();
            $("#"+invoices).removeClass('fa-flask fa-spinner fa-spin'); 
            $("#"+invoices).addClass('fa-flask');

        } else {
            alert("Falha ao sincronizar o laudo:"+data.message)
            $("#"+invoices).removeClass('fa-flask fa-spinner fa-spin'); 
            $("#"+invoices).addClass('fa-flask');
        }
    })
}

function AlertarWhatsapp(Celular, Texto, id) {
    if(!whatsAppAlertado){
        whatsAppAlertado=true;
        showMessageDialog("<strong>Atenção!</strong> Para enviar uma mensagem via WhatsApp é preciso ter a ferramenta instalada em seu computador.  <a target='_blank' href='https://www.whatsapp.com/download/'>Clique aqui para instalar.</a>",
        "warning", "Instalar o WhatsApp", 60 * 1000);
    }
    var url = "whatsapp://send?phone="+Celular+"&text="+Texto;
    $("#wpp-"+id).html("<i class='success fa fa-check-circle'></i>");
    openTab(url);
}

$(".cklaudostodos").on('change', function(){
    var value = $(this).prop("checked");
    $(".cklaudos").prop("checked", value)
});

$(".lab-sync").on("click", function (labid =2){
        alert ('Funcionalidade desabilitada!');
     }  );


    $(".atualizarstatus").on('click', function(){
        var values = $("#StatusID").val();
        if(values != null){
            var todos = values.toString().split(",");
            if( todos.length > 1){
                showMessageDialog("Escolha apenas 1 status", "danger")
            }else{
                var ids = "";
                $(".cklaudos").each(function(i, value){
                    if(value.checked){
                    $.post("atualizarLaudos.asp",  value.value + "&status=" + values, function(result){
                        eval(result)
                    });  
                    }
                });

                $.post("listaLaudos.asp", $("#frmLaudos").serialize(), function (data) {
                $("#divListaLaudos").html(data);
                });
            }
        }else{
            showMessageDialog("Escolha 1 status", "warning")
        }

        return false;
    })

    $("#StatusID").change(function() {
        $(".atualizarstatus").attr("disabled", $(this).val() == 0 );
    });
</script>

