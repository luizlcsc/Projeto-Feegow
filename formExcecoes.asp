        <form method="post" name="frmH" target="assHorarios" action="assHorarios.asp?ProfissionalID=<%=ProfissionalID%>&LocalID=<%=LocalID%>&Procedimentos=<%=Procedimentos%>&Especialidades=<%=Especialidades%>">
            <input type="hidden" name="h" value="h" />

            <table width="868" align="center" class="table table-striped table-bordered table-hover table-condensed">
                <thead>
                    <tr class="alert">
                        <th valign="bottom"><%=quickfield("datepicker", "DataDe", "De", 12, date(), "", "", "") %></th>
                        <th valign="bottom"><%=quickfield("datepicker", "DataA", "Até", 12, date(), "", "", "") %></th>
                        <th valign="bottom"><%=quickfield("timepicker", "HoraDe", "Das", 12, "08:00", "", "", "") %></th>
                        <th colspan="2" valign="bottom"><%=quickfield("timepicker", "HoraA", "Às", 12, "18:00", "", "", "") %></th>
                        <th colspan="2" valign="bottom" nowrap><label>Intervalo (min)</label><br />
                            <input type="number" name="Intervalo" class="form-control" size="5" maxlength="5" value="15" min="1" />
                        </th>
                    </tr>
                    <tr class="alert">

                        <%
                    if ProfissionalID>=0 then %>
                        <th width="20%" valign="bottom"><label>Profissional</label><br />
                            <select name="ProfissionalID" class="form-control">
                                <option value="0">Selecione</option>
                                <%
                            set pProf=db.execute("select * from profissionais where sysActive=1 order by NomeProfissional")
                        while not pProf.EOF
                                %><option value="<%=pProf("id")%>" <%if ProfissionalID=pProf("id") then%> selected="selected" <%end if%>><%=pProf("NomeProfissional")%></option>
                                <%
                            pProf.moveNext
                        wend
                        pProf.close
                        set pProf=nothing
                                %>
                            </select>
                        </th>

                        <%
                    else
                        %>
                        <input type="hidden" name="ProfissionalID" id="ProfissionalID" value="<%=ProfissionalID %>" />
                        <%
                    end if
                        %>
                        <th valign="bottom"><label>Local</label><br />
                            <select name="LocalID" class="form-control">
                                <option value="0">Selecione</option>
                                <%
          set l=db.execute("select l.*, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where l.sysActive=1 order by l.NomeLocal")
          while not l.EOF
                                %><option value="<%=l("id")%>" <%if LocalID=l("id") then%> selected="selected" <%end if%>><%=l("NomeLocal")%></option>
                                <%
          l.moveNext
          wend
          l.close
          set l=nothing
                                %>
                            </select>
                        </th>
                        <th  valign="bottom">
                        <%=quickField("multiple", "Procedimentos", "Procedimentos", 12, "", "select id, NomeProcedimento from procedimentos where ativo='on' and sysActive=1 order by NomeProcedimento", "NomeProcedimento", "")%>
                        </th>


                        <th  valign="bottom">
                        <%=quickField("multiple", "Especialidades", "Especialidades", 12, "", "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "")%>
                        </th>

                        <th  valign="bottom">
                        <%
                        sqlConvenios = "select 'P' id, ' PARTICULAR' NomeConvenio UNION ALL select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' AND COALESCE((SELECT CASE WHEN SomenteConvenios LIKE '%|NONE|%' THEN FALSE ELSE NULLIF(SomenteConvenios,'') END FROM profissionais  WHERE id = "&treatvalzero(ProfissionalID)&") LIKE CONCAT('%|',id,'|%'),TRUE) "&franquia("AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")&" order by NomeConvenio"
                        %>
                        <%=quickField("multiple", "Convenios", "Limitar os convênios aceitos neste período", 12, Convenios, sqlConvenios, "NomeConvenio", "")%>
                        
                        </th>

                        <th valign="bottom" style="vertical-align:top;">
                            <label>Compartilhar</label>
                            <input type="checkbox" class="ace" name="Compartilhada" value="S" style="margin-left:5px" checked="">
                        </th>
                        <th valign="bottom"  style="vertical-align:top;">
                            <button type="submit" name="Cadastrar" style="margin-top:8px" class="btn btn-block btn-alert" value="Cadastrar"><i class="far fa-plus"></i></button>
                        </th>
                    </tr>
                </thead>
            </table>
        </form>
<script >
$(".date-picker").mask("99/99/9999");
</script>
