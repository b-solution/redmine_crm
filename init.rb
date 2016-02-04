Redmine::Plugin.register :redmine_crm do
  name 'Redmine CRM plugin'
  author 'Bilel Kedidi'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :top_menu, :customers,
       {:controller => 'customers', :action => 'index'},
       :caption => :label_customer_plural,
       :if => Proc.new{ User.current.admin?}
  end

Rails.application.config.to_prepare do
  User.send(:include, RedmineCrm::UserPatch)
end


