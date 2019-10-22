<!--#include file="connect.asp"-->
<%
id = ccur(req("I"))-1000000000
op = req("OP")
recursoPermissaoUnimed = recursoAdicional(12)

if recursoPermissaoUnimed=4 and (session("Banco")="clinic6224" or session("Banco")="clinic6581" or session("Banco")="clinic6501") then
    if op="insert" then
        set p = db.execute("select * from clinic5803.pacientes where id="&id)
        if not p.eof then
            'Antes de gravar vou validar para ver se o paciente ja foi cadastrado
            sql = "insert into pacientes (NomePaciente, Nascimento, CEP, Cidade, Estado, Endereco, Numero, Complemento, Bairro, Tel1, Documento, Email1, CPF, Matricula1, idImportado, sysUser, sysActive) values ('"&p("NomePaciente")&"', "&mydatenull(p("Nascimento"))&", '"&p("CEP")&"', '"&p("Cidade")&"', '"&p("Estado")&"', '"&p("Endereco")&"', '"&p("Numero")&"', '"&p("Complemento")&"', '"&p("Bairro")&"', '"&p("Tel1")&"', '"&p("Documento")&"', '"&p("Email1")&"', '"&p("CPF")&"', '"&p("Matricula1")&"', "&id&", "&session("User")&", 1)"
            'response.write(sql)
            db_execute(sql)

            set pacienteInserido = db.execute(" select id from pacientes order by id desc limit 1 ")

            %>
            $("#PacienteID").html('<option value="<%=pacienteInserido("id")%>"><%=p("NomePaciente")%></option>').change();
            <%
        end if
    else
        set p = db.execute("select * from clinic5803.pacientes where id="&id)
        if not p.eof then
            %>
            $("#NomePaciente").val("<%=p("NomePaciente") %>");
            $("#Nascimento").val("<%=p("Nascimento") %>");
            $("#CEP").val("<%=p("CEP") %>");
            $("#Cidade").val("<%=p("Cidade") %>");
            $("#Estado").val("<%=p("Estado") %>");
            $("#Endereco").val("<%=p("Endereco") %>");
            $("#Numero").val("<%=p("Numero") %>");
            $("#Complemento").val("<%=p("Complemento") %>");
            $("#Bairro").val("<%=p("Bairro") %>");
            $("#Tel1").val("<%=p("Tel1") %>");
            $("#Documento").val("<%=p("Documento") %>");
            $("#Email1").val("<%=p("Email1") %>");
            $("#CPF").val("<%=p("CPF") %>");
            $("#Matricula1").val("<%=p("Matricula1") %>");
            <%
        end if
    end if
end if
%>