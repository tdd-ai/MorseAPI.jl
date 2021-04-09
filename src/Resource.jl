module Resource

using ..Client, ..Auth
using Sockets
using HTTP

# add the first API function
HTTP.@register(API_ROUTER, "POST", "/analyze/", Client.handleAnalyze)

not_found(req::HTTP.Request, args) = "not found"
HTTP.@register(API_ROUTER, "/*", not_found)

port = parse(Int, get(ENV, "API_PORT", 5005))

function run()
    HTTP.serve(Auth.AuthHandler, "0.0.0.0", port)
end

end # module