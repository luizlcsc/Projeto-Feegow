<!--#include file="connect.asp"-->
<%

AgendamentoID = request.QueryString("Atender")
PacienteID = ccur(req("I"))
Acao = req("Acao")

if AgendamentoID="" or not isnumeric(AgendamentoID) then
	AgendamentoID = 0
	set getAgendamentoID = db.execute("SELECT id FROM agendamentos WHERE Data= '"&mydate(date())&"' AND PacienteID="&PacienteID&" AND ProfissionalID="&treatvalzero(session("idInTable"))&" LIMIT 1 ")
	if not getAgendamentoID.eof then
	    AgendamentoID = getAgendamentoID("id")
	end if
else
	AgendamentoID = ccur(AgendamentoID)
end if




if Acao="Iniciar" then
	set vesehapac = db.execute("select * from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and isnull(HoraFim) and Data='"&myDate(date())&"'")
	if vesehapac.eof then

		sqlInsert = "insert into atendimentos (PacienteID, AgendamentoID, Data, HoraInicio, sysUser, ProfissionalID, UnidadeID) values ("&PacienteID&", "&AgendamentoID&", '"&mydate(date())&"', '"&time()&"', "&session("User")&", "&treatvalzero(session("idInTable"))&", "&treatvalzero(session("UnidadeID"))&")"
		sqlPult = "select * from atendimentos where PacienteID="&PacienteID&" order by id desc"
		db_execute(sqlInsert)
		set pult = db.execute(sqlPult)
		
		'Ver o que estava agendado e lançar conta a receber ou guia
		set agendamento = db.execute("select age.*, l.UnidadeID from agendamentos age LEFT JOIN locais l ON l.id=age.LocalID where age.id="&AgendamentoID)
		if not agendamento.eof then
            UnidadeIDAgendamento = agendamento("UnidadeID")

			StaX = 2
			'triagem
            set ConfigSQL = db.execute("SELECT Triagem,PosConsulta FROM sys_config WHERE id=1")

            if not ConfigSQL.eof then
                if (ConfigSQL("Triagem")="S" or ConfigSQL("PosConsulta")="S") and agendamento("ProfissionalID")<>session("idInTable") then
                    db_execute("UPDATE atendimentos SET Triagem='S' WHERE id="&pult("id"))
                end if
            end if

            db_execute("update agendamentos SET StaID = "&StaX&" WHERE id="&AgendamentoID)
            if UnidadeIDAgendamento&""<>session("UnidadeID") then
                db.execute("update atendimentos SET UnidadeID = "&treatvalzero(UnidadeIDAgendamento)&" WHERE id="&pult("id"))
            end if
			if agendamento("rdValorPlano")="P" then
				ValorFinal = valConvenio(agendamento("ValorPlano"), "", PacienteID, agendamento("TipoCompromissoID"))
			else
				ValorFinal = agendamento("ValorPlano")
			end if
			db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Obs, ValorPlano, rdValorPlano, Fator, ValorFinal) values ("&pult("id")&", "&agendamento("TipoCompromissoID")&", '', "&treatvalzero(agendamento("ValorPlano"))&", '"&agendamento("rdValorPlano")&"', 1, "&treatvalzero(ValorFinal)&")")
			if agendamento("Procedimentos")&"" <> "" then
			    set ProcedimentosAnexosSQL = db.execute("SELECT * FROM agendamentosprocedimentos WHERE AgendamentoID="&agendamento("id"))
			    if not ProcedimentosAnexosSQL.eof then
			        while not ProcedimentosAnexosSQL.eof
                        if agendamento("rdValorPlano")="P" then
                            ValorFinal = valConvenio(ProcedimentosAnexosSQL("ValorPlano"), "", PacienteID, ProcedimentosAnexosSQL("TipoCompromissoID"))
                        else
                            ValorFinal = ProcedimentosAnexosSQL("ValorPlano")
                        end if
                        db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Obs, ValorPlano, rdValorPlano, Fator, ValorFinal) values ("&pult("id")&", "&ProcedimentosAnexosSQL("TipoCompromissoID")&", '', "&treatvalzero(ProcedimentosAnexosSQL("ValorPlano"))&", '"&ProcedimentosAnexosSQL("rdValorPlano")&"', 1, "&treatvalzero(ValorFinal)&")")

			        ProcedimentosAnexosSQL.movenext
                    wend
                    ProcedimentosAnexosSQL.close
                    set ProcedimentosAnexosSQL=nothing
                end if
            end if
			set pultAP = db.execute("select id from atendimentosprocedimentos where AtendimentoID="&pult("id")&" order by id desc limit 1")
			'Coleta os dados pra identificar o dominio do rateio
			if agendamento("rdValorPlano")="V" then
				FormaID = "P"
			else
				FormaID = agendamento("ValorPlano")
			end if
'			DominioID = dominioRepasse(FormaID, agendamento("ProfissionalID"), agendamento("TipoCompromissoID"), UnidadeID, agendamento("TabelaParticularID"), agendamento("EspecialidadeID"))
'			call materiaisInformados(DominioID, session("User"), pultAP("id"))
		end if
		pultID = pult("id")
	else
		pultID = vesehapac("id")
	end if
	if instr(session("Atendimentos"), "|"&pultID&"|")=0 then
		session("Atendimentos")=session("Atendimentos")&"|"&pultID&"|"
	end if
end if

if Acao="PreEncerrar" then
	set buscaAtendimento = db.execute("select * from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"' and isnull(HoraFim)")
	if buscaAtendimento.eof then
		set buscaAtendimento = db.execute("select * from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"' order by id desc limit 1")
	end if
	if not buscaAtendimento.eof then
''		db_execute("update atendimentos set HoraFim='"&time()&"' where id="&buscaAtendimento("id"))
		'fecha possível lista de espera com este paciente
''		set lista = db.execute("select * from agendamentos where PacienteID="&PacienteID&" and Data='"&mydate(date())&"' and StaID<>3 and ProfissionalID="&session("idInTable")&" order by Hora")
''		if not lista.EOF then
''			db_execute("update agendamentos set StaID=3 where id="&lista("id"))
''		end if
''		session("Atendimentos") = replace(session("Atendimentos"), "|"&buscaAtendimento("id")&"|", "")
		%>
		<script language="javascript">
//		$("#agePac<%=PacienteID%>").css("display", "none");
		//$("#modal").html('<div ><i class="fa fa-circle-o-notch fa-spin fa-fw"></i> <span class="sr-only">Carregando...</span> Carregando...</div>');


		setTimeout(function(){
			$.ajax({
				type:"POST",
				url:"modalInfAtendimento.asp?AgendamentoID=<%=req("Atender")%>&AtendimentoID=<%=buscaAtendimento("id")%>&Origem=Atendimento&PacienteID=<%=PacienteID%>&Solicitacao=<%=req("Solicitacao")%>",
				success: function(data){
					$("#modal").html(data);
					setTimeout(function() {
		                $("#modal-table").modal("show");
					}, 400);
				}
			});
		}, 200);
		</script>
		<%
	end if
end if


if Acao="Solicitar" then
'	response.Write("select * from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"'")
	set buscaAtendimento = db.execute("select * from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"' and isnull(HoraFim)")
	if not buscaAtendimento.eof then
		'db_execute("update atendimentos set HoraFim='"&time()&"' where id="&buscaAtendimento("id"))
		'fecha possível lista de espera com este paciente
		'set lista = db.execute("select * from agendamentos where PacienteID="&PacienteID&" and Data='"&mydate(date())&"' and StaID<>3 and ProfissionalID="&session("idInTable")&" order by Hora")
		'if not lista.EOF then
		'	db_execute("update agendamentos set StaID=3 where id="&lista("id"))
		'end if
		'session("Atendimentos") = replace(session("Atendimentos"), "|"&buscaAtendimento("id")&"|", "")
		db_execute("update sys_users set UsuariosNotificar='"&ref("UsuariosNotificar")&"' where id="&session("User"))
		splNotificar = split(ref("UsuariosNotificar"), "|")
		for	h=0 to ubound(splNotificar)
			if isnumeric(splNotificar(h)) and splNotificar(h)<>"" then
				db_execute("update sys_users as u set notiflanctos=concat( u.notiflanctos, '|"&buscaAtendimento("id")&"|' ) where id="&splNotificar(h))
			end if
		next
		%>
		<script language="javascript">
		$("#modal-table").modal("hide");
		//$("#agePac<%=PacienteID%>").css("display", "none");
/*		$.ajax({
			type:"POST",
			url:"modalFimAtendimento.asp?AtendimentoID=<%=buscaAtendimento("id")%>",
			success: function(data){
				$("#modal").html(data);
				$("#modal-table").modal("show");
			}
		});*/
		//location.href='./?P=ListaEspera&Pers=1';
		</script>
		<%
	end if
end if

'Agora verifica se quando carrega diretamente via server.Execute o paciente em questão está sendo atendido
if session("Atendimentos")<>"" then
	spl = split(session("Atendimentos"), "|")
	for i=0 to ubound(spl)
		if spl(i)<>"" and isnumeric(spl(i)) then
			set vePac = db.execute("select * from atendimentos where id="&spl(i))
			if not vePac.eof then
				if vePac("PacienteID")=PacienteID then
					Conteudo = "Contador"
					HoraInicio = cdate( hour(vePac("HoraInicio"))&":"&minute(vePac("HoraInicio"))&":"&second(vePac("HoraInicio")) )
					Tempo = cdate( time()-HoraInicio )
				end if
			end if
		end if
	next
end if

if Conteudo="" then
	Conteudo = "Play"
end if


iniciarDisabled = ""
if lcase(session("Table")) <> "profissionais" then
    iniciarDisabled = " disabled "
end if

set ConfigObrigarPagamentoSQL = db.execute("SELECT ChamarAposPagamento, ObrigarIniciarAtendimento FROM sys_config WHERE id=1")

if not ConfigObrigarPagamentoSQL.eof then
    if ConfigObrigarPagamentoSQL("ChamarAposPagamento")="S" and ConfigObrigarPagamentoSQL("ObrigarIniciarAtendimento")=1 then

        if session("table")="profissionais" then

            set EncontraAgendamentoSQL = db.execute("SELECT FormaPagto FROM agendamentos WHERE Data=CURDATE() AND ProfissionalID="&session("idInTable")&" AND PacienteID="&PacienteID)

            if not EncontraAgendamentoSQL.eof then
                if EncontraAgendamentoSQL("FormaPagto")=-2 then
                    iniciarDisabled = "disabled"

                    avisoIniciarAtendimento = "Não é possível iniciar atendimento pois há pendências financeiras."
                end if
            end if
        end if

    end if
end if

if Conteudo="Play" then
        if getConfig("ExibirIniciarAtendimento") then
            %>
                    <button <%=iniciarDisabled%> type="button" class="btn btn-success btn-gradient btn-alt btn-block" onClick="atender(<%= AgendamentoID %>, <%= PacienteID %>, 'Iniciar', '')"><i class="fa fa-play"></i> Iniciar Atendimento </button>
            <%
            else
            %>
            <script>
                $("#divContador").parent().removeClass("tray-bin")
            </script>
            <%
        end if
        if avisoIniciarAtendimento<>"" then
            %>
            <small><%=avisoIniciarAtendimento%></small>
            <%
        end if
      else
        %>
        <h3 class="text-center light"><i class="fa fa-clock-o"></i> <span id="counter"><%=Tempo%></span></h3>
          <div class="row">
              <div class="col-sm-6">
                  <button class="btn btn-danger btn-gradient btn-alt btn-block col-sm-6" type="button" onClick="atender(<%= AgendamentoID %>, <%= PacienteID %>, 'PreEncerrar', 'N')"><i class="fa fa-stop"></i> Finalizar</button>
              </div>
              <div class="col-sm-6">
                  <button class="btn btn-warning btn-gradient btn-alt btn-block col-sm-6 <% if session("Banco")="clinic5351" then response.write(" hidden ") end if %> " type="button" onClick="atender(<%= AgendamentoID %>, <%= PacienteID %>, 'PreEncerrar', 'S')"><i class="fa fa-pause"></i> Solicitar</button>
              </div>
          </div>
      <script type="text/javascript">
      var stopTime;
      /**********************************************************************************************
      * CountUp script by Praveen Lobo (http://PraveenLobo.com/techblog/javascript-countup-timer/)
      * This notice MUST stay intact(in both JS file and SCRIPT tag) for legal use.
      * http://praveenlobo.com/blog/disclaimer/
      **********************************************************************************************/
      function CountUp(initDate, id){
          this.beginDate = new Date(initDate);

          this.countainer = document.getElementById(id);
          this.numOfDays = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];
          this.borrowed = 0, this.years = 0, this.months = 0, this.days = 0;
          this.hours = 0, this.minutes = 0, this.seconds = 0;
          this.updateNumOfDays();
          this.updateCounter();
      }

      var c = 0;
      function getNow() {
            var now = "<%=now()%>";

            now = now.split(" ");

            var nowS = now[0].split('/');


            now = nowS[2]+"-"+nowS[1]+"-"+nowS[0]+"T"+now[1];


            var Now = new Date(now);

            if(c > 0){
                Now.setSeconds(Now.getSeconds() + c);
            }

            c += 1;

            return Now;
      }

      CountUp.prototype.updateNumOfDays=function(){
          var dateNow = new Date();
          var currYear = dateNow.getFullYear();
          if ( (currYear % 4 == 0 && currYear % 100 != 0 ) || currYear % 400 == 0 ) {
              this.numOfDays[1] = 29;
          }
          var self = this;
          setTimeout(function(){self.updateNumOfDays();}, (new Date((currYear+1), 1, 2) - dateNow));
      }

      CountUp.prototype.datePartDiff=function(then, now, MAX){
          var diff = now - then - this.borrowed;
          this.borrowed = 0;
          if ( diff > -1 ) return diff;
          this.borrowed = 1;
          return (MAX + diff);
      };

      var is_iPad = navigator.userAgent.match(/iPad/i) != null;

      CountUp.prototype.calculate=function(){
//          var currDate = new Date();
          var currDate = getNow();

          var prevDate = this.beginDate;
          this.seconds = this.datePartDiff(prevDate.getSeconds(), currDate.getSeconds(), 60);
          this.minutes = this.datePartDiff(prevDate.getMinutes(), currDate.getMinutes(), 60);

          this.hours = this.datePartDiff(prevDate.getHours(), currDate.getHours(), 24);
          if(is_iPad){
            this.hours -= 21;
          }
          this.days = this.datePartDiff(prevDate.getDate(), currDate.getDate(), this.numOfDays[currDate.getMonth()]);
          this.months = this.datePartDiff(prevDate.getMonth(), currDate.getMonth(), 12);
          this.years = this.datePartDiff(prevDate.getFullYear(), currDate.getFullYear(),0);
      };

      CountUp.prototype.addLeadingZero=function(value){
          return value < 10 ? ("0" + value) : value;
      };

      CountUp.prototype.formatTime=function(){
          this.seconds = this.addLeadingZero(this.seconds);
          this.minutes = this.addLeadingZero(this.minutes);
          this.hours = this.addLeadingZero(this.hours);
      };

      CountUp.prototype.updateCounter=function(){
          this.calculate();
          this.formatTime();
          var time = this.hours + ":" + this.minutes + ":" + this.seconds;
          this.countainer.innerHTML = time;

          $("title").html(time + " - Em atendimento");
          var self = this;
          stopTime = setTimeout(function(){self.updateCounter();}, 1000);
      };

      //window.onload=function(){ new CountUp('April 16, 2014 <%=HoraInicio%>', 'counter'); }
      $( document ).ready(function() {
          clearTimeout(stopTime);
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth()+1; //January is 0!
            var yyyy = today.getFullYear();

            if(dd<10) {
                dd = '0'+dd
            }

            if(mm<10) {
                mm = '0'+mm
            }

            today = yyyy + '/' + mm  + '/' + dd;

            var dateTime = today+' <%=HoraInicio%>';
            clearTimeout(stopTime);

            new CountUp(dateTime, 'counter');
        });

      </script>

        <%
end if
%>
