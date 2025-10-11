module DepartmentControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :set_department, only: [:show, :update, :destroy, :disable, :enable]
  end

  # GET /departments
  def index
    departments = department_class.all.order(created_at: :desc)
    
    render json: departments, status: :ok
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
    params.require(department_param_key).permit(:name, :description, :active)
  end

  # To be implemented by including controllers
  def department_class
    raise NotImplementedError, "You must implement the department_class method"
  end

  def department_param_key
    raise NotImplementedError, "You must implement the department_param_key method"
  end
end
