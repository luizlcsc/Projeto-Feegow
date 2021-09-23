<!--#include file="connect.asp"-->
<%
PacoteID = req("id")
Tipo = ref("Tipo")

if Tipo="pedidoexame" then
    Titulo = "Exames"
else
    Tipo="pedidosadt"
    Titulo = "Pedidos"
end if


if req("A")="XP" then
    db_execute("delete from pacotesprontuarios where id="&req("I"))
    db_execute("delete from pacotesprontuariositens where PacoteID="&req("I"))
end if

if PacoteID="Lista" then
    %>

    <h1>Pacotes de <%=Titulo%></h1>
    <table class="table table-hover">
        <thead>
            <tr>
                <th>Nome</th>
                <th>Profissionais</th>
                <th>Especialidades</th>
                <th width="1%"></th>
                <th width="1%"><button type="button" class="btn btn-xs btn-success" onclick="modalPastas('', 0)"><i class="far fa-plus"></i></button></th>
            </tr>
        </thead>
        <tbody>
            <%
            set pp = db.execute("select * from pacotesprontuarios where sysActive=1 and tipo='"&Tipo&"' order by Nome")
            while not pp.eof
                listaEspecialidade=""
                listaProfissionais=""
                ppEspecialidades = pp("Especialidades")
                ppProfissionais = pp("Profissionais")

                if ppEspecialidades&""<>"" then
                    listEspec = replace(ppEspecialidades&"", "|", "")
                    if listEspec&""="" then
                        listEspec = "0"
                    end if
                    set sqlEsps = db.execute("select group_concat(Especialidade separator ', ') especialidades from especialidades where sysActive=1 and id in("&listEspec&")")
                    if not sqlEsps.eof then
                        listaEspecialidade = sqlEsps("especialidades")
                    end if
                end if

                if ppProfissionais&""<>"" then
                    listProf = replace(ppProfissionais&"", "|", "")
                    if listProf&""="" then
                        listProf = "0"
                    end if
                    set sqlProf = db.execute("select group_concat(NomeProfissional separator ', ') NomeProfissional from profissionais where sysActive=1 and id in("&listProf&")")
                    if not sqlProf.eof then
                        listaProfissionais = sqlProf("NomeProfissional")
                    end if
                end if
                %>
                <tr>
                    <td><%= pp("Nome") %></td>
                    <td><%= listaProfissionais %></td>
                    <td><%= listaEspecialidade %></td>

                    <%if (pp("sysUser")=session("User") and aut("modelosprontuarioA")=1) or session("Admin")=1 then%>
                        <td><button type="button" onclick="modalPastas('', <%= pp("id") %>)" class="btn btn-success btn-xs"><i class="far fa-edit"></i></button></td>
                        <td><button onclick="ppi('XP', <%= pp("id") %>)" type="button" class="btn btn-danger btn-xs"><i class="far fa-remove"></i></button></td>
                    <%else%>
                        <td></td>
                        <td></td>
                    <%end if%>
                </tr>
                <%
            pp.movenext
            wend
            pp.close
            set pp = nothing
            %>

        </tbody>
    </table>
    <%
else
    if PacoteID="0" then
        set vca = db.execute("select id from pacotesprontuarios where sysUser="&session("User")&" and sysActive=0")
        if not vca.eof then
            PacoteID = vca("id")
        else
            db.execute("insert into pacotesprontuarios (Tipo, sysUser, sysActive) values ('"&Tipo&"', "&session("User")&", 0)")
            set vca = db.execute("select id from pacotesprontuarios where sysUser="&session("User")&" and sysActive=0")
            PacoteID = vca("id")
        end if
    end if

    Acao = req("A")
    I = req("I")

    if Acao="I" then
        db.execute("insert into pacotesprontuariositens (PacoteID, ItemID) values ("& PacoteID &", "& I &")")
    end if
    if Acao="X" then
        db.execute("delete from pacotesprontuariositens where id="& I)
    end if

    if Acao="S" then
        db.execute("update pacotesprontuarios set Nome='"& ref("NomePPI") &"', Tipo='"&Tipo&"', Profissionais='"& ref("ProfissionaisPPI") &"', Especialidades='"& ref("EspecialidadesPPI") &"', sysActive=1 where id="& PacoteID)
        %>
        <script type="text/javascript">
            modalPastas('', 'Lista');
        </script>
        <%
    end if

    set pct = db.execute("select * from pacotesprontuarios where id="& PacoteID)
    if not pct.eof then
        Nome = pct("Nome")
        Especialidades = pct("Especialidades")
        Profissionais = pct("Profissionais")
    end if

    if ref("NomePPI")<>"" then
        Nome = ref("NomePPI")
        Especialidades = ref("EspecialidadesPPI")
        Profissionais = ref("ProfissionaisPPI")
    end if

    if Tipo="pedidoexame" then
        sqlConteudo = "select id, NomeProcedimento Descricao FROM procedimentos WHERE TipoProcedimentoID=3 AND sysActive=1 AND Ativo='on' order by NomeProcedimento"
        sqlExibirConteudo = "select ppi.id, p.NomeProcedimento descricao from pacotesprontuariositens ppi LEFT JOIN procedimentos p ON p.id=ppi.ItemID where PacoteID="& PacoteID
    else
        sqlConteudo = "select codigo id, concat(codigo, ' - ', descricao) Descricao from cliniccentral.procedimentos where tipoTabela='22' order by Descricao"
        sqlExibirConteudo = "select ppi.id, p.descricao from pacotesprontuariositens ppi LEFT JOIN cliniccentral.procedimentos p ON (p.codigo=ppi.ItemID and tipoTabela='22') where PacoteID="& PacoteID
    end if

    %>
    <h1>Pacotes de <%=Titulo%></h1>
    <div class="row">
    	    <input type="hidden" name="Tipo" id="Tipo" value="<%=Tipo%>">
            <%= quickfield("text", "NomePPI", "Nome", 4, Nome, "", "", "") %>
            <%= quickfield("multiple", "ProfissionaisPPI", "Profissionais", 3, Profissionais, "select id, NomeProfissional from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", "") %>
            <%= quickfield("multiple", "EspecialidadesPPI", "Especialidades", 3, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>
            <div class="col-md-2">
                <button class="btn btn-primary mt25" onclick="ppi('S', <%= PacoteID %>)"><i class="far fa-save"></i> SALVAR</button>
            </div>
    </div>
    <div class="row">
        <%= quickfield("simpleSelect", "ProcSADTAdd", "Procedimentos", 4, "", sqlConteudo, "Descricao", "") %>
        <div class="col-md-2 pt25">
            <button type="button" class="btn btn-success" onclick="ppi('I', $('#ProcSADTAdd').val())"><i class="far fa-plus"></i> Adicionar</button>
        </div>
    </div>
    <hr class="short alt" />
    <div class="row">
        <div class="col-md-12">
            <table class="table table-condensed table-hover">
            <%
            set ppi = db.execute(sqlExibirConteudo)
                while not ppi.eof
                    %>
                    <tr>
                        <td><%= ppi("descricao") %></td>
                        <td width="1%">
                            <button onclick="ppi('X', <%= ppi("id") %>)" type="button" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button>
                        </td>
                    </tr>
                    <%
                ppi.movenext
                wend
                ppi.close
                set ppi = nothing
            %>
            </table>
        </div>
    </div>


    <%
end if
%>
<script type="text/javascript">

function ppi(A, I) {
    $.post("pacotesProntuarios.asp?A=" + A + "&I=" + I + "&id=<%=PacoteID%>", $("#NomePPI, #Tipo, #EspecialidadesPPI, #ProfissionaisPPI").serialize(), function (data) {
        $("#iProntCont").html(data);
    });
}

<!--#include file="JQueryFunctions.asp"-->
</script>
