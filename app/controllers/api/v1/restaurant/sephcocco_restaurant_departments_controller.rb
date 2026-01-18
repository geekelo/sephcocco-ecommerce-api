class Api::V1::Restaurant::SephcoccoRestaurantDepartmentsController < ApplicationController
  include Api::V1::Concerns::DepartmentControllerHelper

  private

  def department_class
    Restaurant::SephcoccoRestaurantDepartment
  end

  def department_param_key
    :sephcocco_restaurant_department
  end

  def department_serializer_class
    Restaurant::SephcoccoRestaurantDepartmentSerializer
  end
end
