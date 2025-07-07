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
      activity_class = "#{@outlet.capitalize}::Sephcocco#{@outlet.capitalize}AdminActivity".constantize
      
      activity_class.create!(
        sephcocco_user: @user,
        activity_type: @activity_type,
        activity_name: @activity_name,
        activity_description: @activity_description
      )
    end

    private

    def activity_class
      "#{@outlet.capitalize}::Sephcocco#{@outlet.capitalize}AdminActivity".constantize
    end
  end
end 