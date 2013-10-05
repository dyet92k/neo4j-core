module Neo4j::Server

  class CypherRelationship < Neo4j::Relationship
    include Neo4j::Server::Resource

    def initialize(session)
      @session = session
    end

    def ==(o)
      o.class == self.class && o.neo_id == neo_id
    end
    alias_method :eql?, :==

    def neo_id
      resource_url_id
    end

    def inspect
      "CypherRelationship #{neo_id}, start #{resource_url_id(resource_url(:start))} end #{resource_url_id(resource_url(:end))} (#{object_id})"
    end

    def start_node
      id = resource_url_id(resource_url(:start))
      Neo4j::Node.load(id)
    end

    def end_node
      id = resource_url_id(resource_url(:end))
      Neo4j::Node.load(id)
    end

    def get_property(key)
      id = neo_id
      r = @session.query{rel(id)[key]}
      expect_response_code(r.response, 200)
      r.first_data
    end

    def set_property(key,value)
      id = neo_id
      r = @session.query{rel(id)[key]=value}
      expect_response_code(r.response, 200)
    end

    def remove_property(key)
      id = neo_id
      r = @session.query{rel(id)[key]=:NULL}
      expect_response_code(r.response, 200)
    end

    def del
      id = neo_id
      @session.query{rel(id).del}.raise_unless_response_code(200)
    end

    def exist?
      id = neo_id
      response = @session.query{rel(id)}

      if (!response.error?)
        return true
      elsif (response.error_status == 'BadInputException') # TODO see github issue neo4j/1061
        return false
      else
        response.raise_error
      end
    end

  end
end