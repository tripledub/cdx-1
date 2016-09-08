FROM finddx/cdx-nginx-rails:2.3.1

# Add Foreman config
ADD Procfile /app/Procfile

CMD foreman start -f Procfile

