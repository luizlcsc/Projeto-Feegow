<script>
     fetch(domain+"/sistemas-de-mensagens?tk="+localStorage.getItem("tk"),
            {headers: {
                  "x-access-token":localStorage.getItem("tk"),
                   'Accept': 'application/json',
                   'Content-Type': 'application/json'
           }
     })
     .then((r) => r.text())
     .then((r) => {
         var $modal = getModal(true, 'lg', false);

         openModal(r,"Sistema de Mensagens")
     });
</script>