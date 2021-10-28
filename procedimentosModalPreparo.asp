<!--#include file="connect.asp"-->
<%
ProcedimentoID  = req("ProcedimentoId") 
ProfissionalIDq = req("ProfissionalID")
PacientedIdq    = req("PacientedId")
ExcecaoID       = req("ExcecaoID")
Requester       = req("requester")
AgendamentoID   = req("agendamentoID")
CriarPendencia  = req("criarPendencia")&""

IF NOT Request.Form("preparos") = "" THEN
    IF NOT PacientedIdq > 0 THEN
    %>
        new PNotify({
            title: 'ERRO!',
            text: 'Não foi possível selecionar o paciente',
            type: 'danger',
            delay: 2500
        });
    <%
    response.end
    END IF

    preparos = Request.Form("preparos")
    SQL = "INSERT INTO preparos_respostas(PacienteID, PreparoID, RespostaMarcada, Resposta, sysUser, sysActive, sysDate, DHUp)"&_
          "SELECT "&PacientedIdq&",sys_preparos.id,'S','',"&session("User")&",TRUE,NOW(),NULL FROM sys_preparos WHERE id  in ("&preparos&")"

    db.execute(SQL)
    %>
    new PNotify({
        title: 'Sucesso!',
        text: 'Preparos cadastrados com sucesso.',
        type: 'success',
        delay: 2500
    });
    <%
    response.end
else
%>
<div class="row">
    <div class="col-md-12">
        <%
            if ProfissionalID <> "" then
                where = " SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalID&" AND "
            else
                where = " "
            end if
            sql_exec = "SELECT DISTINCT r.id AS preparoId, prf.id, Descricao, Tipo, Horas, Dias, Inicio, Fim, FALSE AS Restringir,  ( "&_
                " SELECT prf2.ExcecaoID "&_
                " FROM procedimentospreparofrase prf2 "&_
                " WHERE prf2.preparoID = prf.preparoID AND ProcedimentoID IN ("&ProcedimentoID&") AND (ExcecaoID IN (( "&_
                " SELECT id "&_
                " FROM procedimentospreparosexcecao "&_
                " WHERE SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalIDq&" AND ProcedimentoID IN ("&ProcedimentoID&"))) OR ExcecaoID = 0) "&_
                " ORDER BY 1 DESC "&_
                " LIMIT 1) ExcecaoID "&_
                " FROM procedimentospreparofrase prf "&_
                " JOIN sys_preparos r ON r.id = prf.PreparoID "&_
                " WHERE ProcedimentoID IN ("&ProcedimentoID&") AND (ExcecaoID IN (( "&_
                " SELECT id "&_
                " FROM procedimentospreparosexcecao "&_
                " WHERE SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalIDq&" AND ProcedimentoID IN ("&ProcedimentoID&"))) OR ExcecaoID = 0) "&_
                " ORDER BY 10,3 "
 
            set procedimentosExcecaoPadrao = db.execute(sql_exec)
        %>

        <% if procedimentosExcecaoPadrao.eof = true then  %>
        <div class="col-md-12" style="margin: 10px 0 0 0;">            
            <div class="alert alert-warning" role="alert">
                Não existem preparos para esse procedimento
            </div>
            <% if Requester = "AgendaMultipla" then %>
                <script>
                    $(function(){
                        //enviar();
                    });
                </script>
                <button type="button" class="btn btn-primary btn-salvar" id="avancar">Avançar</button>
            <% end if %>
        </div>
        <% response.end %>    
        <% end if %>
        <form id="procedimentos_restricoes_form">
        <input type="hidden" id="irParaPendencia" value="<%=CriarPendencia%>">        
        <table class="table table-condensed table-bordered table-hover table-striped">

        <% 
        
            exibeCabecalho = true
            ExcecaoIDAnterior = 0

        while not procedimentosExcecaoPadrao.eof 
        
            if ccur(procedimentosExcecaoPadrao("ExcecaoID")) = 0 and exibeCabecalho then
                titulo = "padrão"
            elseif ccur(procedimentosExcecaoPadrao("ExcecaoID")) > 0 then

                if ccur(ExcecaoIDAnterior) = 0 then

                        exibeCabecalho = true
                        titulo = "do profissional"
                end if
            end if

            if exibeCabecalho then
%>
                <thead>
                    <tr class="dark">
                        <th width="30%">
                            <%="Preparos "&titulo%>
                        </th>
                        <th>
                            Valor
                        </th>
                    </tr>
                </thead>
<%
                end if

                ExcecaoIDAnterior = procedimentosExcecaoPadrao("ExcecaoID")
                exibeCabecalho = false 
%>
            <tbody>
                <tr>
                    <td>
                        <div style="display: flex;width: 24px">
                            <div class="checkbox-custom checkbox-alert"><input type="checkbox" name="Selecionado_<%=procedimentosExcecaoPadrao("id")%>"
                             id="Selecionado_<%=procedimentosExcecaoPadrao("id")%>" value="<%=procedimentosExcecaoPadrao("id")%>"><label for="Selecionado_<%=procedimentosExcecaoPadrao("id")%>" class="checkbox"></label></div>
                        </div>
                    </td>
                    <td>
                        <label style="padding-top: 10px" for="Selecionado_<%=procedimentosExcecaoPadrao("id")%>">
                            <%=procedimentosExcecaoPadrao("Descricao")%>
                            <% if procedimentosExcecaoPadrao("Tipo") = 2 then %>
                                <strong><%=" ("&procedimentosExcecaoPadrao("Inicio")&"≤x≤"&procedimentosExcecaoPadrao("Fim")&")" %></strong>
                            <% end if %>
                            <% if procedimentosExcecaoPadrao("Tipo") = 3 then %>
                                :<strong> <%=procedimentosExcecaoPadrao("Dias") %> Dias</strong>
                            <% end if %>
                            <% if procedimentosExcecaoPadrao("Tipo") = 4 then %>
                                :<strong> <%=procedimentosExcecaoPadrao("Horas") %> Horas</strong>
                            <% end if %>
                        </label>
                    </td>
                </tr>
            </tbody>
         
        <% procedimentosExcecaoPadrao.movenext %>
        <% wend %> 
        </table>  
        <form>        
    </div>
</div>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->

$(function(){ $("#avancar").on('click', function(){
        enviar();
        $('.modal').modal('hide');
    }) 
 })

function persistProcedimentosPreparosFunction(){
    let ProcedimentoID = '<%= ProcedimentoID%>';
    let PacientedIdq   = '<%= PacientedIdq%>';
    let ExcecaoID      = '<%= ExcecaoID%>';
    let selecionados = [];
    jQuery("[name^=Selecionado_]").each((a,b) => {
        selecionados.push(b.value);
    });

    selecionadosStr = selecionados.join(",")

   $.post(`procedimentosModalPreparo.asp?ProcedimentoID=${ProcedimentoID}&PacientedId=${PacientedIdq}&ExcecaoID=${ExcecaoID}&`, `preparos=${selecionadosStr}`, function (data) { 
       if($("#irParaPendencia").val() == "Sim") {

            $("#irParaPendencia").val("Nao");
            closeComponentsModal();

            var pendencias = [];
            var $pendenciasSelecionadas = $("input[name='BuscaSelecionada']:checked");

            $.each($pendenciasSelecionadas, function() {
                pendencias.push($(this).val())
            });
            $(".modal").modal("hide");
            AbrirPendencias(0, pendencias)
        } else if ($("#irParaPendencia").val() == "Nao") {
        
        } else {
            $(".modal").modal("hide");
            abrirAgenda2()    
        }
       eval(data) 
    });
}

$(document).ready(function(){
    jQuery("[name^=Selecionado_]").click(function(){

        let quantidade = jQuery("[name^=Selecionado_]:not(:checked)").length;

        $('#persistProcedimentosPreparos').remove();

        if(quantidade === 0){
            //Tem que corrigir esse modal. Instrução duplicada para aparecer o botão
            if($('#persistProcedimentosPreparos').length == 0) {
                $('<button style="display:none" type="button" class="btn btn-success btn-salvar" id="persistProcedimentosPreparos" onclick="persistProcedimentosPreparosFunction()">Salvar</button>').appendTo('.modal-footer')
                $('<button type="button" class="btn btn-success btn-salvar" id="persistProcedimentosPreparos" onclick="persistProcedimentosPreparosFunction()">Salvar</button>').appendTo('.modal-footer')
                
            }
        }

        if(quantidade < 1){
            $('#persistProcedimentosPreparos').remove();
        }
    })
})
</script>
<%
end if
%>