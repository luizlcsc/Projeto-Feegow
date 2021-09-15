<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Procedimentos habilitados na agenda (Obs.: quando restrito a agendas específicas)</span>
        <span class="panel-controls">
            <button class="btn btn-sm btn-primary" type="button" id="btnProcsProf"><i class="far fa-save"></i> Salvar</button>
        </span>
    </div>
    <div class="panel-body">
        <div class="row justify-content-md-end">
            <div class="col-md-8 "></div>
               <%=quickField("simpleSelect", "TipoProcedimento", "Tipo de Procedimento", 4, "", "SELECT * FROM tiposprocedimentos order by 2 ", "TipoProcedimento", "")%>
        </div>
        <div class="clearfix"></div>
        <%

        ProfissionalID = req("I")
        tela = req("tela")&""

        campo = "SomenteProfissionais"
        if tela = "ProfissionalExterno" then
            campo = "SomenteProfissionaisExterno"
        elseif tela = "Fornecedores" then 
            campo = "SomenteFornecedor"
        end if

        if req("Alt")="1" then
            db.execute("update procedimentos set "&campo&"=replace("&campo&", ', |"&ProfissionalID&"|', '') where "&campo&" like '%, |"& ProfissionalID &"|%'")
            db.execute("update procedimentos set "&campo&"=replace("&campo&", '|"&ProfissionalID&"|, ', '') where "&campo&" like '%|"& ProfissionalID &"|, %'")
            db.execute("update procedimentos set "&campo&"=replace("&campo&", '|"&ProfissionalID&"|', '') where "&campo&" like '%|"& ProfissionalID &"|%'")
            if ref("ProcedimentosAgenda")<>"" then
                db.execute("update procedimentos set "&campo&"=concat( ifnull("&campo&", ''), if("&campo&" is null or "&campo&"='', '', ', ') ,'|"&ProfissionalID&"|' ) where id in("& replace(ref("ProcedimentosAgenda"), "|", "") &")")
            end if
            %>
<script >
$(document).ready(function() {
    showMessageDialog("Procedimentos salvos.", "success");
});
</script>
            <%
        end if

        set procs = db.execute("select group_concat( concat('|', id, '|')) procedimentos from procedimentos where "&campo&" like '%|"& ProfissionalID &"|%'")
        Procedimentos = procs("Procedimentos")

        'response.write("{"& Procedimentos &"}")

        set dist = db.execute("select distinct ifnull(p.GrupoID, 0) GrupoID, ifnull(g.NomeGrupo, 'PROCEDIMENTOS SEM GRUPO') NomeGrupo from procedimentos p LEFT JOIN procedimentosgrupos g ON g.id=p.GrupoID where p.Ativo='on' ORDER BY g.NomeGrupo")
        while not dist.eof
            %>
            <h4 class="checkbox-custom">
                <input type="checkbox" id="g<%= dist("GrupoID") %>" onclick="$('.g<%=dist("GrupoID")%>').prop('checked', $(this).prop('checked') )" />
                    <label for="g<%= dist("GrupoID") %>">
                        <%= ucase(dist("NomeGrupo")&"") %>
                    </label>
                </h4>
            <div class="row">
            <%
            set proc = db.execute("select id, NomeProcedimento,TipoProcedimentoID from procedimentos where sysActive=1 and Ativo='on' and ifnull(GrupoID, 0)="& dist("GrupoID")&" order by NomeProcedimento")
            while not proc.eof
                %>
                <div class="col-md-3 checkbox-custom checkbox-primary">
                    <input type="checkbox" id="p<%= proc("id") %>" name="ProcedimentosAgenda" tipo="<%=proc("TipoProcedimentoID") %>" value="<%= proc("id") %>" class="g<%= dist("GrupoID") %> procprof" <% if instr(Procedimentos, "|"& proc("id") &"|")>0 then response.write(" checked ") end if %> /> <label for="p<%= proc("id") %>"><%= proc("NomeProcedimento") %></label>
                </div>
                <%
            proc.movenext
            wend
            proc.close
            set proc = nothing
            %>
            </div>
            <hr class="short alt" />
            <%
        dist.movenext
        wend
        dist.close
        set dist = nothing
        %>
    </div>
</div>
<script type="text/javascript">
    $("#TipoProcedimento").change(() => {
        let v = $("#TipoProcedimento").val();
        if(!v){
            $(".row .checkbox-custom").show();
            return;
        }

        $(".row .checkbox-custom").hide();
        $(".row .checkbox-custom [tipo='"+v+"']").parents(".checkbox-custom").show();

    })



    $("#btnProcsProf").click(function () {
        $.post("ProfProcAgenda.asp?I=<%= req("I") %>&Alt=1&tela=<%= req("tela") %>", $('.procprof').serialize(), function (data) {
            $('#divPermissoes').html(data);
        });
    });
</script>