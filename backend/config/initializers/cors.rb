# Be sure to restart your server when you modify this file.

# Allow the React dev server (Vite) to call this API directly during development.
# In production the frontend is expected to be served from the same origin or
# behind a proxy, so set FRONTEND_ORIGIN accordingly.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:5173")

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
