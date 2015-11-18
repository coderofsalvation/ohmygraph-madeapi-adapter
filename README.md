Adapter for for [ohmygraph](https://npmjs.org/packages/ohmygraph) restgraph

# Usage

    <script type="text/javascript" src="ohmygraph-madeapi-adapter.min.js"></script>

# Example

    var adapter, fs, jref, json, opts;

    adapter = require('ohmygraph-madeapi-adapter');
    ohmygraph = require('ohmygraph');
    json = .... // put your madeapi json string in here
    opts                 = {};

    json = adapter.parse(json, '1.0', opts);    // convert first
    graph = ohmygraph.create( omg_graph, {} );  // lets go ohmygraph!
  
    console.log(omg.export_functions());

And then you can just do api-calls as if you're dealing with an ORM:

    graph.books.get({q:"foo"})
  
