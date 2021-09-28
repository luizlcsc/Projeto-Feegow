<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<style type="text/css">
    body {
        font-size:12px;
        color:#000;
        padding:20px;
    }
</style>
<%
response.buffer

Exibicao = ref("Exibicao")
Exercicio = ref("Exercicio")
UnidadeID = ref("UnidadeID")


%>
<div class="row mb20">
    <div class="col-md-2">
        <img width="250" src="https://feegow-public-cdn.s3.us-east-1.amazonaws.com/feegowclinic-v7/assets/img/login_logo.png" />
    </div>
    <h2 class="text-center col-md-10">Demonstração do Resultado do Exercício
         - <%= Exercicio %>
    </h2>
</div>

<table class="table table-hover">
    <tr>
        <th></th>
        <%
        db.execute("delete from cliniccentral.dre_temp where sysUser="& session("User"))
        set pQueries = db.execute("select * from cliniccentral.dre where not isnull(sqlCorpo)")

        while not pQueries.eof
            response.flush()
            qId = pQueries("id")
            sqlAnalitico = pQueries("sqlAnalitico")
            sqlAnalitico = replace(sqlAnalitico, "[sysUser]", session("User") )
            sqlAnalitico = replace(sqlAnalitico, "[LinhaID]", qId )
            sqlCorpo = pQueries("sqlCorpo")
            sqlCorpo = replace(sqlCorpo, "[Mes]", m)
            sqlCorpo = replace(sqlCorpo, "[Ano]", Exercicio)
            sqlCorpo = replace(sqlCorpo, "[Unidades]", replace(UnidadeID, "|", "") )
            sqlFixa = pQueries("sqlFixa")&""
            sqlFixa = replace( sqlFixa, "[Ano]", Exercicio )

            'GRAVANDO AS INVOICES CONSOLIDADAS
                    'dd("insert into cliniccentral.dre_temp (sysUser, LinhaID, Data, Conta, Valor, Link, InvoiceID) SELECT "& sqlAnalitico &" "& sqlCorpo &"")
            db.execute("insert into cliniccentral.dre_temp (sysUser, LinhaID, Data, Conta, Valor, Link, InvoiceID) SELECT "& sqlAnalitico &" "& sqlCorpo &"")

            'LISTANDO AS INVOICES FIXAS
            if sqlFixa<>"" then
                'response.write( sqlFixa )
                set fixa = db.execute( sqlFixa )
                while not fixa.eof
                    response.flush()
                    PrimeiroVencto = fixa("PrimeiroVencto")
                    'InvoiceID = fixa("InvoiceID")
                    Valor = fixa("Valor")
                    Intervalo = fixa("Intervalo")
                    TipoIntervalo = fixa("TipoIntervalo")
                    RepetirAte = fixa("RepetirAte")
                    Conta = fixa("Conta")
                    Valor = fixa("Valor")
                    FixaID = fixa("id")
                    CD = fixa("CD")
                    Geradas = fixa("Geradas")

                    'response.write("<br>"& PrimeiroVencto &" - "& RepetirAte &"<br>")
                    Vencimento = PrimeiroVencto
                    UltimaData = cdate("1/1/"& ccur(Exercicio)+1)-1
                    numero = 0
                    if not isnull(RepetirAte) then
                        if RepetirAte<UltimaData then
                            UltimaData = RepetirAte
                        end if
                    end if
                    while Vencimento<=UltimaData
                        numero = numero+1
                        if Vencimento>date() and instr(Geradas, "|"& numero &"|")=0 then
''                            response.write("> "& Vencimento &" ( "& UltimaData &" )<br>" )
                            sqlIns = "insert into cliniccentral.dre_temp (sysUser, LinhaID, Data, Conta, Valor, Link, InvoiceID) values ("& session("User") &", "& qID &", "& mydatenull(Vencimento) &", '"& Conta &"', "& treatvalzero(Valor) &", './?P=Recorrente&I="& FixaID &"&T="& CD &"&Pers=1', "&treatvalnull(InvoiceID)&")"
                            db.execute(sqlIns       )
                        end if
                        Vencimento = dateAdd( TipoIntervalo, Intervalo, Vencimento )
                    wend
                fixa.movenext
                wend
                fixa.close
                set fixa = nothing
            end if


        pQueries.movenext
        wend
        pQueries.close
        set pQueries = nothing



        m = 1
        while m<=12
            %>
            <th class="system text-center"><%= ucase(left(monthname(m),30)) %></th>
            <%
            m = m+1
        wend
        %>
    </tr>
    <%
    set l = db.execute("select * from cliniccentral.dre where Exibe=1 order by ordem")
    while not l.eof
        response.flush()
        Classe = l("Classe")&""
        LinhaID = l("id")
        FormulaLinhasOriginal = l("FormulaLinhas")
        if Classe="" then
            tag = "td"
        else
            tag = "th"
        end if
        %>
        <tr class="<%= l("Classe") %>">
            <%= "<"& tag &">" & l("Descricao") & "</"& tag &">" %>
            <%
            m = 1
            while m<=12
                FormulaLinhas = FormulaLinhasOriginal
                if isnull(FormulaLinhas) then
                    set t = db.execute("select ifnull(sum(Valor),0) Total from cliniccentral.dre_temp where sysUser="& session("User") &" and month(Data)="& m &" and LinhaID="& LinhaID)
                else
                    FormulaLinhas = replace(FormulaLinhas, "[sysUser]", session("User") )
                    FormulaLinhas = replace(FormulaLinhas, "[Mes]", m)
                    set t = db.execute( FormulaLinhas )
                end if
                'Valor = sql("Valor")
                Valor = t("Total")
                %>
                <%= "<"& tag &" data-l='"& LinhaID &"' data-m='"& m &"' class='text-right'>" & fn(Valor) & "</"& tag &">" %>
                <%
                m = m+1
            wend
            %>
        </tr>
        <%
    l.movenext
    wend
    l.close
    set l = nothing
    %>
</table>

<script type="text/javascript">
    $("tr td").click(function () {
        var LinhaID = $(this).attr("data-l");
        var Mes = $(this).attr("data-m");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $("#modal-table").modal("show");
        $.get("rDRE_detalhes.asp?LinhaID=" + LinhaID + "&Mes=" + Mes, function (data) {
            $("#modal").html(data);
        });
    });
</script>