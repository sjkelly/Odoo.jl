using Odoo
using Base.Test

# write your own tests here
demo = Odoo.demo_server()
@show demo
@show Odoo.version(demo)

@show Odoo.execute_kw(demo,
    "res.partner", "check_access_rights",
    ["read"], Dict("raise_exception" => false))
