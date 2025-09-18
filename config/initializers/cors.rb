Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins [ "https://app.sephcocco.com.ng", "https://manage.sephcocco.com.ng", "http://localhost:3000", "https://sephcocco-eccomerce-admin.vercel.app", "https://sephcocco-lounge-user.vercel.app", "http://localhost:5173" ] # Add your frontend origin(s)

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
    
    resource "/cable",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end
end
