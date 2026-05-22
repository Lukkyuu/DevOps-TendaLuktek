FROM mysql:8.0

# Set environment variables for the database configuration
ENV MYSQL_DATABASE=tienda_perritos
ENV MYSQL_ROOT_PASSWORD=admin123

# Copy the SQL initialization script to the directory executed at startup
COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306
