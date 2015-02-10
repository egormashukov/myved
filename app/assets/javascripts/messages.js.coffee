# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  $('body').on 'click', '.js-open-messages-link', (e) ->
    e.preventDefault()
    messagable_type = $(@).data('messagable-type')
    messagable_id = $(@).data('messagable-id')
    contractor_id = $(@).data('contractor-id')
    someData = {}
    someData["#{messagable_type}"] = messagable_id
    someData['contractor_id'] = contractor_id

    $.ajax(
      url: '/messages'
      type: 'GET'
      data: someData
      success: (data) ->
        if $('.js-msg-window').length > 0
          $('.js-msg-window').replaceWith(data)
          h = $('.js-msg-dialogue').height()
          $('.js-msg-dialogue').scrollTop(h)
        else
          $('body').append(data)
          $('.js-msg-window').hide().stop().fadeIn()
          h = $('.js-msg-dialogue').height()
          $('.js-msg-dialogue').scrollTop(h)
    )

  $('body').on 'click', '.js-messages-window-close', (e) ->
    e.preventDefault()
    $('.js-msg-window').stop().fadeOut()


# $ ->
#   $("body").on "click", ".ask_button", (e) ->
#     e.preventDefault()
#     title = $(@).data("title")
#     receiver = $(@).data("receiver")
#     $(".messages").first().trigger("click")
#     $(".menu_messagable_new").first().trigger("click")
#     $("#message_title").val(title)
#     $("#message_receiver_id").select2("val", receiver)

# $ ->
#   height = $('.lk-column1').height() - 42
#   if $('.lk-column1').length > 0
#     $('.lk-column2 .main_message').height(height)

# $ ->
#   $(".menu_dialogue").hide()
#   $(".dialogue_inset").hide()
#   $(".messagable_new").hide()

#   $(".menu_dialogues").addClass('active')

#   $(".dialogues_inset").on 'click', '.message_dialogue_link', (e) ->
#     e.preventDefault()
#     messagableType = $(@).attr("data-messagable-type")
#     messagableId = $(@).attr("data-messagable-id")
#     contractorId = $(@).attr("data-contractor")
#     link = $(@).parents(".message_collected").first()
#     $.ajax
#       url: "/messages/get_dialogue"
#       type: 'GET'
#       dataType: 'html'
#       data: {'messagable_type': messagableType, 'messagable_id': messagableId, "contractor": contractorId}
#       success: (html) ->
#         link.removeClass("not_read")
#         $(".dialogue_inset").attr("id","dialogue_inset_#{contractorId}").html(html)
#         $(".menu_dialogue").show()
#         showDialogue()
#         notRead = $(".dialogue_inset .not_read")
#         updateMessagesCount(notRead.length)
#         setTimeout(
#           -> notRead.removeClass("not_read")
#           2000
#         )
#         csrf_token = $('meta[name=csrf-token]').attr('content')
#         csrf_param = $('meta[name=csrf-param]').attr('content')
#         if csrf_param != undefined && csrf_token != undefined
#           params = csrf_param + "=" + encodeURIComponent(csrf_token)
#         $('.redactor').redactor({ "imageUpload":"/redactor_rails/pictures?" + params, "imageGetJson":"/redactor_rails/pictures", "path":"/assets/redactor-rails", "css":"style.css", "buttons": ['bold', 'italic', 'unorderedlist', 'orderedlist'], "minHeight": 150})


#   $(".dialogue_inset").on 'click', '.show_more_messages', (e) ->
#     e.preventDefault()
#     messagableType = $(@).attr("data-messagable-type")
#     messagableId = $(@).attr("data-messagable-id")
#     contractorId = $(@).attr("data-contractor")

#     $.ajax
#       url: "/messages/get_more_messages"
#       type: 'GET'
#       dataType: 'html'
#       data: {'messagable_type': messagableType, 'messagable_id': messagableId, "contractor": contractorId, "last_position": $(".dialogue_inset .messages_block .dialogue_message").length}
#       success: (html) ->
#         $(".dialogue_inset .messages_block").append(html)
#         if $(html).filter("div.dialogue_message").length < 10
#           $(".show_more_messages").hide()

#   $(".messages_menu").on "click", ".menu_dialogue", (e) ->
#     e.preventDefault()
#     showDialogue()

#   $(".messages_menu").on "click", ".menu_dialogues", (e) ->
#     e.preventDefault()
#     $(".dialogue_inset").hide()
#     $(".messagable_new").hide()
#     $(".dialogues_inset").show() 
#     $(".messages_menu a").removeClass('active')
#     $(@).addClass('active')

#   $(".messages_menu").on "click", ".menu_messagable_new", (e) ->
#     e.preventDefault()
#     $(".messagable_new").show()
#     $(".dialogue_inset").hide()
#     $(".dialogues_inset").hide() 
#     $(".messages_menu a").removeClass('active')
#     $(@).addClass('active')

# updateMessagesCount = (read) ->
#   $(".not_read_messages").each ->
#     numb = $(@).text() - read
#     if numb > 0
#       $(@).text(numb)
#     else
#       $(@).hide()

# showDialogue = ->
#   $(".messages_menu a").removeClass('active')
#   $(".menu_dialogue").addClass("active")
#   $(".dialogues_inset").hide()
#   $(".messagable_new").hide()
#   $(".dialogue_inset").show()

