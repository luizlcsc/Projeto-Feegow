<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
pacienteID = req("pacienteID")
usuarioID = req("usuarioID")
dataDe = req("dataDe")
dataAte = req("dataAte")


wherePaciente = ""
whereUsuario = ""
whereDataDe = ""
whereDataAte = ""

If pacienteID <> 0 Then
    wherePaciente = " pa.id = " & pacienteID
End if

If usuarioID <> 0 Then 

    whereUsuario = " lu.id = " & usuarioID

    If  wherePaciente <> "" Then
        whereUsuario = " and " & whereUsuario
    End if

End if

If dataDe <> "" Then
    dataDe = split(dataDe,"/")
    newDate = dataDe(2)&"-"&dataDe(1)&"-"&dataDe(0)
    whereDataDe = "pe.DHUp >= " & "'"&newDate&"'"

    If  whereUsuario <> "" or wherePaciente <> "" Then
        whereDataDe = " and " & whereDataDe
    End if

End if

If dataAte <> "" Then
    dataAte = split(dataAte,"/")
    newDate = dataAte(2)&"-"&dataAte(1)&"-"&dataAte(0)

    whereDataAte = "pe.DHUp <= " & "'"&newDate&"'"

    If  whereUsuario <> "" or wherePaciente <> "" or whereDataDe <> "" Then
        whereDataAte = " and " & whereDataAte
    End if
End if

sqlWhere = wherePaciente & whereUsuario & whereDataDe & whereDataAte

If sqlWhere <> "" Then
    sqlWhere = " where " & sqlWhere
End if

sql = " SELECT lu.id usuarioid, lu.Nome usuario, pa.NomePaciente, pe.PendenciaID, (SELECT DHUp FROM pendencia_logs pe2 WHERE pe2.PendenciaID = pe.PendenciaID ORDER BY id DESC LIMIT 1) dataregistro"&chr(13)&_
" FROM pendencia_logs pe                                                                           "&chr(13)&_
" INNER JOIN cliniccentral.licencasusuarios lu ON lu.id = pe.sysUser                               "&chr(13)&_
" INNER JOIN pacientes pa ON pa.id = pe.pacienteid                                                 "&chr(13)&_
sqlWhere&chr(13)&_
" GROUP BY pe.PendenciaID ORDER BY pe.DHUp DESC	                                                                           "&_
"  "

Set p = db.execute(sql)
%>
<table class="table table-striped" style="margin-top: 10px">
            <thead>
            <tr class="success">
                <th>Usuario</th>
                <th>Paciente</th>
                <th>Data</th>
                <th style="width: 1%"></th>
            </tr>
            </thead>
            <tbody>
    <% If p.eof Then %>
        <tr class="danger">
            <th colspan="100%">NENHUM DADO ENCONTRATO</td>
        </tr>    
    <% End if %>
   <% while not p.eof %>

<tr class="danger">
    <td><%= p("usuario") %></td>
    <td><%= p("NomePaciente") %></td>
    <td><%= p("dataregistro") %></td>
    <td nowrap="">
        <button type="button" class="btn btn-info btn-xs" onclick="logDetails(<%= p("usuarioid") %>, 0)">Usuário</button>
        <button type="button" class="btn btn-warning btn-xs" onclick="logDetails(0, <%= p("PendenciaID") %>)">Pendência</button>
    </td>
</tr>
<%
    p.movenext
    Wend
    p.Close
    Set p = Nothing 
%>
    </tbody>
</table>