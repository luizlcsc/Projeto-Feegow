<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
DominioID = req("D")
set dom = db.execute("select * from rateiodominios where id="& DominioID)
Profissionais = dom("Profissionais")
GruposProfissionais = dom("GruposProfissionais")
Procedimentos = dom("Procedimentos")
Formas = dom("Formas")
Unidades = dom("Unidades")
Tabelas = dom("Tabelas")
Dias = dom("Dias")
%>

<div class="panel-heading">
    EDIÇÃO DE DOMÍNIO DE REPASSE
</div>
<form id="frmDom">
    <div class="panel-body">
        <div class="row">
            <div class="col-md-12">
                <%

                corBtn = "btn-default"
                if Formas<>"" then
                    corBtn = "btn-info"
                end if

                %>
                <button class="btn btn-block <%=corBtn%> text-left" type="button" onclick="$('#divConPart').slideToggle()"><i class="far fa-chevron-down"></i> Convênios</button>
            </div>
        </div>
        <div class="row pt10" id="divConPart" style="display:none">
            <%
            sqlConv = "select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio"
        
            set g = db.execute( sqlConv )
                while not g.eof
                    %>
                    <div class="col-md-4 checkbox-custom checkbox-primary">
                        <input name="Formas" value="<%= "|"& g("id") &"|" %>" id="conv<%= g("id") %>" type="checkbox" <% if instr(Formas, "|"&g("id")&"|")>0 then response.write(" checked ") end if %> /><label for="conv<%= g("id") %>"> <%= g("NomeConvenio") %></label>
                    </div>
                    <%
                g.movenext
                wend
                g.close
                set g = nothing
            %>
        </div>
        <hr class="short alt" />

        <div class="row">
            <div class="col-md-12">
                <%
                corBtn = "btn-default"
                if Formas<>"" then
                    if instr(Formas, "_") > 0 or instr(Formas,"|P|")>0 then
                        corBtn = "btn-info"
                    end if
                end if

                %>

                <button class="btn btn-block <%=corBtn%> text-left" type="button" onclick="$('#divFormaPart').slideToggle()"><i class="far fa-chevron-down"></i> Formas de pagamento</button>
            </div>
        </div>
        <div class="row pt10" id="divFormaPart" style="display:none">

            <div class="col-md-12">
                <div class="checkbox-custom checkbox-primary"><input type="checkbox" name="Formas" id="FormaParticular" value="|P|"<% If instr(Formas, "|P|")>0 Then %> checked="checked"<% End If %> /><label for="FormaParticular"> Todas as formas no particular</label></div>
            </div>
            <div class="col-md-12 pt10">
                <label>Ou somente as formas abaixo</label><br />
            </div>
                <%
                set forma = db.execute("select f.*, m.PaymentMethod from sys_formasrecto f left join sys_financialpaymentmethod m on m.id=f.MetodoID order by PaymentMethod")
                while not forma.eof
                    if forma("MetodoID")=1 OR forma("MetodoID")=2 OR forma("MetodoID")=7 then
                        %>
                        <div class="col-md-4 checkbox-custom checkbox-primary">
                            <input name="Formas" value="|P<%=forma("id")%>_0|" id="part<%= forma("id") %>" type="checkbox" <%if instr(Formas, "|P"&forma("id")&"_0|")>0 then%> checked<%end if%> /><label for="part<%= forma("id") %>"><%=forma("PaymentMethod")%>: De <%=forma("ParcelasDe")%> a <%=forma("ParcelasAte")%> parcelas</label>
                        </div>

                        <%
                    else
                        spl = split(forma("Contas"), ", ")
                        for i=0 to ubound(spl)
                            if spl(i)<>"" then
                                conta = replace(spl(i), "|", "")
                                if isnumeric(conta) then
                                    set contas = db.execute("select * from sys_financialcurrentaccounts where id="&conta)
                                    if not contas.eof then
                                        %>
                                        <div class="col-md-4 checkbox-custom checkbox-primary">
                                            <input name="Formas" value="|P<%=forma("id")%>_<%=contas("id")%>|" id="part<%=forma("id")%>_<%=contas("id")%>" type="checkbox" <%if instr(Formas, "|P"&forma("id")&"_"&contas("id")&"|")>0 then%> checked<%end if%> /><label for="part<%=forma("id")%>_<%=contas("id")%>"><%=forma("PaymentMethod")%> - <%=contas("AccountName")%>: De <%=forma("ParcelasDe")%> a <%=forma("ParcelasAte")%> parcelas</label>
                                        </div>
                                        <%
                                    end if
                                end if
                            end if
                        next
                    end if
                forma.movenext
                wend
                forma.close
                set forma=nothing
                %>
        </div>
        <hr class="short alt" />




        <div class="row">
            <div class="col-md-12">
                <%

                corBtn = "btn-default"
                if Tabelas<>"" then
                    corBtn = "btn-info"
                end if

                sqlConv = "select id, NomeTabela from tabelaparticular where sysActive=1 and ativo='on' order by NomeTabela"

                set g = db.execute( sqlConv )


                disabledTabela = ""
                if g.eof then
                    disabledTabela = "disabled "
                end if
                %>

                <button <%=disabledTabela%> class="btn btn-block <%=corBtn%> text-left" type="button" onclick="$('#divTabs').slideToggle()"><i class="far fa-chevron-down"></i> Tabelas Particulares</button>
            </div>
        </div>
        <div class="row pt10" id="divTabs" style="display:none">
            <%
                while not g.eof
                    %>
                    <div class="col-md-4 checkbox-custom checkbox-primary">
                        <input name="Tabelas" value="<%= "|"& g("id") &"|" %>" id="tab<%= g("id") %>" type="checkbox" <% if instr(Tabelas, "|"&g("id")&"|")>0 then response.write(" checked ") end if %> /><label for="tab<%= g("id") %>"> <%= g("NomeTabela") %></label>
                    </div>
                    <%
                g.movenext
                wend
                g.close
                set g = nothing
            %>
        </div>
        <hr class="short alt" />





        <div class="row">
            <div class="col-md-12">
                <%

                corBtn = "btn-default"
                if Profissionais<>"" then
                    if instr(Profissionais, "-") > 0 then
                        corBtn = "btn-info"
                    end if
                end if

                %>

                <button class="btn btn-block btn-default text-left" type="button" onclick="$('#divEsp').slideToggle()"><i class="far fa-chevron-down"></i> Especialidades</button>
            </div>
        </div>
            <div class="row pt10" id="divEsp" style="display:none">
                <% 


                set espprofs = db.execute("select group_concat(distinct EspecialidadeID) esps1 from profissionais where ativo='on' and not isnull(EspecialidadeID)")
                Especialidades1 = espprofs("esps1")&""
                if Especialidades1<>"" then
                    Especialidades1 = " or id in("& Especialidades1 &")"
                end if
                set espprofs2 = db.execute("select group_concat(distinct EspecialidadeID) esps2 from profissionaisespecialidades where not isnull(EspecialidadeID)")
                Especialidades2 = espprofs2("esps2")&""
                if Especialidades2<>"" then
                    Especialidades2 = " or id in("& Especialidades2 &")"
                end if

                sqlEsp = "select id*(-1) id, Especialidade from especialidades where 0 "& Especialidades1 & Especialidades2 &" and sysActive=1 order by especialidade"
        
                set esp = db.execute( sqlEsp )
                    while not esp.eof
                        %>
                        <div class="col-md-4 checkbox-custom checkbox-primary">
                            <input name="Profissionais" value="<%= "|"& esp("id") &"|" %>" id="esp<%= esp("id") %>" type="checkbox" <% if instr(Profissionais, "|"&esp("id")&"|")>0 then response.write(" checked ") end if %> /><label for="esp<%= esp("id") %>"> <%= esp("especialidade") %></label>
                        </div>
                        <%
                    esp.movenext
                    wend
                    esp.close
                    set esp = nothing
                    %>
            </div>
            <hr class="short alt" />
        <div class="row">
            <div class="col-md-12">
                <%

                corBtn = "btn-default"
                if Profissionais<>"" then
                    corBtn = "btn-info"
                end if

                %>

                <button class="btn btn-block <%=corBtn%> text-left" type="button" onclick="$('#divProf').slideToggle()"><i class="far fa-chevron-down"></i> Profissionais</button>
            </div>
        </div>
            <div class="row pt10" id="divProf" style="display:none">
                <%
                sqlProf = "select id, NomeProfissional from profissionais where ativo='on' and sysActive=1 order by NomeProfissional"
        
                set p = db.execute( sqlProf )
                    while not p.eof
                        %>
                        <div class="col-md-4 checkbox-custom checkbox-primary">
                            <input name="Profissionais" value="<%= "|"& p("id") &"|" %>" id="pro<%= p("id") %>" type="checkbox" <% if instr(Profissionais, "|"&p("id")&"|")>0 then response.write(" checked ") end if %> /><label for="pro<%= p("id") %>"> <%= p("NomeProfissional") %></label>
                        </div>
                        <%
                    p.movenext
                    wend
                    p.close
                    set p = nothing
                %>
            </div>
          <hr class="short alt" />
            <div class="row">
                <div class="col-md-12">
                    <%

                    corBtn = "btn-default"
                    if GruposProfissionais<>"" then
                        corBtn = "btn-info"
                    end if

                    sqlGru = "select id, NomeGrupo from profissionaisgrupos where sysActive=1 order by NomeGrupo"

                    set g = db.execute( sqlGru )

                    disabledGrupo = ""
                    if g.eof then
                        disabledGrupo = "disabled "
                    end if
                    %>

                    <button <%=disabledGrupo%> class="btn btn-block <%=corBtn%> text-left" type="button" onclick="$('#divGProf').slideToggle()"><i class="far fa-chevron-down"></i> Grupos de Profissionais</button>
                </div>
            </div>
                <div class="row pt10" id="divGProf" style="display:none">
                    <%
                        while not g.eof
                            %>
                            <div class="col-md-4 checkbox-custom checkbox-primary">
                                <input name="GruposProfissionais" value="<%= "|"& g("id") &"|" %>" id="gru<%= g("id") %>" type="checkbox" <% if instr(GruposProfissionais, "|"&g("id")&"|")>0 then response.write(" checked ") end if %> />
                                <label for="gru<%= g("id") %>"> <%= g("NomeGrupo") %></label>
                            </div>
                            <%
                        g.movenext
                        wend
                        g.close
                        set g = nothing
                    %>
                </div>
            <hr class="short alt" />
        <div class="row">
            <div class="col-md-12">

                <%

                corBtn = "btn-default"
                if Procedimentos<>"" then
                    if instr(Procedimentos, "-")>0 then
                        corBtn = "btn-info"
                    end if
                end if

                sqlGru = "select id*(-1) id, NomeGrupo from procedimentosgrupos where sysActive=1 order by NomeGrupo"

                set g = db.execute( sqlGru )


                disabledGrupo = ""
                if g.eof then
                    disabledGrupo = "disabled "
                end if
                %>
                <button class="btn btn-block btn-default text-left" type="button" onclick="$('#divGProc').slideToggle()"><i class="far fa-chevron-down"></i> Grupos de Procedimentos</button>
            </div>
        </div>
            <div class="row pt10" id="divGProc" style="display:none">
                <%
                    while not g.eof
                        %>
                        <div class="col-md-4 checkbox-custom checkbox-primary">
                            <input name="Procedimentos" value="<%= "|"& g("id") &"|" %>" id="gru<%= g("id") %>" type="checkbox" <% if instr(Procedimentos, "|"&g("id")&"|")>0 then response.write(" checked ") end if %> /><label for="gru<%= g("id") %>"> <%= g("NomeGrupo") %></label>
                        </div>
                        <%
                    g.movenext
                    wend
                    g.close
                    set g = nothing
                %>
            </div>
            <hr class="short alt" />
            <%

            corBtn = "btn-default"
            if Procedimentos<>"" then
                corBtn = "btn-info"
            end if

            %>
        <div class="row">
            <div class="col-md-12">
                <button class="btn btn-block <%=corBtn%> text-left" type="button" onclick="$('#divProcs').slideToggle()"><i class="far fa-chevron-down"></i> Procedimentos</button>
            </div>
        </div>

            <div class="row pt10" id="divProcs" style="display:none">
                <%
                sqlPro = "select id, NomeProcedimento from procedimentos where sysActive=1 and ativo='on' order by NomeProcedimento"
        
                set g = db.execute( sqlPro )
                    while not g.eof
                        %>
                        <div class="col-md-4 checkbox-custom checkbox-primary">
                            <input name="Procedimentos" value="<%= "|"& g("id") &"|" %>" id="proc<%= g("id") %>" type="checkbox" <% if instr(Procedimentos, "|"&g("id")&"|")>0 then response.write(" checked ") end if %> /><label for="proc<%= g("id") %>"> <%= g("NomeProcedimento") %></label>
                        </div>
                        <%
                    g.movenext
                    wend
                    g.close
                    set g = nothing
                %>
            </div>

            <hr class="short alt" />
        <div class="row">
            <div class="col-md-12">
                <%

                corBtn = "btn-default"
                if Unidades<>"" then
                    corBtn = "btn-info"
                end if

                %>
                <button class="btn btn-block <%=corBtn%> text-left" type="button" onclick="$('#divUnis').slideToggle()"><i class="far fa-chevron-down"></i> Unidades</button>
            </div>
        </div>
            <div class="row pt10" id="divUnis" style="display:none">
                <%
                sqlConv = "select '0' id, concat('        ', NomeFantasia) NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits where sysActive=1 order by NomeFantasia"


                set g = db.execute( sqlConv )
                    while not g.eof
                        %>
                        <div class="col-md-4 checkbox-custom checkbox-primary">
                            <input name="Unidades" value="<%= "|"& g("id") &"|" %>" id="u<%= g("id") %>" type="checkbox" <% if instr(Unidades, "|"&g("id")&"|")>0 then response.write(" checked ") end if %> /><label for="u<%= g("id") %>"> <%= g("NomeFantasia") %></label>
                        </div>
                        <%
                    g.movenext
                    wend
                    g.close
                    set g = nothing
                %>
            </div>
            <hr class="short alt" />







                <div class="row">
            <div class="col-md-12">
            <%
            corBtn = "btn-default"
            if Dias<>"" then
                corBtn = "btn-info"
            end if
            %>
                <button class="btn btn-block <%=corBtn%> text-left" type="button" onclick="$('#divDias').slideToggle()"><i class="far fa-chevron-down"></i> Dias da semana</button>
            </div>
        </div>
            <div class="row pt10" id="divDias" style="display:none">
                <%
                dia = 0
                while dia<7
                    dia = dia+1
                    %>
                    <div class="col-md-4 checkbox-custom checkbox-primary">
                        <input name="Dias" value="<%= dia %>" id="d<%= dia %>" type="checkbox" <% if instr(Dias, dia)>0 then response.write(" checked ") end if %> /><label for="d<%= dia %>"> <%= weekdayname(dia) %></label>
                    </div>
                    <%
                wend
                %>
            </div>
            <hr class="short alt" />



    <div class="row">
        <div class="col-md-12 mt15" style="max-height: 250px; overflow-y: scroll">

        <%
        LogFuncoesSQL = renderLogsTable("rateiodominios", DominioID, 0)
        %>
            </div>

        </div>
    </div>


    </div>
    <div class="panel-footer">
        <button class="btn btn-primary"><i class="far fa-save"></i> SALVAR</button>
</div>
</form>

<script type="text/javascript">
    $("#frmDom").submit(function () {
        $.post("editDomSave.asp?D=<%= DominioID %>", $(this).serialize(), function (data) { eval(data) });
        return false;
    });


<!--#include file="jQueryFunctions.asp"-->
</script>
