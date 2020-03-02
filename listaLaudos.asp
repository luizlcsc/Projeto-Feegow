<!--#include file="connect.asp"-->
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
<table class="table table-condensed table-hover">
    <thead>
        <tr>
            <th width="1%"><input type="checkbox" name="cklaudostodos" class="cklaudostodos" value="1" /></th>
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
            <th width="1%"></th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
    <%
    set GroupConcat = db.execute("SET SESSION group_concat_max_len = 1000000;")
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
        sqlPrevisao = " AND l.PrevisaoEntrega BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "

        if ref("TipoData")="1" then
            sqlDataII = " AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlDataI = " and i.sysDate BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlDataGPS = " AND gps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlPrevisao = ""
        end if

        IF Procedimentos <> "" THEN
            filtroGrupo = " ii.ItemID in ("&Procedimentos&") AND "
        END IF

        sql = "SELECT (SELECT count(arq.id) FROM arquivos arq WHERE arq.PacienteID=t.PacienteID LIMIT 1)TemArquivos, proc.SepararLaudoQtd, t.quantidade, t.id IDTabela, t.Tabela, t.DataExecucao, t.PacienteID, t.NomeConvenio, t.ProcedimentoID, proc.DiasLaudo, IF(t.ProcedimentoID =0, 'Laboratório',NomeProcedimento)NomeProcedimento, prof.NomeProfissional,pac.Cel1, IF( pac.NomeSocial IS NULL OR pac.NomeSocial ='', pac.NomePaciente, pac.NomeSocial)NomePaciente, IF(t.Tabela='sys_financialinvoices', t.id, l.id) Identificacao, t.Associacao, t.ProfissionalID, labid, invoiceid  FROM ("&_
            " SELECT ii.id,ii.Quantidade quantidade, 'itensinvoice' Tabela, ii.DataExecucao, ii.ItemID ProcedimentoID, i.AccountID PacienteID, ii.ProfissionalID, ii.Associacao, 'Particular' NomeConvenio, 0 labid, 0 invoiceid FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE ii.Tipo='S' AND ii.Executado='S' AND ii.ItemID IN ("& procsLaudar &") "& sqlDataII & sqlUnidadesP & sqlProcP & sqlPacP &_
            " UNION ALL "&_
            " SELECT i.id, ii.Quantidade quantidade,  'sys_financialinvoices' Tabela, i.sysDate DataExecucao, 0 ProcedimentoID, i.AccountID PacienteID,ii.ProfissionalID, ii.Associacao, 'Particular' NomeConvenio, ls.labid, i.id invoiceid FROM sys_financialinvoices i INNER JOIN labs_solicitacoes ls ON ls.InvoiceID=i.id INNER JOIN itensinvoice ii ON ii.InvoiceID = i.id WHERE "&filtroGrupo&" ii.Executado = 'S' "& sqlDataI & sqlUnidadesP & sqlPacP &" GROUP BY i.id"&_
            " UNION ALL "&_
            " SELECT gps.id, gps.Quantidade quantidade,  'tissprocedimentossadt', gps.Data, gps.ProcedimentoID, gs.PacienteID, gps.ProfissionalID, gps.Associacao, conv.NomeConvenio, 0 labid, 0 invoiceid FROM tissguiasadt gs LEFT JOIN tissprocedimentossadt gps ON gps.GuiaID=gs.id LEFT JOIN convenios conv ON conv.id=gs.ConvenioID WHERE gps.ProcedimentoID IN("& procsLaudar &") "& sqlDataGPS & sqlProcGS & sqlPacGS & sqlUnidadesG &_
            ") t LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID INNER JOIN pacientes pac ON pac.id=t.PacienteID "&_
            " LEFT JOIN Laudos l ON (l.Tabela=t.Tabela AND l.IDTabela=t.id) "&_
            " LEFT JOIN labs_exames_procedimentos lep ON (lep.ProcedimentoID=t.ProcedimentoID) "&_
            " LEFT JOIN profissionais prof ON prof.id=IFNULL(l.ProfissionalID, t.ProfissionalID) WHERE 1 and lep.id is null "& sqlProf & sqlStatus & sqlPrevisao & " GROUP BY t.id ORDER BY t.DataExecucao, pac.NomePaciente"

        set ii = db.execute( sql )


        msgPadraoTemplate = "Olá *[Paciente.Nome]*!%0a%0a O resultado do seu laudo de *[Procedimento.Nome]* se encontra *[Laudo.Status]*."

        LicencaID=replace(session("Banco"), "clinic","")

        set TextoEmail = db.execute(" SELECT sys_smsemail.TextoSMS FROM cliniccentral.areapaciente"&chr(13)&_
                                    " JOIN sys_smsemail ON sys_smsemail.id = areapaciente.ModeloID  "&chr(13)&_
                                    " WHERE LicencaID = "&LicencaID)

        IF not TextoEmail.EOF THEN
            msgPadraoTemplate = TextoEmail("TextoSMS")
        END IF

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

                Previsao = dateAdd("d", DiasLaudo, DataExecucao)

                set vca = db.execute("select l.id, ls.Status, l.PrevisaoEntrega from laudos l LEFT JOIN laudostatus ls ON ls.id=l.StatusID where l.Tabela='"& Tabela &"' and l.IDTabela="& IDTabela &" and l.Serie="&ItemN)
                if not vca.eof then
                    Status = vca("Status")
                    Previsao = vca("PrevisaoEntrega")
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

                if right("0000000"&ii("Identificacao") ,7) = right("0000000"&ref("id") ,7) or ref("id")&""="" then


                    if isnull(ii("Identificacao")) and Tabela="sys_financialinvoices" then
                        disabledEdit = " disabled "
                    end if

                    NomeProcedimento = ii("NomeProcedimento")
                    
                    if NomeProcedimento = "Laboratório" then
                        sqlSiglas = "SELECT GROUP_CONCAT(DISTINCT ifnull(p.Sigla,'') SEPARATOR ', ') Siglas FROM itensinvoice ii INNER JOIN procedimentos p ON ii.ItemID = p.id WHERE ii.Executado = 'S' and p.TipoProcedimentoID = 3 and ii.InvoiceID="&IDTabela
                        set siglasSQL = db.execute(sqlSiglas)
                        if not siglasSQL.eof then
                            NomeProcedimento = siglasSQL("Siglas")
                        end if
                    end if
                    if NomeProcedimento&" " = " " then 
                        NomeProcedimento = ""
                    end if 

                    if adicionaLinha =1 then

                    'msgPadrao = replaceTags(msgPadraoTemplate, PacienteID, session("UserID"), session("UnidadeID"))
                    msgPadrao = msgPadraoTemplate
                    msgPadrao = replace(msgPadrao, "[Paciente.Nome]", TratarNome("Título", ii("NomePaciente")))
                    msgPadrao = replace(msgPadrao, "[Laudo.Status]", LCase(Status&""))
                    msgPadrao = replace(msgPadrao, "[Procedimento.Nome]", LCase(NomeProcedimento))

                    %>
                    <tr>
                        <td><input type="checkbox" name="cklaudos" class="cklaudos" value="<%= link %>" /></td>
                        <td data-id="<%=ii("Identificacao")%>"><%= right("0000000"&ii("Identificacao") ,7)%><% if ExibirSufixoQuantidade then %>-<%=ItemN%><% end if %></td>
                        <td><%= DataExecucao %></td>
                        <td><%= Previsao %></td>
                        <td><%= ii("NomePaciente") %></td>
                        <td class="whatsapp" msg="<%=msgPadrao%>"><%= ii("Cel1") %></td>
                        <td><%= NomeProfissional %></td>
                        <td><%= NomeProcedimento %></td>
                        <td><%= ii("NomeConvenio") %></td>
                        <td><%= Status %> <% if cint(ii("TemArquivos")) > 0 then %> <span><i style="color: #36bf92" class="fa fa-paperclip"></i></span> <% end if %></td>
                        <td>
                            <% if Status <> "Liberado" then %>
                                <% if ii("labid")="1" then %>  
                                    <a id="<%=ii("invoiceid") %>" class="btn btn-xs btn-alert" <%=disabledEdit%> href="javascript:syncLabResult([<%=ii("invoiceid") %>],'<%=ii("labid") %>');  $(this).attr('display','none');" title="Solicitar Resultado São Marcos"><i class="fa fa-flask"></i></a>
                                <% end if %>
                                <% if ii("labid")="2"    then %>  
                                    <a class="btn btn-xs btn-alert" <%=disabledEdit%> href="javascript:syncLabResult([<%=ii("invoiceid") %>],'<%=ii("labid") %>'); $(this).attr('display','none');" title="Solicitar Resultado Diagnósticos do Brasil"><i class="fa fa-flask"></i></a>
                                <% end if %>
                            <% end if %>
                        </td>
                        <td>                            
                            <a class="btn btn-xs btn-success" <%=disabledEdit%> target="_blank" href="./?P=Laudo&Pers=1&<%= link %>"><i class="fa fa-edit"></i></a>
                        </td>
                        <td><button class="btn btn-xs btn-info hidden"><i class="fa fa-print"></i></button></td>
                    </tr>
                    <%
                    end if

                end if
            next

        ii.movenext
        wend
        ii.close
        set ii = nothing
    end if
    %>
    </tbody>
</table>
<br>
<br>

<%
  if recursoAdicional(24)=4 then
  set labAutenticacao = db.execute("SELECT * FROM labs_autenticacao WHERE UnidadeID="&treatvalzero(session("UnidadeID")))
  if not labAutenticacao.eof then
  set soliSQL = db.execute("SELECT DataHora FROM labs_solicitacoes WHERE TipoSolicitacao='request-results' ORDER BY DataHora DESC LIMIT 1")

  UltSinc = "Não sincronizado"
  if not soliSQL.eof then
    UltSinc = soliSQL("DataHora")
  end if
%>
    <div class="col-md-3">
        <!-- <button class="btn btn-primary btn-block mt20 lab-sync" type="button"><i class="fa fa-flask bigger-110"></i> Sincronizar laboratório</button> -->
        <p style="margin-top: 10px; opacity: 0.80">Última sincronização: <%=UltSinc%></p>
    </div>
<%
    end if
end if
%>
<div class="col-md-5">
</div>
<%= quickfield("simpleSelect", "StatusID", "Status", 2, "", "select id, Status FROM laudostatus ", "Status", " no-select2") %>
<div class="col-md-2">
    <button class="btn btn-success btn-block mt20 atualizarstatus" type="button"><i class="fa fa-repeat bigger-110"></i> Atualizar Status</button>
</div>
<script>
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

function syncLabResult(invoices, labid =1) {
    var caminhointegracao = "";
    var url = "";
    //$("#syncInvoiceResultsButton").prop("disabled", true);  
    switch (labid) {
        case '1':      
            caminhointegracao = "matrix"; 
            break;
        case '2': 
            caminhointegracao = "diagbrasil";
            break;
        default:
            alert ('Erro ao integrar com Laboratório');
            return false;
    }  
    url = "labs-integration/"+caminhointegracao+"/sync-invoice";
    postUrl(url, {
        "invoices": invoices
    }, function (data) {
        //$("#syncInvoiceResultsButton").prop("disabled", false);
        if(data.success) {
            alert(data.content);
        } else {
            alert(data.content)
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
    if(value == 1){
        $(".cklaudos").each(function(i, value){
            $(this).prop("checked", true);
        });
    }else{
        $(".cklaudos").each(function(i, value){
            $(this).prop("checked", false);
        });
    }
});

$(".lab-sync").on("click", function (labid){
    const allowedLabs = ["laboratório são marcos"];
    let invoices = [];

    $("#divListaLaudos > table > tbody > tr").each(function(i, el) {
        if(allowedLabs.includes($(el).find("td:nth-child(6)").html().toLowerCase())) {
            invoices.push($(el).find("td:nth-child(2)").data("id"));
        }
    });
    
    postUrl("labs-integration/matrix/sync-invoice", {
        "invoices": invoices
    }, function (data) {
        $("#syncInvoiceResultsButton").prop("disabled", false);
        if(data.success) {
            location.reload();
        } else {
            alert(data.content)
        }
    })
});


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
</script>