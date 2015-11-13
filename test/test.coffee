adapter = require 'ohmygraph-madeapi-adapter'
ohmygraph = require 'ohmygraph'
jref    = require 'json-ref-lite'
fs      = require 'fs' 
json    = JSON.parse fs.readFileSync(__dirname+'/structure.json').toString()

opts = {}
opts.reftoken = '@ref'
opts.pathtoken = '@'
opts.refprefix = 'rest.'
opts.exportfunctions = true
#console.log adapter.parse json, '1.0',opts

opts.exportfunctions = false
json = adapter.parse( json, '1.0',opts)
omg = ohmygraph.create json
#console.log JSON.stringify( json, null,2)
console.log omg.export_functions()
