<!--#include file="connect.asp"-->
<%
save = req("save")
if save&"" = "S" then
    id = req("id")
    db.execute("update buiformspreenchidos set sysActive=1 where id="& id)
else
%>
<script type="text/javascript">

var tipo = '<%= replace(req("tipo"),"|","") %>';
var pacienteID = <%=req("pacienteID")%>;

constroiLogForLocalStorage();

function constroiLogForLocalStorage()
{
    let local = localStorage.getItem("logForms");
    $("#localStorage").html("");

    if(local!=null){
        let ret = JSON.parse(local);

        ret.forEach(element => {
            
            if (element.pacienteID === pacienteID && element.tipo === tipo)
            {
                let conteudo = '';
                for (var key in element.jsonForm) 
                {
                    if (element.jsonForm.hasOwnProperty(key)) {
                        if(key.includes("input"))
                        conteudo += "<p>"+element.jsonForm[key]+"</p>";
                    }
                }

                let text = `
                <div class="panel panel-warning" style="padding-left: 10px; padding-right: 15px">
                    <div class="panel-heading ">
                        Em sua máquina 
                        <code>#${element.formID}</code>           
                        <div class="pull-right"> ${element.dataHora} </div>
                    </div>
                    <div class="panel-body">
                        <button type="button" onclick="DescartarLog('${element.formID}')" class="btn btn-danger pull-right"  data-toggle="tooltip" data-placement="bottom" title="Descartar"><i class="far fa-trash"></i></button>
                        <button type="button" onclick="RestoreLog('${element.formID}')" class="btn btn-primary pull-right mr5" data-toggle="tooltip" data-placement="bottom" title="Restaurar"><i class="far fa-external-link"></i></button>
                    ${conteudo}
                    </div>
                </div>
                `;
                $("#localStorage").append(text);
                }
        });
    }
}

function RestoreLog(id){
    
    let local = localStorage.getItem("logForms");
    let ret = JSON.parse(local);
    let element = ret.findIndex((elem,index)=>{
                   return (elem.formID == id && elem.pacienteID == pacienteID && elem.tipo == tipo);
            }) ;
    $.post("saveNewForm.asp?A=0&t="+ret[element].tipo+"&p="+ret[element].pacienteID+"&m="+ret[element].modeloID+"&i="+ret[element].formID+"&auto=1&Inserir=0",
         ret[element].formData, 
         function(data){
            eval(data);
            closeComponentsModal();
            iPront(ret[element].tipo,ret[element].pacienteID,ret[element].modeloID,ret[element].formID,'');
            
        }).fail(function() {
             console.log("falhou");
            });

}

function DescartarLog(id){
    
    let local = localStorage.getItem("logForms");
    let ret = JSON.parse(local);
    let element = ret.findIndex((elem,index)=>{
                   return (elem.formID == id && elem.pacienteID == pacienteID && elem.tipo == tipo);
            }) ;

    ret.splice(element,1);
    localStorage.setItem("logForms", JSON.stringify(ret));
    constroiLogForLocalStorage();

}

</script>

<div style="overflow:auto; height:600px;">

<div id="localStorage">
</div>

<%
tipo = req("tipo")
paciente = req("pacienteID")

if tipo="|L|" then
    sqlTipo = " and (bf.Tipo IN (3,4,0) or isnull(bf.Tipo))"
else
    sqlTipo = " and (bf.Tipo IN(1,2))"
end if
    'response.write(sqlTipo)

if session("admin") = 1 then 
sqlRestForm = "select bfp.id, bf.Nome, bfp.DataHora ,bfp.sysUser, bfp.ModeloID from buiformspreenchidos bfp join buiforms bf on bf.id = bfp.ModeloID where bfp.sysActive <> 1 AND bfp.PacienteID="&paciente + sqlTipo&" order by bfp.id desc"
else 
sqlRestForm = "select bfp.id, bf.Nome, bfp.DataHora ,bfp.sysUser, bfp.ModeloID from buiformspreenchidos bfp join buiforms bf on bf.id = bfp.ModeloID where bfp.sysActive <> 1 AND bfp.PacienteID="&paciente + sqlTipo&" and bfp.sysUser ="&session("User")&" order by bfp.id desc"

end if

set restForm=db.execute(sqlRestForm)

if not restForm.eof then
    while not restForm.eof
    asql = "select bfp.id from buiformspreenchidos bfp join buiforms bf on bf.id = bfp.ModeloID where bfp.sysActive = 1 AND bfp.PacienteID="&paciente&" and abs(TIMESTAMPDIFF(MINUTE,bfp.DataHora, DATE_FORMAT(str_to_date('"&restForm("DataHora")&"','%d/%m/%Y %H:%i:%s'),'%Y-%m-%d %H:%i:%s')))<240"&sqlTipo
    'response.write (asql)
    set formExist = db.execute(asql)
    colorHeading = "success"
    if not formExist.eof then
        colorHeading = "default"
    end if

    %>
            <div class="panel panel-<%=colorHeading%>" style="padding-left: 10px; padding-right: 15px">
                <div class="panel-heading ">
                    <%=restForm("Nome")&" - "&nameInTable(restForm("sysUser")) %>            
                        <code>#<%=restForm("id")%></code>           
                    <div class="pull-right"><%=restForm("DataHora")%></div>
                </div>
                <div class="panel-body">
                    <button type="button" onclick="restoreform('<%=restForm("id") %>')" class="btn btn-primary pull-right" data-toggle="tooltip" data-placement="bottom" title="Restaurar"><i class="far fa-external-link"></i></button>
                <%
                    response.Write("<small>")
                        sqltest ="SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='_"& restForm("ModeloID") &"'"
                        'response.Write sqltest
                        set tableexist = db.execute(sqltest)
                        if not tableexist.eof then
                            sqltest = "select * from `_"& restForm("ModeloID") &"` where id="& restForm("id")
                            'response.Write sqltest
                            set reg = db.execute(sqltest)
                            if not reg.eof then
                                set pcampos = db.execute("select * from buicamposforms where FormID="&restForm("ModeloID")&" and TipoCampoID NOT IN(7,10,11,12,15) ORDER BY Ordem")
                                while not pcampos.eof
                                    Rotulo = trim(pcampos("RotuloCampo")&"")
                                    if Rotulo<>"" then
                                        Rotulo = "<b>"&Rotulo&" </b> "
                                    end if
                                    if pcampos("TipoCampoID")=9 then
                                        Valor = ""
                                    else
                                        Valor = trim(reg(""&pcampos("id")&"")&"")
                                    end if
                                    select case pcampos("TipoCampoID")
                                        case 3
                                            if Valor<>"" and Valor<>"uploads/" then
                                            %>
                                            <div class="media-body">
                                                <b><%=Rotulo %></b><br />
                                                <img src="uploads/<%=Valor %>" class="mw140 mr25 mb20">
                                            </div><br />
                                            <%
                                            end if
                                        case 4, 5, 6
                                            if instr(Valor, "|")>0 or (Valor<>"" and isnumeric(Valor)) then
                                                set vals = db.execute("select group_concat(Nome SEPARATOR '; ') Valor from buiopcoescampos where id IN("& replace(Valor, "|", "") &")")
                                                if not vals.eof then
                                                    Valor = vals("Valor")
                                                    response.Write( Rotulo & Valor  &"<br>" )
                                                end if
                                            end if
                                        case 9
                                            set regTab = db.execute("select * from buitabelasvalores where CampoID="& pCampos("id")&" and FormPreenchidoID="& restForm("id"))
                                            if not regTab.eof then
                                            %>
                                            <table class="table table-condensed table-bordered mb10">
                                                <thead>
                                                    <tr class="info">
                                                        <%
                                                        Largura = ccur(pcampos("Largura"))
                                                        cLarg = 0
                                                        set pTit = db.execute("select * from buitabelastitulos where CampoID="& pcampos("id"))
                                                        while cLarg<Largura
                                                            cLarg = cLarg + 1
                                                            %>
                                                            <th><%= pTit("c"& cLarg) %></th>
                                                            <%
                                                        wend
                                                        %>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <%
                                                    while not regTab.eof
                                                    %>
                                                    <tr>
                                                        <%
                                                        cLarg = 0
                                                        while cLarg<Largura
                                                            cLarg = cLarg + 1
                                                            %>
                                                            <td><%= regTab("c"& cLarg) %></td>
                                                            <%
                                                        wend
                                                        %>
                                                    </tr>
                                                    <%
                                                    regTab.movenext
                                                    wend
                                                    regTab.close
                                                    set regTab = nothing
                                                    %>
                                                </tbody>
                                            </table>
                                            <%
                                            end if
                                        case 14
                                            %>
                                            <iframe width="100%" scrolling="no" height="460" id="ifrCurva<%= restForm("id") %>" frameborder="0" src="Curva.asp?CampoID=<%= pcampos("id") %>&FormPID=<%= reg("id") %>"></iframe>
                                            <%
                                        case else
                                            if Valor<>"" and Valor<>"<p><br></p>" then
                                            if left(Valor, 5)="{\rtf" then
                                                    call limpa("_"&restForm("ModeloID"), pcampos("id"), reg("id"))

                                            end if
                                            response.Write( Rotulo & Valor  &"<br>" )
                                            end if
                                    end select
                                    'response.Write( Rotulo & Valor  &"<br>[["& pcampos("TipoCampoID") &"]]" )
                                pcampos.movenext
                                wend
                                pcampos.close
                                set pcampos=nothing
                            end if
                        else
                            response.Write("<p>informação não encontrada</p>")
                        end if
                    response.Write("</small>")
                %>
                
                </div>
            </div>
    <%
    restForm.movenext
    wend
    restForm.close
end if
%>
</div>

<script>

function restoreform(idForm) {
    $.get("restoreForms.asp",{
        save:"S",
        id:idForm
        }, function(data,status){
                if (status == "success"){
                    showMessageDialog("Restaurado com sucesso", "success");
                    closeComponentsModal();
                    reloadTimeline();
                }else{
                    showMessageDialog("Erro ao restaurar formulário, tente novamente mais tarde", "danger");
                }
            });
}
</script>
<%
end if
%>