.pragma library

var agent = "harbour-plants/1.0 (Sailfish OS; Qt) contact:sailfish/AT/nephros.org"

var languages;

WorkerScript.onMessage = function(message) {
    if (message.type == "lookupAll") {
        //lookupCountries();
        //lookupLanguages();
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

   r.onreadystatechange = function(event) {
       if (r.readyState == XMLHttpRequest.DONE) {
           if (r.status === 200 || r.status == 0) {
               var rdata = JSON.parse(r.response);
               callback(rdata)
           } else {
               console.debug("error in processing request.", query, r.status, r.statusText);
           }
       }
   }
   r.send();
}

function lookupSpeciesByName(species, cb) {
   var url="https://api.gbif.org/v1/species/match?"
      + "name=" + encodeURI(species)
      + "&rank=species&limit=1&verbose=false"
   lookup(url, function(res) { cb(res.speciesKey); console.debug("lookupSpeciesByName found:", res.speciesKey) } )
}

function lookupLanguages() {
   var url="https://api.gbif.org/v1/enumeration/language"
   function cb(res) { WorkerScript.sendMessage({ "type": "languages", "data": res }) }
   lookup(url,cb)
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
   var url="https://api.gbif.org/v1/species/" + key + "/vernacularNames?limit=20"
   function cb(rdata) {
       var names = {}
       // collect all the names per language
       var result = rdata.results.reduce(function(names, e, i, a) {
           var newnames = []
           var oldnames = !!names[e.language] ? names[e.language] : []
           // some entries have a comma-separated list
           if (e.vernacularName.indexOf(",") != -1) {
             newnames = e.vernacularName.split(",").map(function(n) { return n.trim() } )
           } else {
             newnames = oldnames.concat([ e.vernacularName ])
           }
           // sort, unique
           names[e.language] = newnames.sort().filter(function(e,i,a) { return (i == a.length-1 || (a[i+1].toLowerCase() != e.toLowerCase())) })
           return names
       }, {})
       // Transform Object into array of objects:
       result = Object.keys(result).map(function(k) { return { "language": k, "names": result[k].join(", ") } } )
       WorkerScript.sendMessage({ "type": "names", "data": result } )
   }
   lookup(url,cb)
}
