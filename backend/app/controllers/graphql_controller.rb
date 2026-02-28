# frozen_string_literal: true

class GraphqlController < ApplicationController
  # Include cookie support (not included by default in API-only mode)
  include ActionController::Cookies

  COOKIE_NAME = "_vue_boilerplate_token"

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    context = {
      current_user: current_user,
      set_cookie: ->(token) { set_auth_cookie(token) },
      clear_cookie: -> { clear_auth_cookie }
    }

    result = BackendSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def current_user
    token = cookies[COOKIE_NAME]
    return nil unless token

    payload = AuthToken.decode(token)
    return nil unless payload

    User.find_by(id: payload[:sub])
  end

  def set_auth_cookie(token)
    cookies[COOKIE_NAME] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :strict,
      expires: 24.hours.from_now,
      path: "/"
    }
  end

  def clear_auth_cookie
    cookies.delete(COOKIE_NAME, path: "/")
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
