<!--#include file="connect.asp"-->
<%
usuarioID = req("usuarioID")
pendenciaID = req("pendenciaID")

where = ""

If usuarioID <> 0  Then
    where = "where pao.sysUser = " & usuarioID
End if  

If pendenciaID <> 0  Then
    where = "where pao.PendenciaID = " &pendenciaID
End if  

sqlRegistroObservacao = " SELECT pao.id,                                                                                                                                                        "&chr(13)&_
" pao.sysUser usuarioid,                                                                                                                                                                           "&chr(13)&_
" DATE_FORMAT(pao.DHUp,'%d/%m/%Y') Data,                                                                                                                                                           "&chr(13)&_
" DATE_FORMAT(pao.DHUp,'%H:%i') Hora,                                                                                                                                                              "&chr(13)&_
" lu.nome usuario, pao.ObsGeral                                                                                                                                                                                "&chr(13)&_
" FROM pendenciaadministracaoobservacao pao                                                                                                                                                                              "&chr(13)&_
" JOIN cliniccentral.licencasusuarios lu ON lu.id = pao.sysUser                                                                                                                                    "&chr(13)&_
where                                                                                                                                                                                       &chr(13)&_
" ORDER BY pao.DHUp DESC                                                                                                                                                                           "
%>

<div>
    <div class="panel-body">
        <div class="bs-component">
                    <div class="tab-content pn br-n">
                        <div id="Pendencia" class="tab-pane active widget-box transparent">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data Registro</th>
                                        <th>Hora Registro</th>
                                        <th>Usuario</th>
                                        <th>Observacao</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% 
                                Set p = db.execute(sqlRegistroObservacao)
                                If p.eof Then %>
                                    <tr class="danger">
                                        <td colspan="100%">NENHUM DADO ENCONTRADO</td>
                                    </tr>
                                <% end if 
                                    while not p.eof 
                                %>
                                        <tr>
                                        <td><%= p("id") %></td>
                                        <td><%= p("Data") %></td>
                                        <td><%= p("Hora") %></td>
                                        <td><%= p("usuario") %></td>
                                        <td><%= p("ObsGeral") %></td>
                                    </tr>
                                <% 
                                    p.movenext
                                    Wend
                                    p.Close
                                    Set p = Nothing 
                                %>    
                                </tbody>
                            </table>
                        </div>
                    </div>
        </div>
    </div>
</div>