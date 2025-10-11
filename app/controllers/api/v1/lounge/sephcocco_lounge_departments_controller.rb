class Api::V1::Lounge::SephcoccoLoungeDepartmentsController < ApplicationController
  include Api::V1::Concerns::DepartmentControllerHelper

  private

  def department_class
    Lounge::SephcoccoLoungeDepartment
  end

  def department_param_key
    :sephcocco_lounge_department
  end
end
