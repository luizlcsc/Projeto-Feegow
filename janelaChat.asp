<div id="body_<%=chatID%>" class="tab-pane chat-widget slim-scroll pt15" role="tabpanel" data-height="300">
    <!--#include file="calltalk.asp"-->
</div>

        <form class="chat" id="frm<%=ChatID %>" action="" method="post" onfocusin="statusChat('<%=ChatID %>');">
            <input type="hidden" name="chatID" value="<%=chatID%>" />
            <div class="panel">
                <div class="panel-body">
                    <div class="input-group">
                        <input placeholder="digite a mensagem aqui..." autocomplete="off" type="text" class="form-control input-sm cx-mensagem" name="mensagem" />
                        <span class="input-group-btn">
                            <button class="btn btn-sm btn-info no-radius">
                                <i class="far fa-send"></i>
                            </button>
                        </span>
                    </div>
                </div>
            </div>
        </form>
