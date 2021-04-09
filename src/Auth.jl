module Auth

export API_ROUTER

using HTTP
using JSON

# fetch authentication token
const AUTH_TOKEN = get(ENV, "AUTH_TOKEN", "")

# define http router
const API_ROUTER = HTTP.Router()

function JSONHandler(req::HTTP.Request)
    # first check if there's any request body
    try
        body = IOBuffer(HTTP.payload(req))
        if eof(body)
            # no request body
            response_body = HTTP.handle(API_ROUTER, req)
        else
            # there's a body, so pass it on to the handler we dispatch to
            response_body = HTTP.handle(API_ROUTER, req, JSON.parse(body))
        end
        return HTTP.Response(200, JSON.json(response_body))
    catch e
        s = IOBuffer()
        showerror(s, e, catch_backtrace(); backtrace=true)
        errormsg = String(resize!(s.data, s.size))
        @error errormsg
        resp = HTTP.Response(500, errormsg)
    end
end

# AuthHandler to reject any unknown users, here we authenticate using token, if we don't set the AUTH_TOKEN variable in .env file then there will be no authentication
function AuthHandler(req::HTTP.Request)
    if isempty(AUTH_TOKEN)
        return JSONHandler(req)
    elseif HTTP.hasheader(req, "Auth-Token")
        auth_token = HTTP.header(req, "Auth-Token")
        if AUTH_TOKEN == auth_token
            return JSONHandler(req)
        end
    end
    return HTTP.Response(401, "unauthorized")
end

end # module
