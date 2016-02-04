require_dependency 'user'

module  RedmineCrm
  module UserPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
       before_validation :check_email
      end
    end

  end
  module ClassMethods
    def visible
      includes(:projects)
    end
  end

  module InstanceMethods
    def check_email
      if self.mail.blank?
        self.mail = "usercustomer#{User.count+1}@example.net"
      end
    end

    def project(current_project=nil)
      return @project if @project
      if current_project && self.projects.visible.include?(current_project)
        @project  = current_project
      else
        @project  = self.projects.visible.first
      end

      @project ||= self.projects.first
    end
  end

end