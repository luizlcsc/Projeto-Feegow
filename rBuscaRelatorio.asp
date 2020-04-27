<!--#include file="connect.asp"-->
<%
FormID= ref("FormID")
CamposExibir= replace(ref("CamposExibir"), "|", "")

if CamposExibir="" then
    CamposExibir=0
end if

set FormConfigSQL = db.execute("SELECT * FROM buiforms WHERE sysActive=1 AND id="&FormID)

if not FormConfigSQL.eof then
    set CamposSQL = db.execute("SELECT * FROM buicamposforms WHERE FormID="&FormID&" AND TipoCampoID=2")

    sqlFiltroData = ""
    while not CamposSQL.eof

        if ref("DataDe"&CamposSQL("id"))<>"" then
            sqlFiltroData = " AND DATE_FORMAT(STR_TO_DATE(`"&CamposSQL("id")&"`, '%d/%m/%Y'), '%Y-%m-%d') BETWEEN "&mydatenull(ref("DataDe"&CamposSQL("id")))&" AND "&mydatenull(ref("DataAte"&CamposSQL("id")))&"  "
        end if

    CamposSQL.movenext
    wend
    CamposSQL.close
    set CamposSQL=nothing


    sql = "SELECT f.*, pac.NomePaciente, conv.NomeConvenio FROM `_"&FormID&"` f INNER JOIN pacientes pac ON pac.id=f.PacienteID LEFT JOIN convenios conv ON conv.id=pac.ConvenioID1 LEFT JOIN buiformspreenchidos bfp ON bfp.id=f.id  WHERE bfp.sysActive=1 AND 1=1 "&sqlFiltroData
    set FormSQL = db.execute(sql)

    if not FormSQL.eof then
    %>
    <h2><%=FormConfigSQL("Nome")%></h2><br><br>
    <div class="row">
        <div class="col-md-12">
            <table class="table table-striped">
                <thead>
                     <tr>
                        <th>Data e Hora</th>
                        <th>Usuário</th>
                        <th>Paciente</th>
                        <th>Convênio</th>
                     <%
                     campos = ""
                     set CamposHeaderSQL = db.execute("SELECT * FROM buicamposforms WHERE FormID="&FormID&" AND ID IN ("&CamposExibir&")")

                     while not CamposHeaderSQL.eof
                     %>
                        <th><%=CamposHeaderSQL("RotuloCampo")%></th>
                  <%
                        if campos="" then
                            campos= CamposHeaderSQL("id")
                        else
                            campos= campos&","&CamposHeaderSQL("id")
                        end if
                     CamposHeaderSQL.movenext
                     wend
                     CamposHeaderSQL.close
                     set CamposHeaderSQL=nothing
                  %>
                  </tr>
                </thead>
                <tbody>
                <%

    while not FormSQL.eof

                %>
                    <tr>
                        <td><%=FormSQL("DataHora")%></td>
                        <td><%=nameInTable(FormSQL("sysUser"))%></td>
                        <td><a target="_blank" href="./?P=Pacientes&Pers=1&I=<%=FormSQL("PacienteID")%>"><%=FormSQL("NomePaciente")%></a></td>
                        <td><%=FormSQL("NomeConvenio")%></td>
                        <%
                        camposSplit = split(campos, ",")

                        for i=0 to ubound(camposSplit)
                            if camposSplit(i)&""<>"" then
                                ValorCampo = FormSQL(camposSplit(i))

                                ID=replace(camposSplit(i),",00","")

                                if ID<>"" then
                                    set TipoCampoSQL = db.execute("SELECT TipoCampoID FROM buicamposforms WHERE id="&treatvalnull(ID))
                                    if not TipoCampoSQL.eof then
                                        TipoCampo = TipoCampoSQL("TipoCampoID")

                                        if TipoCampo=6 or TipoCampo=4 or TipoCampo=5 then
                                            ID=replace(ID,",00","")

                                            if instr(ValorCampo, "|")>0 or (ValorCampo<>"" and isnumeric(ValorCampo)) then
                                                sql2="SELECT group_concat(Nome SEPARATOR ', ') as Nome FROM buiopcoescampos WHERE CampoID="&ID&" AND id IN("&replace(ValorCampo,"|","")&")"
                                                set ValorOpcaoSQL = db.execute(sql2)
                                                
                                                if not ValorOpcaoSQL.eof then
                                                    ValorCampo = ValorOpcaoSQL("Nome")
                                                end if
                                            end if
                                        end if
                                        
                                        if TipoCampo=16  then
                                            set pcid = db.execute("select * from cliniccentral.cid10 where id = '"&ValorCampo&"'")
                                            if not pcid.eof then
                                                ValorCampo = pcid("Codigo") &" - "& pcid("Descricao")
                                            end if
                                        end if
                                        
                                    end if
                                end if

                                %>
                                <td><%=ValorCampo%></td>
                                <%
                            end if
                        next
                        %>

                    </tr>
                    <%

    FormSQL.movenext
    wend
    FormSQL.close
    set FormSQL=nothing

                    %>
                </tbody>
            </table>
        </div>
    </div>
    <%
    end if
end if
%>