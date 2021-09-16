<!--#include file="connect.asp"-->
<%if req("PacienteID")="" then %>
<!--#include file="modal.asp"-->
<style>
.duplo>tbody>tr:nth-child(4n+1)>td,
.duplo>tbody>tr:nth-child(4n+2)>td
{    background-color: #f9f9f9;
}
.duplo>tbody>tr:nth-child(4n+3)>td,
.duplo>tbody>tr:nth-child(4n+4)>td
{    background-color: #ffffff;
}

.editavel{
	border:2px solid #fff;
}
.editavel:hover{
	border:2px dotted #CCC;
}
</style>
<%end if %>
<%
tableName = "propostas"
CD = req("T")
PropostaID = req("I")

Titulo = "EDIÇÃO DE PROPOSTA"

if PropostaID="N" then
	sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, CD, Recurrence, RecurrenceType, Value) values ("&session("User")&", 0, '"&CD&"', 1, 'm', 0)")
		set vie = db.execute(sqlVie)
	end if
	response.Redirect("?P=Propostas&I="&vie("id")&"&Pers=1")'A=AgendamentoID quando vem da agenda
else
	set data = db.execute("select * from "&tableName&" where id="&PropostaID)
	if data.eof then
		response.Redirect("?P=Propostas&I=N&Pers=1")
	end if
end if

ContaID = data("AccountID")
AssID = data("AssociationAccountID")
TituloItens = "Itens da Proposta"
TituloOutros = "Outras Despesas"

if data("sysActive")=1 then
	TituloItens = data("Name")
else
	set pultit = db.execute("select Name from propostas where sysActive=1 and not isnull(Name) and not Name='' order by id desc limit 1")
	if not pultit.eof then
		TituloItens = pultit("Name")
	end if
end if

if req("PacienteID")="" then
	Pagador = AssID&"_"&ContaID
else
	Pagador = "3_"&req("PacienteID")
end if
%>
<div class="row">
  <div class="col-xs-12">
    <form id="formItens" action="" method="post">
    <input id="Lancto" type="hidden" name="Lancto" value="<%=req("Lancto")%>">
    <%=header("Propostas", titulo, data("sysActive"), PropostaID, 1, "Follow")%>
    <input type="hidden" id="sysActive" name="sysActive" value="<%=data("sysActive")%>" />
    <div class="clearfix form-actions">
        <div class="col-md-6">
            <label>Paciente</label><br />
            <%=selectInsertCA("", "AccountID", Pagador, "3", "", " required", "")%>
        </div>
        <%
        if data("sysActive")=0 then
            UnidadeID = session("UnidadeID")
        else
            UnidadeID = data("CompanyUnitID")
        end if
        %>
        <%=quickField("empresa", "CompanyUnitID", "Unidade", 3, UnidadeID, " disable", "", "")%>
        <div class="col-md-3">
            <%=quickField("memo", "Description", "", 3, data("Description"), "", "", " rows='2' placeholder='Observa&ccedil;&otilde;es...'")%>
        </div>
    </div>
    
    
    <div class="row">
        <div class="col-xs-12" id="propostaItens">
            <%server.Execute("propostaItens.asp")%>
        </div>
    </div>

    <div class="widget-box transparent">
        <div class="widget-header">
        	<div class="col-xs-8">
                <input class="form-control" name="TituloOutros" id="TituloOutros" value="<%=TituloOutros%>" style="border:none; font-size:18px; color:#4383b4;"></h4>
            </div>
            <div class="col-xs-4">
                <div class="widget-toolbar no-border">
                    <div class="btn-toolbar">
                        <div class="btn-group">
                            <button class="btn btn-success btn-sm dropdown-toggle disable" data-toggle="dropdown">
                            Selecione
                            <span class="far fa-caret-down icon-on-right"></span>
                            </button>
                            <ul class="dropdown-menu dropdown-success">
                                <li>
                                <a href="javascript:itens('S', 'I', 0)">Consulta ou Procedimentos</a>
                                </li>
                                <li class="divider"></li>
                                <li>
                                <a href="javascript:cadastrarOutro()"><i class="far fa-plus"></i> Cadastrar item</a>
                                </li>
                            </ul>
                        </div>
                    </div>            
                </div>
            
            </div>
        </div>
    </div>
    
    <div class="row">
        <div class="col-xs-12" id="propostaItens">
            <%server.Execute("propostaOutrasDespesas.asp")%>
        </div>
    </div>
    <hr>



    <input type="hidden" name="T" value="<%=req("T")%>" />
    </form>
  </div>
</div>
<script type="text/javascript">

<!--#include file="propostasfuncoes.asp"-->

<!--#include file="financialCommomScripts.asp"-->

</script>
<!--#include file="disconnect.asp"-->