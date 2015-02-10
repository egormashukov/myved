# encoding: utf-8

class HelpItemDecorator < Draper::Decorator
  delegate_all

  include Draper::LazyHelpers
  include ActionView::Helpers::UrlHelper

end
