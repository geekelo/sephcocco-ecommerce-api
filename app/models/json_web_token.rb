class JsonWebToken
  JWT_SECRET_KEY = ENV.fetch("JWT_SECRET_KEY") { raise "JWT_SECRET_KEY is missing in environment variables" }

  def self.encode(payload)
    JWT.encode(payload, JWT_SECRET_KEY, "HS256")
  end

  def self.decode(token)
    JWT.decode(token, JWT_SECRET_KEY, true, { algorithm: "HS256" }).first
  rescue
    nil
  end
end
