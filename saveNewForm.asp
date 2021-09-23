<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->
<%
response.Charset = "utf-8" 
response.ContentType = "text/html"

I = req("i")
ModeloID = req("m")
PacienteID = req("p")
Tipo = req("t")
erro = ""
habilitarVazio = req("v")

if ModeloID = 0 then 
    Response.End
end if 

if aut("formsaeA")=0 and req("Inserir")<>"1" then
    erro = "Sem permissão para alteração."
end if
if aut("formsaeI")=0 and req("Inserir")="1" then
    erro = "Sem permissão para inserção."
end if

if lcase(session("Table"))="profissionais" then
    TipoUser = "P"
elseif lcase(session("Table"))="funcionarios" then
    TipoUser = "F"
end if

PermissaoOk = True

set BuiSQL = db.execute("SELECT IF(su.`table`='profissionais',su.idInTable,null) ProfissionalID FROM buiformspreenchidos bui INNER JOIN sys_users su ON su.id=bui.sysUser WHERE bui.id="&treatvalzero(I))

if not BuiSQL.eof then
    ProfissionalID =  BuiSQL("ProfissionalID")
end if

sqlPerm = "SELECT * FROM buipermissoes WHERE Tipo='"&TipoUser&"' AND FormID="&treatvalzero(ModeloID)&" AND Grupo LIKE '%|"&session("idInTable")&"|%' ORDER BY LENGTH(Grupo) "
set PermissaoFormSQL = db.execute(sqlPerm)
if not PermissaoFormSQL.eof then
    Permissoes = PermissaoFormSQL("Permissoes")
    ProfissionalIDProprio = session("idInTable")

    if req("Inserir")="1" and instr(Permissoes,"IN")=0 then
        PermissaoOk=False
        erro="Voce não possui permissões para inserir este formulário"
    end if
    if req("Inserir")<>"1" and instr(Permissoes,"AP")=0 and ProfissionalID=ProfissionalIDProprio then
        PermissaoOk=False
        erro="Voce não possui permissões para alterar este formulário"
    end if
    if req("Inserir")<>"1" and instr(Permissoes,"AO")=0 and ProfissionalID<>ProfissionalIDProprio then
        PermissaoOk=False
        erro="Voce não possui permissões para alterar este formulário de outro profissional"
    end if
end if

if erro<>"" then
    if aut("formsaeV")=1 and req("A")="P" then
        %>
        $(".btn-save-form").remove();
        $(".btn-print-form").remove();
        $("#iProntCont").html("<iframe width='100%' height='500' frameborder=0 src='printForm.asp?PacienteID=<%=PacienteID %>&ModeloID=<%=ModeloID %>&FormID=<%=I %>'></iframe>");
        <%
    else
        %>
        new PNotify({
            title: 'Nada alterado',
            text: '<%=erro%>',
            type: 'warning',
            delay: 1000
        });
        <%
    end if
    Response.End
end if


if I="N" then
    Active=1
    if req("auto")="1" then
        Active=0
    end if
    set pmod = db.execute("select Prior from buiforms where id="& ModeloID)
    if not pmod.eof then
        Prior = pmod("Prior")
    end if

    'inclusão do atendimentoID se houver atendimento em curso
    'verifica se tem atendimento aberto
    set atendimentoReg = db.execute("select * from atendimentos where PacienteID="&PacienteID&" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
     if atendimentoReg.EOF  then
        if getConfig("AutoSaveForms") = 1 then 'Nao permite salvar automaticamente
            db_execute("insert into buiformspreenchidos (ModeloID, PacienteID, sysUser, sysActive, Prior) values ("&ModeloID&", "&PacienteID&", "&session("User")&", "&Active&", "& treatvalzero(Prior) &")")
        else
            db_execute("insert into buiformspreenchidos (ModeloID, PacienteID, sysUser, sysActive, Prior) values ("&ModeloID&", "&PacienteID&", "&session("User")&", 1, "& treatvalzero(Prior) &")")
        end if
    else
        'salva com id do atendimento
         db_execute("insert into buiformspreenchidos (ModeloID, PacienteID, sysUser, sysActive, Prior, AtendimentoID) values ("&ModeloID&", "&PacienteID&", "&session("User")&", "&Active&", "& treatvalzero(Prior) &", "&atendimentoReg("id")&")")
    end if

    set pult = db.execute("select id from buiformspreenchidos where ModeloID="&ModeloID&" and PacienteID="&PacienteID&" and sysUser="&session("User")&" order by id desc limit 1")
    I = pult("id")
    db_execute("insert into `_"&ModeloID&"` (id, PacienteID, sysUser) values ("&I&", "&PacienteID&", "&session("User")&")")
end if

set pcampos = db.execute("select id, TipoCampoID, enviardadoscid from buicamposforms where FormID="&ModeloID)
while not pcampos.eof
    select case pcampos("TipoCampoID")
        case 1, 2, 4, 5, 6, 8,3,16
            if Request("input_"&pcampos("id")).Count > 0 then
                valorCampo = refHTML("input_"&pcampos("id"))
                valorCampo = stripHTML(valorCampo)

                'se o campo vier em branco, verifica se houve alteração
                campoAlterado = false
                if valorCampo = "" then
                    set rsHasUpdate = db.execute("SELECT " & pcampos("id") & " as campo FROM `_"&ModeloID&"` WHERE id = " &I)
                    if not rsHasUpdate.eof then
                        valorAtual = stripHTML(rsHasUpdate("campo")&"")
                        if valorAtual <> valorCampo then
                            campoAlterado = true
                        end if
                    end if
                end if

                if valorCampo <> "" or habilitarVazio = "1" or campoAlterado = true then
                    inputValor = refHTML("input_"&pcampos("id"))
                    'O SEGUNDO PARAMETRO EH UM CARACTER FANTASMA . NAO REMOVER A LINHA DE BAIXO !!!!!
                    inputValor = replace(inputValor, "​", "")
                    sqlUp = sqlUp & ", `"& pcampos("id") &"`='"& inputValor &"'"
                    if pcampos("TipoCampoID")  = 16 and  pcampos("enviardadoscid") = 1 then
                        sqlIncluirCid = "INSERT INTO pacientesdiagnosticos ( PacienteID, CidID, Descricao, DataHora, sysUser, sysActive,  AtendimentoID) "&_
                                        " VALUES ("&PacienteID&", "&inputValor&", '', NOW(), "&session("User")&", 1, null)"
                        db.execute( sqlIncluirCid )
                    end if
                end if
            end if
        case 9
            if req("auto")<>"1" then
                tblRem = ref("tblRem"&pcampos("id"))
                if tblRem<>"" and tblRem<>"0" then
                    sqlRem = "delete from buitabelasvalores where id IN("& tblRem &")"
                    db.execute( sqlRem )
                end if
                linhas = ref("tblH"&pcampos("id"))
                spl = split(linhas, ", ")
                for j=0 to ubound(spl)
                    linha = spl(j)
                    if isnumeric(linha) then
                        linha=ccur(linha)
                        colunas = 20
                        coluna = 0
                        strUp = ""
                        strInLinha = ""
                        strInValLinha = ""
                        while coluna<colunas
                            coluna = coluna +1
                            valor = ref( pcampos("id") &"_"& coluna &"_"& linha )
                            strUp = strUp & ", `c" & coluna & "`='"& valor &"'"
                            strInLinha = strInLinha & ", `c"& coluna &"`"
                            strInValLinha = strInValLinha & ", '"& valor &"'"
                        wend
                        convTags_itens = "UnidadeID_"&replace(session("Banco"),"clinic","")
                        if instr(strUp,"[Paciente.")>0 then
                            convTags_itens = convTags_itens&"|PacienteID_"&req("p")
                        end if

                        if linha<0 or req("Inserir")="1" then
                            strInValLinha = TagsConverte(strInValLinha,convTags_itens,"")
                            sqlIn = "insert into buitabelasvalores (CampoID, FormPreenchidoID "& strInLinha &") values ("& pcampos("id") &", "& I & strInValLinha &")"
                            'response.Write( sqlIn )

                            db.execute( sqlIn )
                            rowTableId = getLastAdded("buitabelasvalores")

                            coluna=0
                            while coluna<colunas
                                coluna = coluna +1
                                    
                                %>
                                $("#<%=pcampos("id")%>_<%=coluna%>_<%=linha%>").attr("name","<%=pcampos("id")%>_<%=coluna%>_<%=rowTableId%>");
                                <%
                            wend

                        else
                            
                            strUp = TagsConverte(strUp,convTags_itens,"")
                            sqlUpLinha = "update buitabelasvalores set FormPreenchidoID="& I & strUp &" where id="& linha
                            'response.write("<pre>"&sqlUpLinha&"</pre>")
                            db.execute(sqlUpLinha)
                        end if
                        %>
                        //alerformt('<%=linha %>');
                        <%
                    end if
                next
                db.execute("update buiformspreenchidos set sysActive=1 where id="& I)
            end if
    end select
    'if sqlUp<>"" then
        'sqlUpFinal = "update `_"&ModeloID&"` set PacienteID="&PacienteID & sqlUp &" WHERE id="&I
        'response.write("<br>update modelo: "&sqlUpFinal&"<br>")

        'db_execute(sqlUpFinal)

       ' if req("auto")<>"1" then
       '     db.execute("update buiformspreenchidos set sysActive=1 where id="& I)
       ' end if
    'end if
pcampos.movenext
wend
pcampos.close

if sqlUp<>"" then
    sqlUpFinal = "update `_"&ModeloID&"` set PacienteID="&PacienteID & sqlUp &" WHERE id="&I
    sqlUpFinal = convertSimbolosHexadecimal(sqlUpFinal)
    'response.write("<br>update modelo: "&sqlUpFinal&"<br>")
    db_execute(sqlUpFinal)
    if req("auto")<>"1" then
        db.execute("update buiformspreenchidos set sysActive=1 where id="& I)
    end if
end if

set pcampos=nothing

lembrarme = ref("lembrarme")
splL = split(lembrarme, ", ")
for j=0 to ubound(splL)
    CampoID = splL(j)
    set vca = db.execute("select id from buiformslembrarme where PacienteID="&PacienteID&" and ModeloID="&ModeloID&" and FormID="&I&" and CampoID="&CampoID)
    if vca.eof then
        db_execute("insert into buiformslembrarme (PacienteID, ModeloID, FormID, CampoID) values ("&PacienteID&", "&ModeloID&", "&I&", "&CampoID&")")
    end if
next
if lembrarme<>"" then
    db_execute("delete from buiformslembrarme where PacienteID="&PacienteID&" and ModeloID="&ModeloID&" and FormID="&I&" and CampoID not in("& lembrarme &")")
else
    db_execute("delete from buiformslembrarme where PacienteID="&PacienteID&" and ModeloID="&ModeloID&" and FormID="&I)
end if

if Tipo="L" then
    db_execute("update buiformspreenchidos set ProfissionaisLaudar='"&ref("ProfissionaisLaudar")&"' where id="&I)

    if ref("Laudado")="S" then
	    Grava = "NOW()"
	    LaudadoPor = session("idInTable")
    else
	    Grava = "NULL"
	    LaudadoPor = "NULL"
    end if
    db_execute("update buiformspreenchidos set LaudadoEm="&Grava&", LaudadoPor="&LaudadoPor&" where id="&I)
end if

if ref("LaudoID")<>"" then
    sql = "update laudos set FormID="& ModeloID &", FormPID="& treatvalnull(I) &" WHERE id="& ref("LaudoID")
    db_execute(sql)
    %>
    showMessageDialog("Laudo salvo com sucesso.", "success");
    <%
end if

ConfigPapelTimbradoFormulario = getConfig("PapelTimbradoFormulario")

if req("A")="P" then
    'acao de imprimir
    %>
    $(".btn-save-form").remove();
    $(".btn-print-form").remove();
    var timbrado = <% if ConfigPapelTimbradoFormulario then %>1<% else %>0<% end if %>

    <%
    recursoPermissaoUnimed = recursoAdicional(12)
    if getConfig("UtilizarFormatoImpressao")=1 or recursoPermissaoUnimed=4  then
    'if  session("Banco")="clinic3756" or session("Banco")="clinic6290" or session("Banco")="clinic100000" or session("Banco")="clinic6256" or session("Banco")="clinic6118" or session("Banco")="clinic105" or session("Banco")="clinic6239" then
    %>

    var urlForm = domain+"print/custom-form/<%=I %>"+"?tk="+localStorage.getItem("tk")+"&formId=<%=ModeloID %>&showPapelTimbrado="+timbrado;
    $("#iProntCont").html("<div class='row'><div class='col-md-10'><iframe width='100%' height='500' frameborder=0 id='impressaoAnamnese' name='impressaoAnamnese' src='"+urlForm+"'></iframe></div><div class='col-md-2'><label><input type='checkbox' id='Timbrado' name='Timbrado' class='ace' <% if ConfigPapelTimbradoFormulario then %> checked='checked' <% end if %>><span class='lbl'> Papel Timbrado</span></label><hr></div></div>");

    $( "#Timbrado" ).change(function() {
        timbrado = $("#Timbrado").prop("checked") ==true?1:0;
        url = domain+"print/custom-form/<%=I %>"+"?tk="+localStorage.getItem("tk")+"&formId=<%=ModeloID %>&showPapelTimbrado="+timbrado;
        $('#impressaoAnamnese').attr('src', url);
    });

    <%
    else
    %>
    $("#iProntCont").html("<iframe width='100%' height='500' frameborder=0 src='printForm.asp?PacienteID=<%=PacienteID %>&ModeloID=<%=ModeloID %>&FormID=<%=I %>'></iframe>");
    <%
    end if
elseif req("auto")="1" then
    set BuiFormSQL = db.execute("SELECT Tipo FROM buiforms WHERE id="&ModeloID)
    if BuiFormSQL("Tipo")=4 or BuiFormSQL("Tipo")=3 then
        FTipo = "L"
    else
        FTipo = "AE"
    end if

    session("FP"&FTipo)=I
    %>
    $("#FormID").val("<%=I%>");
    var $Audiometria = $(".campo-audiometria");
    var LinkAudiometria = $Audiometria.prop("src");

    if(LinkAudiometria){
    $Audiometria.prop("src",LinkAudiometria.replace("FormID=N","FormID=<%=I%>"));
    }

<% else
    %>
    $.magnificPopup.close();
<% end if

if req("auto")<>"1" then

    action = "novo_formulario"

    if I<>"N" then
        action = "altera_formulario"
    end if
%>

gtag('event', '<%=action%>', {
    'event_category': 'formulario',
    'event_label': "Botão 'Salvar' clicado.",
});

pront('timeline.asp?PacienteID=<%=PacienteID %>&Tipo=|<%=req("t") %>|');
<%
end if
%>