<!--#include file="connect.asp"-->

<%
A = ref("A")
if A<>"" then
    I = ref("I")
    II = ref("II")
    G = ref("G")
    if A="I" or A="U" then
        response.write("<div class='panel'><div class='panel-body'>")
        Agrupamento = ref("G")
        call quickfield("text", "Agrupamento", "Agrupamento", 6, Agrupamento, "", "", "")
        response.write("<div class='col-md-6'>")
        call selectInsert("Inserir procedimento", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", "", oti, "")
        response.write("</div>")
        response.write("</div></div><div class='panel-footer text-right'><button class='btn btn-primary' type='button' onclick='proc( $(`#Agrupamento`).val(), `S`, "& ref("I") &", $(`#ProcedimentoID`).val(), false )'><i class='far fa-save'></i> SALVAR</button></div>")
    elseif A="S" then
        if II<>"" and II<>"0" then
            if I="0" then
                db.execute("insert into procedimentosrapidos set Agrupamento='"& trim(G) &"', ProcedimentoID="& II &", UnidadeID="& session("UnidadeID") &", sysUser="& session("User"))
            end if
            response.write("$('#modal-table').modal('hide');")
            response.write("location.href='./?P=ProcedimentosRapidos&Pers=1&T="& time() &"';")
        end if
    elseif A="X" then
        set pi = db.execute("select * from procedimentosrapidos where id="& I)
        if pi("UnidadeID")=session("UnidadeID") then
            db.execute("delete from procedimentosrapidos where id="& I)
        else
            db.execute("update procedimentosrapidos set ExcetoUnidades=concat( ifnull(ExcetoUnidades, ''), '|"& session("UnidadeID") &"|' ) where id="& I)
        end if
        response.write("location.href='./?P=ProcedimentosRapidos&Pers=1&T="& time() &"';")
    end if
    response.end
end if
%>
<!--#include file="modal.asp"-->

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Seleção Rápida de Procedimentos</span>

        <% if aut("pacotesI")=1 and req("P")="ProcedimentosRapidos" then %>
            <span class="panel-controls">
                <button class="btn btn-sm btn-success" type="button" onclick="proc('', 'I', 0, 0, true)"><i class="far fa-plus"></i> Adicionar</button>
            </span>
        <% else
        if session("Admin")=1 then
        %>
        <span class="panel-controls">
            <button onclick="javascript:location.href='./?P=ProcedimentosRapidos&Pers=1'" class="btn btn-sm btn-primary" type="button"><i class="far fa-cog"></i> Configurar procedimentos</button>
        </span>
        <%
        end if
        end if %>
    </div>
    <div class="panel-body">
        <%
        if session("UnidadeID")<>0 then
            sqlOutraUnidade = " AND NOT ISNULL(i.id) "
        end if
       set grupo = db.execute("select distinct Agrupamento from procedimentosrapidos where UnidadeID="& session("UnidadeID") &" OR (UnidadeID=0 AND ifnull(ExcetoUnidades, '') NOT LIKE '%|"& session("UnidadeID") &"|%') ORDER BY Agrupamento")
        while not grupo.eof
            Agrupamento = grupo("Agrupamento")

            if ModoFranquia then
                sql = "select pr.id, pr.ProcedimentoID, p.NomeProcedimento from procedimentosrapidos pr LEFT JOIN procedimentos p ON p.id=pr.ProcedimentoID LEFT JOIN registros_importados_franquia i ON (i.tabela='procedimentos' AND unidade="&session("UnidadeID")&" and idOrigem=pr.ProcedimentoID) where pr.Agrupamento='"& rep(Agrupamento) &"' AND ( UnidadeID="& session("UnidadeID") &" OR (UnidadeID=0 AND ifnull(ExcetoUnidades, '') NOT LIKE '%|"& session("UnidadeID") &"|%') )"& sqlOutraUnidade &" GROUP BY pr.ProcedimentoID ORDER BY p.NomeProcedimento"
            else
                sql = "select pr.id, pr.ProcedimentoID, p.NomeProcedimento from procedimentosrapidos pr LEFT JOIN procedimentos p ON p.id=pr.ProcedimentoID WHERE pr.Agrupamento='"& rep(Agrupamento) &"' AND ( UnidadeID="& session("UnidadeID") &" OR (UnidadeID=0 AND ifnull(ExcetoUnidades, '') NOT LIKE '%|"& session("UnidadeID") &"|%') ) GROUP BY pr.ProcedimentoID ORDER BY p.NomeProcedimento"
            end if

            set procs = db.execute(sql)
            if not procs.eof then
                %>
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title"><%= Agrupamento %></span>
                        <%
                        if aut("pacotesI")=1 and req("P")="ProcedimentosRapidos" then
                            %>
                            <span class="panel-controls">
                                <button class="btn btn-sm btn-success" type="button" onclick="proc(`<%= grupo("Agrupamento") %>`, 'I', 0, 0, true)"><i class="far fa-plus"></i> Adicionar</button>
                            </span>
                            <%
                        end if
                        %>
                    </div>
                    <div class="panel-body">
                        <%
                        while not procs.eof
                            %>
                            <div class="col-md-4">
                                <% if aut("pacotesX")=1 and req("P")="ProcedimentosRapidos" then
                                    %>
                                    <button type="button" class="btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir este procedimento da lista de procedimentos rápidos?')) proc('', 'X', <%= procs("id") %>, 0, false)"><i class="far fa-remove"></i></button>
                                    <%
                                end if %>
                                <label>
                                <input type="checkbox" class="p<%= procs("id") %>" value="<%= procs("ProcedimentoID") %>" <%if instr(ref("PIs"), "|"& procs("ProcedimentoID") &"|")>0 then response.write(" checked ") end if %> onchange="MarDes($(this).val(), $(this).prop('checked'));">  <%= procs("NomeProcedimento") %></label>
                            </div>
                            <%
                        procs.movenext
                        wend
                        procs.close
                        set procs = nothing
                        %>
                    </div>
                </div>
                <%
            end if
        grupo.movenext
        wend
        grupo.close
        set grupo = nothing
        %>
    </div>
</div>


<script type="text/javascript">

    function proc(G, A, I, II, M){
        $("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
        if(M){ $("#modal-table").modal("show"); }
        $.post("ProcedimentosRapidos.asp", { G:G, A:A, I:I, II:II}, function(data){
            if(M){
                $("#modal").html(data);
            }else{
                eval(data);
            }
        });
    }

    $(".crumb-active a").html("Procedimento Rápido");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("procedimentos em checkbox para rápida seleção");
    $(".crumb-icon a span").attr("class", "far fa-reorder");

    <!--#include file="JQueryFunctions.asp"-->
</script>