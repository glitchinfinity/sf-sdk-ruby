module SFRest
  # Error classes for SFRest

  # Extends StandardError so we can catch SFRest::SFError
  class SFError < StandardError; end

  # Throw this when a user cannot successfuly authenticate
  class AccessDeniedError < SFRest::SFError; end

  # Throw this when a user does not have permission to perform an action
  class ActionForbiddenError < SFRest::SFError; end

  # Throw this when the request is incomplete or otherwise cannot be processed by
  # the factory
  class BadRequestError < SFRest::SFError; end

  # Throw this when the request contains unprocessable entity.
  class UnprocessableEntity < SFRest::SFError; end

  # Throw when a task appears to be running too long
  class TaskNotDoneError < SFRest::SFError; end

  # if you get in valid data
  class InvalidDataError < SFRest::SFError; end

  # If the return cannot be parsed into something useful
  class InvalidResponse < SFRest::SFError; end
end
