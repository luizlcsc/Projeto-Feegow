<!--#include file="connect.asp"-->
<%
agendamentoChamada = req("agendamentoID")
chamar = req("chamar")


function getLocalIds(parAgendamentoId,chamadanomelocal)
    sqllocal ="SELECT ag.LocalID ,l.NomeLocal "&_
                    "FROM "&_
                    "agendamentos ag "&_
                    "left join locais l on l.id = ag.LocalID "&_
                    "WHERE "&_
                    "ag.id  = "&parAgendamentoId
    set getLocal = db.execute(sqllocal)
    if not getLocal.eof then
        getLocalIds = getLocal("LocalID")
        chamadanomelocal = getLocal("NomeLocal")
    end if
end function

function getAmbienteIds(parLocald)
    sqlambientes ="SELECT group_CONCAT(id) ids FROM locaisgrupos WHERE locais LIKE CONCAT('%|',"&parLocald&",'|%')"
    set getAmbient = db.execute(sqlambientes)
    if not getAmbient.eof then
        getAmbienteIds = getAmbient("ids")
    end if
end function

if agendamentoChamada <> "" then 
    if chamar = "" then
        'db.execute("call stp_chamadasTV('agendamentos', "&agendamentoChamada&")")
    end if 
    
    aglocalid = getLocalIds(agendamentoChamada,chamadanomelocal)
    ambientes = ", ""ambientes"":"""&getAmbienteIds(aglocalid)&""""
    response.write("{""success"":""ok"""&ambientes&", ""local"":"""&chamadanomelocal&"""}")
    response.end
end if


  if ModoFranquia <> 0 or session("UnidadeID") <> 0 then
      myUnidade = session("UnidadeID")
  end if

  SocketChamadaTV = getConfig("SocketChamadaTV")
   
  %>
  <script>
  async function callChamadaTV(agendamentoid, chamar=false){
     <% if SocketChamadaTV <> 0 then %>
      let pchamar = chamar ? "&chamar=1":"";
      let response = await fetch('chamadaTV.asp?agendamentoID='+agendamentoid+pchamar,{});
      let data = await response.json();

      fetch('https://socket.feegow.com/send',{
        method:"POST",
        headers: {
              "Authorization":localStorage.getItem("tk"),
              'Accept': 'application/json',
              'Content-Type': 'application/json',
        },
        body:JSON.stringify({
                                "service":"panel",
                                "data": {
                                  "call": "next", 
                                  "unidade": "<%=session("UnidadeID")%>",
                                  "ambiente": data.ambientes,
                                  "chamando": data.local 
                                  }
                            })
      })
    <% end if %>
      return;
      }
</script>
