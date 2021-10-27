<!--#include file="connect.asp"-->
<%

textHelp = Req("text")

paginaTitulo = "<h3 class=""text-center"">Resultado da busca por <i>"""&textHelp&"""</i></h3>"

if textHelp <> "" then 
    sql = "SELECT *, p.id as idprocedimento FROM procedimentos AS p " &_ 
            " LEFT JOIN procedimentosgrupos pg ON pg.id = p.GrupoID " &_ 
            " WHERE p.NomeProcedimento LIKE '%" & textHelp & "%' AND p.sysActive=1 and Ativo='on' and ifnull(OpcoesAgenda, 0)<>3 "
    set helpRs = db.execute(sql)
    if helpRs.eof then
        conteudoProcedimentos = "Nenhum procedimento foi encontrado."
    else
       
        while not helpRs.eof
            conteudoProcedimentosContent = "<tr class='linhaprocedimento'>"&_
            "<td>" & helpRs("NomeGrupo") & "</td>"&_
                "<td>" & helpRs("NomeProcedimento") & "</td>"&_
                "<td><input type='hidden' class='idprocedimentotxt' name='idprocedimento' data-value='"& helpRs("NomeProcedimento") &"' value='" & helpRs("idprocedimento")& "' >" & helpRs("idprocedimento") & "</td>"&_
            "</tr>"
        if conteudoProcedimentos="" then
            conteudoProcedimentos = conteudoProcedimentosContent
        else
            conteudoProcedimentos = conteudoProcedimentos&conteudoProcedimentosContent
        end if

        helpRs.movenext
        wend
        helpRs.close
        set helpRs = nothing
        
         conteudoProcedimentos = "<table class='table table-bordered'>"&_
            "<tr>"&_
            "    <th>Grupo</th><th>Procedimento</th>"&_
            "</tr>"&_
                conteudoProcedimentos&_
            "</table>"
    end if   


    sqlBaseConhecimento = "SELECT * FROM basedeconhecimento AS bc " &_ 
                          " WHERE (bc.pergunta LIKE '%" & textHelp & "%' OR bc.Resposta LIKE '%" & textHelp & "%') AND bc.sysActive=1  "
    set helpBaseRs = db.execute(sqlBaseConhecimento)
    if helpBaseRs.eof then
        conteudoBaseConhecimento = "Nenhum procedimento foi encontrado."
    else
        diasValidade = getConfig("ValidadeBaseConhecimento")
        while not helpBaseRs.eof
            data=dateadd("d",10,helpBaseRs("sysDate"))
            classe = ""
            if date() > data then
                classe = "danger "
            end if
            conteudoBaseConhecimentoConteudo =  "<tr class='"&classe&"'>"&_
                                                    "<td>" & helpBaseRs("Pergunta") & "</td>"&_
                                                    "<td>" & helpBaseRs("Resposta") & "</td>"&_
                                                "</tr>"

            if conteudoBaseConhecimento="" then
                conteudoBaseConhecimento = conteudoBaseConhecimentoConteudo
            else
                conteudoBaseConhecimento = conteudoBaseConhecimento&conteudoBaseConhecimentoConteudo
            end if

        helpBaseRs.movenext
        wend
        helpBaseRs.close
        set helpBaseRs = nothing

        conteudoBaseConhecimento =  "<table class='table table-bordered' style='margin-top: 20px'>"&_
                                    "    <thead>"&_
                                    "    <tr>"&_
                                    "        <th>Pergunta</th><th>Respostas</th>"&_
                                    "    </tr>"&_
                                    "    </thead>"&_
                                    "    <tbody>"&_
                                         conteudoBaseConhecimento&_
                                    "    </tbody>"&_
                                    "</table>"

    end if  

end if
%>

<div style="margin:20px; height:85vh;overflow-y:auto;overflow-x:hidden;">
    <%=paginaTitulo%>
    <div class="row">
        <div class="col-md-12">
            <div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
                <div class="panel panel-default">
                    <div class="panel-heading" role="tab" id="headingOne">
                    <h4 class="panel-title">
                        <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                            Procedimentos
                        </a>
                    </h4>
                    </div>
                    <div id="collapseOne" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne">
                    <div class="panel-body">
                        <%=conteudoProcedimentos%>
                    </div>
                    </div>
                </div>
                <div class="panel panel-default">
                    <div class="panel-heading" role="tab" id="headingTwo">
                    <h4 class="panel-title">
                        <a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                            Base de Conhecimento
                        </a>
                    </h4>
                    </div>
                    <div id="collapseTwo" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingTwo">
                    <div class="panel-body">
                        <%=conteudoBaseConhecimento%>
                    </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    $(function(){
        $(".linhaprocedimento td").css('cursor' , 'pointer')
        $(".linhaprocedimento").on('click', function(){
            var idprocedimento = $(this).find(".idprocedimentotxt").val();
            var nomeprocedimento = $(this).find(".idprocedimentotxt").attr("data-value");
            $('#bProcedimentoID').append('<option value="'+idprocedimento+'">'+nomeprocedimento+'</option>');
            $('#bProcedimentoID').select2('val', ''+idprocedimento+'', true);
            $("#modal-table").modal("hide");
        });
    })
</script>