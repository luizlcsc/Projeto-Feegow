<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->

<style type="text/css">
@media print {
    body * {
        font-size:9px;
    }
}
</style>
<%
response.Buffer

if req("Dup")<>"" then
    db.execute("insert into rateiodominios (nomeDominio, Tipo, Procedimentos, Profissionais, Formas, GruposProfissionais, Tabelas, Unidades, Dias, Horas, UsarValorNoProcedimento, dominioSuperior, sysUser, sysActive) select nomeDominio, Tipo, Procedimentos, Profissionais, Formas, GruposProfissionais, Tabelas, Unidades, Dias, Horas, UsarValorNoProcedimento, dominioSuperior, "& session("User") &", sysActive from rateiodominios where id="& req("Dup"))
    set pult = db.execute("select id from rateiodominios order by id desc limit 1")
    db.execute("insert into rateiofuncoes (Funcao, DominioID, tipoValor, Valor, ContaPadrao, modoCalculo, sysUser, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysActive, Variavel, ValorVariavel) select Funcao, "& pult("id") &", tipoValor, Valor, ContaPadrao, modoCalculo, "& session("User") &", Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysActive, Variavel, ValorVariavel from rateiofuncoes where DominioID="& req("Dup"))
    response.Redirect("./?P=RepasseLinear&Pers=1")
end if
%>

<form id="frmRL">
    <%
    if ref("Convenios")<>"" then
        sfConvenios = " AND Formas LIKE '%|"& ref("Convenios") &"|%' "
    end if
    if ref("TabelasParticulares")<>"" then
        sfTabelasParticulares = " AND Tabelas LIKE '%|"& ref("TabelasParticulares") &"|%' "
    end if
    if ref("Especialidades")<>"" then
        sfEspecialidades = " AND Profissionais LIKE '%|"& ref("Especialidades") &"|%' "
    end if
    if ref("Profissionais")<>"" then
        sfProfissionais = " AND Profissionais LIKE '%|"& ref("Profissionais") &"|%' "
    end if
    if ref("ProfissionaisGrupos")<>"" then
        sfProfissionaisGrupos = " AND GruposProfissionais LIKE '%|"& ref("ProfissionaisGrupos") &"|%' "
    end if
    if ref("ProcedimentosGrupos")<>"" then
        sfProcedimentosGrupos = " AND Procedimentos LIKE '%|"& ref("ProcedimentosGrupos") &"|%' "
    end if
    if ref("Procedimentos")<>"" then
        sfProcedimentos = " AND Procedimentos LIKE '%|"& ref("Procedimentos") &"|%' "
    end if
    if ref("Unidades")<>"" then
        sfUnidades = " AND Unidades LIKE '%|"& ref("Unidades") &"|%' "
    end if

    sqlDom = "select '0' id, '' nomeDominio, '' Tipo, '' Procedimentos, '' Profissionais, '' Formas, '' GruposProfissionais, '' Tabelas, '' Unidades, '' Dias, '' Horas  UNION ALL SELECT id, nomeDominio, Tipo, Procedimentos, Profissionais, Formas, GruposProfissionais, Tabelas, Unidades, Dias, Horas from rateiodominios WHERE 1 "& sfConvenios & sfTabelasParticulares & sfEspecialidades & sfProfissionais & sfProfissionaisGrupos & sfProcedimentosGrupos & sfProcedimentos & sfUnidades &" ORDER BY CAST(id AS UNSIGNED)"
    'dd( sqlDom )
    set dom = db.execute( sqlDom )
    while not dom.eof
        response.flush()
        Formas = dom("Formas")&""
        strFormas = ""
        'if instr(Formas, "|P|") then
            'strFormas = "PARTICULAR"
            'Formas = replace(Formas, "|P|", "|0|")
        'end if
        Formas = replace(Formas, "|", "")
        Convenios = ""

        if Formas&""<>"" then
            if instr(Formas, "P")<=0 then
                Formas = replace(Formas, "C", "0")
                sql= "select group_concat(trim(NomeConvenio) separator ', ') convenios from convenios where id in("& fix_array_comma(Formas) &") and sysActive=1"
                set sqlFormas = db.execute(sql)
                Convenios = sqlFormas("convenios") &""
            else
                strFormas = strFormas& "PARTICULAR"
            end if
            if Convenios<>"" and strFormas<>"" then
                strFormas = strFormas &", "
            end if
        end if
        strFormas = strFormas & Convenios

        Profissionais = replace(dom("Profissionais")&"", "|", "")
        strEspecialidades = ""
        strProfissionais = ""

        if Profissionais<>"" then
            Profissionais = replace(Profissionais, "ESP","")
            Profissionais = replace(Profissionais&"","8_" , "")

            set sqlEsps = db.execute("select group_concat(Especialidade separator ', ') especialidades from especialidades where sysActive=1 and id*(-1) in("& Profissionais &")")
            strEspecialidades = sqlEsps("Especialidades") '& "("& Profissionais &")"

            set sqlProfs = db.execute("select group_concat(NomeProfissional separator ', ') profissionais from profissionais where sysActive=1 and ativo='on' and id in("& Profissionais &")")
            strProfissionais = sqlProfs("Profissionais")
        end if

        GruposProfissionais = replace(dom("GruposProfissionais")&"", "|", "")
        strProfissionaisGrupos = ""

        if GruposProfissionais<>"" then
            set sqlProfsGrup = db.execute("select group_concat(NomeGrupo separator ', ') profissionaisgrupos from profissionaisgrupos where sysActive=1 and id in("& GruposProfissionais &")")
            strProfissionaisGrupos = sqlProfsGrup("ProfissionaisGrupos")
        end if

        Procedimentos = replace(dom("Procedimentos")&"", "|", "")
        strProcedimentos = ""
        strProcedimentosGrupos = ""
        if Procedimentos<>"" then
            Procedimentos =  replace(replace(Procedimentos&"@", ",@", ""), "@", "")
            if Procedimentos&""="" then
                Procedimentos="0"
            end if

            Procedimentos = fix_array_comma(Procedimentos)

            set sqlProcs = db.execute("select group_concat(NomeProcedimento separator ', ') procedimentos from procedimentos where sysActive=1 and ativo='on' and id in("& Procedimentos &") order by NomeProcedimento")
            strProcedimentos = sqlProcs("Procedimentos")
            set sqlGrupos = db.execute("select group_concat(NomeGrupo separator ', ') procedimentosgrupos from procedimentosgrupos where sysActive=1 and id*(-1) in("& Procedimentos &") order by NomeGrupo")
            strProcedimentosGrupos = sqlGrupos("ProcedimentosGrupos")
        end if

        strUnidades = ""
        Unidades = dom("Unidades")&""
        if Unidades<>"" then
            Unidades = replace(Unidades, "|", "")
            set sqlu = db.execute("select group_concat(t.NomeFantasia separator ', ') Unidades from (select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits where sysActive=1) t where t.id in("& Unidades &")")
            strUnidades = sqlu("Unidades")
        end if

        Tabelas = replace(dom("Tabelas")&"", "|", "")
        strTabelas = ""
        if Tabelas<>"" then
            set sqltab = db.execute("select group_concat(NomeTabela separator ', ') Tabelas from tabelaparticular where ativo='on' and id in("&Tabelas&")")
            if not sqlTab.eof then
                strTabelas = sqlTab("Tabelas")
            end if
        end if

        DominioID = dom("id")
        %>
        <div class="panel mb5">
            <div class="panel-heading">
                <span class="panel-title">
                    <span class="label label-success"><%= "REGRA #"& DominioID %></span>
                    <% if DominioID>0 then %>
                        <span class="panel-controls hidden-print">

                            <button onclick="editDom(<%= dom("id") %>)" type="button" class="btn btn-success btn-sm"><i class="far fa-edit"></i></button>

                            <button onclick="if(confirm('Tem certeza de que deseja duplicar esta regra?'))location.href='./?P=RepasseLinear&Pers=1&Dup=<%= dom("id") %>'" type="button" class="btn btn-alert btn-sm"><i class="far fa-paste"></i></button>

                            <button onclick="if(confirm('Tem certeza de que deseja apagar esta regra?'))location.href='./?P=RepasseLinear&Pers=1&X=<%= dom("id") %>'" type="button" class="btn btn-danger btn-sm"><i class="far fa-remove"></i></button>

                        </span>
                    <% end if %>
                </span>
            </div>
            <div class="panel-body">
                <%
                if DominioID=0 then
                    rw("<em>Esta é a regra principal. Todos os itens que não se encaixarem em alguma das regras criadas serão adicionados a esta regra.</em>")
                end if


                if strFormas<>"" then
                    rw("<b>CONVÊNIO / PARTICULAR</b>")
                    rw( strFormas &"<br>")
                end if
                if strTabelas<>"" then
                    rw("<b>TABELAS</b>")
                    rw( strTabelas &"<br>")
                end if
                if strEspecialidades<>"" then
                    rw("<b>ESPECIALIDADES</b>")
                    rw( strEspecialidades &"<br>")
                end if
                if strProfissionaisGrupos<>"" then
                    rw("<b>GRUPOS DE PROFISSIONAIS</b>")
                    rw( strProfissionaisGrupos &"<br>")
                end if
                if strProfissionais<>"" then
                    rw("<b>PROFISSIONAIS</b>")
                    rw( strProfissionais &"<br>")
                end if
                if strProcedimentosGrupos<>"" then
                    rw("<b>GRUPOS DE PROCEDIMENTOS</b>")
                    rw( strProcedimentosGrupos &"<br>")
                end if
                if strProcedimentos<>"" then
                    rw("<b>PROCEDIMENTOS</b>")
                    rw( strProcedimentos &"<br>")
                end if
                if strUnidades<>"" then
                    rw("<b>UNIDADES</b>")
                    rw( strUnidades &"<br>")
                end if
                %>
            </div>
            <div class="panel-footer">
                <b>Funções para Repasse:<br></b>
                <button type="button" onclick="valFun(<%= DominioID %>); $('#save').click()" class="btn btn-xs btn-info">
                    <%
                    set f = db.execute("select * from rateiofuncoes where not isnull(Valor) and DominioID="& DominioID &" order by Sobre")

                    if f.eof then
                        response.Write("Sem valor")
                    end if

                    while not f.eof
                        tipoValor = f("tipoValor")
                        Valor = f("Valor")
                        if tipoValor="P" then
                            RS = ""
                            Perc = "%"
                        elseif tipoValor="V" then
                            RS = "R$ "
                            Perc = ""
                        elseif tipoValor="E" then
                            RS = ""
                            Perc = "% (custo)"
                        elseif tipoValor="S" then
                            RS = ""
                            Perc = "% (venda)"
                        end if
                        Funcao = f("Funcao")
                        %>
                        <%= Funcao &": "& RS & fn(Valor) & Perc %> <br />
                        <%
                    f.movenext
                    wend
                    f.close
                    set f = nothing
                        %>
                </button>

            </div>
        </div>
        <%
    dom.movenext
    wend
    dom.close
    set dom = nothing
    %>

    <div class="panel mt20">
        <div class="panel-heading">
            <span class="panel-title">Descontos adicionais no repasse de acordo com a forma de recebimento</span>
            <span class="panel-controls">
                <button type="button" onclick="repasseDesconto(0)" class="btn-sm btn btn-primary">
                    <i class="far fa-plus"></i> Adicionar
                </button>
            </span>
        </div>
        <div class="panel-body" id="">
            <div class="row">
                <div class="col-xs-12" id="repassesDescontos">
                    <%=server.Execute("repassesDescontos.asp")%>
                </div>
            </div>
        </div>
    </div>
</form>
