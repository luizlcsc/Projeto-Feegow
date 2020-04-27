<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="Classes/Connection.asp"-->
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
<script type="text/javascript">
    $(".crumb-active a").html("Implantação");
    // $(".crumb-link").removeClass("hidden");
    // $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "fa fa-question-circle");
</script>
<div class="panel mt15">
    <div class="panel-body">

        <table class="table table-bordered table-striped">

            <thead>
                <tr class="primary">
                    <th>#</th>
                    <th>Pagamento</th>
                    <th>Vendedor</th>
                    <th>Razão social</th>
                    <th>Celular</th>
                    <th>N. Usuários</th>
                    <th >Cert. Nasc. (0)</th>
                    <th >Boas-vindas (1)</th>
                    <th >Ag. futuros (2)</th>
                    <th >Ag. concluídos (3)</th>
                    <th >Banco de Dados</th>
                    <th >Último acesso</th>
                    <th></th>
                </tr>
            </thead>

            <tbody>
<%
set db = newConnection("clinic5459","dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com")

function etapaIcon(valorBool, descricao)
    %>
    <span data-toggle="tooltip" title="<%=descricao%>">
    <%

    if valorBool then
        %> <i class="fa fa-check-circle" style="color: green"></i> <%
    else
        %> <i class="fa fa-times-circle" style="color: red"></i> <%
    end if
    %>
    </span>
    <%
end function

if session("User")="" then %>
    <meta http-equiv="refresh" content="60" />
    <%
end if
    response.buffer
    set impo = db.execute("SELECT prof.NomeProfissional ,l.id LicencaID ,ii.id, i.id, i.AssociationAccountID, i.AccountID, p.NomePaciente, p.Cel1, p.NomeSocial, ii.DataExecucao, ii.Quantidade,ii.Quantidade * (ii.ValorUnitario+ii.Acrescimo-ii.Desconto) ValorS, id.Valor ValorQuitado, m.Value ValorPagto, m.Date DataPagto, pro.Foto " &_
    " FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID " &_
    " INNER JOIN pacientes p ON p.id=i.AccountID " &_
    " LEFT JOIN cliniccentral.licencas l ON l.Cliente=p.id " &_
    " LEFT JOIN profissionais prof ON prof.id=ii.ProfissionalID " &_
    " LEFT JOIN sys_users su ON su.id=p.sysUser LEFT JOIN profissionais pro ON pro.id=su.idInTable LEFT JOIN itensdescontados id ON id.ItemID=ii.id LEFT JOIN sys_financialmovement m ON m.id=id.PagamentoID " &_
    " WHERE ii.ItemID=3 AND ii.Tipo='S' AND i.CD='C' AND NOT ISNULL(m.Value) GROUP BY i.AccountID ORDER BY m.Date DESC LIMIT 400")
    while not impo.eof
        Response.Flush()

        ClienteID=impo("AccountID")
        LicencaID=impo("LicencaID")
        response.flush()
        Etapa0OK = False
        Etapa1OK = False
        Etapa2OK = False
        Etapa3OK = False
        Etapa4OK = False
        Etapa5OK = False


        Etapa0Descricao=""
        Etapa1Descricao=""
        Etapa2Descricao=""
        Etapa3Descricao=""
        Etapa4Descricao=""
        Etapa5Descricao=""

        classeUltimoAcesso=""

        set Etapa1SQL = db.execute("SELECT ie.Texto, ia.DataHora, lu.Nome Usuario FROM impla_acoes ia LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=ia.UsuarioID INNER JOIN impla_etapas ie ON ie.id=ia.EtapaID WHERE ia.ClienteID="&ClienteID&" AND ia.EtapaID=1")
        if not Etapa1SQL.eof then
            Etapa1OK=True
            Etapa1Descricao = Etapa1SQL("Texto")&" em "&Etapa1SQL("DataHora") &" por "&Etapa1SQL("Usuario")
        end if

        set CertidaoDeNascimentoSQL = db.execute("SELECT DataHora FROM buiformspreenchidos WHERE PacienteID="&ClienteID&" AND ModeloID=48 AND sysActive=1")
        if not CertidaoDeNascimentoSQL.eof then
            Etapa0OK=True
            Etapa0Descricao="Certidão lançada em "&CertidaoDeNascimentoSQL("DataHora")
        end if

        set UltimoAcessoSQL = db.execute("SELECT u.DataHora FROM cliniccentral.licencaslogins u WHERE LicencaID="&treatvalzero(LicencaID)&" AND Sucesso=1 ORDER BY DataHora DESC LIMIT 1")
        UltimoAcesso = "-"
        if not UltimoAcessoSQL.eof then
            UltimoAcesso = datediff("d", UltimoAcessoSQL("DataHora"), date())
            UltimoAcessoDescricao="Último acesso há "&UltimoAcesso&" dia(s)"

            if ccur(UltimoAcesso)=0 then
                classeUltimoAcesso="success"
            end if
            if ccur(UltimoAcesso)>=1 then
                classeUltimoAcesso="warning"
            end if
            if ccur(UltimoAcesso)>15 then
                classeUltimoAcesso="danger"
            end if
        end if

        NumeroUsuarios = impo("Quantidade")
        classeNumeroUsuarios = ""

        if NumeroUsuarios > 5 then
            classeNumeroUsuarios = " warning"
        end if

        if NumeroUsuarios > 25 then
            classeNumeroUsuarios = " danger"
        end if

        set BancoDeDadosSQL = db.execute("SELECT csa.DataContratacao, csa.`Status`, ssa.TipoStatus from cliniccentral.clientes_servicosadicionais csa  "&_
                                         "INNER JOIN cliniccentral.status_servicosadicionais ssa ON ssa.id=csa.`Status` "&_
                                         "WHERE csa.ServicoID=5 AND csa.LicencaID="&treatvalzero(LicencaID))
        if not BancoDeDadosSQL.eof then
            if BancoDeDadosSQL("Status")=4 or BancoDeDadosSQL("Status")=6 then
                Etapa5OK = True
            end if
            Etapa5Descricao = "Status: "&BancoDeDadosSQL("TipoStatus")
        else
            Etapa5OK=True
            Etapa5Descricao = "Serviço não contratado"
        end if

        set Etapa3SQL = db.execute("SELECT count(a.id)Qtd FROM agendamentos a WHERE a.Data<=curdate() AND a.StaID IN (3) AND a.PacienteID="&ClienteID)
        if not Etapa3SQL.eof then
            if ccur(Etapa3SQL("Qtd"))>0 then
                Etapa3OK=True
            end if
            Etapa3Descricao = Etapa3SQL("Qtd") &" agendamento(s) realizado(s) "
        end if


        set Etapa2SQL = db.execute("SELECT count(a.id)Qtd FROM agendamentos a WHERE a.Data>=curdate() AND a.StaID IN (1, 7) AND a.PacienteID="&ClienteID)
        if not Etapa2SQL.eof then
            if ccur(Etapa2SQL("Qtd"))>0 or Etapa3OK then
                Etapa2OK=True


                Etapa2Descricao = Etapa2SQL("Qtd") &" agendamento(s) futuros"
            end if
        end if
        %>
        <tr >
            <td><code>#<%=LicencaID%></code></td>
            <td><%=impo("DataPagto")%></td>
            <td><%=impo("NomeProfissional")%></td>
            <td><small><%= impo("NomePaciente")&"" %></small></td>
            <td><%= impo("Cel1") %></td>
            <th class="<%=classeNumeroUsuarios%>"><%= NumeroUsuarios %></th>
            <td><%=etapaIcon(Etapa0OK, Etapa0Descricao)%></td>
            <td><%=etapaIcon(Etapa1OK, Etapa1Descricao)%></td>
            <td><%=etapaIcon(Etapa2OK, Etapa2Descricao)%></td>
            <td><%=etapaIcon(Etapa3OK, Etapa3Descricao)%></td>
            <td><%=etapaIcon(Etapa5OK, Etapa5Descricao)%></td>
            <td><small><span class="label label-<%=classeUltimoAcesso%>"><%=UltimoAcessoDescricao%></span></small></td>
            <td><button class="btn btn-xs btn-primary" type="button" onclick="ed(<%= impo("AccountID") %>)"><i class="fa fa-external-link"></i></button></td>
       </tr>
        <%
    impo.movenext
    wend
    impo.close
    set impo = nothing
    %>
            </tbody>
        </table>
    </div>
</div>
    <marquee style="position:fixed; width100%; padding:30px; bottom:0; left:0;" id="ranking"></marquee>
<script type="text/javascript">
    $(document).ready(function () {
    <%
    if false then
        set ia = db.execute("select ia.EtapaID, ia.StatusID, ia.ClienteID, ist.Status, ist.Classe, prof.Foto, prof.id ProfissionalID from impla_acoes ia LEFT JOIN impla_status ist ON ist.id=ia.StatusID LEFT JOIN sys_users su ON su.id=ia.UsuarioID LEFT JOIN profissionais prof ON prof.id=su.idInTable WHERE ia.Atual=1 GROUP BY ia.EtapaID, ia.ClienteID ORDER BY ia.EtapaID desc")
        while not ia.eof
            %>
            $("#b<%= ia("ClienteID") %> tr td .label-e<%= ia("EtapaID") %>").html("<%= "<img src='/uploads/5459/Perfil/"& ia("Foto") &"' class='mw30 br64 ff'>" & ucase(ia("Status")&"") %>");
            $("#b<%= ia("ClienteID") %> tr td .label-e<%= ia("EtapaID") %>").addClass("label-<%= ia("Classe") %>");$("#b<%= ia("ClienteID") %> tr td .label-e<%= ia("EtapaID") %>").removeClass("label-replace");
            <% 
            if ia("StatusID")=4 then %>
                if( $("#foto<%= ia("ProfissionalID")%>").size()==0 ){
                    //$("#ranking").html( $("#ranking").html() + "<img src='/uploads/5459/Perfil/<%= ia("Foto") %>' id='foto<%= ia("ProfissionalID")%>' width='30' class='img-circle m15' style='border:4px solid green'>" );
                } else {
                    //$("#foto<%= ia("ProfissionalID")%>").attr('width', parseInt($("#foto<%= ia("ProfissionalID")%>").attr('width'))+8 );
                    //$("#foto<%= ia("ProfissionalID")%>").attr('height', parseInt($("#foto<%= ia("ProfissionalID")%>").attr('width'))+8 );
                }
                <%
            end if
        ia.movenext
        wend
        ia.close
        set ia = nothing
    end if
    %>
    $(".label-replace").addClass("label-danger");
    });

    function ed(ClienteID) {
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.get("ImplantacaoEdicao.asp?ClienteID=" + ClienteID, function (data) {
            $("#modal").html(data);
        });
    }

    $(document).ready(function() {
      setTimeout(function() {
        $("#toggle_sidemenu_l").click()
      }, 500);
    })
</script>