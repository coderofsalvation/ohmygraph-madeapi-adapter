adapter = require 'ohmygraph-madeapi-adapter'
jref    = require 'json-ref-lite'
fs      = require 'fs' 
json    = JSON.parse fs.readFileSync(__dirname+'/structure.json').toString()

console.dir adapter.parse json, '1.0'
