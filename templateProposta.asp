<!--#include file="connect.asp"-->









                                                    POSTA DO EMAIL JA TODOS OS POSTS PRO INDX Q JA RECEBE O POST NO TEMPLATE DA PROPOSTA EM PHP EM STRING, GERA O PDF E CHAMA O ASP Q ENVIA O EMAIL













<%
PropostaID = req("PropostaID")
set prop = db.execute("select prop.*, pac.NomePaciente, pac.Email1, pac.Email2 from propostas prop LEFT JOIN pacientes pac on pac.id=prop.PacienteID where prop.id="&PropostaID)
set itens = db.execute("select i.*, p.NomeProcedimento from itensproposta i LEFT JOIN procedimentos p on p.id=i.ItemID where PropostaID="&PropostaID)
while not itens.eof
    DescItens = DescItens & "<h3>Valor por "& lcase(itens("NomeProcedimento")&"") &": R$ "& fn(itens("ValorUnitario")-itens("Desconto")+itens("Acrescimo")) &" x "& itens("Quantidade") &"</h3>"
itens.movenext
wend
itens.close
set itens=nothing

set pema = db.execute("select Email from cliniccentral.licencasusuarios where id="&req("U"))

%>
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <meta charset="utf-8" />
    <style>
        body {
            font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;
            font-weight: lighter;
            line-height: 35px;
        }
    </style>
</head>
<body>
    <div style="position: absolute; margin-top: 440px; left: 90px; color: #fff;">
        <h2>Proposta de Implementação</h2>
        <h1><%=ucase(prop("NomePaciente")&"")%></h1>
    </div>
    <img src="http://localhost/feegowclinic/pdf/img/p1.png" width="100%" />

    <pagebreak>
   
            <div style="position:absolute; margin-top:230px; left:590px; width:460px;">
     <h3>
        Fundada em 2008, somos uma empresa de tecnologia que tem como missão desenvolver soluções para clínicas e consultórios médicos  baseando-se na experiência do usuário e os problemas que ele encontra no dia-a-dia.
         </h3>
            </div>
         
    <img src="http://localhost/feegowclinic/pdf/img/p2.png" width="100%" />

    <pagebreak> 
    <img src="http://localhost/feegowclinic/pdf/img/p3.png" width="100%" />

    <pagebreak> 
    <img src="http://localhost/feegowclinic/pdf/img/p4.png" width="100%" />

    <pagebreak> 




    <img src="http://localhost/feegowclinic/pdf/img/p5.png" width="100%" />

    <pagebreak> 
    <img src="http://localhost/feegowclinic/pdf/img/p6.png" width="100%" />


    <pagebreak> 


        <div style="top:140px; left:83px; position:absolute; width:500px">
            <h1>INVESTIMENTO MENSAL</h1>
            <%=DescItens %>
            <br />
            <h2>Mensalidade total -> R$ <%=fn(prop("Valor")) %></h2>
            <h2>Taxa de habilitação -> ISENTO</h2>
            <br />
            <h4>
                A mensalidade acima calculada contempla os seguintes serviços/benefícios:
                <ul>
                    <li>Suporte técnico ilimitado via telefone, chat, e-mail, acesso remoto e helpdesk, de segunda a sexta em horário comercial.</li>
                    <li>Treinamento aos funcionários da clínica através dos canais acima mencionados.</li>
                    <li>Infraestrutura de hospedagem do software e seu banco de dados em nuvem, com total infraestrutura e segurança.</li>
                    <li>Espelhamento de dados e backups diários automatizados.</li>
                    <li>Obs.: Proposta tem que ter logo dos aplicativos e ser um resumo de tudo o que o sistema possui, sem esquecer de nenhum detalhe.</li>
                </ul>
            </h4>
        </div>


    <img src="http://localhost/feegowclinic/pdf/img/p7.png" width="100%" />


    <pagebreak> 


        <div style="position:absolute; top:410px; left:90px; color:#fff; width:100%">
            <table width="950">
                <tr>
                    <td style="color:#fff">
                        <h1><%=session("NameUser") %> - Comercial</h1>
                        <h3>
                            0800-729-6103 // www.feegowclinic.com.br // <%=pema("Email") %>
                        </h3>
                            <br />
                        <h4>
                            Validade desta proposta: 15 dias.
                        </h4>
                    </td>
                    <td>
                        <img src="http://127.0.0.1/feegowclinic/uploads/7888d28b745586fa3cde798d3dc7100c.jpg" height="190" style="object-fit:cover; border-radius:50px"/>
                    </td>
                </tr>
            </table>

        </div>

    <img src="http://localhost/feegowclinic/pdf/img/p8.png" width="100%" />




</body>
</html>
