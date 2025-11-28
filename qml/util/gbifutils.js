.pragma library

var agent = "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"

WorkerScript.onMessage = function(message) {
    if (message.type == "lookupAll") {
        lookupCountries();
        lookupDetails(message.key)
        lookupNames(message.key)
        lookupMedia(message.key)
    }
}

function lookup(url, callback) {
   var r = new XMLHttpRequest();
   r.open("GET", url);
   r.setRequestHeader('User-Agent', agent);
   r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
   r.setRequestHeader('Accept', 'application/json');
   r.setRequestHeader('Origin', '');

   //gbifCard.xhrs += 1
   r.onreadystatechange = function(event) {
       if (r.readyState == XMLHttpRequest.DONE) {
           if (r.status === 200 || r.status == 0) {
               var rdata = JSON.parse(r.response);
               callback(rdata)
           } else {
               console.debug("error in processing request.", query, r.status, r.statusText);
           }
           //gbifCard.xhrs -= 1
       }
   }
   r.send();
}

function lookupSpeciesByName(species, out) {
   var url="https://api.gbif.org/v1/species/match?"
      + "name=" + encodeURI(species)
      + "&rank=species&limit=1&verbose=false"
   lookup(url, function(res) { out = res.speciesKey; console.debug("lookupSpeciesByName found:", out) } )
}

function lookupCountries() {
   var url="https://api.gbif.org/v1/enumeration/country"
   function cb(res) { WorkerScript.sendMessage({ "type": "countries", "data": res }) }
   lookup(url,cb)
}
function lookupDetails(key) {
   var url="https://api.gbif.org/v1/species/" + key
   function cb(res) { WorkerScript.sendMessage({ "type": "details", "data": res }  ) }
   lookup(url,cb)
}
function lookupMedia(key) {
   var url="https://api.gbif.org/v1/species/" + key + "/media/"
   function cb(rdata) {
      var res = rdata.results.filter(function(e) { return e.type == "StillImage" } )
      WorkerScript.sendMessage({ "type": "media", "data": res })
   }
   lookup(url,cb)
}

function lookupNames(key) {
   var url="https://api.gbif.org/v1/species/" + key + "/vernacularNames?limit=10"
   function cb(rdata) {
       var names = {}
       rdata.results.forEach(function(e) {
           var n = names[e.language] 
           if (!n) n = []
           if (n.indexOf(e.vernacularName) == -1) {
               n.push(e.vernacularName)
               names[e.language] = n
           }
       })
       WorkerScript.sendMessage({ "type": "names", "data": names }    )
   }
   lookup(url,cb)
}
