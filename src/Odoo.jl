VERSION >= v"0.4.0-dev+6521" && __precompile__(true)

module Odoo

using XMLRPC

export OdooServer, AuthenticatedOdooSession

immutable OdooServer
    url::AbstractString
end

const common_endpt = "/xmlrpc/2/common"
const object_endpt = "/xmlrpc/2/object"

immutable AuthenticatedOdooSession
    server::OdooServer
    db::AbstractString
    uid::Int
    pw::AbstractString
end

common(o::OdooServer) = XMLRPCProxy(o.url*common_endpt)
object(o::OdooServer) = XMLRPCProxy(o.url*object_endpt)
common(o::AuthenticatedOdooSession) = XMLRPCProxy(o.server.url*common_endpt)
object(o::AuthenticatedOdooSession) = XMLRPCProxy(o.server.url*object_endpt)

"""
Create a `AuthenticatedOdooSession` using the Odoo demo service.
"""
function demo_server()
    info = XMLRPCProxy("https://demo.odoo.com/start")["start"]()
    AuthenticatedOdooSession(info["host"], info["database"], info["user"], info["password"])
end

function version(o::Union{OdooServer, AuthenticatedOdooSession})
    common(o)["version"]()
end

function AuthenticatedOdooSession(o::OdooServer,
                                  db::AbstractString,
                                  username::AbstractString,
                                  pw::AbstractString)
    uid = common(o)["authenticate"](db, username, pw, [])
    AuthenticatedOdooSession(o, db, uid, pw)
end

function AuthenticatedOdooSession(o::AbstractString,
                                  db::AbstractString,
                                  username::AbstractString,
                                  pw::AbstractString)
    AuthenticatedOdooSession(OdooServer(o), db, username, pw)
end


function execute_kw(a::AuthenticatedOdooSession, args...)
    object(a)["execute_kw"](a.db, a.uid, a.pw, args...)
end


"""
List Odoo record fields, optionally constrain the
listed attributes.
"""
function Base.fieldnames(a::AuthenticatedOdooSession, d::AbstractString,
                         args::AbstractString...)
    execute_kw(a, d, "fields_get", [], isempty(args) ? Dict() :
                                       Dict("attributes" => [args...]))
end

"""
Search Odoo record fields.

Example:

```
search(odoo, "product.template", ["name", "=", "FooBarProduct"])
```
"""
function Base.search(a::AuthenticatedOdooSession, d::AbstractString,
                         args...)
    execute_kw(a, d, "search", Any[Any[args...]])
end

"""
Read Odoo record fields.

"""
function Base.read(a::AuthenticatedOdooSession, d::AbstractString,
                         args::Array)
    execute_kw(a, d, "read", Any[args])
end

Base.read(a::AuthenticatedOdooSession, d::AbstractString, args::Integer...) =
    read(a,d, [args...])


end # module
