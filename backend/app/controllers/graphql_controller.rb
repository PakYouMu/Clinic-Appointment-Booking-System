# frozen_string_literal: true

class GraphqlController < ApplicationController
  # Include cookie support (not included by default in API-only mode)
  include ActionController::Cookies

  COOKIE_NAME = "_mustard_clinic_token "

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    
    app_type = request.headers['HTTP_X_APP_TYPE'] || request.headers['x-app-type'] || 'patient'
    
    context = {
      app_type: app_type,
      current_user: current_user(app_type),
      set_cookie: ->(token) { set_auth_cookie(token, app_type) },
      clear_cookie: -> { clear_auth_cookie(app_type) }
    }

    result = BackendSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def cookie_name_for(app_type)
    app_type == 'admin' ? "_clinic_admin_token" : "_clinic_patient_token"
  end

  def current_user(app_type)
    token = cookies[cookie_name_for(app_type)]
    return nil unless token

    payload = AuthToken.decode(token)
    return nil unless payload

    user = User.find_by(id: payload[:sub])
    
    # Ensure the user has the correct role for the app they are accessing
    return nil if user.nil?
    return nil if app_type == 'admin' && !user.admin?
    return nil if app_type == 'patient' && !user.patient?
    
    user
  end

  def set_auth_cookie(token, app_type)
    cookies[cookie_name_for(app_type)] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: Rails.env.production? ? :none : :lax,
      expires: 24.hours.from_now,
      path: "/"
    }
  end

  def clear_auth_cookie(app_type)
    cookies.delete(cookie_name_for(app_type), path: "/")
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
