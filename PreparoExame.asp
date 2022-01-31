<!--#include file="connect.asp"-->
<div class="container" style="width:100%; border:1px solid #f0f0f0;padding:15px">

    <div class="modal-body">
        <h2><strong>Informe de Preparo</strong></h2>
        <%
            param = ref("param")
            pacienteID = ref("pacienteID")

            splitParam = split(param,"-")

            temProcedimento = 0
            temPreparoPadrao = 0

            for i=0 to UBound(splitParam)

                splitConteudo = split(splitParam(i),"|")
                
                'FornecedorID = splitConteudo(0)
                profissionaisselecionados = splitConteudo(0)
                IDSProcedimentos = splitConteudo(1)
                parProfissionaID = replace(profissionaisselecionados,"5_","")

                if IDSProcedimentos&""="" or parProfissionaID&""="" then
                  %>
                  <script>
                      showMessageDialog("Nenhum profissional executante \n foi selecionado.", 'warning');
                  </script>
                  <%
                  response.end
                end if
                
                'set executor = db.execute("SELECT NomeFornecedor FROM fornecedores WHERE id = "&FornecedorID)
                set profissional = db.execute("SELECT COALESCE(NomeSocial, NomeProfissional) NomeProfissional FROM profissionais WHERE id = "&parProfissionaID)
        %>
        <div class="page-header preparopadrao">
            <strong>EXECUTANTE:</strong>
            <a href="#"><%=profissional("NomeProfissional")%></a>
        </div>
        <%
            Excecao = ""

            sqlPreparo = "SELECT prep.Descricao DescricaoPreparo, "&_
                        "CONCAT (COALESCE(ppf.Horas, ppf.Dias),' ',(CASE WHEN Horas > 1 OR Dias > 1 THEN CONCAT(pt.Tipo,'s') ELSE pt.Tipo END)) PreparoTexto, "&_
                        "prep.id AS PreparoID, ppf.Horas, ppf.Dias, " &_
                        "ppf.ExcecaoID, "&_
                        "p.NomeProcedimento, "&_
                        "ppf.id, "&_
                        "ppf.Inicio, "&_
                        "ppf.Fim, "&_
                        "p.NomeProcedimento "&_
                        "FROM sys_preparos prep "&_
                        "INNER JOIN procedimentospreparofrase ppf ON ppf.PreparoID = prep.id "&_
                        "INNER JOIN procedimentos p ON p.id = ppf.ProcedimentoID "&_
                        "INNER JOIN cliniccentral.preparostipo pt ON pt.id = prep.Tipo "&_
                        "WHERE prep.sysActive = 1  "&_
                        "AND ppf.ProcedimentoID IN (" & IDSProcedimentos & ")"

            set preparos = db.execute(sqlPreparo)

            Set maioresPreparos = Server.CreateObject("Scripting.Dictionary")
            if not preparos.eof then

                'PREPARAÇÃO DOS DADOS =========================================================================
                line = 0
                temProcedimento = 1
                temPreparoPadrao = 0
                while not preparos.eof

                    if preparos("ExcecaoID") = 0 then

                        temPreparoPadrao = 1

                        preparoId = cstr(preparos("PreparoID"))

                        if not maioresPreparos.Exists(preparoId) then
                            set maioresPreparos.item(preparoId) = Server.CreateObject("Scripting.Dictionary")
                            maioresPreparos.item(preparoId).item("line") = line
                            maioresPreparos.item(preparoId).item("value") = 0
                        end if

                        maiorPreparo = maioresPreparos.item(preparoId).item("value")

                        if preparos("Dias") > 0 and preparos("Dias") * 24 > maiorPreparo then
                            maioresPreparos.item(preparoId).item("line")  = line
                            maioresPreparos.item(preparoId).item("value") = preparos("Dias") * 24
                        elseif preparos("Horas") > 0 and preparos("Horas") > maiorPreparo then
                            maioresPreparos.item(preparoId).item("line")  = line
                            maioresPreparos.item(preparoId).item("value") = preparos("Horas")
                        end if

                    else
                        Excecao = Excecao & preparos("ExcecaoID") & ","
                    end if
                    
                    line = line + 1
                    preparos.movenext
                wend
                preparos.movefirst

                if Excecao <> "" then
                    Excecao = Excecao + "0"

                    sqlPreparoExcecao = "SELECT *, prep.id AS PreparoID, ppf.Horas, ppf.Dias, " &_
                                        "prep.Descricao as DescricaoPreparo FROM sys_preparos prep " &_
                                        "INNER JOIN procedimentospreparofrase ppf ON ppf.PreparoID = prep.id  " &_
                                        "INNER JOIN procedimentospreparosexcecao ppe ON ppe.id = ppf.ExcecaoID  " &_
                                        "INNER JOIN procedimentos p ON p.id = ppf.ProcedimentoID " &_
                                        "WHERE prep.sysActive = 1 " &_ 
                                        "AND ppe.id in (" & Excecao & ") " &_
                                        "AND ppe.Conta in ('" & profissionaisselecionados & "') "

                    set execoes = db.execute(sqlPreparoExcecao)

                    if not execoes.eof then
                        temProcedimento = 1
                        while not execoes.eof

                            preparoId = cstr(execoes("PreparoID"))

                            if not maioresPreparos.Exists(preparoId) then
                                set maioresPreparos.item(preparoId) = Server.CreateObject("Scripting.Dictionary")
                                maioresPreparos.item(preparoId).item("line") = line
                                maioresPreparos.item(preparoId).item("value") = 0
                            end if

                            maiorPreparo = maioresPreparos.item(preparoId).item("value")

                            if execoes("Dias") * 24 > maiorPreparo then
                                maioresPreparos.item(preparoId).item("line")  = line
                                maioresPreparos.item(preparoId).item("value") = execoes("Dias") * 24
                            elseif execoes("Horas") > maiorPreparo then
                                maioresPreparos.item(preparoId).item("line")  = line
                                maioresPreparos.item(preparoId).item("value") = execoes("Horas")
                            end if

                            line = line + 1
                            execoes.movenext
                        wend
                        execoes.movefirst 
                    end if
                end if
                'FIM DA PREPARAÇÃO DOS DADOS =========================================================================
        %>
        
                <strong>PONTOS PRINCIPAIS DE INFORMAÇÃO:</strong>
                <span>(Resultado maior deste executante)</span>
                <% 
                    line = 0
                    if temPreparoPadrao = 1 then 
                %>
                <table class="table table-bordered preparopadrao" style="width:40vw;">
                    <tr>
                        <th>PROCEDIMENTO</th>
                        <th>PREPARO/RESTRIÇÃO/INFORMAÇÃO</th>
                        <th>INFORMAÇÃO/VALOR</th>
                    </tr>
                <%
                    end if
                    while not preparos.eof
                        
                        if temPreparoPadrao = 1 and preparos("ExcecaoID") = 0 then
                            classe = ""

                            preparoId = cstr(preparos("PreparoID"))

                            if maioresPreparos.Exists(preparoId) and maioresPreparos.item(preparoId).item("line") = line and maioresPreparos.item(preparoId).item("value") > 0 then
                                classe = " class='alert-warning'"
                            end if

                            Response.write("<tr id='preparo"&line&"' "&classe&" >")
                            Response.Write("<td>" & UCase(preparos("NomeProcedimento")) & "</td>")
                            Response.Write("<td>" & UCase(preparos("DescricaoPreparo")) & "</td>")
                            Response.Write("<td>" & preparos("PreparoTexto") & " </td>")
                            Response.write("</tr>")
                        end if

                        line = line + 1
                        preparos.movenext
                    wend
                %>
                <% if temPreparoPadrao = 1 then %>
                </table>
                <% end if %>
                <%
                    else
                        Response.write("<p>Não existem preparos</p>")
                    end if
                %>
                    <input type="hidden" name="ProcedimentoIDProfissional" id="ProcedimentoIDProfissional" value="<%=ProcedimentoID & "_" & ProfissionalID%>">
                    <input type="hidden" name="<%="quantidade_" & ProcedimentoID & "_" & ProfissionalID %>" class="quantidades" value="<%=Quantidade%>">
                <%
                    if Excecao <> "" then

                        if not execoes.eof then 
                %>
        
                <strong>INFORMAÇÃO TOTAL SOBRE O PEDIDO DO EXECUTANTE:</strong>
                <table class="table table-bordered" style="width:40vw;">
                    <tr>
                        <th>LABORATÓRIOS</th>
                        <th>PROCEDIMENTO</th>
                        <th>PREPARO/RESTRIÇÃO/INFORMAÇÃO</th>
                        <th>INFORMAÇÃO/VALOR</th>
                    </tr>
                <%
                    while not execoes.eof 
                        values = Split(execoes("Conta"), "_")
                        
                        accoountAssociation = values(0)
                        idOutraTabela = values(1)

                        sqlTabela = "select * from sys_financialaccountsassociation where id = " & accoountAssociation

                        preparoId = cstr(execoes("PreparoID"))
                        if maioresPreparos.Exists(preparoId) and maioresPreparos.item(preparoId).item("line") = line and maioresPreparos.item(preparoId).item("value") > 0 then
                            classe = " class='alert-warning'"
                        else
                            classe = ""
                        end if

                        Response.write("<tr"&classe&">")

                        set tabela = db.execute(sqlTabela)

                        if not tabela.eof then
                            sqlProfissional = "select " & tabela("column") & " as nomeColuna from " & tabela("table") & " where id = " & idOutraTabela
                            set profissional = db.execute(sqlProfissional)

                            Response.write("<td><strong>" & profissional("nomeColuna") & " " &"</strong></td>")
                        else 
                            Response.write("<td></td>")
                        end if

                        Response.Write("<td>" & execoes("NomeProcedimento") & "</td>")
                        Response.Write("<td>" & execoes("DescricaoPreparo") & "</td>")
                        
                        if execoes("Dias") <> "" and execoes("Dias") > 1 then
                            Response.Write("<td>" & execoes("Dias") & " dias </td>")
                        elseif execoes("Dias") <> "" then
                            Response.Write("<td>" & execoes("Dias") & " dia </td>")
                        elseif execoes("Horas") <> "" and execoes("Horas") > 1 then
                            Response.Write("<td>" & execoes("Horas") & " horas </td>")
                        elseif execoes("Horas") <> "" then
                            Response.Write("<td>" & execoes("Horas") & " hora </td>")
                        else
                            Response.Write("<td>&nbsp;</td>")
                        end if
                        Response.write("</tr>")

                        line = line + 1
                        execoes.movenext
                    wend
                %>
                </table>
                <%
                        else
                            Response.write("<p>Não existem exceções</p>")
                        end if
                    end if
                %>
    <%
        next
    %>
    </div>

    <div>
        <% if temProcedimento = 1 then %>
            <div class="checkbox-custom checkbox-primary">
                <input type="checkbox" name="informoupaciente" id="informoupaciente" value="1">
                <label class="checkbox" for="informoupaciente">Informou o paciente sobre os preparos para realização do exame?</label>
            </div>
        <% end if %>
        <input type="hidden" name="pacienteID" id="pacienteID" value="<%=pacienteID%>">
    </div>
    <div class="mt20" >
        <input type="button" name="completarCadastro" id="btcompletar" value="Fechar" class="btn btn-secondary" >
    </div>

</div>

<script>
    $(function(){
        var fechar = true;
        $('body').on('hide.bs.modal', '.modal', function (ev) {
            if($("#informoupaciente").is(":visible")){
                fechar = $("#informoupaciente").is(":checked")
            }
            
            if(!fechar){
                ev.preventDefault();
                showMessageDialog("Precisa informar o paciente", 'warning');
            }
        });

        $('#btcompletar').on('click', function() {
            $("#modal-table").modal("hide");
        });
    })


    function fechar2(){
        fechar = false;
    }

</script>