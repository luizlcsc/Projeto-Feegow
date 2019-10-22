<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>




<div class="play">Play</div>

<div class="pause">Stop</div>


<script>
    $(document).ready(function() {
        var audioElement = document.createElement('audio');
        audioElement.setAttribute('src', 'sons/som2.wav');
        audioElement.setAttribute('autoplay', 'autoplay');
        //audioElement.load()

        $.get();

        audioElement.addEventListener("load", function() {
            audioElement.play();
        }, true);

        $('.play').click(function() {
            audioElement.play();
        });

        $('.pause').click(function() {
            audioElement.pause();
        });
    });
</script>      