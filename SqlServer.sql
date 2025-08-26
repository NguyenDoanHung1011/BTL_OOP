CREATE TABLE [User] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [username] varchar(50) UNIQUE NOT NULL,
  [email] varchar(100) UNIQUE NOT NULL,
  [password] varchar(255) NOT NULL,
  [full_name] varchar(100),
  [phone] varchar(20),
  [address] text,
  [role_id] int NOT NULL,
  [created_at] datetime,
  [updated_at] datetime
)
GO

CREATE TABLE [Role] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [name] varchar(50) UNIQUE NOT NULL
)
GO

CREATE TABLE [Category] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [name] varchar(100) NOT NULL,
  [description] text
)
GO

CREATE TABLE [Brand] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [name] varchar(100) NOT NULL,
  [description] text
)
GO

CREATE TABLE [Product] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [name] varchar(150) NOT NULL,
  [description] text,
  [price] decimal(12,2) NOT NULL,
  [stock] int NOT NULL,
  [category_id] int NOT NULL,
  [brand_id] int NOT NULL,
  [created_at] datetime,
  [updated_at] datetime
)
GO

CREATE TABLE [ProductImage] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [product_id] int NOT NULL,
  [url] varchar(255) NOT NULL,
  [is_thumbnail] boolean DEFAULT (false),
  [created_at] datetime
)
GO

CREATE TABLE [Cart] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [user_id] int NOT NULL,
  [created_at] datetime
)
GO

CREATE TABLE [CartItem] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [cart_id] int NOT NULL,
  [product_id] int NOT NULL,
  [quantity] int NOT NULL DEFAULT (1)
)
GO

CREATE TABLE [Voucher] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [code] varchar(50) UNIQUE NOT NULL,
  [discount_percent] int,
  [start_date] datetime,
  [end_date] datetime,
  [min_order_value] decimal(12,2)
)
GO

CREATE TABLE [Order] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [user_id] int NOT NULL,
  [voucher_id] int,
  [total_amount] decimal(12,2) NOT NULL,
  [status] varchar(50) DEFAULT 'pending',
  [created_at] datetime,
  [updated_at] datetime
)
GO

CREATE TABLE [OrderItem] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [order_id] int NOT NULL,
  [product_id] int NOT NULL,
  [quantity] int NOT NULL,
  [price] decimal(12,2) NOT NULL
)
GO

CREATE TABLE [Bill] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [order_id] int NOT NULL,
  [employee_id] int NOT NULL,
  [payment_method] varchar(50) NOT NULL,
  [payment_status] varchar(50) DEFAULT 'unpaid',
  [issued_date] datetime,
  [paid_date] datetime
)
GO

CREATE TABLE [Blog] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [title] varchar(200) NOT NULL,
  [content] text NOT NULL,
  [image_url] varchar(255),
  [author_id] int NOT NULL,
  [created_at] datetime,
  [updated_at] datetime
)
GO

CREATE TABLE [Shift] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [employee_id] int NOT NULL,
  [start_time] datetime,
  [end_time] datetime,
  [total_revenue] decimal(12,2) DEFAULT (0),
  [total_bills] int DEFAULT (0),
  [status] varchar(50) DEFAULT 'scheduled',
  [assigned_by] int NOT NULL,
  [created_at] datetime,
  [updated_at] datetime
)
GO

CREATE TABLE [Salary] (
  [id] int PRIMARY KEY IDENTITY(1, 1),
  [employee_id] int NOT NULL,
  [shift_id] int NOT NULL,
  [base_salary] decimal(12,2) NOT NULL,
  [bonus] decimal(12,2) DEFAULT (0),
  [total_salary] decimal(12,2) NOT NULL,
  [paid_status] varchar(50) DEFAULT 'unpaid',
  [paid_date] datetime
)
GO

ALTER TABLE [User] ADD FOREIGN KEY ([role_id]) REFERENCES [Role] ([id])
GO

ALTER TABLE [Product] ADD FOREIGN KEY ([category_id]) REFERENCES [Category] ([id])
GO

ALTER TABLE [Product] ADD FOREIGN KEY ([brand_id]) REFERENCES [Brand] ([id])
GO

ALTER TABLE [ProductImage] ADD FOREIGN KEY ([product_id]) REFERENCES [Product] ([id])
GO

ALTER TABLE [Cart] ADD FOREIGN KEY ([user_id]) REFERENCES [User] ([id])
GO

ALTER TABLE [CartItem] ADD FOREIGN KEY ([cart_id]) REFERENCES [Cart] ([id])
GO

ALTER TABLE [CartItem] ADD FOREIGN KEY ([product_id]) REFERENCES [Product] ([id])
GO

ALTER TABLE [Order] ADD FOREIGN KEY ([user_id]) REFERENCES [User] ([id])
GO

ALTER TABLE [Order] ADD FOREIGN KEY ([voucher_id]) REFERENCES [Voucher] ([id])
GO

ALTER TABLE [OrderItem] ADD FOREIGN KEY ([order_id]) REFERENCES [Order] ([id])
GO

ALTER TABLE [OrderItem] ADD FOREIGN KEY ([product_id]) REFERENCES [Product] ([id])
GO

ALTER TABLE [Bill] ADD FOREIGN KEY ([order_id]) REFERENCES [Order] ([id])
GO

ALTER TABLE [Blog] ADD FOREIGN KEY ([author_id]) REFERENCES [User] ([id])
GO

ALTER TABLE [Bill] ADD FOREIGN KEY ([employee_id]) REFERENCES [User] ([id])
GO

ALTER TABLE [Shift] ADD FOREIGN KEY ([employee_id]) REFERENCES [User] ([id])
GO

ALTER TABLE [Shift] ADD FOREIGN KEY ([assigned_by]) REFERENCES [User] ([id])
GO

ALTER TABLE [Salary] ADD FOREIGN KEY ([employee_id]) REFERENCES [User] ([id])
GO

ALTER TABLE [Salary] ADD FOREIGN KEY ([shift_id]) REFERENCES [Shift] ([id])
GO
