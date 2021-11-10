<!--#include file="connect.asp"-->
<%
I = req("i")
PacienteID = req("p")
if I="" then
    set pult = db.execute("select id from pedidossadt where sysActive=0 and sysUser="& session("User") &" order by id desc limit 1")
    if pult.eof then

    'inclusão do atendimentoID se houver atendimento em curso
    'verifica se tem atendimento aberto
    set atendimentoReg = db.execute("select * from atendimentos where PacienteID="& PacienteID &" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
    if(atendimentoReg.EOF) then
        db_execute("insert into pedidossadt (PacienteID, sysUser, sysActive) values ("& PacienteID &", "& session("User") &", 0)")
    else
        'salva com id do atendimento
        db_execute("insert into pedidossadt (PacienteID, sysUser, sysActive, AtendimentoID) values ("& PacienteID &", "&session("User")&", 0 , "& atendimentoReg("id") &")")
    end if

        set pult = db.execute("select id from pedidossadt where sysActive=0 and sysUser="& session("User") &" order by id desc limit 1")
        I = pult("id")
    else
        I = pult("id")
        db_execute("update pedidossadt set PacienteID="& PacienteID &" where id="& I)
        db_execute("delete from pedidossadtprocedimentos where PedidoID="& I)
    end if
end if

if ref("Codigo")<>"" then
    set conta = db.execute("select count(id) total from pedidossadtprocedimentos where PedidoID="& I)
    total = ccur(conta("total"))
    if total<26 then
        if total=0 then
            sqlUp = "update pedidossadt set PacienteID="& PacienteID &", sysUser="& session("User") &", sysActive=1, sysDate=now() where id="& I
            'response.write( sqlUp )
            db.execute( sqlUp )
        end if
        refDescricao = ref("descricao")
        if refDescricao<>"" then
            Descricao = "'"&refDescricao&"'"
        else
            Descricao = "(select descricao from cliniccentral.procedimentos where TipoTabela='"& ref("Tabela") &"' AND Codigo='"& ref("Codigo") &"' LIMIT 1)"
        end if

        db_execute("insert into pedidossadtprocedimentos set PedidoID="& I &", TabelaID="& ref("Tabela") &", CodigoProcedimento='"& ref("Codigo") &"', Quantidade='1', Descricao="&Descricao&" ")
    else
        %>
        <div class="alert alert-danger">
            O máximo de permitido por guia é de 25 (cinco) procedimentos. Para inserir uma quantidade maior, crie uma nova guia de solicitação.
        </div>
        <%
    end if
end if

if ref("X")<>"" then
    db_execute("delete from pedidossadtprocedimentos where id="& ref("X"))
end if
%>
<input type="hidden" name="PedidoSADTID" id="PedidoSADTID" value="<%= I %>" />

<table class="table table-condensed">
    <thead>
        <tr class="primary">
            <th width="10%">Código</th>
            <th width="10%">Grupo</th>
            <th width="80%">Descrição</th>
            <th width="5%">Qte</th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
        <%
        set pprocs = db.execute("select * from pedidossadtprocedimentos pp LEFT JOIN procedimentos p on p.Codigo=pp.CodigoProcedimento LEFT JOIN procedimentosgrupos pg ON pg.id=p.GrupoID where PedidoID="& I)
            while not pprocs.eof
                %>
                <tr>
                <input hidden id="idPedidoSADT" value="<%= pprocs("id") %>">
                    <td><%= pprocs("CodigoProcedimento") %></td>
                    <td><%= pprocs("NomeGrupo") %></td>
                    <td><%= pprocs("Descricao") %></td>
                    <td><%= quickfield("number", "Quantidade_"&pprocs("id"), "", 1, pprocs("Quantidade"), " quantidade", "", "") %></td>
                    <td>
                        <button onclick="xPedidoSADT(<%= pprocs("id") %>)" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button>
                    </td>
                </tr>
                <%
            pprocs.movenext
            wend
            pprocs.close
            set pprocs=nothing
            %>
    </tbody>
</table>
<br>
<script>

$(".quantidade").on("change", function() {
    let value = $(this).val();
    let id = $(this).attr("id").split("_")[1];
    $.post("savePedidoSADT.asp", {
        Tipo: "U",
        Quantidade: value,
        pedidoSADTProcedimentosID: id
    });

})
</script>
