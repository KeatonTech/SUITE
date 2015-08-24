# Can't live without this
window.wait = (t, f) -> setTimeout f, t

window._sh = window.SUITE.Helpers =
  camelToDash: (str)-> str.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
  dashToCamel: (str)-> str.toLowerCase().replace /([a-z])-([a-z])/g, (_,a,b)->
    "#{a}#{b.toUpperCase()}"

  time: (label, func)->
    start_time = new Date().getTime()
    func()
    diff = (new Date().getTime()) - start_time
    console.log "#{label} took #{diff}ms"
