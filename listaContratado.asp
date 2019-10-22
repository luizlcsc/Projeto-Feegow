<!--#include file="connect.asp"-->
<%
GuiaID = req("I")
if GuiaID<>"" and isnumeric(GuiaID) then
    've se a guia tem convenio id, se tem, lista os contratados desse convenio e cria variavel do contratadoid
    'se a guia nao eh sysActive verifica se o req AeA pega o convenioid, buscando a funcao q pega os contratados desse convenio
    tabela = req("P")
    set g = db.execute("select * from "&tabela&" where id="&GuiaID)
    if not g.eof then
        if g("sysActive")=0 then
            nega = ""
            autoriza = ""
            UnidadeID = session("UnidadeID")
        else
            Contratado = g("Contratado")
            ConvenioID = g("ConvenioID")
            UnidadeID = g("UnidadeID")
        end if
    end if
else
    'passa nesse caso manualmente o ConvenioID e a Unidade, gerando a lista nesses 2 parâmetros
    ConvenioID = req("ConvenioID")
    UnidadeID = req("UnidadeID")
    ProfissionalID = req("ProfissionalID")
end if

if isnumeric(ConvenioID) and not isnull(ConvenioID) and ConvenioID<>"" then
    set conv = db.execute("select * from convenios where id="&ConvenioID)
    if not conv.eof then
        if conv("ContratadosPreCadastrados")=1 and not isnull(conv("ContratadosPreCadastrados")) then
            set cont = db.execute("select group_concat(concat('|', Contratado, '|')) Somente from contratosconvenio where ConvenioID="&ConvenioID&" and (isnull(SomenteUnidades) or SomenteUnidades like '' or SomenteUnidades like '%|"&UnidadeID&"|%')")
           ' response.Write("select group_concat(concat('|', Contratado, '|')) Somente from contratosconvenio where ConvenioID="&ConvenioID&" and (isnull(SomenteUnidades) or SomenteUnidades like '' or SomenteUnidades like '%|"&UnidadeID&"|%')")
            ExibeSomente = 1
            SomenteEstesContratados = cont("Somente")
        end if
    end if
end if

if GuiaID<>"" then
    response.write("<label>Nome do Contratado</label><br />")
    response.write("<select class=""form-control"" name=""Contratado"" id=""Contratado"">")
end if
%>
<option value="FALSE">Selecione</option>
<%
    set conts = db.execute("(select '0' id, NomeFantasia Nome from empresa where not isnull(NomeEmpresa)) UNION ALL (select id*(-1), NomeFantasia from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 order by UnitName) UNION ALL (select id, NomeProfissional from profissionais where sysActive=1 and ativo='on' order by NomeProfissional)")
    while not conts.eof
        if (ExibeSomente=1 and instr(SomenteEstesContratados, "|"&conts("id")&"|")) or ExibeSomente="" then 'colocar |
            if Primeiro="" then
                Primeiro = conts("id")
            end if
            %>
            <option value="<%=conts("id") %>" <%if cstr(conts("id"))=cstr(Contratado&"") then %> selected <%end if%> ><%=conts("Nome") %></option>
            <%
        end if
    conts.movenext
    wend
    conts.close
    set conts=nothing
if GuiaID<>"" then
    response.write("</select>")
end if
%>