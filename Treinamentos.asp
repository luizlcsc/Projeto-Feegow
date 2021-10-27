<!--#include file="connect.asp"-->
<%

set dblicense = newConnection("clinic5459", "dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com")

if req("Fim")="1" then
    dblicense.execute("update treinamentos set Fim=now() where AnalistaID="& session("User") &" and isnull(Fim)")
    response.Redirect("./?P=Treinamentos&Pers=1")
end if


%>
<div class="panel mt20">
    <div class="panel-body">
        <%
        set vca = dblicense.execute("select * from treinamentos where AnalistaID="& session("User") &" and isnull(Fim)")
        if vca.eof then
            if ref("Usuario")<>"" and ref("LicencaUsuarioID")="" then
                %>
                <div class="alert alert-danger">Selecione um usuário para iniciar a apresentação.</div>
                <%
            elseif ref("Usuario")<>"" and ref("LicencaUsuarioID")<>"" then
                dblicense.execute("insert into treinamentos (LicencaUsuarioID, PerfilPersonaID, PerfilEmpresaID, OutrasCaracteristicas, AnalistaID, Inicio) VALUES ("& ref("LicencaUsuarioID") &", "& ref("PerfilEmpresa") &", "& ref("Persona") &", '"& ref("Caracteristicas") &"', "& session("User") &", NOW() )")
                response.Redirect("./?P=Treinamentos&Pers=1&H="& time())
            end if
            %>
                    <form method="post" action="">
                        <h1>INICIAR APRESENTAÇÃO</h1>
                        <hr class="short alt" />
                        <div class="row">
                            <%= quickfield("text", "Usuario", "E-mail de acesso ao Feegow", 6, ref("Usuario"), "", "", "placeholder='Digite e-mail ou nome' onclick='$(this).select()' autocomplete='off' required ") %>
                            <%= quickfield("simpleSelect", "PerfilEmpresa", "Qual o perfil da empresa", 3, ref("PerfilEmpresa"), "select * from treinamentoempresas", "TipoEmpresa", " empty required ") %>
                            <%= quickfield("simpleSelect", "Persona", "Qual o perfil da pessoa", 3, ref("Persona"), "select * from treinamentopersonas", "Persona", " empty required ") %>
                        </div>
                        <div class="row pt20">
                            <%= quickfield("text", "Website", "Endereço do site da clínica", 12, ref("Website"), "", "", " placeholder='Caso não tenha digite -' required ") %>
                        </div>
                        <div class="row pt20">
                            <%= quickfield("simpleSelect", "Marketing", "Tem interesse em conhecer as ferramentas de marketing do sistema para atrair mais pacientes ou fidelizá-los?", 12, ref("Marketing"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                            <div id="divUsuarios" style="width:600px; display:none; overflow-x:hidden; overflow-y:scroll; height:400px; margin:62px 0 0 15px; position:absolute; border:1px solid #ccc; background-color:#fff"></div>
                            <input type="hidden" name="LicencaUsuarioID" id="LicencaUsuarioID" value="<%= ref("LicencaUsuarioID") %>" />
                        </div>
                        <div class="row pt20">
                            <%= quickfield("simpleSelect", "Multiclinica", "Possui mais de uma unidade da clínica?", 6, ref("Multiclinica"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                            <%= quickfield("multiple", "Especialidades", "Quais as principais especialidades?", 6, ref("Especialidades"), "select * from especialidades order by especialidade", "especialidade", " empty required ") %>
                        </div>
                        <div class="row pt20">
                            <%= quickfield("simpleSelect", "Convenio", "Aceita convênio?", 4, ref("Convenio"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                            <%= quickfield("simpleSelect", "Triagem", "Possui triagem ou pré-atendimento de pacientes?", 4, ref("Triagem"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                            <%= quickfield("simpleSelect", "Laudo", "Algum profissional emite laudo na clínica?", 4, ref("Laudo"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                        </div>
                        <div class="row pt20">
                            <%= quickfield("multiple", "FormasRecto", "Com quais formas de pagamento a clínica trabalha?", 6, ref("FormasRecto"), "select * from sys_financialpaymentmethod where AccountTypesC<>''", "PaymentMethod", " empty required ") %>
                            <%= quickfield("simpleSelect", "Equipamentos", "Possui equipamentos pra execução de procedimentos?", 6, ref("Equipamentos"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                        </div>
                        <div class="row pt20">
                            <%= quickfield("simpleSelect", "VendeExame", "Vende algum tipo de exame?", 6, ref("VendeExame"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                            <%= quickfield("simpleSelect", "CataoFidelidade", "Possui algum tipo de cartão fidelidade ou plano próprio?", 6, ref("CataoFidelidade"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                        </div>
                        <div class="row pt20">
                            <%= quickfield("simpleSelect", "Orcamento", "Emite orçamentos / propostas?", 4, ref("Orcamento"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                            <%= quickfield("simpleSelect", "AlcadaDesconto", "Existem políticas de desconto?", 4, ref("AlcadaDesconto"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                            <%= quickfield("simpleSelect", "AprovacaoDesconto", "Deseja utilizar aprovação de desconto em tempo real?", 4, ref("AprovacaoDesconto"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                        </div>
                        <div class="row pt20">
                            <%= quickfield("simpleSelect", "Repasse", "Paga algum tipo de repasse / comissão aos profissionais da clínica?", 6, ref("Repasse"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                            <%= quickfield("simpleSelect", "RepasseInvertido", "Tem algum acordo onde o médico aceite plano próprio e pague o repasse à clínica?", 6, ref("Equipamentos"), "select 'S' id, 'Sim' Valor UNION select 'N', 'Não'", "Valor", " empty required ") %>
                        </div>
                        <div class="row pt20">
                        </div>
                        <div class="row">
                            <div class="col-md-1">
                                <button class="btn btn-primary mt25">INICIAR</button>
                            </div>
                        </div>
                    </form>
            <%
        else
            TreinamentoID = vca("id")
            set cli = dblicense.execute("SELECT lu.id, upper(ifnull(lu.Nome,'')) Nome, lower(lu.email) Email, upper(IFNULL(p.NomePaciente, '')) Empresa FROM cliniccentral.licencasusuarios lu LEFT JOIN cliniccentral.licencas l ON l.id=lu.LicencaID LEFT JOIN clinic5459.pacientes p ON p.id=l.Cliente WHERE lu.id="& vca("LicencaUsuarioID"))
            Nome = cli("Nome")
            Empresa = cli("Empresa")
            if req("T")<>"" then
                dblicense.execute("insert into treinamentosnav set TreinamentoID="& TreinamentoID &", Tela="& req("T") &", Hora=now()")
                %>
                <script type="text/javascript">
                    $(".crumb-active a").html("<%= Nome %>");
                    $(".crumb-link").removeClass("hidden");
                    $(".crumb-link").html("<%= Empresa %>");
                    $(".crumb-icon a span").attr("class", "far fa-reorder");
                    <%
                    if aut("lancamentosI")=1 then
                    %>
                    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" target="_blank" href="./?P=Treinamento&Pers=0&I=<%= req("T") %>"><i class="far fa-exchange"></i><span class="menu-text"> Editar</span></a>');
                    <%
                    end if
                    %>
                </script>
                <%
                set tela = dblicense.execute("SELECT * FROM treinamento WHERE id="& req("T"))
                Recurso = tela("Recurso")
                FraseCurta = tela("FraseCurta")
                ProblemasResolvidos = tela("ProblemasResolvidos")
                Detalhamento = tela("Detalhamento")
                %>
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel-body mt20" style="font-size:18px">
                            <h2><code><%= ucase(Recurso) %></code></h2><br />
                            <%= Detalhamento %>
                        </div>
                    </div>
                </div>
                <div class="panel-body mt20">
                    <%
                    arrTipos = array("Criticas", "Bugs", "Sugestoes", "Elogios")
                    arrLTipos = array("Críticas", "Bugs", "Sugestões", "Elogios")
                    for j=0 to ubound(arrTipos)
                        Memo = ""
                        set vcaM = dblicense.execute("select Memo from treinamentosmemo where Tela="& req("T") &" and TreinamentoID="& TreinamentoID &" and Tipo='"& arrTipos(j) &"'")
                        if not vcaM.eof then
                            Memo = vcaM("Memo")
                        end if
                        call quickfield("memo", arrTipos(j), arrLTipos(j), 3, Memo, "", "", "")
                    next
                    %>
                </div>
                <hr class="short alt" />
                <div class="row">
                    <div class="col-md-6">
                        <div class="panel-body">
                            <code>Pitch</code>
                            <%= FraseCurta %>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="panel-body">
                            <code>Problemas por não ter este recurso</code>
                            <%= ProblemasResolvidos %>
                        </div>
                    </div>
                </div>
                <hr class="short alt" />
                <div class="row">
                    <div class="col-md-2"><button type="button" class="btn btn-lg btn-system btn-block" id="anterior">ANTERIOR</button></div>
                    <div class="col-md-8 text-center"><button onclick="location.href='./?P=Treinamentos&Pers=1&Fim=1&T=<%= req("T") %>'" type="button" class="btn btn-lg btn-warning" id="fim">FINALIZAR</button></div>
                    <div class="col-md-2"><button type="button" class="btn btn-lg btn-system btn-block" id="proximo">PRÓXIMO</button></div>
                </div>
                <%
            end if
        end if
        %>
    </div>
</div>

<script type="text/javascript">
$("#Usuario").keyup(function(){
    v = $(this).val();
    d = $("#divUsuarios");
    u = $("#LicencaUsuarioID")
    u.val("");
    if(v==""){
        d.css("display", "none");
    } else {
        d.css("display", "block");
        $.get("TreinamentosListaUsuarios.asp?U="+v, function(data){ d.html(data) });
    }
});

$("textarea").change(function(){
    $.post("treinamentosmemo.asp?Tela=<%= req("T")%>&TreinamentoID=<%= TreinamentoID %>&Tipo="+ $(this).attr("id"), { M: $(this).val() }, function (data) { eval(data) });
});
</script>
