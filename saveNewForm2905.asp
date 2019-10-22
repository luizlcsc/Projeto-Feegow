<!--#include file="connect.asp"-->
<%
I = req("i")
ModeloID = req("m")
PacienteID = req("p")
Tipo = req("t")
erro = ""

if aut("formsaeA")=0 and req("Inserir")<>"1" then
    erro = "Sem permissão para alteração."
end if
if aut("formsaeI")=0 and req("Inserir")="1" then
    erro = "Sem permissão para inserção."
end if

if erro<>"" then
    if aut("formsaeV")=1 and req("A")="P" then
        %>
        $(".btn-save-form").remove();
        $("#iProntCont").html("<iframe width='100%' height='500' frameborder=0 src='printForm.asp?PacienteID=<%=PacienteID %>&ModeloID=<%=ModeloID %>&FormID=<%=I %>'></iframe>)");
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
    db_execute("insert into buiformspreenchidos (ModeloID, PacienteID, sysUser,sysActive) values ("&ModeloID&", "&PacienteID&", "&session("User")&", "&Active&")")
    set pult = db.execute("select id from buiformspreenchidos where ModeloID="&ModeloID&" and PacienteID="&PacienteID&" and sysUser="&session("User")&" order by id desc limit 1")
    I = pult("id")
    db_execute("insert into `_"&ModeloID&"` (id, PacienteID, sysUser) values ("&I&", "&PacienteID&", "&session("User")&")")
elseif req("Inserir")="1" then
    db_execute("update buiformspreenchidos SET sysActive=1 WHERE id="&I)
end if

set pcampos = db.execute("select id, TipoCampoID from buicamposforms where FormID="&ModeloID)
while not pcampos.eof
    select case pcampos("TipoCampoID")
        case 1, 2, 4, 5, 6, 8,3
            sqlUp = sqlUp & ", `"& pcampos("id") &"`='"& ref("input_"&pcampos("id")) &"'"
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
                        if linha<0 then
                            sqlIn = "insert into buitabelasvalores (CampoID, FormPreenchidoID "& strInLinha &") values ("& pcampos("id") &", "& I & strInValLinha &")"
                            'response.Write( sqlIn )
                            db.execute( sqlIn )
                        else
                            sqlUpLinha = "update buitabelasvalores set FormPreenchidoID="& I & strUp &" where id="& linha
                            'response.write(sqlUp)Linha
                            db.execute(sqlUpLinha)
                        end if
                        %>
                        //alert('<%=linha %>');
                        <%
                    end if
                next
            end if
    end select
    if sqlUp<>"" then
        sqlUpFinal = "update `_"&ModeloID&"` set PacienteID="&PacienteID & sqlUp &" WHERE id="&I

        db_execute(sqlUpFinal)
    end if
pcampos.movenext
wend
pcampos.close
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


if req("A")="P" then
    'acao de imprimir
    %>
    $(".btn-save-form").remove();
    $("#iProntCont").html("<iframe width='100%' height='500' frameborder=0 src='printForm.asp?PacienteID=<%=PacienteID %>&ModeloID=<%=ModeloID %>&FormID=<%=I %>'></iframe>)");
    <%
elseif req("auto")="1" then
    set BuiFormSQL = db.execute("SELECT Tipo FROM buiforms WHERE id="&ModeloID)
    if BuiFormSQL("Tipo")=4 or BuiFormSQL("Tipo")=3 then
        FTipo = "L"
    else
        FTipo = "AE"
    end if
    session("FP"&FTipo)=I
    %>
    new PNotify({
        title: 'Salvo',
        text: 'Formulário salvo.',
        type: 'success',
        delay: 500
    });
    $("#FormID").val("<%=I%>");
    var $Audiometria = $(".campo-audiometria");
    var LinkAudiometria = $Audiometria.prop("src");

    if(LinkAudiometria){
    $Audiometria.prop("src",LinkAudiometria.replace("FormID=N","FormID=<%=I%>"));
    }

<% else
    %>
    $.magnificPopup.close();
<% end if %>
pront('timeline.asp?PacienteID=<%=PacienteID %>&Tipo=|<%=Tipo %>|');