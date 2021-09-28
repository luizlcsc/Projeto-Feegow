<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="Classes/Logs.asp"-->


<%

if req("Add")="1" then
    sqlRepasseConfig = "insert into rateiodominios (DominioSuperior, sysUser, sysActive) values (0, "& session("User") &", 1)"
    call gravaLogs(sqlRepasseConfig, "AUTO", "Regra de repasse adicionada", "")

    db.execute(sqlRepasseConfig)
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
    $(".crumb-icon a span").attr("class", "far fa-puzzle");
    <%
    if aut("repassesI")=1 then
    %>
    $("#rbtns").html('<button type="button" onclick="print()" class="btn btn-info btn-sm mr10"><i class="far fa-print"></i> IMPRIMIR</button> <a onclick="location.href=\'./?P=RepasseLinear&Pers=1&Add=1\'" class="btn btn-sm btn-success pull-right"><i class="far fa-plus"></i><span class="menu-text"> ADICIONAR</span></a>');
    <%
    end if
    %>
</script>

<div class="panel mt20 hidden-print">
    <div class="panel-heading">
        <span class="panel-title"><i class="far fa-filter"></i> Filtrar Funil de Regra</span>
        <span class="panel-controls">
            <button type="button" onclick="HistoricoAlteracoes()" class="btn btn-default btn-sm" title="Histórico de alterações"><i class="far fa-history"></i> </button>
            <!-- <button type="button" class="btn btn-primary btn-sm"><i class="far fa-filter"></i> Filtrar</button> -->
        </span>
    </div>
    <div class="panel-body">
        <form id="filtroRepasse">
            <div class="row">
                <%= quickfield("simpleSelect", "Convenios", "Convênios", 2, "", "select 'P' id, '           PARTICULAR' NomeConvenio UNION ALL select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", " empty ") %>

                <%= quickfield("simpleSelect", "TabelasParticulares", "Tabelas Particulares", 2, "", "select id, NomeTabela from tabelaparticular where sysActive=1 and ativo='on' order by NomeTabela", "NomeTabela", " empty ") %>

                <%
                    'ESPECIALIDADES
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

                    sqlEsp = "select concat('', id*(-1)) id, Especialidade from especialidades where 0 "& Especialidades1 & Especialidades2 &" and sysActive=1 order by especialidade"
                    call quickfield("simpleSelect", "Especialidades", "Especialidades", 2, "", sqlEsp, "Especialidade", " empty ")
                %>

                <%= quickfield("simpleSelect", "Profissionais", "Profissional", 2, "", "select id, NomeProfissional from profissionais where ativo='on' and sysActive=1 order by NomeProfissional", "NomeProfissional", " empty ") %>

                <%= quickfield("simpleSelect", "ProfissionaisGrupos", "Grupo de Profissional", 2, "", "select id, NomeGrupo from profissionaisgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", " empty ") %>

                <%= quickfield("simpleSelect", "ProcedimentosGrupos", "Grupo de Procedimento", 2, "", "select concat('', id*(-1)) id, NomeGrupo from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", " empty ") %>

                <%= quickfield("simpleSelect", "Procedimentos", "Procedimento", 2, "", "select id, NomeProcedimento from procedimentos where sysActive=1 and ativo='on' order by NomeProcedimento", "NomeProcedimento", " empty ") %>

                <%= quickfield("simpleSelect", "Unidades", "Unidade", 2, "", "select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits where sysActive=1", "NomeFantasia", " empty ") %>

            </div>
        </form>
    </div>
</div>

<div id="divFRMrl">
    <% server.execute("frmRL2.asp") %>
</div>

<script type="text/javascript">

function editDom(D){
    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10"><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.get("editDom.asp?D="+D, function(data){ $("#modal").html(data) });
}

function salvaRepasseLinear(){
    $.post("saveRepasseLinear.asp", $("#frmRL").serialize(), function (data) {
        eval(data);
    });
}
    function valFun(D){
       $("#modal-table").modal("show");
       $("#modal").html(`<div class="p10"><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
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
		   $("#modal").html(`<div class="p10"><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
		   $("#modal-table").modal('show');
		   setTimeout(function(){$("#modal").html(data);}, 1000);
	   }
   });
}

function repasseDesconto(I) {
    $("#modal").html(`<div class="p10"><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
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

    $("#filtroRepasse").change(function () {
        $("#divFRMrl").html("<i class='far fa-spinner fa-spin orange bigger-125'></i> Carregando...")
        
        $.post("frmRL2.asp", $(this).serialize(), function (data) {
            $("#divFRMrl").html(data)
        });
    });

    function HistoricoAlteracoes() {
        openComponentsModal("LogUltimasAlteracoes.asp", {
            Tabelas: "rateiofuncoes,rateiodominios"
        }, "Log de alterações", true);
    }
</script>
