<%
if RecursoTag= "" then
    RecursoTag = request.QueryString("P")
end if
%>

<div class="text-right">
    <button type="button" class="btn btn-default " data-toggle="tooltip" data-placement="left" title="Lista de dados dinâmicos"
    onclick="openComponentsModal('ModalTags.asp?P=<%=modalModulo%>&R=<%=RecursoTag%>', true, 'Tags Prescrições', true, '')">
        <i class="fa fa-list-alt"></i> Tags
    </button>
</div>