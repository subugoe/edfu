# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  uploadConfig =
    #statusUrl: 'http://edfu.sub.uni-goettingen.de:3000/edfu_status/status.json'
    statusUrl: '/edfu_status/status.json'
    pollingInterval: '20000' # ms
    $form: $('#new_upload')
    $submitButton: $('#button_id') #$form.find('[type=submit]')
    $messageHolder: $('#edfustatus')

  #uploadConfig.$submitButton.prop('disabled', true)

  (pollUploadStatus = ->
    again = true
    $.ajax
      url: uploadConfig.statusUrl
      dataType: 'json'
      success: (data) ->
        #console.dir data
        uploadConfig.$messageHolder.text data.message
        if data.status is 'finished'
          again = false
          #uploadConfig.$submitButton.prop('disabled', false)
        return
      complete: ->
        if again
          setTimeout (->
            pollUploadStatus()
          ), uploadConfig.pollingInterval
        return
    return
  )()