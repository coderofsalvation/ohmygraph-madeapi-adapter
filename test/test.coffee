adapter = require 'ohmygraph-madeapi-adapter'
jref    = require 'json-ref-lite'
fs      = require 'fs' 
json    = JSON.parse fs.readFileSync(__dirname+'/structure.json').toString()

opts = {}
opts.reftoken = '@ref'
opts.pathtoken = '@'
opts.refprefix = 'rest.'
opts.exportfunctions = true
console.log adapter.parse json, '1.0',opts

opts.exportfunctions = false
console.log JSON.stringify adapter.parse( json, '1.0',opts), null, 2
