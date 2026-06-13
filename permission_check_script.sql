-- 权限检查和分配脚本
-- 用于食品安全追溯系统

-- 1. 检查当前用户权限
SELECT 
    u.username,
    u.email,
    GROUP_CONCAT(DISTINCT r.name) as roles,
    GROUP_CONCAT(DISTINCT a.authority) as authorities
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
LEFT JOIN role_authorities ra ON r.id = ra.role_id
LEFT JOIN authorities a ON ra.authority_id = a.id
WHERE u.username = 'newuser'
GROUP BY u.id, u.username, u.email;

-- 2. 检查系统中所有可用的权限
SELECT * FROM authorities ORDER BY authority;

-- 3. 检查系统中所有可用的角色
SELECT 
    r.name as role_name,
    r.description,
    GROUP_CONCAT(a.authority) as authorities
FROM roles r
LEFT JOIN role_authorities ra ON r.id = ra.role_id
LEFT JOIN authorities a ON ra.authority_id = a.id
GROUP BY r.id, r.name, r.description;

-- 4. 为用户 newuser 分配基础权限（如果权限表存在）
-- 注意：请根据实际的数据库表结构调整以下SQL

-- 方案A：直接分配权限给用户
INSERT IGNORE INTO user_authorities (user_id, authority_id)
SELECT u.id, a.id
FROM users u, authorities a
WHERE u.username = 'newuser'
AND a.authority IN (
    'SAFETY_INDEX_VIEW',
    'USER_PROFILE_VIEW', 
    'USER_SETTINGS_VIEW',
    'AR_PACKAGE_VIEW',
    'RISK_ANALYSIS_VIEW',
    'PRODUCT_VIEW'
);

-- 方案B：为用户分配角色（推荐）
-- 首先创建一个基础用户角色（如果不存在）
INSERT IGNORE INTO roles (name, description) 
VALUES ('BASIC_USER', '基础用户角色，包含查看权限');

-- 为角色分配权限
INSERT IGNORE INTO role_authorities (role_id, authority_id)
SELECT r.id, a.id
FROM roles r, authorities a
WHERE r.name = 'BASIC_USER'
AND a.authority IN (
    'SAFETY_INDEX_VIEW',
    'USER_PROFILE_VIEW',
    'USER_SETTINGS_VIEW', 
    'AR_PACKAGE_VIEW',
    'RISK_ANALYSIS_VIEW',
    'PRODUCT_VIEW'
);

-- 为用户分配角色
INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u, roles r
WHERE u.username = 'newuser'
AND r.name = 'BASIC_USER';

-- 5. 验证权限分配结果
SELECT 
    u.username,
    'Direct Authority' as source,
    a.authority
FROM users u
JOIN user_authorities ua ON u.id = ua.user_id
JOIN authorities a ON ua.authority_id = a.id
WHERE u.username = 'newuser'

UNION ALL

SELECT 
    u.username,
    CONCAT('Role: ', r.name) as source,
    a.authority
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
JOIN role_authorities ra ON r.id = ra.role_id
JOIN authorities a ON ra.authority_id = a.id
WHERE u.username = 'newuser'

ORDER BY authority;

-- 6. 如果使用简化的权限模型，可能需要以下SQL
-- （根据实际表结构调整）

-- 检查用户表中的权限字段
SELECT username, roles, permissions FROM users WHERE username = 'newuser';

-- 更新用户权限（如果权限存储在用户表中）
UPDATE users 
SET permissions = CONCAT(IFNULL(permissions, ''), 
    ',SAFETY_INDEX_VIEW,USER_PROFILE_VIEW,AR_PACKAGE_VIEW,RISK_ANALYSIS_VIEW,PRODUCT_VIEW')
WHERE username = 'newuser';

-- 或者更新角色字段
UPDATE users 
SET roles = 'USER,BASIC_USER'
WHERE username = 'newuser';

-- 7. 创建测试用户（可选）
INSERT IGNORE INTO users (username, password, email, enabled) 
VALUES ('testuser', '$2a$10$encrypted_password', 'test@example.com', 1);

-- 为测试用户分配完整权限
INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u, roles r
WHERE u.username = 'testuser'
AND r.name = 'ADMIN'; -- 或其他管理员角色
