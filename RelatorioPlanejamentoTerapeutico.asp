<!--#include file="connect.asp"-->
<%
'este arquivo atualmente está mockado para o cliente FollowKids - #14486
I = req("I")
set pac = db.execute("SELECT pac.*, conv.NomeConvenio, s.NomeSexo FROM pacientes pac "&_ 
    " LEFT JOIN convenios conv ON conv.id=pac.ConvenioID1 "&_ 
    " LEFT JOIN sexo s ON s.id=pac.Sexo "&_ 
    " WHERE pac.id="& I)

set ConfigSQL = db.execute("SELECT * FROM sys_config WHERE id=1")

if not ConfigSQL.eof then
    Logo = ConfigSQL("Logo")
end if

set form = db.execute("SELECT DATE(DataHora) Data FROM buiformspreenchidos WHERE PacienteID="& I &" AND sysActive=1 ORDER BY id")

set timb = db.execute("select * from papeltimbrado where NomeModelo='Planejamento Terapêutico' AND sysActive=1")

if not timb.eof then
    'Cabecalhounscape = timb("Cabecalho")
    Margens = "margin-left:"&timb("mLeft")&"px;margin-top:"&timb("mTop")&"px;margin-bottom:"&timb("mBottom")&"px;margin-right:"&timb("mRight")&"px;"
    
    Rodape = replaceTags(timb("Rodape"), 0, session("UserID"), session("UnidadeID"))
    Rodape = unscapeOutput(Rodape)
end if

%>
<div class="row">
    <div class="col-xs-6"><img src="<%=Logo%>" height="125"></div>
    <div class="col-xs-6 text-right"><img src="https://functions.feegow.com/load-image?licenseId=14486&folder=Perfil&file=<%= pac("Foto") %>" height="125"></div>
</div>
<div class="row">
    <div class="col-md-12 pt20">
        <table class="table table-bordered">
            <tr class="warning">
                <th colspan="4" class="text-center">RELATÓRIO DE AVALIAÇÃO E PLANEJAMENTO TERAPÊUTICO</th>
            </tr>
            <tr>
                <th>Plano</th>
                <td><%= pac("NomeConvenio") %></td>
                <th>1a. Avaliação</th>
                <td><%= form("Data") %></td>
            </tr>
            <tr>
                <th>Paciente</th>
                <td colspan="3"><%= pac("NomePaciente") %></td>
            </tr>
            <tr>
                <th>Data Nasc.</th>
                <td><%= pac("Nascimento") %></td>
                <th>Gênero</th>
                <td><%= pac("NomeSexo") %></td>
            </tr>
            <tr>
                <th>Endereço</th>
                <td colspan="3"><%= pac("Endereco") &", "& pac("Numero") &" - "& pac("Complemento") %></td>
            </tr>
            <tr>
                <th>Bairro/Cidade/Estado</th>
                <td><%= pac("Bairro") &" - "& pac("Cidade") &" - "& pac("Estado") %></td>
                <th>CEP</th>
                <td><%= pac("Cep") %></td>
            </tr>
            <tr>
                <td colspan="4" class="pn"><hr class="short alt"></td>
            </tr>
            <%
            set rels = db.execute("SELECT * FROM pacientesrelativos WHERE sysActive=1 AND PacienteID="& I)
            while not rels.eof
            %>
            <tr>
                <th>Nome do Responsável</th>
                <td><%= rels("Nome") %></td>
                <th>Profissão</th>
                <td><%= rels("Profissao") %></td>
            </tr>
            <tr>
                <th>E-mail</th>
                <td><%= rels("Email") %></td>
                <th>Fone</th>
                <td><%= rels("Telefone") %></td>
            </tr>
            <%
            rels.movenext
            wend
            rels.close
            set rels = nothing
            %>
            <tr class="warning">
                <th class="text-center" colspan="4">INFORMAÇÕES CLÍNICAS</th>
            </tr>
            <%
            set prim = db.execute("SELECT f.* FROM _31 f INNER JOIN buiformspreenchidos fp ON fp.id=f.id WHERE f.PacienteID="& I &" AND fp.sysActive=1 LIMIT 1")
            if not prim.eof then
                set cf = db.execute("SELECT * FROM buicamposforms WHERE FormID=31 AND TipoCampoID NOT IN(10) ORDER BY Ordem")
                while not cf.eof
                %>
                <tr>
                    <td colspan="4">
                        <b><%= cf("RotuloCampo") %>:</b>
                        <%= prim(""& cf("id") &"") %>
                    </td>
                </tr>
                <%
                cf.movenext
                wend
                cf.close
                set cf = nothing
            end if
            %>
            <tr>
                <td colspan="4">
                    <b>Data da Impressão:</b>
                    <%= date() %>
                </td>
            </tr>
        </table>
    </div>
</div>
<%=Rodape%>