document.addEventListener("DOMContentLoaded", function(){
    const AGE_LIMIT = 24 * 60 * 60 * 1000; // Hours * Minutes * Seconds * Millis
    const ghcards = document.querySelectorAll(".gh-card");
    const api_url = "https://api.github.com/repos/";

    if (ghcards.length != 0) {
        Array.prototype.forEach.call(ghcards, function(el, i){
            // Get our repo data from the cards
            const username = el.getAttribute('data-username');
            const reponame = el.getAttribute('data-repo');
            const repoId = username + "/" + reponame;

            // See if we have a cached version
            let curData = JSON.parse(localStorage.getItem(repoId));

            // If so, load the cache version if it's new enough
            if (curData && !isOld(curData)) {
                console.log("loading cache data: " + repoId);
                el.querySelectorAll(".star-count")[0].innerHTML = curData.stars;
                el.querySelectorAll(".fork-count")[0].innerHTML = curData.forks;
            } else {
                // Otherwise, get a new update and store it
                getJSON(api_url + repoId, function(data) {
                    // Parse the data we need
                    const stars = data["stargazers_count"];
                    const forks = data["forks_count"];

                    // Update the HTML
                    el.querySelectorAll(".star-count")[0].innerHTML = stars;
                    el.querySelectorAll(".fork-count")[0].innerHTML = forks;

                    // Stores the data so we don't go over Github's rate limit
                    localStorage.setItem(repoId, JSON.stringify(
                        {stars: stars, forks: forks, age: new Date().getTime()}
                    ));
                    console.log("setting cache data for: " + repoId);
                });
            }

            // A RepoObject is a
            // {stars: String, forks: String, age: int}

            // RepoObject -> boolean datatype
            // Checks if the RepoObject is old.
            function isOld(curData) {
                const curTime = new Date().getTime();
                return (curTime - curData.age) > AGE_LIMIT;
            }
        });
    }

    // String function -> null
    // Gets JSON data from url, and calls the callback with the result
    // as the param
    function getJSON(url, callback) {
        let request = new XMLHttpRequest();
        request.open('GET', url, true);

        request.onload = function() {
          if (this.status >= 200 && this.status < 400) {
            callback(JSON.parse(this.response));
          } else {
              conosle.log("GitHub Cards Update error: " + this.response);
          }
        };

        request.onerror = function() {
            console.log("GitHub Cards could not connect to Github!");
        };

        request.send()
    }
});
