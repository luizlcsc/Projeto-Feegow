<!--#include file="connect.asp"-->
<%
Origem = req("Origem")
if Origem="Agenda" then
    set vcaEmAberto = db.execute("select id from propostas where PacienteID="& req("PacienteID") &" AND StaID IN (1,2,4) limit 1")
    if vcaEmAberto.eof then
        response.end
    end if
end if


if req("Acao")="Agendamento" then
    response.redirect("./?P=AgendaMultipla&Pers=1&PacienteID="& req("PacienteID") &"&ItemPropostaID="& req("ItemPropostaID") &"&ProcedimentoID="& req("ProcedimentoID"))
end if
%>
<!--#include file="Classes/WhatsApp.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
        <div class="panel mt15">
        <%
        CallID = req("CallID")

        if req("X")<>"" then
	        db_execute("delete from propostas where id="&req("X"))
	        db_execute("delete from pacientespropostasformas where PropostaID="&req("X"))
	        db_execute("delete from pacientespropostasoutros where PropostaID="&req("X"))
	        db_execute("delete from itensproposta where PropostaID="&req("X"))
        end if

        response.Buffer

        if req("I")="" then
	        %>
            <div class="panel-heading">
                    <span class="panel-title"><i class="far fa-files-o blue"></i> Propostas Geradas </span>
                    <%if req("PacienteID")<>"" then %>
                    <span class="panel-controls">
                        <button class="btn btn-sm btn-success" onclick="ajxContent('PacientesPropostas&CallID=<%=CallID%>&PropostaID=N&PacienteID=<%=req("PacienteID")%>', '', '1', 'pront<%=CallID %>')"><i class="far fa-plus"></i> INSERIR</button>
                    </span>
                    <%end if %>
            </div>
	        <%
        end if%>
        <div class="panel-body">
        <div class="table-responsive" style="overflow-y: scroll">
            <table class="table table-striped table-bordered">
                <thead>
                    <tr class="success">
                        <th width="8%">Data</th>
                        <%if req("PacienteID")="" then%>
                            <th>Paciente</th>
                            <th>Telefone</th>
                        <%end if%>
                        <th>Itens</th>
                        <th width="15%">Status</th>
                        <th width="5%">Contrato</th>
                        <% if session("Banco")<>"clinic4456" or (session("Banco")="clinic4456" and lcase(session("Table"))="funcionarios") then %>
                            <th width="15%">Valor</th>
                        <% end if %>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if req("PacienteID")<>"" then
                        set p = db.execute("select p.id, p.InvoiceID, p.PacienteID,s.NomeStatus, p.DataProposta, p.Valor, (select group_concat( concat('<a class=""btn btn-xs btn-success mt5"" href=""./?P=ListaPropostas&Pers=1&Acao=Agendamento&ProcedimentoID=', ip.ItemID, '&PacienteID=', p.PacienteID, '&ItemPropostaID=', ip.id, '"" target=""_blank""><i class=""far fa-calendar ""></i></a> ', proc.NomeProcedimento ) SEPARATOR '<br> ') from itensproposta ip left join procedimentos proc on proc.id=ip.ItemID where ip.PropostaID=p.id) procedimentos from propostas p LEFT JOIN propostasstatus s on s.id=p.StaID where p.sysActive=1 AND PacienteID='"&req("PacienteID")&"' group by p.id order by p.DataProposta desc")
                    else
                        if ref("Procedimentos")<>"" then
                            leftProc = " LEFT JOIN itensproposta itens ON itens.PropostaID=p.id "
                            sqlProc = " AND itens.ItemID IN("& replace(ref("Procedimentos"), "|", "") &") "
                        end if
                        if ref("Unidades")<>"" then
                            whereUnidade = " AND p.UnidadeID IN("& replace(ref("Unidades"), "|", "") &") "
                        end if
                        if ref("EmitidaPor")<>"" then
                            sqlUser = " AND p.sysUser="& ref("EmitidaPor") &" "
                        end if
                        sqlp = "select p.id, p.PacienteID, p.InvoiceID, s.NomeStatus, p.DataProposta, pac.Tel1, pac.Tel2, pac.Cel1, pac.Cel2, p.Valor, pac.NomePaciente, (select group_concat(' ', proc.NomeProcedimento) from itensproposta ip left join procedimentos proc on proc.id=ip.ItemID where ip.PropostaID=p.id) procedimentos from propostas p LEFT JOIN propostasstatus s on s.id=p.StaID LEFT JOIN pacientes pac on pac.id=p.PacienteID "&leftProc&" WHERE p.sysActive=1 and p.StaID IN("&replace(ref("Status"), "|", "")&") AND p.DataProposta BETWEEN "&mydatenull(ref("De"))&" AND "&mydatenull(ref("Ate"))&" "& sqlProc & sqlUser & whereUnidade &" group by p.id order by p.DataProposta desc"
                        set p = db.execute(sqlp)
                    end if

                    set ConfigSQL = db.execute("SELECT NomeEmpresa FROM sys_config ")
                    if not ConfigSQL.eof then
                        NomeEmpresa = ConfigSQL("NomeEmpresa")
                    end if
                    while not p.eof
                        PropostaNaoExecutada = false
                        %>
                        <tr>
                            <td><%=p("DataProposta")%></td>
                            <%if req("PacienteID")="" then

                                Tel = p("Tel1")
                                Cel = p("Cel1")

                                if Tel1&"" = "" then
                                    Tel = p("Tel2")
                                end if
                                if Cel&"" = "" then
                                    Cel = p("Cel2")
                                end if


                                TagWhatsApp = True

                                if not celularValido(Cel) then
                                    TagWhatsApp= False
                                end if

                                CelularFormatado = formataCelularWhatsApp(Cel)

                                TextoWhatsApp = "*"&NomeEmpresa&"*%0a%0aOla, "&TratarNome("Título", p("NomePaciente"))&" !"
                            %>
                                <td nowrap><%=p("NomePaciente")%></td>
                                <td><span <% if TagWhatsApp then %> style="color: #6495ed; text-decoration: underline"  onclick="AlertarWhatsapp('<%=CelularFormatado%>', `<%=TextoWhatsApp%>`, '<%=p("id")%>')" <% else %> <%=Tel%>&nbsp;&nbsp;<%=Cel%> <%end if%> ><span id="wpp-<%=p("id")%>"></span> <%= Cel %></span>

                            <%end if%>
                            <td><%=p("Procedimentos")%></td>
                            <td><%=p("NomeStatus")%></td>
                            <td>
                                <%if isnull(p("InvoiceID")) AND (p("PacienteID")&""<>"" AND p("PacienteID")&""<>"0") then
                                    PropostaNaoExecutada = True
                                %>
                                    <a href="./?P=GerarContrato&Pers=1&PropostaID=<%=p("id")%>" class="btn btn-xs btn-default">Gerar Contrato</a>
                                <%elseif p("PacienteID")&""="" or p("PacienteID")&""="0"  then%>
                                    <span class="btn btn-xs btn-danger" style="cursor: default" title="Sem paciente selecionado">Indisponível</span>
                                <%else%>
                                    <a href="./?P=invoice&I=<%=p("InvoiceID")%>&A=&Pers=1&T=C" class="btn btn-xs btn-info">Ver Contrato</a>
                                <%end if%>
                            </td>
                            <% if session("Banco")<>"clinic4456" or (session("Banco")="clinic4456" and lcase(session("Table"))="funcionarios") then %>
                                <%
                                    valor = p("Valor")

                                    if valor&"" = "" then
                                        valor=0
                                    end if

                                %>
                                <td class="text-right">R$ <%=formatnumber(valor,2)%></td>
                            <% end if %>
                            <td nowrap>
                                <%if session("OtherCurrencies")="phone" then %>
                                <a class="btn btn-xs btn-info" title="Enviar por E-mail"
                                    onclick="enviarPorEmail(<%=p("id")%>)"
                                    ><i class="far fa-paper-plane"></i></a>
                                <%end if %>
                                <a class="btn btn-xs btn-success" href="<%if req("PacienteID")="" then%>./?P=PacientesPropostas&Pers=1&I=<%=req("I")%>&PropostaID=<%=p("id")%><%
                                    else
                                    %>javascript:ajxContent('PacientesPropostas&CallID=<%=CallID %>&PacienteID=<%=req("PacienteID")%>&PropostaID=<%=p("id")%>', '', '1', 'pront<%=CallID %>')<%end if%>" title="Editar Proposta"><i class="far fa-edit"></i></a>
                                <%
                                if aut("|propostasX|")=1 and PropostaNaoExecutada then
                                %>
                                <button type="button" class="btn btn-xs btn-danger" onClick="x(<%=p("id")%>)" title="Excluir Proposta"><i class="far fa-remove"></i></button>
                                <%
                                end if
                                %>
                            </td>
                        </tr>
                        <%
                    p.movenext
                    wend
                    p.close
                    set p=nothing
                    %>
                </tbody>
            </table>
            </div>
        </div>
        </div>


<script type="text/javascript">
/*function x(I){
		location.href='./?P=listaPropostas&CallID=<%=CallID %>&Pers=1&I=<%=req("I")%>&X='+I;
	}*/
function enviarPorEmail(id) {
    $.post("enviarProposta.asp?Pers=1&I="+id, '', function(data, status){
        $("#modal-table").modal("show");
        $("#modal").html(data);
    });
}

function x(i) {
    if (confirm('Tem certeza de que deseja excluir esta proposta?')) {
        d = $("#resPropostas, #pront");
        d.html('<center><i class="far fa-circle-o-notch fa-spin"></i> Buscando...</center>')
        $.post("listaPropostas.asp?CallID=<%=CallID %>&I=<%=req("I")%>&PacienteID=<%=req("PacienteID")%>&X=" + i, $("#frmProposta").serialize(), function (data) {
            d.html(data);
        });
    }
}
</script>