<!--#include file="connect.asp"-->
<%
Pagina = lcase(ref("P"))
id = ref("id")
termoCompleto = lcase(" "&ref("t")&" ")
termo = lcase(ref("t")&"")
strLimpar = " de | para | da | do | em | e | por | paciente | favor | agora | obrigado | gentileza | mim | pra | pro | também | porfavor "
strCom = "PRESCREVER:prescrição, prescrever, prescreva, prescrevo, clima de, receite, receituário, receita, receitar, recente, prescrição, escreva, escrevo, acrescente, residente, estrela, riqueza, princesa, residente|BUSCAR:baixa, acha, buscar, procure, procura, procurar, localize, localizar, achar, ache, encontrar, encontre|FICHA:prontuário, ficha, pista|ATESTADO:atestar, testado, testada, atestado, ateste|FORMULÁRIO:anamnese, formulário, laudo, laudos, laudar"

function Limpar(txt)
    splLimpar = split(strLimpar, "|")
    for ib=0 to ubound(splLimpar)
        if instr(txt, splLimpar(ib)) then
            txt = replace(txt, splLimpar(ib), " ")
        end if
    next
    Limpar = txt
end function


function replaceSeparador(txt)
    txt = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(txt, " e ", "+"), " também ", "+"), " mais ", "+"), " coloca ", "+"), " insere ", "+"), " adiciona ", "+"), " põe ", "+"), " mas ", "+"), " com ", "+"), " e também ", "+")
    replaceSeparador = txt
end function



function getComando()
    getComando = "BUSCAR"
    splCats = split(strCom, "|")
    for i=0 to ubound(splCats)
        Bloco = splCats(i)
        splBloco = split(Bloco, ":")
        for j=0 to ubound(splBloco)
            esteComando = splBloco(0)
            palavras = splBloco(1)
            splPalavras = split(palavras, ", ")
            for k=0 to ubound(splPalavras)
                Palavra = splPalavras(k)
                if instr(termoCompleto, Palavra) then
                    getComando = esteComando
                end if
            next
        next
    next
end function

function getPalavraChave()
    getPalavraChave = ""
    splCats = split(strCom, "|")
    for i=0 to ubound(splCats)
        Bloco = splCats(i)
        splBloco = split(Bloco, ":")
        for j=0 to ubound(splBloco)
            esteComando = splBloco(0)
            palavras = splBloco(1)
            splPalavras = split(palavras, ", ")
            for k=0 to ubound(splPalavras)
                Palavra = splPalavras(k)
                if instr(termoCompleto, Palavra) then
                    getPalavraChave = Palavra
                end if
            next
        next
    next
end function

Comando = getComando()
PalavraChave = getPalavraChave()

Conteudo = termoCompleto
if PalavraChave<>"" then
    splConteudo = split(Conteudo, PalavraChave)
    Conteudo = splConteudo(1)
end if
ConteudoLista = replaceSeparador(Conteudo)
Conteudo = Limpar(Conteudo)





if ref("recognitionPront")&"" <> "S" then
select case comando
    case "BUSCAR"
        response.write( "location.href='./?P=Busca&q="& Conteudo &"&Pers=1';" )
    case "PRESCREVER"
        if Pagina<>"pacientes" or (Pagina="pacientes" and id="") then
            response.write("alert('VOCÊ PRECISA ESTAR NA FICHA DE UM PACIENTE PARA RECEITAR.')")
        else
            response.write( " $('#abaPrescricoes').click(); " )
        end if

        session("sqlMedicamentos") = ""
        splLista = split(ConteudoLista, "+")
        for i=0 to ubound(splLista)
            Medicamento = splLista(i)
            Medicamento = trim(Limpar(Medicamento))
            if Medicamento<>"" then
                session("sqlMedicamentos") = session("sqlMedicamentos") & " OR Medicamento like '%"& replace(Medicamento, " ", "%") &"%' "
            end if
        next


    case "ATESTADO"
        if Pagina<>"pacientes" or (Pagina="pacientes" and id="") then
            response.write("alert('VOCÊ PRECISA ESTAR NA FICHA DE UM PACIENTE PARA ATESTAR.')")
        else
            response.write( " $('#abaAtestados').click(); " )
        end if

        session("sqlAtestados") = ""
        splLista = split(ConteudoLista, "+")
        for i=0 to ubound(splLista)
            Atestado = splLista(i)
            Atestado = trim(Limpar(Atestado))
            if Atestado<>"" then
                session("sqlAtestados") = session("sqlAtestados") & " OR NomeAtestado like '%"& replace(Atestado, " ", "%") &"%' "
            end if
        next


    case "FICHA"
        set conta = db.execute("select count(id) total from pacientes where NomePaciente like '%"&replace(Conteudo, " ", "%")&"%'")
        if ccur(conta("total"))=1 then
            set pac = db.execute("select id from pacientes where NomePaciente like '%"&replace(trim(Conteudo), " ", "%")&"%'")
            response.write(" location.href='./?P=pacientes&I="& pac("id") &"&Pers=1'; ")
        else
            response.write(" location.href='./?P=Busca&q="& Conteudo &"&Pers=1'; ")
        end if
end select
end if
%>

//alert("<%=session("sqlMedicamentos") %>");
//alert("Termo completo: '<%=termoCompleto %>' \n A palavra chave é '<%=PalavraChave %>' \n O comando utilizado foi '<%=comando%>' \n O conteúdo é '<%=Conteudo %>' \n Você está na página <%=Pagina %> ");

$.gritter.add({
    title: '<i class="far fa-microphone"></i> <%=Comando %>',
    text: '<%=Conteudo%>',
    class_name: 'gritter-success'
});
