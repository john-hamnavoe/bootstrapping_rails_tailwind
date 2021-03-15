# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
  include SessionsHelper
  delegate :current_user, to: :connection

  def search
    session[session_symbol("query")] = element[:value].strip
  end

  def order
    session[session_symbol("order_by")] = element.dataset["column-name"]
    session[session_symbol("direction")] = element.dataset["direction"]
  end

  def paginate
    session[session_symbol("page")] = element.dataset[:page].to_i
  end

  def toggle
    session[session_symbol("selected_id")] = element.dataset[:id].to_i
  end

  def account_address_select
    key = "adddress_#{element.dataset['account-id']}"
    session[key] = element.value unless element.value.empty?
    session.delete(key) if element.value.empty?
    @key = key
  end
end
