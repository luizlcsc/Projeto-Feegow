<style type="text/css">
    .preto {
        background-color:#000;
        color:#fff;
    }
</style>

<!--#include file="connect.asp"-->
<%

'DAQUI PRA BAIXO JOGA EM OUTRO ARQUIVO

'2. EXIBINDO AS UNIDADES QUE FORAM LOCALIZADAS
Data = cdate(req("Data"))
DataFinal = Data+5
sql = "SELECT distinct ifnull(l.UnidadeID, 0) UnidadeID, u.Regiao FROM agendabuscahorarios ah LEFT JOIN locais l ON l.id=ah.LocalID LEFT JOIN sys_financialcompanyunits u ON u.id=l.UnidadeID WHERE ah.sysUser="& session("User") &" ORDER BY l.UnidadeID"
'response.write( sql )
set un = db.execute( sql )
fakeAPID = 0
while not un.eof
    UnidadeID = ccur(un("UnidadeID"))
    Regiao = replace(un("Regiao")&"", " ", "_")
    if UnidadeID=0 then
        set nu = db.execute("select NomeFantasia from empresa")
    else
        set nu = db.execute("select NomeFantasia from sys_financialcompanyunits where id="& UnidadeID)
    end if
    NomeFantasia = nu("NomeFantasia")
    %>
    <table class="table table-condensed table-bordered mt5 table-hover unidade <%= Regiao %> <% if Regiao<>replace(req("Regiao"), " ", "_") and req("Regiao")<>"" then response.write(" hidden ") end if %>">
        <thead>
            <tr class="preto">
                <th width="13%" onclick="expand(<%= UnidadeID %>, '')"><i id="icoU<%= UnidadeID %>" class="far fa-plus"></i></th>
                <th class="bg-primary"><i class="far fa-map-marker"></i> <%= NomeFantasia %></th>
                <%
                DataAtu = Data
                while DataAtu<DataFinal
                    %>
                    <th class="text-center" width="13%"><%= DataAtu %></th>
                    <%
                    DataAtu = DataAtu+1
                wend
                %>
            </tr>
            <%
            set esp = db.execute("select distinct bh.CarrinhoID, p.NomeProcedimento, cart.EspecialidadeID, cart.ProcedimentoID FROM agendabuscahorarios bh LEFT JOIN locais l ON l.id=bh.LocalID LEFT JOIN procedimentos p ON p.id=bh.ProcedimentoID LEFT JOIN agendacarrinho cart ON cart.id=bh.CarrinhoID WHERE bh.sysUser="& session("User") &" AND l.UnidadeID="& UnidadeID)
            while not esp.eof
                CarrinhoID = esp("CarrinhoID")
                NomeProcedimento = esp("NomeProcedimento")
                EspecialidadeID = esp("EspecialidadeID")
                ProcedimentoID = esp("ProcedimentoID")

'                ProcedimentoID = esp("ProcedimentoID")
                %>
                <tr class="dark">
                    <th onclick="expand(<%= UnidadeID %>, '<%= ProcedimentoID %>')"><i id="icoUP<%= UnidadeID&"_"& ProcedimentoID %>" class="far fa-plus"></i>
                        
                        <span class="pull-right label label-dark label-xs">R$</span></th>
                    <th><%= NomeProcedimento %></th>
                    <%
                    DataAtu = Data
                    while DataAtu<DataFinal
                        set conta = db.execute("SELECT "&_ 
                            "( select count(bh.id) from agendabuscahorarios bh LEFT JOIN locais l ON l.id=bh.LocalID WHERE bh.sysUser="& session("User") &" AND l.UnidadeID="& UnidadeID &" AND bh.CarrinhoID="& CarrinhoID &" AND bh.Data="& mydatenull(DataAtu) &" AND bh.Hora BETWEEN '00:00:00' AND '11:59:00') M, "&_ 
                            "( select count(bh.id) from agendabuscahorarios bh LEFT JOIN locais l ON l.id=bh.LocalID WHERE bh.sysUser="& session("User") &" AND l.UnidadeID="& UnidadeID &" AND bh.CarrinhoID="& CarrinhoID &" AND bh.Data="& mydatenull(DataAtu) &" AND bh.Hora BETWEEN '12:00:00' AND '23:59:00') T")
                        Manha = ccur(conta("M"))
                        Tarde = ccur(conta("T"))
                        if Manha>0 or Tarde>0 then
                            classe = "bg-success"
                        else
                            classe = ""
                        end if
                        %>
                        <th class="text-center <%= classe %>"><%= Manha &" M / "& Tarde &" T" %></th>
                        <%
                        DataAtu = DataAtu+1
                    wend
                    %>
                </tr>
        </thead>
        <tbody>
                <%
                set profs = db.execute("select distinct bh.ProfissionalID, prof.NomeProfissional, esp.Especialidade, prof.ObsAgenda FROM agendabuscahorarios bh LEFT JOIN profissionais prof ON prof.id=bh.ProfissionalID LEFT JOIN locais l ON l.id=bh.LocalID LEFT JOIN especialidades esp ON esp.id=prof.EspecialidadeID WHERE bh.sysUser="& session("User") &" AND l.UnidadeID="& UnidadeID &" AND CarrinhoID="& CarrinhoID &" ORDER BY prof.NomeProfissional")
                while not profs.eof
                    ProfissionalID = profs("ProfissionalID")
                    fakeAPID = fakeAPID + 1
                    ObsAgenda = profs("ObsAgenda")
                    %>
                    <tr class="rowUP<%= UnidadeID&"_"& ProcedimentoID %> rowU<%= UnidadeID %> hidden">
                        <th valign="top" style="vertical-align:top">
                            <%= quickfield("currency", "Valor"&fakeAPID, "À vista", 12, "Carregando...", "", "", " disabled ") %>
                            <script type="text/javascript">
                                $.post("AgendaParametros.asp?tipo=ProcedimentoID<%= fakeAPID %>&id=<%= ProcedimentoID %>", {
                                    ProfissionalID: '<%= ProfissionalID %>',
                                    Data: '<%= Data %>',
                                    EspecialidadeID: '<%= EspecialidadeID %>',
                                    ageTabela: '<%= TabelaID %>'
                                }, function (data) { eval(data) });
                            </script>



                        </th>
                        <th valign="top" style="vertical-align:top">
                            <%= profs("NomeProfissional") %><br />
                            <small><%= profs("Especialidade") %></small>

                            <% if ObsAgenda&""<>"" then %>
                                <br />
                                <button onclick="obs(<%= ProfissionalID %>);" type="button" class="btn btn-xs btn-dark">OBSERVAÇÃO</button>
                            <% end if %>
                        </th>
                        <%
                        DataAtu = Data
                        while DataAtu<DataFinal
                            %>
                            <th valign="top" class="text-center pl10 pr10 ptn pbn">
                                <%
                                sql = "SELECT bh.Hora FROM agendabuscahorarios bh LEFT JOIN locais l ON l.id=bh.LocalID WHERE  bh.sysUser="& session("User") &" AND bh.CarrinhoID="& CarrinhoID &" AND l.UnidadeID="& UnidadeID &" AND bh.Data="& mydatenull(DataAtu) &" AND bh.ProfissionalID="& ProfissionalID &" limit 3000"
                                'response.Write( sql )
                                set hor = db.execute( sql )
                                if not hor.eof then
                                    %>
                                    <div class="row" style="height:120px; overflow:scroll; overflow-x:hidden">
                                    <%
                                    while not hor.eof
                                        %>
                                        <div class="col-xs-4 pn">
                                            <button type="button" class="btn btn-sm btn-block btn-primary mn"><%= ft(hor("Hora")) %></button>
                                        </div>
                                        <%
                                    hor.movenext
                                    wend
                                    hor.close
                                    set hor=nothing
                                    %>
                                    </div>
                                    <%
                                end if
                                %>
                            </th>
                            <%
                            DataAtu = DataAtu+1
                        wend
                        %>
                    </tr>
                    <%
                profs.movenext
                wend
                profs.close
                set profs = nothing
            esp.movenext
            wend
            esp.close
            set esp = nothing
            %>
        </tbody>
    </table>
    <%
un.movenext
wend
un.close
set un=nothing

if req("Regiao")<>"" then
    %>
    <button class="btn btn-primary btn-block" type="button" onclick="$('.unidade').removeClass('hidden'); $(this).addClass('hidden');">Mostrar todas as regiões</button>
    <%
end if
%>


<script type="text/javascript">
    function obs(ProfissionalID) {
        $("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
        $("#modal-table").modal("show");
        $.get("ObsAgenda.asp?ProfissionalID=" + ProfissionalID, function (data) { $("#modal").html(data) });
    }

    function expand(U, P) {
        if (P == '') {
            var classe = "U" + U;
        } else {
            var classe = "UP" + U + "_" + P;
        }
        var el = $(".row" + classe);
        var ic = $("#ico" + classe);
        if (el.hasClass("hidden")) {
            el.removeClass("hidden");
            ic.removeClass("fa-plus");
            ic.addClass("fa-minus");
        } else {
            el.addClass("hidden");
            ic.removeClass("fa-minus");
            ic.addClass("fa-plus");
        }
    }
</script>