<!--#include file="connect.asp"-->
<%

idpaciente = ref("idpaciente")
nome = UCase(ref("nome"))
CPF = ref("CPF")
Nascimento = ref("Nascimento")
Sexo = ref("Sexo")
Observacoes = UCase(ref("Observacoes"))
Tel1 = ref("Tel1")
Cel1 = ref("Cel1")
Cel2 = ref("Cel2")
Origem = ref("Origem")
Cep = ref("Cep")
Endereco = UCase(ref("Endereco"))
Numero = ref("Numero")
Complemento = UCase(ref("Complemento"))
Bairro = UCase(ref("Bairro"))
Cidade = UCase(ref("Cidade"))
Estado = UCase(ref("Estado"))
Pais = UCase(ref("Pais"))

if Nascimento&"" = "" then 
    Nascimento = "NULL"
end if

if Pais&"" = "" then 
    Pais = "0"
end if


sql = "update pacientes set NomePaciente = '"&nome&"', Nascimento="&mydatenull(Nascimento)&", Tel1 = '"&Tel1&"', Cel1 = '"&Cel1&"', Cel2 = '"&Cel2&"', CPF = '"&CPF&"', Sexo = '"&Sexo&"', Origem = '"&Origem&"', " &_ 
        " cep = '"&Cep&"', endereco = '"&Endereco&"', bairro = '"&Bairro&"', numero = '"&Numero&"', complemento = '"&Complemento&"', cidade = '"&Cidade&"', estado = '"&Estado&"', pais = '"&Pais&"', Observacoes = '"&Observacoes&"' where id = " & idpaciente
db.execute(sql)
%>
new PNotify({
    title: 'Sucesso!',
    text: 'Atualizado com sucesso.',
    type: 'success',
    delay: 2500
});

naoSalvo = true;
<!--#include file="disconnect.asp"-->