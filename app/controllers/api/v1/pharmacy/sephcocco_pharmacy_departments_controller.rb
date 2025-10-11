class Api::V1::Pharmacy::SephcoccoPharmacyDepartmentsController < ApplicationController
  include DepartmentControllerHelper

  private

  def department_class
    Pharmacy::SephcoccoPharmacyDepartment
  end

  def department_param_key
    :sephcocco_pharmacy_department
  end
end
