<!--#include file="connect.asp"-->
<select name="ProfissionalID" id="ProfissionalID">
     <option value="">Selecione o profissional</option>
     <option value="ALL">Todos os profissionais</option>
     <%

 sqlunidades  = "select Unidades from " & session("table") &" where id = " & session("idInTable")
 set UnidadesUser  = db.execute(sqlunidades)
 UnidadesUser = replace(UnidadesUser("Unidades"), "|", "")
 lista = split(UnidadesUser, ",")
 sqlOR = ""
 for z=0 to ubound(lista)
     sqlOR = sqlOR & " or prof.unidades like '%|"& replace(lista(z), " ","") &"|%' "
     'response.write ("<script> console.log('"&lista(z)&"');</script>")
 next
 sqlOR = " AND (false " & sqlOR & ") "
 sql = " SELECT und.NomeFantasia, prof.id, prof.unidades, concat(ifnull(trat.Tratamento,''), ' ',LEFT(prof.NomeProfissional, 20)) NomeProfissional, prof.NomeSocial, prof.Cor, prof.Ativo " &_
       " FROM Profissionais prof " &_
       " INNER JOIN agendamentos age ON age.ProfissionalID=prof.id " &_
       " LEFT JOIN locais l ON l.id=age.LocalID " &_
       " LEFT JOIN tratamento trat on trat.id=prof.TratamentoID " &_
       " LEFT JOIN (select un.id, un.NomeFantasia from sys_financialcompanyunits un where un.sysActive=1 UNION ALL select '0', e.NomeFantasia from empresa e) und ON und.id=l.UnidadeID" &_
       " WHERE (prof.NaoExibirAgenda != 'S' OR prof.NaoExibirAgenda is null OR prof.NaoExibirAgenda='') " &_
       " AND prof.sysActive=1 and age.Data=curdate() " &_
       " " &  sqlOR &_
       " GROUP BY prof.id order by und.NomeFantasia ASC, prof.NomeProfissional "
 set Prof = db.execute(sql)


 UnidadeAtual = ""
 UltimaUnidade = "0"
 TemOptgroup = False
 while not Prof.EOF
     UnidadeAtual = Prof("NomeFantasia")
     if lcase(session("table"))="profissionais" and session("idInTable")=Prof("id") then
         selected = " selected=""selected"""
         selectedPropf = Prof("id")

     else
         if session("UltimaAgenda")=cstr(Prof("id")) then
             selected = " selected=""selected"""
             selectedPropf = Prof("id")
         else
             selected = ""
         end if
     end if

     NomeProfissional = Prof("NomeProfissional")
     unidadesprof = Prof("unidades")
     if Prof("NomeSocial")&"" <> "" then
          NomeProfissional=Prof("NomeSocial")
     end if
     if UnidadeAtual&""<>UltimaUnidade&"" then
         if TemOptgroup then
             %>
             </optgroup>
             <%
         end if
         TemOptgroup=True
         %>
         <optgroup label="<%=UnidadeAtual%>">
         <%
     end if


     %>
     <option <%=selected%> style="border-left: <%=Prof("Cor")%> 10px solid; background-color: #fff;" value="<%=Prof("id")%>"><%=ucase(NomeProfissional)%></option>
     <%
     if ListProID&""<>"" then
         sep=","
     end if
     ListProID = ListProID&sep&Prof("id")

     UltimaUnidade=UnidadeAtual
 Prof.movenext
 wend
 Prof.close
 set Prof = nothing


     %>
 </select>