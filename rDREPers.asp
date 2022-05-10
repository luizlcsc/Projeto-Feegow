<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<style type="text/css">
    body {
        font-size:12px;
        color:#000;
        padding:20px;
    }
    #dre-table .row-show-more:hover td, #dre-table .col-show-more:hover{
        //text-decoration: underline;
        background-color: #e4f4ff;
        border: 1px solid #a3d8ff;
        color: #008cde;
    }
    #dre-table .row-show-more, .col-show-more{
        cursor: pointer;
    }
    .td-loading{
        opacity: 0.8;
    }
</style>
<%
response.buffer

Exibicao = ref("Exibicao")
Exercicio = ref("Exercicio")
UnidadeID = replace(ref("UnidadeID"), "|", "")
ModeloID = ref("ModeloID")

%>
<div class="row mb20">
    <div class="col-md-2">
        <img width="250" src="https://feegow-public-cdn.s3.us-east-1.amazonaws.com/feegowclinic-v7/assets/img/login_logo.png" />
    </div>
    <h2 class="text-center col-md-10">Demonstração do Resultado do Exercício
         - <%= Exercicio %>
    </h2>
</div>

<table id="dre-table" class="table table-hover">
    <tr>
        <th class="system"></th>
        <%
        db.execute("delete from cliniccentral.dre_temp where sysUser="& session("User"))
        set pcon = db.execute("select c.*, ccond.sqlAnalitico, ccond.sqlAnaliticoPagto, ccond.CD, ccond.Tipo, l.Descricao, l.TipoValor, ccond.Grupos tabcolGrupos, ccond.Categorias tabcolCategorias from dre_modeloscondicoes c LEFT JOIN dre_modeloslinhas l ON l.id=c.LinhaID LEFT JOIN cliniccentral.dre_condicoes ccond ON ccond.id=c.CondicaoID where l.ModeloID="& ModeloID)
        while not pcon.eof
            SemGrupo = 0
            SemCategoria = 0
            Grupos = pcon("Grupos")&""
            Categorias = pcon("Categorias")&""
            if instr(Grupos, "|0|")>0 then
                SemGrupo=1
            end if
            if instr(Categorias, "|0|")>0 then
                SemCategoria=1
            end if
            Grupos = replace( Grupos , "|", "" )
            Categorias = replace( Categorias , "|", "" )
            Pessoas = replace( pcon("Pessoas")&"" , "|", "" )
            tabcolGrupos = pcon("tabcolGrupos")&""
            tabcolCategorias = pcon("tabcolCategorias")&""
            TipoData = pcon("TipoValor")
            CD = pcon("CD")&""
            Tipo = pcon("Tipo")&""
            multiploValor = pcon("Valor")
            multiploDesconto = pcon("Desconto")
            multiploAcrescimo = pcon("Acrescimo")

            'FILTROS
            leftGrupoProcedimentos = ""
            leftCategorias = ""

            andGrupoProcedimentos = ""
            andCategorias = ""
            andPessoas = ""

            if tabcolGrupos<>"" then
                splGrupos = split(tabcolGrupos, ";")
                tabGruposTabLeft = splGrupos(0)
                tabGruposColLeft = "id" 'o join eh sempre pelo ID
                tabGruposTabLeft2 = splGrupos(2)
                tabGruposColLeft2 = splGrupos(3)
                leftGrupoProcedimentos = " LEFT JOIN "& tabGruposTabLeft2 &" ti ON ti.id=ii.ItemID LEFT JOIN "& tabGruposTabLeft &" tg ON tg.id=ti."& tabGruposColLeft2 &" "
            end if

            if tabcolCategorias<>"" then
                splCategorias = split(tabcolCategorias, ";")
                tabCategoriasTabLeft = splCategorias(0)
                tabCategoriasColLeft = splCategorias(1)
                leftCategorias = " LEFT JOIN "& tabCategoriasTabLeft &" ct ON ct.id=ii.CategoriaID"
            end if

            if Grupos<>"" then
                if SemGrupo=1 then
                    sqlSemGrupo = " OR ISNULL(tg."& tabGruposColLeft &") "
                end if
                andGrupoProcedimentos = " AND (tg."& tabGruposColLeft &" IN ("& Grupos &") "& sqlSemCategoria &" ) "
            end if
            if Categorias<>"" and tabcolCategorias<>"" then
                if SemCategoria=1 then
                    sqlSemCategoria = " OR ISNULL(ii.CategoriaID) "
                end if
                andCategorias = " AND (ii.CategoriaID IN ("& Categorias &") "& sqlSemCategoria &" ) "
            end if
            if Pessoas<>"" then
                andPessoas = " AND i.AssociationAccountID IN ("& Pessoas &") "
            end if


            if TipoData="Pagamento" then
                sql = pcon("sqlAnaliticoPagto")&""
            else
                sql = pcon("sqlAnalitico")&""
            end if

            sql = replace(sql, "[sysUser]", session("User"))
            sql = replace(sql, "[LinhaID]", pcon("LinhaID"))
            sql = replace(sql, "[Ano]", Exercicio)
            sql = replace(sql, "[Unidades]", UnidadeID)
            sql = replace(sql, "[Unidades]", UnidadeID)
            sql = replace(sql, "[CD]", CD)
            sql = replace(sql, "[multiploValor]", multiploValor)
            sql = replace(sql, "[multiploDesconto]", multiploDesconto)
            sql = replace(sql, "[multiploAcrescimo]", multiploAcrescimo)
            sql = replace(sql, "[Tipo]", Tipo)
            if Tipo="S" then
                Agrupamento = ", tg.NomeGrupo "
            elseif Tipo="O" then
                Agrupamento = ", ct.Name "
            elseif Tipo="M" then
                Agrupamento = ", concat(ct.Name, ' (estoque)')"
            else
                Agrupamento = ", '' "
            end if
            sql = replace(sql, "[agrupamento]", Agrupamento)
            sql = replace(sql, "[leftGrupoProcedimentos]", leftGrupoProcedimentos)
            sql = replace(sql, "[andGrupoProcedimentos]", andGrupoProcedimentos)
            sql = replace(sql, "[leftCategorias]", leftCategorias)
            sql = replace(sql, "[andCategorias]", andCategorias)
            sql = replace(sql, "[andPessoas]", andPessoas)


            if sql<>"" then
                db.execute("insert into cliniccentral.dre_temp (sysUser, LinhaID, Data, Conta, Valor, Link, NF, ItemInvoiceID, Agrupamento)" & sql )
            end if
        pcon.movenext
        wend
        pcon.close
        set pcon = nothing

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
    set l = db.execute("select * from dre_modeloslinhas WHERE ModeloID="& ModeloID &" ORDER BY ordem   ")
    while not l.eof
        response.flush()
        Classe = l("CorFundo")&""
        LinhaID = l("id")
        Tipo = l("Tipo")
        if Classe="" then
            tag = "td"
        else
            tag = "th"
        end if
        %>
        <tr class="<%= Classe %> row-show-more" id="prin<%= LinhaID %>">
            <%= "<"& tag &" class='col-show-more'>" & l("Descricao") & "</"& tag &">" %>
            <%
            m = 1
            while m<=12
                if Tipo="LINHA" then
                    set t = db.execute("select ifnull(sum(Valor),0) Total from cliniccentral.dre_temp where sysUser="& session("User") &" and month(Data)="& m &" and LinhaID="& LinhaID)
                else
                    Tots = ""
                    set plt = db.execute("select * from dre_totalizadores where LinhaTotID="& LinhaID)
                    while not plt.eof
                        Tots = Tots & " + ifnull(((select sum(Valor) from cliniccentral.dre_temp where LinhaID="& plt("LinhaID") &" and sysUser="& session("User") &" and month(Data)="& m &" and year(Data)="& Exercicio &") * "& plt("SomarSubtrair") &"),0) "
                    plt.movenext
                    wend
                    plt.close
                    set plt = nothing

                    st = "select 0 "& Tots &" Total"
                    'response.write( st &"<br>")
                    set t = db.execute( st )
                end if
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

    let linhasCarregadas = [];
     
    const loadingHtml = `<i class="fas fa-cog fa-spin"></i>`;
    
    function det(l, m, a) {

        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $("#modal-table").modal("show");
        $.get("rDRE_detalhes.asp?LinhaID=" + l + "&Mes=" + m +"&A="+ a, function (data) {
            $("#modal").html(data);
        });
    }
    

    $(".row-show-more").click(function(){
        i = $(this).attr('id').replace('prin', '');
        
        if(linhasCarregadas.includes(i) ){
            return;
        }
        linhasCarregadas.push(i);


        //$('#append'+i).append('<tr><td colspan=13>Carregando...</td></tr>');
        $.get("rDreCats.asp?L="+i, function(data){
            $('.tmp'+i).remove();
            $('#prin'+i).after( data );
        });

    });

    function downloadExcel(tableId){
        $("#htmlTable").val($(tableId).html());
        $("#formExcel").attr("action", domain+"reports/download-excel?title=Extrato&tk=" + localStorage.getItem("tk")).submit();
    }

</script>