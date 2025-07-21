# Action Cable configuration
Rails.application.configure do
  # Allow requests from all origins in development
  config.action_cable.disable_request_forgery_protection = true
  
  # Allow all origins for Action Cable
  config.action_cable.allowed_request_origins = [
    'http://localhost:3000',
    'http://localhost:5173',
    'https://sephcocco-eccomerce-admin.vercel.app',
    'https://sephcocco-lounge-user.vercel.app',
    'https://sephcocco-lounge-api.onrender.com'
  ]
end 