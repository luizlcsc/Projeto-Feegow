<!--#include file="connect.asp"-->

<div id='divVHSS' style="display:none"></div><%if 1=2 then
	response.Write("<script language=""JavaScript"" type=""text/javascript"" src=""https://vhss-d.oddcast.com/vhost_embed_functions_v2.php?acc=1024058&js=1""></script><script language=""JavaScript"" type=""text/javascript"">AC_VHost_Embed(1024058,188,250,'',1,1, 2382723, 0,1,0,'33eb8b8b948709c09c3c14a014b521d4',9);")
	NumeroVoz = 5
else
	response.Write("<script language=""JavaScript"" type=""text/javascript"" src=""https://vhss-d.oddcast.com/vhost_embed_functions_v2.php?acc=1024058&js=1""></script><script language=""JavaScript"" type=""text/javascript"" src=""https://vhss-d.oddcast.com/vhost_embed_functions_v2.php?acc=1024058&js=1""></script><script language=""JavaScript"" type=""text/javascript"">AC_VHost_Embed(1024058,188,250,'',1,1, 2382721, 0,1,0,'10b88d2f92b1f949435598aa94a9a226',9);")
	NumeroVoz = 4
end if
TextoFalado = "Seja bem-vindo, "&session("NameUser")&". Agora você pode usar a minha voz para a chamada de seus pacientes. Assista a nossa breve apresentação e entenda por que o Figo Clinic é o melhor software clínico do Brasil."
Texto = "Seja bem-vindo, "&session("NameUser")&". Agora você pode usar a minha voz para a chamada de seus pacientes. Assista a nossa breve apresentação e entenda por que o Feegow Clinic é o melhor software clínico do Brasil."
%>
function vh_sceneLoaded()
            {
            //the scene begins playing, add actions here
			//Mulher=4|Homem(1o.)=5
            sayText('<%=TextoFalado%>',<%=NumeroVoz%>,6,2);
            }
window.parent.document.getElementById('legend').style.display='block';
window.parent.document.getElementById('legendText').innerHTML='<%=Texto%>';
</script>
