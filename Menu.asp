				<div class="sidebar" id="sidebar">
					<script type="text/javascript">
						try{ace.settings.check('sidebar' , 'fixed')}catch(e){}
					</script>

					<div class="sidebar-shortcuts" id="sidebar-shortcuts">
						<div class="sidebar-shortcuts-large" id="sidebar-shortcuts-large">
							<a href="./?P=Pacientes">
                            <button class="btn btn-warning tooltip-warning" title="" data-placement="bottom" data-rel="tooltip" data-original-title="Pacientes">
								<i class="far fa-group"></i>
							</button>
                            </a>

							<button class="btn btn-info tooltip-info" title="" data-placement="bottom" data-rel="tooltip" data-original-title="Agenda">
								<i class="far fa-calendar"></i>
							</button>

							<button class="btn btn-success tooltip-success" title="" data-placement="bottom" data-rel="tooltip" data-original-title="Prontu&aacute;rios">
								<i class="far fa-stethoscope"></i>
							</button>

							<button class="btn btn-danger tooltip-danger" title="" data-placement="bottom" data-rel="tooltip" data-original-title="Configura&ccedil;&otilde;es">
								<i class="far fa-cog"></i>
							</button>
						</div>

						<div class="sidebar-shortcregrergreguts-mini" id="sidebar-shortcuts-mini">
							<span class="btn btn-success"></span>

							<span class="btn btn-info"></span>

							<span class="btn btn-warning"></span>

							<span class="btn btn-danger"></span>
						</div>
					</div><!-- #sidebar-shortcuts -->

					<ul class="nav nav-list">
                        <%
						set Cat = db.execute("select * from cliniccentral.sys_menu where Superior=0")
						while not Cat.EOF
							set Menu = db.execute("select * from cliniccentral.sys_menu where Superior="&Cat("id"))
						%>
						<li>
							<a href="#" class="dropdown-toggle">
								<i class="far fa-<%=Cat("Icon")%>"></i>
								<span class="menu-text"> <%=Cat("Title")%> </span>
							<%if not Menu.EOF then%>
								<b class="arrow icon-angle-down"></b>
                            <%end if%>
							</a>
							<%if not Menu.EOF then%>
                                <ul class="submenu">
                                <%
                                while not Menu.EOF
                                %>
                                    <li>
                                        <a href="<%=Menu("Link")%>">
                                            <i class="far fa-double-angle-right"></i>
                                            <%=Menu("Title")%>
                                        </a>
                                    </li>
                                <%
                                Menu.moveNext
                                wend
                                Menu.close
                                set Menu = nothing
                                %>
                                </ul>
                            <%end if%>
						</li>
                        <%
						Cat.moveNext
						wend
						Cat.close
						set Cat = nothing
						%>
					</ul><!-- /.nav-list -->

					<div class="sidebar-collapse" id="sidebar-collapse">
						<i class="far fa-double-angle-left" data-icon1="far fa-double-angle-left" data-icon2="far fa-double-angle-right"></i>
					</div>

					<script type="text/javascript">
						try{ace.settings.check('sidebar' , 'collapsed')}catch(e){}
					</script>
				</div>
