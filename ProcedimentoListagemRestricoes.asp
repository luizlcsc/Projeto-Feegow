<!--#include file="connect.asp"-->
<!--#include file="Classes/Restricao.asp"-->
<!--#include file="modal.asp"-->
<%
ProcedimentoID  = req("ProcedimentoId")
PacientedId    = req("PacientedId")

splitProcedimentoID = split(ProcedimentoID,",")

for i=0 to UBound(splitProcedimentoID)

    sql = " SELECT DISTINCT 0 Conta, 1, 'Padrao' NomeProfissional, RestricaoID,                                                        "&chr(13)&_
    " r.Descricao, Tipo, ExcecaoID, RestricaoSemExcecao, prf.ProcedimentoID, pro.NomeProcedimento                                       "&chr(13)&_
    " FROM procedimentosrestricaofrase prf                                                                                              "&chr(13)&_
    " JOIN sys_restricoes r ON r.id = prf.RestricaoID  JOIN procedimentos pro ON pro.id = prf.ProcedimentoID                            "&chr(13)&_
    " WHERE prf.ProcedimentoID IN ("&splitProcedimentoID(i)&")  AND ExcecaoID = 0                                                               "&chr(13)&_
    " UNION                                                                                                                             "&chr(13)&_
    " SELECT Conta, 2, COALESCE(NomeSocial, NomeProfissional) NomeProfissional,                                                    "&chr(13)&_
    " RestricaoID, r.Descricao, Tipo, ExcecaoID, RestricaoSemExcecao, pre.ProcedimentoID , pro.NomeProcedimento                                               "&chr(13)&_
    " FROM procedimentosrestricaofrase prf                                                                                              "&chr(13)&_
    " JOIN procedimentosrestricoesexcecao pre ON pre.id = prf.excecaoid                                                                 "&chr(13)&_
    " JOIN profissionais p ON p.id = SUBSTRING_INDEX(pre.Conta,'_',-1)                                                                  "&chr(13)&_
    " JOIN sys_restricoes r ON r.id = prf.RestricaoID JOIN procedimentos pro ON pro.id = pre.ProcedimentoID                             "&chr(13)&_
    " WHERE prf.ProcedimentoID IN ("&splitProcedimentoID(i)&") "&where& "ORDER BY 2,3 " 

    set procedimentosExcecaoPadrao = db.execute(sql)
    exibeCabecalho = true
    ExcecaoIDAnterior = 0

    dim restricaoObj
    set restricaoObj = new Restricao

%>

<style>
    #tblRestricoes{
        border-collapse: collapse;
        width: 100%;
    }

    #tblRestricoes td, #tblRestricoes th {
        border: 0.5px solid #FDF0D4;
        padding: 8px;
    }

     #tblRestricoes tr:hover {background-color: #FEF5E2;}

    #tblRestricoes th {
        padding-top: 12px;
        padding-bottom: 12px;
        text-align: left;
        background-color: #F5B125;
        color: white;
    }

    tr.tbl-header {
  cursor: pointer;
}
</style>

<div class="row">

    <table id="tblRestricoes" style="background-color:white">
        <% while not procedimentosExcecaoPadrao.eof 
        profissional = Replace(procedimentosExcecaoPadrao("conta"),"5_","")
        
        set resultadoRestricao = restricaoObj.verificaRestricao(profissional, splitProcedimentoID(i), PacientedId, procedimentosExcecaoPadrao("RestricaoID"), "")
        Restringe = resultadoRestricao.item("resultado")
        SemExcecao = resultadoRestricao.item("semExcecao")

        set restricoesPaciente = restricaoObj.restricaoPaciente(PacientedId, splitProcedimentoID(i), profissional)
        totalRestricao = restricoesPaciente.item("resultado")

        sqlResposta = "SELECT RespostaMarcada, Resposta, Observacao FROM restricoes_respostas WHERE PacienteID = "&PacientedId&" AND RestricaoID = "&procedimentosExcecaoPadrao("RestricaoID")    

        set resp = db.execute(sqlResposta)

        If not resp.eof then
        
            Resposta = resp("Resposta")
            RespostaMarcada = resp("RespostaMarcada")
            RespostaObs = resp("Observacao")
            If RespostaMarcada <> "" and RespostaMarcada = "S" Then
                RespostaMarcada = "Sim"
            elseif RespostaMarcada <> "" and RespostaMarcada = "N" then
                RespostaMarcada = "Não"
            End if
        End if

        If ccur(procedimentosExcecaoPadrao("ExcecaoID")) = 0 and exibeCabecalho Then
            titulo = "Restrição Padrão "&"  "&procedimentosExcecaoPadrao("NomeProcedimento")
        else
            exibeCabecalho = true
            titulo = procedimentosExcecaoPadrao("nomeprofissional")

            If ccur(ExcecaoIDAnterior) = ccur(procedimentosExcecaoPadrao("ExcecaoID")) Then
                exibeCabecalho = false   
            End if
        End if

        if exibeCabecalho then
        %>

      <tr class="dark tbl-header">
        <th width="30%"><%=titulo%></th>
        <th> Resposta </th>
        <th>Observacao</th>
        <% If totalRestricao > 0 Then %>
            <th width="1%"><button type="button" class="btn btn-danger btn-xs" title="Restrição"><li class="fa fa-remove"></li></button></li></th>
        <% Else %>
            <th width="1%"><button type="button" class="btn btn-success btn-xs" title=""><li class="fa fa-check"></li></button></li></th>
        <% End if %>
        
      </tr>

        <% 
        end if 
            ExcecaoIDAnterior = procedimentosExcecaoPadrao("ExcecaoID")
            exibeCabecalho = false 
        %>
          <tr class="restricaoToggle">
            <td><%=procedimentosExcecaoPadrao("descricao")%></td>
            <% if RespostaMarcada <> "" then %>
                <td><%=RespostaMarcada%></td>
            <% else %>
                <td><%=Resposta%></td>
            <% end if %>
            
            <% if Restringe = "S" then %>
                <td><%=Resposta%></td>
                <td><button type="button" class="btn btn-danger btn-xs" title="Restrição"><li class="fa fa-remove"></li></button></li></td>
            <% else %>
                <td></td>
                <td><button type="button" class="btn btn-success btn-xs" title=""><li class="fa fa-check"></li></button></li></td>
            <% end if %>
             
          </tr>
        <% 
            procedimentosExcecaoPadrao.movenext  
            wend 
            procedimentosExcecaoPadrao.close
            set procedimentosExcecaoPadrao = nothing
        %>
    </table>
    <br>
    </div>
    <%
next
    %>

    <div id="modalPendenciasFooter" class="row">
        <div class="col-md-10"></div>
        <div id="divBtnVoltar" class="col-md-1 text-left" style="margin: 10px 0 0 0;">            
            <button type="button" class="btn btn-primary" id="btn-voltar">Voltar</button>        
        </div>

        <div id="divBtnSalvar" class="col-md-1 text-right" style="margin: 10px 0 0 0;">            
            <button type="button" class="btn btn-success" id="btn-salvar">Salvar</button>        
        </div>
    </div>

<script type="text/javascript">
    var pendencias = [];
    var $pendenciasSelecionadas = $("input[name='BuscaSelecionada2']:checked");
    $.each($pendenciasSelecionadas, function() {
        pendencias.push($(this).val())
    });

    $("#btn-salvar").click(function () {
        $(".modalpendencias2").modal("hide");
        AbrirPendencias(0, pendencias);
    });

    $("#btn-voltar").click(function () {
        $(".modalpendencias2").modal("hide");
        $(".modalpendencias").modal("show");
    });

    $(function(){
        $('.restricaoToggle').hide();

        $('tr.tbl-header').click(function() {
          $(this).find('span').text(function(_, value) {
            return value == '-' ? '+' : '-'
          });

          $(this).nextUntil('tr.tbl-header').slideToggle(100, function() {});
        });
    });
</script>