<!--#include file="connect.asp"-->
<%

if ref("NomeLayout")<>"" then
    set cols = db.execute("SELECT ccol.NomeColuna, ccol.Descricao, ccol.id ColunaCentralID, cl.id idLinha, cl.Posicao FROM cliniccentral.conciliacaocolunas ccol LEFT JOIN cartaocolunaslayout cl ON (cl.LayoutID="& req("I") &" AND cl.ColunaCentralID=ccol.id) ORDER BY ccol.id")
    while not cols.eof
        valorColuna = ref( cols("NomeColuna") )
        valorColuna = lenu(valorColuna, "N")
        if isnull(cols("idLinha")) then
            db.execute("INSERT INTO cartaocolunaslayout SET LayoutID="& req("I") &", ColunaCentralID="& cols("ColunaCentralID") &", Posicao="& treatValNULL( valorColuna ))
        else
            sqlUp = "UPDATE cartaocolunaslayout SET Posicao="& treatValNULL( valorColuna ) &" WHERE LayoutID="& req("I") &" AND ColunaCentralID="& cols("ColunaCentralID")
            rw( sqlUp )
            db.execute( sqlUp )
        end if
    cols.movenext
    wend
    cols.close
    set cols = nothing

    response.end
end if

call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
%>
<script type="text/javascript">
    $(".crumb-active a").html("Edição de Layout de Conciliação de Cartão");
    $(".crumb-icon a span").attr("class", "far fa-credit-card");
</script>

<form method="post" id="frm" name="frm" action="save.asp">
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />

    <div class="panel mt25">
        <div class="panel-heading">
            <span class="panel-title">Dados do Layout</span>
            <span class="panel-controls">
                <%
                if session("Admin")=1 then
                    %>
                    <button class="btn  btn-primary" id="save">
                        <i class="far fa-save"></i> Salvar
                    </button>
                    <%
                end if
                %>
            </span>
        </div>
        <%'= lenu(req("valor"), req("para")) %>
        <div class="panel-body">
            <div class="row">
                <%= quickfield("text", "NomeLayout", "Nome do Layout", 6, reg("NomeLayout"), "", "", " required ") %>
                <%= quickfield("number", "LinhaInicial", "Número da Linha Inicial", 6, reg("LinhaInicial"), "", "", "") %>
            </div>
            <hr class="short alt"/>
            <div class="row">
                <h3>Informe a letra da coluna no CSV para cada campo de conciliação</h3>
                <%
                set cols = db.execute("SELECT ccol.NomeColuna, ccol.Descricao, ccol.id ColunaCentralID, cl.Posicao FROM cliniccentral.conciliacaocolunas ccol LEFT JOIN cartaocolunaslayout cl ON (cl.LayoutID="& reg("id") &" AND cl.ColunaCentralID=ccol.id) ORDER BY ccol.id")
                while not cols.eof
                    call quickfield("text", cols("NomeColuna"), cols("Descricao"), 2, lenu(cols("Posicao"), "L"), "", "", " maxlength='1' ")
                cols.movenext
                wend
                cols.close
                set cols = nothing
                %>
            </div>
        </div>
    </div>
</form>
<script>
<%call formSave("frm", "save", "")%>

$("#frm").submit(function(){
    $.post("CartaoLayouts.asp?I=<%= req("I") %>", $(this).serialize(), )
});
</script>
