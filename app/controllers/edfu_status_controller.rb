class EdfuStatusController < ApplicationController

  # http://localhost:3000/edfu_status/status
  def status
    @status = EdfuStatus.last

    respond_to do |format|
      format.json { render :json => @status.to_json}
    end
  end
end
