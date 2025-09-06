-- Tạo cơ sở dữ liệu
CREATE DATABASE IF NOT EXISTS trendify;

-- Sử dụng cơ sở dữ liệu
USE trendify;

-- ========================
-- ROLE
-- ========================

CREATE TABLE Role (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL -- admin, employee, user
);

-- ========================
-- USER 
-- ========================

CREATE TABLE User (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    password VARCHAR(255),
    social_provider VARCHAR(50) DEFAULT NULL, -- google, facebook, github
    social_id VARCHAR(100),
    full_name VARCHAR(100) DEFAULT NULL,
    avatar_url VARCHAR(255) DEFAULT NULL,
    address TEXT DEFAULT NULL,
    total_points DECIMAL(10,2) DEFAULT 0, -- Added for loyalty points aggregation
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Role(id)
);

-- ========================
-- CATEGORY & PRODUCT
-- ========================

CREATE TABLE Category (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    total_sold BIGINT DEFAULT 0, -- Added for category sales aggregation
    deleted_at DATETIME DEFAULT NULL
);

CREATE TABLE Product (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(15,2) NOT NULL,
    stock INT DEFAULT 0,
    total_sold BIGINT DEFAULT 0, -- Added for product sales aggregation
    deleted_at DATETIME DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Category(id)
);

CREATE TABLE ProductVariant (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    color VARCHAR(50),
    size VARCHAR(20),
    stock INT DEFAULT 0,
    total_sold BIGINT DEFAULT 0, -- Added for variant sales aggregation
    FOREIGN KEY (product_id) REFERENCES Product(id)
);

CREATE TABLE ProductImage (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    url VARCHAR(255) NOT NULL,
    is_thumbnail INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES Product(id)
);

-- ========================
-- CART
-- ========================

CREATE TABLE Cart (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(id)
);

CREATE TABLE CartItem (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT NOT NULL,
    product_variant_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES Cart(id),
    FOREIGN KEY (product_variant_id) REFERENCES ProductVariant(id)
);

-- ========================
-- ORDER & ORDERITEM
-- ========================

CREATE TABLE `Order` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    payment_status VARCHAR(50), -- pending, paid, failed
    payment_method VARCHAR(50), -- cash, qr_banking
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    confirmed_by INT,
    FOREIGN KEY (user_id) REFERENCES User(id),
    FOREIGN KEY (confirmed_by) REFERENCES User(id)
);

CREATE TABLE OrderItem (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_variant_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `Order`(id),
    FOREIGN KEY (product_variant_id) REFERENCES ProductVariant(id)
);

-- ========================
-- BILL & BILLITEM
-- ========================

CREATE TABLE Bill (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cashier_id INT NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cashier_id) REFERENCES User(id)
);

CREATE TABLE BillItem (
    id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT NOT NULL,
    product_variant_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (bill_id) REFERENCES Bill(id),
    FOREIGN KEY (product_variant_id) REFERENCES ProductVariant(id)
);

-- ========================
-- COUPON
-- ========================

CREATE TABLE Coupon (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type VARCHAR(50), -- percent, fixed
    discount_value DECIMAL(10,2) NOT NULL,
    start_date DATE,
    end_date DATE,
    usage_limit INT DEFAULT 1,
    used_count INT DEFAULT 0,
    product_id INT DEFAULT NULL, -- NULL → toàn bill, NOT NULL → áp dụng cho sản phẩm
    FOREIGN KEY (product_id) REFERENCES Product(id)
);

-- ========================
-- FEED 
-- ========================

CREATE TABLE Feed (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    thumbnail VARCHAR(255) DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ========================
-- SHIFT
-- ========================

CREATE TABLE Shift (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);

CREATE TABLE ShiftSchedule (
    id INT PRIMARY KEY AUTO_INCREMENT,
    shift_id INT NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (shift_id) REFERENCES Shift(id)
);

CREATE TABLE ShiftAssignment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    schedule_id INT NOT NULL,
    employee_id INT NOT NULL,
    assigned_by INT NOT NULL,
    FOREIGN KEY (schedule_id) REFERENCES ShiftSchedule(id),
    FOREIGN KEY (employee_id) REFERENCES User(id),
    FOREIGN KEY (assigned_by) REFERENCES User(id)
);

CREATE TABLE ShiftAttendance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    assignment_id INT NOT NULL,
    check_in DATETIME,
    check_out DATETIME,
    FOREIGN KEY (assignment_id) REFERENCES ShiftAssignment(id)
);

CREATE TABLE ShiftReport (
    id INT PRIMARY KEY AUTO_INCREMENT,
    schedule_id INT NOT NULL,
    total_bills INT DEFAULT 0,
    total_orders INT DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0,
    FOREIGN KEY (schedule_id) REFERENCES ShiftSchedule(id)
);

CREATE TABLE ShiftEmployeeReport (
    id INT PRIMARY KEY AUTO_INCREMENT,
    assignment_id INT NOT NULL,
    bills_handled INT DEFAULT 0,
    revenue DECIMAL(15,2) DEFAULT 0,
    FOREIGN KEY (assignment_id) REFERENCES ShiftAssignment(id)
);

-- ========================
-- RETURN
-- ========================

CREATE TABLE ReturnRequest (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    bill_id INT,
    user_id INT NOT NULL,
    status VARCHAR(50),
    reason TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    approved_by INT,
    FOREIGN KEY (order_id) REFERENCES `Order`(id),
    FOREIGN KEY (bill_id) REFERENCES Bill(id),
    FOREIGN KEY (user_id) REFERENCES User(id),
    FOREIGN KEY (approved_by) REFERENCES User(id)
);

CREATE TABLE ReturnItem (
    id INT PRIMARY KEY AUTO_INCREMENT,
    request_id INT NOT NULL,
    product_variant_id INT NOT NULL,
    quantity INT NOT NULL,
    refund_amount DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (request_id) REFERENCES ReturnRequest(id),
    FOREIGN KEY (product_variant_id) REFERENCES ProductVariant(id)
);

-- ========================
-- PAYMENT
-- ========================

CREATE TABLE Payment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    bill_id INT,
    amount DECIMAL(15,2) NOT NULL,
    method VARCHAR(50),
    status VARCHAR(50),
    transaction_ref VARCHAR(100),
    payment_proof VARCHAR(255) DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES `Order`(id),
    FOREIGN KEY (bill_id) REFERENCES Bill(id)
);

-- ========================
-- ROYALTY POINTS
-- ========================

CREATE TABLE RoyaltyPoints (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_id INT,
    bill_id INT,
    points DECIMAL(10,2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(id),
    FOREIGN KEY (order_id) REFERENCES `Order`(id),
    FOREIGN KEY (bill_id) REFERENCES Bill(id)
);

-- ========================
-- PRODUCT REVIEW
-- ========================

CREATE TABLE ProductReview (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_item_id) REFERENCES OrderItem(id)
);

-- ========================
-- REVENUE SUMMARY 
-- ========================

CREATE TABLE RevenueSummary (
    id INT PRIMARY KEY AUTO_INCREMENT,
    period_type VARCHAR(20), -- day, week, month, year
    period_value VARCHAR(20), -- e.g., '2025-09' for month, '2025-36' for week
    total_revenue DECIMAL(15,2) DEFAULT 0,
    total_bills INT DEFAULT 0,
    total_orders INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (period_type, period_value)
);

-- ========================
-- INDEXES
-- ========================

CREATE INDEX idx_orderitem_product_variant ON OrderItem(product_variant_id, order_id);
CREATE INDEX idx_billitem_product_variant ON BillItem(product_variant_id, bill_id);
CREATE INDEX idx_royaltypoints_user ON RoyaltyPoints(user_id);
CREATE INDEX idx_bill_created_at ON Bill(created_at);
CREATE INDEX idx_order_created_at ON `Order`(created_at);
CREATE INDEX idx_revenue_summary_period ON RevenueSummary(period_type, period_value);

-- ========================
-- TRIGGERS
-- ========================

-- Trigger to update total_sold for Product, ProductVariant, and Category on OrderItem insert
DELIMITER //
CREATE TRIGGER update_product_sold_orderitem
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
    UPDATE ProductVariant SET total_sold = total_sold + NEW.quantity WHERE id = NEW.product_variant_id;
    UPDATE Product p
    JOIN ProductVariant pv ON p.id = pv.product_id
    SET p.total_sold = p.total_sold + NEW.quantity
    WHERE pv.id = NEW.product_variant_id;
    UPDATE Category c
    JOIN Product p ON c.id = p.category_id
    JOIN ProductVariant pv ON p.id = pv.product_id
    SET c.total_sold = c.total_sold + NEW.quantity
    WHERE pv.id = NEW.product_variant_id;
END //
DELIMITER ;

-- Trigger to update total_sold for Product, ProductVariant, and Category on BillItem insert
DELIMITER //
CREATE TRIGGER update_product_sold_billitem
AFTER INSERT ON BillItem
FOR EACH ROW
BEGIN
    UPDATE ProductVariant SET total_sold = total_sold + NEW.quantity WHERE id = NEW.product_variant_id;
    UPDATE Product p
    JOIN ProductVariant pv ON p.id = pv.product_id
    SET p.total_sold = p.total_sold + NEW.quantity
    WHERE pv.id = NEW.product_variant_id;
    UPDATE Category c
    JOIN Product p ON c.id = p.category_id
    JOIN ProductVariant pv ON p.id = pv.product_id
    SET c.total_sold = c.total_sold + NEW.quantity
    WHERE pv.id = NEW.product_variant_id;
END //
DELIMITER ;

-- Trigger to update total_points for User on RoyaltyPoints insert
DELIMITER //
CREATE TRIGGER update_user_points
AFTER INSERT ON RoyaltyPoints
FOR EACH ROW
BEGIN
    UPDATE User SET total_points = total_points + NEW.points WHERE id = NEW.user_id;
END //
DELIMITER ;

-- Trigger to update RevenueSummary on Bill insert
DELIMITER //
CREATE TRIGGER update_revenue_summary_bill
AFTER INSERT ON Bill
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'paid' THEN
        INSERT INTO RevenueSummary (period_type, period_value, total_revenue, total_bills, created_at)
        VALUES 
            ('month', DATE_FORMAT(NEW.created_at, '%Y-%m'), NEW.total, 1, NOW()),
            ('week', DATE_FORMAT(NEW.created_at, '%Y-%U'), NEW.total, 1, NOW()),
            ('year', DATE_FORMAT(NEW.created_at, '%Y'), NEW.total, 1, NOW())
        ON DUPLICATE KEY UPDATE
            total_revenue = total_revenue + NEW.total,
            total_bills = total_bills + 1;
    END IF;
END //
DELIMITER ;

-- Trigger to update RevenueSummary on Order insert
DELIMITER //
CREATE TRIGGER update_revenue_summary_order
AFTER INSERT ON `Order`
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'paid' THEN
        INSERT INTO RevenueSummary (period_type, period_value, total_revenue, total_orders, created_at)
        VALUES 
            ('month', DATE_FORMAT(NEW.created_at, '%Y-%m'), NEW.total, 1, NOW()),
            ('week', DATE_FORMAT(NEW.created_at, '%Y-%U'), NEW.total, 1, NOW()),
            ('year', DATE_FORMAT(NEW.created_at, '%Y'), NEW.total, 1, NOW())
        ON DUPLICATE KEY UPDATE
            total_revenue = total_revenue + NEW.total,
            total_orders = total_orders + 1;
    END IF;
END //
DELIMITER ;