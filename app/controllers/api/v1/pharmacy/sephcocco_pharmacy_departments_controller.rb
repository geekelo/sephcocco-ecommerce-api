class Api::V1::Pharmacy::SephcoccoPharmacyDepartmentsController < ApplicationController
  include Api::V1::Concerns::DepartmentControllerHelper

  private

  def department_class
    Pharmacy::SephcoccoPharmacyDepartment
  end

  def department_param_key
    :sephcocco_pharmacy_department
  end
end
