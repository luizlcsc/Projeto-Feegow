<!--#include file="connect.asp"-->
<%
PropostaID = req("I")

set prop = db.execute("select prop.*, pac.NomePaciente, pac.Email1, pac.Email2 from propostas prop LEFT JOIN pacientes pac on pac.id=prop.PacienteID where prop.id="&PropostaID)
set itens = db.execute("select i.*, p.NomeProcedimento from itensproposta i LEFT JOIN procedimentos p on p.id=i.ItemID where PropostaID="&PropostaID)
while not itens.eof
    DescItens = DescItens & "<h3>"& (itens("NomeProcedimento")&"") &": R$ "& fn(itens("ValorUnitario")-itens("Desconto")+itens("Acrescimo")) &" x "& itens("Quantidade") &"</h3>"
itens.movenext
wend
itens.close
set itens=nothing

Assunto = "Proposta Feegow Clinic"

Para = prop("Email1")
if instr(prop("Email2"), "@") then
    Para = Para &"; "& prop("Email2")
end if

set pema = db.execute("select Email from cliniccentral.licencasusuarios where id="&session("User"))

Mensagem = "Prezado(a) sr(a). "& prop("NomePaciente") & "<br><br>Conforme conversado, envio proposta para implementação do melhor e mais completo software do mercado.<br><br> Para quaisquer esclarecimentos, coloco-me inteiramente à disposição.<br><br>Atenciosamente, <br> "& session("NameUser")
%>

<%'=DescItens %>
<form id="frmEmail">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Enviar proposta</h4>
    </div>
    <div class="modal-body">
            <div class="clearfix form-actions no-margin">
                <%=quickfield("memo", "Para", "Para", 12, Para, "", "", " rows=1") %>
                <%=quickfield("text", "Assunto", "Assunto", 12, Assunto, "", "", "") %>
            </div>
            <div class="row"><br>
                <%=quickfield("editor", "Mensagem", " ", 12, Mensagem, "150", "", "") %>
            </div>

    </div>
    <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
        <button class="btn btn-primary"><i class="far fa-paper-plane"></i> Enviar</button>
    </div>
</form>

<script type="text/javascript">
    $("#frmEmail").submit(function(){
        $.post("pdf/GeraPDF.php?F=PropostaFeegowClinic_<%=PropostaID%>", {
            Para: $("#Para").val(),
            Assunto: $("#Assunto").val(),
            Mensagem: $("#Mensagem").val(),
            NomeCliente: '<%=prop("NomePaciente")%>',
            NomeProp: '<%=session("NameUser")%>',
            EmailProp: '<%=pema("Email")%>',
            DescItens: '<%=DescItens%>',
            ValTotal: 'R$ <%=fn(prop("Valor"))%>',
            FotoProp: '<%=session("Photo")%>',
            PacienteID: '<%=prop("PacienteID")%>',
            User: '<%=session("User")%>',
            B: '<%=session("banco")%>'
        }, function(data){
            eval(data);
        });
        return false;
    });

<!--#include file="jQueryFunctions.asp"-->
</script>