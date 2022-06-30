<!--#include file="connect.asp"-->
<%
Tipo = req("Tipo")
ID = req("ID")
FormID = req("FormID")
CampoID = req("CampoID")
Comm = req("Comm")
Termo = req("Termo")
PacienteID = req("PacienteID")

set pCampo = db.execute("select * from buicamposforms where id="& CampoID)
Estruturacao = pCampo("Estruturacao")


function getProfissionaisEspecialidades(EspecialidadeID)
    set getEspecialidade = db.execute("select codigoTiss from cliniccentral.especialidades_correcao where id="&EspecialidadeID)
    if not getEspecialidade.eof then
        codigoTiss = getEspecialidade("codigoTiss")
    end if
    licenca = replace(session("Banco"), "clinic", "")
    sqlConteudo =  "SELECT '"&licenca&"' Licenca, CONCAT('"&licenca&"', '_', profEsp.ProfissionalID) id, p.NomeProfissional, profEsp.EspecialidadeID,  profEsp.Conselho, profEsp.UFConselho, profEsp.DocumentoConselho, esp.codigoTISS FROM profissionais p  "&_
                    "LEFT JOIN (SELECT ProfissionalID, EspecialidadeID, Conselho, UFConselho, DocumentoConselho FROM profissionaisespecialidades "&_
                    "UNION ALL "&_
                    "SELECT  id ProfissionalID, EspecialidadeID, Conselho, UFConselho, DocumentoConselho FROM profissionais) profEsp ON profEsp.ProfissionalID=p.id  "&_
                    "LEFT JOIN especialidades esp ON esp.id=profEsp.EspecialidadeID "&_
                    "WHERE p.sysActive=1 AND p.Ativo='on' AND esp.codigoTISS='"&codigoTiss&"' "

    set getCupom = db.execute("SELECT Cupom FROM cliniccentral.licencas WHERE Cupom<>'' AND Cupom is not null AND id="&replace(session("Banco"), "clinic",""))
    if not getCupom.eof then
        set getLicencas = db.execute("SELECT GROUP_CONCAT(id) licencas FROM cliniccentral.licencas WHERE Cupom Like '"&getCupom("Cupom")&"' ")
        if not getLicencas.eof then
            licenca = split(getLicencas("licencas"), ",")
            sqlConteudo = ""
            Union = ""
            for i = 0 to ubound(licenca)
                sql = "SELECT '"&licenca(i)&"' Licenca, CONCAT('"&licenca(i)&"', '_', profEsp.ProfissionalID) id, p.NomeProfissional, profEsp.EspecialidadeID,  profEsp.Conselho, profEsp.UFConselho, profEsp.DocumentoConselho, esp.codigoTISS FROM clinic"&licenca(i)&".profissionais p  "&_
                      "LEFT JOIN (SELECT ProfissionalID, EspecialidadeID, Conselho, UFConselho, DocumentoConselho FROM clinic"&licenca(i)&".profissionaisespecialidades "&_
                      "UNION ALL "&_
                      "SELECT  id ProfissionalID, EspecialidadeID, Conselho, UFConselho, DocumentoConselho FROM clinic"&licenca(i)&".profissionais) profEsp ON profEsp.ProfissionalID=p.id  "&_
                      "LEFT JOIN clinic"&licenca(i)&".especialidades esp ON esp.id=profEsp.EspecialidadeID "&_
                      "WHERE p.sysActive=1 AND p.Ativo='on' AND esp.codigoTISS='"&codigoTiss&"' "
                sqlConteudo = sqlConteudo & Union & sql
                Union = " UNION "
            next
        end if
    end if

    getProfissionaisEspecialidades = sqlConteudo

end function


if Tipo = "ciapAdd" then
    ID = ccur(ID)
    if ID=0 then
        db.execute("insert into Tags SET Tag='"& Termo &"', sysUser="& session("User"))
    elseif ID<0 then
        db.execute("insert into pacientestags SET FormID="& FormID &", CampoID="& CampoID &", TagID="& ID*(-1) &", sysUser="& session("User"))
    else
        db.execute("insert into pacientesciap (CiapID, FormID, CampoID, sysUser) values ("& ID &", "& FormID &", "& CampoID &", "& session("User") &")")
        set PacientesCiapSQL = db.execute("SELECT LAST_INSERT_ID() as Last")
        set Cid10SQL = db.execute("SELECT c.id, c.Descricao "&_
                                    " FROM cliniccentral.tesauro t "&_
                                    " LEFT JOIN cliniccentral.cid10 c ON c.codigo = REPLACE(t.CID10_Cd1,'.','') "&_
                                    " WHERE t.id="&ID)
        if not Cid10SQL.eof AND pCampo("EnviarDadosCid")&"" = "1" then
            CidID = Cid10SQL("id")
            DescricaoCid10 = Cid10SQL("Descricao")
            db.execute("insert into pacientesdiagnosticos (PacienteID, PacientesCiapID, FormID, CidID, Descricao, sysUser, sysActive) values ("& PacienteID &", '"& PacientesCiapSQL("last") &"', "& FormID &", "& CidID &", '"& DescricaoCid10 &"', "& session("User") &", '-1')")
        end if
    end if
    %>
    protList('ciapList', <%= FormID %>, <%= CampoID %>, '');
    <%
elseif Tipo = "prescAdd" then
    db.execute("insert into memed_prescricoes (MedicamentoID, FormID, PacienteID, CampoID, sysUser, sysActive) values ("& ID &", "& FormID &", "&PacienteID&", "& CampoID &", "& session("User") &", 1)")
    %>
    protList('prescList', <%= FormID %>, <%= CampoID %>, '');
    <%
elseif Tipo = "pedAdd" then
    db.execute("insert into protocolospedidos (PedidoID, FormID, PacienteID, CampoID, sysUser, sysActive) values ("& ID &", "& FormID &", "&PacienteID&", "& CampoID &", "& session("User") &", 1)")
    %>
    protList('pedList', <%= FormID %>, <%= CampoID %>, '');
    <%
elseif Tipo = "atesAdd" then
    if ID&""<>"" then
        set getAtestado = db.execute("SELECT TituloAtestado, TextoAtestado FROM pacientesatestadostextos WHERE id="&ID)
        if not getAtestado.eof then
            TituloAtestado = getAtestado("TituloAtestado")
            TextoAtestado = getAtestado("TextoAtestado")
        end if
        db.execute("insert into pacientesatestados (sysUser, sysActive, PacienteID, Atestado, Titulo, FormID, CampoID, AtestadoID) values ("& session("User") &", 1, "&PacienteID&", '"&TextoAtestado&"', '"&TituloAtestado&"', "&FormID&", "&CampoID&", "&ID&") ")
    end if
    %>
    protList('atesList', <%= FormID %>, <%= CampoID %>, '');
    <%
elseif Tipo = "encAdd" then
    db.execute("insert into protocolosencaminhamentos (Tipo, FormID, PacienteID, CampoID, sysUser, sysActive) values ('"& ID &"', "& FormID &", "&PacienteID&", "& CampoID &", "& session("User") &", 1)")
    %>
    protList('encList', <%= FormID %>, <%= CampoID %>, '');
    <%
elseif Tipo = "ciapList" then
    if Comm<>"" then
        if left(Comm, 1)="X" then
            if left(Comm, 2)="X-" then
                db.execute("delete from pacientestags where id="& replace(Comm, "X-", ""))
            else
                db.execute("delete from pacientesciap where id="& replace(Comm, "X", ""))
                db.execute("delete from pacientesdiagnosticos where PacientesCiapID="& replace(Comm, "X", ""))
            end if
        elseif left(Comm, 1)="U" then
            splU = split(replace(Comm, "U", ""), "_")
            db.execute("update pacientesciap set StatusID="& splU(1) &" WHERE id="& splU(0))
        end if
    end if
    sqlBmj = montaSubqueryBMJ("bmj.codcid10 = t.CID10_Cd1")
    set pc = db.execute("select pc.id, pc.StatusID, pc.DataEntrada, pc.DataSaida, pc.Hospital, c.Descricao as Termo, t.CID10_Cd1, " & sqlBmj & " bmj_link FROM pacientesciap pc LEFT JOIN cliniccentral.tesauro t ON t.id=pc.CiapID LEFT JOIN cliniccentral.cid10 c ON c.codigo = REPLACE(t.CID10_Cd1,'.','') WHERE pc.FormID="& FormID &" AND pc.CampoID="& CampoID &_
        " UNION ALL "&_
                        "select pt.id, '', NULL, NULL, NULL, t.Tag, 'Tag', '' bmj_link FROM pacientestags pt LEFT JOIN tags t ON t.id=pt.TagID WHERE pt.FormID="& FormID &" AND pt.CampoID="& CampoID)

    if 0 then
    %>
    <span class="label label-primary" onclick="if(confirm('Tem certeza de que deseja excluir?')) protList('ciapList', <%= FormID %>, <%= CampoID %>, 'X-<%= pt("id") %>')"><%= pt("Tag") %></span>
    <%
    end if
    if not pc.eof then
        set cp = db.execute("select * from buicamposforms where id="& CampoID)
        %>
        <hr class="short alt" />
        <table class="table table-condensed">
            <tbody>
                <%
                while not pc.eof
                    %>
                    <tr>
                        <td><% if pc("CID10_Cd1")="Tag" then response.Write("<i style='cursor:pointer' class='far fa-star'></i> ") end if %> <%= pc("CID10_Cd1") %></td>
                        <td><%= pc("Termo") %></td>
                        <td><%= pc("bmj_link") %></td>

                        <%
                        if cp("NomeCampo")="internações" then %>
                            <td width="100"><%= quickfield("datepicker", "DataEntrada"&pc("id"), "Entrada", 12, pc("DataEntrada"), "", "", " onchange='saveProt(0)' ") %></td>
                            <td width="100"><%= quickfield("datepicker", "DataSaida"&pc("id"), "Saída", 12, pc("DataSaida"), "", "", " onchange='saveProt(0)' ") %></td>
                            <td width="300"><%= quickfield("text", "Hospital"& pc("id"), "Hospital", 12, pc("Hospital"), "", "", " onchange='saveProt(0)' ") %></td>
                        <%
                        end if
                        set adds = db.execute("select distinct Tipo from cliniccentral.buipressets")
                        while not adds.eof
                            if instr(Estruturacao, "|"& adds("Tipo") &"|")>0 then
                                %>
                                <td width="120"><%= quickfield("simpleSelect", adds("Tipo") & pc("id"), "&nbsp;", 12, pc("StatusID"), "select id, Descricao from cliniccentral.buipressets WHERE Tipo='"& adds("Tipo") &"'", "Descricao", " no-select2 semVazio onchange=""protList('ciapList', "& FormID &", "& CampoID &", 'U"& pc("id") &"_'+$(this).val())"" ") %></td>
                                <%
                            end if
                        adds.movenext
                        wend
                        adds.close
                        set adds = nothing
                            %>
                        <td width="150" class="info hidden"><%= quickfield("simpleSelect", "sta"&pc("id"), "", 12, pc("StatusID"), "select * from cliniccentral.cidstatus", "Descricao", " no-select2 semVazio onchange=""protList('ciapList', "& FormID &", "& CampoID &", 'U"& pc("id") &"_'+$(this).val())"" ") %></td>
                        <td width="1%"><button type="button" class="btn btn-danger mt25" onclick="if(confirm('Tem certeza de que deseja excluir?')) protList('ciapList', <%= FormID %>, <%= CampoID %>, 'X<%= pc("id") %>')"><i class="far fa-remove"></i></button></td>
                    </tr>
                    <%
                pc.movenext
                wend
                pc.close
                set pc = nothing
                %>
            </tbody>
        </table>
        <%
    end if
elseif Tipo="prescList" then
    if Comm<>"" then
        if left(Comm, 1)="X" then
            db.execute("update memed_prescricoes set sysActive=-1 where id="& replace(Comm, "X", ""))
        elseif left(Comm, 1)="U" then
            splU = split(replace(Comm, "U", ""), "_")
            db.execute("update memed_prescricoes set StatusID="& splU(1) &" WHERE id="& splU(0))
        end if
    end if
    set pc = db.execute("select pp.*, m.NomeMedicamento, m.DescricaoMedicamento, m.FabricanteMedicamento FROM memed_prescricoes pp LEFT JOIN cliniccentral.medicamentos2 m ON m.id=pp.MedicamentoID WHERE pp.sysActive=1 AND pp.FormID="& FormID &" AND pp.CampoID="& CampoID)
    if not pc.eof then
        %>
        <hr class="short alt" />
        <table class="table table-condensed">
            <tbody>
                <%
                while not pc.eof
                    Dose = pc("Dose")
                    Apresentacao = pc("Apresentacao")
                    Via = pc("Via")
                    Frequencia = pc("Frequencia")
                    Duracao = pc("Duracao")
                    TempoTratamento = pc("TempoTratamento")
                    TipoTempo = pc("TipoTempo")
                    PosologiaMedicamento = pc("PosologiaMedicamento")
                    %>
                    <tr>
                        <td width="1%"><input class="check-prescricao" type="checkbox" name="Chk<%= CampoID %>-<%= pc("id") %>" value="<%= pc("id") %>" /></td>
                        <td>
                            <div class="row">
                            <%= quickfield("text", "Medicamento"&pc("id"), "Medicamento", 5, pc("NomeMedicamento"), "", "", " disabled ") %>
                            <%= quickfield("text", "Dose"&pc("id"), "Dose", 2, Dose, "", "", " onchange='preencherPosologia("&pc("id")&")' ") %>
                            <%= quickfield("simpleSelect", "Apresentacao"& pc("id"), "Apresentação", 2, Apresentacao, "select * from cliniccentral.medicamentosunidades", "Descricao", " onchange='preencherPosologia("&pc("id")&")' semVazio ") %>
                            <%= quickfield("simpleSelect", "Via"&pc("id"), "Via de administração", 3, Via, "select * from cliniccentral.usosmedicamentos", "Uso", " onchange='saveProt(0);'  semVazio ") %>
                            </div>
                            <div class="row">
                            <%= quickfield("simpleSelect", "Frequencia"&pc("id"), "Frequencia", 2, Frequencia, "select * from cliniccentral.medicamentosfrequencia order by id", "Descricao", " onchange='preencherPosologia("&pc("id")&")'  semVazio ") %>
                            <%= quickfield("simpleSelect", "Duracao"&pc("id"), "Duração", 2, Duracao, "select * from cliniccentral.medicamentosduracao", "Descricao", " onchange='preencherPosologia("&pc("id")&")'  semVazio ") %>
                            <%= quickfield("text", "TempoTratamento"&pc("id"), "Período", 2, TempoTratamento, "", "", " onchange='preencherPosologia("&pc("id")&")'  autocomplete='off' ") %>
                            <%= quickfield("simpleSelect", "TipoTempo"& pc("id"), "&nbsp;", 2, TipoTempo, "select 'H' id, 'horas' Descricao UNION select 'D', 'dias' UNION select 'S', 'semanas' UNION SELECT 'm', 'mês' UNION select 'C', 'uso contínuo'", "Descricao", " onchange='preencherPosologia("&pc("id")&")'  semVazio ") %>
                            </div>
                            <div class="row">
                            <%= quickfield("text", "PosologiaMedicamento"&pc("id"), "Posologia", 12, PosologiaMedicamento, "", "", " onchange='saveProt(0);' ") %>
                            </div>

                        </td>



                        <td width="1" class="pt25 hidden"><%= quickfield("simpleSelect", "sta"&pc("id"), "", 12, pc("StatusID"), "select * from cliniccentral.prescricaostatus", "Descricao", " no-select2 semVazio onchange=""protList('prescList', "& FormID &", "& CampoID &", 'U"& pc("id") &"_'+$(this).val())"" ") %></td>
                        <td width="1%" class="pt25"><button type="button" class="btn btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir?')) protList('prescList', <%= FormID %>, <%= CampoID %>, 'X<%= pc("id") %>')"><i class="far fa-remove"></i></button></td>
                    </tr>
                    <%
                pc.movenext
                wend
                pc.close
                set pc = nothing
                %>
            </tbody>
        </table>
        <%
    end if
elseif Tipo="encList" then
    if Comm<>"" then
        if left(Comm, 1)="X" then
            db.execute("update protocolosencaminhamentos set sysActive=-1 where id="& replace(Comm, "X", ""))
        elseif left(Comm, 1)="U" then
            splU = split(replace(Comm, "U", ""), "_")
            db.execute("update protocolosencaminhamentos set EspecialidadeID="& splU(1) &" WHERE id="& splU(0))
        elseif left(Comm, 1)="P" then
            splU = split(replace(Comm, "P", ""), "_")
            if splU(1)<>0 then
                db.execute("update protocolosencaminhamentos set LicencaID="& splU(1) &", ProfissionalID="& splU(2) &" WHERE id="& splU(0))
            else
                db.execute("update protocolosencaminhamentos set LicencaID=0, ProfissionalID=0 WHERE id="& splU(0))
            end if
        end if
    end if
    set pc = db.execute("select en.* from protocolosencaminhamentos en WHERE en.sysActive=1 AND  en.FormID="& FormID &" AND en.CampoID="& CampoID)
    if not pc.eof then
        %>
        <hr class="short alt" />
        <table class="table table-condensed">
            <tbody>
                <%
                while not pc.eof
                    if pc("Tipo")="Especialista" then
                        sql = "select * from cliniccentral.especialidades_correcao where id NOT IN(167, 188, 192, 201, 168, 193) and not isnull(nomeEspecialidade) AND sysActive=1 order by nomeEspecialidade"
                    else
                        sql = "select * from cliniccentral.especialidades_correcao especialidades where id IN(167, 188, 192, 201, 168, 193) order by nomeEspecialidade"
                    end if
                    %>
                    <tr>
                        <td width="1%"><input class="check-encaminhamento" hidden type="checkbox" name="Chk<%= CampoID %>" value="<%= pc("id") %>" /></td>
                        <td id="encaminhamento-<%=pc("id")%>"><%= pc("Tipo") %></td>

                        <%if pc("Tipo")<>"Pronto-Socorro" then%>
                        <td width="200" class="pt25"><%= quickfield("simpleSelect", "sta"&pc("id"), "", 12, pc("EspecialidadeID"), sql, "nomeEspecialidade", " no-select2 semVazio onchange=""protList('encList', "& FormID &", "& CampoID &", 'U"& pc("id") &"_'+$(this).val())"" ") %></td>

                        <td width="200" class="pt25">
                            <%if pc("EspecialidadeID")&""<>0 then
                                sqlConteudo = getProfissionaisEspecialidades(pc("EspecialidadeID"))
                                ProfissionalID = pc("LicencaID") & "_" & pc("ProfissionalID")
                                call quickfield("simpleSelect", "sta"&pc("id"), "", 12, ProfissionalID, sqlConteudo, "NomeProfissional", " no-select2 onchange=""protList('encList', "& FormID &", "& CampoID &", 'P"& pc("id") &"_'+$(this).val())"" ")
                            end if%>
                        </td>
                        <%else%>
                        <td width="200" class="pt25"></td>
                        <td width="200" class="pt25"></td>
                        <%end if%>
                        <td width="1%" class="pt25"><button type="button" class="btn btn-info" onClick="printCampo('encaminhamento', '<%= CampoID %>', <%=pc("id")%>)"><i class="far fa-print"></i></button></td>
                        <td width="1%" class="pt25"><button type="button" class="btn btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir?')) protList('encList', <%= FormID %>, <%= CampoID %>, 'X<%= pc("id") %>')"><i class="far fa-remove"></i></button></td>
                    </tr>
                    <tr id="result<%= CampoID &"_"& pc("id") %>">
                        <td colspan="6">
                        <%= quickfield("memo", "Motivo"& pc("id"), "Motivo", 12, pc("Motivo"), "", "", " onchange='saveProt(0)'  ") %>
                        <%= quickfield("memo", "Obs"& pc("id"), "Observações", 12, pc("Obs"), "", "", " onchange='saveProt(0)'  ") %>
                        </td>
                    </tr>
                    <%
                pc.movenext
                wend
                pc.close
                set pc = nothing
                %>
            </tbody>
        </table>
        <%
    end if
elseif Tipo="pedList" then
    if Comm<>"" then
        if left(Comm, 1)="X" then
            db.execute("update protocolospedidos set sysActive=-1 where id="& replace(Comm, "X", ""))
        elseif left(Comm, 1)="U" then
            splU = split(replace(Comm, "U", ""), "_")
            db.execute("update protocolospedidos set StatusID="& splU(1) &" WHERE id="& splU(0))
        end if
    end if
    set pc = db.execute("select pp.*, m.codigo, m.descricao FROM protocolospedidos pp LEFT JOIN cliniccentral.tusscorrelacao m ON m.id=pp.PedidoID WHERE pp.sysActive=1 AND pp.FormID="& FormID &" AND pp.CampoID="& CampoID)
    if not pc.eof then
        %>
        <hr class="short alt" />
        <table class="table table-condensed">
            <tbody>
                <%
                while not pc.eof
                    Resultado = pc("Resultado")&""
                    %>
                    <tr>
                        <%if pc("GuiaID")&""<>"" then%>
                            <td width="1%">
                                <a href="./?P=tissguiasadt&Pers=1&I=<%=pc("GuiaID")%>" target="_blank" title="Abrir guia SADT" class="btn btn-default btn-xs m2"><i class="far fa-link"></i></a>
                                <button type="button" onClick="guiaTISS('GuiaSADT',<%=pc("GuiaID")%>)" title="Imprimir guia SADT" class="btn btn-info btn-xs m2"><i class="far fa-print"></i></button>
                            </td>
                        <%else%>
                            <td width="1%">
                                <a target="_blank" class="btn btn-default btn-xs m2 hidden" id="Guia<%= CampoID %>-<%= pc("id") %>"><i class="far fa-link"></i></a>
                                <button type="button" class="btn btn-info btn-xs m2 hidden" id="Print<%= CampoID %>-<%= pc("id") %>"><i class="far fa-print"></i></button>
                                <input class="check-pedido" type="checkbox" name="Chk<%= CampoID %>" id="Chk<%= CampoID %>-<%= pc("id") %>" value="<%= pc("id") %>" />
                            </td>
                        <%end if%>
                        <td><label for="Chk<%= CampoID %>-<%= pc("id") %>"><%= pc("descricao") %></label></td>
                        <td width="150" class="pt25"><%= quickfield("simpleSelect", "sta"&pc("id"), "", 12, pc("StatusID"), "select * from cliniccentral.pedidosstatus", "Descricao", " no-select2 semVazio onchange=""protList('pedList', "& FormID &", "& CampoID &", 'U"& pc("id") &"_'+$(this).val())"" ") %></td>
                        <td width="1%" class="pt25"><button type="button" class="btn btn-info"  title="Resultado" onclick="$(this).fadeOut(); $('#result<%= CampoID &"_"& pc("id") %>').fadeIn()"><i class="far fa-list"></i></button></td>
                        <td width="1%" class="pt25 hidden"><button type="button" class="btn btn-info" onclick=""><i class="far fa-paperclip"></i></button></td>
                        <td width="1%" class="pt25"><button type="button" id="Delete<%= CampoID %>-<%= pc("id") %>" <%if pc("GuiaID")&""<>"" then%> disabled <%end if%> class="btn btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir?')) protList('pedList', <%= FormID %>, <%= CampoID %>, 'X<%= pc("id") %>')"><i class="far fa-remove"></i></button></td>
                    </tr>
                    <tr <% if Resultado="" then response.write(" style=""display:none"" ") end if %> id="result<%= CampoID &"_"& pc("id") %>">
                        <td colspan="6">
                        <%= quickfield("memo", "Resultado"& pc("id"), "Resultado", 12, Resultado, "", "", " onchange='saveProt()' ") %>
                        </td>
                    </tr>
                    <%
                pc.movenext
                wend
                pc.close
                set pc = nothing
                %>
            </tbody>
        </table>
        <%
    end if
elseif Tipo="atesList" then
    if Comm<>"" then
        if left(Comm, 1)="X" then
            db.execute("update pacientesatestados set sysActive=-1 where id="& replace(Comm, "X", ""))
        end if
    end if
    set pa = db.execute("select pa.*, pat.NomeAtestado FROM pacientesatestados pa LEFT JOIN pacientesatestadostextos pat ON pat.id=pa.AtestadoID WHERE pa.sysActive=1 AND pa.FormID="& FormID &" AND pa.PacienteID = "&PacienteID&" AND pa.CampoID="& CampoID)
    if not pa.eof then
        %>
        <hr class="short alt" />
        <table class="table table-condensed">
            <tbody>
                <%
                while not pa.eof
                    %>
                    <tr>
                        <td width="1%">
                        </td>
                        <td><label><%= pa("NomeAtestado") %></label></td>
                        <td width="1%" class="pt25"><button type="button" class="btn btn-success" onclick="editPront('atestado', <%=pa("id")%>, <%=PacienteID%>)"><i class="far fa-edit"></i></button></td>
                        <td width="1%" class="pt25"><button type="button" class="btn btn-info" id="Print<%= CampoID %>-<%= pa("id") %>" onclick="printCampo('atestado', <%= CampoID %>, <%=pa("id")%>)"><i class="far fa-print"></i></button></td>
                        <td width="1%" class="pt25"><button type="button" class="btn btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir?')) protList('atesList', <%= FormID %>, <%= CampoID %>, 'X<%= pa("id") %>')"><i class="far fa-remove"></i></button></td>
                    </tr>

                    <%
                pa.movenext
                wend
                pa.close
                set pa = nothing
                %>
            </tbody>
        </table>
        <%
    end if
end if
%>