<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="modal.asp"-->
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
            <th>Executante</th>
            <th>Laudador</th>
            <th>Procedimento</th>
            <th>Convênio</th>
            <th>Status</th>
            <th width="1%"></th>
            <th width="100"></th>
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
            <td colspan="10">
                <em>Nenhum procedimento com laudo habilitado. Habilite a opção de laudo no cadastro dos procedimentos em que deseja utilizar este recurso.</em>
            </td>
        </tr>
        <%

    else
        if ref("ProcedimentoID")<>"0" and ref("ProcedimentoID")&""<>"" then
            if instr(ref("ProcedimentoID"), "G")=0 then
                sqlProcP = " AND ii.ItemID="& ref("ProcedimentoID") &" "
                sqlProcGS = " AND gps.ProcedimentoID="& ref("ProcedimentoID") &" "
                Procedimentos = ref("ProcedimentoID")
            else
                set gp = db.execute("select group_concat(id) Procedimentos from procedimentos WHERE integracaopleres<>'S' AND  Laudo=1 AND GrupoID="& replace(ref("ProcedimentoID"), "G", ""))
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
            sqlProf = " AND (IFNULL(t.ProfissionalID, l.ProfissionalID)="& ref("ProfissionalID") &" "
            if lcase(session("Table"))="profissionais" then
                'sqlProf = sqlProf & " OR ISNULL(l.ProfissionalID) "
            end if
            sqlProf = sqlProf & ") "
        end if

        sqlDataII = ""
        sqlDataI = ""
        sqlDataGPS = ""
        sqlPrevisao = "  AND (l.PrevisaoEntrega BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" or l.id is null) "
        sqlPrevisaoII = " WHERE cliniccentral.sf_adddiasuteis(tab.dataexecucao, tab.diaslaudo) BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &"  "

        if ref("TipoData")="1" then
            sqlDataII = " AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlDataI = " AND i.sysDate BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlDataGPS = " AND gps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" "
            sqlPrevisao = ""
            sqlPrevisaoII = ""
        end if

        IF Procedimentos <> "" THEN
            filtroGrupo = " ii.ItemID in ("&Procedimentos&") AND "
        END IF
      
        sql =   " SELECT tab.*,  prof_lau.NomeProfissional NomeProfissionalLaudador , tab.DiasLaudo FROM "&_
                " (SELECT proc.DiasLaudo, l.Associacao AssociacaoLaudadorID, l.ProfissionalID ProfissionalLaudadorID, (SELECT count(arq.id) FROM arquivos arq WHERE arq.LaudoID=l.id )TemArquivos, "&_ 
                " proc.SepararLaudoQtd, t.quantidade, t.id IDTabela, t.Tabela, t.DataExecucao, t.PacienteID, t.NomeConvenio, t.ProcedimentoID, 0 , IF(t.ProcedimentoID =0, 'Laboratório', "&_
                " NomeProcedimento)NomeProcedimento, prof.NomeProfissional, pac.Cel1, IF( pac.NomeSocial IS NULL OR pac.NomeSocial ='', pac.NomePaciente, pac.NomeSocial)NomePaciente, "&_ 
                " l.id Identificacao, t.Associacao, t.ProfissionalID, t.labid, invoiceid, nomelab  FROM ("&_
                " SELECT ii.id,ii.Quantidade quantidade, 'itensinvoice' Tabela, ii.DataExecucao, ii.ItemID ProcedimentoID, i.AccountID PacienteID, ii.ProfissionalID, ii.Associacao, "&_
                " 'Particular' NomeConvenio, null labid, ii.InvoiceID invoiceid, null nomelab FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE ii.Tipo='S' AND ii.Executado='S' "&_ 
                " AND ii.dataexecucao  >= date(SUBDATE(NOW(), INTERVAL 60 DAY)) AND ii.ItemID IN ("& procsLaudar &") "& sqlDataII & sqlUnidadesP & sqlProcP & sqlPacP &_
                " UNION ALL "&_
                " SELECT gps.id, gps.Quantidade quantidade,  'tissprocedimentossadt', gps.Data, gps.ProcedimentoID, gs.PacienteID, gps.ProfissionalID, gps.Associacao, conv.NomeConvenio, 0 labid, "&_
                " 0 invoiceid, '' as nomelab FROM tissguiasadt gs "&_ 
                " LEFT JOIN tissprocedimentossadt gps ON gps.GuiaID=gs.id "&_ 
                " LEFT JOIN convenios conv ON conv.id=gs.ConvenioID "&_ 
                " WHERE gs.sysDate >= date(SUBDATE(NOW(), INTERVAL 60 DAY)) AND gps.ProcedimentoID IN("& procsLaudar &") "& sqlDataGPS & sqlProcGS & sqlPacGS & sqlUnidadesG &_
                ") t INNER JOIN procedimentos proc ON proc.id=t.ProcedimentoID and proc.integracaopleres <>'S'"&_ 
                " INNER JOIN pacientes pac ON pac.id=t.PacienteID  "&_
                " LEFT JOIN Laudos l ON (l.Tabela=t.Tabela AND l.IDTabela=t.id and l.tabela<> 'sys_financialinvoices') "&_
                " LEFT JOIN profissionais prof ON prof.id=IFNULL(t.ProfissionalID, l.ProfissionalID ) "&_
                " WHERE true "& sqlProf & sqlStatus & sqlPrevisao & " "&_
                " GROUP BY t.id ORDER BY pac.NomePaciente ) as tab"&_
                " LEFT JOIN profissionais prof_lau ON prof_lau.id=tab.ProfissionalLaudadorID AND tab.AssociacaoLaudadorID=5 " & sqlPrevisaoII



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
                Identificacao = ii("Identificacao")
                Previsao  = dateAdd("d", DiasLaudo, DataExecucao)
                

                sql = "select l.id, ls.Status, l.PrevisaoEntrega from laudos l LEFT JOIN laudostatus ls ON ls.id=l.StatusID where l.Tabela='"& Tabela &"' and l.IDTabela="& IDTabela &" and l.Serie="&ItemN
                 'response.write (sql)
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
                Laudador = ii("NomeProfissionalLaudador")

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
                        <td><small><%= left(Laudador, 20) %></small></td>
                        <td>
                            <%if NomeProcedimento = "Laboratório" then %>
                                <span class="label label-system" title="Ver Detalhes" onclick="esconder('<%=ii("Identificacao")%>',<%=ii("invoiceid")%> );"> <i class="far fa-flask"></i> <small><%=NomeProcedimento %></small> </span>
                            <%else %>
                                <small><%=NomeProcedimento %></small>
                            <%end if%>
                        </td>
                        <td><%= ii("NomeConvenio") %></td>
                        <td id="status<%=ii("invoiceid") %>"><span  class="label label-rounded label-<%=StatusClasse%>"><%= Status %></span></td>
                        <td><% if cint(ii("TemArquivos")) > 0 then %><span data-toggle="tooltip" title="<%=ii("TemArquivos")%> arquivo(s) anexo(s)" class="label label-rounded label-info"><i class="far fa-paperclip"></i></span><% end if %></td>
                        <td>
                            <div class="btn-group" style="float: right">
                            <% if Status = "Pendente" or Status="Parcial" then %>
                                <% if ii("labid")="1" then %>
                                    <a id="a<%=ii("invoiceid") %>"  class="btn btn-sm btn-alert" <%=disabledEdit%> href="javascript:syncLabResult(['<%=ii("invoiceid") %>'],'<%=ii("labid") %>'); $('#<%=ii("invoiceid") %>').toggleClass('fa-flask fa-spinner fa-spin');" title="Solicitar Resultado São Marcos"><i id="<%=ii("invoiceid") %>" class="far fa-flask"></i></a>
                                <% end if %>
                                <% if ii("labid")="2" then %>
                                    <a id="a<%=ii("invoiceid") %>" class="btn btn-sm btn-" <%=disabledEdit%> href="javascript:syncLabResult([<%=ii("invoiceid") %>],'<%=ii("labid") %>'); $('#<%=ii("invoiceid") %>').toggleClass('fa-flask fa-spinner fa-spin');" title="Solicitar Resultado Diagnósticos do Brasil" ><i id="<%=ii("invoiceid") %>" class="far fa-flask"></i></a>
                                <% end if %>
                                <% if ii("labid")="3" then %>
                                    <a id="a<%=ii("invoiceid") %>" class="btn btn-sm btn-" <%=disabledEdit%> href="javascript:syncLabResult([<%=ii("invoiceid") %>],'<%=ii("labid") %>'); $('#<%=ii("invoiceid") %>').toggleClass('fa-flask fa-spinner fa-spin');" title="Solicitar Resultado Álvaro" ><i id="<%=ii("invoiceid") %>" class="far fa-flask"></i></a>
                                <% end if %>
                                <% if ii("labid")="4" then %>
                                    <a id="a<%=ii("invoiceid") %>" class="btn btn-sm btn-" <%=disabledEdit%> href="javascript:syncLabResult([<%=ii("invoiceid") %>],'<%=ii("labid") %>'); $('#<%=ii("invoiceid") %>').toggleClass('fa-flask fa-spinner fa-spin');" title="Solicitar Resultado Hermes Pardini" ><i id="<%=ii("invoiceid") %>" class="far fa-flask"></i></a>
                                <% end if %>
                            <% end if %>
                             <% if ii("labid")="1" then %>
                                 <a class="btn btn-sm btn-default" <%=disabledEdit%> target="_blank" href="./?P=Laudo&Pers=1&formid=648&Pac=<%=PacienteID%>&invoiceid=<%=ii("invoiceid") %>"><i class="far fa-edit"></i></a>
                             <% elseif ii("labid")="2" then %>
                                <a class="btn btn-sm btn-default" <%=disabledEdit%> target="_blank" href="./?P=Laudo&Pers=1&formid=739&Pac=<%=PacienteID%>&invoiceid=<%=ii("invoiceid") %>"><i class="far fa-edit"></i></a>
                             <% elseif ii("labid")="3" then %>
                                 <% if  Status="Liberado" then %>
                                    <a class="btn btn-sm btn-default" <%=disabledEdit%> onclick="entrega(<%=IDLaudo %>,'pdf');" href="#"><i class="far fa-file-pdf-o"></i></a>
                                 <% end if %>
                             <% elseif ii("labid")="4" then %>
                                <% if  Status="Liberado" then %>
                                    <a class="btn btn-sm btn-default" <%=disabledEdit%> onclick="entrega(<%=IDLaudo %>,'pdf');" href="#"><i class="far fa-file-pdf-o"></i></a>
                                <% end if %>
                             <% else %> 
                                <a class="btn btn-sm btn-default" <%=disabledEdit%> target="_blank" href="./?P=Laudo&Pers=1&<%=link%>"><i class="far fa-edit"></i></a>
                            <% end if
                            
                            if Status="Liberado" and ii("labid")<>"4" and ii("labid")<>"3" then
                                response.write("<a href=""javascript:entrega("&IDLaudo&",'html')"" class='btn btn-sm btn-info'><span class='far fa-print'></span> </a>")
                            end if
                            %>
                            <button class="btn btn-sm btn-info hidden"><i class="far fa-print"></i></button>

                            </div>
                        </td>
                    </tr>
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
    %>
    </tbody>
</table>

<script>
function saveLaudo(T, print){
    $.post("saveLaudo.asp?L=<%= LaudoID %>&T="+ T, $("#Texto, #StatusID, #ProfissionalID, #Restritivo, #DataEntrega, #HoraEntrega, #ObsEntrega, #Receptor").serialize(), function(data){
        eval(data);
    });
}


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
                   $(arg1).append("<i class='success far fa-check-circle'></i>");
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
        case '4':
            caminhointegracao = "hermespardini";
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
            alert("Laudo não sincronizado: "+data.content)
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
    $("#wpp-"+id).html("<i class='success far fa-check-circle'></i>");
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

