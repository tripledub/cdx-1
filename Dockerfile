FROM finddx/cdx-nginx-rails:2.2

# Add Foreman config
ADD Procfile /app/Procfile

CMD foreman start -f Procfile

