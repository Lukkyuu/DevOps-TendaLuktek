CREATE DATABASE IF NOT EXISTS tienda_luktek;
USE tienda_luktek;

-- Table structure for productos
CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    precio INT NOT NULL,
    descripcion TEXT
);

-- Insert sample records
INSERT INTO productos (nombre, precio, descripcion) VALUES
('Alimento Premium Perro Adulto (15kg)', 45990, 'Alimento balanceado premium para perros adultos.'),
('Alimento Cachorro Raza Pequeña (3kg)', 18990, 'Nutrición especializada para el crecimiento óptimo de cachorros.'),
('Juguete Hueso Dental Interactivo', 5990, 'Hueso de goma ultra resistente que ayuda a limpiar los dientes.'),
('Cama Ortopédica Memory Foam (Grande)', 32990, 'Máximo confort para el descanso de tu mascota.'),
('Collar Reflectante Ajustable Rojo', 4990, 'Collar de alta visibilidad para paseos nocturnos seguros.'),
('Arnés Ergonómico Antitirones', 15990, 'Arnés de alta calidad para un control cómodo durante el paseo.');
