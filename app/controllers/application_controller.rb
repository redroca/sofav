module Admin
  class ApplicationController < ::ApplicationController
    layout "admin"

    include Admin::ActionController
    include Admin::CommonActions
    include ApplicationHelper

    helper_method :scope, :model, :decorator, :record, :decorate, :records, :render_to_string

    before_action :authenticate_user!
    before_action do
      if current_user.user? or current_user.role.blank?
        render :file => "public/403.html", :status => :unauthorized, :layout => false
      end
    end

    before_action do
      prepend_view_path 'app/views/admin/application'
    end

  end
end
