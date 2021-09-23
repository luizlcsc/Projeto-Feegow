<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
acao = ref("acao")
id_procedimento = ref("id_procedimento")
id_profissional = ref("id_profissional")
id_unidade = ref("id_unidade")

if acao = "I" then

    'db.execute("INSERT INTO procedimento_profissional_unidade (id_profissional, id_procedimento, id_unidade) VALUES ("&id_profissional&","&id_procedimento&","&id_unidade&")")

    if isnumeric(id_unidade)&"" and isnumeric(id_profissional)&"" then
    set ProfissionalUnidades = db.execute("SELECT Unidades FROM profissionais WHERE id=0"&id_profissional)
        if not ProfissionalUnidades.eof then
            profissionais_Unidades = ProfissionalUnidades("Unidades")&", |"&id_unidade&"|"
            profissionais_Unidades = removeDuplicatas(RemoveCaracters(profissionais_Unidades," "),",")
            profissionais_Unidades = replace(profissionais_Unidades, ",",", ")

            'db.execute("UPDATE profissionais p SET Unidades='"&profissionais_Unidades&"' WHERE p.id="&id_profissional)
        end if
    end if



updateLOUCO = "QUERYS"&chr(13)
updateLOUCO = updateLOUCO& "update procedimentos set "&campo&"=replace("&campo&", ', |"&ProfissionalID&"|', '') where "&campo&" like '%, |"& ProfissionalID &"|%'"&chr(13)
updateLOUCO = updateLOUCO& "update procedimentos set "&campo&"=replace("&campo&", '|"&ProfissionalID&"|, ', '') where "&campo&" like '%|"& ProfissionalID &"|, %'"&chr(13)        
updateLOUCO = updateLOUCO& "update procedimentos set "&campo&"=replace("&campo&", '|"&ProfissionalID&"|', '') where "&campo&" like '%|"& ProfissionalID &"|%'"  &chr(13)         

updateLOUCO = updateLOUCO& "update procedimentos set "&campo&"=concat( ifnull("&campo&", ''), if("&campo&" is null or "&campo&"='', '', ', ') ,'|"&ProfissionalID&"|' ) where id in("& replace(ref("ProcedimentosAgenda"), "|", "") &")"

'
updateLOUCO = updateLOUCO&"FORMS"&chr(13)&replace(request.form(),"&",chr(13))  & chr(13)&chr(13)

updateLOUCO = updateLOUCO&"VERIFICAR UPDATES DE 'ProfProcAgenda.asp'"
'
'valores = profissionais_Unidades
'valoresTratados =  removeDuplicatas(RemoveCaracters(valores," "),",") 


'updateLOUCO = updateLOUCO&chr(13)&"REGISTROS: "&chr(13)&valoresTratados

response.write("console.log(`"&updateLOUCO&"`);")


elseif acao = "D" then

    db.execute("DELETE FROM procedimento_profissional_unidade WHERE id_profissional = "&id_profissional&" AND id_procedimento = "&id_procedimento&" AND id_unidade = "&id_unidade)

    set totalUnidades = db.execute("SELECT COUNT(*) total FROM procedimento_profissional_unidade WHERE id_unidade = "&id_unidade&" AND id_profissional = "&id_profissional)

    if ccur(totalUnidades("total")) = 0 then

        'db.execute("update profissionais set Unidades=replace(Unidades, ', |"&id_unidade&"|', '') where Unidades like '%, |"& id_unidade &"|%'")
        'db.execute("update profissionais set Unidades=replace(Unidades, '|"&id_unidade&"|, ', '') where Unidades like '%|"& id_unidade &"|, %'")
        'db.execute("update profissionais set Unidades=replace(Unidades, '|"&id_unidade&"|', '') where Unidades like '%|"& id_unidade &"|%'")

    end if

end if
%>