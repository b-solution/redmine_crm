class UserQuery < Query

  self.queried_class = User

  self.available_columns = [
      QueryColumn.new(:login, :sortable => "#{User.table_name}.login",:groupable => true),
      QueryColumn.new(:firstname, :sortable => "#{User.table_name}.login",:groupable => true),
      QueryColumn.new(:lastname, :sortable => "#{User.table_name}.login",:groupable => true),
      QueryColumn.new(:mail, :sortable => "#{User.table_name}.login",:groupable => true),
      QueryColumn.new(:status, :sortable => "#{User.table_name}.login",:groupable => true),
      QueryColumn.new(:created_on, :sortable => "#{User.table_name}.login",:groupable => true)
       ]

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= {}
    add_filter('login', '*') unless filters.present?
  end

  def initialize_available_filters
    add_available_filter "login", :type => :string, :order => 0
    add_available_filter "firstname", :type => :string, :order => 1
    add_available_filter "lastname", :type => :string, :order => 2
    add_available_filter "mail", :type => :string, :order => 3
    add_available_filter "created_on", :type => :string, :order => 4
    add_custom_fields_filters(UserCustomField.where(:is_filter => true))
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup
    @available_columns += CustomField.where(:type => 'UserCustomField').all.map {|cf| QueryCustomFieldColumn.new(cf) }
    @available_columns
  end

  def default_columns_names
    @default_columns_names ||=  [:login, :mail, :firstname, :lastname]
  end

  def results_scope(options={})
    order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

    User.where(statement).includes(:custom_values).where("custom_values.value = 'Customers'").
        order(order_option).
        joins(joins_for_order_statement(order_option.join(',')))
  end

  # Accepts :from/:to params as shortcut filters
  def build_from_params(params)
    super
    if params[:from].present? && params[:to].present?
      add_filter('created_on', '><', [params[:from], params[:to]])
    elsif params[:from].present?
      add_filter('created_on', '>=', [params[:from]])
    elsif params[:to].present?
      add_filter('created_on', '<=', [params[:to]])
    end
    self
  end
end
