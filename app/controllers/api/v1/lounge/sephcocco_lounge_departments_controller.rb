class Api::V1::Lounge::SephcoccoLoungeDepartmentsController < ApplicationController
  include DepartmentControllerHelper

  private

  def department_class
    Lounge::SephcoccoLoungeDepartment
  end

  def department_param_key
    :sephcocco_lounge_department
  end
end
