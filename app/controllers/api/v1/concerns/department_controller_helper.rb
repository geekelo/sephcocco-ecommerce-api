module Api::V1::Concerns::DepartmentControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :set_department, only: [:show, :update, :destroy, :disable, :enable]
  end

  # GET /departments
  def index
    departments = department_class.all.order(created_at: :desc)

    if params[:filter].present?
      if params[:filter][:search_terms].present?
        search_term = "%#{params[:filter][:search_terms]}%"
        departments = departments.where("name ILIKE ? OR address ILIKE ?", search_term, search_term)
      end
      if params[:filter][:status].present?
        if params[:filter][:status] == "enabled"
          departments = departments.where(active: true)
        elsif params[:filter][:status] == "disabled"
          departments = departments.where(active: false)
        end
      end
      if params[:filter][:start_date].present? && params[:filter][:end_date].present?
        departments = departments.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
      elsif params[:filter][:start_date].present?
        departments = departments.where('created_at >= ?', params[:filter][:start_date])
      elsif params[:filter][:end_date].present?
        departments = departments.where('created_at <= ?', params[:filter][:end_date])
      end
      departments = departments.order(created_at: :desc)
      departments = departments.page(params[:page]).per(params[:per_page] || 20)
    end
    
    render json: {
      departments: ActiveModelSerializers::SerializableResource.new(departments, each_serializer: department_serializer_class).as_json,
      meta: {
        total_count: departments.total_count,
        total_pages: departments.total_pages,
        current_page: departments.current_page
      }
    }
  end

  # GET /departments/active
  def get_active
    departments = department_class.active.order(created_at: :desc)
    
    render json: departments, status: :ok
  end

  # GET /departments/:id
  def show
    render json: @department, status: :ok
  end

  # POST /departments
  def create
    department = department_class.new(department_params)

    if department.save
      render json: department, status: :created
    else
      render json: { errors: department.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /departments/:id
  def update
    if @department.update(department_params)
      render json: @department, status: :ok
    else
      render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /departments/:id
  def destroy
    @department.destroy
    render json: { message: "Department deleted successfully" }, status: :ok
  rescue => e
    render json: { error: "Failed to delete department: #{e.message}" }, status: :unprocessable_entity
  end

  # PATCH /departments/:id/disable
  def disable
    if @department.update(active: false)
      render json: { message: "Department disabled successfully", department: @department }, status: :ok
    else
      render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /departments/:id/enable
  def enable
    if @department.update(active: true)
      render json: { message: "Department enabled successfully", department: @department }, status: :ok
    else
      render json: { errors: @department.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_department
    @department = department_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Department not found" }, status: :not_found
  end

  def department_params
    permitted = params.require(department_param_key).permit(:name, :description, :address, :active)
    
    # Map address to description for backward compatibility
    if permitted[:address].present? && permitted[:description].blank?
      permitted[:description] = permitted[:address]
    end
    
    # Remove address since it's not a database column
    permitted.delete(:address)
    
    permitted
  end

  # To be implemented by including controllers
  def department_class
    raise NotImplementedError, "You must implement the department_class method"
  end

  def department_param_key
    raise NotImplementedError, "You must implement the department_param_key method"
  end

  def department_serializer_class
    raise NotImplementedError, "You must implement the department_serializer_class method"
  end
end
