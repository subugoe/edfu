class EdfuStatusController < ApplicationController

  # http://localhost:3000/edfu_status/status
  def status
    @status = EdfuStatus.first
  end
end
