-- database/migrations/01_initial_schema.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    role VARCHAR(50) DEFAULT 'user'
);

-- User Profiles Table
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    credit_score INTEGER,
    credit_score_updated_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Accounts Table (Bank accounts, credit cards, etc.)
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL, -- checking, savings, credit, loan, etc.
    balance DECIMAL(15,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'GBP',
    institution VARCHAR(100),
    account_number VARCHAR(100),
    interest_rate DECIMAL(5,2),
    credit_limit DECIMAL(15,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Debts Table
CREATE TABLE debts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounts(id),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL, -- credit card, loan, mortgage, etc.
    original_amount DECIMAL(15,2) NOT NULL,
    current_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2),
    minimum_payment DECIMAL(15,2),
    due_date INTEGER, -- Day of month
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Transactions Table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounts(id),
    category_id UUID,
    amount DECIMAL(15,2) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- income, expense, transfer
    description TEXT,
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL, -- income, expense
    parent_id UUID REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Update the transactions table to reference categories
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_category
    FOREIGN KEY (category_id) REFERENCES categories(id);

-- Bills Table
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id),
    name VARCHAR(100) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    frequency VARCHAR(50) NOT NULL, -- monthly, quarterly, annually
    due_day INTEGER, -- Day of month/quarter/year
    auto_payment BOOLEAN DEFAULT FALSE,
    reminder_days INTEGER, -- Days before due to remind
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Companies Table
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    company_number VARCHAR(50),
    company_type VARCHAR(50), -- ltd, cic, etc.
    incorporation_date DATE,
    fiscal_year_end DATE,
    vat_number VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tax Obligations Table
CREATE TABLE tax_obligations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    tax_type VARCHAR(50) NOT NULL, -- corporation tax, VAT, PAYE, etc.
    due_date DATE NOT NULL,
    amount DECIMAL(15,2),
    status VARCHAR(50) DEFAULT 'pending', -- pending, paid, overdue
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Investments Table
CREATE TABLE investments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- stock, bond, fund, etc.
    symbol VARCHAR(20),
    purchase_price DECIMAL(15,2) NOT NULL,
    current_price DECIMAL(15,2) NOT NULL,
    quantity DECIMAL(15,6) NOT NULL,
    purchase_date DATE NOT NULL,
    platform VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Financial Goals Table
CREATE TABLE financial_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    target_amount DECIMAL(15,2) NOT NULL,
    current_amount DECIMAL(15,2) DEFAULT 0,
    target_date DATE,
    priority INTEGER,
    status VARCHAR(50) DEFAULT 'active', -- active, achieved, abandoned
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Default Categories
INSERT INTO categories (id, user_id, name, type, parent_id) VALUES
(uuid_generate_v4(), NULL, 'Income', 'income', NULL),
(uuid_generate_v4(), NULL, 'Expense', 'expense', NULL);

-- Add system default subcategories for income
INSERT INTO categories (id, user_id, name, type, parent_id)
SELECT uuid_generate_v4(), NULL, 'Salary', 'income', id FROM categories WHERE name = 'Income' AND user_id IS NULL;

INSERT INTO categories (id, user_id, name, type, parent_id)
SELECT uuid_generate_v4(), NULL, 'Benefits', 'income', id FROM categories WHERE name = 'Income' AND user_id IS NULL;

-- Add system default subcategories for expenses
INSERT INTO categories (id, user_id, name, type, parent_id)
SELECT uuid_generate_v4(), NULL, 'Housing', 'expense', id FROM categories WHERE name = 'Expense' AND user_id IS NULL;

INSERT INTO categories (id, user_id, name, type, parent_id)
SELECT uuid_generate_v4(), NULL, 'Utilities', 'expense', id FROM categories WHERE name = 'Expense' AND user_id IS NULL;

INSERT INTO categories (id, user_id, name, type, parent_id)
SELECT uuid_generate_v4(), NULL, 'Food', 'expense', id FROM categories WHERE name = 'Expense' AND user_id IS NULL;

INSERT INTO categories (id, user_id, name, type, parent_id)
SELECT uuid_generate_v4(), NULL, 'Transportation', 'expense', id FROM categories WHERE name = 'Expense' AND user_id IS NULL;

INSERT INTO categories (id, user_id, name, type, parent_id)
SELECT uuid_generate_v4(), NULL, 'Entertainment', 'expense', id FROM categories WHERE name = 'Expense' AND user_id IS NULL;

INSERT INTO categories (id, user_id, name, type, parent_id)
SELECT uuid_generate_v4(), NULL, 'Subscriptions', 'expense', id FROM categories WHERE name = 'Expense' AND user_id IS NULL;