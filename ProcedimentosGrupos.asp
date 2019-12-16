<!--#include file="connect.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select g.*, (select group_concat('|', id, '|') from procedimentos where GrupoID=g.id) Procedimentos from procedimentosgrupos g where g.id="&req("I"))
%>



<form method="post" id="frm" name="frm" action="save.asp">
    <%=header(req("P"), "Cadastro de Grupo de Procedimentos", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
    <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
    <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />

    <br />
    <div class="panel">
        <div class="panel-body">
            <%=quickField("text", "NomeGrupo", "Nome do Grupo", 6, reg("NomeGrupo"), "", "", " required")%>
            <%=quickfield("multiple", "Procedimentos", "Procedimentos do Grupo", 4, reg("Procedimentos"), "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' order by NomeProcedimento", "NomeProcedimento", "")%>
            <%

            set RecursosAdicionaisSQL = db.execute("SELECT RecursosAdicionais FROM sys_config WHERE id=1")

            if not RecursosAdicionaisSQL.eof then
                RecursosAdicionais=RecursosAdicionaisSQL("RecursosAdicionais")
                if instr(RecursosAdicionais, "|NFe|") then
                %>
                  <%=quickField("memo", "DescricaoNFse", "Descrição da NFS-e", 4, reg("DescricaoNFSe"), "", "", "" )%>
                <%
                end if
            end if
            %>
            <%= quickField("simpleSelect", "ModalidadeID", "Modalidade (PACS)", 2, reg("ModalidadeId"), "select * from cliniccentral.pacs_modalidades", "Modalidade", "") %>
        </div>
    </div>
</form>
<script type="text/javascript">
    $(document).ready(function(e) {
        <%call formSave("frm", "save", "")%>
        });

</script>
<!--#include file="disconnect.asp"-->
