CREATE USER 'authorization-service'@'%' IDENTIFIED BY '<<gen-pass-auth-service>>';
GRANT ALL PRIVILEGES ON authorization.* TO 'authorization-service'@'%';
FLUSH PRIVILEGES;