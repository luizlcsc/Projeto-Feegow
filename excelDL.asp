<%@ Language=VBScript %>
<%  Option Explicit

response.CharSet = "utf-8"

Response.ContentType = "application/vnd.ms-excel"
Response.AddHeader "Content-Disposition", "attachment; filename="& req("FN") &".xls"
%>
<style type="text/css">
   a[href]:after {
     content: ""!important;
   }

</style>

<div class="container-fluid">
    <div style="position:fixed; top:10px; right:10px">
        <button type="button" onclick="location.href='excel.asp?<%= request.QueryString %>'" class="btn btn-success hidden-print"><i class="far fa-file-excel-o"></i></button>
        <button type="button" onclick="print()" class="btn btn-info hidden-print"><i class="far fa-print"></i></button>
    </div>
	<%server.Execute(req("R")&".asp")%>
</div>
