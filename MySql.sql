CREATE TABLE `User` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `username` varchar(50) UNIQUE NOT NULL,
  `email` varchar(100) UNIQUE NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100),
  `phone` varchar(20),
  `address` text,
  `role_id` int NOT NULL,
  `created_at` datetime,
  `updated_at` datetime
);

CREATE TABLE `Role` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(50) UNIQUE NOT NULL
);

CREATE TABLE `Category` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text
);

CREATE TABLE `Brand` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text
);

CREATE TABLE `Product` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `description` text,
  `price` decimal(12,2) NOT NULL,
  `stock` int NOT NULL,
  `category_id` int NOT NULL,
  `brand_id` int NOT NULL,
  `created_at` datetime,
  `updated_at` datetime
);

CREATE TABLE `ProductImage` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `url` varchar(255) NOT NULL,
  `is_thumbnail` boolean DEFAULT false,
  `created_at` datetime
);

CREATE TABLE `Cart` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `created_at` datetime
);

CREATE TABLE `CartItem` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `cart_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT 1
);

CREATE TABLE `Voucher` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `code` varchar(50) UNIQUE NOT NULL,
  `discount_percent` int,
  `start_date` datetime,
  `end_date` datetime,
  `min_order_value` decimal(12,2)
);

CREATE TABLE `Order` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `voucher_id` int,
  `total_amount` decimal(12,2) NOT NULL,
  `status` varchar(50) DEFAULT 'pending',
  `created_at` datetime,
  `updated_at` datetime
);

CREATE TABLE `OrderItem` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(12,2) NOT NULL
);

CREATE TABLE `Bill` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `payment_status` varchar(50) DEFAULT 'unpaid',
  `issued_date` datetime,
  `paid_date` datetime
);

CREATE TABLE `Blog` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(255),
  `author_id` int NOT NULL,
  `created_at` datetime,
  `updated_at` datetime
);

CREATE TABLE `Shift` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `start_time` datetime,
  `end_time` datetime,
  `total_revenue` decimal(12,2) DEFAULT 0,
  `total_bills` int DEFAULT 0,
  `status` varchar(50) DEFAULT 'scheduled',
  `assigned_by` int NOT NULL,
  `created_at` datetime,
  `updated_at` datetime
);

CREATE TABLE `Salary` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `employee_id` int NOT NULL,
  `shift_id` int NOT NULL,
  `base_salary` decimal(12,2) NOT NULL,
  `bonus` decimal(12,2) DEFAULT 0,
  `total_salary` decimal(12,2) NOT NULL,
  `paid_status` varchar(50) DEFAULT 'unpaid',
  `paid_date` datetime
);

ALTER TABLE `User` ADD FOREIGN KEY (`role_id`) REFERENCES `Role` (`id`);

ALTER TABLE `Product` ADD FOREIGN KEY (`category_id`) REFERENCES `Category` (`id`);

ALTER TABLE `Product` ADD FOREIGN KEY (`brand_id`) REFERENCES `Brand` (`id`);

ALTER TABLE `ProductImage` ADD FOREIGN KEY (`product_id`) REFERENCES `Product` (`id`);

ALTER TABLE `Cart` ADD FOREIGN KEY (`user_id`) REFERENCES `User` (`id`);

ALTER TABLE `CartItem` ADD FOREIGN KEY (`cart_id`) REFERENCES `Cart` (`id`);

ALTER TABLE `CartItem` ADD FOREIGN KEY (`product_id`) REFERENCES `Product` (`id`);

ALTER TABLE `Order` ADD FOREIGN KEY (`user_id`) REFERENCES `User` (`id`);

ALTER TABLE `Order` ADD FOREIGN KEY (`voucher_id`) REFERENCES `Voucher` (`id`);

ALTER TABLE `OrderItem` ADD FOREIGN KEY (`order_id`) REFERENCES `Order` (`id`);

ALTER TABLE `OrderItem` ADD FOREIGN KEY (`product_id`) REFERENCES `Product` (`id`);

ALTER TABLE `Bill` ADD FOREIGN KEY (`order_id`) REFERENCES `Order` (`id`);

ALTER TABLE `Blog` ADD FOREIGN KEY (`author_id`) REFERENCES `User` (`id`);

ALTER TABLE `Bill` ADD FOREIGN KEY (`employee_id`) REFERENCES `User` (`id`);

ALTER TABLE `Shift` ADD FOREIGN KEY (`employee_id`) REFERENCES `User` (`id`);

ALTER TABLE `Shift` ADD FOREIGN KEY (`assigned_by`) REFERENCES `User` (`id`);

ALTER TABLE `Salary` ADD FOREIGN KEY (`employee_id`) REFERENCES `User` (`id`);

ALTER TABLE `Salary` ADD FOREIGN KEY (`shift_id`) REFERENCES `Shift` (`id`);
