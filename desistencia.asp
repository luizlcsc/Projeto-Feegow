<!--#include file="connect.asp"-->
<%
Acao = ref("A")
Motivo = ref("Motivo")
Obs = ref("Obs")
PacienteID = req("PacienteID")
sessaoAgenda = req("sessaoAgenda")

if Acao = "E" then
sessaoAgenda = ref("sessaoAgenda")
itens = ""
PacienteID = ref("PacienteID")
msg = ""
sql = "select * from agendacarrinho where Arquivado IS NULL AND sysUser = "&Session("User")&" AND sessaoAgenda ='"&sessaoAgenda&"' order by id desc"

idCarrinho = 0
idscarrinho = "0"
set AgendamentoSQL = db.execute(sql)
if not AgendamentoSQL.eof then
    while not AgendamentoSQL.eof  
        IDAgendamento = AgendamentoSQL("AgendamentoID")
        idCarrinho = AgendamentoSQL("id")
        idscarrinho = idscarrinho & "," & AgendamentoSQL("id") 
        itens = itens & "," & AgendamentoSQL("ProcedimentoID")

        'sqlAgendamento = "SELECT * FROM agendamentos where id = " & IDAgendamento & " AND StaID NOT IN(7,1,3,2,5)"
        if IDAgendamento&"" <> "" then 
            sqlAgendamento = "SELECT * FROM agendamentos where id = " & IDAgendamento
            set AgendamentoCancelado = db.execute(sqlAgendamento)
            if not AgendamentoCancelado.eof then    
                Hora=formatdatetime(AgendamentoCancelado("Hora"),4)
                sqlLogMarcacao = "insert into logsmarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora,  Sta, Usuario, Motivo, Obs, ARX, ConsultaID, UnidadeID) values(" &_
                    " " &PacienteID& ", "&AgendamentoCancelado("ProfissionalID")&", "&AgendamentoSQL("ProcedimentoID")&", now(), " & mydatenull(AgendamentoCancelado("Data")) & ", '" & Hora & "', "&AgendamentoCancelado("StaID")&", " & session("User") &"," &_
                    " " & Motivo & ", '"& Obs &"', 'X', " & IDAgendamento & ", " & treatvalnull(session("Unidade")) & ")"
                
                db.execute(sqlLogMarcacao)    
                db.execute("UPDATE agendamentos SET StaID=11 WHERE id="&IDAgendamento)
                msg = "Agendamento cancelado"
            else 
                msg = "Não existem agendamentos para este paciente"
            end if
        end if

        AgendamentoSQL.movenext
    wend

    set resMotivo = db.execute("select motivo from motivosreagendamento where id = "&Motivo)
    obsInterna = "Motivo de exclusão: "&resMotivo("motivo")&" &NewLine; Observação: "&Obs&"&NewLine;"

    sqlSave = "insert into propostas(PacienteID, Valor, UnidadeID, StaID, TituloItens, sysActive, sysUser, DataProposta, ProfissionalID, Internas) values ("&PacienteID&",0,"& treatvalnull(session("Unidade")) & ",1,'', 1, "&session("User")&" ,now(),null, '"&obsInterna&"')"

    db_execute(sqlSave)

    sqlLastProposta = "select id from propostas where sysActive = 1 and sysUser = "&session("User")&" order by id desc limit 1"
    
    set rsProposta = db.execute(sqlLastProposta)
    if not rsProposta.eof then
        totalValor = 0
        todosItens = Split(itens,",")
        for i=0 to ubound(todosItens)
            novoItem = todosItens(i)

            if novoItem <> "" then 

                valorProcedimento = calcValorProcedimento(novoItem, "", "", "", "", "", "")
                totalValor = totalValor + valorProcedimento

                sqlInsert = "insert into itensproposta (PropostaID , Ordem, Prioridade, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto,TipoDesconto, Descricao, " &_
                " Executado, DataExecucao, HoraExecucao, AgendamentoID, sysUser, ProfissionalID, HoraFim, Acrescimo, AtendimentoID) values ("&rsProposta("id")&", 0,1,'S', 1, 0, " &_ 
                " "&novoItem&", "& treatvalzero(valorProcedimento) &", 0, 'V', '', '', null, null, 0, "&session("User")&", null, null, 0, null)"

                db_execute(sqlInsert)


            end if
        next

        sqlAt = "update propostas set Valor = "&treatvalzero(totalValor)&" where id = " &rsProposta("id")
        
        db_execute(sqlAt)
    end if

else
    msg = "Não existem agendamentos para este paciente"
end if
%>
showMessageDialog("<%=msg%>", "success")
    let stringParam = "";
    var PacienteID = <%=PacienteID%>
    var idCarrinho = <%=idCarrinho%>
    if (PacienteID != "" && PacienteID != "-1"){
        stringParam += "&I="+PacienteID;
    }

    if (idCarrinho != "" && idCarrinho != 0){
        stringParam += "&Carrinho="+idCarrinho;
    }
    Limpar(100)

<% 
    response.end() 
    end if
%>

<%

set rsMotivos = db.execute("select * from motivosreagendamento where sysActive = 1 order by Motivo ")

%>

<div class="row">
    <div class="col-md-7">
        <input type="hidden" value="1" name="StatusID">
        <div class="col-md-12">
            <div class="row">
                <div class="col-md-12">
                    <label for="Motivo">Motivo de exclusão</label>
                    <select name="Motivo" id="Motivo" required class="form-control">
                        <option value=""></option>
                        <% if not rsMotivos.eof then 
                            while not rsMotivos.eof 
                        %>
                            <option value="<%=rsMotivos("id") %>"><%=rsMotivos("Motivo") %></option>
                        <%
                                rsMotivos.movenext
                            wend
                        end if %>
                    </select>
                </div>
            </div>
        </div>

        <div class="col-md-12">
            <div class="row">
                <div class="col-md-12">
                    <label for="Obs">Observação</label>
                    <textarea name="Obs" id="Obs" class="form-control"></textarea>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
get$ComponentsForm().unbind().submit(function() {
//$("#btnenviar").on('click', function(){
    $.post('desistencia.asp', {
        A : "E",
        Motivo : $("#Motivo").val(),
        Obs : $("#Obs").val(),
        PacienteID : <%=PacienteID%>,
        sessaoAgenda : <%=sessaoAgenda%>

    },
    function(data){
        eval(data)
        //showMessageDialog("Pendência excluída", "success")
        //location.reload();
    });
    return false;
});
<!--#include file="jQueryFunctions.asp"-->
</script>