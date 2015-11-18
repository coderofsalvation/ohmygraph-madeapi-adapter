module.exports = ( () ->

  me = @

  @.parse = (json,version,opts) ->
    opts.reftoken  = '$ref'      if not opts.reftoken?
    opts.pathtoken = '#'         if not opts.pathtoken?
    opts.refprefix = ''          if not opts.refprefix?
    opts.version   = version
    @.opts = opts
    obj = {} ; 
    throw new Error({msg:"version #{version} not supported"}) if not @.v[version]?
    parser = @.v[version]
    parser.patch json
    for k,v of json.structure

      # entity
      plural = parser.make_plural k 
      ref = {} ; obj[k] = {}
      #parser.set_relations v.relations,obj[k] if v.relations?
      parser.set_properties v,obj[k] if v.payload?
      parser.set_requestconfig k,v.access,obj[k],'/id/{'+me.opts.refprefix+k+'.input.id.value}'
      obj[k].type = "object"
      obj[k].output = [] 
      obj[k].input =
        id: { type:"integer", value:'' }

      # collection
      ref[ opts.reftoken ] = opts.pathtoken+opts.refprefix+k
      obj[plural] = {}
      obj[plural].type = "array"
      obj[plural].items = [ ref ]
      parser.set_requestconfig k,["read"],obj[plural]

      # custom urls
      if v.custom?
        for type,cv of v.custom
          for kcv,cvv of cv
            if kcv in ["read","update","delete"]
              obj[plural].config = {} if not obj[plural].config?
              parser.add_custom_request k,type,[kcv],obj[plural],type,cvv

    return obj

  @.v = 
    '1.0':

      patch: (json) ->
        json = json #json.structure.carecenter.custom.search.read.arguments.query.date.default = "flop"

      make_plural: (str) -> String(str+"s").replace( /ys$/,'ies').replace /sss$/,'ss_all'

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
          _method = @.convert_method method
          if key.match '_'
            customkey = key.split('_') ; customkey.shift()
            return @.add_custom_request key, method,methods,obj,slugextra
          slug = key.replace /_/g, '/'
          url = @.get_url slug+slugextra 
          obj.request = {} if not obj.request
          obj.request[method] = 
            config:
              method: _method
              url: url
              payload: {}
          if obj.type == "array"
            # hardcoded because no replyschema is provided
            for i in [{sort:"weight"},{limit:20},{offset:0}]
              k = Object.keys(i)[0] ; val = i[k]
              obj.input = {} if not obj.input?
              obj.input[ k ] = val 
              #obj.request[method].config.payload[ k ] = {}
              #obj.request[method].config.payload[ k ][ me.opts.reftoken ] = me.opts.pathtoken + @.make_plural(key)+".input."+k
              obj.request[method].config.payload[ k ] = '{'+@.make_plural(key)+".input."+k+'}'

      add_custom_request: (key,customkey,methods,obj,slugextra = '',customobj) ->
        for method in methods
          method = @.convert_method method
          slug = key.replace /_/g, '/'
          url = @.get_url slug+( if slugextra.length then '/'+slugextra else '')
          obj.request = {} if not obj.request
          obj.request[ customkey ] =
            config:
              method: method
              url: url
              payload: {}
          if customobj and customobj.arguments? #and customobj.arguments.length
            reqobj = obj.request[ customkey ]
            obj.input = {} if not obj.input?
            obj.input[ customkey ] = {} if not obj.input[ customkey ]?
            reqobj.config.payload = customobj.arguments
            if reqobj.config.payload.query?
              payload = reqobj.config.payload
              for qk,qv of payload.query
                qv.value = ( if qv.default? then qv.default else '' )
                obj.input[ qk ] = qv.value
                #payload[ qk ] = {}
                #payload[ qk ][ me.opts.reftoken ] = me.opts.pathtoken + ( if obj.type == "array" then @.make_plural(key) else key )+".input.#{customkey}."+qk
                payload[ qk ] = '{'+ ( if obj.type == "array" then @.make_plural(key) else key )+".input."+qk+'}'
              delete payload.query

      get_url: (slug) ->
        '/v'+me.opts.version.replace(/\..*/,'')+'/'+slug

      convert_method: (method) ->
        method = "get"     if method is "read"
        method = "post"    if method is "post"
        method = "update"  if method is "update"
        method = "delete"  if method is "delete"
        method

  @

).apply({})
