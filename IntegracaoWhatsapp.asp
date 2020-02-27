<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>

<% IF recursoAdicional(31)=4 THEN %>
    <% set whatsapp_instace = db.execute("select * from cliniccentral.whatsapp_instancias w where (w.LicencaID = "&replace(Session("Banco"), "clinic", "")&")") %>
    <% IF not whatsapp_instace.eof THEN %>
    <div class="app" style="padding-top: 11px;">
        Carregando ...
    </div>

        <script type="text/javascript">
            getUrl("chat-pro/show", {}, function(data) {
                $(".app").hide();
                $(".app").html(data);
                $(".app").fadeIn('slow');
            });
        </script>
    <% ELSE %>
        <script type="text/javascript">
            $(".app").hide();
        </script>
        <p>Nenhuma instância whatsapp ativa para esta licença</p>
    <% END IF %>

<% else %>   
    <p>Item não ativado</p>
<% end if%>

