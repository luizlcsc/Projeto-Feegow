<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
acao = ref("acao")
id_procedimento = ref("id_procedimento")
id_profissional = ref("id_profissional")
id_unidade = ref("id_unidade")

Coluna = "SomenteProfissionais"
'<CONDIÇÃO EXISTENTE NO UPDATE DA VERSÃO ANTERIOR, NÃO INDENTIFIQUEI campo<>'' 'ProfProcAgenda.asp>'
'tela = req("tela")&""
'campo = "SomenteProfissionais"
'if tela = "ProfissionalExterno" then
'    campo = "SomenteProfissionaisExterno"
'elseif tela = "Fornecedores" then 
'    campo = "SomenteFornecedor"
'end if
'</CONDIÇÃO EXISTENTE NO UPDATE DA VERSÃO ANTERIOR, NÃO INDENTIFIQUEI campo<>'' 'ProfProcAgenda.asp>'

if acao = "I" then

    db.execute("INSERT INTO procedimento_profissional_unidade (id_profissional, id_procedimento, id_unidade) VALUES ("&id_profissional&","&id_procedimento&","&id_unidade&")")

    if isnumeric(id_unidade)&"" and isnumeric(id_profissional)&"" then
        set ProfissionalUnidades = db.execute("SELECT Unidades FROM profissionais WHERE id=0"&id_profissional)
        if not ProfissionalUnidades.eof then
            profissionais_Unidades = ProfissionalUnidades("Unidades")&", |"&id_unidade&"|"
            profissionais_Unidades = removeDuplicatas(RemoveCaracters(profissionais_Unidades," "),",")
            profissionais_Unidades = replace(profissionais_Unidades, ",",", ")

            db.execute("UPDATE profissionais p SET Unidades='"&profissionais_Unidades&"' WHERE p.id="&id_profissional)
        end if
        ProfissionalUnidades.close
        set ProfissionalUnidades = nothing
    end if
    
    IF (Coluna="SomenteProfissionais" or Coluna="SomenteProfissionaisExterno" or Coluna="SomenteFornecedor") AND isnumeric(id_profissional) AND isnumeric(id_procedimento) then
        set ProcedimentosUnidades = db.execute("SELECT "&Coluna&" FROM procedimentos p WHERE p.id = "&id_procedimento)
        if not ProcedimentosUnidades.eof then

            procedimentosProfissionalColuna = ProcedimentosUnidades(Coluna)&", |"&id_profissional&"|"
            procedimentosProfissionalColuna = removeDuplicatas(RemoveCaracters(procedimentosProfissionalColuna," "),",")
            procedimentosProfissionalColuna = replace(procedimentosProfissionalColuna, ",",", ")

            db.execute("update procedimentos SET "&Coluna&"='"&procedimentosProfissionalColuna&"' WHERE id="&id_procedimento)

        end if
        ProcedimentosUnidades.close
        set ProcedimentosUnidades = nothing

    END IF
    response.write("showMessageDialog('Procedimento Adicionado!', 'success');")

elseif acao = "D" then

    db.execute("DELETE FROM procedimento_profissional_unidade WHERE id_profissional = "&id_profissional&" AND id_procedimento = "&id_procedimento&" AND id_unidade = "&id_unidade)

    ProfissionalUnidadesWhereSQL =  " id=0"&id_profissional&" AND Unidades like '%|"&id_unidade&"|%'"
    SET ProfissionalUnidades = db.execute("SELECT Unidades FROM profissionais WHERE "&ProfissionalUnidadesWhereSQL)
    if not ProfissionalUnidades.eof then

        profissionais_unidades = "'"&trim(replace(ProfissionalUnidades("Unidades"),"|"&id_unidade&"|",""))&"'"
        profissionais_unidades = replace(profissionais_unidades,"',","'")
        profissionais_unidades = replace(profissionais_unidades,", ,","")
        profissionais_unidades = replace(profissionais_unidades,",'","'")
            
        db.execute("UPDATE profissionais SET Unidades="&profissionais_unidades&" WHERE "&ProfissionalUnidadesWhereSQL)
        
    end if
    ProfissionalUnidades.close
    set ProfissionalUnidades = nothing

    IF (Coluna="SomenteProfissionais" or Coluna="SomenteProfissionaisExterno" or Coluna="SomenteFornecedor") AND isnumeric(id_profissional) AND isnumeric(id_procedimento) then
        set ProcedimentosUnidades = db.execute("SELECT "&Coluna&" FROM procedimentos p WHERE p.id = "&id_procedimento&" AND "&Coluna&" LIKE '%|"&id_profissional&"|%'")
        if not ProcedimentosUnidades.eof then

            procedimentosProfissionalColuna = "'"&trim(replace(ProcedimentosUnidades(Coluna),"|"&id_profissional&"|",""))&"'"
            procedimentosProfissionalColuna = replace(procedimentosProfissionalColuna,"',","'")
            procedimentosProfissionalColuna = replace(procedimentosProfissionalColuna,", ,","")
            procedimentosProfissionalColuna = replace(procedimentosProfissionalColuna,",'","'")

            db.execute("update procedimentos SET "&Coluna&"="&procedimentosProfissionalColuna&" WHERE id="&id_procedimento)
            
        end if

    END IF

    response.write("showMessageDialog('Procedimento Removido!', 'success');")

end if
%>
