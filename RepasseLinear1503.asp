<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<style>


.sb-l-o #content_wrapper {
    margin-left: 0;
}
#sidebar_left {
    background-color: transparent!important;
    border:none!important;
}
</style>

<%

if req("Add")="1" then
    db.execute("insert into rateiodominios (DominioSuperior, sysUser, sysActive) values (0, "& session("User") &", 1)")
    response.Redirect("./?P=RepasseLinear&Pers=1")
end if

if req("X")<>"" then
    db.execute("delete from rateiodominios where id="& req("X"))
end if

%>
<script type="text/javascript">
    $(".crumb-active a").html("Repasse");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("edição simplificada");
    $(".crumb-icon a span").attr("class", "fa fa-puzzle");
    <%
    if aut("repassesI")=1 then
    %>
    $("#rbtns").html('<a onclick="location.href=\'./?P=RepasseLinear&Pers=1&Add=1\'" class="btn btn-sm btn-success pull-right"><i class="fa fa-plus"></i><span class="menu-text"> ADICIONAR</span></a>');
    <%
    end if
    %>
</script>

<form id="frmRL">
    <div class="panel mt20">
        <div class="panel-body">
            <table class="table table-condensed table-hover table-bordered table-striped">
                <thead>
                    <tr>
                        <th width="1%"></th>
                        <th width="21%">CONVÊNIO / PARTICULAR</th>
                        <th width="21%">TABELAS</th>
                        <th width="21%">ESPECIALIDADES / PROFISSIONAIS / GRUPOS</th>
                        <th width="21%">GRUPOS / PROCEDIMENTOS</th>
                        <th width="7%">UNIDADES</th>
                        <th width="15%">VALOR</th>
                        <th width="1%"></th>
                        <th width="1%"></th>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th>0</th>
                        <th colspan="5">REGRA GERAL</th>
                        <td nowrap>
                            <button type="button" onclick="valFun(0); $('#save').click()" class="btn btn-xs btn-info btn-block">
                            <%
                            DominioID = 0

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
                        </td>
                    </tr>
                    <%
                    set dom = db.execute("select * from rateiodominios order by id")
                    while not dom.eof
                        Formas = dom("Formas")&""
                        strFormas = ""
                        'if instr(Formas, "|P|") then
                            'strFormas = "PARTICULAR"
                            'Formas = replace(Formas, "|P|", "|0|")
                        'end if
                        Formas = replace(Formas, "|", "")
                        Convenios = ""

                        if Formas<>"" then
                            if instr(Formas, "P")<=0 then
                                set sqlFormas = db.execute("select group_concat(trim(NomeConvenio) separator ', ') convenios from convenios where id in("& Formas &") and sysActive=1")
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
                        <tr>
                            <td width="1%"><%= DominioID %></td>
                            <td><%= strFormas %></td>
                            <td><%= strTabelas %></td>
                            <td><%= strEspecialidades &"<br>"& strProfissionaisGrupos &"<br>"& strProfissionais %></td>
                            <td><%= strProcedimentosGrupos &"<br>"& strProcedimentos %></td>
                            <td><%= strUnidades %></td>
                            <td nowrap>
                                <button type="button" onclick="valFun(<%= DominioID %>); $('#save').click()" class="btn btn-xs btn-info btn-block">
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
                            </td>
                            <td>
                                <button onclick="editDom(<%= dom("id") %>)" type="button" class="btn btn-success btn-sm"><i class="fa fa-edit"></i></button>
                            </td>
                            <td>
                                <button onclick="if(confirm('Tem certeza de que deseja apagar esta regra?'))location.href='./?P=RepasseLinear&Pers=1&X=<%= dom("id") %>'" type="button" class="btn btn-danger btn-sm"><i class="fa fa-remove"></i></button>
                            </td>
                        </tr>
                        <%
                    dom.movenext
                    wend
                    dom.close
                    set dom = nothing
                        %>
                </tbody>
            </table>
        </div>

    </div>


    <div class="panel mt20">
        <div class="panel-heading">
            <span class="panel-title">Descontos adicionais no repasse de acordo com a forma de recebimento</span>
            <span class="panel-controls">
                <button type="button" onclick="repasseDesconto(0)" class="btn-sm btn btn-primary">
                    <i class="fa fa-plus"></i> Adicionar
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

<script type="text/javascript">

function editDom(D){
    $("#modal-table").modal("show");
    $("#modal").html("Carregando...");
    $.get("editDom.asp?D="+D, function(data){ $("#modal").html(data) });
}

function salvaRepasseLinear(){
    $.post("saveRepasseLinear.asp", $("#frmRL").serialize(), function (data) {
        eval(data);
    });
}
    function valFun(D){
       $("#modal-table").modal("show");
       $("#modal").html("Carregando...");
       $.get("modalRateioFuncoes.asp?T=&I="+D+"&A=E&Linear=1", function(data){
            $("#modal").html(data);
        });
    }

$("#frmModal").submit(function(){
	$.ajax({
		   type:"POST",
		   url:"saveFuncoesRateio.asp?DominioID=<%=DominioID%>&Tipo=<%=Tipo%>&Acao=<%=Acao%>",
		   data:$("#frmModal").serialize(),
		   success:function(data){
			   eval(data);
		   }
		   });
	return false;
});

function removeItem(Tipo, ItemID){
	if(Tipo=='Item'){
		var msg = 'Tem certeza de que deseja excluir este item?';
	}else{
		var msg = 'Tem certeza de que deseja excluir todos os itens listados acima?';
	}
	if(confirm(msg)){
			   $.ajax({
			   type:"POST",
			   url:"funcoesRateioRemoveItem.asp?Tipo="+Tipo+"&DominioID=<%=DominioID%>&ItemID="+ItemID,
			   success:function(data){
				   eval(data);
			   }
			   });
	}
}

function adicionaItem(Tipo, ItemID, FM){
   $.ajax({
   type:"POST",
   url:"funcoesRateioRemoveItem.asp?Tipo="+Tipo+"&DominioID=<%=DominioID%>&ItemID="+ItemID+"&FM="+FM,
   success:function(data){
	   eval(data);
   }
   });
}
</script>


<script type="text/javascript">
function fRateio(T, I, A){
	$.ajax({
	   type:"GET",
	   url:"modalRateioFuncoes.asp?T="+T+"&I="+I+"&A="+A,
	   success:function(data){
		   $("#modal").html("Carregando...");
		   $("#modal-table").modal('show');
		   setTimeout(function(){$("#modal").html(data);}, 1000);
	   }
   });
}

function repasseDesconto(I) {
    $("#modal").html("Carregando...");
    $("#modal-table").modal("show");
    $.get("repasseDesconto.asp?I=" + I, function (data) {
        $("#modal").html(data);
    });
}

function removeDominio(I){
	var msg = 'Tem certeza de que deseja remover esta regras e todas as regras a ela atreladas?';
	if(confirm(msg)){
			   $.ajax({
			   type:"POST",
			   url:"removeRateioDominio.asp?I="+I,
			   success:function(data){
				   ajxContent('arvorerateio', '', 1, 'arvorerateio');
			   }
			   });
	}
}

</script>
