<!--#include file="connect.asp"-->
<%
ConsultaID = req("id")
if ConsultaID&""="" then
    ConsultaID=req("ConsultaID")
end if
PostPaid = req("PostPaid")
set pacID = db.execute("select PacienteID, ProfissionalID from agendamentos where id="& ConsultaID)
PacienteID = pacID("PacienteID")
ProfissionalID = pacID("ProfissionalID")

AgendamentoIDii = ref("A")
AgendamentoProcedimentoIDii = ref("AP")
ItemInvoiceIDii = ref("II")

if AgendamentoIDii<>"" then
    db.execute("update itensinvoice set Executado='S', ProfissionalID="& ProfissionalID &", Associacao=5, DataExecucao=CURDATE() WHERE id="& ItemInvoiceIDii)
end if


function linhaPagtoCheckin(strTipoGuia, rdValorPlano, ClasseLinha, IDMovementBill)


    %>
    <tr class="<%=ClasseLinha%>">
        <td class="default" colspan="10" style="border-top:none">

            <%
            if rdValorPlano="V" then
                Rotulo = "RECEBER"
                recebimentoFunc =""
                if styleDisabled = "" then
                    recebimentoFunc = "onclick='lanctoCheckin("""&Bloco &""", """&IDMovementBill&""")'"
                end if
                recebimentoFuncCaixinha=""

                if aut("|contasareceberI|")=0 and session("CaixaID")="" and aut("|aberturacaixinhaI|") then
                    recebimentoFunc="data-toggle='tooltip' title='Você precisar abrir o caixinha'"
                    recebimentoFuncCaixinha="data-toggle='tooltip' title='Você precisar abrir o caixinha'"
                    styleDisabled = "style='cursor: not-allowed; opacity:0.65'"
                end if                
                
                if getConfig("ObrigarFormaRecebimentoCheckin") = "1" and inputsLancto>0 then %>
                    <button type="button" class="ckpagar btn btn-xs btn-warning" <%=styleDisabled%> <%=recebimentoFuncCaixinha%> data-toggle="modal" <%if styleDisabled = "" then %>onclick='lanctoCheckinNovoUpdate(<%=Bloco%>) <% end if %>'>
                        <i class="fa fa-arrow-circle-up"></i> <%= Rotulo %>
                    </button>
                <% else %>
                    <button type="button" class="ckpagar btn btn-xs btn-warning" onclick="lanctoCheckinNovoUpdate(<%=Bloco%>)"><i class="fa fa-arrow-circle-up"></i> <%= Rotulo %></button>
                <% end if %>
                <!-- Botão para acionar modal -->
               
                
                <%
            else
                spl = split(strTipoGuia, ", ")
                for i=0 to ubound(spl)
                    TipoGuia = spl(i)
                    Rotulo = " Guia "& TipoGuia
                    %>
                    <button type="button" id="btnAgGuia<%=TipoGuia%>" onclick="GeraGuia('<%=TipoGuia%>')" class="btn btn-xs btn-warning"><i class="fa fa-arrow-circle-up"></i> <%= ucase(Rotulo) %></button>
                    <%
                next
            end if
            %> </td>
    </tr>
    <%
end function

%>


<table class="table table-condensed table-hover">
<%
sql =   "SELECT proc.NomeProcedimento, proc.TipoProcedimentoID, t.*, if(conv.registroans='0' or conv.registroans='simplificado' ,'Simplificada', if(isnull(proc.TipoGuia) or proc.TipoGuia='', 'Consulta, SADT', proc.TipoGuia)) TipoGuia, IF(rdValorPlano='V', 'Particular', conv.NomeConvenio) NomeConvenio, "&_
        " COALESCE(tpvp.Valor, tpv.Valor) ValorConvenio, proc.id as ProcedimentoID, proc.Valor valorProcedimentoOriginal, "&_
        " COALESCE(conv.NaoPermitirGuiaDeConsulta, 0) NaoPermitirGuiaDeConsulta FROM ("&_
        " SELECT '' id, a.rdValorPlano, a.ValorPlano, a.TipoCompromissoID, a.Tempo, a.LocalID, a.EquipamentoID,a.PlanoID from agendamentos a where id="& ConsultaID &_
        " UNION ALL "&_
        " SELECT ap.id, ap.rdValorPlano, ap.ValorPlano, ap.TipoCompromissoID, ap.Tempo, ap.LocalID, ap.EquipamentoID,ap.PlanoID FROM agendamentosprocedimentos ap "&_
        " WHERE AgendamentoID="& ConsultaID &_
        " ) t "&_
        " LEFT JOIN procedimentos proc ON proc.id=t.TipoCompromissoID "&_
        " LEFT JOIN tissprocedimentosvalores tpv ON tpv.ProcedimentoId = t.TipoCompromissoID AND (tpv.ConvenioID=t.ValorPlano AND t.rdValorPlano='P')  "&_
        " LEFT JOIN tissprocedimentosvaloresplanos tpvp ON tpvp.AssociacaoID=tpv.id AND tpvp.PlanoID=t.PlanoID  "&_
        " LEFT JOIN convenios conv ON (conv.id=t.ValorPlano AND t.rdValorPlano='P') "&_
        " GROUP BY t.id ORDER BY t.rdValorPlano DESC, t.ValorPlano, proc.TipoGuia"
'response.write (sql &"<br><br>")
set agp = db.execute( sql )
'UrdValorPlano = agp("rdValorPlano")
blocoPend = 0
blocoPendParcial = 0
Bloco = 0
ValorConvenio = ""
TipoProcedimentoID = 0

'INICIO DO LOOP PRA LISTAR OS PROCEDIMENTOS
while not agp.eof
    ProcedimentoID = agp("TipoCompromissoID")
    NomeProcedimento = agp("NomeProcedimento")
    btnBaixar = ""
    TipoProcedimentoID=agp("TipoProcedimentoID")
    n = agp("id")
    Tempo = agp("Tempo")
    LocalID = agp("LocalID")
    EquipamentoID = agp("EquipamentoID")

    procedimentos = ""
    PermitirFaturamentoContaZerada = getConfig("PermitirFaturamentoContaZerada")

    'DEFINE SE É PARTICULAR E ESTÁ PAGO OU PENDENTE
    if agp("rdValorPlano")="V" then

        if PermitirFaturamentoContaZerada="0" and agp("ValorPlano")=0 then
            staPagto = "success"
        else
            ItemInvoiceID = "null"  
            FormaIDSelecionado = ""
            TipoCompromissoIDSe = agp("TipoCompromissoID")
            sqlQuitacao = "select mov.id MovementID, i.FormaID, ii.InvoiceID, ii.Desconto, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorItem, ifnull((select sum(Valor) from itensdescontados where ItemID=ii.id), 0) TotalQuitado from itensinvoice ii "&_
            " INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
            " INNER JOIN sys_financialmovement mov ON mov.InvoiceID=i.id "&_
            " WHERE i.AccountID="& PacienteID &" and AssociationAccountID=3 "&_
            " AND ii.ItemID="& TipoCompromissoIDSe &" "&_
            " AND DataExecucao=CURDATE() "&_
            " AND ProfissionalID="& treatvalnull(ProfissionalID) &" and ii.Executado='S' order by 6 desc"
            'response.write( sqlQuitacao )
            set vcaIIPaga = db.execute(sqlQuitacao)


            if not vcaIIPaga.eof then
                ItemInvoiceID = vcaIIPaga("InvoiceID")    
                FormaIDSelecionado = vcaIIPaga("FormaID")

                IF round(agp("ValorPlano")-vcaIIPaga("Desconto"),2)<=round(vcaIIPaga("TotalQuitado"),2) AND ModoFranquia THEN
                    staPagto = "success"
                ELSEIF round(agp("ValorPlano"),2)<=round(vcaIIPaga("TotalQuitado"),2) then
                    staPagto = "success"
                else
                    if round(vcaIIPaga("TotalQuitado"),2) > 1 then
                        'staPagto = "warning"
                        staPagto = "success"
                        MovementID=vcaIIPaga("MovementID")
                    else
                        staPagto = "danger"
                    end if
                end if
            else
                staPagto = "danger"
            end if

            if staPagto="warning" or staPagto="danger" then
                ItemInvoiceIDBaixar = ""
            end if

        end if
        
    'SE É CONVÊNIO
    else
        staPagto = "danger"'verifica as guias antes de dar DANGER

        'libera guia de retorno
        if TipoProcedimentoID&""="9" then
            staPagto = "success"
        end if

        set sqlGuiaGerada = db.execute("SELECT * FROM  "&_
        "(SELECT ValorProcedimento, DataAtendimento, ProcedimentoID, PacienteID, ProfissionalID, AgendamentoID "&_
        "FROM tissguiaconsulta "&_
        "UNION ALL "&_
        "SELECT tps.ValorTotal ValorProcedimento, tps.`Data` DataAtendimento, tps.ProcedimentoID, tgs.PacienteID, tps.ProfissionalID, tps.AgendamentoID "&_
        "FROM tissprocedimentossadt tps "&_
        "LEFT JOIN tissguiasadt tgs ON tgs.id=tps.GuiaID) t "&_
        "WHERE t.PacienteID IS NOT NULL AND DataAtendimento = CURDATE() AND t.ProcedimentoID="&agp("TipoCompromissoID")&" AND (ISNULL(t.ProfissionalID) or t.ProfissionalID=0 OR t.ProfissionalID="& treatvalnull(ProfissionalID) &") AND t.PacienteID="&PacienteID&" LIMIT 1")
            
        if not sqlGuiaGerada.eof then

            ValorProcedimento = sqlGuiaGerada("ValorProcedimento")
            if ValorProcedimento > 0 then
                staPagto = "success"
            end if
            if PermitirFaturamentoContaZerada = 1 and ValorProcedimento = 0 then
                staPagto = "success"
            end if
        end if

    end if

    'response.write(FormaIDSelecionado)

    if UTipoGuia<>"" and UTipoGuia<>agp("TipoGuia") and blocoPend=1 then
        call linhaPagtoCheckin( UTipoGuia, UrdValorPlano, "danger", "" )
    end if
    if UrdValorPlano<>agp("rdValorPlano") or (UrdValorPlano="P" and UValorPlano<>agp("ValorPlano")) then
        Bloco = Bloco + 1

        %>
        <tr class="info" data-position="<%=Bloco%>" data-tipo="<%=UTipoGuia%>">
            <th width="1%"></th>
            <th width="30%"><%= agp("NomeConvenio") %></th>
            <th width="5%">Tempo</th>
            <th colspan="2" width="30%">Forma</th>
            <th width="20%">Local</th>
            <th width="20%">Equipamento</th>
            <th></th>
        </tr>
        <%
        blocoPend = 0
    end if
    'response.write( agp("TipoGuia") &" { "& UTipoGuia &" } [ "& UrdValorPlano &" ]<br>")
    %>

    <%idagp = agp("id")%>
    <input type="hidden" class="linha-procedimento-id" value="<%=agp("ProcedimentoID")%>"> 
    <input type="hidden" class="linha-procedimento-id-daPro" name="daPro" data-idPro="<%=idagp%>" value="<%=agp("valorProcedimentoOriginal")%>">

    <%
    '-> LINHA AGENDA QUE PUXAVA DO CONNECT -> ANTIGA function linhaagenda(...
    ischeckin = false
    ischeckin = req("Checkin")="1"
        
    if rdValorPlano="V" then
        ConvenioID=0
    end if
    %>
    <tr class="linha-procedimento" id="la<%=n %>" data-id="<%=n %>">
        <% 
        inputsLancto = 0
        if ischeckin then %>
            <td class="<%= staPagto %>" style="border:none">
                <% if staPagto="success" then %>
                    <i class=" fa fa-check-circle text-success"></i>
                <% else 

                    '-> Verifica se tem invoice pré-paga
                    AgID = ConsultaID
                    AgPID = n
                    if AgPID="" then
                        sqlAg = "SELECT l.UnidadeID, a.PacienteID, a.TipoCompromissoID ProcedimentoID, a.ProfissionalID, a.EspecialidadeID FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID WHERE a.id="& AgID
                    else
                        sqlAg = "SELECT l.UnidadeID, a.PacienteID, ap.TipoCompromissoID ProcedimentoID, a.ProfissionalID, a.EspecialidadeID FROM agendamentos a LEFT JOIN agendamentosprocedimentos ap ON a.id=ap.AgendamentoID LEFT JOIN locais l ON l.id=ap.LocalID WHERE ap.id="& AgPID
                    end if
                    set ag = db.execute( sqlAg )
                    if not ag.eof then
                        UnidadeID = ag("UnidadeID")
                        PacienteID = ag("PacienteID")
                        ProcedimentoID = ag("ProcedimentoID")
                        ProfissionalID = ag("ProfissionalID")
                        EspecialidadeID = ag("EspecialidadeID")

                        set iiPaga = db.execute("select ii.id from itensinvoice ii INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID INNER JOIN itensdescontados idesc ON idesc.ItemID=ii.id WHERE i.AssociationAccountID=3 AND i.CD='C' AND i.AccountID="& PacienteID &" AND i.CompanyUnitID="& treatvalzero(UnidadeID) &" AND ii.Executado='' AND ii.Tipo='S' AND ii.ItemID="& ProcedimentoID &" AND (ii.ProfissionalID="& ProfissionalID &" OR ii.ProfissionalID=0 OR ISNULL(ii.ProfissionalID) OR ii.Executado='') AND (ii.EspecialidadeID="& treatvalzero(EspecialidadeID) &" OR ii.EspecialidadeID=0 OR ISNULL(ii.EspecialidadeID) OR "& treatvalzero(EspecialidadeID) &"=0) AND round(ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))<=round((select sum(Valor) from itensdescontados where ItemID=ii.id))")
                        if NOT iiPaga.eof then
                            ItemInvoiceIDBaixar = iiPaga("id")
                            if PostPaid="1" then
                                db.execute("update itensinvoice set Executado='S', ProfissionalID="& ProfissionalID &", Associacao=5, DataExecucao=CURDATE() WHERE id="& ItemInvoiceIDBaixar)
                            end if
                            btnBaixar = "<button type=""button"" class=""btn btn-success btn-xs bpp"" style=""position:absolute; margin:-11px 0 0 172px"" onclick=""baixarPrePago('"& ConsultaID &"', '"& agp("id") &"', '"& ItemInvoiceIDBaixar &"')""><i class=""fa fa-chevron-left""></i> Dar baixa em item pré-pago</button>"
                            response.write( btnBaixar )
                        end if
                    end if
                    '<- Verifica se tem invoice pré-paga
                    if btnBaixar="" then
                        inputsLancto = inputsLancto+1
                        %>
                        <input type="checkbox" checked="checked" name="LanctoCheckin" class="ckpagar Bloco<%= Bloco %>" value="<%= ConsultaID &"_"& AgPID %>" />
                        <%
                    end if
                    %>
                        </td>
                <% 
                end if
                %>
                
                
                
                
                <td>
                    <input type="hidden" name="ProcedimentoID<%=n%>" id="ProcedimentoID<%=n%>" value="<%=ProcedimentoID%>">
                    <%=NomeProcedimento%>
                </td>
                <td>
                    <%
                    TempoChange = ""
                    if aut("|agendaalteracaoprecadastroA|")=0 then
                        TempoChange=" readonly"
                    end if
                    %>
                    <input type="hidden" name="Tempo<%=n%>" id="Tempo<%=n%>" value="<%=Tempo%>">
                    <span><%=Tempo%></span> 
                </td>
                <td>
                    <%
                    formapg = "Particular"
                    if rdValorPlano="P" then
                        formapg = "Convênio"
                    end if
                    %>
                    <input type="radio" class="hidden" name="rdValorPlano<%=n %>" id="rdValorPlanoV<%=n%>" <% If formapg = "Particular" Then %> checked="checked"<% End If %> value="V">
                    <input type="radio"  class="hidden"  name="rdValorPlano<%=n %>" id="rdValorPlanoP<%=n%>" <% If formapg = "Convênio" Then %> checked="checked"<% End If %> value="P">
                    <label><%=formapg%>
                    <% if agp("rdValorPlano")="V" then
                        response.write(" - R$ "& fn(agp("ValorPlano")) )
                    end if %>
                    </label> 
                </td>
                <td>
                    <div class="col-md-12" id="divValor<%=n %>" <% If rdValorPlano<>"V" Then %> style="display:none"<% End If %>>
                        <div class="row">
                            <div class="col-md-12">
                                <input data-valor="<%= agp("ValorPlano") %>" type="hidden" id="Valor<%=n %>" name="Valor<%=n %>" value="<%= agp("ValorPlano") %>" class="valorprocedimento">
                                R$ <span id="ValorText<%=n %>"><%=fn(Valor)%></span>
                                <script >
                                $("#Valor<%=n %>").change(function() {
                                    $("#ValorText<%=n %>").html($(this).val());
                                });
                                </script>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12" id="divConvenio<%=n %>" <% If rdValorPlano<>"P" Then %> style="display:none"<% End If %>>
                        <%
                        if not isnull(ConvenioID) and ConvenioID<>"" then
                            set ConvenioSQL = db.execute("SELECT NomeConvenio FROM convenios "&_
                                                        " WHERE id="&ConvenioID&"")
                            if not ConvenioSQL.eof then
                                if PlanoID&""<>"" then
                                    set PlanoSQL = db.execute("SELECT NomePlano FROM conveniosplanos "&_
                                                        " WHERE id="&PlanoID&" AND NomePlano!=''")
                                    if not PlanoSQL.eof then
                                        NomePlano = "<label> - Plano:</label><span>"&PlanoSQL("NomePlano")&"</span>"
                                    end if
                                end if 
                                
                                %>
                                <input type="hidden" name="ConvenioID<%=n%>" id="ConvenioID<%=n%>" value="<%=ConvenioID%>">
                                <input type="hidden" name="PlanoID<%=n%>" id="PlanoID<%=n%>" value="<%=PlanoID%>">
                                <span><%=ConvenioSQL("NomeConvenio")%></span>
                                <%=NomePlano%>
                                <%
                            end if
                        end if
                        %>

                    </div>

                </td>
                <td><%
                    disabled = ""
                    if fieldReadonly = " readonly " then 
                        disabled = " disabled " 
                    end if
                    
                        set localSQL = db.execute("select NomeLocal from locais where sysActive=1 and id="&treatvalzero(LocalID))
                        if not localSQL.eof then
                            NomeLocal = "<span>"&localSQL("NomeLocal")&"</span>"
                        end if
                        %>
                        <input type="hidden" name="LocalID<%=n %>" id="LocalID<%=n %>" value="<%=LocalID%>" />
                        <%=NomeLocal%>
                        <%
            
                    %>
                </td>
                <td>
                    <%
                    set equipSQL = db.execute("select NomeEquipamento from equipamentos where sysActive=1 and id="&treatvalzero(EquipamentoID))
                    if not equipSQL.eof then
                        NomeEquipamento = "<span>"&equipSQL("NomeEquipamento")&"</span>"
                    end if
                    %>
                    <input type="hidden" name="EquipamentoID<%=n %>" id="EquipamentoID<%=n %>" value="<%=EquipamentoID%>" />
                    <%=NomeEquipamento%>
                </td>
                <td>
                    <input type="hidden" name="ProcedimentosAgendamento" value="<%=n %>" />
        
                    <div class="btn-group mt5">
                        <button type="button" class="btn btn-info btn-xs dropdown-toggle rgrec" data-toggle="dropdown" title="Gerar recibo" aria-expanded="false"><i class="fa fa-print bigger-110"></i></button>
                        <ul class="dropdown-menu dropdown-info pull-right">
                            <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Protocolo')"><i class="fa fa-plus"></i> Protocolo de laudo </a></li>
                            <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Impresso')"><i class="fa fa-plus"></i> Impresso </a></li>
                            <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Etiqueta')"><i class="fa fa-plus"></i> Etiqueta </a></li>
                        </ul>
                    </div>
                </td>
            </tr>                
                
                <%
        end if %>


        <tr id="restr<%= n %>"></tr>        
            
            <%
        '<- LINHA AGENDA QUE PUXAVA DO CONNECT
        UrdValorPlano = agp("rdValorPlano")
        UValorPlano = agp("ValorPlano")
        ValorConvenio = agp("ValorConvenio")
        UTipoGuia = agp("TipoGuia")

        NaoPermitirGuiaDeConsulta = agp("NaoPermitirGuiaDeConsulta")
        if NaoPermitirGuiaDeConsulta=1 then
            UTipoGuia = "SADT"
        end if


        if staPagto="danger" then
            blocoPend = 1
        end if
        if staPagto="warning" then
            blocoPendParcial = 1
        end if
    agp.movenext
    wend
    agp.close
    set agp = nothing

'UrdValorPlano="P"
'blocoPendParcial=1
'blocoPend=2
    if blocoPend=1 then
        if UrdValorPlano = "V" or (UrdValorPlano = "P" and ValorConvenio&"" <> "") then
            call linhaPagtoCheckin( UTipoGuia, UrdValorPlano , "danger", "" )
        elseif (UrdValorPlano = "P" and (ValorConvenio&""="" or ValorConvenio&""="0")) then
        %>
        <tr class="danger">
            <td class="default" colspan="10" style="border-top:none">
                <i class="fa fa-exclamation-circle"></i> Não possui valor cadastrado no convênio
            </td>
        </tr>
        <%

        end if
    elseif blocoPendParcial=1 then
        if UrdValorPlano = "V" or (UrdValorPlano = "P" and ValorConvenio&"" <> "") then
            call linhaPagtoCheckin( UTipoGuia, UrdValorPlano , "warning", MovementID )
        end if
    else
        %>
<script >
$("#btnSalvarAgenda").attr("disabled", false).removeClass("disabled")
</script>
        <%
    end if
    %>
    </table>

<script type="text/javascript">
function baixarPrePago(A, AP, II){
    $.post("checkinProcedimentosBaixar.asp?Checkin=1&id=<%= ConsultaID %>", {
        A: A,
        AP: AP,
        II: II
    }, function( data ){
        $("#checkinProcedimentosBaixar").html( data );
    });
}

<%
if PostPaid="1" then
    response.write(" ajxContent('checkinProcedimentosBaixar&Checkin=1&id='+$('#ConsultaID').val(), '', '1', 'divAgendamentoCheckin') ")
end if
%>
</script>