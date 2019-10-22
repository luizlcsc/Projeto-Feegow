<!--#include file="connect.asp"--><%


if req("T")="S" then   
    db_execute("insert into cliniccentral.excel (UserID, Conteudo, Nome) values ("&session("User")&", '"&ref("cont")&"', '"&req("N")&"')")
else
    set p = db.execute("select * from cliniccentral.excel where UserID=111 order by id desc")
    if not p.eof then
    '    response.Write("<table><tr><td data-verify='0090' >UM</td><td data-verify='0090' >DOISsgg</td><td data-verify='0090' >TRÊS</td></tr><tr><td data-verify='0090' data-title='1'>Titulo123321231231</td></tr><tr><td data-verify='0090' >Cell 1</td><td data-verify='0090' >Cell 2</td></tr><tr><td data-verify='0090' data-title='1'>Titulo2</td></tr><tr><td data-verify='0090' >Cell 11</td><td data-verify='0090' >Cell 22</td></tr><tr><td data-verify='0090' data-title='1'>PEDRO LUCAS</td></tr><tr><td data-verify='0090' >a</td><td data-verify='0090' >b</td><td data-verify='0090' >c</td></tr><tr><td data-verify='0090' >d</td><td data-verify='0090' >e</td><td data-verify='0090' >f</td></tr><tr><td data-verify='0090' data-title='1'>Carlito Alfajor</td></tr><tr><td data-verify='0090' >A</td><td data-verify='0090' >B</td><td data-verify='0090' >C</td></tr><tr><td data-verify='0090' >AA</td><td data-verify='0090' >BB</td><td data-verify='0090' >CC</td></tr></table>")
        response.Write( replace(replace(replace(p("Conteudo"), """", "'"), chr(10), ""), chr(13), "") )
    end if
    db_execute("delete from cliniccentral.excel where UserID=111")
end if
%>