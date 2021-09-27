<%
session("Banco") = "clinic5459"
session("Servidor") = "dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com"
%>
<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<style type="text/css">
    .ff {
        position:absolute;
        margin-left:-28px;
    }
    .ffr {
        position:absolute;
        right:0;
    }
</style>
<% if session("User")="" then %>
    <meta http-equiv="refresh" content="60" />
    <%
end if
    response.buffer
    set impo = db.execute("SELECT ii.id, i.id, i.AssociationAccountID, i.AccountID, p.NomePaciente, p.NomeSocial, ii.DataExecucao, ii.Quantidade * (ii.ValorUnitario+ii.Acrescimo-ii.Desconto) ValorS, id.Valor ValorQuitado, m.Value ValorPagto, m.Date DataPagto, pro.Foto FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN pacientes p ON p.id=i.AccountID LEFT JOIN sys_users su ON su.id=p.sysUser LEFT JOIN profissionais pro ON pro.id=su.idInTable LEFT JOIN itensdescontados id ON id.ItemID=ii.id LEFT JOIN sys_financialmovement m ON m.id=id.PagamentoID WHERE ii.ItemID=3 AND ii.Tipo='S' AND i.CD='C' AND NOT ISNULL(m.Value) GROUP BY i.AccountID ORDER BY m.Date DESC LIMIT "& req("F") &", 30")
    while not impo.eof
        response.flush()
        %>
        <div class="panel col-xs-<% if session("User")="" then response.write(2) else response.write(4) end if %>">
            <div class="panel-heading bg-primary" <%if session("User")<>"" then %> onclick="ed(<%= impo("AccountID") %>)" <%end if %> >
                <span class="panel-title"><%= left(impo("NomePaciente")&"", 15) %><small> :: <%= left(impo("NomeSocial")&"", 15) %></small></span>
				<code><%= datediff("d", impo("DataPagto"), date()) %></code>
                <img src="/uploads/5459/Perfil/<%= impo("Foto") %>" class="mw30 br64 ffr">
            </div>
            <div class="panel-body pn">
                <table class="table table-consensed">
                    <thead>

                    </thead>
                    <tbody id="b<%= impo("AccountID") %>">
                    </tbody>
                </table>
            </div>
        </div>
        <%
    impo.movenext
    wend
    impo.close
    set impo = nothing
    %>
    <marquee style="position:fixed; width100%; padding:30px; bottom:0; left:0;" id="ranking"></marquee>
<script type="text/javascript">
    $("tbody").html('<%
    set et = db.execute("select ie.* from impla_etapas ie")
    while not et.eof
        %><tr class="pn"><td class="p5"><%= et("Texto") %></td><td class="pn"><span class="label label-xs mn label-replace label-e<%= et("id") %>">PENDENTE FEEGOW</span></td></tr><%
    et.movenext
    wend
    et.close
    set et=nothing
    %>');

    $(document).ready(function () {
    <%
        set ia = db.execute("select ia.EtapaID, ia.StatusID, ia.ClienteID, ist.Status, ist.Classe, prof.Foto, prof.id ProfissionalID from impla_acoes ia LEFT JOIN impla_status ist ON ist.id=ia.StatusID LEFT JOIN sys_users su ON su.id=ia.UsuarioID LEFT JOIN profissionais prof ON prof.id=su.idInTable WHERE ia.Atual=1 GROUP BY ia.EtapaID, ia.ClienteID ORDER BY ia.EtapaID desc")
        while not ia.eof
            %>
            $("#b<%= ia("ClienteID") %> tr td .label-e<%= ia("EtapaID") %>").html("<%= "<img src='/uploads/5459/Perfil/"& ia("Foto") &"' class='mw30 br64 ff'>" & ucase(ia("Status")&"") %>");
            $("#b<%= ia("ClienteID") %> tr td .label-e<%= ia("EtapaID") %>").addClass("label-<%= ia("Classe") %>");$("#b<%= ia("ClienteID") %> tr td .label-e<%= ia("EtapaID") %>").removeClass("label-replace");
            <% 
            if ia("StatusID")=4 then %>
                if( $("#foto<%= ia("ProfissionalID")%>").size()==0 ){
                    $("#ranking").html( $("#ranking").html() + "<img src='/uploads/5459/Perfil/<%= ia("Foto") %>' id='foto<%= ia("ProfissionalID")%>' width='30' class='img-circle m15' style='border:4px solid green'>" );
                } else {
                    $("#foto<%= ia("ProfissionalID")%>").attr('width', parseInt($("#foto<%= ia("ProfissionalID")%>").attr('width'))+8 );
                    $("#foto<%= ia("ProfissionalID")%>").attr('height', parseInt($("#foto<%= ia("ProfissionalID")%>").attr('width'))+8 );
                }
                <%
            end if
        ia.movenext
        wend
        ia.close
        set ia = nothing
    %>
    $(".label-replace").addClass("label-danger");
    });

    function ed(ClienteID) {
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
        $.get("ImplantacaoEdicao.asp?ClienteID=" + ClienteID, function (data) {
            $("#modal").html(data);
        });
    }
    
</script>