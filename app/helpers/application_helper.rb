module ApplicationHelper
  class TargetBlankRenderer < Redcarpet::Render::HTML
    def initialize(extensions = {})
      super extensions.merge(link_attributes: { target: "_blank" })
    end
  end

  def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /^http/
      abs_path = "#{request.protocol}#{request.host_with_port}#{abs_path}"
    end
   abs_path
  end

  # Dynamic current userable method depending on the user's role
  # Example: if current_user is a member you can simply call current_member
  User::ROLES.each do |role|
    define_method "current_#{role.downcase}" do
      current_user.userable if user_signed_in?
    end
  end

  def edit_current_user_path(user, new_user = nil)
    send("edit_#{user.class.name.downcase}_path", user, new_user)
  end

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
    options = {
      underline: true,
      space_after_headers: true,
      highlight: true,
      lax_spacing: true,
      autolink: true,
      no_intra_emphasis: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end

  def markdown_for_additional_links(text)
    renderer = TargetBlankRenderer.new(hard_wrap: true, filter_html: true)
    options = {
      underline: true,
      space_after_headers: true,
      highlight: true,
      lax_spacing: true,
      autolink: true,
      no_intra_emphasis: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end

  def tab_class(activator)
    'active' if params[:controller] == activator
  end

  def filter_class(filter)
    'active' if params[:filter] == filter
  end

  def url_with_protocol(url)
    if url[/^https?/]
      url
    else
      "http://#{url}"
    end
  end

  def preview_url(url)
    content_tag :div, class: 'url-preview js-url-preview' do
      Onebox.preview(url_with_protocol(url)).to_s.html_safe
    end
  end

  DEFAULT_KEY_MATCHING = {
    alert:      :danger,
    notice:     :success,
    info:       :info,
    secondary:  :info,
    success:    :success,
    error:      :danger,
    warning:    :warning
  }

  def display_flash_messages
    flash.reduce '' do |message, (key, value)|
      if value.is_a?(Array)
        value.each do |val|
          message += build_message(key: key, value: val, key_match: DEFAULT_KEY_MATCHING)
        end
        message
      else
        build_message(key: key, value: value, key_match: DEFAULT_KEY_MATCHING)
      end
    end.html_safe
  end

  private

  def build_message(args)
    html = content_tag :div, data: { alert: '' }, class: "alert alert-#{args[:key_match][args[:key].to_sym] || :standard} alert-dismissible" do
      raw "<button type='button' class='close' data-dismiss='alert' aria-label='Close'>
           <span aria-hidden='true'>&times;</span></button>
           #{args[:value]}"
    end
    html.html_safe
  end
end
