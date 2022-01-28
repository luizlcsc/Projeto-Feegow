<!--#include file="connect.asp"-->
<%
spl1 = split(req("C"), "|")
NomeLocalr = split(req("NomeLocal"), "|")

list = array()
for i=0 to ubound(spl1)
    ReDim Preserve list(UBound(list) + 1)
     list(UBound(list)) = spl1(i)            
next

chamados = ""

for u=0 to ubound(list)
    spl = split(list(u), "_")

    if spl(0)<>"" and instr(chamados, list(u))=0 then

        NomeLocal = NomeLocalr(u)
        set prof = db.execute("select profissionais.TratamentoID, IF(profissionais.NomeSocial IS NULL OR profissionais.NomeSocial = '', profissionais.NomeProfissional, profissionais.NomeSocial) NomeProfissional, tratamento.Tratamento from profissionais left join tratamento on profissionais.TratamentoID=tratamento.id where profissionais.id like '"&spl(0)&"'")
        if not prof.eof then
            Tratamento = prof("Tratamento")
            NomeProfissional = prof("NomeProfissional")
        end if
        set pac = db.execute("select IF(NomeSocial IS NOT NULL AND NomeSocial !='', NomeSocial, NomePaciente)NomePaciente from pacientes where id = '"&spl(1)&"'")
        if not pac.EOF then
            NomePaciente = pac("NomePaciente")
        end if
        set confvoz = db.execute("select * from sys_chamadaporvoz")
        %>
        <div id='divVHSS' style="display:none"></div><%if confvoz("Sexo")=1 then
            response.Write("<script language=""JavaScript"" type=""text/javascript"" src=""https://vhss-d.oddcast.com/vhost_embed_functions_v2.php?acc=1024058&js=1""></script><script language=""JavaScript"" type=""text/javascript"">AC_VHost_Embed(1024058,188,250,'',1,1, 2382723, 0,1,0,'33eb8b8b948709c09c3c14a014b521d4',9);")
            NumeroVoz = 5
        else
            response.Write("<script language=""JavaScript"" type=""text/javascript"" src=""https://vhss-d.oddcast.com/vhost_embed_functions_v2.php?acc=1024058&js=1""></script><script language=""JavaScript"" type=""text/javascript"" src=""https://vhss-d.oddcast.com/vhost_embed_functions_v2.php?acc=1024058&js=1""></script><script language=""JavaScript"" type=""text/javascript"">AC_VHost_Embed(1024058,188,250,'',1,1, 2382721, 0,1,0,'10b88d2f92b1f949435598aa94a9a226',9);")
            NumeroVoz = 4
        end if
        Texto = confvoz("Texto")
        Texto = replace(Texto&" ", "[TratamentoProfissional]", Tratamento&" ")
        Texto = replace(Texto&" ", "[NomeProfissional]", NomeProfissional&" ")
        Texto = replace(Texto&" ", "[NomePaciente]", NomePaciente&" ")
        Texto = replace(Texto&" ", "[NomeLocal]", NomeLocal&" ")
        Texto = replace(Texto&" ", "esta", "está")

        'triagem ponto saude
        set RecursosAdicionaisSQL = db.execute("SELECT RecursosAdicionais FROM sys_config WHERE id=1")

        if not RecursosAdicionaisSQL.eof then
            if instr(RecursosAdicionaisSQL("RecursosAdicionais"), "|PreConsulta|") then
                if spl(0)="105" then
                    Texto = replace(Texto&" ", "atendimento", "pré-consulta")
                end if
                if spl(0)="106" then
                    Texto = replace(Texto&" ", "atendimento", "pós-consulta")
                end if
            end if
        end if

        Texto = replace(Texto,chr(10),"")
        Texto = replace(Texto,chr(13),"")
        %>

        if ('speechSynthesis' in window) {
                // Synthesis support. Make your web apps talk!
                var msg = new SpeechSynthesisUtterance();
                var voices = window.speechSynthesis.getVoices();

                msg.voiceURI = 'native';
                msg.volume = 1; // 0 to 1
                msg.rate = 1; // 0.1 to 10
                msg.pitch = 1; //0 to 2
                msg.text = '<%=Texto%>';
                msg.text = msg.text.replace(".", "");
                msg.text = msg.text.replace("   ", " ");
                msg.lang = 'pt-BR';

                console.log(msg.text);
                msg.onend = function(e) {
                    console.log('Finished in ' + event.elapsedTime + ' seconds.');

                };


                speechSynthesis.speak(msg);
        }
        /*
        function vh_sceneLoaded()
                    {
                    //the scene begins playing, add actions here
                    //Mulher=4|Homem(1o.)=5
                    sayText('<%=Texto%>',<%=NumeroVoz%>,6,2);
                    }
        */
        window.parent.document.getElementById('legend').style.display='inline-table';


        var html = '<div>';
        html += '<%=Texto%>'
        html += '</div>';

        var tempElement = document.createElement('div');
        tempElement.innerHTML = html;
        window.parent.document.getElementById('legendText').append(tempElement);

        listChamadasPacientes = window.parent.document.getElementById('legendText').children
        if(listChamadasPacientes.length > 2){
            listChamadasPacientes[0].remove()
        }

        function notify() {
            Notification.requestPermission(function() {
                var notification = new Notification("FEEGOW CLINIC INFORMA", {
                    icon: 'https://clinic.feegow.com.br/icon_clinic.png',
                    body: "<%=Texto%>"
                });
                notification.onclick = function() {
                    window.open("https://app.feegow.com/main/");
                }
            });
        }

        notify();

        </script>
<%
    end if
    chamados = chamados & "_"&list(u)

next
%>



