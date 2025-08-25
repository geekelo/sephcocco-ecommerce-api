module AdminActivities
  class CreateService
    def initialize(user:, activity_type:, activity_name:, activity_description:, outlet:)
      @user = user
      @activity_type = activity_type
      @activity_name = activity_name
      @activity_description = activity_description
      @outlet = outlet
    end

    def call
      # Handle both Module and String types for @outlet
      outlet_name = @outlet.is_a?(Module) ? @outlet.name : @outlet
      activity_class = "#{outlet_name.capitalize}::Sephcocco#{outlet_name.capitalize}AdminActivity".constantize
      
      activity_class.create!(
        sephcocco_user: @user,
        activity_type: @activity_type,
        activity_name: @activity_name,
        activity_description: @activity_description
      )
    end
  end
end 