create database nexuspay;
 
 
 use nexuspay;


CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    address TEXT not null,
    login_pin_hash VARCHAR(255) NOT NULL,
    transaction_pin_hash VARCHAR(255) NOT NULL,
    account_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    kyc_status ENUM('verified', 'pending', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE Wallets (
	user_wallet_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    balance DECIMAL(12,2) DEFAULT 0.00,
    upi_handle VARCHAR(50) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


CREATE TABLE BankAccounts (
    bank_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    bank_name VARCHAR(100),
    account_number VARCHAR(30),
    ifsc_code VARCHAR(15),
    is_primary BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Merchants (
    merchant_id INT PRIMARY KEY AUTO_INCREMENT,
    merchant_name VARCHAR(100),
    category VARCHAR(50),
    user_id int not null,
    foreign key (user_id) references users (user_id)
);



-- (CORE TABLE)
CREATE TABLE Transactions (
    txn_id INT PRIMARY KEY AUTO_INCREMENT,
    txn_ref VARCHAR(50) UNIQUE NOT NULL,
    txn_type ENUM('send', 'request', 'bill_pay', 'cashback') NOT NULL,

    amount DECIMAL(12,2) NOT NULL,
    fee DECIMAL(8,2) DEFAULT 0.00,
    net_amount DECIMAL(12,2) GENERATED ALWAYS AS (amount - fee) STORED,

    status ENUM('processing', 'success', 'failed') DEFAULT 'processing',

    user_wallet_id INT,
    bank_id INT,
    merchant_id INT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_wallet_id) REFERENCES Wallets(user_wallet_id),
    FOREIGN KEY (bank_id) REFERENCES BankAccounts(bank_id),
    FOREIGN KEY (merchant_id) REFERENCES Merchants(merchant_id)
);

CREATE TABLE TransactionHistory (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    txn_id INT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    action_type VARCHAR(50),
    performed_by VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (txn_id) REFERENCES Transactions(txn_id)
);

CREATE TABLE FraudDetection (
    fraud_id INT PRIMARY KEY AUTO_INCREMENT,
    txn_id INT NOT NULL,
    user_id INT,

    rule_name VARCHAR(100),
    rule_type ENUM('amount', 'velocity', 'location', 'device'),
    threshold_value DECIMAL(12,2),

    risk_score INT,
    action_taken ENUM('flag', 'block', 'verify'),
    fraud_status ENUM('flagged', 'confirmed', 'cleared') DEFAULT 'flagged',

    ip_address VARCHAR(45),
    device_id VARCHAR(50),
    location VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (txn_id) REFERENCES Transactions(txn_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Services (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    service_type ENUM('coupon', 'discount', 'loan', 'cashback', 'autopay'),
    service_name VARCHAR(100),

    -- Coupon / Discount
    coupon_code VARCHAR(50),
    discount_percent DECIMAL(5,2),

    -- Cashback
    cashback_amount DECIMAL(10,2),

    -- Loan
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),

    -- Autopay (merged here)
    merchant_id INT,
    autopay_amount DECIMAL(10,2),
    frequency ENUM('weekly', 'monthly'),
    next_due_date DATE,
    validity_end DATE,
    status ENUM('active', 'used', 'expired', 'paused') DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bank_id int not null ,

    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (merchant_id) REFERENCES Merchants(merchant_id),
    foreign key (bank_id) references bankaccounts (bank_id)
);




CREATE TABLE SupportTickets__Reviews (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    txn_id INT,

    issue_type VARCHAR(50),
    description TEXT,

    status ENUM('open', 'in_progress', 'resolved') DEFAULT 'open',

    --  Review fields added
    rating INT CHECK (rating BETWEEN 1 AND 5),
    feedback_text TEXT,
    review_type ENUM('support', 'transaction', 'app'),
    reviewed_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,

    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (txn_id) REFERENCES Transactions(txn_id)
);




USE nexuspay;

-- ============================================================
-- 1. USERS (50 records)
-- ============================================================
INSERT INTO Users (full_name, phone, email, address, login_pin_hash, transaction_pin_hash, account_status, kyc_status) VALUES
('Arjun Sharma',     '9876543201', 'arjun.sharma@gmail.com',     '12 MG Road, Mumbai',            '$2b$10$loginA1', '$2b$10$txnA1', 'active',    'verified'),
('Priya Verma',      '9876543202', 'priya.verma@gmail.com',      '45 Andheri West, Mumbai',       '$2b$10$loginA2', '$2b$10$txnA2', 'active',    'verified'),
('Rohit Nair',       '9876543203', 'rohit.nair@yahoo.com',       '7 Bandra East, Mumbai',         '$2b$10$loginA3', '$2b$10$txnA3', 'active',    'pending'),
('Sneha Patel',      '9876543204', 'sneha.patel@hotmail.com',    '22 Powai, Mumbai',              '$2b$10$loginA4', '$2b$10$txnA4', 'active',    'verified'),
('Karan Mehta',      '9876543205', 'karan.mehta@gmail.com',      '88 Juhu, Mumbai',               '$2b$10$loginA5', '$2b$10$txnA5', 'suspended', 'rejected'),
('Divya Iyer',       '9876543206', 'divya.iyer@gmail.com',       '3 Dadar, Mumbai',               '$2b$10$loginA6', '$2b$10$txnA6', 'active',    'verified'),
('Amit Desai',       '9876543207', 'amit.desai@gmail.com',       '61 Thane West, Thane',          '$2b$10$loginA7', '$2b$10$txnA7', 'active',    'pending'),
('Neha Joshi',       '9876543208', 'neha.joshi@gmail.com',       '14 Kalyan, Thane',              '$2b$10$loginA8', '$2b$10$txnA8', 'active',    'verified'),
('Vikram Singh',     '9876543209', 'vikram.singh@outlook.com',   '9 Worli, Mumbai',               '$2b$10$loginA9', '$2b$10$txnA9', 'inactive',  'pending'),
('Pooja Rao',        '9876543210', 'pooja.rao@gmail.com',        '55 Vile Parle, Mumbai',         '$2b$10$loginB1', '$2b$10$txnB1', 'active',    'verified'),
('Suresh Kumar',     '9876543211', 'suresh.kumar@gmail.com',     '77 Goregaon, Mumbai',           '$2b$10$loginB2', '$2b$10$txnB2', 'active',    'verified'),
('Meena Pillai',     '9876543212', 'meena.pillai@gmail.com',     '30 Colaba, Mumbai',             '$2b$10$loginB3', '$2b$10$txnB3', 'active',    'verified'),
('Ravi Gupta',       '9876543213', 'ravi.gupta@rediffmail.com',  '18 Santacruz, Mumbai',          '$2b$10$loginB4', '$2b$10$txnB4', 'active',    'pending'),
('Anita Mishra',     '9876543214', 'anita.mishra@gmail.com',     '5 Chembur, Mumbai',             '$2b$10$loginB5', '$2b$10$txnB5', 'active',    'verified'),
('Deepak Trivedi',   '9876543215', 'deepak.trivedi@yahoo.com',   '11 Kandivali, Mumbai',          '$2b$10$loginB6', '$2b$10$txnB6', 'inactive',  'pending'),
('Kavita Reddy',     '9876543216', 'kavita.reddy@gmail.com',     '66 Malad, Mumbai',              '$2b$10$loginB7', '$2b$10$txnB7', 'active',    'verified'),
('Nitin Bhatt',      '9876543217', 'nitin.bhatt@gmail.com',      '24 Borivali, Mumbai',           '$2b$10$loginB8', '$2b$10$txnB8', 'active',    'verified'),
('Swati Kulkarni',   '9876543218', 'swati.kulkarni@gmail.com',   '8 Ghatkopar, Mumbai',           '$2b$10$loginB9', '$2b$10$txnB9', 'active',    'verified'),
('Harsh Agarwal',    '9876543219', 'harsh.agarwal@gmail.com',    '43 Mulund, Mumbai',             '$2b$10$loginC1', '$2b$10$txnC1', 'active',    'pending'),
('Sonal Shah',       '9876543220', 'sonal.shah@gmail.com',       '19 Vikhroli, Mumbai',           '$2b$10$loginC2', '$2b$10$txnC2', 'active',    'verified'),
('Manish Pandey',    '9876543221', 'manish.pandey@gmail.com',    '37 Bhayander, Thane',           '$2b$10$loginC3', '$2b$10$txnC3', 'active',    'verified'),
('Rekha Nambiar',    '9876543222', 'rekha.nambiar@yahoo.com',    '50 Mira Road, Thane',           '$2b$10$loginC4', '$2b$10$txnC4', 'active',    'verified'),
('Anil Tiwari',      '9876543223', 'anil.tiwari@gmail.com',      '2 Vasai, Palghar',              '$2b$10$loginC5', '$2b$10$txnC5', 'suspended', 'rejected'),
('Priyanka Jain',    '9876543224', 'priyanka.jain@gmail.com',    '15 Virar, Palghar',             '$2b$10$loginC6', '$2b$10$txnC6', 'active',    'verified'),
('Sunil Yadav',      '9876543225', 'sunil.yadav@gmail.com',      '29 Nalasopara, Palghar',        '$2b$10$loginC7', '$2b$10$txnC7', 'active',    'pending'),
('Archana Bhosle',   '9876543226', 'archana.bhosle@gmail.com',   '6 Palghar, Palghar',            '$2b$10$loginC8', '$2b$10$txnC8', 'active',    'verified'),
('Tushar More',      '9876543227', 'tushar.more@gmail.com',      '33 Pune West, Pune',            '$2b$10$loginC9', '$2b$10$txnC9', 'active',    'verified'),
('Lalita Deshpande', '9876543228', 'lalita.deshpande@gmail.com', '48 Kothrud, Pune',              '$2b$10$loginD1', '$2b$10$txnD1', 'active',    'verified'),
('Ganesh Bhat',      '9876543229', 'ganesh.bhat@gmail.com',      '10 Hadapsar, Pune',             '$2b$10$loginD2', '$2b$10$txnD2', 'active',    'pending'),
('Namrata Sawant',   '9876543230', 'namrata.sawant@gmail.com',   '25 Wakad, Pune',                '$2b$10$loginD3', '$2b$10$txnD3', 'active',    'verified'),
('Rajesh Patil',     '9876543231', 'rajesh.patil@gmail.com',     '39 Hinjawadi, Pune',            '$2b$10$loginD4', '$2b$10$txnD4', 'active',    'verified'),
('Usha Naik',        '9876543232', 'usha.naik@gmail.com',        '17 Aundh, Pune',                '$2b$10$loginD5', '$2b$10$txnD5', 'inactive',  'pending'),
('Prasad Limaye',    '9876543233', 'prasad.limaye@gmail.com',    '53 Baner, Pune',                '$2b$10$loginD6', '$2b$10$txnD6', 'active',    'verified'),
('Geeta Chavan',     '9876543234', 'geeta.chavan@gmail.com',     '4 Shivaji Nagar, Pune',         '$2b$10$loginD7', '$2b$10$txnD7', 'active',    'verified'),
('Vinod Kamat',      '9876543235', 'vinod.kamat@gmail.com',      '21 Camp, Pune',                 '$2b$10$loginD8', '$2b$10$txnD8', 'active',    'verified'),
('Shweta Barve',     '9876543236', 'shweta.barve@gmail.com',     '60 Koregaon Park, Pune',        '$2b$10$loginD9', '$2b$10$txnD9', 'active',    'pending'),
('Omkar Ghosh',      '9876543237', 'omkar.ghosh@gmail.com',      '32 Salt Lake, Kolkata',         '$2b$10$loginE1', '$2b$10$txnE1', 'active',    'verified'),
('Tanuja Sen',       '9876543238', 'tanuja.sen@gmail.com',        '47 Park Street, Kolkata',       '$2b$10$loginE2', '$2b$10$txnE2', 'active',    'verified'),
('Bhaskar Das',      '9876543239', 'bhaskar.das@yahoo.com',      '13 Howrah, Kolkata',            '$2b$10$loginE3', '$2b$10$txnE3', 'active',    'pending'),
('Puja Chatterjee',  '9876543240', 'puja.chatterjee@gmail.com',  '28 Alipore, Kolkata',           '$2b$10$loginE4', '$2b$10$txnE4', 'active',    'verified'),
('Siddharth Roy',    '9876543241', 'siddharth.roy@gmail.com',    '9 Behala, Kolkata',             '$2b$10$loginE5', '$2b$10$txnE5', 'active',    'verified'),
('Monika Banerjee',  '9876543242', 'monika.banerjee@gmail.com',  '41 Dumdum, Kolkata',            '$2b$10$loginE6', '$2b$10$txnE6', 'active',    'verified'),
('Aakash Verma',     '9876543243', 'aakash.verma@gmail.com',     '16 Connaught Place, Delhi',     '$2b$10$loginE7', '$2b$10$txnE7', 'active',    'pending'),
('Sunita Khanna',    '9876543244', 'sunita.khanna@gmail.com',    '34 Karol Bagh, Delhi',          '$2b$10$loginE8', '$2b$10$txnE8', 'active',    'verified'),
('Devendra Malik',   '9876543245', 'devendra.malik@gmail.com',   '58 Dwarka, Delhi',              '$2b$10$loginE9', '$2b$10$txnE9', 'active',    'verified'),
('Ritu Kapoor',      '9876543246', 'ritu.kapoor@gmail.com',      '23 Rohini, Delhi',              '$2b$10$loginF1', '$2b$10$txnF1', 'active',    'verified'),
('Harish Negi',      '9876543247', 'harish.negi@gmail.com',      '7 Saket, Delhi',                '$2b$10$loginF2', '$2b$10$txnF2', 'suspended', 'rejected'),
('Shobha Krishnan',  '9876543248', 'shobha.krishnan@gmail.com',  '46 Indiranagar, Bengaluru',     '$2b$10$loginF3', '$2b$10$txnF3', 'active',    'verified'),
('Karthik Menon',    '9876543249', 'karthik.menon@gmail.com',    '11 Koramangala, Bengaluru',     '$2b$10$loginF4', '$2b$10$txnF4', 'active',    'verified'),
('Lakshmi Sundar',   '9876543250', 'lakshmi.sundar@gmail.com',   '35 Whitefield, Bengaluru',      '$2b$10$loginF5', '$2b$10$txnF5', 'active',    'verified');

select * from users;


-- ============================================================
-- 2. WALLETS (50 records — one per user)
-- ============================================================
INSERT INTO Wallets (user_id, balance, upi_handle, is_active) VALUES
(1,  15000.00, 'arjun.sharma@nexus',     TRUE),
(2,  8500.50,  'priya.verma@nexus',      TRUE),
(3,  3200.75,  'rohit.nair@nexus',       TRUE),
(4,  22000.00, 'sneha.patel@nexus',      TRUE),
(5,  0.00,     'karan.mehta@nexus',      FALSE),
(6,  6750.25,  'divya.iyer@nexus',       TRUE),
(7,  11200.00, 'amit.desai@nexus',       TRUE),
(8,  4300.50,  'neha.joshi@nexus',       TRUE),
(9,  0.00,     'vikram.singh@nexus',     FALSE),
(10, 9100.00,  'pooja.rao@nexus',        TRUE),
(11, 18000.00, 'suresh.kumar@nexus',     TRUE),
(12, 5600.75,  'meena.pillai@nexus',     TRUE),
(13, 2100.00,  'ravi.gupta@nexus',       TRUE),
(14, 13500.50, 'anita.mishra@nexus',     TRUE),
(15, 0.00,     'deepak.trivedi@nexus',   FALSE),
(16, 7800.25,  'kavita.reddy@nexus',     TRUE),
(17, 24000.00, 'nitin.bhatt@nexus',      TRUE),
(18, 9900.00,  'swati.kulkarni@nexus',   TRUE),
(19, 3300.50,  'harsh.agarwal@nexus',    TRUE),
(20, 16000.00, 'sonal.shah@nexus',       TRUE),
(21, 4750.00,  'manish.pandey@nexus',    TRUE),
(22, 12500.75, 'rekha.nambiar@nexus',    TRUE),
(23, 0.00,     'anil.tiwari@nexus',      FALSE),
(24, 8200.00,  'priyanka.jain@nexus',    TRUE),
(25, 1950.50,  'sunil.yadav@nexus',      TRUE),
(26, 10500.00, 'archana.bhosle@nexus',   TRUE),
(27, 5100.25,  'tushar.more@nexus',      TRUE),
(28, 20000.00, 'lalita.deshpande@nexus', TRUE),
(29, 3800.00,  'ganesh.bhat@nexus',      TRUE),
(30, 7500.50,  'namrata.sawant@nexus',   TRUE),
(31, 14300.00, 'rajesh.patil@nexus',     TRUE),
(32, 0.00,     'usha.naik@nexus',        FALSE),
(33, 6100.75,  'prasad.limaye@nexus',    TRUE),
(34, 11800.00, 'geeta.chavan@nexus',     TRUE),
(35, 9200.50,  'vinod.kamat@nexus',      TRUE),
(36, 4400.00,  'shweta.barve@nexus',     TRUE),
(37, 17600.25, 'omkar.ghosh@nexus',      TRUE),
(38, 8050.00,  'tanuja.sen@nexus',       TRUE),
(39, 2700.50,  'bhaskar.das@nexus',      TRUE),
(40, 13100.00, 'puja.chatterjee@nexus',  TRUE),
(41, 6900.75,  'siddharth.roy@nexus',    TRUE),
(42, 21000.00, 'monika.banerjee@nexus',  TRUE),
(43, 3600.00,  'aakash.verma@nexus',     TRUE),
(44, 10200.50, 'sunita.khanna@nexus',    TRUE),
(45, 5500.25,  'devendra.malik@nexus',   TRUE),
(46, 18500.00, 'ritu.kapoor@nexus',      TRUE),
(47, 0.00,     'harish.negi@nexus',      FALSE),
(48, 7300.75,  'shobha.krishnan@nexus',  TRUE),
(49, 12700.00, 'karthik.menon@nexus',    TRUE),
(50, 9400.50,  'lakshmi.sundar@nexus',   TRUE);

-- ============================================================
-- 3. BANK ACCOUNTS (50 records)
-- ============================================================
INSERT INTO BankAccounts (user_id, bank_name, account_number, ifsc_code, is_primary) VALUES
(1,  'HDFC Bank',       '100000000000001', 'HDFC0001001', TRUE),
(2,  'ICICI Bank',      '100000000000002', 'ICIC0001002', TRUE),
(3,  'SBI',             '100000000000003', 'SBIN0001003', TRUE),
(4,  'Axis Bank',       '100000000000004', 'UTIB0001004', TRUE),
(5,  'Kotak Mahindra',  '100000000000005', 'KKBK0001005', TRUE),
(6,  'Yes Bank',        '100000000000006', 'YESB0001006', TRUE),
(7,  'HDFC Bank',       '100000000000007', 'HDFC0001007', TRUE),
(8,  'PNB',             '100000000000008', 'PUNB0001008', TRUE),
(9,  'ICICI Bank',      '100000000000009', 'ICIC0001009', TRUE),
(10, 'Bank of Baroda',  '100000000000010', 'BARB0001010', TRUE),
(11, 'SBI',             '100000000000011', 'SBIN0001011', TRUE),
(12, 'Canara Bank',     '100000000000012', 'CNRB0001012', TRUE),
(13, 'Union Bank',      '100000000000013', 'UBIN0001013', TRUE),
(14, 'HDFC Bank',       '100000000000014', 'HDFC0001014', TRUE),
(15, 'Axis Bank',       '100000000000015', 'UTIB0001015', TRUE),
(16, 'ICICI Bank',      '100000000000016', 'ICIC0001016', TRUE),
(17, 'Kotak Mahindra',  '100000000000017', 'KKBK0001017', TRUE),
(18, 'SBI',             '100000000000018', 'SBIN0001018', TRUE),
(19, 'HDFC Bank',       '100000000000019', 'HDFC0001019', TRUE),
(20, 'Yes Bank',        '100000000000020', 'YESB0001020', TRUE),
(21, 'PNB',             '100000000000021', 'PUNB0001021', TRUE),
(22, 'ICICI Bank',      '100000000000022', 'ICIC0001022', TRUE),
(23, 'Bank of Baroda',  '100000000000023', 'BARB0001023', TRUE),
(24, 'SBI',             '100000000000024', 'SBIN0001024', TRUE),
(25, 'Canara Bank',     '100000000000025', 'CNRB0001025', TRUE),
(26, 'HDFC Bank',       '100000000000026', 'HDFC0001026', TRUE),
(27, 'Axis Bank',       '100000000000027', 'UTIB0001027', TRUE),
(28, 'ICICI Bank',      '100000000000028', 'ICIC0001028', TRUE),
(29, 'Union Bank',      '100000000000029', 'UBIN0001029', TRUE),
(30, 'Yes Bank',        '100000000000030', 'YESB0001030', TRUE),
(31, 'SBI',             '100000000000031', 'SBIN0001031', TRUE),
(32, 'Kotak Mahindra',  '100000000000032', 'KKBK0001032', TRUE),
(33, 'HDFC Bank',       '100000000000033', 'HDFC0001033', TRUE),
(34, 'PNB',             '100000000000034', 'PUNB0001034', TRUE),
(35, 'ICICI Bank',      '100000000000035', 'ICIC0001035', TRUE),
(36, 'Canara Bank',     '100000000000036', 'CNRB0001036', TRUE),
(37, 'Axis Bank',       '100000000000037', 'UTIB0001037', TRUE),
(38, 'SBI',             '100000000000038', 'SBIN0001038', TRUE),
(39, 'Bank of Baroda',  '100000000000039', 'BARB0001039', TRUE),
(40, 'HDFC Bank',       '100000000000040', 'HDFC0001040', TRUE),
(41, 'ICICI Bank',      '100000000000041', 'ICIC0001041', TRUE),
(42, 'Union Bank',      '100000000000042', 'UBIN0001042', TRUE),
(43, 'Yes Bank',        '100000000000043', 'YESB0001043', TRUE),
(44, 'SBI',             '100000000000044', 'SBIN0001044', TRUE),
(45, 'Kotak Mahindra',  '100000000000045', 'KKBK0001045', TRUE),
(46, 'HDFC Bank',       '100000000000046', 'HDFC0001046', TRUE),
(47, 'PNB',             '100000000000047', 'PUNB0001047', TRUE),
(48, 'Axis Bank',       '100000000000048', 'UTIB0001048', TRUE),
(49, 'ICICI Bank',      '100000000000049', 'ICIC0001049', TRUE),
(50, 'Canara Bank',     '100000000000050', 'CNRB0001050', TRUE);

select * from bankaccounts;
-- ============================================================\

INSERT INTO Merchants (merchant_name, category, user_id) VALUES
('Reliance Fresh',        'Grocery',          1),
('BookMyShow',            'Entertainment',    2),
('Ola Cabs',              'Transport',        4),
('Zomato',                'Food & Dining',    6),
('Airtel',                'Telecom',          8),
('BigBasket',             'Grocery',          10),
('Netflix India',         'Entertainment',    11),
('Rapido',                'Transport',        12),
('Swiggy',                'Food & Dining',    14),
('Jio',                   'Telecom',          16),
('D-Mart',                'Grocery',          17),
('PVR Cinemas',           'Entertainment',    18),
('Uber India',            'Transport',        20),
('Dominos Pizza',         'Food & Dining',    21),
('BSNL',                  'Telecom',          22),
('Nykaa',                 'Beauty & Health',  24),
('Myntra',                'Fashion',          26),
('Amazon India',          'E-Commerce',       27),
('Flipkart',              'E-Commerce',       28),
('Meesho',                'E-Commerce',       30),
('HDFC Credit Card',      'Finance',          31),
('LIC Insurance',         'Finance',          33),
('SBI Mutual Fund',       'Finance',          34),
('Zerodha',               'Finance',          35),
('PharmEasy',             'Pharmacy',         36),
('Apollo Pharmacy',       'Pharmacy',         37),
('1mg',                   'Pharmacy',         38),
('MakeMyTrip',            'Travel',           40),
('IRCTC',                 'Travel',           41),
('EaseMyTrip',            'Travel',           42),
('Byju''s',               'Education',        43),
('Unacademy',             'Education',        44),
('Vedantu',               'Education',        45),
('Hotstar',               'Entertainment',    46),
('Sony LIV',              'Entertainment',    48),
('Paytm Mall',            'E-Commerce',       49),
('Tata CLiQ',             'E-Commerce',       50),
('BESCOM',                'Utility',          1),
('MSEDCL',                'Utility',          2),
('BWSSB',                 'Utility',          4),
('Indane Gas',            'Utility',          6),
('HP Gas',                'Utility',          8),
('Bharat Gas',            'Utility',          10),
('Hathway Internet',      'Internet',         11),
('ACT Fibernet',          'Internet',         12),
('JioFiber',              'Internet',         14),
('ICICI Lombard',         'Insurance',        16),
('Star Health',           'Insurance',        17),
('HDFC ERGO',             'Insurance',        18),
('Policy Bazaar',         'Finance',          20);


-- ============================================================
-- 5. TRANSACTIONS (50 records)
--  

INSERT INTO Transactions (txn_ref, txn_type, amount, fee, status, user_wallet_id, bank_id, merchant_id) VALUES
('TXN2024000001', 'send',     500.00,   2.50,  'success',    1,  1,  NULL),
('TXN2024000002', 'bill_pay', 999.00,   0.00,  'success',    2,  2,  2),
('TXN2024000003', 'send',     1500.00,  5.00,  'success',    3,  3,  NULL),
('TXN2024000004', 'request',  250.00,   0.00,  'processing', 4,  4,  NULL),
('TXN2024000005', 'bill_pay', 350.00,   3.50,  'success',    6,  6,  5),
('TXN2024000006', 'cashback', 50.00,    0.00,  'success',    1,  1,  1),
('TXN2024000007', 'send',     2000.00,  10.00, 'failed',     2,  2,  NULL),
('TXN2024000008', 'bill_pay', 499.00,   0.00,  'success',    3,  3,  5),
('TXN2024000009', 'send',     750.00,   3.75,  'success',    4,  4,  NULL),
('TXN2024000010', 'bill_pay', 1200.00,  6.00,  'processing', 6,  6,  3),
('TXN2024000011', 'send',     300.00,   1.50,  'success',    7,  7,  NULL),
('TXN2024000012', 'bill_pay', 850.00,   0.00,  'success',    8,  8,  6),
('TXN2024000013', 'request',  400.00,   0.00,  'success',    10, 10, NULL),
('TXN2024000014', 'send',     1800.00,  9.00,  'success',    11, 11, NULL),
('TXN2024000015', 'cashback', 100.00,   0.00,  'success',    12, 12, 7),
('TXN2024000016', 'bill_pay', 650.00,   3.25,  'success',    13, 13, 8),
('TXN2024000017', 'send',     950.00,   4.75,  'failed',     14, 14, NULL),
('TXN2024000018', 'bill_pay', 1100.00,  5.50,  'success',    16, 16, 9),
('TXN2024000019', 'request',  600.00,   0.00,  'processing', 17, 17, NULL),
('TXN2024000020', 'send',     2500.00,  12.50, 'success',    18, 18, NULL),
('TXN2024000021', 'cashback', 75.00,    0.00,  'success',    19, 19, 10),
('TXN2024000022', 'bill_pay', 450.00,   2.25,  'success',    20, 20, 11),
('TXN2024000023', 'send',     1700.00,  8.50,  'success',    21, 21, NULL),
('TXN2024000024', 'bill_pay', 900.00,   4.50,  'failed',     22, 22, 12),
('TXN2024000025', 'request',  350.00,   0.00,  'success',    24, 24, NULL),
('TXN2024000026', 'send',     5000.00,  25.00, 'success',    25, 25, NULL),
('TXN2024000027', 'bill_pay', 799.00,   0.00,  'success',    26, 26, 13),
('TXN2024000028', 'cashback', 200.00,   0.00,  'success',    27, 27, 14),
('TXN2024000029', 'send',     1250.00,  6.25,  'success',    28, 28, NULL),
('TXN2024000030', 'bill_pay', 550.00,   2.75,  'processing', 29, 29, 15),
('TXN2024000031', 'send',     800.00,   4.00,  'success',    30, 30, NULL),
('TXN2024000032', 'bill_pay', 1050.00,  5.25,  'success',    31, 31, 16),
('TXN2024000033', 'request',  700.00,   0.00,  'failed',     33, 33, NULL),
('TXN2024000034', 'send',     3000.00,  15.00, 'success',    34, 34, NULL),
('TXN2024000035', 'cashback', 150.00,   0.00,  'success',    35, 35, 17),
('TXN2024000036', 'bill_pay', 400.00,   2.00,  'success',    36, 36, 18),
('TXN2024000037', 'send',     2200.00,  11.00, 'success',    37, 37, NULL),
('TXN2024000038', 'bill_pay', 600.00,   3.00,  'success',    38, 38, 19),
('TXN2024000039', 'request',  950.00,   0.00,  'success',    40, 40, NULL),
('TXN2024000040', 'send',     1400.00,  7.00,  'failed',     41, 41, NULL),
('TXN2024000041', 'cashback', 125.00,   0.00,  'success',    42, 42, 20),
('TXN2024000042', 'bill_pay', 750.00,   3.75,  'success',    43, 43, 21),
('TXN2024000043', 'send',     1900.00,  9.50,  'success',    44, 44, NULL),
('TXN2024000044', 'bill_pay', 850.00,   4.25,  'success',    45, 45, 22),
('TXN2024000045', 'request',  500.00,   0.00,  'processing', 46, 46, NULL),
('TXN2024000046', 'send',     4500.00,  22.50, 'success',    48, 48, NULL),
('TXN2024000047', 'bill_pay', 699.00,   0.00,  'success',    49, 49, 23),
('TXN2024000048', 'cashback', 80.00,    0.00,  'success',    50, 50, 24),
('TXN2024000049', 'send',     1100.00,  5.50,  'success',    10, 10, NULL),
('TXN2024000050', 'bill_pay', 980.00,   4.90,  'failed',     11, 11, 25);


-- ============================================================
-- 6. TRANSACTION HISTORY (50 records)
--    txn_id refs 1-50
-- ============================================================
INSERT INTO TransactionHistory (txn_id, old_status, new_status, action_type, performed_by) VALUES
(1,  'processing', 'success',    'status_update',  'system'),
(2,  'processing', 'success',    'status_update',  'system'),
(3,  'processing', 'success',    'status_update',  'system'),
(4,  'processing', 'processing', 'retry',          'user'),
(5,  'processing', 'success',    'status_update',  'system'),
(6,  'processing', 'success',    'cashback_credit', 'system'),
(7,  'processing', 'failed',     'fraud_block',    'fraud_engine'),
(8,  'processing', 'success',    'status_update',  'system'),
(9,  'processing', 'success',    'status_update',  'system'),
(10, 'processing', 'processing', 'retry',          'user'),
(11, 'processing', 'success',    'status_update',  'system'),
(12, 'processing', 'success',    'status_update',  'system'),
(13, 'processing', 'success',    'status_update',  'system'),
(14, 'processing', 'success',    'status_update',  'system'),
(15, 'processing', 'success',    'cashback_credit', 'system'),
(16, 'processing', 'success',    'status_update',  'system'),
(17, 'processing', 'failed',     'fraud_block',    'fraud_engine'),
(18, 'processing', 'success',    'status_update',  'system'),
(19, 'processing', 'processing', 'retry',          'user'),
(20, 'processing', 'success',    'status_update',  'system'),
(21, 'processing', 'success',    'cashback_credit', 'system'),
(22, 'processing', 'success',    'status_update',  'system'),
(23, 'processing', 'success',    'status_update',  'system'),
(24, 'processing', 'failed',     'bank_decline',   'bank'),
(25, 'processing', 'success',    'status_update',  'system'),
(26, 'processing', 'success',    'status_update',  'system'),
(27, 'processing', 'success',    'status_update',  'system'),
(28, 'processing', 'success',    'cashback_credit', 'system'),
(29, 'processing', 'success',    'status_update',  'system'),
(30, 'processing', 'processing', 'retry',          'user'),
(31, 'processing', 'success',    'status_update',  'system'),
(32, 'processing', 'success',    'status_update',  'system'),
(33, 'processing', 'failed',     'bank_decline',   'bank'),
(34, 'processing', 'success',    'status_update',  'system'),
(35, 'processing', 'success',    'cashback_credit', 'system'),
(36, 'processing', 'success',    'status_update',  'system'),
(37, 'processing', 'success',    'status_update',  'system'),
(38, 'processing', 'success',    'status_update',  'system'),
(39, 'processing', 'success',    'status_update',  'system'),
(40, 'processing', 'failed',     'fraud_block',    'fraud_engine'),
(41, 'processing', 'success',    'cashback_credit', 'system'),
(42, 'processing', 'success',    'status_update',  'system'),
(43, 'processing', 'success',    'status_update',  'system'),
(44, 'processing', 'success',    'status_update',  'system'),
(45, 'processing', 'processing', 'retry',          'user'),
(46, 'processing', 'success',    'status_update',  'system'),
(47, 'processing', 'success',    'status_update',  'system'),
(48, 'processing', 'success',    'cashback_credit', 'system'),
(49, 'processing', 'success',    'status_update',  'system'),
(50, 'processing', 'failed',     'bank_decline',   'bank');


-- ============================================================
-- 7. FRAUD DETECTION (50 records)
--    txn_id and user_id must be valid
-- ============================================================
INSERT INTO FraudDetection (txn_id, user_id, rule_name, rule_type, threshold_value, risk_score, action_taken, fraud_status, ip_address, device_id, location) VALUES
(7,  2,  'High Amount Threshold',     'amount',   1500.00, 85, 'block',  'confirmed', '192.168.1.10',  'DEV-001', 'Mumbai, MH'),
(17, 14, 'Rapid Successive Txns',     'velocity', 3.00,    72, 'block',  'confirmed', '10.0.0.22',     'DEV-002', 'Mumbai, MH'),
(24, 22, 'Unusual Bank Decline',      'amount',   800.00,  60, 'flag',   'flagged',   '172.16.0.5',    'DEV-003', 'Thane, MH'),
(33, 33, 'Repeated Failed Request',   'velocity', 2.00,    55, 'flag',   'flagged',   '203.0.113.1',   'DEV-004', 'Pune, MH'),
(40, 41, 'High Amount Threshold',     'amount',   1200.00, 80, 'block',  'confirmed', '192.168.2.15',  'DEV-005', 'Kolkata, WB'),
(50, 11, 'Repeated Failed Payment',   'velocity', 2.00,    65, 'flag',   'flagged',   '10.0.1.33',     'DEV-006', 'Mumbai, MH'),
(4,  4,  'Rapid Successive Txns',     'velocity', 5.00,    60, 'flag',   'flagged',   '10.0.0.55',     'DEV-007', 'Pune, MH'),
(10, 6,  'Unusual Location',          'location', 0.00,    45, 'verify', 'cleared',   '203.0.113.10',  'DEV-008', 'Bengaluru, KA'),
(19, 17, 'New Device Login',          'device',   0.00,    40, 'verify', 'cleared',   '172.16.0.12',   'DEV-009', 'Delhi, DL'),
(30, 29, 'Incomplete Txn Retry',      'velocity', 3.00,    35, 'verify', 'cleared',   '192.168.3.20',  'DEV-010', 'Pune, MH'),
(45, 46, 'Processing Delay Flag',     'velocity', 2.00,    30, 'flag',   'cleared',   '10.0.2.44',     'DEV-011', 'Delhi, DL'),
(1,  1,  'Foreign IP Access',         'location', 0.00,    50, 'verify', 'cleared',   '45.33.32.156',  'DEV-012', 'Mumbai, MH'),
(2,  2,  'High Frequency Bill Pay',   'velocity', 4.00,    42, 'flag',   'cleared',   '192.168.1.11',  'DEV-013', 'Mumbai, MH'),
(3,  3,  'Unusual Amount Pattern',    'amount',   1200.00, 38, 'verify', 'cleared',   '10.0.0.60',     'DEV-014', 'Mumbai, MH'),
(5,  6,  'New Merchant Payment',      'amount',   300.00,  32, 'flag',   'cleared',   '172.16.0.20',   'DEV-015', 'Mumbai, MH'),
(6,  1,  'Cashback Abuse Attempt',    'amount',   0.00,    70, 'block',  'confirmed', '192.168.1.10',  'DEV-001', 'Mumbai, MH'),
(8,  3,  'Multiple Telecom Bills',    'velocity', 3.00,    44, 'flag',   'cleared',   '10.0.0.61',     'DEV-014', 'Mumbai, MH'),
(9,  4,  'Night Time Transaction',    'velocity', 0.00,    30, 'verify', 'cleared',   '172.16.1.5',    'DEV-016', 'Mumbai, MH'),
(11, 7,  'Mid Amount Send',           'amount',   200.00,  25, 'verify', 'cleared',   '192.168.4.1',   'DEV-017', 'Thane, MH'),
(12, 8,  'First Bill Payment',        'amount',   500.00,  28, 'flag',   'cleared',   '10.0.3.10',     'DEV-018', 'Thane, MH'),
(13, 10, 'Unverified Request',        'amount',   350.00,  33, 'flag',   'cleared',   '172.16.2.9',    'DEV-019', 'Mumbai, MH'),
(14, 11, 'Large Send Threshold',      'amount',   1500.00, 58, 'flag',   'flagged',   '192.168.5.2',   'DEV-020', 'Mumbai, MH'),
(15, 12, 'Cashback Multi Claim',      'amount',   0.00,    55, 'flag',   'flagged',   '10.0.4.7',      'DEV-021', 'Mumbai, MH'),
(16, 13, 'Unusual OTT Spend',         'amount',   600.00,  40, 'verify', 'cleared',   '172.16.3.15',   'DEV-022', 'Mumbai, MH'),
(18, 16, 'Duplicate Bill Pay',        'velocity', 2.00,    60, 'flag',   'flagged',   '192.168.6.3',   'DEV-023', 'Mumbai, MH'),
(20, 18, 'Large Wallet Send',         'amount',   2000.00, 62, 'flag',   'flagged',   '10.0.5.18',     'DEV-024', 'Mumbai, MH'),
(21, 19, 'Suspicious Cashback',       'amount',   0.00,    68, 'block',  'confirmed', '172.16.4.11',   'DEV-025', 'Mumbai, MH'),
(22, 20, 'Frequent Streaming Bills',  'velocity', 5.00,    35, 'verify', 'cleared',   '192.168.7.4',   'DEV-026', 'Mumbai, MH'),
(23, 21, 'Multiple Sends Same Day',   'velocity', 3.00,    48, 'flag',   'flagged',   '10.0.6.25',     'DEV-027', 'Thane, MH'),
(25, 24, 'Cross-City Request',        'location', 0.00,    30, 'verify', 'cleared',   '172.16.5.8',    'DEV-028', 'Palghar, MH'),
(26, 25, 'Large Amount Send',         'amount',   4000.00, 72, 'block',  'confirmed', '192.168.8.5',   'DEV-029', 'Palghar, MH'),
(27, 26, 'Odd Hour Bill Pay',         'velocity', 0.00,    28, 'verify', 'cleared',   '10.0.7.30',     'DEV-030', 'Palghar, MH'),
(28, 27, 'Cashback Same Merchant',    'amount',   0.00,    55, 'flag',   'flagged',   '172.16.6.14',   'DEV-031', 'Pune, MH'),
(29, 28, 'High Frequency Sends',      'velocity', 4.00,    50, 'flag',   'flagged',   '192.168.9.6',   'DEV-032', 'Pune, MH'),
(31, 30, 'Wallet Send After Reload',  'amount',   700.00,  32, 'verify', 'cleared',   '10.0.8.35',     'DEV-033', 'Pune, MH'),
(32, 31, 'Insurance Bill Spike',      'amount',   900.00,  45, 'flag',   'cleared',   '172.16.7.20',   'DEV-034', 'Pune, MH'),
(34, 34, 'Large Investment Send',     'amount',   2500.00, 66, 'flag',   'flagged',   '192.168.10.7',  'DEV-035', 'Pune, MH'),
(35, 35, 'Cashback Rule Exploit',     'amount',   0.00,    75, 'block',  'confirmed', '10.0.9.40',     'DEV-036', 'Pune, MH'),
(36, 36, 'Unusual E-Commerce Pay',    'amount',   350.00,  36, 'verify', 'cleared',   '172.16.8.25',   'DEV-037', 'Pune, MH'),
(37, 37, 'High Amount Cross-City',    'amount',   2000.00, 58, 'flag',   'flagged',   '192.168.11.8',  'DEV-038', 'Kolkata, WB'),
(38, 38, 'Repeated E-Commerce',       'velocity', 3.00,    42, 'flag',   'cleared',   '10.0.10.45',    'DEV-039', 'Kolkata, WB'),
(39, 40, 'Request from New Device',   'device',   0.00,    38, 'verify', 'cleared',   '172.16.9.30',   'DEV-040', 'Kolkata, WB'),
(41, 42, 'Cashback Repeat Trigger',   'amount',   0.00,    70, 'block',  'confirmed', '192.168.12.9',  'DEV-041', 'Kolkata, WB'),
(42, 43, 'First Payment New User',    'amount',   600.00,  30, 'verify', 'cleared',   '10.0.11.50',    'DEV-042', 'Delhi, DL'),
(43, 44, 'Large Send Delhi',          'amount',   1700.00, 55, 'flag',   'flagged',   '172.16.10.35',  'DEV-043', 'Delhi, DL'),
(44, 45, 'Insurance Spike',           'amount',   750.00,  42, 'flag',   'cleared',   '192.168.13.10', 'DEV-044', 'Delhi, DL'),
(46, 48, 'Large Send Bengaluru',      'amount',   4000.00, 78, 'block',  'confirmed', '10.0.12.55',    'DEV-045', 'Bengaluru, KA'),
(47, 49, 'Unusual E-Commerce Pay',    'amount',   600.00,  38, 'verify', 'cleared',   '172.16.11.40',  'DEV-046', 'Bengaluru, KA'),
(48, 50, 'Cashback Suspicious',       'amount',   0.00,    65, 'flag',   'flagged',   '192.168.14.11', 'DEV-047', 'Bengaluru, KA'),
(49, 10, 'High Frequency Sends',      'velocity', 4.00,    50, 'flag',   'flagged',   '172.16.12.45',  'DEV-048', 'Mumbai, MH');


-- ============================================================
-- 8. SERVICES (50 records)
--    bank_id is NOT NULL — must ref valid bank 1-50
--    merchant_id used for cashback/autopay/discount
-- ============================================================
INSERT INTO Services (user_id, service_type, service_name, coupon_code, discount_percent, cashback_amount, loan_amount, interest_rate, merchant_id, autopay_amount, frequency, next_due_date, validity_end, status, bank_id) VALUES
(1,  'coupon',    'Festive Discount',        'FEST2024',  10.00, NULL,    NULL,     NULL,  NULL, NULL,   NULL,      NULL,         '2024-12-31', 'active',  1),
(2,  'cashback',  'Movie Cashback',          NULL,        NULL,  75.00,   NULL,     NULL,  2,    NULL,   NULL,      NULL,         '2024-11-30', 'active',  2),
(3,  'discount',  'Grocery Save',            'GROC10',    10.00, NULL,    NULL,     NULL,  1,    NULL,   NULL,      NULL,         '2024-10-31', 'expired', 3),
(4,  'loan',      'Personal Loan',           NULL,        NULL,  NULL,    50000.00, 12.50, NULL, NULL,   NULL,      NULL,         '2025-06-30', 'active',  4),
(6,  'autopay',   'Zomato Pro Autopay',      NULL,        NULL,  NULL,    NULL,     NULL,  4,    199.00, 'monthly', '2024-12-01', '2025-12-01', 'active',  6),
(7,  'coupon',    'New User Coupon',         'NEWU50',    50.00, NULL,    NULL,     NULL,  NULL, NULL,   NULL,      NULL,         '2024-09-30', 'used',    7),
(8,  'cashback',  'Telecom Cashback',        NULL,        NULL,  50.00,   NULL,     NULL,  5,    NULL,   NULL,      NULL,         '2024-12-31', 'active',  8),
(10, 'discount',  'BigBasket Weekend',       'BB20',      20.00, NULL,    NULL,     NULL,  6,    NULL,   NULL,      NULL,         '2024-11-15', 'expired', 10),
(11, 'autopay',   'Netflix Monthly',         NULL,        NULL,  NULL,    NULL,     NULL,  7,    649.00, 'monthly', '2024-12-05', '2025-12-05', 'active',  11),
(12, 'loan',      'Education Loan',          NULL,        NULL,  NULL,    100000.00,10.00, NULL, NULL,   NULL,      NULL,         '2026-03-31', 'active',  12),
(13, 'coupon',    'Transport Promo',         'RIDO15',    15.00, NULL,    NULL,     NULL,  8,    NULL,   NULL,      NULL,         '2024-10-15', 'used',    13),
(14, 'cashback',  'Food Order Cashback',     NULL,        NULL,  100.00,  NULL,     NULL,  9,    NULL,   NULL,      NULL,         '2024-12-31', 'active',  14),
(16, 'discount',  'Jio Recharge Offer',      'JIO20',     20.00, NULL,    NULL,     NULL,  10,   NULL,   NULL,      NULL,         '2024-11-30', 'active',  16),
(17, 'autopay',   'D-Mart Weekly',           NULL,        NULL,  NULL,    NULL,     NULL,  11,   500.00, 'weekly',  '2024-12-07', '2025-12-07', 'active',  17),
(18, 'coupon',    'Cinema Discount',         'PVR25',     25.00, NULL,    NULL,     NULL,  12,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  18),
(19, 'cashback',  'Weekend Cashback',        NULL,        NULL,  60.00,   NULL,     NULL,  13,   NULL,   NULL,      NULL,         '2024-11-30', 'active',  19),
(20, 'loan',      'Home Improvement Loan',   NULL,        NULL,  NULL,    200000.00,11.00, NULL, NULL,   NULL,      NULL,         '2027-06-30', 'active',  20),
(21, 'discount',  'Pizza Tuesday Deal',      'PIZZA10',   10.00, NULL,    NULL,     NULL,  14,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  21),
(22, 'autopay',   'BSNL Broadband Auto',     NULL,        NULL,  NULL,    NULL,     NULL,  15,   299.00, 'monthly', '2024-12-10', '2025-12-10', 'active',  22),
(24, 'coupon',    'Beauty Sale Coupon',      'NYK30',     30.00, NULL,    NULL,     NULL,  16,   NULL,   NULL,      NULL,         '2024-11-11', 'used',    24),
(25, 'cashback',  'Fashion Week CB',         NULL,        NULL,  150.00,  NULL,     NULL,  17,   NULL,   NULL,      NULL,         '2024-10-31', 'expired', 25),
(26, 'discount',  'Amazon Prime Offer',      'AMZN15',    15.00, NULL,    NULL,     NULL,  18,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  26),
(27, 'loan',      'Vehicle Loan',            NULL,        NULL,  NULL,    300000.00,9.50,  NULL, NULL,   NULL,      NULL,         '2028-03-31', 'active',  27),
(28, 'autopay',   'Flipkart EMI Autopay',    NULL,        NULL,  NULL,    NULL,     NULL,  19,   1000.00,'monthly', '2024-12-15', '2025-06-15', 'active',  28),
(29, 'coupon',    'Meesho First Order',      'MEE50',     50.00, NULL,    NULL,     NULL,  20,   NULL,   NULL,      NULL,         '2024-09-30', 'expired', 29),
(30, 'cashback',  'Credit Card Reward',      NULL,        NULL,  200.00,  NULL,     NULL,  21,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  30),
(31, 'discount',  'LIC Premium Discount',    'LIC5',      5.00,  NULL,    NULL,     NULL,  22,   NULL,   NULL,      NULL,         '2025-03-31', 'active',  31),
(33, 'autopay',   'SBI MF SIP Auto',         NULL,        NULL,  NULL,    NULL,     NULL,  23,   2000.00,'monthly', '2024-12-20', '2026-12-20', 'active',  33),
(34, 'loan',      'Business Loan',           NULL,        NULL,  NULL,    500000.00,14.00, NULL, NULL,   NULL,      NULL,         '2026-09-30', 'active',  34),
(35, 'coupon',    'Trading Fee Waiver',      'ZRD100',    100.00,NULL,    NULL,     NULL,  24,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  35),
(36, 'cashback',  'Pharma Order CB',         NULL,        NULL,  40.00,   NULL,     NULL,  25,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  36),
(37, 'discount',  'Apollo Health Offer',     'APL10',     10.00, NULL,    NULL,     NULL,  26,   NULL,   NULL,      NULL,         '2025-01-31', 'active',  37),
(38, 'autopay',   '1mg Subscription Auto',   NULL,        NULL,  NULL,    NULL,     NULL,  27,   199.00, 'monthly', '2024-12-25', '2025-12-25', 'active',  38),
(40, 'coupon',    'Flight Discount',         'MMT20',     20.00, NULL,    NULL,     NULL,  28,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  40),
(41, 'cashback',  'IRCTC Rail CB',           NULL,        NULL,  80.00,   NULL,     NULL,  29,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  41),
(42, 'discount',  'EaseMyTrip Hotel Deal',   'EMT15',     15.00, NULL,    NULL,     NULL,  30,   NULL,   NULL,      NULL,         '2025-01-15', 'active',  42),
(43, 'loan',      'Education Loan',          NULL,        NULL,  NULL,    75000.00, 11.50, NULL, NULL,   NULL,      NULL,         '2026-06-30', 'active',  43),
(44, 'autopay',   'Unacademy Sub Auto',      NULL,        NULL,  NULL,    NULL,     NULL,  32,   1500.00,'monthly', '2024-12-01', '2025-12-01', 'active',  44),
(45, 'coupon',    'Ed-Tech Promo',           'VED25',     25.00, NULL,    NULL,     NULL,  33,   NULL,   NULL,      NULL,         '2024-11-30', 'expired', 45),
(46, 'cashback',  'Hotstar CB',              NULL,        NULL,  90.00,   NULL,     NULL,  34,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  46),
(48, 'discount',  'Sony LIV Discount',       'SLIV20',    20.00, NULL,    NULL,     NULL,  35,   NULL,   NULL,      NULL,         '2025-01-31', 'active',  48),
(49, 'autopay',   'Paytm Mall EMI',          NULL,        NULL,  NULL,    NULL,     NULL,  36,   800.00, 'monthly', '2024-12-10', '2025-06-10', 'active',  49),
(50, 'coupon',    'Tata CLiQ New User',      'TCQ10',     10.00, NULL,    NULL,     NULL,  37,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  50),
(1,  'cashback',  'Utility Bill CB',         NULL,        NULL,  30.00,   NULL,     NULL,  38,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  1),
(2,  'autopay',   'MSEDCL Electric Auto',    NULL,        NULL,  NULL,    NULL,     NULL,  39,   700.00, 'monthly', '2024-12-05', '2025-12-05', 'active',  2),
(4,  'discount',  'Water Bill Offer',        'WAT5',      5.00,  NULL,    NULL,     NULL,  40,   NULL,   NULL,      NULL,         '2025-03-31', 'active',  4),
(6,  'coupon',    'Gas Refill Coupon',       'GAS100',    NULL,  NULL,    NULL,     NULL,  41,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  6),
(8,  'cashback',  'HP Gas CB',               NULL,        NULL,  20.00,   NULL,     NULL,  42,   NULL,   NULL,      NULL,         '2024-12-31', 'active',  8),
(10, 'autopay',   'Hathway Internet Auto',   NULL,        NULL,  NULL,    NULL,     NULL,  44,   599.00, 'monthly', '2024-12-08', '2025-12-08', 'active',  10);


-- ============================================================
-- 9. SUPPORT TICKETS & REVIEWS (50 records)
--    user_id and txn_id must be valid
-- ============================================================
INSERT INTO SupportTickets__Reviews (user_id, txn_id, issue_type, description, status, rating, feedback_text, review_type, reviewed_at, resolved_at) VALUES
(2,  7,  'failed_transaction',   'My Rs.2000 payment was deducted but shows failed.',            'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(1,  1,  'cashback_not_credited','Cashback not received after successful send.',                 'resolved',    5,    'Very fast resolution, loved the support!', 'support',    '2024-09-15 10:30:00', '2024-09-15 12:00:00'),
(4,  4,  'payment_stuck',        'Payment stuck in processing state for over 24 hours.',         'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(3,  3,  'app_feedback',         'App UI is great but UPI sometimes lags.',                      'resolved',    4,    'Good app, minor UPI issues.',             'app',        '2024-09-20 14:00:00', '2024-09-20 14:00:00'),
(6,  5,  'wrong_amount',         'Extra fee was charged on Zomato bill payment.',                'in_progress', 2,    'Disappointed with extra charges.',        'transaction', '2024-09-22 09:00:00', NULL),
(14, 17, 'failed_transaction',   'Rs.950 sent but marked failed. Amount deducted.',              'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(22, 24, 'bank_decline',         'Bank declined my bill payment repeatedly.',                   'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(33, 33, 'payment_failed',       'Request payment failed with no reason shown.',                 'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(41, 40, 'fraud_complaint',      'Received OTP I never requested. Possible fraud attempt.',      'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(11, 50, 'bill_pay_failed',      'Pharmacy bill payment failed three times in a row.',           'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(8,  12, 'app_review',           'Very smooth BigBasket payment experience.',                   'resolved',    5,    'Seamless experience overall!',            'app',        '2024-09-25 10:00:00', '2024-09-25 10:00:00'),
(10, 13, 'general_query',        'Want to know how to increase wallet limit.',                   'resolved',    4,    'Support was helpful and quick.',           'support',    '2024-09-26 11:00:00', '2024-09-26 12:00:00'),
(12, 15, 'cashback_delay',       'Cashback from Netflix bill not credited yet.',                 'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(16, 18, 'duplicate_charge',     'Charged twice for the same streaming bill.',                  'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(18, 20, 'large_txn_review',     'Large send transaction of Rs.2500 was flagged. Why?',          'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(20, 22, 'bill_pay_success',     'Netflix payment went through perfectly.',                     'resolved',    5,    'App is brilliant for bill payments.',     'transaction', '2024-09-28 08:00:00', '2024-09-28 08:30:00'),
(21, 23, 'send_query',           'Not sure if recipient received the Rs.1700 send.',             'resolved',    4,    'Got confirmation quickly via support.',   'support',    '2024-09-29 09:00:00', '2024-09-29 10:00:00'),
(25, 26, 'fraud_alert',          'Got a fraud alert on my Rs.5000 transaction. Please review.', 'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(27, 28, 'cashback_query',       'Why did I get only Rs.200 cashback instead of Rs.500?',        'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(28, 29, 'send_failed',          'Sent Rs.1250 to wrong UPI handle. Need refund.',               'in_progress', 1,    'Process was slow and stressful.',         'support',    '2024-10-01 10:00:00', NULL),
(30, 31, 'general_feedback',     'Great app for daily wallet sends.',                           'resolved',    5,    'Keep up the excellent service!',          'app',        '2024-10-02 11:00:00', '2024-10-02 11:00:00'),
(31, 32, 'bill_pay_query',       'Insurance payment processed but not reflected in policy.',    'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(34, 34, 'large_txn_query',      'Rs.3000 send to SBI investment account. Confirm receipt.',    'resolved',    4,    'Was resolved efficiently.',               'support',    '2024-10-03 09:00:00', '2024-10-03 10:30:00'),
(35, 35, 'cashback_dispute',     'Cashback of Rs.150 was not added to wallet.',                 'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(37, 37, 'fraud_query',          'Large send was flagged. Requesting de-flag.',                  'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(38, 38, 'bill_pay_slow',        'E-commerce bill payment took 10 min to confirm.',              'resolved',    3,    'Slow but eventually worked fine.',        'transaction', '2024-10-05 12:00:00', '2024-10-05 13:00:00'),
(40, 39, 'request_delayed',      'Payment request to friend pending for 2 days.',               'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(42, 41, 'cashback_blocked',     'Cashback was blocked. Says fraud review pending.',             'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(43, 42, 'first_payment',        'First ever bill payment via NexusPay — very easy!',           'resolved',    5,    'Simple and smooth experience.',           'app',        '2024-10-07 08:00:00', '2024-10-07 08:00:00'),
(44, 43, 'send_review',          'Rs.1900 send was fast and reliable.',                         'resolved',    5,    'Great transaction speed!',                'transaction', '2024-10-08 09:00:00', '2024-10-08 09:00:00'),
(45, 44, 'bill_query',           'Insurance payment via NexusPay — will it auto-renew?',        'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(46, 45, 'processing_stuck',     'Payment to service merchant stuck in processing.',             'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(48, 46, 'large_send_flag',      'Rs.4500 flagged as suspicious. I initiated it myself.',        'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(49, 47, 'bill_pay_review',      'E-commerce bill payment to Paytm Mall was perfect.',          'resolved',    4,    'Reliable service, minor UI lag.',         'transaction', '2024-10-10 10:00:00', '2024-10-10 11:00:00'),
(50, 48, 'cashback_pending',     'Cashback of Rs.80 still pending after 3 days.',               'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(10, 49, 'send_query',           'Sent Rs.1100 — confirmation message not received.',           'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(11, 50, 'bill_failed_retry',    'Tried bill payment 3 times. All failed. Charged once?',       'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(1,  6,  'cashback_review',      'Cashback from Reliance was instantly credited. Loved it!',    'resolved',    5,    'Best cashback turnaround time!',          'transaction', '2024-10-12 08:00:00', '2024-10-12 08:00:00'),
(2,  2,  'bill_feedback',        'BookMyShow payment went through without any OTP lag.',        'resolved',    4,    'Smooth experience overall.',              'transaction', '2024-10-13 09:00:00', '2024-10-13 09:30:00'),
(3,  8,  'app_complaint',        'App crashed during Airtel bill payment. Lost Rs.499.',        'in_progress', 1,    'Very bad experience. Need refund.',        'app',        '2024-10-14 10:00:00', NULL),
(4,  9,  'send_success',         'Rs.750 reached friend instantly. Great service!',             'resolved',    5,    'Fast and reliable sends.',                'transaction', '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
(6,  10, 'slow_processing',      'Ola cab bill still processing after 1 hour.',                 'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(7,  11, 'first_send',           'First send via NexusPay. Was seamless.',                      'resolved',    5,    'Excellent new user experience!',          'app',        '2024-10-16 10:00:00', '2024-10-16 10:00:00'),
(8,  12, 'telecom_pay',          'BigBasket bill payment was confirmed instantly.',             'resolved',    4,    'Quick confirmation, happy with service.', 'transaction', '2024-10-17 11:00:00', '2024-10-17 11:30:00'),
(13, 16, 'excess_fee',           'Charged Rs.3.25 fee on a Rs.650 bill. Seems high.',           'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(19, 21, 'cashback_issue',       'Cashback for Uber ride not showing in wallet.',               'in_progress', NULL, NULL,                                    NULL,          NULL,                   NULL),
(24, 25, 'request_issue',        'Payment request to colleague declined unexpectedly.',          'open',        NULL, NULL,                                    NULL,          NULL,                   NULL),
(29, 30, 'delay_complaint',      'Bill payment in processing state for 5 hours now.',           'in_progress', 2,    'Too slow. Needs improvement.',            'support',    '2024-10-20 14:00:00', NULL),
(36, 36, 'merchant_review',      'Amazon bill payment was instant and hassle-free.',            'resolved',    5,    'Keep building on this speed!',            'transaction', '2024-10-21 08:00:00', '2024-10-21 08:00:00'),
(17, 19, 'processing_query',     'D-Mart request payment still pending. Please check.',         'open',        NULL, NULL,                                    NULL,          NULL,                   NULL);