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

  # Throw when a task appears to be running too long
  class TaskNotDoneError < SFRest::SFError; end
end
