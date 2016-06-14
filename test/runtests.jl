using Odoo
using Base.Test

# write your own tests here
demo = Odoo.demo_server()
@show demo
@show Odoo.version(demo)
