<!--#include file="../connect.asp"-->
<!--#include file="ApiClient.asp"-->

<%

Class EventosEmailSMS

    Public Function updateStatusAgendamentos()
        hora = "17:00"

        set ConfigSQL = db.execute("SELECT AlterarStatusAgendamentosNoFimDoDia FROM sys_config WHERE id=1")
        AlterarStatus=False

        if not ConfigSQL.eof then
            if ConfigSQL("AlterarStatusAgendamentosNoFimDoDia")="S" then
                AlterarStatus=True
            end if
        end if

        if time()>cdate(hora) and AlterarStatus then

            sqlDateInterval = "Data > DATE_SUB(CURDATE(), INTERVAL 3 DAY) AND Data < CURDATE()"

            sql = "SELECT GROUP_CONCAT(id)ids FROM agendamentos WHERE "&sqlDateInterval&" AND StaID IN (2,4,5,101,103,105,1,7)"
            
            set AgendamentosParaAlterarSQL = db.execute(sql)

            if not AgendamentosParaAlterarSQL.eof then
                ids = AgendamentosParaAlterarSQL("ids")

                Set api = new ApiClient
                'response.write(res)
                'res = api.submitPost("patient-interaction/get-multiple-appointments-events", "{""appointments"": """&ids&"""}")

                db.execute("UPDATE agendamentos SET StaID=6 WHERE "&sqlDateInterval&" AND StaID IN (1,7)")
                db.execute("UPDATE agendamentos SET StaID=3 WHERE "&sqlDateInterval&" AND StaID IN (2,4,5,101,103,105)")
            end if
        end if
    End function
End Class
%>