<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/Environment.asp"-->


<form id="frmOC" >

    <input type="hidden" name="E" value="E" />
<%

E = ref("E")
currentVersionFolder = replace(replace(Request.ServerVariables("PATH_INFO"),"index.asp",""),"/","")
AppEnv = getEnv("FC_APP_ENV", "local")

if AppEnv<>"production" then
    if ModoFranquia then
        currentVersionFolder="v7.6"
    else
        currentVersionFolder="main"
    end if
end if

'AND JSON_SEARCH(Versoes,'one','"&currentVersionFolder&"') IS NOT null

set confNew = db.execute("select *, ifnull(IsClinicCentral,0) VIsClinicCentral from cliniccentral.config_opcoes where sysActive = 1 and (TipoConfig != 'APP' OR TipoConfig IS NULL)  order by secao ")
LicencaID = replace(session("Banco"), "clinic", "")
if E = "E" then

    if not confNew.eof then
        while not confNew.eof
            valor = ref(confNew("Coluna"))

            if ccur(confNew("VIsClinicCentral")) = 1 then
                'response.write("select * from cliniccentral.config where ConfigID = " & confNew("id") & " AND LicencaID = " & LicencaID)
                set confGeral = dbc.execute("select * from cliniccentral.config where ConfigID = " & confNew("id") & " AND LicencaID = " & LicencaID)
                if not confGeral.eof then
                    dbc.execute("update cliniccentral.config set Valor = '" & Valor & "' where ConfigID = " & confNew("id") & " AND LicencaID = " & LicencaID)
                else
                    dbc.execute("insert into cliniccentral.config(ConfigID, LicencaID, Valor, sysActive, sysUser) values(" & confNew("id") & ", " &LicencaID& ", '" & Valor & "', 1, " & session("user") & ")")
                end if
            else
                set confGeral = db.execute("select * from config_gerais where ConfigID = " & confNew("id") & " ")
                'if valor <> "" then
                    if not confGeral.eof then
                        db.execute("update config_gerais set Valor = '" & Valor & "' where ConfigID = " & confNew("id") & " ")
                    else
                        db.execute("insert into config_gerais(ConfigID, Valor, sysActive, sysUser) values(" & confNew("id") & ", '" & Valor & "', 1, " & session("user") & ")")
                    end if
                'else
                '    if not confGeral.eof then
                '        db.execute("update config_gerais set Valor = '" & confNew("ValorPadrao") & "' where ConfigID = " & confNew("id") & " ")
                '    end if
                'end if
            end if
            confNew.movenext
        wend
        confNew.movefirst
    end if
else


titulo = ""
i = 0
if not confNew.eof then
    while not confNew.eof
        if UCase(titulo) <> UCase(confNew("Secao")) then
            if i > 0 then
                response.write("<div class='row'><br><hr /></div>")
            end if
            titulo = UCase(confNew("Secao"))
            response.write("<h2 class='mb20 mt30'>" & titulo & "</h2>")
        end if

        valorPadrao = confNew("ValorPadrao")

        if ccur(confNew("VIsClinicCentral")) = 1 then
          '  response.write("select * from cliniccentral.config where ConfigID = " & confNew("id") & " AND LicencaID = " & LicencaID)
            set confGeral = dbc.execute("select * from cliniccentral.config where ConfigID = " & confNew("id") & " AND LicencaID = " & LicencaID)
            if not confGeral.eof then
                valorPadrao = confGeral("Valor")
            end if
        else
         '   response.write("select * from config_gerais where ConfigID = " & confNew("id") & " ")
            set confGeral = db.execute("select * from config_gerais where ConfigID = " & confNew("id") & " ")
            if not confGeral.eof then
                valorPadrao = confGeral("Valor")
            end if
        end if

        call createFields(confNew("TipoCampo"), confNew("Coluna"), confNew("Label"), 6, valorPadrao,  confNew("ValorMarcado"), "", confNew("selectColumnToShow"), confNew("id"), confNew("selectSQL"))
        i = i + 1
        confNew.movenext
    wend
end if


function createFields(fieldType, fieldName, label, width, fieldValue, defaultValue, sqlOrClass, columnToShow, idConf, selectSQL)

    if label<>"" then
		abreDivBoot = "<div class=""col-md-"&width&" qf"" id=""qf"&lcase(fieldName)&""">"
		fechaDivBoot = "</div>"
		if label=" " then
			LabelFor = ""
		else
			LabelFor = "<label for="""&fieldName&""">"&label&"</label><br />"
		end if
    else
		abreDivBoot = ""
		fechaDivBoot = ""
		LabelFor = ""
	end if

	response.Write(abreDivBoot)

    select case fieldType
        case "simpleCheckboxHidden"
    			%>
    			<div class="checkbox-custom checkbox-primary" style="display: none">
                    <input type="checkbox" class="ace <%=sqlOrClass%>" name="<%= fieldName %>" id="<%= fieldName %>" value="<%=defaultValue%>"<%if fieldValue=defaultValue then response.write("checked") end if %> /> <label class="checkbox" for="<%= fieldName %>"> <%= label %></label>
    			</div>
    			<%
		case "simpleCheckbox"
			%>
			<div class="checkbox-custom checkbox-primary">
                <input type="checkbox" class="ace <%=sqlOrClass%>" name="<%= fieldName %>" id="<%= fieldName %>" value="<%=defaultValue%>"<%if fieldValue=defaultValue then response.write("checked") end if %> /> <label class="checkbox" for="<%= fieldName %>"> <%= label %></label>
			</div>
			<%
        case "number"
			%>
			<div class="form-group">
                <%= label %>
                <input type="number" class="ace form-control  <%=sqlOrClass%>" name="<%= fieldName %>" id="<%= fieldName %>" value="<%=fieldValue%>" />
			</div>
			<%
        case "text"
			%>
			<div class="form-group">
                <%= label %>
                <input type="text" class="ace form-control  <%=sqlOrClass%>" name="<%= fieldName %>" id="<%= fieldName %>" value="<%=fieldValue%>" />
			</div>
			<%
		case "multipleSelect"
		     set conf = db.execute("select * from config_gerais where ConfigID = "&idConf)

		     valorConf = ""
		     if not conf.eof then
		       valorConf = conf("Valor")
		     end if

		    %>
            <div class="form-group" style="margin-top: 20px;">
                <%= label %>
                <%=quickField("multiple", fieldName, "", 3, valorConf, selectSQL, columnToShow, "")%>
            </div>
		    <%
		case "simpleSelect"
		     set conf = db.execute("select * from config_gerais where ConfigID = "&idConf)

		     valorConf = ""
		     if not conf.eof then
		       valorConf = conf("Valor")
		     end if

		    %>
            <div class="form-group" >
                <%= label %>
                <%=quickField("simpleSelect", fieldName, "", 3, valorConf, selectSQL, columnToShow, "")%>
            </div>
		    <%
    end select
	response.Write(fechaDivBoot)
end function

%>
    <div class="clearfix form-actions">
        <button class="btn btn-primary pull-right btnsave"><i class="far fa-save"></i> Salvar</button>
    </div>
</form>
<script>


$(function(){
    $(".btnsave").on('click', function(){
        $.post('novasConfiguracoes.asp', $("#frmOC").serialize(), function(data){
            showMessageDialog("Salvo com sucesso", "success")
        })
        return false;
    })
})
<!--#include file="JQueryFunctions.asp"-->
</script>
<%
end if
%>

