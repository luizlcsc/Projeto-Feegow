<!--#include file="connect.asp"-->

<style type="text/css">
body, tr, td, th {
	font-size:9px!important;
	padding:2px!important;
}

.btnPac {
    visibility:hidden;
}

.linhaPac:hover .btnPac {
    visibility:visible;
}

</style>

<%
response.CharSet="utf-8"

TotalGeral = 0
TotalRec = 0
TotalAtendimentos = 0
db_execute("delete from tempfaturamento where sysUser="&session("User"))

DataDe = reqf("DataDe")
DataAte = reqf("DataAte")

response.Buffer
%>
<h3 class="text-center">Produ&ccedil;&atilde;o - Analítico</h3>
<h5 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h5>

<%
if reqf("ProfissionalID")="" then
    erro = "Selecione ao menos um profissional"
end if
if reqf("Forma")="" and reqf("ConvenioID")="" then
    erro = "Selecione ao menos uma forma de faturamento (particular ou convênio)"
end if
if erro="" then

    Procedimentos = reqf("ProcedimentoID")
    if Procedimentos<>"" then
        splProcedimentos = split(Procedimentos, ", ")
        for k=0 to ubound(splProcedimentos)
            if instr(splProcedimentos(k), "G")>0 then
                limitarGrupos = limitarGrupos &", "& replace(replace(splProcedimentos(k), "G", ""), "|", "")
            else
                limitarProcedimentos = limitarProcedimentos &", "& replace(splProcedimentos(k), "|", "")
            end if
        next

        if limitarGrupos<>"" then
            limitarGrupos = right(limitarGrupos, len(limitarGrupos)-2)
            sqlLimitarGrupos = " GrupoID IN("& limitarGrupos &") "
        end if
        if limitarProcedimentos<>"" then
            limitarProcedimentos = right(limitarProcedimentos, len(limitarProcedimentos)-2)
            sqlLimitarProcedimentos = " id IN ("& limitarProcedimentos &") "
        end if
        if sqlLimitarGrupos<>"" and sqlLimitarProcedimentos<>"" then
            sqlOR = " OR "
        end if

        Procedimentos = ""
        set limProcs = db.execute("SELECT id FROM procedimentos WHERE NOT ISNULL(id) AND ("& sqlLimitarGrupos & sqlOR & sqlLimitarProcedimentos &")")
        while not limProcs.eof
            Procedimentos = Procedimentos & limProcs("id") &", "
        limProcs.movenext
        wend
        limProcs.close
        set limProcs=nothing
        if Procedimentos<>"" then
            Procedimentos = left(Procedimentos, len(Procedimentos)-2)
            'response.Write( Procedimentos )
            sqlProcedimentosParticular = " AND ii.ItemID IN ("& Procedimentos &") "
            sqlProcedimentosConvenioGC = " AND gc.ProcedimentoID IN ("& Procedimentos &") "
            sqlProcedimentosConvenioGS = " AND igs.ProcedimentoID IN ("& Procedimentos &") "
            sqlProcedimentosAtendimento = " AND ap.ProcedimentoID IN ("& Procedimentos &") "
        end if
    end if


    splU = split(reqf("Unidades"), ", ")
    for i=0 to ubound(splU)
	      Total = 0
	      set prof = db.execute("select p.*, u.id UsuarioID from profissionais p left join sys_users u on u.idInTable=p.id and `Table` like 'profissionais' where p.sysActive=1 and p.Ativo='on' "&sqlProf&" and p.id in("&reqf("ProfissionalID")&") order by p.NomeProfissional")
	      while not prof.eof
	  	    if isnull(prof("UsuarioID")) then
			    UsuarioID = 0
		    else
			    UsuarioID = prof("UsuarioID")
		    end if
		    if splU(i)="0" then
			    set un = db.execute("select NomeFantasia Nome from empresa")
		    else
			    set un = db.execute("select UnitName Nome from sys_financialcompanyunits where id="&splU(i))
		    end if
		    if un.EOF then
			    NomeUnidade = ""
		    else
			    NomeUnidade = un("Nome")
		    end if
        %>
        <div class="ProfissionalAnaliticoResultado">
        <%
        if UltimaUnidade<>NomeUnidade then
	          %>
		        <h4><%= ucase(NomeUnidade& " ") %></h4>
              <%
        end if
        UltimaUnidade=NomeUnidade


        nomeTabela = splU(i) &"_"& prof("id")


        tabelas = tabelas & "|" & nomeTabela
        %>

        <h5><%=ucase(prof("NomeProfissional"))%></h5>

        <%if reqf("AgruparConvenio")="S" then %>
            <!--#include file="rPMagrupadoConvenio.asp"-->
        <%else %>
            <!--#include file="rPMnaoagrupado.asp"-->
        <%end if %>


	  	        <%
		        Total = Total+Subtotal
		        TotalNovo = TotalNovo+SubtotalNovo
		        %>
                </div>
		        <%
	          prof.movenext
	          wend
	          prof.close
	          set prof = nothing
	          %>
        <%
    next
    %>
    <hr>

    <%
    if reqf("resumoProc")="S" then
    %>
    <table class="table table-striped table-bordered" width="100%">
      <thead>
  	    <tr>
    	    <th colspan="3">Resumo por Procedimento</th>
        </tr>
      </thead>
      <tbody>
	    <%
	    set res = db.execute("select distinct tf.ProcedimentoID, proc.NomeProcedimento, (select count(*) from tempfaturamento where ProcedimentoID=tf.ProcedimentoID and sysUser="&session("User")&") qtd, (select sum(valor) from tempfaturamento where sysUser="&session("User")&" and ProcedimentoID=tf.ProcedimentoID) total from tempfaturamento tf left join procedimentos proc on proc.id=tf.ProcedimentoID where not isnull(NomeProcedimento) and tf.sysUser="&session("User")&" order by proc.NomeProcedimento")
	    TotalProcs = 0
	    TotalProcsValor = 0
	    while not res.EOF
		    TotalProcs = TotalProcs+ccur(res("qtd"))
		    TotalProcsValor = TotalProcsValor+ccur(res("total"))
		    %>
		    <tr>
        	    <td><%=res("NomeProcedimento")%></td>
        	    <td class="text-right"><%=res("qtd")%></td>
        	    <td class="text-right">R$ <%=formatnumber(res("total"), 2)%></td>
            </tr>
		    <%
	    res.movenext
	    wend
	    res.close
	    set res=nothing
	    %>
      </tbody>
      <tfoot>
        <tr>
    	    <td><strong>TOTAL GERAL</strong></td>
            <td class="text-right"><strong><%=TotalProcs%></strong></td>
            <td class="text-right"><strong>R$ <%=formatnumber(TotalProcsValor, 2)%></strong></td>
        </tr>
      </tfoot>
    </table>
    <% End If %>
    <%
    if reqf("resumoConv")="S" then
    %>
    <table class="table table-striped table-bordered" width="100%">
      <thead>
  	    <tr>
    	    <th colspan="3">Resumo por Conv&ecirc;nio</th>
        </tr>
      </thead>
      <tbody>
	    <%
	    set res = db.execute("select distinct tf.ConvenioID, conv.NomeConvenio, (select count(*) from tempfaturamento where ConvenioID=tf.ConvenioID and sysUser="&session("User")&") qtd, (select sum(valor) from tempfaturamento where sysUser="&session("User")&" and ConvenioID=tf.ConvenioID) total from tempfaturamento tf left join convenios conv on conv.id=tf.ConvenioID where not isnull(NomeConvenio) and tf.sysUser="&session("User")&" order by conv.NomeConvenio")
	    TotalProcs = 0
	    TotalProcsValor = 0
	    while not res.EOF
		    TotalProcs = TotalProcs+ccur(res("qtd"))
		    TotalProcsValor = TotalProcsValor+ccur(res("total"))
		    %>
		    <tr>
        	    <td><%=res("NomeConvenio")%></td>
        	    <td class="text-right"><%=res("qtd")%></td>
        	    <td class="text-right">R$ <%=formatnumber(res("total"), 2)%></td>
            </tr>
		    <%
	    res.movenext
	    wend
	    res.close
	    set res=nothing

	    %>
      </tbody>
      <tfoot>
        <tr>
    	    <td><strong>TOTAL GERAL</strong></td>
            <td class="text-right"><strong><%=TotalProcs%></strong></td>
            <td class="text-right"><strong>R$ <%=formatnumber(TotalProcsValor, 2)%></strong></td>
        </tr>
      </tfoot>
    </table>
    <% End If %>

    <%if reqf("AgruparConvenio")="S" then %>
        <h5 class="text-right">Total Recebido: R$ <%=formatnumber(TotalRec, 2)%></h5>
        <h5 class="text-right">Total Faturado: R$ <%=formatnumber(TotalGeral, 2)%></h5>
    <%else %>
        <h5 class="text-right">
            Atendimentos: <%= TotalAtendimentos %>
            <br />
            Total: R$ <%=formatnumber(TotalGeral, 2)%>
        </h5>
    <%end if %>
<%else%>

<div class="alert alert-warning">
    Erro: <%=erro%>
</div>

<%end if%>







<script type="text/javascript">
    jQuery(function ($) {
        jQuery.extend( jQuery.fn.dataTableExt.oSort, {
        "date-uk-pre": function ( a ) {
            var ukDatea = a.split('/');
            return (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
        },

        "date-uk-asc": function ( a, b ) {
            return ((a < b) ? -1 : ((a > b) ? 1 : 0));
        },

        "date-uk-desc": function ( a, b ) {
            return ((a < b) ? 1 : ((a > b) ? -1 : 0));
        }
        } );

        <%
        splTabelas = split(tabelas, "|")
        for tb=1 to ubound(splTabelas)
        %>
        var oTable<%=tb%> = $('#t<%=splTabelas(tb)%>');
        if(oTable<%=tb%>.find("tbody").find("tr").length === 0){
            oTable<%=tb%>.parents(".ProfissionalAnaliticoResultado").css("display","none");
        }else{

            oTable<%=tb%>.dataTable( {
                aoColumns: [ null,null,{ "sType": "date-uk" }, null,null,null,null,null,null,null ],
                ordering: true,
                bPaginate: false,
                bLengthChange: false,
                bFilter: false,
                bInfo: false,
                bAutoWidth: false
            } );
        }$(document).ready(function() {

         });
        <%
        next
        %>
    })
</script>