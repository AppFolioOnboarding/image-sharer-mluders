module ApplicationHelper
  def current_controller_actions?(controller, actions)
    params[:controller].eql?(controller) && actions.include?(params[:action])
  end
end
