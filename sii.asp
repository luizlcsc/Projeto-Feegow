<!--#include file="connect.asp"-->
<!--#include file="webhookFuncoes.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
'response.Write(sql)
set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName like '"&ref("resource")&"'")
if not dadosResource.eof then
    'aqui faz o insert
    if not isnull(dadosResource("mainFormColumn")) then
	    Coluna = ", "&dadosResource("mainFormColumn")
	    ValorColuna = ", '"&ref("campoSuperior")&"'"
    end if
	othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
	if not isnull(othersToAddSelectInsert) then
		spl = split(othersToAddSelectInsert, ", ")
		for i=0 to ubound(spl)
			compInsert = compInsert&", "&spl(i)
			valInsert = valInsert&", '"&ref(spl(i))&"'"
		next
	end if

end if


if ref("v")<>"" then

    JaInserido = false
    IF ref("cpf") <> "" AND ref("resource") = "pacientes" THEN

        cpfValue = RemoveCaracters(ref("CPF"),".-/ ")
        if getConfig("NaoPermitirCPFduplicado") = 1 then

            set PacienteDuplicadoSQL = db.execute("SELECT cpf,id, NomePaciente FROM pacientes WHERE (cpf='"&ref("CPF")&"' or cpf='"&cpfValue&"')  and sysActive=1 and '"&ref("CPF")&"'!='' ")
            if not PacienteDuplicadoSQL.eof then

                %>
                new PNotify({
                    title: 'Paciente com cpf duplicado. ',
                    text: '<%=PacienteDuplicadoSQL("NomePaciente") %>',
                    type: 'danger',
                    delay: 5000
                });
                <%
                response.end
            end if
        end if

        sql = "insert into "&ref("resource")&" (cpf,sysActive, sysUser,NomePaciente ) values ('"&cpfValue&"',1, "&session("User")&", '"&NomeNoPadrao(ref("v"))&"')"
        
        db_execute(sql)
        set getLast = db.execute("select id from "&ref("resource")&" where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")

        InsertId = getLast("id")
            %>
            $("#modal-components").modal("hide");

            $("#ageCPF").val('<%=cpfValue%>')
            $("#<%=ref("t") %> option").val("<%=InsertId %>");

            new PNotify({
                title: 'Registro salvo...',
                text: '<%=ref("v")%>',
                type: 'success',
                delay: 500
            });

        <%
        JaInserido = true
        response.end


    END IF

    IF NOT JaInserido THEN
        sql = "insert into "&ref("resource")&" (sysActive, sysUser, "&ref("showColumn")&Coluna&compInsert&") values (1, "&session("User")&", '"&NomeNoPadrao(ref("v"))&"'"&ValorColuna&valInsert&")"
        db_execute(sql)
        set getLast = db.execute("select id from "&ref("resource")&" where sysUser="&session("User")&" and sysActive=1 order by id desc LIMIT 1")

        InsertId = getLast("id")
    END IF



	if ref("resource")="pacientes" then
        'call addToQueue(116, InsertId)
	end if
%>
    $("#<%=ref("t") %> option").val("<%=InsertId %>");

    /*
    $("#<%=ref("t") %> option").text("<%=ref("v") %>");
    $("#<%=ref("t") %>").val("<%=getLast("id") %>");
    $("#<%=ref("t") %>").select2("destroy");
    $("#<%=ref("t") %>").select2();
    */
    //$("#<%=ref("t")%>").val("<%=getLast("id")%>");


        new PNotify({
            title: 'Registro salvo...',
            text: '<%=ref("v")%>',
            type: 'success',
            delay: 500
        });
<%end if %>