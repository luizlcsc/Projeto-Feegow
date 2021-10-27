<!--#include file="connect.asp"-->
<%
II = req("II")    
if ref("ScanProfissionalID")="" then
    erro = "Selecione um profissional."
end if
if erro<>"" then
%>
    $.gritter.add({
        title: '<i class="far fa-thumbs-down"></i> ERRO',
        text: '<%=erro%>',
        class_name: 'gritter-error gritter-light'
    });
<%else
    'atualiza o item invoice
    db_execute("update itensinvoice set Executado='S', ProfissionalID="&ref("ScanProfissionalID")&", DataExecucao=curdate(), Associacao=5 WHERE id="&II)

    'insere o compromisso na agenda com o status selecionado e a hora de chegada
    set pac = db.execute("select i.AccountID, ii.ItemID, (Quantidade*(ValorUnitario+Acrescimo-Desconto)) Valor from sys_financialinvoices i left join itensinvoice ii on ii.InvoiceID=i.id where ii.id="&II)
    if not pac.eof then
        db_execute("insert into agendamentos (PacienteID, ProfissionalID, Data, Hora, HoraSta, TipoCompromissoID, StaID, ValorPlano, rdValorPlano) values ("&pac("AccountID")&", "&ref("ScanProfissionalID")&", CURDATE(), CURTIME(), CURTIME(), "&treatvalzero(pac("ItemID"))&", "&req("StaID")&", "&treatvalzero( pac("Valor") )&", 'V')")
    end if

    session("UltimaAgenda") = ref("ScanProfissionalID")
    'redireciona para a agenda do profissional
    

    %>
    $.gritter.add({
        title: '<i class="far fa-save"></i> SALVANDO...',
        text: '<%=erro%>',
        class_name: 'gritter-success gritter-light'
    });

    location.href='./?P=Agenda-1&Pers=1';
<%end if %>