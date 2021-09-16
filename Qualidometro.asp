<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
if req("N")<>"" and isnumeric(req("N")) then
    dbc.execute("insert into cliniccentral.pesquisa_satisfacao (UsuarioID, LicencaID, NotaNova) values ("& session("User") &", "& replace(session("Banco"), "clinic", "") &", "& req("N") &")")
    db_execute("update cliniccentral.licencasusuarios set QualiData=now(), Qualidometro="& req("N") &" where id="& session("User"))
end if    
%>
<div class="col-md-12 pb10">
    <div class="btn-group" role="group" aria-label="Basic example">
        <%
        set ultQuali = db.execute("select NotaNova from cliniccentral.pesquisa_satisfacao where UsuarioID="& session("User") &" order by DataHora desc")
        Nota = 0
        corNota = ""
        txtNota = "<i class='far fa-chevron-up'></i><br /> QUEREMOS LHE ATENDER MELHOR"
        if not ultQuali.eof then
            Nota = ultQuali("NotaNova")
        end if

            'response.write( Nota )

        set quali = db.execute("select * from cliniccentral.qualidometrostatus qs order by id")
        while not quali.eof
            if quali("id")=Nota then
                corNota = "#"& quali("Cor")
                txtNota = "Sua última avaliação foi <br> "& ucase(quali("Status")) &"<br>Continua assim?"
            end if
            %>
            <button class="btn btn-default p7" data-rel="tooltip" data-placement="bottom" title="" data-original-title="<%= quali("Status") %>" style="border-bottom:#<%= quali("Cor")%> 2px solid; <% if quali("id")=Nota then response.write(" background-color:#"& quali("Cor") &";") end if %>"><i class="fs20 imoon imoon-<%= quali("Icone") %>" onclick="qualidometro(<%= quali("Nota") %>)"></i></button>
            <%
        quali.movenext
        wend
        quali.close
        set quali = nothing
        %>
    </div>
</div>
<h6 class="pt10" style="color:<%= corNota %>">
    <%= txtNota %>
</h6>
