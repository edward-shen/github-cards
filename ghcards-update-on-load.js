document.addEventListener("DOMContentLoaded", function(){
    const ghcards = document.querySelectorAll(".gh-card");
    const api_url = "https://api.github.com/repos/";
    if (ghcards.length != 0) {
        Array.prototype.forEach.call(ghcards, function(el, i){
            // Get our data from github
            const username = el.getAttribute('data-username');
            const reponame = el.getAttribute('data-repo');
            getJSONP(api_url + username + "/" + reponame, function(data) {
                // Parse the data we need
                const stars = resp["stargazers_count"];
                const forks = resp["forks_count"];

                el.querySelectorAll(".star-count").innerHTML = stars;
                el.querySelectorAll(".fork-count").innerHTML = forks;

            });
        });
    }

    function getJSONP(url, success) {
        var ud = '_' + +new Date,
            script = document.createElement('script'),
            head = document.getElementsByTagName('head')[0]
                    || document.documentElement;

        window[ud] = function(data) {
            head.removeChild(script);
            success && success(data);
        };

        script.src = url.replace('callback=?', 'callback=' + ud);
        head.appendChild(script);

    }
});
