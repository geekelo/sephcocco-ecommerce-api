class Api::V1::Restaurant::SephcoccoRestaurantDepartmentsController < ApplicationController
  include DepartmentControllerHelper

  private

  def department_class
    Restaurant::SephcoccoRestaurantDepartment
  end

  def department_param_key
    :sephcocco_restaurant_department
  end
end
