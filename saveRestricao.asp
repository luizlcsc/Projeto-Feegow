<!--#include file="connect.asp"-->
<%
Acao = ref("Acao")
RestricaoID = ref("I")

if Acao = "salvarFormRestricao" then

    if ref("TextoNAO") <> "" then
        TextoNAO = "'"&ref("TextoNAO")&"'"
    else
        TextoNAO = "NULL"
    end if

    if ref("TextoSIM") <> "" then
        TextoSIM = "'"&ref("TextoSIM")&"'"
    else
        TextoSIM = "NULL"
    end if

    if ref("CaixaNAO") <> "" then
        CaixaNAO = "'"&ref("CaixaNAO")&"'"
    else
        CaixaNAO = "NULL"
    end if

    if ref("CaixaSIM") <> "" then
        CaixaSIM = "'"&ref("CaixaSIM")&"'"
    else
        CaixaSIM = "NULL"
    end if

    if ref("Tipo") <> "" then
        Tipo = "'"&ref("Tipo")&"'"
    else
        Tipo = "NULL"
    end if

    if ref("Descricao") <> "" then
        Descricao = "'"&ref("Descricao")&"'"
    else
        Descricao = "NULL"
    end if

    if ref("DadoFicha") <> "" then
        DadoFicha = "'"&ref("DadoFicha")&"'"
    else
        DadoFicha = "NULL"
    end if

    if ref("AlteraDadoFicha") <> "" then
        AlteraDadoFicha = "'"&ref("AlteraDadoFicha")&"'"
    else
        AlteraDadoFicha = "NULL"
    end if

    if ref("ExibeDadoFicha") <> "" then
        ExibeDadoFicha = "'"&ref("ExibeDadoFicha")&"'"
    else
        ExibeDadoFicha = "NULL"
    end if

    if ref("ExibirCheckin") <> "" then
        ExibirCheckin = "'"&ref("ExibirCheckin")&"'"
    else
        ExibirCheckin = "NULL"
    end if

    if ref("RestricaoSemExcecao") <> "" then
        RestricaoSemExcecao = "'"&ref("RestricaoSemExcecao")&"'"
    else
        RestricaoSemExcecao = "NULL"
    end if
    db.execute("UPDATE sys_restricoes SET sysActive=1, TextoNAO="&TextoNAO&", TextoSIM="&TextoSIM&", CaixaNAO="&CaixaNAO&", CaixaSIM="&CaixaSIM&", Tipo="&Tipo&", Descricao="&Descricao&", DadoFicha="&DadoFicha&", AlteraDadoFicha="&AlteraDadoFicha&", ExibeDadoFicha="&ExibeDadoFicha&", ExibirCheckin="&ExibirCheckin&", RestricaoSemExcecao="&RestricaoSemExcecao&" WHERE id ="&RestricaoID)

%>
$(document).ready(function(e) {
    new PNotify({
        title: 'Registro salvo com sucesso',
        text: '',
        type: 'success',
        delay: 3000
    });
});
<%
end if
%>