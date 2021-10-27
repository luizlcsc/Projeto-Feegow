<%
modalModulo = req("P")
if RecursoTag= "" then
    RecursoTag = req("P")
end if
%>

<div class="text-right">
    <button type="button" class="btn btn-default " data-toggle="tooltip" data-placement="left" title="Lista de dados dinâmicos"
    onclick="openComponentsModal('ModalTags.asp?P=<%=modalModulo%>&R=<%=RecursoTag%>', true, 'Lista de Tags', true, '')">
        <i class="far fa-list-alt"></i> Tags
    </button>
</div>