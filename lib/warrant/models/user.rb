# frozen_string_literal: true

module Warrant
  class User
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end
  end
end
