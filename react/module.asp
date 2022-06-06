<div id="root"></div>
<% IF Request.QueryString("dev") = "true" THEN  %>
    <script src="http://localhost:3009/static/js/<%=Request.QueryString("module") %>-0.1.0.bundle.js"></script>
<% ELSE %>
    <script src="https://frontend.feegow.com/static/js/<%=Request.QueryString("module") %>-0.1.0.bundle.js"></script>
<% END IF %>
<script>
    feegowModules["<%=Request.QueryString("module") %>"](document.getElementById("root"))
</script>
