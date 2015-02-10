$('.js-msg-dialogue').append("<%= j render 'window_message', msg: @message %>")
$('.js-enter-autosubmit').val('')

h = $('.js-msg-dialogue').height()
$('.js-msg-dialogue').scrollTop(h)

# $("#dialogue_inset_<%= @message.receiver_id %> .messages_block").prepend('<%= j render "messages/dialogue_message", message: @message %>');

# if ($("#messages_from_<%= @message.receiver_id %>").length == 1) {
#   $("#messages_from_<%= @message.receiver_id %>").html('<%= j render @message, contractor: @message.receiver, resource: @messagable %>').insertBefore($(".messages_from").first());
# } else {
#   $(".messages_from").first().before('<%= j render @message, contractor: @message.receiver, resource: @messagable %>');
# }

# $('.window_dialogue').find('input:text, textarea').val('')
# $(".menu_dialogues").trigger("click")
