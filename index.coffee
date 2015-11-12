module.exports = ( () ->

  me = @

  @.parse = (json,version,opts) ->
    opts.reftoken  = '$ref'      if not opts.reftoken?
    opts.pathtoken = '#'         if not opts.pathtoken?
    opts.refprefix = ''          if not opts.refprefix?
    opts.exportfunctions = false if not opts.exportfunctions 
    opts.version   = version
    @.opts = opts
    obj = {} ; 
    throw new Error({msg:"version #{version} not supported"}) if not @.v[version]?
    parser = @.v[version]
    for k,v of json.structure

      # entity
      plural = String(k+"s").replace( /ys$/,'ies').replace /sss$/,'ss_all'
      ref = {} ; obj[k] = {}
      #parser.set_relations v.relations,obj[k] if v.relations?
      parser.set_properties v,obj[k] if v.payload
      parser.set_requestconfig k,v.access,obj[k],'/id/{'+me.opts.refprefix+k+'.input.id.value}'
      obj[k].type = "object"
      obj[k].output = [] 
      obj[k].input =
        id: { type:"integer", value:'' }

      # collection
      ref[ opts.reftoken ] = opts.pathtoken+opts.refprefix+k
      obj[plural] = {}
      parser.set_requestconfig k,["read"],obj[plural]
      obj[plural].type = "array"
      obj[plural].items = [ ref ]

      # custom urls
      if v.custom?
        for type,cv of v.custom
          for kcv,cvv of cv
            if kcv in ["read","update","delete"]
              obj[plural].config = {} if not obj[plural].config?
              parser.add_custom_request k,type,[kcv],obj[plural],type,cvv

    return obj if not opts.exportfunctions
    return parser.export_functions obj

  @.v = 
    '1.0':

      set_relations: (relations,obj) ->
        for relation,rv of relations
          ref = {} ; ref[ me.opts.reftoken ] = me.opts.pathtoken+me.opts.refprefix+relation
          obj.output.push ref 

      set_properties: (entity,obj) ->
        obj.properties = {} if not obj.properties?
        return if not entity.payload?
        for name,pv of entity.payload 
          obj.properties[name] = pv
          if pv.resource?
            o = obj.properties[name]
            o = {} 
            o[ me.opts.reftoken ] = me.opts.pathtoken+me.opts.refprefix+pv.resource
            obj.properties[name] = o

      set_requestconfig: (key,methods,obj,slugextra = '') ->
        for method in methods
          method = @.convert_method method
          if key.match '_'
            customkey = key.split('_') ; customkey.shift()
            return @.add_custom_request key, customkey.join('_'),methods,obj,slugextra
          slug = key.replace /_/g, '/'
          url = @.get_url slug+slugextra 
          obj.config = {} if not obj.config
          obj.config.get = 
            method: method
            url: url
            payload: {}

      add_custom_request: (key,customkey,methods,obj,slugextra = '',customobj) ->
        for method in methods
          method = @.convert_method method
          slug = key.replace /_/g, '/'
          url = @.get_url slug+( if slugextra.length then '/'+slugextra else '')
          obj.config = {} if not obj.config
          obj.config[ customkey ] =
            method: method
            url: url
            payload: {}
          obj.config[ customkey ].payload = customobj.arguments if customobj and customobj.arguments?

      get_url: (slug) ->
        '/v'+me.opts.version.replace(/\..*/,'')+'/'+slug

      convert_method: (method) ->
        method = "get"     if method is "read"
        method = "post"    if method is "post"
        method = "update"  if method is "update"
        method = "delete"  if method is "delete"
        method

      export_functions: (graph) ->
        str = ''
        for name,node of graph
          for k,v of node
            if k == "config"
              for ck,cv of node.config
                str += name+"."+ck+"()\n"
        return str

  @

).apply({})
