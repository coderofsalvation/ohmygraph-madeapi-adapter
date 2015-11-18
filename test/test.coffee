adapter = require 'ohmygraph-madeapi-adapter'
ohmygraph = require 'ohmygraph'
jref    = require 'json-ref-lite'
fs      = require 'fs' 
json    = JSON.parse fs.readFileSync(__dirname+'/structure.json').toString()

opts = {}
opts.reftoken = '@ref'
opts.pathtoken = '@'
opts.extendtoken = '@extend'
opts.baseurl  = 'http://proxy.plaatz-core.cloud.2webapp.com'
opts.verbose = 2
#console.log adapter.parse json, '1.0',opts

aopts = JSON.parse JSON.stringify opts 
json = adapter.parse( json, '1.0',aopts)
require('fs').writeFileSync __dirname+"/omg.json", JSON.stringify(json,null,2)
omg = ohmygraph.create json, opts
omg.init.client()
require('fs').writeFileSync __dirname+"/omg.resolved.json", JSON.stringify(omg.graph,null,2)
api = omg.graph
#console.log JSON.stringify( json, null,2)
#console.log omg.export_functions()

api.caretypes.on 'data', (caretypes) ->
  console.dir caretypes

api.carecenters.on 'data', (carecenters) ->
  console.dir carecenters
console.log "todo: provide payload"
#api.caretypes.read({sort:"weight"})

api.carecenters.input.date = '2015-12-01'
api.carecenters.search()

api.carecenters.search({date:'2015-12-02'})
