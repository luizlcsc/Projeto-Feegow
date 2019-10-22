<!--#include file="connect.asp"-->
<html>
    <head>
        <style type="text/css">
            body{
                font-family:'Trebuchet MS';
                background-color:#000;
                margin:0;
                overflow:hidden;
            }
            #chamadas{
                width:30%;
                background-color:#fff;
                height:100%;
                position:absolute;
                right:0;
                opacity:0.85;
                padding: 20px;
            }
            .nomePac{
                text-transform:uppercase;
                font-weight:bold;
                font-size:40px;
                margin-bottom:10px;
                margin-top:20px;
            
            }
            .localPac{
                text-align:right;
                background-color:#090360;
                padding:5px;
                font-size:18px;
                color:#fff;
                border-radius:10px;
                margin-bottom:15px;
                width:100%;
                }
            .logo{
                text-align:center;
                margin-bottom:60px;
            }
            .contNome {
                background-color:#fff;
                padding:10px;
                opacity:1;
                fill-opacity:1;
            }
            #pisca {
                text-align:center;
                color:#fff;
                font-size:30px;
                background-color:#f00;
                padding:10px;
                border-radius:10px;
            }
        </style>
    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
    </head>
    <body>
        <div id="chamadas">
            <div class="logo"><img src="logo/<%=session("logo") %>" width="50%" /></div>
            <div id="pisca">CHAMADA DE PACIENTES</div>
            <div id="contChamadas"></div>
        </div>


        <iframe scrolling="no" frameborder="0" width="100%" height="100%" src="https://globoplay.globo.com/"></iframe>

        <script type="text/javascript">
            function cham() {
                $.get("tryChamada.asp", function (data) {
                    if (data == '') {
                        $("#chamadas").slideUp();
                    } else {
                        $("#chamadas").slideDown();
                    }
                    $("#contChamadas").html(data);
                });
            }

                $("#pisca").css("opacity", "0.4");//define opacidade inicial
                setInterval(function () {
                    if ($("#pisca").css("opacity") == 0.5) {
                        $("#pisca").css("opacity", "1");
                    } else {
                        $("#pisca").css("opacity", "0.5");
                    }
                }, 500);
            

            setInterval(function () { cham() }, 5000);
        </script>
    </body>
</html>
