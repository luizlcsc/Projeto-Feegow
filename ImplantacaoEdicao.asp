<!--#include file="connect.asp"-->
<%
ClienteID = req("ClienteID")

if req("Alt")="1" then
    EtapaID = ref("EtapaID")
    StatusID = ref("StatusID")
    Notas = ref("Notas")
    db.execute("update impla_acoes set Atual=NULL where ClienteID="& ClienteID &" and EtapaID="& EtapaID)
    db.execute("insert into impla_acoes (EtapaID, StatusID, ClienteID, Notas, Atual, UsuarioID) values ("& EtapaID &", "& StatusID &", "& ClienteID &", '"& Notas &"', 1, "& session("User") &")")
    %>
    location.reload();
    <%
else
    %>

    <form method="post" id="altSta">
        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">Edição de Status</span>
            </div>
            <div class="panel-body">
                    <%= quickfield("simpleSelect", "EtapaID", "Etapa", 4, "", "select * from impla_etapas", "Texto", " empty required ") %>
                    <%= quickfield("simpleSelect", "StatusID", "Status", 4, "", "select * from impla_status", "Status", " empty required ") %>
                    <%= quickfield("memo", "Notas", "Observações", 12, "", "", "", " required ") %>
            </div>
        </div>
        <div class="panel-footer">
            <button type="submit" class="btn btn-primary">SALVAR</button>
        </div>
    </form>

    <div class="panel">
        <div class="panel-body">
        <%
        set pac = db.execute("select * from pacientes where id="& ClienteID)
        if not pac.eof then
            Nome = pac("NomePaciente")
            Fantasia = pac("NomeSocial")
            %>
            <div class="panel">
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-6">
                            <b>Razão Social:</b><br /> <%= Nome %> <a target="_blank" href="./?P=Pacientes&Pers=1&I=<%= pac("id") %>" class="btn btn-xs btn-primary"><i class="far fa-edit"></i></a>
                        </div>
                        <div class="col-md-6">
                            <b>Nome Fantasia:</b><br /> <%= Fantasia %>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6"><b>Telefones:</b><br /> <%= "<code>"& pac("Tel1") &" </code> <code> "& pac("Tel2") &" </code> <code> "& pac("Cel1") &" </code> <code> "& pac("Cel2") &"</code>" %></div>
                        <div class="col-md-6"><b>E-mails:</b><br /> <%= "<code>"& pac("Email1") &" </code> <code> "& pac("Email2") &"</code>" %></div>
                    </div>
                </div>
            </div>
            <%
        end if
        set ia = db.execute("select ia.*, ist.Status, ist.Classe, ie.Texto Etapa from impla_acoes ia LEFT JOIN impla_etapas ie ON ie.id=ia.EtapaID LEFT JOIN impla_status ist ON ist.id=ia.StatusID where ClienteID="& ClienteID &" order by DataHora DESC")
        while not ia.eof
            %>
            <div class="row">
                <div class="col-md-3">
                    <span class="label label-xs label-<%= ia("Classe") %>"><%= ia("Status") %></span>
                    <br />
                    <%= nameInTable(ia("UsuarioID")) %>
                    <br />
                    <%= ia("DataHora") %>
                </div>
                <div class="col-md-9">
                    <b><%= ia("Etapa") %></b><br />
                    <%= ia("Notas") %></div>
            </div>
            <%
        ia.movenext
        wend
        ia.close
        set ia = nothing
        %>
        </div>
    </div>

    <script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->

    $("#altSta").submit(function () {
        $.post("ImplantacaoEdicao.asp?ClienteID=<%= ClienteID %>&Alt=1", $(this).serialize(), function (data) { eval(data) });
        return false;
    });
    </script>
    <%
end if
%>
