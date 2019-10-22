<!--#include file="connect.asp"-->
<%

'aqui transforma um pedido em proposta

if ref("GerarProposta") = "S" and ref("idsExames[]")<>"" then
    idsExamesSplt = split(ref("idsExames[]"),",")

    GRUPOID = " NULL "

    IF getconfig("DesmembrarPropostas") = "1" THEN
        GRUPOID = " GrupoID "
    END IF

    sqlPacote = "SELECT group_concat(CONCAT('|',procedimentos.id,'|'))  as procedimentos,"&GRUPOID&" as pacote FROM procedimentos"&_
                " WHERE procedimentos.id IN ("&ref("idsExames[]")&") "&_
                " GROUP BY 2;"

    set Pacotes =  db.execute(sqlPacote)

    if ubound(idsExamesSplt) >= 0 then
        while NOT Pacotes.EOF

            'sqlSomaProcedimentos = "SELECT SUM(Valor)ValorTotal FROM procedimentos WHERE id IN ("&ref("idsExames[]")&")"
            'set SomaProcedimentosSQL = db.execute(sqlSomaProcedimentos)

            ValorTotal = 0
            sqlProposta = "INSERT INTO propostas (PacienteID,Valor,UnidadeID,StaID,TituloItens,TituloOutros,TituloPagamento,sysActive,sysUser,DataProposta, ProfissionalID)"&_
                          " VALUES ("&ref("PacienteID")&", "&treatvalzero(ValorTotal)&", '"&session("UnidadeID")&"' ,1,'Exames','Outras Despesas','Forma de Pagamento',1,'"&session("User")&"', CURDATE(), "&session("idInTable")&")"
            db_execute(sqlProposta)

            set PropostaSQL = db.execute("SELECT id FROM propostas ORDER BY id DESC LIMIT 1")
            PropostaID = PropostaSQL("id")

            for i=0 to ubound(idsExamesSplt)
                IF instr(Pacotes("procedimentos"), "|"&TRIM(idsExamesSplt(i))&"|")>0 THEN
                    set ProcedimentoSQL = db.execute("SELECT id,Valor FROM procedimentos WHERE id="&idsExamesSplt(i))
                    ValorTotal = ValorTotal + ProcedimentoSQL("Valor")

                    sqlItensProposta = "INSERT INTO itensproposta (PropostaID, Tipo, Quantidade, CategoriaID, ItemID,ValorUnitario,Desconto,TipoDesconto,sysUser,ProfissionalID) "&_
                                       " VALUES ('"&PropostaID&"', 'S', 1, 0, "&ProcedimentoSQL("id")&", "&treatvalzero(ProcedimentoSQL("Valor"))&",0,'V',"&session("User")&", "&session("idInTable")&")"
                    db_execute(sqlItensProposta)
                END IF
            next
            db.execute("UPDATE propostas SET Valor="&treatvalzero(ValorTotal)&" WHERE id = "& PropostaID)
        Pacotes.movenext
        wend
        Pacotes.close
    end if
end if

set reg = db.execute("select * from PacientesPedidos where PedidoExame like '"&ref("pedido")&"' and PacienteID="&ref("PacienteID")&" and date(Data)='"&mydate(date())&"'")

exameNovo = FALSE

IF NOT reg.EOF AND ref("idsExames[]") <> "" THEN
    sql = "select count(*) as exameNovo from procedimentos where id in ("&ref("idsExames[]")&")"&_
          " AND id not in ((SELECT ProcedimentoID FROM pedidoexameprocedimentos WHERE PedidoExameID = "&reg("id")&"))"


    set regExameNovo = db.execute(sql)

    exameNovo = (regExameNovo("exameNovo")) > "0"
END IF


if reg.EOF OR exameNovo then

    'inclusão do atendimentoID se houver atendimento em curso
    'verifica se tem atendimento aberto
    set atendimentoReg = db.execute("select * from atendimentos where PacienteID="&ref("PacienteID")&" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
    if atendimentoReg.EOF then
	    db_execute("insert into PacientesPedidos (PacienteID, PedidoExame, sysUser) values ("&ref("PacienteID")&", '"&ref("pedido")&"', "&session("User")&")")
    else
        'salva com id do atendimento
        db_execute("insert into PacientesPedidos (PacienteID, PedidoExame, sysUser, AtendimentoID) values ("&ref("PacienteID")&", '"&ref("pedido")&"',  "&session("User")&", "&atendimentoReg("id")&")")
    end if
	set reg = db.execute("select * from pacientesPedidos where PacienteID="&ref("PacienteID")&" order by id desc")
end if

if ref("idsExames[]")<>"" then
    idsExamesSplt = split(ref("idsExames[]"),",")
    examesObsSplt = split(ref("examesObs[]"),",")

    db_execute("DELETE FROM pedidoexameprocedimentos WHERE PedidoExameID="&reg("id"))
    on error resume next

    for i=0 to ubound(idsExamesSplt)
        ProcedimentoID = idsExamesSplt(i)
        PedidoID=reg("id")

        if TypeName(examesObsSplt(i)) <> "Nothing" then
            Obs=examesObsSplt(i)
        else
            Obs=""
        end if

        db_execute("INSERT INTO pedidoexameprocedimentos (ProcedimentoID,PedidoExameID,Observacoes) VALUES ("&ProcedimentoID&", "&PedidoID&", '"&Obs&"')")
    next
end if

recursoPermissaoUnimed = recursoAdicional(12)
%>
<div class="modal-body">
    <div class="row">
        <div class="col-md-10">
        <%
			src="PedidoExame.asp?PedidoID="&reg("id")
		%>
        <%
        if getConfig("UtilizarFormatoImpressao")=1 or recursoPermissaoUnimed=4  then
        'if session("Banco")="clinic6273" or session("Banco")="clinic6006" or session("Banco")="clinic6256" or session("Banco")="clinic1526" or recursoPermissaoUnimed=4 then
        %>
        <object style="width:100%; height: 600px;" id="ImpressaoPedido" width="800" data="" type="text/html"></object>
        <%
        else
        %>
        <iframe width="100%" height="600px" src="<%=src%>" id="ImpressaoPedido" name="ImpressaoPedido" frameborder="0"></iframe>
        <%
        end if
        %>
        </div>
        <div class="col-md-2">
            <label><input type="checkbox" id="Carimbo" name="Carimbo" class="ace" checked="checked" onclick="window.frames['ImpressaoPedido'].Carimbo(this.checked);" />
                <span class="lbl"> Carimbar</span>
            </label>
            <hr />
            <button class="btn btn-sm btn-success btn-block" data-dismiss="modal">
                <i class="fa fa-remove"></i>
                Fechar
            </button>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">


</div>
<script type="text/javascript">
    <%
        if getConfig("UtilizarFormatoImpressao")=1 or recursoPermissaoUnimed=4  then
        'if session("Banco")="clinic6273" or session("Banco")="clinic6006" or session("Banco")="clinic6256" or session("Banco")="clinic1526" or recursoPermissaoUnimed=4 then
    %>
        visualizarImpressao();
        //var url = domain+"print/medical-certificate/<%=reg("id")%>&tk="+localStorage.getItem("tk");
        //console.log(url)
        //$("#ImpressaoPedido").prop("data", url);
    <%
    end if
    %>
    $(".exame-procedimento-content:eq(0)").css("display", "none");
    pront('timeline.asp?PacienteID=<%=ref("PacienteID")%>&Tipo=|Pedido|');

    function visualizarImpressao(){
        var timbrado = 1;

        var url = domain+"print/exam-request/<%=reg("id")%>?tk="+localStorage.getItem("tk")+"&showPapelTimbrado="+timbrado;
        console.log(url)
        $("#ImpressaoPedido").prop("data", url);
    }

    $("#btnVisualizar").click(function(){
        visualizarImpressao();
});



</script>