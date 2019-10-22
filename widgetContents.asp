<!--#include file="connect.asp"-->
<%
if ref("html")="" then
    c = 0
    while c<10
    %>
			<div id="w<%=c%>" data-tam="6" class="col-sm-6 widget-container-span">
				<div class="widget-box">
					<div class="widget-header">
						<h5 class="smaller"><%=c%></h5>

						<div class="widget-toolbar">
							<button type="button" onclick="tam(0, <%=c %>)" class="btn-tam btn btn-xs btn-primary">-</button>
							<button type="button" onclick="tam(1, <%=c %>)" class="btn-tam btn btn-xs btn-primary">+</button>
						</div>
					</div>

					<div class="widget-body">
						<div class="widget-main padding-6">
							<div class="alert alert-info"> Hello World! </div>
						</div>
					</div>
				</div>
			</div>
    <%
    c = c+1
    wend
else
    response.Write(ref("html"))
end if
    %>

