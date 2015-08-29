# Can't live without this
window.wait = (t, f) -> setTimeout f, t

window._sh = window.SUITE.Helpers =
  camelToDash: (str)-> str.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
  dashToCamel: (str)-> str.replace /([A-Za-z])-([A-Za-z])/g, (_,a,b)->
    "#{a.toLowerCase()}#{b.toUpperCase()}"

  time: (label, func)->
    start_time = new Date().getTime()
    result = func()
    diff = (new Date().getTime()) - start_time
    console.log "#{label} took #{diff}ms"
    return result

  generateID: (len)->
    Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, len)
