module.exports = ( () ->

  @.parse = (json, version, reftoken = '$', pathtoken = '#' ) ->
    obj = {}
    throw new Error({msg:"version #{version} not supported"}) if not @.v[version]?
    parser = @.v[version]
    for k,v of json.structure
      obj[k] = {}
      parser.get_relations  v.relations,obj[k] if v.relations?
      parser.get_properties v,obj[k] if v.relations?
    obj

  @.v = 
    '1.0':

      get_relations: (relations,obj) ->
        obj.output = [] if not obj.output?
        for relation,rv of relations
          ref = {} ; ref[ reftoken+"ref" ] = pathtoken+"/"+relation
          obj.output.push ref 

      get_properties: (entity,obj) ->
        obj.properties = {} if not obj.properties?
        return if not entity.payload?
        for name,pv of entity.payload 
          obj.properties[name] = pv

  @

).apply({})
