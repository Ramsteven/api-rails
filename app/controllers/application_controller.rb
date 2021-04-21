class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end
  include JsonapiErrorsHandler


  ErrorMapper.map_errors!({
    'ActiveRecord::RecordNotFound' => 'JsonapiErrorsHandler::Errors::NotFound',
    "ActiveRecord::RecordInvalid" => "JsonapiErrorsHandler::Errors::Invalid",
    "ApplicationController::AuthorizationError" => "JsonapiErrorsHandler::Errors::Forbidden",
  })

  rescue_from ::StandardError, with: lambda  { |e| handle_error(e) }
  rescue_from ActiveRecord::RecordInvalid, with: lambda { |e| handle_validation_error(e) }
  rescue_from UserAuthenticator::AuthenticationError, with: :authentication_error
  rescue_from AuthorizationError, with: :authorization_error
  before_action :authorize!

  private

  def authorize!
    raise AuthorizationError unless current_user
  end

  def access_token
    provided_token = request.authorization&.gsub(/\ABearer\s/, '')
    @access_token = AccessToken.find_by(token: provided_token)
  end

  def current_user
    @current_user = access_token&.user
  end

  def authentication_error
    error = {
      "status" => "401",
      "source" => { "pointer" => "/code" },
      "title" =>  "Authentication code is invalid",
      "detail" => "You must provide valid code in order to exchange it for token."
    }
    render json: { "errors": error }, status: 401
  end

  def authorization_error
    error = {
      "status" => "403",
      "source" => { "pointer" => "/headers/authorization" },
      "title" =>  "Not authorized",
      "detail" => "You have no right to access this resource."
    }
    render json: { "errors": error }, status: 403
  end

  def handle_validation_error(error)
    error_model = error.try(:model) || error.try(:record)
    errors = error_model.errors.reduce([]) do |r, e|
      r << {
          "status": 422,
          "title": "Invalid request",
          "detail": e.message,
          "source": { pointer: "/data/attributes/#{e.attribute}" }
      }
    end
    render json: { "errors": errors }, status: 422
  end
end
