<div class="content-sidebar-partner" style="position: absolute; top: 0; left: -250px; z-index: 9999;  width: 250px;
box-shadow: 0px 1px 10px 3px rgba(0,0,0,0.15);">
<!--div style="background-color:#4E8CCC; width:280px; height:100%; position:fixed; left:0; top:0; padding:100px 0 0 10px"-->
    <div onclick="toggleSidebar()" style="background-color: #fff; width: 23px; height: 40px; position:absolute; right: -22px;top: 80px;border-right: 1px #d6d6d6 solid;border-top: 1px #d6d6d6 solid;border-bottom: 1px #d6d6d6 solid;border-radius: 3px;z-index: 9; cursor: pointer;">
        <div class="text-center" style="margin-top: 10px;margin-left:3px">
            <i class="icon-expand-partner far fa-chevron-right"></i>
        </div>
    </div>
    <div style="height: 100%; background-color: #fff;">

        <div style="padding:7px">
            <p><h4>Buscar licenças</h4></p>

            <input class="form-control" placeholder="Filtrar..." id="partnerFiltrar" />
        </div>

        <%
	    set lics = db.execute("select id, NomeEmpresa from cliniccentral.licencas where Cupom='"&session("Partner")&"' and Status='C' ORDER BY NomeEmpresa")
        while not lics.eof
            %>
            <div style="border-bottom: #efefef 1px solid" class="item-license p10<%if session("Banco")="clinic"&lics("id") then%> active<%end if%>"><a href="./?P=ChangeLic&I=<%=lics("id")%>&Pers=1">
                <span class="badge badge-lg badge-primary"><%=ucase(left(lics("NomeEmpresa"),2))%></span> <span class="menu-text"><%=lics("NomeEmpresa")%></a></span>
                <span class="hidden"><%=lcase(lics("NomeEmpresa")&"") %></span>
            </div>
            <%
        lics.movenext
        wend
        lics.close
        set lics=nothing
        %>

        <div id="sidebar-collapse" class="sidebar-collapse">
            <i class="far fa-double-angle-left" data-icon2="far fa-double-angle-right" data-icon1="far fa-double-angle-left"></i>
        </div>
    </div>
</div>
<script type="text/javascript">
    $("#partnerFiltrar").keyup(function () {
        var value = $(this).val().toLowerCase();

        $(".item-license").each(function () {
            if ($(this).text().search(value) > -1) {
                $(this).show();
            }
            else {
                $(this).hide();
            }
        });
    });

    var partnerSidebarActive= false;

    function toggleSidebar() {
        var  $contentPartner = $(".content-sidebar-partner");
        var $icon = $contentPartner.find(".icon-expand-partner");

        partnerSidebarActive = !partnerSidebarActive;

        if(!partnerSidebarActive){
            $contentPartner.css("left", -250);
            $icon.removeClass("fa-chevron-left").addClass("fa-chevron-right");
        }else{
            $contentPartner.css("left", 0);
            $icon.removeClass("fa-chevron-right").addClass("fa-chevron-left");
        }

    }
</script>