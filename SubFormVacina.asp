<!--#include file="connect.asp"-->
<%
Acao = req("opt")
VacinaID = req("VacinaID")
SerieID = req("SerieID")
DosagemID = req("DosagemID")

'Exclui todas as séries de dosagens e séries
if Acao="Del" then
    db_execute("delete from vacina_serie_dosagem where SerieID ="&SerieID)
    db_execute("delete from vacina_serie where id="&SerieID)
end if
'Fim

'Exclui apenas a série de dosagem
if Acao="DelDosagem" then
    db_execute("delete from vacina_serie_dosagem where id ="&DosagemID)
end if
'Fim

'Adiciona uma nova série
if Acao="Add" then
	db_execute("insert into vacina_serie (sysActive, sysUser, VacinaID) values (1, "&session("User")&", "&VacinaID&")")
end if
'Fim

'Adiciona uma série de dosagem
if Acao="AddDosagem" then
    db_execute("INSERT INTO vacina_serie_dosagem (sysActive, sysUser, SerieID) values (1,"&session("User")&","&SerieID&")")
end if
'Fim

'Retorna todas as dosagens
set dosagem = db.execute(" SELECT id, "&_
            " NomeProduto AS descricao "&_
            " FROM produtos "&_
            " WHERE sysActive = 1 "&_
            " ORDER BY 2")

while not dosagem.EOF
    dosagemChave = dosagemChave&dosagem("id")&"|"
    dosagemValor = dosagemValor&dosagem("descricao")&"|"
    dosagem.movenext
wend

dosagem.close
set dosagem=nothing
'Fim

%>
<div id="divVacinaSerie">

<div class="panel" id="p<%=NomeTabela %>">
    <div class="panel-heading">
        <span class="panel-title">Série de Vacina </span>
        <span class="panel-controls">
            <a class="panel-control-collapse hidden" href="#"></a>
            <a class="panel-control" onclick="atualizarForm('Add','<%=VacinaID%>','','')" href="javascript:void(0)"><i class="far fa-plus"></i></a>
        </span>
    </div>
    <div class="panel-body pn" <% if device()<>"" then %> style="overflow-x:scroll!important" <% end if %> >
<% 
        serSql = "SELECT * FROM vacina_serie WHERE sysActive=1 AND VacinaID="&VacinaID&" ORDER BY id"

        set ser = db.execute(serSql)

        if ser.EOF then
        
            db_execute("INSERT INTO vacina_serie (sysActive, sysUser, VacinaID) values (1,"&session("User")&","&VacinaID&")")
            serSql = "SELECT * FROM vacina_serie WHERE sysActive=1 AND VacinaID = "&VacinaID&" ORDER BY id"

            set ser = db.execute(serSql)
        end if
        while not ser.eof


            valorSerieTitulo = ""
            valorSerieDescricao = ""

            if Acao="" then
                valorSerieTitulo = ser("Titulo")
                valorSerieDescricao = ser("Descricao")
            else
                valorSerieTitulo = ref("Titulo-vacina_serie-"&ser("id"))
                valorSerieDescricao = ref("Descricao-vacina_serie-"&ser("id"))
            end if
      
%>
            <table width="100%" class="table table-condensed">
                <thead>
                    <tr>
                    <th colspan="100%" class="bg-info">
                        Série
                    </th>
                </tr>
                <tr>
                    <th>
                        Título
                    </th>
                    <th>
                        Descrição
                    </th>
                    <th>
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td width="49%">
                        <input type="text" name="Titulo-vacina_serie-<%=ser("id")%>" id="Titulo-<%=ser("id")%>" class="form-control" value="<%=valorSerieTitulo%>" >
                        <input type="hidden" name="id-vacina_serie" value="<%=ser("id")%>">
                    </td>
                    <td width="50%">
                        <input type="text" name="Descricao-vacina_serie-<%=ser("id")%>" id="Descricao-<%=ser("id")%>" class="form-control" value="<%=valorSerieDescricao%>" >
                    </td>
                    <td width="1%">
                        <button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="javascript:if(confirm('Tem certeza de que deseja excluir esta série?'))atualizarForm('Del','<%=VacinaID%>','<%=ser("id")%>','')"><i class="far fa-trash"></i></button>
                    </td>
                <tr>
                    <td colspan="90%">
                        <h5>Dosagem da série</h5>
                    </td>
                    <td colspan="10%">
                        <button type="button" class="btn btn-sm btn-success remove-item-subform" onclick="atualizarForm('AddDosagem','<%=VacinaID%>','<%=ser("id")%>','')"><i class="far fa-plus"></i></button>
                    </td>
                </tr>
                </tr>
<%
                    dosSql = "SELECT * FROM vacina_serie_dosagem WHERE sysActive=1 AND SerieID="&ser("id")&" ORDER BY Ordem"
                    
                    set dos = db.execute(dosSql)

                    if dos.EOF then
                    
                        db_execute("INSERT INTO vacina_serie_dosagem (sysActive, sysUser, SerieID) values (1,"&session("User")&","&ser("id")&")")
                        serDosSql = "SELECT * FROM vacina_serie_dosagem WHERE sysActive=1 AND SerieID = "&ser("id")&" ORDER BY Ordem"

                        set dos = db.execute(serDosSql)
                    end if
                    while not dos.eof
%>
                <tr>
                    <td colspan="100%">
                    <%
                    valorOrdem = ""
                    valorDescricao = ""
                    valorDosagem = ""

                    if Acao="" then
                        valorOrdem = dos("Ordem")
                        valorDescricao = dos("Descricao")
                        valorDosagem = dos("ProdutoID")
                        valorPeriodoDias = dos("PeriodoDias")
                    else
                        valorOrdem = ref("Ordem-vacina_serie_dosagem-"&dos("id"))
                        valorDescricao = ref("Descricao-vacina_serie_dosagem-"&dos("id"))
                        valorDosagem = ref("ProdutoID-vacina_serie_dosagem-"&dos("id"))
                        valorPeriodoDias = ref("PeriodoDias-vacina_serie_dosagem-"&dos("id"))
                    end if
                    %>
                        <table width="100%" class="table table-condensed">
                            <thead>
                                <th width="5%">Ordem</th>
                                <th width="30%">Descrição</th>
                                <th width="30%">Dosagem</th>
                                <th width="30%">Dias até a próxima dosagem<th>
                                <th width="5%"></th>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <input type="text" name="Ordem-vacina_serie_dosagem-<%=dos("id")%>" id="Ordem-<%=dos("id")%>" class="form-control" value="<%=valorOrdem%>" >
                                        <input type="hidden" name="id-vacina_serie_dosagem" value="<%=dos("id")%>">
                                    </td>
                                    <td>
                                        <input type="text" name="Descricao-vacina_serie_dosagem-<%=dos("id")%>" id="Descricao-<%=dos("id")%>" class="form-control" value="<%=valorDescricao%>" >
                                    </td>
                                    <td>
                                        <select id="ProdutoID-<%=dos("id")%>" name="ProdutoID-vacina_serie_dosagem-<%=dos("id")%>" class="select-dosagem" >
                                            <option value="0">Selecione</option>
<%
                                                splChave = split(dosagemChave, "|")
                                                splValor = split(dosagemValor, "|")

                                                for j=0 to ubound(splChave)

                                                    selected = ""

                                                    if ""&valorDosagem&"" = splChave(j) then
                                                        selected = " selected"
                                                    end if

                                                    if not splChave(j) = "" then
                                                        response.write("<option value='"&splChave(j)&"' "&selected&">"&splValor(j)&"</option>")
                                                    end if
                                                next
%>
                                        </select>
                                    <td>
                                        <input type="text" name="PeriodoDias-vacina_serie_dosagem-<%=dos("id")%>" id="PeriodoDias-<%=dos("id")%>" class="form-control" value="<%=valorPeriodoDias%>" >
                                    </td>
                                    </td>
                                        <td style="align: right">
                                        <button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="javascript:if(confirm('Tem certeza de que deseja excluir esta dosagem?'))atualizarForm('DelDosagem','<%=VacinaID%>','','<%=dos("id")%>')"><i class="far fa-trash"></i></button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
<%
                dos.movenext
            wend
            dos.close
            set dos=nothing
%>
            </tbody>
        </table>
<%
        ser.movenext
        wend
        ser.close
        set ser=nothing
%>
    </div>
</div>

</div>

<script>
    <!--#include file="jQueryFunctions.asp"-->

    $(document).ready(function(e) {

        $('.select-dosagem').select2();

    });

    function atualizarForm(opt, VacinaID, SerieID, DosagemID){
        $.post("SubFormVacina.asp?opt="+opt+"&VacinaID="+VacinaID+"&SerieID="+SerieID+"&DosagemID="+DosagemID, $("#frm").serialize()
            ,function(data){
                $("#divVacinaSerie").html(data);
            }
        );
    }
</script>
