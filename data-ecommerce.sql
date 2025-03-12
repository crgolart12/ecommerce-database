-- Criação do Banco de Dados
CREATE DATABASE ecommerce;
USE ecommerce;

-- Tabelas
CREATE TABLE Client (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('PJ', 'PF') NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Client_PJ (
    client_id INT PRIMARY KEY,
    CNPJ VARCHAR(20) NOT NULL UNIQUE,
    company_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (client_id) REFERENCES Client(client_id)
);

CREATE TABLE Client_PF (
    client_id INT PRIMARY KEY,
    CPF VARCHAR(14) NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    FOREIGN KEY (client_id) REFERENCES Client(client_id)
);

CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    payment_type VARCHAR(50) NOT NULL,
    card_number VARCHAR(20),
    payment_alias VARCHAR(100),
    FOREIGN KEY (client_id) REFERENCES Client(client_id)
);

CREATE TABLE `Order` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (client_id) REFERENCES Client(client_id)
);

CREATE TABLE Delivery (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status VARCHAR(50),
    tracking_code VARCHAR(100) UNIQUE,
    estimated_date DATE,
    delivered_date DATE,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id)
);

CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100)
);

CREATE TABLE Supplier (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    CNPJ VARCHAR(20) NOT NULL UNIQUE,
    supplier_name VARCHAR(255) NOT NULL,
    contact VARCHAR(255)
);

CREATE TABLE ProductSupplier (
    product_id INT,
    supplier_id INT,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

CREATE TABLE Seller (
    seller_id INT AUTO_INCREMENT PRIMARY KEY,
    identification VARCHAR(20) NOT NULL UNIQUE,
    seller_name VARCHAR(255) NOT NULL,
    contact VARCHAR(255),
    type ENUM('PJ', 'PF')
);

CREATE TABLE ProductSeller (
    seller_id INT,
    product_id INT,
    quantity INT DEFAULT 0,
    PRIMARY KEY (seller_id, product_id),
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE OrderItem (
    order_id INT,
    product_id INT,
    quantity INT,
    price_at_order DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    location VARCHAR(255),
    quantity INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Inserção de Dados de Exemplo
INSERT INTO Client (type) VALUES ('PJ'), ('PF');

INSERT INTO Client_PJ (client_id, CNPJ, company_name) VALUES
(1, '12345678901234', 'Empresa Tech LTDA');

INSERT INTO Client_PF (client_id, CPF, first_name, last_name) VALUES
(2, '98765432109', 'João', 'Silva');

INSERT INTO Payment (client_id, payment_type, card_number) VALUES
(1, 'Cartão Crédito', '1234-5678-9012-3456'),
(2, 'Boleto', NULL);

INSERT INTO Product (name, price, category) VALUES
('Notebook', 3500.00, 'Eletrônicos'),
('Smartphone', 2000.00, 'Eletrônicos');

INSERT INTO Supplier (CNPJ, supplier_name, contact) VALUES
('11222333444455', 'Fornecedor Geral', 'contato@fornecedor.com');

INSERT INTO ProductSupplier (product_id, supplier_id) VALUES
(1, 1), (2, 1);

INSERT INTO Seller (identification, seller_name, type, contact) VALUES
('99888777666655', 'Loja Eletro', 'PJ', 'vendas@eletro.com'),
('12345678901', 'Vendedor Autônomo', 'PF', 'vendedor@email.com');

INSERT INTO ProductSeller (seller_id, product_id, quantity) VALUES
(1, 1, 5), (2, 2, 10);

INSERT INTO `Order` (client_id, status, total_amount) VALUES
(1, 'Processando', 3500.00),
(2, 'Entregue', 2000.00);

INSERT INTO OrderItem (order_id, product_id, quantity, price_at_order) VALUES
(1, 1, 1, 3500.00),
(2, 2, 1, 2000.00);

INSERT INTO Delivery (order_id, status, tracking_code) VALUES
(1, 'Em trânsito', 'BR123456789'),
(2, 'Entregue', 'BR987654321');

-- Queries Exemplo

-- Quantidade de Pedidos por Cliente
SELECT 
    c.client_id,
    COALESCE(pj.company_name, CONCAT(pf.first_name, ' ', pf.last_name)) AS cliente,
    COUNT(o.order_id) AS total_pedidos
FROM Client c
LEFT JOIN Client_PJ pj ON c.client_id = pj.client_id
LEFT JOIN Client_PF pf ON c.client_id = pf.client_id
LEFT JOIN `Order` o ON c.client_id = o.client_id
GROUP BY c.client_id;

-- Verificar se algum vendedor é também fornecedor
SELECT s.seller_id, s.seller_name, sup.supplier_name
FROM Seller s
INNER JOIN Supplier sup ON s.identification = sup.CNPJ;

-- Relação de produtos, fornecedores e estoque
SELECT 
    p.name AS produto,
    sup.supplier_name AS fornecedor,
    inv.quantity AS estoque
FROM Product p
JOIN ProductSupplier ps ON p.product_id = ps.product_id
JOIN Supplier sup ON ps.supplier_id = sup.supplier_id
JOIN Inventory inv ON p.product_id = inv.product_id;

-- Pedidos com entrega pendente
SELECT 
    o.order_id,
    d.tracking_code,
    d.status AS status_entrega
FROM `Order` o
JOIN Delivery d ON o.order_id = d.order_id
WHERE d.status != 'Entregue';