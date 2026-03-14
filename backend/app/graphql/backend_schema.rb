# frozen_string_literal: true

class BackendSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    if err.is_a?(GraphQL::InvalidNullError)
      # Log the error to know the database data violates the schema contract
      Rails.logger.error("GraphQL InvalidNullError: #{err.message}")
      # Return nil to let GraphQL bubble up the null instead of crashing the entire request
      return nil
    end
    
    super
  end

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    # Infer the GraphQL Type from the ActiveRecord Model class name
    type_class_name = "Types::#{obj.class.name}Type"
    type_class_name.safe_constantize || raise(GraphQL::RequiredImplementationMissingError, "Could not resolve type for object: #{obj.inspect}")
  end

  # Limit the size of incoming queries:
  max_query_string_tokens(5000)

  # Stop validating when it encounters this many errors:
  validate_max_errors(100)

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    object.to_gid_param
  end

  # Given a string UUID, find the object
  def self.object_from_id(global_id, query_ctx)
    GlobalID.find(global_id)
  end
end