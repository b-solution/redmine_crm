class CustomersController < ApplicationController
  unloadable

  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper

  def index
    # hash = {"set_filter"=>"1", "f"=>[ "cf_1"], "op"=>{"cf_1"=>"="}, "v"=>{"cf_1"=>["Customers"]}, "group_by"=>"" }
    #
    # params.reverse_merge!(hash)
    @query = UserQuery.build_from_params(params, :name => '_')

    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      case params[:format]
        when 'csv', 'pdf'
          @limit = Setting.issues_export_limit.to_i
          if params[:columns] == 'all'
            @query.column_names = @query.available_inline_columns.map(&:name)
          end
        when 'atom'
          @limit = Setting.feeds_limit.to_i
        when 'xml', 'json'
          @offset, @limit = api_offset_and_limit
          @query.column_names = %w(author)
        else
          @limit = per_page_option
      end
      scope = @query.results_scope({:order => sort_clause})
      @entry_count = scope.count
      @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
      @users = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).all
      render :layout => !request.xhr?
    else
      respond_to do |format|
        format.html { render(:template => 'issues/index', :layout => !request.xhr?) }
        format.any(:atom, :csv, :pdf) { render(:nothing => true) }
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
